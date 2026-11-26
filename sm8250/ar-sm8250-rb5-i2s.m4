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
STREAM_MASTER_PLAYBACK_VOLUME_CTRL(1)
dnl STREAM_SG_PCM_ADD(stream, stream-dai-id, stream-index, 
dnl 	format, min-rate, max-rate, min-channels, max-channels,
dnl	perf-mode, direction,
dnl	senario-id, container-cap, container-pos,
dnl	domain, stack-size,
dnl	sg-iid-start, cont-iid-start, mod-iid-start
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1, 1,
	`S16_LE', 48000, 48000, 2, 2,	
	APM_SG_PERF_MODE_LOW_LATENCY, APM_SUB_GRAPH_DIRECTION_RX,
	APM_SUB_GRAPH_SID_AUDIO_PLAYBACK, APM_CONTAINER_CAP_ID_CD, APM_CONT_GRAPH_POS_STREAM,
	APM_PROC_DOMAIN_ID_ADSP, 8192,
	0x00004001, 0x00004001, 0x00006001)
dnl 
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA2, 2,
	`S16_LE', 48000, 48000, 2, 2,	
	APM_SG_PERF_MODE_LOW_LATENCY, APM_SUB_GRAPH_DIRECTION_TX,
	APM_SUB_GRAPH_SID_AUDIO_RECORD, APM_CONTAINER_CAP_ID_CD, APM_CONT_GRAPH_POS_GLOBAL_DEV,
	APM_PROC_DOMAIN_ID_ADSP, 8192,
	0x00004002, 0x00004002, 0x00006011)


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
dnl	perf-mode, direction, senario-id, container-cap, container-pos,
dnl	domain, stack-size,
dnl	interface-type, interface-index, data-format,
dnl	sg-iid-start, cont-iid-start, mod-iid-start

#DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-playback.m4, `WSA_CODEC_DMA_RX_0', WSA_CODEC_DMA_RX_0, 3,
#	`S16_LE', 48000, 48000, 2, 2,	
#	APM_SG_PERF_MODE_LOW_LATENCY, APM_SUB_GRAPH_DIRECTION_TX, APM_SUB_GRAPH_SID_AUDIO_PLAYBACK,
#	APM_CONTAINER_CAP_ID_EP, APM_CONT_GRAPH_POS_STREAM, APM_PROC_DOMAIN_ID_ADSP, 8192,
#	LPAIF_INTF_TYPE_WSA, CODEC_INTF_IDX_RX0, DATA_FORMAT_FIXED_POINT,
#	0x00004003, 0x00004003, 0x00006030)

DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `TERTIARY_MI2S_RX', TERTIARY_MI2S_RX, 3,
	`S16_LE', 48000, 48000, 2, 2,	
	APM_SG_PERF_MODE_LOW_LATENCY, APM_SUB_GRAPH_DIRECTION_TX, APM_SUB_GRAPH_SID_AUDIO_PLAYBACK,
	APM_CONTAINER_CAP_ID_EP, APM_CONT_GRAPH_POS_STREAM, APM_PROC_DOMAIN_ID_ADSP, 8192,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_TERTIARY, DATA_FORMAT_FIXED_POINT,
	0x00004003, 0x00004003, 0x00006030)


DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `VA_CODEC_DMA_TX_0', VA_CODEC_DMA_TX_0, 4,
	`S16_LE', 48000, 48000, 2, 2,	
	APM_SG_PERF_MODE_LOW_LATENCY, APM_SUB_GRAPH_DIRECTION_TX, APM_SUB_GRAPH_SID_AUDIO_RECORD,
	APM_CONTAINER_CAP_ID_EP, APM_CONT_GRAPH_POS_GLOBAL_DEV, APM_PROC_DOMAIN_ID_ADSP, 8192,
	LPAIF_INTF_TYPE_VA, CODEC_INTF_IDX_TX0, DATA_FORMAT_FIXED_POINT,
	0x00004004, 0x00004004, 0x00006040)

# STREAM_DEVICE_PLAYBACK_MIXER(3, ``WSA_CODEC_DMA_RX_0'', ``PCM1'')
# STREAM_DEVICE_PLAYBACK_ROUTE(3, ``WSA_CODEC_DMA_RX_0 Audio Mixer'', ``PCM1, stream.logger1'')
STREAM_DEVICE_PLAYBACK_MIXER(3, ``TERTIARY_MI2S_RX'', ``PCM1'')
STREAM_DEVICE_PLAYBACK_ROUTE(3, ``TERTIARY_MI2S_RX Audio Mixer'', ``PCM1, stream.logger1'')


STREAM_DEVICE_CAPTURE_MIXER(2, ``VA_CODEC_DMA_TX_0'')
STREAM_DEVICE_CAPTURE_ROUTE(2, ``MultiMedia2 Mixer'', ``VA_CODEC_DMA_TX_0, device.logger4'')
