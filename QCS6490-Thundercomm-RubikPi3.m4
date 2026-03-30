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
dnl Playback MultiMedia2
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S32_LE', 48000, 48000, 2, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')
dnl
dnl Playback MultiMedia4
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA4,
	`S32_LE', 48000, 48000, 2, 2,
	0x00004004, 0x00004004, 0x00006030, `110000')
dnl
dnl Playback MultiMedia6
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA6,
	`S32_LE', 48000, 48000, 2, 2,
	0x00004011, 0x00004011, 0x00006080, `110000')
dnl
dnl Capture MultiMedia3
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')
dnl
dnl Capture MultiMedia5
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA5,
	`S32_LE', 48000, 48000, 1, 2,
	0x00004008, 0x00004008, 0x00006040, `110000')
dnl
dnl Capture MultiMedia7
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA7,
	`S32_LE', 48000, 48000, 1, 2,
	0x00004012, 0x00004012, 0x00006110, `110000')
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
dnl     format, min-rate, max-rate, min-channels, max-channels,
dnl interface-type, interface-index, data-format,
dnl sg-iid-start, cont-iid-start, mod-iid-start)

dnl Primary MI2S Playback
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Primary', PRIMARY_MI2S_RX,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004005, 0x00004005, 0x00006050, `PRIMARY_MI2S_RX')
dnl
dnl Quaternary MI2S Playback
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Quaternary', QUATERNARY_MI2S_RX,
	`S32_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_RXTX, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060, `QUATERNARY_MI2S_RX')
dnl
dnl Tertiary MI2S Playback
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Tertiary', TERTIARY_MI2S_RX,
	`S32_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_TERTIARY, SD_LINE_IDX_I2S_SD1, DATA_FORMAT_FIXED_POINT,
	0x00004009, 0x00004009, 0x00006090, `TERTIARY_MI2S_RX')
dnl
dnl Quinary MI2S Playback
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Quinary', QUINARY_MI2S_RX,
	`S32_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_QUINARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004013, 0x00004013, 0x00006120, `QUINARY_MI2S_RX')
dnl
dnl Primary MI2S Capture
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `Primary', PRIMARY_MI2S_TX,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD1, DATA_FORMAT_FIXED_POINT,
	0x00004007, 0x00004007, 0x00006070, `PRIMARY_MI2S_TX', `PRIMARY_MI2S_TX')
dnl
dnl Tertiary MI2S Capture
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `Tertiary', TERTIARY_MI2S_TX,
	`S32_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_TERTIARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004010, 0x00004010, 0x00006100, `TERTIARY_MI2S_TX', `TERTIARY_MI2S_TX')
dnl
dnl Quinary MI2S Capture
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `Quinary', QUINARY_MI2S_TX,
	`S32_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_QUINARY, SD_LINE_IDX_I2S_SD1, DATA_FORMAT_FIXED_POINT,
	0x00004014, 0x00004014, 0x00006130, `QUINARY_MI2S_TX', `QUINARY_MI2S_TX')
dnl

STREAM_DEVICE_PLAYBACK_MIXER(PRIMARY_MI2S_RX, ``PRIMARY_MI2S_RX'', ``MultiMedia1'')
STREAM_DEVICE_PLAYBACK_ROUTE(PRIMARY_MI2S_RX, ``PRIMARY_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'')

STREAM_DEVICE_PLAYBACK_MIXER(QUATERNARY_MI2S_RX, ``QUATERNARY_MI2S_RX'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_ROUTE(QUATERNARY_MI2S_RX, ``QUATERNARY_MI2S_RX Audio Mixer'', ``MultiMedia2, stream1.logger1'')

STREAM_DEVICE_PLAYBACK_MIXER(TERTIARY_MI2S_RX, ``TERTIARY_MI2S_RX'', ``MultiMedia4'')
STREAM_DEVICE_PLAYBACK_ROUTE(TERTIARY_MI2S_RX, ``TERTIARY_MI2S_RX Audio Mixer'', ``MultiMedia4, stream3.logger1'')

STREAM_DEVICE_PLAYBACK_MIXER(QUINARY_MI2S_RX, ``QUINARY_MI2S_RX'', ``MultiMedia6'')
STREAM_DEVICE_PLAYBACK_ROUTE(QUINARY_MI2S_RX, ``QUINARY_MI2S_RX Audio Mixer'', ``MultiMedia6, stream5.logger1'')

dnl STREAM_DEVICE_CAPTURE_MIXER(stream-index, kcontro1, kcontrol2... kcontrolN)
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``PRIMARY_MI2S_TX'')
dnl STREAM_DEVICE_CAPTURE_ROUTE(stream-index, mixer-name, route1, route2.. routeN)
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``PRIMARY_MI2S_TX, device17.logger1'')

dnl STREAM_DEVICE_CAPTURE_MIXER(stream-index, kcontro1, kcontrol2... kcontrolN)
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA5, ``TERTIARY_MI2S_TX'')
dnl STREAM_DEVICE_CAPTURE_ROUTE(stream-index, mixer-name, route1, route2.. routeN)
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA5, ``MultiMedia5 Mixer'', ``TERTIARY_MI2S_TX, device21.logger1'')

dnl STREAM_DEVICE_CAPTURE_MIXER(stream-index, kcontro1, kcontrol2... kcontrolN)
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA7, ``QUINARY_MI2S_TX'')
dnl STREAM_DEVICE_CAPTURE_ROUTE(stream-index, mixer-name, route1, route2.. routeN)
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA7, ``MultiMedia7 Mixer'', ``QUINARY_MI2S_TX, device128.logger1'')
