# Copyright (c) 2026 Vicharak Computers Pvt. Ltd.
# SPDX-License-Identifier: BSD-3-Clause

include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')

dnl Stereo playback through the ES8388 codec and speaker amplifiers.
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')

dnl Capture from either the ES8388 headset microphone or the two digital microphones.
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')

DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Secondary', SECONDARY_MI2S_RX,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_SDR, I2S_INTF_TYPE_SECONDARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060, `SECONDARY_MI2S_RX')

DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `Secondary', SECONDARY_MI2S_TX,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_SDR, I2S_INTF_TYPE_SECONDARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004007, 0x00004007, 0x00006070, `SECONDARY_MI2S_TX', `SECONDARY_MI2S_TX')

dnl The microphones use SD0 and SD1 with shared clock and word select.
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `Tertiary', TERTIARY_MI2S_TX,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_SDR, I2S_INTF_TYPE_TERTIARY, SD_LINE_IDX_I2S_QUAD01, DATA_FORMAT_FIXED_POINT,
	0x00004008, 0x00004008, 0x00006080, `TERTIARY_MI2S_TX', `TERTIARY_MI2S_TX')

STREAM_DEVICE_PLAYBACK_MIXER(SECONDARY_MI2S_RX, ``SECONDARY_MI2S_RX'', ``MultiMedia1'')
STREAM_DEVICE_PLAYBACK_ROUTE(SECONDARY_MI2S_RX, ``SECONDARY_MI2S_RX Audio Mixer'',
	``MultiMedia1, stream0.logger1'')

STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA2, ``SECONDARY_MI2S_TX'', ``TERTIARY_MI2S_TX'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA2, ``MultiMedia2 Mixer'',
	``SECONDARY_MI2S_TX, device19.logger1'', ``TERTIARY_MI2S_TX, device21.logger1'')
