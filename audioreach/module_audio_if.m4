dnl Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
dnl SPDX-License-Identifier: BSD-3-Clause
include(`util/util.m4') dnl

dnl
dnl Audio IF module macros
dnl
dnl These are the unified serial-interface endpoint modules used on newer QCOM
dnl platforms. The topology carries the interface-specific configuration and the
dnl kernel applies the same token set for Audio IF sink/source modules, allowing
dnl the same model to work for TDM, PCM and I2S by changing intf_mode and the
dnl related serial-interface fields.
dnl
dnl Parameter list shared by sink/source macros:
dnl   $1  = module index
dnl   $2  = subgraph index
dnl   $3  = container index
dnl   $4  = module instance ID (IID)
dnl   $5  = max input ports
dnl   $6  = max output ports
dnl   $7  = src op port ID
dnl   $8  = dst in port ID
dnl   $9  = hw_if_type
dnl   $10 = hw_if_idx
dnl   $11 = data_format
dnl   $12 = sync_src
dnl   $13 = ctrl_data_out_enable
dnl   $14 = slot_mask
dnl   $15 = nslots_per_frame
dnl   $16 = slot_width
dnl   $17 = intf_mode
dnl   $18 = frame_sync_mode
dnl   $19 = ctrl_invert_sync_pulse
dnl   $20 = ctrl_sync_data_delay
dnl   $21 = qaif_type
dnl   $22 = active_lane_mask
dnl   $23 = frame_sync_rate
dnl   $24 = bit_clk_type
dnl   $25 = inv_int_bit_clk
dnl   $26 = inv_ext_bit_clk
dnl   $27 = device name
dnl   $28 = dst module IID
dnl

define(`AR_MODULE_AUDIO_IF_SINK',
`'
`SectionVendorTuples."NAME_PREFIX.audio_if_rx$1_tuples" {'
`        tokens "audioreach_tokens"'
`'
`        tuples."word.u32_data" {'
`                AR_TKN_U32_MODULE_INSTANCE_ID STR($4)'
`                AR_TKN_U32_MODULE_ID STR(MODULE_ID_AUDIO_IF_SINK)'
`                AR_TKN_U32_MODULE_MAX_IP_PORTS STR($5)'
`                AR_TKN_U32_MODULE_MAX_OP_PORTS STR($6)'
`                AR_TKN_U32_MODULE_SRC_OP_PORT_ID STR($7)'
`                AR_TKN_U32_MODULE_DST_IN_PORT_ID STR($8)'
`                AR_TKN_U32_MODULE_SRC_INSTANCE_ID STR($4)'
`                AR_TKN_U32_MODULE_DST_INSTANCE_ID STR($28)'
`                AR_TKN_U32_MODULE_HW_IF_TYPE STR($9)'
`                AR_TKN_U32_MODULE_HW_IF_IDX STR($10)'
`                AR_TKN_U32_MODULE_FMT_DATA STR($11)'
`                AR_TKN_U32_MODULE_SYNC_SRC STR($12)'
`                AR_TKN_U32_MODULE_CTRL_DATA_OUT_ENABLE STR($13)'
`                AR_TKN_U32_MODULE_SLOT_MASK STR($14)'
`                AR_TKN_U32_MODULE_NSLOTS_PER_FRAME STR($15)'
`                AR_TKN_U32_MODULE_SLOT_WIDTH STR($16)'
`                AR_TKN_U32_MODULE_INTF_MODE STR($17)'
`                AR_TKN_U32_MODULE_SYNC_MODE STR($18)'
`                AR_TKN_U32_MODULE_CTRL_INVERT_SYNC_PULSE STR($19)'
`                AR_TKN_U32_MODULE_CTRL_SYNC_DATA_DELAY STR($20)'
`                AR_TKN_U32_MODULE_QAIF_TYPE STR($21)'
`                AR_TKN_U32_MODULE_ACTIVE_LANE_MASK STR($22)'
`                AR_TKN_U32_MODULE_FRAME_SYNC_RATE STR($23)'
`                AR_TKN_U32_MODULE_BIT_CLK_TYPE STR($24)'
`                AR_TKN_U32_MODULE_INV_INT_BIT_CLK STR($25)'
`                AR_TKN_U32_MODULE_INV_EXT_BIT_CLK STR($26)'
`        }'
`}'
`'
`SectionData."NAME_PREFIX.audio_if_rx$1_data" {'
`        tuples "NAME_PREFIX.audio_if_rx$1_tuples"'
`}'
`'
`SectionWidget."NAME_PREFIX.audio_if_rx$1" {'
`        index STR($1)'
`        type "aif_in"'
`        no_pm "true"'
`        stream_name "$27 Playback"'
`        subseq "10"'
`        data ['
`                "NAME_PREFIX.sub_graph$2_data"'
`                "NAME_PREFIX.container$3_data"'
`                "NAME_PREFIX.audio_if_rx$1_data"'
`        ]'
`}') dnl

define(`AR_MODULE_AUDIO_IF_SOURCE',
`'
`SectionVendorTuples."NAME_PREFIX.audio_if_tx$1_tuples" {'
`        tokens "audioreach_tokens"'
`'
`        tuples."word.u32_data" {'
`                AR_TKN_U32_MODULE_INSTANCE_ID STR($4)'
`                AR_TKN_U32_MODULE_ID STR(MODULE_ID_AUDIO_IF_SOURCE)'
`                AR_TKN_U32_MODULE_MAX_IP_PORTS STR($5)'
`                AR_TKN_U32_MODULE_MAX_OP_PORTS STR($6)'
`                AR_TKN_U32_MODULE_SRC_OP_PORT_ID STR($7)'
`                AR_TKN_U32_MODULE_DST_IN_PORT_ID STR($8)'
`                AR_TKN_U32_MODULE_SRC_INSTANCE_ID STR($4)'
`                AR_TKN_U32_MODULE_DST_INSTANCE_ID STR($28)'
`                AR_TKN_U32_MODULE_HW_IF_TYPE STR($9)'
`                AR_TKN_U32_MODULE_HW_IF_IDX STR($10)'
`                AR_TKN_U32_MODULE_FMT_DATA STR($11)'
`                AR_TKN_U32_MODULE_SYNC_SRC STR($12)'
`                AR_TKN_U32_MODULE_CTRL_DATA_OUT_ENABLE STR($13)'
`                AR_TKN_U32_MODULE_SLOT_MASK STR($14)'
`                AR_TKN_U32_MODULE_NSLOTS_PER_FRAME STR($15)'
`                AR_TKN_U32_MODULE_SLOT_WIDTH STR($16)'
`                AR_TKN_U32_MODULE_INTF_MODE STR($17)'
`                AR_TKN_U32_MODULE_SYNC_MODE STR($18)'
`                AR_TKN_U32_MODULE_CTRL_INVERT_SYNC_PULSE STR($19)'
`                AR_TKN_U32_MODULE_CTRL_SYNC_DATA_DELAY STR($20)'
`                AR_TKN_U32_MODULE_QAIF_TYPE STR($21)'
`                AR_TKN_U32_MODULE_ACTIVE_LANE_MASK STR($22)'
`                AR_TKN_U32_MODULE_FRAME_SYNC_RATE STR($23)'
`                AR_TKN_U32_MODULE_BIT_CLK_TYPE STR($24)'
`                AR_TKN_U32_MODULE_INV_INT_BIT_CLK STR($25)'
`                AR_TKN_U32_MODULE_INV_EXT_BIT_CLK STR($26)'
`        }'
`}'
`'
`SectionData."NAME_PREFIX.audio_if_tx$1_data" {'
`        tuples "NAME_PREFIX.audio_if_tx$1_tuples"'
`}'
`'
`SectionWidget."NAME_PREFIX.audio_if_tx$1" {'
`        index STR($1)'
`        type "aif_out"'
`        no_pm "true"'
`        stream_name "$27 Capture"'
`        subseq "10"'
`        data ['
`                "NAME_PREFIX.sub_graph$2_data"'
`                "NAME_PREFIX.container$3_data"'
`                "NAME_PREFIX.audio_if_tx$1_data"'
`        ]'
`}') dnl
