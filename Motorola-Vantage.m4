# SPDX-License-Identifier: BSD-3-Clause
# Motorola Signature (vantage): TFA9865 speaker and earpiece amplifiers on
# the primary MI2S of the WSA LPAIF (senary MI2S port).
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
dnl Capture MultiMedia2
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')
dnl
#
# Device SubGraph for the amplifiers
#
#         ___________________
#        |   Sub Graph 2     |
# Mixer -| [LOG] -> [I2S EP] |
#        |___________________|
#
dnl Senary MI2S Playback
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-mfc-playback.m4, `Senary', SENARY_MI2S_RX,
	`S32_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_WSA, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060, `SENARY_MI2S_RX')
dnl VA Capture (digital microphones)
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `VA_CODEC_DMA_TX_0', VA_CODEC_DMA_TX_0,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_VA, CODEC_INTF_IDX_TX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004008, 0x00004008, 0x00006080)
dnl
STREAM_DEVICE_PLAYBACK_MIXER(SENARY_MI2S_RX, ``SENARY_MI2S_RX'', ``MultiMedia1'')
STREAM_DEVICE_PLAYBACK_ROUTE(SENARY_MI2S_RX, ``SENARY_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'')
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA2, ``VA_CODEC_DMA_TX_0'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA2, ``MultiMedia2 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'')
