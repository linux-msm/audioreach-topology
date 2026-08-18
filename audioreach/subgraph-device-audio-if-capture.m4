dnl Copyright, Linaro Ltd, 2024
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
dnl SubGraph for Audio IF capture backend
dnl
dnl The AUDIO_IF_SOURCE module is the unified serial-interface capture
dnl endpoint used by newer Qualcomm platforms. It replaces legacy dedicated
dnl TDM/I2S modules and selects the physical interface via the intf_mode
dnl token: TDM=0, PCM=1, I2S=2.
dnl
dnl Graph topology:
dnl  ______________________________
dnl |   Sub Graph                  |
dnl | [AUDIO_IF_SOURCE EP] -> [LOG] |
dnl |______________________________|
dnl
dnl DEVICE_AUDIO_IF_SG_ADD parameters used:
dnl   DEVICE_INTF_TYPE  = LPAIF_INTF_TYPE_AUD (5) - AUD/QAIF interface
dnl   DEVICE_INTF_INDEX = AUD_INTF index
dnl   DEVICE_SD_LINE_IDX = not used by AUDIO_IF (no SD line), passed as 0
dnl   DEVICE_DATA_FORMAT = DATA_FORMAT_FIXED_POINT
dnl   DEVICE_AUDIO_IF_* = interface configuration supplied by the board topology

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

dnl Subgraph configuration for capture:
dnl  DIRECTION_RX = data flows from HW to ADSP (capture)
dnl  SID_AUDIO_RECORD = audio record scenario
define(`DEVICE_PERF_MODE', APM_SG_PERF_MODE_LOW_LATENCY) dnl'
define(`DEVICE_DIRECTION', APM_SUB_GRAPH_DIRECTION_TX) dnl'
define(`CONT_SENARIO_ID', APM_SUB_GRAPH_SID_AUDIO_RECORD) dnl'
define(`CONT_CAP', `ifelse(LPASS_VER_COMPAT, 110000, APM_CONTAINER_TYPE_ID_GC, APM_CONTAINER_CAP_ID_EP)') dnl'
define(`CONT_POSITION', APM_CONT_GRAPH_POS_GLOBAL_DEV)dnl'
define(`DEVICE_DOMAIN_ID', `ifdef(`AR_SELECTED_PROC_DOMAIN_ID', AR_SELECTED_PROC_DOMAIN_ID, APM_PROC_DOMAIN_ID_ADSP)') dnl'
define(`CONT_STACK_SIZE', 8192) dnl'
dnl
dnl Module IID assignments:
dnl  AUDIO_IF_MODULE_IID = MOD_IID_START + 0  (AUDIO_IF_SOURCE HW endpoint)
dnl  LOG_MODULE_IID      = MOD_IID_START + 1  (data logging module)
define(`AUDIO_IF_MODULE_IID', MOD_IID_START) dnl
define(`LOG_MODULE_IID', eval(MOD_IID_START + 1)) dnl
define(`SG_INDEX', 1) dnl
define(`CONTAINER_INDEX', 1) dnl
define(`MOD_INDEX', 1) dnl
dnl
dnl DEVICE_CAPTURE_ROUTE(stream-index, dai-name, mixer-prefix)
dnl Defines the ALSA graph connections for Audio IF capture:
dnl   stream Capture <- logger <- audio_if_tx widget
dnl The stream_name "$2 Capture" must match the backend DAI stream_name
dnl for the selected Audio IF interface instance.
define(`DEVICE_CAPTURE_ROUTE',
`'
`SectionGraph."NAME_PREFIX.$1 $3 Graph" {'
`        index STR($1)'
`        lines ['
`                "NAME_PREFIX.audio_if_tx$1, , $2 Capture"'
`                "NAME_PREFIX.logger$1, , NAME_PREFIX.audio_if_tx$1"'
`        ]'
`}')


AR_SUBGRAPH(SG_INDEX, DEVICE_DAI_ID, SG_IID_START, DEVICE_PERF_MODE, DEVICE_DIRECTION, CONT_SENARIO_ID)
AR_CONTAINER(CONTAINER_INDEX, CONT_IID_START, CONT_CAP, CONT_STACK_SIZE, CONT_POSITION, DEVICE_DOMAIN_ID)

dnl AUDIO_IF_SOURCE module: the serial-interface HW capture endpoint
AR_MODULE_AUDIO_IF_SOURCE(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,
	AUDIO_IF_MODULE_IID, 0, 1, 1, 2,
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
	`DEVICE_NAME', LOG_MODULE_IID)

dnl LOG module: receives data from AUDIO_IF_SOURCE
AR_MODULE_LOG(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,
	LOG_MODULE_IID, 1, 1, 1, 2, 0x000019ab, 1, 0, NONE_IID)

dnl kcontrol switch
DEVICE_CAPTURE_MIXER(SG_INDEX, `MIXER_PREFIX')
DEVICE_CAPTURE_ROUTE(MOD_INDEX, `DEVICE_NAME', `MIXER_PREFIX')
