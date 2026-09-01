# Copyright, Linaro Ltd, 2024
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

STREAM_SG_PCM_ADD(`audioreach/subgraph-stream-vol-playback.m4', 0,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')

STREAM_SG_PCM_ADD(`audioreach/subgraph-stream-capture.m4', 1,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')

dnl ---------------------------------------------------------------------
dnl SECONDARY_TDM_RX_0 device
dnl ---------------------------------------------------------------------

DEVICE_AUDIO_IF_SG_ADD(`audioreach/subgraph-device-audio-if-playback.m4',
	`Secondary TDM0', SECONDARY_TDM_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_AUD, AUD_INTF_IDX_2, 0, DATA_FORMAT_FIXED_POINT,
	0x00004040, 0x00004040, 0x00006040, `SECONDARY_TDM_RX_0',
	AUDIO_IF_SYNC_SRC_INTERNAL, AUDIO_IF_CTRL_DATA_OE_ENABLE,
	0x03, 4, 32,
	AUDIO_IF_INTF_MODE_TDM, AUDIO_IF_FRAME_SYNC_MODE_SHORT_SYNC,
	0, 1,
	AUDIO_IF_TYPE_QAIF, AUDIO_IF_LANE_MASK_1, 0,
	AUDIO_IF_I_BIT_CLK_EN, AUDIO_IF_INT_CLK_NORMAL,
	AUDIO_IF_EXT_CLK_NORMAL)

dnl ---------------------------------------------------------------------
dnl VA_CODEC_DMA_TX_0 device (capture backend)
dnl ---------------------------------------------------------------------

DEVICE_SG_ADD(`audioreach/subgraph-device-codec-dma-capture.m4',
	`VA_CODEC_DMA_TX_0', 110,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_QAIF_AUD, CODEC_INTF_IDX_TX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004008, 0x00004008, 0x00006080, `MIXER_PREFIX')

dnl ---------------------------------------------------------------------
dnl Playback stream/device mixers and routes
dnl ---------------------------------------------------------------------

STREAM_DEVICE_PLAYBACK_MIXER(40, ``SECONDARY_TDM_RX_0'', ``MultiMedia1'')

STREAM_DEVICE_PLAYBACK_ROUTE(40, ``SECONDARY_TDM_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'')

STREAM_DEVICE_CAPTURE_MIXER(1, ``VA_CODEC_DMA_TX_0'')

STREAM_DEVICE_CAPTURE_ROUTE(1, ``MultiMedia2 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'')
