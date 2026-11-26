# SPDX-License-Identifier: BSD-3-Clause
# Copyright, Linaro Ltd, 2023
# Lenovo IdeaPad Slim 3x 15Q8X10 (X1P42100/X1-26-100):
#   2x WSA884x speakers (WSA, swr0), WCD938x headset, 2x VA DMIC,
#   DP0 (USB-C alt mode) and DP2 (internal PS185HDM DP->HDMI bridge).
# Based on X1E80100-LENOVO-Thinkpad-T14s.m4, with dedicated DisplayPort
# frontends as in X1E80100-LENOVO-IdeaCentre-Mini.m4.
#
# PCM map (ALSA device = FE dai id = MultiMediaN - 1):
#   hw:X,0  MultiMedia1 Playback -> RX_CODEC_DMA_RX_0  (headphones)
#   hw:X,1  MultiMedia2 Playback -> WSA_CODEC_DMA_RX_0 (speakers)
#   hw:X,2  MultiMedia3 Capture  <- TX_CODEC_DMA_TX_3 / VA_CODEC_DMA_TX_0 (headset mic)
#   hw:X,3  MultiMedia4 Capture  <- VA_CODEC_DMA_TX_0 / TX_CODEC_DMA_TX_3 (DMIC)
#   hw:X,4  MultiMedia5 Playback -> DISPLAY_PORT_RX_0  (USB-C DP alt mode)
#   hw:X,6  MultiMedia7 Playback -> DISPLAY_PORT_RX_2  (HDMI via PS185HDM)
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')
#
# Stream SubGraphs
#
dnl Playback MultiMedia1 - headphones (WCD RX)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')
dnl Playback MultiMedia2 - speakers (WSA)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')
dnl Capture MultiMedia3 - headset mic
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')
dnl Capture MultiMedia4 - internal DMIC
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA4,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004004, 0x00004004, 0x00006030, `110000')
dnl Playback MultiMedia5 - dedicated stream for DisplayPort RX 0
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA5,
	`S16_LE', 48000, 48000, 2, 2,
	0x0000400A, 0x0000400A, 0x00006200, `110000')
dnl Playback MultiMedia7 - dedicated stream for DisplayPort RX 2 (HDMI)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA7,
	`S16_LE', 48000, 48000, 2, 2,
	0x0000400B, 0x0000400B, 0x00006210, `110000')
#
# Device SubGraphs
#
dnl DEVICE_SG_ADD(stream, stream-dai-id, stream-index,
dnl 	format, min-rate, max-rate, min-channels, max-channels,
dnl	interface-type, interface-index, data-format,
dnl	sg-iid-start, cont-iid-start, mod-iid-start
dnl WSA Playback
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-playback.m4, `WSA_CODEC_DMA_RX_0', WSA_CODEC_DMA_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_WSA, CODEC_INTF_IDX_RX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004005, 0x00004005, 0x00006050)
dnl
dnl WCDRX Playback
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-playback.m4, `RX_CODEC_DMA_RX_0', RX_CODEC_DMA_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_RX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004007, 0x00004007, 0x00006070)
dnl
dnl Display port0 Playback (USB-C alt mode)
DEVICE_SG_ADD(audioreach/subgraph-device-display-port-playback.m4, `DISPLAY_PORT_RX_0', DISPLAY_PORT_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004012, 0x00004012, 0x00006120, `DISPLAY_PORT_RX_0')
dnl
dnl Display port2/HDMI Playback (PS185HDM)
DEVICE_SG_ADD(audioreach/subgraph-device-display-port-playback.m4, `DISPLAY_PORT_RX_2', DISPLAY_PORT_RX_2,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004014, 0x00004014, 0x00006140, `DISPLAY_PORT_RX_2')
dnl
dnl VA Capture
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `VA_CODEC_DMA_TX_0', VA_CODEC_DMA_TX_0,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_VA, CODEC_INTF_IDX_TX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004018, 0x00004018, 0x00006180)
dnl
dnl WCDTX Capture
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `TX_CODEC_DMA_TX_3', TX_CODEC_DMA_TX_3,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_TX3, 0, DATA_FORMAT_FIXED_POINT,
	0x00004019, 0x00004019, 0x00006190)

#
# Mixers & routes
# Strict per-port playback paths (as in X1E80100-LENOVO-IdeaCentre-Mini):
# every playback backend has exactly one frontend, so a PCM open never
# depends on another port's backend state.
#
STREAM_DEVICE_PLAYBACK_MIXER(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0'', ``MultiMedia1'')
STREAM_DEVICE_PLAYBACK_MIXER(WSA_CODEC_DMA_RX_0, ``WSA_CODEC_DMA_RX_0'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_MIXER(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0'', ``MultiMedia5'')
STREAM_DEVICE_PLAYBACK_MIXER(DISPLAY_PORT_RX_2, ``DISPLAY_PORT_RX_2'', ``MultiMedia7'')

STREAM_DEVICE_PLAYBACK_ROUTE(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(WSA_CODEC_DMA_RX_0, ``WSA_CODEC_DMA_RX_0 Audio Mixer'', ``MultiMedia2, stream1.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0 Audio Mixer'', ``MultiMedia5, stream4.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(DISPLAY_PORT_RX_2, ``DISPLAY_PORT_RX_2 Audio Mixer'', ``MultiMedia7, stream6.logger1'')

dnl STREAM_DEVICE_CAPTURE_MIXER(stream-index, kcontro1, kcontrol2... kcontrolN)
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``VA_CODEC_DMA_TX_0'',``TX_CODEC_DMA_TX_3'' )
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA4, ``VA_CODEC_DMA_TX_0'',``TX_CODEC_DMA_TX_3'' )
dnl STREAM_DEVICE_CAPTURE_ROUTE(stream-index, mixer-name, route1, route2.. routeN)
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA4, ``MultiMedia4 Mixer'', ``VA_CODEC_DMA_TX_0, device110.logger1'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
