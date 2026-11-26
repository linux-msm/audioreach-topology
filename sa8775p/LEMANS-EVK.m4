# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')
#
# Stream SubGraph  for MultiMedia Playback
#
#  ______________________________________________
# |               Sub Graph 1                    |
# | [WR_SH] -> [PCM DEC] -> [PCM CONV] -> [LOG]  |- Kcontrol
# |______________________________________________|
#
dnl Playback MultiMedia1
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')
dnl
dnl Capture MultiMedia2
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA2,
        `S16_LE', 48000, 48000, 1, 2,
        0x00004003, 0x00004003, 0x00006020,  `110000')
dnl
dnl Playback MultiMedia3 (Compress Offload)
STREAM_SG_PCM_ADD(audioreach/subgraph-compress-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA3,
`S16_LE', 48000, 48000, 2, 2,
0x00004002, 0x00004002, 0x00006010, `110000', `true')
dnl
dnl Playback MultiMedia4 (Display Port)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA4,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004005, 0x00004005, 0x00006030, `110000')
dnl
#
#
# Device SubGraph  for WSA RX0 Backend
#
#         ___________________
#        |   Sub Graph 2     |
# Mixer -| [LOG] -> [WSA EP] |
#        |___________________|
#
dnl DEVICE_SG_ADD(stream, stream-dai-id, stream-index,
dnl 	format, min-rate, max-rate, min-channels, max-channels,
dnl	interface-type, interface-index, data-format,
dnl	sg-iid-start, cont-iid-start, mod-iid-start
dnl Primary MI2S Playback
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Primary', PRIMARY_MI2S_RX,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_SDR, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060, `PRIMARY_MI2S_RX')
dnl
dnl Tertiary MI2S Capture
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `Tertiary', TERTIARY_MI2S_TX,
        `S16_LE', 48000, 48000, 1, 1,
        LPAIF_INTF_TYPE_SDR, I2S_INTF_TYPE_TERTIARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
        0x00004008, 0x00004008, 0x00006080, `TERTIARY_MI2S_TX', `TERTIARY_MI2S_TX')
dnl Display port0 Playback
DEVICE_SG_ADD(audioreach/subgraph-device-display-port-playback.m4, `DISPLAY_PORT_RX_0', DISPLAY_PORT_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	0, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004012, 0x00004012, 0x00006120, `DISPLAY_PORT_RX_0')
dnl

STREAM_DEVICE_PLAYBACK_MIXER(PRIMARY_MI2S_RX, ``PRIMARY_MI2S_RX'', ``MultiMedia1'', ``MultiMedia3'')
STREAM_DEVICE_PLAYBACK_ROUTE(PRIMARY_MI2S_RX, ``PRIMARY_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia3, stream2.logger1'')

STREAM_DEVICE_PLAYBACK_MIXER(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0'', ``MultiMedia4'')
STREAM_DEVICE_PLAYBACK_ROUTE(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0 Audio Mixer'', ``MultiMedia4, stream3.logger1'')

dnl STREAM_DEVICE_CAPTURE_MIXER(stream-index, kcontro1, kcontrol2... kcontrolN)
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA2, ``TERTIARY_MI2S_TX'')
dnl STREAM_DEVICE_CAPTURE_ROUTE(stream-index, mixer-name, route1, route2.. routeN)
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA2, ``MultiMedia2 Mixer'', ``TERTIARY_MI2S_TX, device21.logger1'')
