# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')

dnl ---------------------------------------------------------------------
dnl Streams
dnl ---------------------------------------------------------------------

STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')

STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')

STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')

STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA4,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004004, 0x00004004, 0x00006030, `110000')

dnl ---------------------------------------------------------------------
dnl AIF_TDM_RX_1 device (speaker playback backend)
dnl ---------------------------------------------------------------------

DEVICE_AUDIO_IF_SG_ADD(audioreach/subgraph-device-audio-if-playback.m4, `AIF RX1 TDM1', AIF_TDM_RX_1,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_AUD, AUD_INTF_IDX_1, 0, DATA_FORMAT_FIXED_POINT,
	0x00004040, 0x00004040, 0x00006040, `AIF_TDM_RX_1',
	AUDIO_IF_SYNC_SRC_INTERNAL, AUDIO_IF_CTRL_DATA_OE_ENABLE,
	0x03, 4, 32,
	AUDIO_IF_INTF_MODE_TDM, AUDIO_IF_FRAME_SYNC_MODE_SHORT_SYNC,
	0, 1,
	AUDIO_IF_TYPE_QAIF, AUDIO_IF_LANE_MASK_1, 0,
	AUDIO_IF_I_BIT_CLK_EN, AUDIO_IF_INT_CLK_NORMAL,
	AUDIO_IF_EXT_CLK_NORMAL)

dnl ---------------------------------------------------------------------
dnl RX_CODEC_DMA_RX_0 device (headset playback backend)
dnl ---------------------------------------------------------------------

DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-playback.m4, `RX_CODEC_DMA_RX_0', RX_CODEC_DMA_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_QAIF_AUD, CODEC_INTF_IDX_RX2, 0, DATA_FORMAT_FIXED_POINT,
	0x00004007, 0x00004007, 0x00006070)

dnl ---------------------------------------------------------------------
dnl VA_CODEC_DMA_TX_0 device (capture backend)
dnl ---------------------------------------------------------------------

DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `VA_CODEC_DMA_TX_0', VA_CODEC_DMA_TX_0,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_QAIF_VA, CODEC_INTF_IDX_TX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004008, 0x00004008, 0x00006080)

dnl ---------------------------------------------------------------------
dnl TX_CODEC_DMA_TX_3 device (headset capture backend)
dnl ---------------------------------------------------------------------

DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `TX_CODEC_DMA_TX_3', TX_CODEC_DMA_TX_3,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_QAIF_AUD, CODEC_INTF_IDX_TX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004009, 0x00004009, 0x00006090)

dnl ---------------------------------------------------------------------
dnl Playback stream/device mixers and routes
dnl ---------------------------------------------------------------------

STREAM_DEVICE_PLAYBACK_MIXER(AIF_TDM_RX_1, ``AIF_TDM_RX_1'', ``MultiMedia1'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_MIXER(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0'', ``MultiMedia1'', ``MultiMedia2'')

STREAM_DEVICE_PLAYBACK_ROUTE(AIF_TDM_RX_1, ``AIF_TDM_RX_1 Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')

dnl ---------------------------------------------------------------------
dnl Capture stream/device mixers and routes
dnl ---------------------------------------------------------------------

STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``VA_CODEC_DMA_TX_0'', ``TX_CODEC_DMA_TX_3'')
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA4, ``VA_CODEC_DMA_TX_0'', ``TX_CODEC_DMA_TX_3'')

STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA4, ``MultiMedia4 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
