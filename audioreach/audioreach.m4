# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
define(`APM_SG_PERF_MODE_LOW_POWER', `0x1') dnl
define(`APM_SG_PERF_MODE_LOW_LATENCY', `0x2') dnl
define(`APM_SUB_GRAPH_DIRECTION_TX', `0x1') dnl
define(`APM_SUB_GRAPH_DIRECTION_RX', `0x2') dnl
define(`APM_SUB_GRAPH_SID_AUDIO_PLAYBACK', `0x1') dnl
define(`APM_SUB_GRAPH_SID_AUDIO_RECORD', `0x2') dnl
define(`APM_SUB_GRAPH_SID_VOICE_CALL', `0x3') dnl
dnl container capability ID Pre/Post Processing (PP) (legacy)
define(`APM_CONTAINER_CAP_ID_PP', `0x1') dnl
dnl container capability ID Compression/Decompression (CD) (legacy)
define(`APM_CONTAINER_CAP_ID_CD', `0x2') dnl
dnl container capability ID End Point(EP) (legacy)
define(`APM_CONTAINER_CAP_ID_EP', `0x3') dnl
dnl container capability ID Offload (OLC) (legacy)
define(`APM_CONTAINER_CAP_ID_OLC', `0x4') dnl
dnl Container type identifier for a specialized container
define(`APM_CONTAINER_TYPE_ID_SC', `0x0B001000') dnl
dnl Container type identifier for a generic container
define(`APM_CONTAINER_TYPE_ID_GC', `0x0B001001') dnl
dnl Container type identifier for an offload container
define(`APM_CONTAINER_TYPE_ID_OLC', `0x0B001002') dnl
dnl Container type identifier for a wear container
define(`APM_CONTAINER_TYPE_ID_WC', `0x0B001003') dnl
define(`APM_CONT_GRAPH_POS_STREAM', `0x1') dnl
dnl container graph position Per Stream Per Device
define(`APM_CONT_GRAPH_POS_PER_STR_PER_DEV', `0x2') dnl
dnl container graph position Stream-Device 
define(`APM_CONT_GRAPH_POS_STR_DEV', `0x3') dnl
dnl container graph position Global Device 
define(`APM_CONT_GRAPH_POS_GLOBAL_DEV', `0x4') dnl
dnl container processor domain for  Invalid Domain 
define(`APM_PROC_DOMAIN_ID_INVALID', `0x0') dnl
dnl container procesor domain  Modem DSP 
define(`APM_PROC_DOMAIN_ID_MDSP', `0x1') dnl
dnl container processor domain for  Audio DSP 
define(`APM_PROC_DOMAIN_ID_ADSP', `0x2') dnl
dnl container procesor domain  Sensors DSP 
define(`APM_PROC_DOMAIN_ID_SDSP', `0x4') dnl
dnl container procesor domain  Compute DSP 
define(`APM_PROC_DOMAIN_ID_CDSP', `0x5') dnl
dnl container graph position Stream 
define(`APM_CONT_GRAPH_POS_STREAM', `0x1') dnl
dnl container graph position Per Stream Per Device
define(`APM_CONT_GRAPH_POS_PER_STR_PER_DEV', `0x2') dnl
dnl container graph position Stream-Device 
define(`APM_CONT_GRAPH_POS_STR_DEV', `0x3') dnl
dnl container graph position Global Device 
define(`APM_CONT_GRAPH_POS_GLOBAL_DEV', `0x4') dnl
define(`PCM_INTERLEAVED', `1') dnl
define(`PCM_DEINTERLEAVED_PACKED', `2') dnl
define(`PCM_DEINTERLEAVED_UNPACKED', `3') dnl
define(`DATA_FORMAT_FIXED_POINT', `1') dnl
define(`LPAIF_INTF_TYPE_LPAIF', `0') dnl
define(`LPAIF_INTF_TYPE_RXTX', `1') dnl
define(`LPAIF_INTF_TYPE_WSA',`2') dnl
define(`LPAIF_INTF_TYPE_VA', `3') dnl
define(`LPAIF_INTF_TYPE_AXI', `4') dnl
define(`LPAIF_INTF_TYPE_AUD', `5') dnl
define(`LPAIF_INTF_TYPE_SDR', `6') dnl
define(`I2S_INTF_TYPE_PRIMARY', `0') dnl
define(`I2S_INTF_TYPE_SECONDARY', `1') dnl
define(`I2S_INTF_TYPE_TERTIARY', `2') dnl
define(`I2S_INTF_TYPE_QUATERNARY', `3') dnl
define(`I2S_INTF_TYPE_QUINARY', `4') dnl
define(`SD_LINE_IDX_I2S_SD0', `1') dnl
define(`SD_LINE_IDX_I2S_SD1', `2') dnl
define(`SD_LINE_IDX_I2S_SD2', `3') dnl
define(`SD_LINE_IDX_I2S_SD3', `4') dnl
define(`SD_LINE_IDX_I2S_QUAD01', `5') dnl
define(`SD_LINE_IDX_I2S_QUAD23', `6') dnl
define(`SD_LINE_IDX_I2S_6CHS', `7') dnl
define(`SD_LINE_IDX_I2S_8CHS', `8') dnl
define(`CODEC_INTF_IDX_RX0', `1') dnl
define(`CODEC_INTF_IDX_TX0', `1') dnl
define(`CODEC_INTF_IDX_RX1', `2') dnl
define(`CODEC_INTF_IDX_TX1', `2') dnl
define(`CODEC_INTF_IDX_RX2', `3') dnl
define(`CODEC_INTF_IDX_TX2', `3') dnl
define(`CODEC_INTF_IDX_RX3', `4') dnl
define(`CODEC_INTF_IDX_TX3', `4') dnl
define(`CODEC_INTF_IDX_RX4', `5') dnl
define(`CODEC_INTF_IDX_TX4', `5') dnl
define(`CODEC_INTF_IDX_RX5', `6') dnl
define(`CODEC_INTF_IDX_TX5', `6') dnl
define(`CODEC_INTF_IDX_RX6', `7') dnl
define(`CODEC_INTF_IDX_RX7', `8') dnl
dnl Modules
define(`MODULE_ID_WR_SHARED_MEM_CLIENT', `0x0700105C') dnl
define(`MODULE_ID_WR_SHARED_MEM_EP', `0x07001000') dnl
define(`MODULE_ID_DATA_LOGGING', `0x0700101A') dnl
define(`MODULE_ID_RD_SHARED_MEM_EP', `0x07001001') dnl
define(`MODULE_ID_PCM_CNV', `0x07001003') dnl
define(`MODULE_ID_PCM_ENC', `0x07001004') dnl
define(`MODULE_ID_PCM_DEC', `0x07001005') dnl
define(`MODULE_ID_RD_SHARED_MEM_CLIENT', `0x0700105D') dnl
define(`MODULE_ID_DISPLAY_PORT_SINK', `0x07001069') dnl
define(`MODULE_ID_CODEC_DMA_SINK', `0x07001023') dnl
define(`MODULE_ID_CODEC_DMA_SOURCE', `0x07001024') dnl
define(`MODULE_ID_LOG', `0x0700101A') dnl
define(`MODULE_ID_PLACEHOLDER_ENCODER', `0x07001008') dnl
define(`MODULE_ID_PLACEHOLDER_DECODER', `0x07001009') dnl
define(`MODULE_ID_I2S_SINK', `0x0700100A') dnl
define(`MODULE_ID_I2S_SOURCE', `0x0700100B') dnl
define(`MODULE_ID_MFC', `0x07001015') dnl
define(`MODULE_ID_VOL_CTRL', `0x0700101B') dnl
define(`MODULE_ID_SMECNS_V2', `0x07001031') dnl
define(`MODULE_ID_DISPLAY_PORT_SINK', `0x07001069') dnl
dnl Linux frontend dai ids
define(`FRONTEND_DAI_MULTIMEDIA1', `0') dnl
define(`FRONTEND_DAI_MULTIMEDIA2', `1') dnl
define(`FRONTEND_DAI_MULTIMEDIA3', `2') dnl
define(`FRONTEND_DAI_MULTIMEDIA4', `3') dnl
define(`FRONTEND_DAI_MULTIMEDIA5', `4') dnl
define(`FRONTEND_DAI_MULTIMEDIA6', `5') dnl
define(`FRONTEND_DAI_MULTIMEDIA7', `6') dnl
define(`FRONTEND_DAI_MULTIMEDIA8', `7') dnl
dnl Audio Process Manager (APM) virtual ports IDs 
define(`HDMI_RX', `1') dnl
define(`SLIMBUS_0_RX', `2') dnl
define(`SLIMBUS_0_TX', `3') dnl
define(`SLIMBUS_1_RX', `4') dnl
define(`SLIMBUS_1_TX', `5') dnl
define(`SLIMBUS_2_RX', `6') dnl
define(`SLIMBUS_2_TX', `7') dnl
define(`SLIMBUS_3_RX', `8') dnl
define(`SLIMBUS_3_TX', `9') dnl
define(`SLIMBUS_4_RX', `10') dnl
define(`SLIMBUS_4_TX', `11') dnl
define(`SLIMBUS_5_RX', `12') dnl
define(`SLIMBUS_5_TX', `13') dnl
define(`SLIMBUS_6_RX', `14') dnl
define(`SLIMBUS_6_TX', `15') dnl
define(`PRIMARY_MI2S_RX', `16') dnl
define(`PRIMARY_MI2S_TX', `17') dnl
define(`SECONDARY_MI2S_RX', `18') dnl
define(`SECONDARY_MI2S_TX', `19') dnl
define(`TERTIARY_MI2S_RX', `20') dnl
define(`TERTIARY_MI2S_TX', `21') dnl
define(`QUATERNARY_MI2S_RX', `22') dnl
define(`QUATERNARY_MI2S_TX', `23') dnl
define(`PRIMARY_TDM_RX_0', `24') dnl
define(`PRIMARY_TDM_TX_0', `25') dnl
define(`PRIMARY_TDM_RX_1', `26') dnl
define(`PRIMARY_TDM_TX_1', `27') dnl
define(`PRIMARY_TDM_RX_2', `28') dnl
define(`PRIMARY_TDM_TX_2', `29') dnl
define(`PRIMARY_TDM_RX_3', `30') dnl
define(`PRIMARY_TDM_TX_3', `31') dnl
define(`PRIMARY_TDM_RX_4', `32') dnl
define(`PRIMARY_TDM_TX_4', `33') dnl
define(`PRIMARY_TDM_RX_5', `34') dnl
define(`PRIMARY_TDM_TX_5', `35') dnl
define(`PRIMARY_TDM_RX_6', `36') dnl
define(`PRIMARY_TDM_TX_6', `37') dnl
define(`PRIMARY_TDM_RX_7', `38') dnl
define(`PRIMARY_TDM_TX_7', `39') dnl
define(`SECONDARY_TDM_RX_0', `40') dnl
define(`SECONDARY_TDM_TX_0', `41') dnl
define(`SECONDARY_TDM_RX_1', `42') dnl
define(`SECONDARY_TDM_TX_1', `43') dnl
define(`SECONDARY_TDM_RX_2', `44') dnl
define(`SECONDARY_TDM_TX_2', `45') dnl
define(`SECONDARY_TDM_RX_3', `46') dnl
define(`SECONDARY_TDM_TX_3', `47') dnl
define(`SECONDARY_TDM_RX_4', `48') dnl
define(`SECONDARY_TDM_TX_4', `49') dnl
define(`SECONDARY_TDM_RX_5', `50') dnl
define(`SECONDARY_TDM_TX_5', `51') dnl
define(`SECONDARY_TDM_RX_6', `52') dnl
define(`SECONDARY_TDM_TX_6', `53') dnl
define(`SECONDARY_TDM_RX_7', `54') dnl
define(`SECONDARY_TDM_TX_7', `55') dnl
define(`TERTIARY_TDM_RX_0', `56') dnl
define(`TERTIARY_TDM_TX_0', `57') dnl
define(`TERTIARY_TDM_RX_1', `58') dnl
define(`TERTIARY_TDM_TX_1', `59') dnl
define(`TERTIARY_TDM_RX_2', `60') dnl
define(`TERTIARY_TDM_TX_2', `61') dnl
define(`TERTIARY_TDM_RX_3', `62') dnl
define(`TERTIARY_TDM_TX_3', `63') dnl
define(`TERTIARY_TDM_RX_4', `64') dnl
define(`TERTIARY_TDM_TX_4', `65') dnl
define(`TERTIARY_TDM_RX_5', `66') dnl
define(`TERTIARY_TDM_TX_5', `67') dnl
define(`TERTIARY_TDM_RX_6', `68') dnl
define(`TERTIARY_TDM_TX_6', `69') dnl
define(`TERTIARY_TDM_RX_7', `70') dnl
define(`TERTIARY_TDM_TX_7', `71') dnl
define(`QUATERNARY_TDM_RX_0', `72') dnl
define(`QUATERNARY_TDM_TX_0', `73') dnl
define(`QUATERNARY_TDM_RX_1', `74') dnl
define(`QUATERNARY_TDM_TX_1', `75') dnl
define(`QUATERNARY_TDM_RX_2', `76') dnl
define(`QUATERNARY_TDM_TX_2', `77') dnl
define(`QUATERNARY_TDM_RX_3', `78') dnl
define(`QUATERNARY_TDM_TX_3', `79') dnl
define(`QUATERNARY_TDM_RX_4', `80') dnl
define(`QUATERNARY_TDM_TX_4', `81') dnl
define(`QUATERNARY_TDM_RX_5', `82') dnl
define(`QUATERNARY_TDM_TX_5', `83') dnl
define(`QUATERNARY_TDM_RX_6', `84') dnl
define(`QUATERNARY_TDM_TX_6', `85') dnl
define(`QUATERNARY_TDM_RX_7', `86') dnl
define(`QUATERNARY_TDM_TX_7', `87') dnl
define(`QUINARY_TDM_RX_0', `88') dnl
define(`QUINARY_TDM_TX_0', `89') dnl
define(`QUINARY_TDM_RX_1', `90') dnl
define(`QUINARY_TDM_TX_1', `91') dnl
define(`QUINARY_TDM_RX_2', `92') dnl
define(`QUINARY_TDM_TX_2', `93') dnl
define(`QUINARY_TDM_RX_3', `94') dnl
define(`QUINARY_TDM_TX_3', `95') dnl
define(`QUINARY_TDM_RX_4', `96') dnl
define(`QUINARY_TDM_TX_4', `97') dnl
define(`QUINARY_TDM_RX_5', `98') dnl
define(`QUINARY_TDM_TX_5', `99') dnl
define(`QUINARY_TDM_RX_6', `100') dnl
define(`QUINARY_TDM_TX_6', `101') dnl
define(`QUINARY_TDM_RX_7', `102') dnl
define(`QUINARY_TDM_TX_7', `103') dnl
define(`DISPLAY_PORT_RX', `104') dnl
define(`WSA_CODEC_DMA_RX_0', `105') dnl
define(`WSA_CODEC_DMA_TX_0', `106') dnl
define(`WSA_CODEC_DMA_RX_1', `107') dnl
define(`WSA_CODEC_DMA_TX_1', `108') dnl
define(`WSA_CODEC_DMA_TX_2', `109') dnl
define(`VA_CODEC_DMA_TX_0', `110') dnl
define(`VA_CODEC_DMA_TX_1', `111') dnl
define(`VA_CODEC_DMA_TX_2', `112') dnl
define(`RX_CODEC_DMA_RX_0', `113') dnl
define(`TX_CODEC_DMA_TX_0', `114') dnl
define(`RX_CODEC_DMA_RX_1', `115') dnl
define(`TX_CODEC_DMA_TX_1', `116') dnl
define(`RX_CODEC_DMA_RX_2', `117') dnl
define(`TX_CODEC_DMA_TX_2', `118') dnl
define(`RX_CODEC_DMA_RX_3', `119') dnl
define(`TX_CODEC_DMA_TX_3', `120') dnl
define(`RX_CODEC_DMA_RX_4', `121') dnl
define(`TX_CODEC_DMA_TX_4', `122') dnl
define(`RX_CODEC_DMA_RX_5', `123') dnl
define(`TX_CODEC_DMA_TX_5', `124') dnl
define(`RX_CODEC_DMA_RX_6', `125') dnl
define(`RX_CODEC_DMA_RX_7', `126') dnl
define(`QUINARY_MI2S_RX', `127') dnl
define(`QUINARY_MI2S_TX', `128') dnl
define(`DISPLAY_PORT_RX_0', `104') dnl
define(`DISPLAY_PORT_RX_1', `129') dnl
define(`DISPLAY_PORT_RX_2', `130') dnl
define(`DISPLAY_PORT_RX_3', `131') dnl
define(`DISPLAY_PORT_RX_4', `132') dnl
define(`DISPLAY_PORT_RX_5', `133') dnl
define(`DISPLAY_PORT_RX_6', `134') dnl
define(`DISPLAY_PORT_RX_7', `135') dnl
define(`SND_SOC_AR_TPLG_FE_BE_GRAPH_CTL_MIX', `256') dnl
define(`SND_SOC_AR_TPLG_VOL_CTL', `257') dnl
define(`NONE_IID', `0x0') dnl
