#!/bin/bash
#
# pipe the output of the tail through this script
#
DT=""
while read -r line; do
	if [[ $line =~ .*E2.* ]]; then
	#	echo "DT $line"
		timestamp=`date "+%y%m%d@%H%M%S"`
		echo "[$timestamp] $line"
	fi
done
