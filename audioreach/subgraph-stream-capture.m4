# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4') dnl
include(`util/pcm.m4') dnl
include(`audioreach/subgraph.m4') dnl
include(`audioreach/container.m4') dnl
include(`audioreach/module_rdsh.m4') dnl
include(`audioreach/module_pcmenc.m4') dnl
include(`audioreach/module_mfc.m4') dnl
include(`audioreach/module_pcmcnv.m4') dnl
include(`audioreach/module_log.m4') dnl
include(`util/mixer.m4') dnl
dnl
# SubGraph  for PCM Capture
#
#  ______________________________________________
# |               Sub Graph 1                    |
# | [RD_SH]<-- [PCM ENC] <--[PCM CONV] <--[LOG]  |-[DAPM - MIXER]
# |  PCM(n)                                      |
# |______________________________________________|
#
undefine(`PCM_PERF_MODE') dnl
undefine(`PCM_DIRECTION') dnl
undefine(`CONT_SENARIO_ID') dnl
undefine(`CONT_CAP') dnl
undefine(`CONT_POSITION') dnl
undefine(`PCM_DOMAIN_ID') dnl
undefine(`CONT_STACK_SIZE') dnl

define(`PCM_PERF_MODE', APM_SG_PERF_MODE_LOW_LATENCY) dnl'
define(`PCM_DIRECTION', APM_SUB_GRAPH_DIRECTION_TX) dnl'
define(`CONT_SENARIO_ID', APM_SG_PERF_MODE_LOW_LATENCY) dnl'
define(`CONT_CAP', `ifelse(LPASS_VER_COMPAT, 110000, APM_CONTAINER_TYPE_ID_GC, APM_CONTAINER_CAP_ID_CD)') dnl'
define(`CONT_POSITION', APM_CONT_GRAPH_POS_GLOBAL_DEV) dnl'
define(`PCM_DOMAIN_ID', APM_PROC_DOMAIN_ID_ADSP) dnl'
define(`CONT_STACK_SIZE', 8192) dnl'

define(`LOG_MODULE_IID', MOD_IID_START) dnl
define(`MFC_MODULE_IID', eval(MOD_IID_START + 1)) dnl
define(`PCMCNV_MODULE_IID', eval(MOD_IID_START + 2)) dnl
define(`PCMENC_MODULE_IID', eval(MOD_IID_START + 3)) dnl
define(`RDSH_MODULE_IID', eval(MOD_IID_START + 4)) dnl
define(`SG_INDEX', 1) dnl
define(`CONTAINER_INDEX', 1) dnl
define(`MOD_INDEX', 1) dnl
dnl
dnl STREAM_CAPTURE_ROUTE(stream-index, dai-id)
define(`STREAM_CAPTURE_ROUTE',
`'
`SectionGraph."NAME_PREFIX.$1 Graph" {'
`        index STR($1)'
`        lines ['
`                "NAME_PREFIX.logger$1, , `MultiMedia'eval($2 + 1)` Mixer'"'
`                "NAME_PREFIX.mfc$1, , NAME_PREFIX.logger$1"'
`                "NAME_PREFIX.pcm_converter$1, , NAME_PREFIX.mfc$1"'
`                "NAME_PREFIX.pcm_encoder$1, , NAME_PREFIX.pcm_converter$1"'
`                "NAME_PREFIX.rdsh_ep$1, , NAME_PREFIX.pcm_encoder$1"'
`        ]'
`}')
dnl AR_PCM_CAPTURE(index, formats, rate_min, rate_max, ch_min, ch_max)
AR_PCM_CAPTURE(PCM_DAI_ID, PCM_FORMAT, PCM_MIN_RATE, PCM_MAX_RATE, PCM_MIN_CHANNELS, PCM_MAX_CHANNELS)

AR_SUBGRAPH(SG_INDEX, PCM_DAI_ID, SG_IID_START, PCM_PERF_MODE, PCM_DIRECTION, CONT_SENARIO_ID)

AR_CONTAINER(CONTAINER_INDEX, CONT_IID_START,  CONT_CAP, CONT_STACK_SIZE, CONT_POSITION, PCM_DOMAIN_ID)

dnl AR_MODULE_LOG(index, sgidx, container-idx, iid, maxip-ports, max-op-ports, src-port, dst-port,
dnl               log-code, log-tap-point, log-mode, dst-iid)
AR_MODULE_LOG(MOD_INDEX,    SG_INDEX, CONTAINER_INDEX, LOG_MODULE_IID,    1, 1, 1, 2, 0x000019af, 1, 0,MFC_MODULE_IID)
AR_MODULE_MFC(MOD_INDEX, SG_INDEX, CONTAINER_INDEX, MFC_MODULE_IID, 1, 1, 1, 2, PCMCNV_MODULE_IID)
AR_MODULE_PCMCNV(MOD_INDEX, SG_INDEX, CONTAINER_INDEX, PCMCNV_MODULE_IID, 1, 1, 1, 2, PCM_INTERLEAVED, PCMENC_MODULE_IID)
AR_MODULE_PCMENC(MOD_INDEX, SG_INDEX, CONTAINER_INDEX, PCMENC_MODULE_IID, 1, 1, 1, 2, PCM_INTERLEAVED, RDSH_MODULE_IID)
AR_MODULE_RDSH(MOD_INDEX,   SG_INDEX, CONTAINER_INDEX, RDSH_MODULE_IID,   1, 0, 1, 0, PCM_DAI_ID, NONE_IID)

STREAM_CAPTURE_ROUTE(MOD_INDEX, PCM_DAI_ID)
