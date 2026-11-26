# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause
include(`util/util.m4') dnl
include(`audioreach/tokens.m4') dnl
include(`audioreach/audioreach.m4') dnl
dnl Select MDSP for Shikra; subgraph templates use this override instead of the default ADSP domain.
define(`AR_SELECTED_PROC_DOMAIN_ID', APM_PROC_DOMAIN_ID_MDSP) dnl
include(`audioreach/stream-subgraph.m4') dnl
include(`audioreach/device-subgraph.m4') dnl
include(`util/mixer.m4') dnl
include(`util/route.m4') dnl

dnl ---------------------------------------------------------------------
dnl Streams
dnl ---------------------------------------------------------------------

STREAM_SG_PCM_ADD(`audioreach/subgraph-stream-vol-playback.m4',
	FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')

STREAM_SG_PCM_ADD(`audioreach/subgraph-stream-capture.m4',
	FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')

STREAM_SG_PCM_ADD(`audioreach/subgraph-stream-capture.m4',
	FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')

dnl ---------------------------------------------------------------------
dnl AIF_MI2S_RX_0 device
dnl ---------------------------------------------------------------------

DEVICE_AUDIO_IF_SG_ADD(`audioreach/subgraph-device-audio-if-playback.m4',
	`AIF RX0 MI2S', AIF_MI2S_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_AUD, AUD_INTF_IDX_0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060, `AIF_MI2S_RX_0',
	AUDIO_IF_SYNC_SRC_INTERNAL, AUDIO_IF_CTRL_DATA_OE_ENABLE,
	0x03, 2, 16,
	AUDIO_IF_INTF_MODE_I2S, AUDIO_IF_FRAME_SYNC_MODE_LONG_SYNC,
	AUDIO_IF_CTRL_INVERT_SYNC_PULSE_ENABLE,
	AUDIO_IF_CTRL_SYNC_DATA_DELAY_ENABLE,
	AUDIO_IF_TYPE_QAIF, AUDIO_IF_LANE_MASK_0, 48000,
	AUDIO_IF_I_BIT_CLK_EN, AUDIO_IF_INT_CLK_INVERT,
	AUDIO_IF_EXT_CLK_NORMAL)

dnl ---------------------------------------------------------------------
dnl VA_CODEC_DMA_TX_0 device (capture backend)
dnl ---------------------------------------------------------------------

DEVICE_SG_ADD(`audioreach/subgraph-device-codec-dma-capture.m4',
	`VA_CODEC_DMA_TX_0', VA_CODEC_DMA_TX_0,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_QAIF_AUD, CODEC_INTF_IDX_TX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004008, 0x00004008, 0x00006080, `MIXER_PREFIX')

dnl ---------------------------------------------------------------------
dnl AIF_MI2S_TX_0 device (headset record)
dnl ---------------------------------------------------------------------

DEVICE_AUDIO_IF_SG_ADD(`audioreach/subgraph-device-audio-if-capture.m4',
	`AIF TX0 MI2S', AIF_MI2S_TX_0,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_AUD, AUD_INTF_IDX_0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004009, 0x00004009, 0x00006090, `AIF_MI2S_TX_0',
	AUDIO_IF_SYNC_SRC_INTERNAL, AUDIO_IF_CTRL_DATA_OE_ENABLE,
	0x03, 2, 16,
	AUDIO_IF_INTF_MODE_I2S, AUDIO_IF_FRAME_SYNC_MODE_LONG_SYNC,
	AUDIO_IF_CTRL_INVERT_SYNC_PULSE_ENABLE,
	AUDIO_IF_CTRL_SYNC_DATA_DELAY_ENABLE,
	AUDIO_IF_TYPE_QAIF, AUDIO_IF_LANE_MASK_1, 48000,
	AUDIO_IF_I_BIT_CLK_EN, AUDIO_IF_INT_CLK_INVERT,
	AUDIO_IF_EXT_CLK_NORMAL)

dnl ---------------------------------------------------------------------
dnl Playback stream/device mixers and routes
dnl ---------------------------------------------------------------------

STREAM_DEVICE_PLAYBACK_MIXER(AIF_MI2S_RX_0, ``AIF_MI2S_RX_0'', ``MultiMedia1'')

STREAM_DEVICE_PLAYBACK_ROUTE(AIF_MI2S_RX_0, ``AIF_MI2S_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'')

STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA2, ``VA_CODEC_DMA_TX_0'')
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``AIF_MI2S_TX_0'')

STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA2, ``MultiMedia2 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``AIF_MI2S_TX_0, device154.logger1'')
