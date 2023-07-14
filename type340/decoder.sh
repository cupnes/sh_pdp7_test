#!/bin/bash

set -ue

usage() {
	echo 'Usage:' 1>&2
	echo -e "\t$0 TYPE340_MACHINE_CODE_FILE" 1>&2
	echo -e "\t$0 -h" 1>&2
}

echo_mode_name() {
	local id=$1
	case $id in
	0)
		echo 'Parameter Mode'
		;;
	1)
		echo 'Point Mode'
		;;
	4)
		echo 'Vector Mode'
		;;
	*)
		echo 'Error: Unsupported mode id.' 1>&2
		exit 1
		;;
	esac
}

if [ $# -eq 1 ] && [ "$1" = '-h' ]; then
	usage
	exit 0
fi
if [ $# -ne 1 ]; then
	usage
	exit 1
fi

TYPE340_MACHINE_CODE_FILE=$1
NEXT_MODE=0

decode_param_mode() {
	local machine_code_8=$1
	local machine_code_10=$(bc <<< "ibase=8;$machine_code_8")

	local intensity=$((machine_code_10 & 3))
	local set_intensity_bit=$(((machine_code_10 & 4) >> 2))
	local scale=$(((machine_code_10 & 48) >> 4))
	local set_scale_bit=$(((machine_code_10 & 64) >> 6))
	local set_stop_int=$(((machine_code_10 & 512) >> 9))
	local set_stop_bit=$(((machine_code_10 & 1024) >> 10))
	local lp_ena=$(((machine_code_10 & 2048) >> 11))
	local set_lp_ena=$(((machine_code_10 & 4096) >> 12))
	NEXT_MODE=$(((machine_code_10 & 57344) >> 13))

	echo "# code:$machine_code_8 ($(echo_mode_name 0))"
	echo -e "- next_mode:\t$NEXT_MODE($(echo_mode_name $NEXT_MODE))"
	echo -e "- set_lp_ena:\t$set_lp_ena"
	echo -e "- lp_ena:\t$lp_ena"
	echo -e "- set_stop_bit:\t$set_stop_bit"
	echo -e "- set_stop_int:\t$set_stop_int"
	echo -e "- set_scale_bit:\t$set_scale_bit"
	echo -e "- scale:\t$scale"
	echo -e "- set_intensity_bit:\t$set_intensity_bit"
	echo -e "- intensity:\t$intensity"
	echo
}

decode_point_mode() {
	local machine_code_8=$1
	local machine_code_10=$(bc <<< "ibase=8;$machine_code_8")

	local pos=$((machine_code_10 & 1023))
	local intensify=$(((machine_code_10 & 1024) >> 10))
	local lp_ena=$(((machine_code_10 & 2048) >> 11))
	local set_lp_ena=$(((machine_code_10 & 4096) >> 12))
	NEXT_MODE=$(((machine_code_10 & 57344) >> 13))
	local axis=$(((machine_code_10 & 65536) >> 16))
	local axis_char='X'
	if [ $axis -eq 1 ]; then
		axis_char='Y'
	fi

	echo "# code:$machine_code_8 ($(echo_mode_name 1))"
	echo -e "- axis:\t$axis($axis_char)"
	echo -e "- next_mode:\t$NEXT_MODE($(echo_mode_name $NEXT_MODE))"
	echo -e "- set_lp_ena:\t$set_lp_ena"
	echo -e "- lp_ena:\t$lp_ena"
	echo -e "- intensify:\t$intensify"
	echo -e "- pos:\t$pos"
	echo
}

decode_vector_mode() {
	local machine_code_8=$1
	local machine_code_10=$(bc <<< "ibase=8;$machine_code_8")

	local dx=$((machine_code_10 & 127))
	local sx=$(((machine_code_10 & 128) >> 7))
	local dy=$(((machine_code_10 & 32512) >> 8))
	local sy=$(((machine_code_10 & 32768) >> 15))
	local draw_line=$(((machine_code_10 & 65536) >> 16))
	local escape=$(((machine_code_10 & 131072) >> 17))

	NEXT_MODE=4
	if [ $escape -eq 1 ]; then
		NEXT_MODE=0
	fi

	echo "# code:$machine_code_8 ($(echo_mode_name 4))"
	echo -e "- escape:\t$escape(next_mode:$(echo_mode_name $NEXT_MODE))"
	echo -e "- draw_line:\t$draw_line"
	echo -e "- sy:\t$sy"
	echo -e "- dy:\t$dy"
	echo -e "- sx:\t$sx"
	echo -e "- dx:\t$dx"
	echo
}

main() {
	local current_mode=0

	for type340_machine_code in $(cat $TYPE340_MACHINE_CODE_FILE); do
		case $current_mode in
		0)
			decode_param_mode $type340_machine_code
			;;
		1)
			decode_point_mode $type340_machine_code
			;;
		4)
			decode_vector_mode $type340_machine_code
			;;
		*)
			echo 'Error: Unsupported mode.' 1>&2
			exit 1
			;;
		esac
		current_mode=$NEXT_MODE
	done
}

main
