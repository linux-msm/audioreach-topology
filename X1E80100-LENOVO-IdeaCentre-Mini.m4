# SPDX-License-Identifier: BSD-3-Clause
# Copyright, Linaro Ltd, 2023
# Adapted for Lenovo IdeaCentre Mini 01Q8X10 (no speakers, no internal mics)
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')

#
# Stream SubGraphs
#
dnl Playback MultiMedia1
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')
dnl Capture MultiMedia3 (headset mic)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')
dnl Playback MultiMedia5 - for DisplayPort RX 0
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA5,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004005, 0x00004005, 0x00006040, `110000')
dnl Playback MultiMedia6 - for DisplayPort RX 1
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA6,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004006, 0x00004006, 0x00006050, `110000')
dnl Playback MultiMedia7 - for DisplayPort RX 2
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA7,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004007, 0x00004007, 0x00006060, `110000')

#
# Device SubGraphs
#
dnl WCD RX (headset/headphone)
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-playback.m4, `RX_CODEC_DMA_RX_0', RX_CODEC_DMA_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_RX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004009, 0x00004009, 0x00006080)

dnl DisplayPort 0/1/2
DEVICE_SG_ADD(audioreach/subgraph-device-display-port-playback.m4, `DISPLAY_PORT_RX_0', DISPLAY_PORT_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x0000400C, 0x0000400C, 0x000060B0, `DISPLAY_PORT_RX_0')
DEVICE_SG_ADD(audioreach/subgraph-device-display-port-playback.m4, `DISPLAY_PORT_RX_1', DISPLAY_PORT_RX_1,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x0000400D, 0x0000400D, 0x000060C0, `DISPLAY_PORT_RX_1')
DEVICE_SG_ADD(audioreach/subgraph-device-display-port-playback.m4, `DISPLAY_PORT_RX_2', DISPLAY_PORT_RX_2,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x0000400E, 0x0000400E, 0x000060D0, `DISPLAY_PORT_RX_2')

dnl WCD TX (headset mic)
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `TX_CODEC_DMA_TX_3', TX_CODEC_DMA_TX_3,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_TX3, 0, DATA_FORMAT_FIXED_POINT,
	0x0000400B, 0x0000400B, 0x000060A0)

#
# Mixers & routes
#
STREAM_DEVICE_PLAYBACK_MIXER(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0'', ``MultiMedia1'')
dnl DisplayPort mixers - dedicated MultiMedia5 .. MultiMedia7
STREAM_DEVICE_PLAYBACK_MIXER(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0'', ``MultiMedia5'')
STREAM_DEVICE_PLAYBACK_MIXER(DISPLAY_PORT_RX_1, ``DISPLAY_PORT_RX_1'', ``MultiMedia6'')
STREAM_DEVICE_PLAYBACK_MIXER(DISPLAY_PORT_RX_2, ``DISPLAY_PORT_RX_2'', ``MultiMedia7'')

STREAM_DEVICE_PLAYBACK_ROUTE(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0 Audio Mixer'', ``MultiMedia5, stream4.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(DISPLAY_PORT_RX_1, ``DISPLAY_PORT_RX_1 Audio Mixer'', ``MultiMedia6, stream5.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(DISPLAY_PORT_RX_2, ``DISPLAY_PORT_RX_2 Audio Mixer'', ``MultiMedia7, stream6.logger1'')

STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``TX_CODEC_DMA_TX_3'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
