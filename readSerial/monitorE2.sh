#!/bin/bash
#
# pipe the output of 'tail -f logfile' through this script to see when the solar panels are generating electricity
#
DT=""
while read -r line; do
	if [[ $line =~ .*E2.* ]]; then
	#	echo "DT $line"
		timestamp=`date "+%y%m%d@%H%M%S"`
		echo "[$timestamp] $line"
	fi
done
