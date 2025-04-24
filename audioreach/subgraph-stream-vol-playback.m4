# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4') dnl
include(`util/pcm.m4') dnl
include(`audioreach/subgraph.m4') dnl
include(`audioreach/container.m4') dnl
include(`audioreach/module_wrsh.m4') dnl
include(`audioreach/module_pcmdec.m4') dnl
include(`audioreach/module_mfc.m4') dnl
include(`audioreach/module_pcmcnv.m4') dnl
include(`audioreach/module_vol_ctrl.m4') dnl
include(`audioreach/module_log.m4') dnl
include(`util/mixer.m4') dnl
dnl
# SubGraph  for PCM Playback
# 
#  ______________________________________________________
# |               Sub Graph 1                            |
# | [WR_SH] -> [PCM DEC] -> [PCM CONV] -> [VOL]-> [LOG]  |---Mixer--
# |______________________________________________________|
#
undefine(`PCM_PERF_MODE') dnl
undefine(`PCM_DIRECTION') dnl
undefine(`CONT_SENARIO_ID') dnl
undefine(`CONT_CAP') dnl
undefine(`CONT_POSITION') dnl
undefine(`PCM_DOMAIN_ID') dnl
undefine(`CONT_STACK_SIZE') dnl

define(`PCM_PERF_MODE', APM_SG_PERF_MODE_LOW_LATENCY) dnl'
define(`PCM_DIRECTION', APM_SUB_GRAPH_DIRECTION_RX) dnl'
define(`CONT_SENARIO_ID', APM_SUB_GRAPH_SID_AUDIO_PLAYBACK) dnl'
define(`CONT_CAP', `ifelse(LPASS_VER_COMPAT, 110000, APM_CONTAINER_TYPE_ID_GC, APM_CONTAINER_CAP_ID_CD)') dnl'
define(`CONT_POSITION', APM_CONT_GRAPH_POS_STREAM) dnl'
define(`PCM_DOMAIN_ID', APM_PROC_DOMAIN_ID_ADSP) dnl'
define(`CONT_STACK_SIZE', 8192) dnl'

define(`WRSH_MODULE_IID', MOD_IID_START) dnl
define(`PCMDEC_MODULE_IID', eval(MOD_IID_START + 1)) dnl
define(`PCMCNV_MODULE_IID', eval(MOD_IID_START + 2)) dnl
define(`VOLCTRL_MODULE_IID', eval(MOD_IID_START + 3)) dnl
define(`MFC_MODULE_IID', eval(MOD_IID_START + 4)) dnl
define(`LOG_MODULE_IID', eval(MOD_IID_START + 5)) dnl
define(`SG_INDEX', 1) dnl
define(`CONTAINER_INDEX', 1) dnl
define(`MOD_INDEX', 1) dnl

dnl
dnl STREAM_PLAYBACK_ROUTE(stream-index)
define(`STREAM_PLAYBACK_ROUTE',
`'
`SectionGraph."NAME_PREFIX.$2 Graph" {'
`        index STR($2)'
`        lines ['
`                "NAME_PREFIX.pcm_decoder$2, , NAME_PREFIX.wrsh_ep$2"'
`                "NAME_PREFIX.pcm_converter$2, , NAME_PREFIX.pcm_decoder$2"'
`                "NAME_PREFIX.vol_ctrl$1, , NAME_PREFIX.pcm_converter$2"'
`                "NAME_PREFIX.mfc$2, , NAME_PREFIX.vol_ctrl$1"'
`                "NAME_PREFIX.logger$2, , NAME_PREFIX.mfc$2"'
`        ]'
`}')

dnl
AR_PCM_PLAYBACK(PCM_DAI_ID, PCM_FORMAT, PCM_MIN_RATE, PCM_MAX_RATE, PCM_MIN_CHANNELS, PCM_MAX_CHANNELS)

AR_SUBGRAPH(SG_INDEX, PCM_DAI_ID, SG_IID_START, PCM_PERF_MODE, PCM_DIRECTION, CONT_SENARIO_ID)

AR_CONTAINER(CONTAINER_INDEX, CONT_IID_START, CONT_CAP, CONT_STACK_SIZE, APM_CONT_GRAPH_POS_STREAM, APM_PROC_DOMAIN_ID_ADSP)

AR_MODULE_WRSH(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,	WRSH_MODULE_IID,  0, 1, 1, 2, PCM_DAI_ID, PCMDEC_MODULE_IID)
AR_MODULE_PCMDEC(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,	PCMDEC_MODULE_IID, 1, 1, 1, 2, PCM_INTERLEAVED,PCMCNV_MODULE_IID)
AR_MODULE_PCMCNV(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,	PCMCNV_MODULE_IID, 1, 1, 1, 2, PCM_DEINTERLEAVED_UNPACKED,VOLCTRL_MODULE_IID)
AR_MODULE_VOL_CTRL(PCM_DAI_ID, SG_INDEX, CONTAINER_INDEX, VOLCTRL_MODULE_IID,1, 1, 1, 2,MFC_MODULE_IID)
AR_MODULE_MFC(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,	MFC_MODULE_IID, 1, 1, 1, 2, LOG_MODULE_IID)
AR_MODULE_LOG(MOD_INDEX,    SG_INDEX, CONTAINER_INDEX, 	LOG_MODULE_IID,    1, 1, 1, 2, 0x000019af, 1, 0, NONE_IID)
STREAM_PLAYBACK_MIXER(PCM_DAI_ID, SG_INDEX)
STREAM_PLAYBACK_ROUTE(PCM_DAI_ID, MOD_INDEX) 
