#!/bin/bash

set -ue
# set -uex

usage() {
	echo 'Usage:' 1>&2
	echo -e "\t$0 SRC_ML_FILE DST_SIMH_FILE START_ADDR" 1>&2
	echo -e "\t$0 -h" 1>&2
}

if [ $# -eq 1 ]; then
	if [ "$1" = '-h' ]; then
		usage
		exit 0
	fi
fi
if [ $# -ne 3 ]; then
	usage
	exit 1
fi

SRC_ML_FILE=$1
DST_SIMH_FILE=$2
START_ADDR=$3

for ml in $(cat $SRC_ML_FILE); do
	echo "d $START_ADDR $ml"
	START_ADDR=$(bc <<< "obase=8;ibase=8;$START_ADDR + 1")
done >$DST_SIMH_FILE
