#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026 Qualcomm Technologies, Inc. All rights reserved.
"""
Generate an HTML visualization of an AudioReach .conf topology.

Parses an alsa-topology .conf (output of m4) and emits an HTML page with:
  - a high-level Mermaid flowchart (FE PCMs, mixer widgets, BE DAIs, subgraph groups,
    control links as dashed edges)
  - a low-level Mermaid flowchart that expands every subgraph and shows the
    individual module chain and the actual routes between them
  - tables of DAI endpoints, controls, and control links

Usage:
    gen_topology_html.py <input.conf> [<output.html>]
    gen_topology_html.py <build-dir>          # process every .conf under build-dir

No third-party dependencies. The emitted HTML pulls Mermaid.js from a CDN.
"""

from __future__ import annotations

import html as H
import pathlib
import re
import sys
from collections import defaultdict


# ---------------------------------------------------------------------------
# Minimal parser for alsa-topology .conf (nested { } blocks + [ ] arrays)
# ---------------------------------------------------------------------------

RE_SECTION = re.compile(r'^(Section\w+)\.\s*"([^"]+)"\s*\{')
RE_NESTED_NAMED = re.compile(r'^(\w+)\.\s*"([^"]+)"\s*\{')
RE_NESTED_DOTTED = re.compile(r'^(\w+)\.(\w+)\s*\{')
RE_NESTED = re.compile(r'^(\w+)\s*\{')
RE_ARRAY = re.compile(r'^(\w+)\s*\[\s*$')
RE_KV_Q = re.compile(r'^(\w+)\s+"([^"]*)"\s*$')
RE_KV_BARE = re.compile(r'^(\w+)\s+([^\s"][^\s]*)\s*$')


def _skip(line: str) -> bool:
    s = line.strip()
    return not s or s.startswith('#')


def parse_conf(text: str) -> dict:
    """Return {Section: {Name: body}} where body is a nested dict/list tree."""
    lines = text.splitlines()
    i = [0]

    def peek():
        while i[0] < len(lines) and _skip(lines[i[0]]):
            i[0] += 1
        return lines[i[0]].strip() if i[0] < len(lines) else None

    def parse_body():
        body = {}
        while i[0] < len(lines):
            s = peek()
            if s is None:
                return body
            if s.startswith('}'):
                i[0] += 1
                return body
            m = RE_NESTED_NAMED.match(s)
            if m:
                i[0] += 1
                body.setdefault(m.group(1), {})[m.group(2)] = parse_body()
                continue
            m = RE_NESTED_DOTTED.match(s)
            if m:
                i[0] += 1
                body.setdefault(m.group(1), {})[m.group(2)] = parse_body()
                continue
            m = RE_ARRAY.match(s)
            if m:
                i[0] += 1
                arr = []
                while i[0] < len(lines):
                    t = lines[i[0]].strip()
                    if t.startswith(']'):
                        i[0] += 1
                        break
                    if t and not t.startswith('#'):
                        arr.append(t.strip(',').strip().strip('"'))
                    i[0] += 1
                body[m.group(1)] = arr
                continue
            m = RE_NESTED.match(s)
            if m:
                i[0] += 1
                body[m.group(1)] = parse_body()
                continue
            m = RE_KV_Q.match(s)
            if m:
                body[m.group(1)] = m.group(2)
                i[0] += 1
                continue
            m = RE_KV_BARE.match(s)
            if m:
                body[m.group(1)] = m.group(2)
                i[0] += 1
                continue
            # bare word (e.g. a member inside an inline SectionWidget.mixer list)
            if re.match(r'^\S+$', s):
                body.setdefault('_bare', []).append(s)
            i[0] += 1
        return body

    sections = {}
    while i[0] < len(lines):
        s = peek()
        if s is None:
            break
        m = RE_SECTION.match(s)
        if m:
            i[0] += 1
            sections.setdefault(m.group(1), {})[m.group(2)] = parse_body()
        else:
            i[0] += 1
    return sections


def _find(body, key):
    """Depth-first search for the first value under key."""
    if isinstance(body, dict):
        if key in body:
            return body[key]
        for v in body.values():
            r = _find(v, key)
            if r is not None:
                return r
    elif isinstance(body, list):
        for v in body:
            r = _find(v, key)
            if r is not None:
                return r
    return None


# ---------------------------------------------------------------------------
# Extract an opinionated graph model from the parsed sections
# ---------------------------------------------------------------------------

def _subgraph_of(name: str) -> str:
    m = re.match(r'^(stream\d+|device\d+)\.', name)
    return m.group(1) if m else ''


def _norm_iid(s) -> int | str:
    try:
        return int(str(s).strip().strip('"'), 0)
    except (TypeError, ValueError):
        return str(s)


def extract(sections: dict) -> dict:
    pcm_caps = sections.get('SectionPCMCapabilities', {})

    data = {
        'fe_pcms': [],       # (name, direction, caps_dict)
        'be_dais': [],       # (name, direction, stream_name, subgraph)
        'widgets': {},       # name -> {type, stream_name, iid, subgraph}
        'mixers': [],        # mixer widget names
        'routes': [],        # (src, label, dst)  — raw from SectionGraph lines
        'subgraphs': defaultdict(list),  # sg -> [widget names in that sg]
        'controls_mixer': [],   # (name, info_id, get_id)
        'controls_enum': [],    # (name, [texts])
        'ctl_links': [],        # dict with peer names, iids, intent
        'iid_to_widget': {},
    }

    # FE PCMs + their capability block
    for name, pcm in sections.get('SectionPCM', {}).items():
        pcm_dir = 'playback' if 'playback' in pcm.get('pcm', {}) else 'capture'
        cap_name = pcm.get('pcm', {}).get(pcm_dir, {}).get('capabilities', '')
        caps = pcm_caps.get(cap_name, {})
        data['fe_pcms'].append((name, pcm_dir, caps))

    # Widgets: types matter — aif_in/out are BE DAI endpoints, mixer are DAPM mixers
    for wname, w in sections.get('SectionWidget', {}).items():
        wtype = w.get('type', '')
        stream = w.get('stream_name', '')
        sg = _subgraph_of(wname)
        # find the matching vendor tuples section to pull module IID
        iid = None
        tuples = sections.get('SectionVendorTuples', {})
        candidate = f'{wname}_tuples'
        if candidate in tuples:
            iid = _find(tuples[candidate], 'AR_TKN_U32_MODULE_INSTANCE_ID')
        if iid is None:
            # fall back: scan every tuple section that has this widget's name as a prefix
            for tn, tb in tuples.items():
                if tn.startswith(wname + '_'):
                    iid = _find(tb, 'AR_TKN_U32_MODULE_INSTANCE_ID')
                    if iid is not None:
                        break
        data['widgets'][wname] = {
            'type': wtype,
            'stream_name': stream,
            'iid': iid,
            'subgraph': sg,
        }
        if iid is not None:
            data['iid_to_widget'][_norm_iid(iid)] = wname
        if sg:
            data['subgraphs'][sg].append(wname)
        if wtype == 'mixer':
            data['mixers'].append(wname)
        if wtype in ('aif_in', 'aif_out'):
            direction = 'playback' if wtype == 'aif_in' else 'capture'
            data['be_dais'].append((wname, direction, stream, sg))

    # Routes: `dst, label, src` per SectionGraph.lines entry
    for gname, g in sections.get('SectionGraph', {}).items():
        for line in g.get('lines', []):
            parts = [p.strip() for p in line.split(',')]
            if len(parts) >= 3:
                dst, label, src = parts[0], parts[1], parts[2]
                data['routes'].append((src, label, dst))

    # Controls — compose the full kcontrol name as "<mixer-widget> <switch>".
    # One SectionControlMixer definition can be shared by multiple mixer
    # widgets (e.g. a single `MultiMedia1` switch is reused by every playback
    # mixer that routes MM1), so iterate over mixer widgets to emit a row per
    # kcontrol instance. Standalone controls not attached to any mixer widget
    # (e.g. SP R0T0) are emitted once with their declared name.
    control_mixer_defs = sections.get('SectionControlMixer', {})
    attached_switches = set()
    for wn, w in sections.get('SectionWidget', {}).items():
        if w.get('type') != 'mixer':
            continue
        for sw in w.get('mixer', []):
            attached_switches.add(sw)
            c = control_mixer_defs.get(sw, {})
            ctl = c.get('ops', {}).get('ctl', {})
            data['controls_mixer'].append(
                (f'{wn} {sw}', ctl.get('info', ''), ctl.get('get', ''))
            )
    for name, c in control_mixer_defs.items():
        if name in attached_switches:
            continue
        ctl = c.get('ops', {}).get('ctl', {})
        data['controls_mixer'].append(
            (name, ctl.get('info', ''), ctl.get('get', ''))
        )

    for name, c in sections.get('SectionControlEnum', {}).items():
        txts_ref = c.get('texts', '')
        texts = sections.get('SectionText', {}).get(txts_ref, {}).get('values', [])
        data['controls_enum'].append((name, texts))

    # Control links: scan every VendorTuples block for CONTROL_LINK tokens.
    # The conf typically declares the same link twice — once from each peer
    # subgraph side — so dedupe by the unordered (peer1, peer2) pair + intent.
    seen_links = set()
    for tn, tb in sections.get('SectionVendorTuples', {}).items():
        p1 = _find(tb, 'AR_TKN_U32_CONTROL_LINK_PEER1_MOD_IID')
        p2 = _find(tb, 'AR_TKN_U32_CONTROL_LINK_PEER2_MOD_IID')
        if not (p1 and p2):
            continue
        intent = _find(tb, 'AR_TKN_U32_CONTROL_LINK_INTENT0') or '0'
        key = (tuple(sorted((_norm_iid(p1), _norm_iid(p2)), key=repr)), str(intent))
        if key in seen_links:
            continue
        seen_links.add(key)
        data['ctl_links'].append({
            'peer1_iid': p1,
            'peer2_iid': p2,
            'peer1_port': _find(tb, 'AR_TKN_U32_CONTROL_LINK_PEER1_MOD_PORT_ID') or '',
            'peer2_port': _find(tb, 'AR_TKN_U32_CONTROL_LINK_PEER2_MOD_PORT_ID') or '',
            'intent0': intent,
            'link_iid': _find(tb, 'AR_TKN_U32_CONTROL_LINK_IID') or '',
            'peer1_name': data['iid_to_widget'].get(_norm_iid(p1), f'iid {p1}'),
            'peer2_name': data['iid_to_widget'].get(_norm_iid(p2), f'iid {p2}'),
        })

    return data


# ---------------------------------------------------------------------------
# Mermaid rendering
# ---------------------------------------------------------------------------

_MID = re.compile(r'[^A-Za-z0-9_]')


def mid(name: str) -> str:
    return _MID.sub('_', name)


def find_fe_chains(d: dict) -> list:
    """
    For each FE PCM, enumerate every mixer its stream SG reaches and, for each
    mixer, the device SG(s) on its other side. Returns one chain per
    (FE, mixer) pair — a FE that fans into N mixers yields N chains.
    """
    chains = []
    for name, direction, caps in d['fe_pcms']:
        aif_type = 'aif_in' if direction == 'playback' else 'aif_out'
        stream_sg = None
        for wn, w in d['widgets'].items():
            if w['type'] == aif_type and w['stream_name'] == name:
                stream_sg = w['subgraph']
                break
        if not stream_sg:
            continue

        # Every mixer touching this stream SG
        mixers = []
        for src, _lbl, dst in d['routes']:
            if direction == 'playback':
                s_sg = d['widgets'].get(src, {}).get('subgraph', '')
                dw = d['widgets'].get(dst, {})
                if s_sg == stream_sg and dw.get('type') == 'mixer' and dst not in mixers:
                    mixers.append(dst)
            else:
                sw = d['widgets'].get(src, {})
                d_sg = d['widgets'].get(dst, {}).get('subgraph', '')
                if sw.get('type') == 'mixer' and d_sg == stream_sg and src not in mixers:
                    mixers.append(src)

        if not mixers:
            mixers = [None]  # keep solo FEs visible

        for mixer in mixers:
            devs = []
            seen_sg = set()
            if mixer is not None:
                for src, label, dst in d['routes']:
                    if direction == 'playback' and src == mixer:
                        dsg = d['widgets'].get(dst, {}).get('subgraph', '')
                        if dsg and dsg != stream_sg and dsg not in seen_sg:
                            seen_sg.add(dsg)
                            devs.append({'sg': dsg, 'label': label})
                    elif direction == 'capture' and dst == mixer:
                        dsg = d['widgets'].get(src, {}).get('subgraph', '')
                        if dsg and dsg != stream_sg and dsg not in seen_sg:
                            seen_sg.add(dsg)
                            devs.append({'sg': dsg, 'label': label})
            for dev in devs:
                be = next(((n, s) for n, _, s, sg in d['be_dais'] if sg == dev['sg']), None)
                dev['be_dai'] = be
            chains.append({
                'fe': name,
                'direction': direction,
                'caps': caps,
                'stream_sg': stream_sg,
                'mixer': mixer,
                'devices': devs,
            })
    return chains


def group_by_mixer(chains: list) -> list:
    """
    Collapse per-FE chains into one block per unique mixer. Multiple FEs that
    reach the same mixer become its FE side; the mixer's device-side devices
    are deduped so each device SG is drawn once per block.
    """
    seen = {}
    groups = []
    for c in chains:
        key = c['mixer'] or f'__solo__::{c["fe"]}'
        g = seen.get(key)
        if g is None:
            g = {
                'mixer': c['mixer'],
                'direction': c['direction'],
                'fes': [],
                'devices': [],
                '_fe_set': set(),
                '_dev_set': set(),
            }
            seen[key] = g
            groups.append(g)
        if c['fe'] not in g['_fe_set']:
            g['_fe_set'].add(c['fe'])
            g['fes'].append({
                'fe': c['fe'], 'stream_sg': c['stream_sg'], 'caps': c['caps'],
            })
        for dev in c['devices']:
            if dev['sg'] not in g['_dev_set']:
                g['_dev_set'].add(dev['sg'])
                g['devices'].append(dev)
    return groups


def svg_high_level(d: dict, title: str) -> str:
    """
    Hand-drawn SVG, one block per mixer: multiple FEs on top, mixer in the
    middle, deduped device SG(s) with their BE DAI(s) on the bottom.
    Playback groups drawn first, then capture groups, stacked vertically.
    Dashed red arc shows an AudioReach control link between two device SGs
    (within or across groups).
    """
    chains = find_fe_chains(d)
    groups = group_by_mixer(chains)
    pb = [g for g in groups if g['direction'] == 'playback']
    cap = [g for g in groups if g['direction'] == 'capture']

    LW = 220
    MARGIN = 24
    LANE_GAP = 20
    GROUP_H_GAP = 40        # horizontal gap between groups in a row
    GROUP_V_GAP = 56        # vertical gap between rows (and pb/cap bands)
    MAX_WIDTH = 1400        # wrap into a new row once width would exceed this
    H_small = 60
    H_tall = 96
    ROW_GAP = 20

    EDGE = '#5a5a5a'
    INK = '#111'
    QUIET = '#666'
    ACCENT = '#2d6cdf'
    ACCENT_BG = '#eef4ff'
    ACCENT2 = '#c33a2b'
    FE_BG = '#f0f3f8'       # neutral light-blue fill for FE PCM boxes
    BE_BG = '#f6f3ec'       # neutral light-cream fill for BE DAI boxes

    # Pre-compute per-group lane counts and widths
    def gw(g):
        fe_n = max(1, len(g['fes']))
        dev_n = max(1, len(g['devices']))
        lanes = max(fe_n, dev_n)
        return fe_n, dev_n, lanes, lanes * LW + (lanes - 1) * LANE_GAP

    pb_metas = [gw(g) for g in pb]
    cap_metas = [gw(g) for g in cap]
    all_metas = pb_metas + cap_metas
    cell_w = max((m[3] for m in all_metas), default=400)

    cell_pitch = cell_w + GROUP_H_GAP
    cols = max(1, (MAX_WIDTH - 2 * MARGIN + GROUP_H_GAP) // cell_pitch)
    cols = min(cols, max(len(pb), len(cap), 1))

    def row_count(n):
        return 0 if n == 0 else (n + cols - 1) // cols

    pb_rows = row_count(len(pb))
    cap_rows = row_count(len(cap))

    group_h = (H_small + ROW_GAP + H_tall + ROW_GAP + H_small
               + ROW_GAP + H_tall + ROW_GAP + H_small)

    used_cols = min(cols, max(len(pb), len(cap), 1))
    width = max(760, 2 * MARGIN + used_cols * cell_w + (used_cols - 1) * GROUP_H_GAP)
    height = 72 + (pb_rows + cap_rows) * (group_h + GROUP_V_GAP) + 20

    def rect(cx, cy, w, h, accent=False, fill=None):
        f = fill if fill is not None else (ACCENT_BG if accent else 'none')
        return (
            f'<rect x="{cx - w // 2}" y="{cy - h // 2}" width="{w}" height="{h}" '
            f'rx="8" fill="{f}" '
            f'stroke="{ACCENT if accent else EDGE}" '
            f'stroke-width="{2 if accent else 1.25}"/>'
        )

    def label(x, y, s, size=13, color=None, weight=400, anchor='middle'):
        col = color if color else INK
        return (
            f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-size="{size}" '
            f'font-weight="{weight}" fill="{col}">{H.escape(s)}</text>'
        )

    def arrv(x, y1, y2, marker='arr'):
        color = ACCENT2 if marker == 'arrctl' else EDGE
        return (
            f'<path d="M{x} {y1}L{x} {y2}" fill="none" stroke="{color}" '
            f'stroke-width="1.25" marker-end="url(#{marker})"/>'
        )

    def line(x1, y1, x2, y2):
        return (
            f'<path d="M{x1} {y1}L{x2} {y2}" fill="none" '
            f'stroke="{EDGE}" stroke-width="1.25"/>'
        )

    def sg_mods(sg):
        return [n.rsplit('.', 1)[-1]
                for n in d['subgraphs'].get(sg, [])
                if d['widgets'][n]['type'] not in ('aif_in', 'aif_out', 'mixer')]

    def wrap_arrows(mods, max_chars):
        """Pack ' -> ' joined names into lines, each at most max_chars wide."""
        if not mods:
            return ['—']
        sep = ' → '
        lines = []
        cur = ''
        for m in mods:
            piece = m if not cur else sep + m
            if cur and len(cur) + len(piece) > max_chars:
                lines.append(cur)
                cur = m
            else:
                cur += piece
        if cur:
            lines.append(cur)
        return lines

    def shorten_rate(r_min, r_max):
        """48000 -> '48 kHz'; '8000-48000' -> '8–48 kHz'."""
        if not r_min:
            return ''
        def k(v):
            try:
                v = int(v)
            except ValueError:
                return str(v)
            return f'{v // 1000}' if v % 1000 == 0 else f'{v / 1000:g}'
        if r_min == r_max:
            return f'{k(r_min)} kHz'
        return f'{k(r_min)}–{k(r_max)} kHz'

    out = []
    out.append(
        f'<svg viewBox="0 0 {width} {height}" width="{width}" height="{height}" '
        f'xmlns="http://www.w3.org/2000/svg" '
        'font-family="system-ui, -apple-system, Segoe UI, Helvetica, Arial, sans-serif" '
        'font-size="13">'
    )
    out.append('<defs>')
    out.append(
        f'<marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" '
        f'markerHeight="6" orient="auto-start-reverse">'
        f'<path d="M0 0L10 5L0 10z" fill="{EDGE}"/></marker>'
    )
    out.append(
        f'<marker id="arrctl" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" '
        f'markerHeight="6" orient="auto-start-reverse">'
        f'<path d="M0 0L10 5L0 10z" fill="{ACCENT2}"/></marker>'
    )
    out.append('</defs>')
    out.append(label(24, 28, title, size=15, weight=600, anchor='start'))
    out.append(label(24, 48,
                     'One block per mixer · FEs on top, deduped device SGs on bottom'
                     ' · dashed red: AudioReach control link',
                     size=11, color=QUIET, anchor='start'))

    sg_to_pos = {}  # device subgraph -> (cx, y_dev_top) for control-link arcs

    def draw_group(g, fe_n, dev_n, lanes, g_width, start_x, start_y):
        direction = g['direction']

        y_fe = start_y + H_small // 2
        y_sg = y_fe + H_small // 2 + ROW_GAP + H_tall // 2
        y_mx = y_sg + H_tall // 2 + ROW_GAP + H_small // 2
        y_dev = y_mx + H_small // 2 + ROW_GAP + H_tall // 2
        y_be = y_dev + H_tall // 2 + ROW_GAP + H_small // 2

        fe_step = g_width // fe_n
        dev_step = g_width // dev_n
        fe_xs = [start_x + fe_step // 2 + i * fe_step for i in range(fe_n)]
        dev_xs = [start_x + dev_step // 2 + i * dev_step for i in range(dev_n)]
        mx_cx = start_x + g_width // 2
        fe_box_w = fe_step - LANE_GAP
        dev_box_w = dev_step - LANE_GAP

        # pixel-per-char estimates for the two font sizes used in boxes
        px_name = 7.0   # 13 pt bold
        px_meta = 6.0   # 11 pt regular

        def mc(box_w, px):
            return max(8, int((box_w - 20) / px))

        def wrap_text(s, max_chars):
            if not s:
                return ['']
            lines, cur = [], ''
            for w in s.split():
                piece = w if not cur else ' ' + w
                if cur and len(cur) + len(piece) > max_chars:
                    lines.append(cur); cur = w
                else:
                    cur += piece
            if cur:
                lines.append(cur)
            return lines

        def multi(cx, y0, lines, size=11, color=QUIET, weight=400, line_h=14):
            for i, ln in enumerate(lines):
                out.append(label(cx, y0 + i * line_h, ln,
                                 size=size, color=color, weight=weight))

        # FE row (fill tint distinguishes FE from BE)
        for i, fe in enumerate(g['fes']):
            cx = fe_xs[i]
            out.append(rect(cx, y_fe, fe_box_w, H_small, fill=FE_BG))
            # Name on top (wrap if box narrow)
            name_lines = wrap_text(fe['fe'], mc(fe_box_w, px_name))
            multi(cx, y_fe - 6, name_lines, size=13, color=INK, weight=600)
            caps = fe['caps']
            fmt = caps.get('formats', '')
            rate_s = shorten_rate(caps.get('rate_min', ''), caps.get('rate_max', ''))
            cmin = caps.get('channels_min', '')
            cmax = caps.get('channels_max', '')
            ch = cmin if cmin == cmax else f'{cmin}–{cmax}'
            meta = ' · '.join(b for b in (fmt, rate_s,
                                          f'{ch} ch' if ch else '') if b)
            meta_lines = wrap_text(meta, mc(fe_box_w, px_meta))
            multi(cx, y_fe - 6 + len(name_lines) * 14,
                  meta_lines, size=11, color=QUIET)

            # Stream SG
            out.append(rect(cx, y_sg, fe_box_w, H_tall))
            out.append(label(cx, y_sg - 24, fe['stream_sg'] + ' subgraph', weight=600))
            mod_lines = wrap_arrows(sg_mods(fe['stream_sg']), mc(fe_box_w, px_meta))
            multi(cx, y_sg - 6, mod_lines, size=11, color=QUIET)

        # Mixer (one wide, accent)
        out.append(rect(mx_cx, y_mx, g_width, H_small, accent=True))
        mx_name = g['mixer'] or '(no mixer)'
        mx_lines = wrap_text(mx_name, mc(g_width, px_name))
        n = len(mx_lines)
        top_y = y_mx - 2 - (n - 1) * 14 // 2
        multi(mx_cx, top_y, mx_lines, size=13, color=INK, weight=600)
        info_bits = []
        if fe_n:
            info_bits.append(f'{fe_n} FE' + ('s' if fe_n != 1 else ''))
        if dev_n:
            info_bits.append(f'{dev_n} BE' + ('s' if dev_n != 1 else ''))
        out.append(label(mx_cx, y_mx + 18, ' · '.join(info_bits),
                         size=11, color=QUIET))

        # Device SG + BE DAI rows
        for i, dev in enumerate(g['devices']):
            cx = dev_xs[i]
            sg_to_pos[dev['sg']] = (cx, y_dev - H_tall // 2)
            out.append(rect(cx, y_dev, dev_box_w, H_tall))
            out.append(label(cx, y_dev - 24, dev['sg'] + ' subgraph', weight=600))
            dmod_lines = wrap_arrows(sg_mods(dev['sg']), mc(dev_box_w, px_meta))
            multi(cx, y_dev - 6, dmod_lines, size=11, color=QUIET)
            if dev['label']:
                via_lines = wrap_text(f'via “{dev["label"]}”',
                                      mc(dev_box_w, px_meta))
                # Place just below the module lines
                via_y = y_dev - 6 + len(dmod_lines) * 14
                multi(cx, via_y, via_lines, size=11, color=QUIET)

            out.append(rect(cx, y_be, dev_box_w, H_small, fill=BE_BG))
            if dev['be_dai']:
                be_name_lines = wrap_text(dev['be_dai'][0], mc(dev_box_w, px_name))
                multi(cx, y_be - 6, be_name_lines, size=13, color=INK, weight=600)
                be_stream_lines = wrap_text(dev['be_dai'][1], mc(dev_box_w, px_meta))
                multi(cx, y_be - 6 + len(be_name_lines) * 14,
                      be_stream_lines, size=11, color=QUIET)
            else:
                out.append(label(cx, y_be, '(no BE DAI)', color=QUIET))

        # Arrows: FE <-> Stream SG, one per FE lane
        for cx in fe_xs:
            if direction == 'playback':
                out.append(arrv(cx, y_fe + H_small // 2, y_sg - H_tall // 2))
            else:
                out.append(arrv(cx, y_sg - H_tall // 2, y_fe + H_small // 2))

        # Arrows: Stream SG <-> Mixer, trunk if >1 FE
        sg_bot = y_sg + H_tall // 2
        mx_top = y_mx - H_small // 2
        trunk1_y = (sg_bot + mx_top) // 2
        if fe_n > 1:
            if direction == 'playback':
                for cx in fe_xs:
                    out.append(line(cx, sg_bot, cx, trunk1_y))
                out.append(line(min(fe_xs), trunk1_y, max(fe_xs), trunk1_y))
                out.append(arrv(mx_cx, trunk1_y, mx_top))
            else:
                out.append(line(mx_cx, mx_top, mx_cx, trunk1_y))
                out.append(line(min(fe_xs), trunk1_y, max(fe_xs), trunk1_y))
                for cx in fe_xs:
                    out.append(arrv(cx, trunk1_y, sg_bot))
        else:
            if direction == 'playback':
                out.append(arrv(fe_xs[0], sg_bot, mx_top))
            else:
                out.append(arrv(fe_xs[0], mx_top, sg_bot))

        # Arrows: Mixer <-> Device SG, trunk if >1 device
        mx_bot = y_mx + H_small // 2
        dev_top = y_dev - H_tall // 2
        trunk2_y = (mx_bot + dev_top) // 2
        if dev_n > 1:
            if direction == 'playback':
                out.append(line(mx_cx, mx_bot, mx_cx, trunk2_y))
                out.append(line(min(dev_xs), trunk2_y, max(dev_xs), trunk2_y))
                for cx in dev_xs:
                    out.append(arrv(cx, trunk2_y, dev_top))
            else:
                for cx in dev_xs:
                    out.append(line(cx, dev_top, cx, trunk2_y))
                out.append(line(min(dev_xs), trunk2_y, max(dev_xs), trunk2_y))
                out.append(arrv(mx_cx, trunk2_y, mx_bot))
        else:
            if direction == 'playback':
                out.append(arrv(dev_xs[0], mx_bot, dev_top))
            else:
                out.append(arrv(dev_xs[0], dev_top, mx_bot))

        # Arrows: Device SG <-> BE DAI, one per device lane
        dev_bot = y_dev + H_tall // 2
        be_top = y_be - H_small // 2
        for cx in dev_xs:
            if direction == 'playback':
                out.append(arrv(cx, dev_bot, be_top))
            else:
                out.append(arrv(cx, be_top, dev_bot))

    def place(metas, groups_, y_cluster_top):
        for i, (g, meta) in enumerate(zip(groups_, metas)):
            r = i // cols
            c = i % cols
            x = MARGIN + c * cell_pitch + (cell_w - meta[3]) // 2
            y = y_cluster_top + r * (group_h + GROUP_V_GAP)
            draw_group(g, *meta, start_x=x, start_y=y)

    y_cluster = 72
    place(pb_metas, pb, y_cluster)
    y_cluster += pb_rows * (group_h + GROUP_V_GAP)
    place(cap_metas, cap, y_cluster)

    # Control-link arcs: dashed line between the two device SG top edges.
    # If the peers live in the same group (close vertically), arc over the
    # mixer row; otherwise connect with a straight dashed line through the gap.
    for cl in d['ctl_links']:
        p1_sg = d['widgets'].get(cl['peer1_name'], {}).get('subgraph')
        p2_sg = d['widgets'].get(cl['peer2_name'], {}).get('subgraph')
        if p1_sg not in sg_to_pos or p2_sg not in sg_to_pos:
            continue
        x1, y_edge1 = sg_to_pos[p1_sg]
        x2, y_edge2 = sg_to_pos[p2_sg]
        mid_x = (x1 + x2) // 2
        try:
            intent_h = f'0x{int(str(cl["intent0"]), 0):x}'
        except ValueError:
            intent_h = cl['intent0']
        ctl_label = (
            f'{cl["peer1_name"].rsplit(".", 1)[-1]} → '
            f'{cl["peer2_name"].rsplit(".", 1)[-1]} · intent {intent_h}'
        )
        if abs(y_edge1 - y_edge2) < 60:
            y_peak = min(y_edge1, y_edge2) - 24
            out.append(
                f'<path d="M{x1} {y_edge1}Q{mid_x} {y_peak} {x2} {y_edge2}" '
                f'fill="none" stroke="{ACCENT2}" stroke-width="1.5" '
                f'stroke-dasharray="5 4" marker-end="url(#arrctl)"/>'
            )
            out.append(label(mid_x, y_peak - 6, ctl_label,
                             size=11, color=ACCENT2, weight=600))
        else:
            out.append(
                f'<path d="M{x1} {y_edge1}L{x2} {y_edge2}" '
                f'fill="none" stroke="{ACCENT2}" stroke-width="1.5" '
                f'stroke-dasharray="5 4" marker-end="url(#arrctl)"/>'
            )
            mid_y = (y_edge1 + y_edge2) // 2
            out.append(label(mid_x + 8, mid_y, ctl_label,
                             size=11, color=ACCENT2, weight=600, anchor='start'))

    out.append('</svg>')
    return '\n'.join(out)


def svg_low_level(d: dict, title: str) -> str:
    """
    Hand-drawn SVG that mirrors svg_high_level's horizontal mixer-group layout
    but expands every subgraph box to stack its individual modules (with iids)
    inside, drawing the real intra-subgraph routes and placing the control-link
    arrow between the specific peer modules.
    """
    chains = find_fe_chains(d)
    groups = group_by_mixer(chains)
    pb = [g for g in groups if g['direction'] == 'playback']
    cap = [g for g in groups if g['direction'] == 'capture']

    LW = 240
    MARGIN = 24
    LANE_GAP = 20
    GROUP_H_GAP = 40
    GROUP_V_GAP = 56
    MAX_WIDTH = 1400
    H_small = 60
    ROW_GAP = 20
    MOD_H = 28
    SG_HDR = 32
    SG_PAD = 12

    EDGE = '#5a5a5a'
    INK = '#111'
    QUIET = '#666'
    ACCENT = '#2d6cdf'
    ACCENT_BG = '#eef4ff'
    ACCENT2 = '#c33a2b'
    MOD_BG = '#f7f9fc'
    FE_BG = '#f0f3f8'
    BE_BG = '#f6f3ec'

    def mods_for(sg: str, direction: str):
        mods = [n for n in d['subgraphs'].get(sg, [])
                if d['widgets'][n]['type'] not in ('aif_in', 'aif_out', 'mixer')]
        return list(reversed(mods)) if direction == 'capture' else mods

    # Compute uniform SG heights (max across groups) so rows stay aligned
    stream_mod_counts = []
    device_mod_counts = []
    for g in groups:
        for fe in g['fes']:
            stream_mod_counts.append(len(mods_for(fe['stream_sg'], g['direction'])))
        for dev in g['devices']:
            device_mod_counts.append(len(mods_for(dev['sg'], g['direction'])))
    stream_sg_h = SG_HDR + MOD_H * max(stream_mod_counts, default=1) + SG_PAD
    device_sg_h = SG_HDR + MOD_H * max(device_mod_counts, default=1) + SG_PAD

    def gw(g):
        fe_n = max(1, len(g['fes']))
        dev_n = max(1, len(g['devices']))
        lanes = max(fe_n, dev_n)
        return fe_n, dev_n, lanes, lanes * LW + (lanes - 1) * LANE_GAP

    pb_metas = [gw(g) for g in pb]
    cap_metas = [gw(g) for g in cap]
    all_metas = pb_metas + cap_metas
    cell_w = max((m[3] for m in all_metas), default=400)
    cell_pitch = cell_w + GROUP_H_GAP
    cols = max(1, (MAX_WIDTH - 2 * MARGIN + GROUP_H_GAP) // cell_pitch)
    cols = min(cols, max(len(pb), len(cap), 1))

    def row_count(n):
        return 0 if n == 0 else (n + cols - 1) // cols

    pb_rows = row_count(len(pb))
    cap_rows = row_count(len(cap))

    group_h = (H_small + ROW_GAP + stream_sg_h + ROW_GAP + H_small
               + ROW_GAP + device_sg_h + ROW_GAP + H_small)

    used_cols = min(cols, max(len(pb), len(cap), 1))
    width = max(760, 2 * MARGIN + used_cols * cell_w + (used_cols - 1) * GROUP_H_GAP)
    height = 72 + (pb_rows + cap_rows) * (group_h + GROUP_V_GAP) + 48

    def rect(cx, cy, w, h, accent=False, fill=None):
        f = fill or (ACCENT_BG if accent else 'none')
        s = ACCENT if accent else EDGE
        sw = 2 if accent else 1.25
        return (f'<rect x="{cx - w // 2}" y="{cy - h // 2}" width="{w}" height="{h}" '
                f'rx="8" fill="{f}" stroke="{s}" stroke-width="{sw}"/>')

    def label(x, y, s, size=13, color=None, weight=400, anchor='middle'):
        col = color or INK
        return (f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-size="{size}" '
                f'font-weight="{weight}" fill="{col}">{H.escape(s)}</text>')

    def arrv(x, y1, y2, marker='arrll'):
        color = ACCENT2 if marker == 'arrllctl' else EDGE
        return (f'<path d="M{x} {y1}L{x} {y2}" fill="none" stroke="{color}" '
                f'stroke-width="1.25" marker-end="url(#{marker})"/>')

    def line(x1, y1, x2, y2):
        return (f'<path d="M{x1} {y1}L{x2} {y2}" fill="none" '
                f'stroke="{EDGE}" stroke-width="1.25"/>')

    out = []
    out.append(
        f'<svg viewBox="0 0 {width} {height}" width="{width}" height="{height}" '
        f'xmlns="http://www.w3.org/2000/svg" '
        'font-family="system-ui, -apple-system, Segoe UI, Helvetica, Arial, sans-serif" '
        'font-size="13">'
    )
    out.append('<defs>')
    out.append(
        f'<marker id="arrll" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" '
        f'markerHeight="6" orient="auto-start-reverse">'
        f'<path d="M0 0L10 5L0 10z" fill="{EDGE}"/></marker>'
    )
    out.append(
        f'<marker id="arrllctl" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" '
        f'markerHeight="6" orient="auto-start-reverse">'
        f'<path d="M0 0L10 5L0 10z" fill="{ACCENT2}"/></marker>'
    )
    out.append('</defs>')
    out.append(label(24, 28, title, size=15, weight=600, anchor='start'))
    out.append(label(24, 48,
                     'Every module in every subgraph with its instance id · '
                     'routes from each SectionGraph · dashed red: control link',
                     size=11, color=QUIET, anchor='start'))

    mod_pos = {}  # (sg, module_name) -> (cx, cy, box_w)

    def draw_sg_box(sg: str, cx: int, cy: int, h: int, box_w: int, direction: str):
        out.append(rect(cx, cy, box_w, h))
        out.append(label(cx, cy - h // 2 + 20, f'{sg} subgraph', weight=600))
        mods = mods_for(sg, direction)
        y0 = cy - h // 2 + SG_HDR
        mod_w = box_w - 20
        prev_cy = None
        for i, mn in enumerate(mods):
            short = mn.rsplit('.', 1)[-1]
            iid = d['widgets'][mn]['iid']
            try:
                iid_s = f'0x{_norm_iid(iid):x}' if iid is not None else ''
            except TypeError:
                iid_s = str(iid)
            mod_cy = y0 + i * MOD_H + MOD_H // 2
            out.append(rect(cx, mod_cy, mod_w, MOD_H - 4, fill=MOD_BG))
            txt = f'{short}  ·  {iid_s}' if iid_s else short
            out.append(label(cx, mod_cy + 4, txt, size=12))
            mod_pos[(sg, mn)] = (cx, mod_cy, mod_w)
            prev_cy = mod_cy

    def draw_group(g, fe_n, dev_n, lanes, g_width, start_x, start_y):
        direction = g['direction']

        y_fe = start_y + H_small // 2
        y_sg = y_fe + H_small // 2 + ROW_GAP + stream_sg_h // 2
        y_mx = y_sg + stream_sg_h // 2 + ROW_GAP + H_small // 2
        y_dev = y_mx + H_small // 2 + ROW_GAP + device_sg_h // 2
        y_be = y_dev + device_sg_h // 2 + ROW_GAP + H_small // 2

        fe_step = g_width // fe_n
        dev_step = g_width // dev_n
        fe_xs = [start_x + fe_step // 2 + i * fe_step for i in range(fe_n)]
        dev_xs = [start_x + dev_step // 2 + i * dev_step for i in range(dev_n)]
        mx_cx = start_x + g_width // 2
        fe_box_w = fe_step - LANE_GAP
        dev_box_w = dev_step - LANE_GAP

        # FE row (neutral blue fill)
        for i, fe in enumerate(g['fes']):
            cx = fe_xs[i]
            out.append(rect(cx, y_fe, fe_box_w, H_small, fill=FE_BG))
            out.append(label(cx, y_fe - 2, fe['fe'], weight=600))
            out.append(label(cx, y_fe + 18, f'FE · {direction}',
                             size=11, color=QUIET))
            # Stream SG expanded
            draw_sg_box(fe['stream_sg'], cx, y_sg, stream_sg_h, fe_box_w, direction)

        # Mixer
        out.append(rect(mx_cx, y_mx, g_width, H_small, accent=True))
        out.append(label(mx_cx, y_mx - 2, g['mixer'] or '(no mixer)', weight=600))
        info_bits = []
        if fe_n:
            info_bits.append(f'{fe_n} FE' + ('s' if fe_n != 1 else ''))
        if dev_n:
            info_bits.append(f'{dev_n} BE' + ('s' if dev_n != 1 else ''))
        out.append(label(mx_cx, y_mx + 18, ' · '.join(info_bits),
                         size=11, color=QUIET))

        # Device SG + BE row (BE gets neutral cream fill)
        for i, dev in enumerate(g['devices']):
            cx = dev_xs[i]
            draw_sg_box(dev['sg'], cx, y_dev, device_sg_h, dev_box_w, direction)
            out.append(rect(cx, y_be, dev_box_w, H_small, fill=BE_BG))
            if dev['be_dai']:
                out.append(label(cx, y_be - 2, dev['be_dai'][0], weight=600))
                out.append(label(cx, y_be + 18, dev['be_dai'][1],
                                 size=11, color=QUIET))

        # Internal routes inside each SG (follow actual SectionGraph lines)
        for src, _lbl, dst in d['routes']:
            for fe in g['fes']:
                if (fe['stream_sg'], src) in mod_pos and (fe['stream_sg'], dst) in mod_pos:
                    sx, sy, _ = mod_pos[(fe['stream_sg'], src)]
                    _, dy, _ = mod_pos[(fe['stream_sg'], dst)]
                    out.append(arrv(sx, sy + MOD_H // 2 - 2, dy - MOD_H // 2 + 2))
            for dev in g['devices']:
                if (dev['sg'], src) in mod_pos and (dev['sg'], dst) in mod_pos:
                    sx, sy, _ = mod_pos[(dev['sg'], src)]
                    _, dy, _ = mod_pos[(dev['sg'], dst)]
                    out.append(arrv(sx, sy + MOD_H // 2 - 2, dy - MOD_H // 2 + 2))

        # External arrows between rows (same scheme as high-level)
        for cx in fe_xs:
            if direction == 'playback':
                out.append(arrv(cx, y_fe + H_small // 2, y_sg - stream_sg_h // 2))
            else:
                out.append(arrv(cx, y_sg - stream_sg_h // 2, y_fe + H_small // 2))

        sg_bot = y_sg + stream_sg_h // 2
        mx_top = y_mx - H_small // 2
        trunk1_y = (sg_bot + mx_top) // 2
        if fe_n > 1:
            if direction == 'playback':
                for cx in fe_xs:
                    out.append(line(cx, sg_bot, cx, trunk1_y))
                out.append(line(min(fe_xs), trunk1_y, max(fe_xs), trunk1_y))
                out.append(arrv(mx_cx, trunk1_y, mx_top))
            else:
                out.append(line(mx_cx, mx_top, mx_cx, trunk1_y))
                out.append(line(min(fe_xs), trunk1_y, max(fe_xs), trunk1_y))
                for cx in fe_xs:
                    out.append(arrv(cx, trunk1_y, sg_bot))
        else:
            if direction == 'playback':
                out.append(arrv(fe_xs[0], sg_bot, mx_top))
            else:
                out.append(arrv(fe_xs[0], mx_top, sg_bot))

        mx_bot = y_mx + H_small // 2
        dev_top = y_dev - device_sg_h // 2
        trunk2_y = (mx_bot + dev_top) // 2
        if dev_n > 1:
            if direction == 'playback':
                out.append(line(mx_cx, mx_bot, mx_cx, trunk2_y))
                out.append(line(min(dev_xs), trunk2_y, max(dev_xs), trunk2_y))
                for cx in dev_xs:
                    out.append(arrv(cx, trunk2_y, dev_top))
            else:
                for cx in dev_xs:
                    out.append(line(cx, dev_top, cx, trunk2_y))
                out.append(line(min(dev_xs), trunk2_y, max(dev_xs), trunk2_y))
                out.append(arrv(mx_cx, trunk2_y, mx_bot))
        else:
            if direction == 'playback':
                out.append(arrv(dev_xs[0], mx_bot, dev_top))
            else:
                out.append(arrv(dev_xs[0], dev_top, mx_bot))

        dev_bot = y_dev + device_sg_h // 2
        be_top = y_be - H_small // 2
        for cx in dev_xs:
            if direction == 'playback':
                out.append(arrv(cx, dev_bot, be_top))
            else:
                out.append(arrv(cx, be_top, dev_bot))

    def place(metas, groups_, y_cluster_top):
        for i, (g, meta) in enumerate(zip(groups_, metas)):
            r = i // cols
            c = i % cols
            x = MARGIN + c * cell_pitch + (cell_w - meta[3]) // 2
            y = y_cluster_top + r * (group_h + GROUP_V_GAP)
            draw_group(g, *meta, start_x=x, start_y=y)

    y_cluster = 72
    place(pb_metas, pb, y_cluster)
    y_cluster += pb_rows * (group_h + GROUP_V_GAP)
    place(cap_metas, cap, y_cluster)

    # Control-link arrows between individual peer modules
    for cl in d['ctl_links']:
        p1 = cl['peer1_name']
        p2 = cl['peer2_name']
        p1_sg = d['widgets'].get(p1, {}).get('subgraph')
        p2_sg = d['widgets'].get(p2, {}).get('subgraph')
        if (p1_sg, p1) not in mod_pos or (p2_sg, p2) not in mod_pos:
            continue
        x1, y1, _ = mod_pos[(p1_sg, p1)]
        x2, y2, _ = mod_pos[(p2_sg, p2)]
        mid_x = (x1 + x2) // 2
        try:
            intent_h = f'0x{int(str(cl["intent0"]), 0):x}'
        except ValueError:
            intent_h = cl['intent0']
        ctl_label = (f'{p1.rsplit(".", 1)[-1]} → '
                     f'{p2.rsplit(".", 1)[-1]} · intent {intent_h}')
        if abs(y1 - y2) < 80 and abs(x1 - x2) > 40:
            y_peak = min(y1, y2) - 40
            out.append(
                f'<path d="M{x1} {y1 - MOD_H // 2 + 2}Q{mid_x} {y_peak} '
                f'{x2} {y2 - MOD_H // 2 + 2}" fill="none" stroke="{ACCENT2}" '
                f'stroke-width="1.5" stroke-dasharray="5 4" '
                f'marker-end="url(#arrllctl)"/>'
            )
            out.append(label(mid_x, y_peak - 6, ctl_label,
                             size=11, color=ACCENT2, weight=600))
        else:
            out.append(
                f'<path d="M{x1} {y1}L{x2} {y2}" fill="none" '
                f'stroke="{ACCENT2}" stroke-width="1.5" '
                f'stroke-dasharray="5 4" marker-end="url(#arrllctl)"/>'
            )
            out.append(label((x1 + x2) // 2 + 8, (y1 + y2) // 2, ctl_label,
                             size=11, color=ACCENT2, weight=600, anchor='start'))

    out.append('</svg>')
    return '\n'.join(out)


def mermaid_low_level(d: dict) -> str:
    """Expand every subgraph and show the module chain + the actual routes."""
    lines = ['flowchart TB']

    for name, dir_, _caps in d['fe_pcms']:
        lines.append(f'  {mid(name)}(("{name}<br/><i>{dir_}</i>"))')
    for name, dir_, stream, _sg in d['be_dais']:
        lines.append(f'  {mid(name)}[("{name}<br/><i>{stream}</i>")]')
    for m in d['mixers']:
        lines.append(f'  {mid(m)}{{{{"{m}"}}}}')

    for sg, nodes in d['subgraphs'].items():
        label = f'{sg} subgraph'
        lines.append(f'  subgraph sg_{mid(sg)}["{label}"]')
        lines.append('    direction LR')
        for n in nodes:
            w = d['widgets'][n]
            short = n.rsplit('.', 1)[-1]
            iid_str = ''
            if w['iid'] is not None:
                try:
                    iid_str = f'<br/><i>iid 0x{_norm_iid(w["iid"]):x}</i>'
                except TypeError:
                    iid_str = f'<br/><i>iid {w["iid"]}</i>'
            if w['type'] in ('aif_in', 'aif_out'):
                continue  # drawn as BE DAI outside the box
            if w['type'] == 'mixer':
                lines.append(f'    {mid(n)}{{{{"{short}{iid_str}"}}}}')
            else:
                lines.append(f'    {mid(n)}["{short}{iid_str}"]')
        lines.append('  end')

    # All routes
    for src, label, dst in d['routes']:
        s_node = mid(src)
        t_node = mid(dst)
        if label:
            lines.append(f'  {s_node} -- "{label}" --> {t_node}')
        else:
            lines.append(f'  {s_node} --> {t_node}')

    # Control links (dashed)
    for cl in d['ctl_links']:
        s_node = mid(cl['peer1_name'])
        t_node = mid(cl['peer2_name'])
        intent = cl['intent0']
        try:
            intent_h = f'0x{int(str(intent), 0):x}'
        except ValueError:
            intent_h = intent
        label = f'ctrl · intent {intent_h}'
        lines.append(f'  {s_node} -. "{label}" .-> {t_node}')

    lines.append('  classDef mixer fill:#eef4ff,stroke:#2d6cdf,color:#111')
    for m in d['mixers']:
        lines.append(f'  class {mid(m)} mixer')
    return '\n'.join(lines)


# ---------------------------------------------------------------------------
# HTML emit
# ---------------------------------------------------------------------------

HTML_TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<style>
  :root {{ --fg:#111; --muted:#666; --rule:#d7d7dc; --code-bg:#f0f1f3; }}
  body {{ font-family: system-ui, -apple-system, 'Segoe UI', Helvetica, Arial, sans-serif;
         color: var(--fg); margin: 2rem; max-width: 1200px; }}
  h1 {{ font-size: 1.5rem; margin: 0 0 .25rem 0; }}
  h2 {{ font-size: 1.15rem; margin-top: 2rem; border-bottom: 1px solid var(--rule);
       padding-bottom: .25rem; }}
  .meta {{ color: var(--muted); font-size: 0.9rem; margin: 0; }}
  table {{ border-collapse: collapse; width: 100%; margin: 1rem 0; font-size: 0.9rem; }}
  th, td {{ text-align: left; padding: .4rem .6rem; border-bottom: 1px solid var(--rule);
           vertical-align: top; }}
  th {{ background: #eef1f5; font-weight: 600; }}
  code {{ font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
          background: var(--code-bg); padding: 1px 4px; border-radius: 3px;
          font-size: 0.85rem; }}
  .diagram {{ background: #fff; padding: 1rem; border: 1px solid var(--rule);
             border-radius: 6px; overflow: auto; max-height: 85vh; resize: vertical; }}
  /* render at natural viewBox size so the content stays readable; the
     container scrolls both axes when the diagram is bigger than the page */
  .diagram svg {{ display: block; }}
  .mermaid {{ background: #fff; padding: 1rem; border: 1px solid var(--rule);
             border-radius: 6px; overflow-x: auto; }}
  .legend {{ color: var(--muted); font-size: 0.85rem; }}
</style>
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
  mermaid.initialize({{ startOnLoad: true, theme: 'neutral', securityLevel: 'loose',
                       flowchart: {{ htmlLabels: true, curve: 'basis' }} }});
</script>
</head>
<body>
<h1>{title}</h1>
<p class="meta">AudioReach topology generated from <code>{source}</code>.</p>

<h2>High-level graph</h2>
<div class="diagram">
{svg_high}
</div>
<p class="legend">FEs on top, BEs on the bottom · playback on the left, capture on the right · blue boxes are DAPM mixer widgets · dashed red arc is an AudioReach control link.</p>

<h2>Low-level graph</h2>
<div class="diagram">
{svg_low}
</div>
<p class="legend">Every module in every subgraph with its instance id, plus the exact routes from each <code>SectionGraph</code>; dashed red arrow is the AudioReach control link between the specific peer modules.</p>

<h2>DAI endpoints</h2>
{dai_table}

<h2>Controls</h2>
{ctrl_table}

<h2>Control links</h2>
{ctl_links}
</body>
</html>
"""


def esc(s) -> str:
    return H.escape(str(s))


def render_dai_table(d: dict) -> str:
    rows = []
    for name, dir_, caps in d['fe_pcms']:
        fmts = caps.get('formats', '')
        rmin = caps.get('rate_min', '')
        rmax = caps.get('rate_max', '')
        cmin = caps.get('channels_min', '')
        cmax = caps.get('channels_max', '')
        rate = rmin if rmin == rmax else f'{rmin}–{rmax}'
        ch = cmin if cmin == cmax else f'{cmin}–{cmax}'
        rows.append(
            f'<tr><td>FE</td><td><code>{esc(name)}</code></td>'
            f'<td>{dir_}</td><td>{esc(fmts)}</td>'
            f'<td>{esc(rate)}</td><td>{esc(ch)}</td><td>—</td></tr>'
        )
    for name, dir_, stream, sg in d['be_dais']:
        rows.append(
            f'<tr><td>BE</td><td><code>{esc(name)}</code></td><td>{dir_}</td>'
            f'<td colspan="3">stream <code>{esc(stream)}</code></td>'
            f'<td><code>{esc(sg)}</code></td></tr>'
        )
    return (
        '<table><thead><tr>'
        '<th>Role</th><th>Name</th><th>Direction</th>'
        '<th>Formats</th><th>Rate (Hz)</th><th>Channels</th><th>Subgraph</th>'
        '</tr></thead><tbody>' + ''.join(rows) + '</tbody></table>'
    )


def render_controls_table(d: dict) -> str:
    rows = []
    for name, info, get in d['controls_mixer']:
        rows.append(
            f'<tr><td><code>{esc(name)}</code></td><td>mixer</td>'
            f'<td>info <code>{esc(info)}</code> · get <code>{esc(get)}</code></td></tr>'
        )
    for name, texts in d['controls_enum']:
        tx = ', '.join(texts)
        rows.append(
            f'<tr><td><code>{esc(name)}</code></td><td>enum</td>'
            f'<td>{esc(tx)}</td></tr>'
        )
    if not rows:
        return '<p><em>No controls declared in this topology.</em></p>'
    return (
        '<table><thead><tr><th>Control</th><th>Type</th><th>Details</th></tr></thead>'
        f'<tbody>{"".join(rows)}</tbody></table>'
    )


def render_ctl_links_table(d: dict) -> str:
    if not d['ctl_links']:
        return '<p><em>No control links in this topology.</em></p>'
    rows = []
    for cl in d['ctl_links']:
        try:
            intent_h = f'0x{int(str(cl["intent0"]), 0):x}'
        except ValueError:
            intent_h = cl['intent0']
        rows.append(
            f'<tr>'
            f'<td><code>{esc(cl["peer1_name"])}</code> (iid <code>{esc(cl["peer1_iid"])}</code>, port <code>{esc(cl["peer1_port"])}</code>)</td>'
            f'<td><code>{esc(cl["peer2_name"])}</code> (iid <code>{esc(cl["peer2_iid"])}</code>, port <code>{esc(cl["peer2_port"])}</code>)</td>'
            f'<td><code>{esc(intent_h)}</code></td>'
            f'<td><code>{esc(cl["link_iid"])}</code></td>'
            f'</tr>'
        )
    return (
        '<table><thead><tr>'
        '<th>Peer 1</th><th>Peer 2</th><th>Intent 0</th><th>Link iid</th>'
        '</tr></thead>'
        f'<tbody>{"".join(rows)}</tbody></table>'
    )


def render(d: dict, source_name: str, title: str) -> str:
    return HTML_TEMPLATE.format(
        title=esc(title),
        source=esc(source_name),
        svg_high=svg_high_level(d, title),
        svg_low=svg_low_level(d, title),
        dai_table=render_dai_table(d),
        ctrl_table=render_controls_table(d),
        ctl_links=render_ctl_links_table(d),
    )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

SVG_WRAPPER = (
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n'
    '<!-- Generated from {source} by gen_topology_html.py -->\n'
    '{svg}\n'
)


def process(conf_path: pathlib.Path, out_path: pathlib.Path | None = None) -> pathlib.Path:
    text = conf_path.read_text()
    sections = parse_conf(text)
    data = extract(sections)
    html_out = render(data, conf_path.name, conf_path.stem)
    out = out_path or conf_path.with_suffix('.html')
    out.write_text(html_out)
    # Also emit both diagrams as standalone .svg files next to the html
    high_svg = out.with_name(f'{out.stem}-high.svg')
    low_svg = out.with_name(f'{out.stem}-low.svg')
    high_svg.write_text(SVG_WRAPPER.format(
        source=conf_path.name,
        svg=svg_high_level(data, conf_path.stem),
    ))
    low_svg.write_text(SVG_WRAPPER.format(
        source=conf_path.name,
        svg=svg_low_level(data, conf_path.stem),
    ))
    return out


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 2
    target = pathlib.Path(argv[1])
    if target.is_dir():
        for p in sorted(target.rglob('*.conf')):
            out = process(p)
            print(f'wrote {out}')
    else:
        out = process(target, pathlib.Path(argv[2]) if len(argv) > 2 else None)
        print(f'wrote {out}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
