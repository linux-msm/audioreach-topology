# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
dnl DEVICE_SG_ADD(stream, name, stream-id, stream-index, 
dnl 	format, min-rate, max-rate, min-channels, max-channels,
dnl	domain, stack-size,
dnl	interface-type, interface-index, sd-line-idx, data-format,
dnl	sg-iid-start, cont-iid-start, mod-iid-start
define(`DEVICE_SG_ADD',
`undefine(`DEVICE_NAME') dnl'
`undefine(`DEVICE_DAI_ID') dnl'
`undefine(`DEVICE_FORMAT') dnl'
`undefine(`DEVICE_MIN_RATE') dnl'
`undefine(`DEVICE_MAX_RATE') dnl'
`undefine(`DEVICE_MIN_CHANNELS') dnl'
`undefine(`DEVICE_MAX_CHANNELS') dnl'
`undefine(`DEVICE_INTF_TYPE') dnl'
`undefine(`DEVICE_INTF_INDEX') dnl'
`undefine(`DEVICE_DATA_FORMAT') dnl'
`undefine(`SG_IID_START') dnl'
`undefine(`CONT_IID_START') dnl'
`undefine(`MOD_IID_START') dnl'
`define(`DEVICE_NAME', ``$2'') dnl'
`define(`DEVICE_DAI_ID', `$3') dnl'
`define(`DEVICE_FORMAT', `$4') dnl'
`define(`DEVICE_MIN_RATE', `$5') dnl'
`define(`DEVICE_MAX_RATE', `$6') dnl'
`define(`DEVICE_MIN_CHANNELS', `$7') dnl'
`define(`DEVICE_MAX_CHANNELS', `$8') dnl'
`define(`DEVICE_INTF_TYPE', `$9') dnl'
`define(`DEVICE_INTF_INDEX', `$10') dnl'
`define(`DEVICE_SD_LINE_IDX', `$11') dnl'
`define(`DEVICE_DATA_FORMAT', `$12') dnl'
`define(`SG_IID_START', `$13') dnl'
`define(`CONT_IID_START', `$14') dnl'
`define(`MOD_IID_START', `$15') dnl'
`define(`NAME_PREFIX', `device$3') dnl'
`define(`MIXER_PREFIX', ``$16'') dnl'
`include($1)') dnl

dnl DEVICE_AUDIO_IF_SG_ADD(stream, name, stream-id,
dnl     format, min-rate, max-rate, min-channels, max-channels,
dnl     interface-type, interface-index, sd-line-idx, data-format,
dnl     sg-iid-start, cont-iid-start, mod-iid-start, mixer-prefix,
dnl     sync-src, ctrl-data-out-enable,
dnl     slot-mask, nslots-per-frame, slot-width,
dnl     intf-mode, frame-sync-mode,
dnl     ctrl-invert-sync-pulse, ctrl-sync-data-delay,
dnl     qaif-type, active-lane-mask, frame-sync-rate,
dnl     bit-clk-type, inv-int-bit-clk, inv-ext-bit-clk)
define(`DEVICE_AUDIO_IF_SG_ADD',
`undefine(`DEVICE_NAME') dnl'
`undefine(`DEVICE_DAI_ID') dnl'
`undefine(`DEVICE_FORMAT') dnl'
`undefine(`DEVICE_MIN_RATE') dnl'
`undefine(`DEVICE_MAX_RATE') dnl'
`undefine(`DEVICE_MIN_CHANNELS') dnl'
`undefine(`DEVICE_MAX_CHANNELS') dnl'
`undefine(`DEVICE_INTF_TYPE') dnl'
`undefine(`DEVICE_INTF_INDEX') dnl'
`undefine(`DEVICE_SD_LINE_IDX') dnl'
`undefine(`DEVICE_DATA_FORMAT') dnl'
`undefine(`SG_IID_START') dnl'
`undefine(`CONT_IID_START') dnl'
`undefine(`MOD_IID_START') dnl'
`undefine(`DEVICE_AUDIO_IF_SYNC_SRC') dnl'
`undefine(`DEVICE_AUDIO_IF_CTRL_DATA_OUT_ENABLE') dnl'
`undefine(`DEVICE_AUDIO_IF_SLOT_MASK') dnl'
`undefine(`DEVICE_AUDIO_IF_NSLOTS_PER_FRAME') dnl'
`undefine(`DEVICE_AUDIO_IF_SLOT_WIDTH') dnl'
`undefine(`DEVICE_AUDIO_IF_INTF_MODE') dnl'
`undefine(`DEVICE_AUDIO_IF_FRAME_SYNC_MODE') dnl'
`undefine(`DEVICE_AUDIO_IF_CTRL_INVERT_SYNC_PULSE') dnl'
`undefine(`DEVICE_AUDIO_IF_CTRL_SYNC_DATA_DELAY') dnl'
`undefine(`DEVICE_AUDIO_IF_QAIF_TYPE') dnl'
`undefine(`DEVICE_AUDIO_IF_ACTIVE_LANE_MASK') dnl'
`undefine(`DEVICE_AUDIO_IF_FRAME_SYNC_RATE') dnl'
`undefine(`DEVICE_AUDIO_IF_BIT_CLK_TYPE') dnl'
`undefine(`DEVICE_AUDIO_IF_INV_INT_BIT_CLK') dnl'
`undefine(`DEVICE_AUDIO_IF_INV_EXT_BIT_CLK') dnl'
`define(`DEVICE_NAME', ``$2'') dnl'
`define(`DEVICE_DAI_ID', `$3') dnl'
`define(`DEVICE_FORMAT', `$4') dnl'
`define(`DEVICE_MIN_RATE', `$5') dnl'
`define(`DEVICE_MAX_RATE', `$6') dnl'
`define(`DEVICE_MIN_CHANNELS', `$7') dnl'
`define(`DEVICE_MAX_CHANNELS', `$8') dnl'
`define(`DEVICE_INTF_TYPE', `$9') dnl'
`define(`DEVICE_INTF_INDEX', `$10') dnl'
`define(`DEVICE_SD_LINE_IDX', `$11') dnl'
`define(`DEVICE_DATA_FORMAT', `$12') dnl'
`define(`SG_IID_START', `$13') dnl'
`define(`CONT_IID_START', `$14') dnl'
`define(`MOD_IID_START', `$15') dnl'
`define(`NAME_PREFIX', `device$3') dnl'
`define(`MIXER_PREFIX', ``$16'') dnl'
`define(`DEVICE_AUDIO_IF_SYNC_SRC', `$17') dnl'
`define(`DEVICE_AUDIO_IF_CTRL_DATA_OUT_ENABLE', `$18') dnl'
`define(`DEVICE_AUDIO_IF_SLOT_MASK', `$19') dnl'
`define(`DEVICE_AUDIO_IF_NSLOTS_PER_FRAME', `$20') dnl'
`define(`DEVICE_AUDIO_IF_SLOT_WIDTH', `$21') dnl'
`define(`DEVICE_AUDIO_IF_INTF_MODE', `$22') dnl'
`define(`DEVICE_AUDIO_IF_FRAME_SYNC_MODE', `$23') dnl'
`define(`DEVICE_AUDIO_IF_CTRL_INVERT_SYNC_PULSE', `$24') dnl'
`define(`DEVICE_AUDIO_IF_CTRL_SYNC_DATA_DELAY', `$25') dnl'
`define(`DEVICE_AUDIO_IF_QAIF_TYPE', `$26') dnl'
`define(`DEVICE_AUDIO_IF_ACTIVE_LANE_MASK', `$27') dnl'
`define(`DEVICE_AUDIO_IF_FRAME_SYNC_RATE', `$28') dnl'
`define(`DEVICE_AUDIO_IF_BIT_CLK_TYPE', `$29') dnl'
`define(`DEVICE_AUDIO_IF_INV_INT_BIT_CLK', `$30') dnl'
`define(`DEVICE_AUDIO_IF_INV_EXT_BIT_CLK', `$31') dnl'
`include($1)') dnl
