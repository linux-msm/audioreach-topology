# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')
#
# Stream SubGraph  for PCM Playback
# 
#  _____________________________________________________
# |               Sub Graph 1                    	|
# | [WR_SH] -> [PCM DEC] -> [PCM CONV] -> [VOL]->[LOG]  |- Kcontrol
# |_____________________________________________________|
#
#
dnl STREAM_SG_PCM_ADD(stream, stream-dai-id, stream-index, 
dnl 	format, min-rate, max-rate, min-channels, max-channels,
dnl	sg-iid-start, cont-iid-start, mod-iid-start)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001)
dnl
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004002, 0x00004002, 0x00006010)
dnl 
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 2, 2,	
	0x00004003, 0x00004003, 0x00006020)
#
# Device SubGraph  for WSA RX0 Backend
# 
#         ___________________
#        |   Sub Graph 2     |
# Mixer -| [LOG] -> [WSA EP] |
#        |___________________|
#
dnl DEVICE_SG_ADD(stream, stream-dai-id,
dnl 	format, min-rate, max-rate, min-channels, max-channels,
dnl	interface-type, interface-index, sd-line-idx, data-format,
dnl	sg-iid-start, cont-iid-start, mod-iid-start
dnl
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-playback.m4, `WSA_CODEC_DMA_RX_0', WSA_CODEC_DMA_RX_0,
	`S16_LE', 48000, 48000, 2, 2,	
	LPAIF_INTF_TYPE_WSA, CODEC_INTF_IDX_RX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004004, 0x00004004, 0x00006040)
dnl
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `TERTIARY_MI2S_RX', TERTIARY_MI2S_RX,
	`S16_LE', 48000, 48000, 2, 2,	
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_TERTIARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004005, 0x00004005, 0x00006050)
dnl
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `VA_CODEC_DMA_TX_0', VA_CODEC_DMA_TX_0,
	`S16_LE', 48000, 48000, 2, 2,	
	LPAIF_INTF_TYPE_VA, CODEC_INTF_IDX_TX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060)
dnl
STREAM_DEVICE_PLAYBACK_MIXER(WSA_CODEC_DMA_RX_0, ``WSA_CODEC_DMA_RX_0'', ``MultiMedia1'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_MIXER(TERTIARY_MI2S_RX, ``TERTIARY_MI2S_RX'', ``MultiMedia1'', ``MultiMedia2'')
dnl
STREAM_DEVICE_PLAYBACK_ROUTE(WSA_CODEC_DMA_RX_0, ``WSA_CODEC_DMA_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(TERTIARY_MI2S_RX, ``TERTIARY_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')
dnl
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``VA_CODEC_DMA_TX_0'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'')

