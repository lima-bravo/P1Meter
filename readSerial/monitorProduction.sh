#!/bin/bash
#
# pipe the output of 'tail -f logfile' through this script to see the current status
#
while read -r line; do
	timestamp=`date "+%y%m%d@%H%M%S"`
	echo "[$timestamp] $line"
done
