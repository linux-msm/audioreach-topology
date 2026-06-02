dnl Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
dnl SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4') dnl
include(`util/pcm.m4') dnl
include(`audioreach/subgraph.m4') dnl
include(`audioreach/container.m4') dnl
include(`audioreach/module_log.m4') dnl
include(`audioreach/module_audio_if.m4') dnl
include(`util/mixer.m4') dnl
dnl
dnl
dnl SubGraph for Audio IF playback backend
dnl
dnl The AUDIO_IF_SINK module (0x0700117C) is the unified serial-interface
dnl playback endpoint used by newer Qualcomm platforms. It replaces legacy
dnl dedicated TDM/I2S modules and selects the physical interface via the
dnl intf_mode token: TDM=0, PCM=1, I2S=2.
dnl
dnl Graph topology:
dnl  ______________________________
dnl |   Sub Graph                  |
dnl | [LOG] -> [AUDIO_IF_SINK EP]  |
dnl |______________________________|
dnl


undefine(`LOG_MODULE_IID') dnl
undefine(`AUDIO_IF_MODULE_IID') dnl
undefine(`SG_INDEX') dnl
undefine(`CONTAINER_INDEX') dnl
undefine(`MOD_INDEX') dnl

undefine(`DEVICE_PERF_MODE') dnl
undefine(`DEVICE_DIRECTION') dnl
undefine(`CONT_SENARIO_ID') dnl
undefine(`CONT_CAP') dnl
undefine(`CONT_POSITION') dnl
undefine(`DEVICE_DOMAIN_ID') dnl
undefine(`CONT_STACK_SIZE') dnl

dnl Subgraph configuration - same as I2S playback:
dnl  DIRECTION_TX = data flows from ADSP to HW (playback)
dnl  SID_AUDIO_PLAYBACK = audio playback scenario
define(`DEVICE_PERF_MODE', APM_SG_PERF_MODE_LOW_LATENCY) dnl'
define(`DEVICE_DIRECTION', APM_SUB_GRAPH_DIRECTION_TX) dnl'
define(`CONT_SENARIO_ID', APM_SUB_GRAPH_SID_AUDIO_PLAYBACK) dnl'
define(`CONT_CAP', `ifelse(LPASS_VER_COMPAT, 110000, APM_CONTAINER_TYPE_ID_GC, APM_CONTAINER_CAP_ID_EP)') dnl'
define(`CONT_POSITION', APM_CONT_GRAPH_POS_STREAM)dnl'
define(`DEVICE_DOMAIN_ID', APM_PROC_DOMAIN_ID_ADSP) dnl'
define(`CONT_STACK_SIZE', 8192) dnl'
dnl
dnl Module IID assignments:
dnl  LOG_MODULE_IID  = MOD_IID_START + 0  (data logging module)
dnl  AUDIO_IF_MODULE_IID = MOD_IID_START + 1  (AUDIO_IF_SINK HW endpoint)
define(`LOG_MODULE_IID', MOD_IID_START) dnl
define(`AUDIO_IF_MODULE_IID', eval(MOD_IID_START + 1)) dnl
define(`SG_INDEX', 1) dnl
define(`CONTAINER_INDEX', 1) dnl
define(`MOD_INDEX', 1) dnl
dnl
dnl DEVICE_PLAYBACK_ROUTE(stream-index, dai-name, mixer-prefix)
dnl Defines the ALSA graph connections for Audio IF playback:
dnl   audio_if_rx widget <- logger <- Audio Mixer <- stream
dnl The stream_name "$2 Playback" must match the backend DAI stream_name
dnl for the selected Audio IF interface instance.
define(`DEVICE_PLAYBACK_ROUTE',
`'
`SectionGraph."NAME_PREFIX.$1 $3 Graph" {'
`        index STR($1)'
`        lines ['
`                "NAME_PREFIX.logger$1, , $3 Audio Mixer"'
`                "NAME_PREFIX.audio_if_rx$1, , NAME_PREFIX.logger$1"'
`                "$2 Playback, , NAME_PREFIX.audio_if_rx$1"'
`        ]'
`}')


AR_SUBGRAPH(SG_INDEX, DEVICE_DAI_ID, SG_IID_START, DEVICE_PERF_MODE, DEVICE_DIRECTION, CONT_SENARIO_ID)
AR_CONTAINER(CONTAINER_INDEX, CONT_IID_START, CONT_CAP, CONT_STACK_SIZE, CONT_POSITION, DEVICE_DOMAIN_ID)

dnl LOG module: connects stream mixer to AUDIO_IF_SINK
dnl AR_MODULE_LOG(idx, sg, cont, iid, maxip, maxop, src-port, dst-port, log-code, log-tap, log-mode, dst-iid)
AR_MODULE_LOG(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,
	LOG_MODULE_IID, 1, 1, 1, 2, 0x000019ab, 1, 0, AUDIO_IF_MODULE_IID)

dnl AUDIO_IF_SINK module: the serial-interface HW endpoint
dnl AR_MODULE_AUDIO_IF_SINK(idx, sg, cont, iid, maxip, maxop, src-port, dst-port,
dnl   hw_if_type, hw_if_idx, data_format,
dnl   sync_src, ctrl_data_out_enable, slot_mask, nslots_per_frame, slot_width,
dnl   sync_mode, ctrl_invert_sync_pulse, ctrl_sync_data_delay,
dnl   dev-name, dst-iid)
dnl
dnl Notes on parameter values:
dnl   hw_if_type = DEVICE_INTF_TYPE
dnl   hw_if_idx  = DEVICE_INTF_INDEX
dnl   sync source, slot layout, interface mode, sync timing, lane
dnl   selection and bit clock polarity are all supplied by the board
dnl   topology through DEVICE_AUDIO_IF_* so the same subgraph can be
dnl   reused across TDM, PCM and I2S style Audio IF playback paths.
AR_MODULE_AUDIO_IF_SINK(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,
	AUDIO_IF_MODULE_IID, 1, 0, 1, 0,
	DEVICE_INTF_TYPE, DEVICE_INTF_INDEX, DEVICE_DATA_FORMAT,
	DEVICE_AUDIO_IF_SYNC_SRC, DEVICE_AUDIO_IF_CTRL_DATA_OUT_ENABLE,
	DEVICE_AUDIO_IF_SLOT_MASK, DEVICE_AUDIO_IF_NSLOTS_PER_FRAME,
	DEVICE_AUDIO_IF_SLOT_WIDTH, DEVICE_AUDIO_IF_INTF_MODE,
	DEVICE_AUDIO_IF_FRAME_SYNC_MODE,
	DEVICE_AUDIO_IF_CTRL_INVERT_SYNC_PULSE,
	DEVICE_AUDIO_IF_CTRL_SYNC_DATA_DELAY,
	DEVICE_AUDIO_IF_QAIF_TYPE,
	DEVICE_AUDIO_IF_ACTIVE_LANE_MASK, DEVICE_AUDIO_IF_FRAME_SYNC_RATE,
	DEVICE_AUDIO_IF_BIT_CLK_TYPE, DEVICE_AUDIO_IF_INV_INT_BIT_CLK,
	DEVICE_AUDIO_IF_INV_EXT_BIT_CLK,
	`DEVICE_NAME', NONE_IID)

DEVICE_PLAYBACK_ROUTE(MOD_INDEX, `DEVICE_NAME', `MIXER_PREFIX')
