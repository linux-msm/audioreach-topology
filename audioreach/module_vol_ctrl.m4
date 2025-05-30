# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
include(`util/util.m4') dnl
dnl AR_MODULE_VOL_CTRL(index, sgidx, container-idx, iid,  maxip-ports, max-op-ports, src-port, dst-port, dist-iid
define(`AR_MODULE_VOL_CTRL',
`SectionVendorTuples."NAME_PREFIX.vol_ctrl$1_tuples" {'
`        tokens "audioreach_tokens"'
`'
`        tuples."word.u32_data" {'
`                AR_TKN_U32_MODULE_INSTANCE_ID STR($4)'
`                AR_TKN_U32_MODULE_ID STR(MODULE_ID_VOL_CTRL)'
`                AR_TKN_U32_MODULE_MAX_IP_PORTS STR($5)'
`                AR_TKN_U32_MODULE_MAX_OP_PORTS STR($6)'
`                AR_TKN_U32_MODULE_SRC_OP_PORT_ID STR($7)'
`                AR_TKN_U32_MODULE_DST_IN_PORT_ID STR($8)'
`                AR_TKN_U32_MODULE_SRC_INSTANCE_ID STR($4)'
`                AR_TKN_U32_MODULE_DST_INSTANCE_ID STR($9)'
`        }'
`}'
`'
`SectionData."NAME_PREFIX.vol_ctrl$1_data" {'
`        tuples "NAME_PREFIX.vol_ctrl$1_tuples"'
`}'
`'
`SectionWidget."NAME_PREFIX.vol_ctrl$1" {'
`        index STR($1)'
`        type "pga"'
`        no_pm "true"'
`        event_type "1"'
`        event_flags "15"'
`        subseq "10"'
`        data ['
`                "NAME_PREFIX.sub_graph$2_data"'
`                "NAME_PREFIX.container$3_data"'
`                "NAME_PREFIX.vol_ctrl$1_data"'
`        ]'
`	mixer ['
`		"`MultiMedia'eval($1 + 1)` Playback Volume'"'
`	]'
`}'
`'
`SectionTLV."`MultiMedia'eval($1 + 1)`_playback_vol_ctrl_tlv'" {'
`	scale {'
`		min "0"'
`		step "100"'
`		mute "0"'
`	}'
`}'
`SectionControlMixer."`MultiMedia'eval($1 + 1)` Playback Volume'" {'
`	Comment "Stream Global volume"'
`'
`	# control belongs to this index group'
`	index "$1"'
`'
`	# Channel register and shift for Front Left/Right'
`	channel."FL" {'
`		reg "0"'
`		shift "0"'
`	}'
`	channel."FR" {'
`		reg "0"'
`		shift "0"'
`	}'
`'
`	# max control value and whether value is inverted'
`	max "65535"'
`	invert "false"'
`'
`	# control uses bespoke driver get/put/info ID 0'
`	ops."ctl" {'
`		info "volsw"'
`		get "257"'
`		put "257"'
`	}'
`	tlv "`MultiMedia'eval($1 + 1)`_playback_vol_ctrl_tlv'"'
`}') dnl
