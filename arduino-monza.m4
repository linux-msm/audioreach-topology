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
dnl Playback MultiMedia1 Headset/Lineout/Earout.
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')

dnl Playback MultiMedia2 HDMI 
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')
dnl Display Port
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')

dnl Capture MultiMedia4  Headset Mic
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA4,
        `S16_LE', 48000, 48000, 1, 2,
        0x00004004, 0x00004004, 0x00006030,  `110000')
dnl External Mic
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA5,
        `S16_LE', 48000, 48000, 1, 2,
        0x00004005, 0x00004005, 0x00006040,  `110000')
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
dnl LPI QUAD Playback
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `LPI RX0', LPI_MI2S_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_RXTX, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060, `LPI_MI2S_RX_0')
dnl
dnl LPI QUAD Capture //FIXME.. WHY SD1 ??
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `LPI TX0', LPI_MI2S_TX_0,
        `S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_RXTX, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD1, DATA_FORMAT_FIXED_POINT,
        0x00004008, 0x00004008, 0x00006080, `LPI_MI2S_TX_0', `LPI_MI2S_TX_0')

dnl LPI MI2S4 using WSA DMA 
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `LPI RX4', LPI_MI2S_RX_4,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_WSA2, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004009, 0x00004009, 0x00006070, `LPI_MI2S_RX_4')


STREAM_DEVICE_PLAYBACK_MIXER(LPI_MI2S_RX_0, ``LPI_MI2S_RX_0'', ``MultiMedia1'', ``MultiMedia2'', ``MultiMedia3'')
STREAM_DEVICE_PLAYBACK_MIXER(LPI_MI2S_RX_4, ``LPI_MI2S_RX_4'', ``MultiMedia1'', ``MultiMedia2'', ``MultiMedia3'')

STREAM_DEVICE_PLAYBACK_ROUTE(LPI_MI2S_RX_0, ``LPI_MI2S_RX_0 Audio Mixer'',
 ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'', ``MultiMedia3, stream2.logger1'')

STREAM_DEVICE_PLAYBACK_ROUTE(LPI_MI2S_RX_4, ``LPI_MI2S_RX_4 Audio Mixer'',
 ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'', ``MultiMedia3, stream2.logger1'')

dnl STREAM_DEVICE_CAPTURE_MIXER(stream-index, kcontro1, kcontrol2... kcontrolN)
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA4, ``LPI_MI2S_TX_0'')
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA5, ``LPI_MI2S_TX_0'')
dnl STREAM_DEVICE_CAPTURE_ROUTE(stream-index, mixer-name, route1, route2.. routeN)
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA4, ``MultiMedia4 Mixer'', ``LPI_MI2S_TX_0, device138.logger1'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA5, ``MultiMedia5 Mixer'', ``LPI_MI2S_TX_0, device138.logger1'')
