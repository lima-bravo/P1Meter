#!/bin/bash
#
# pipe the output of the tail through this script
#
while read -r line; do
	timestamp=`date "+%y%m%d@%H%M%S"`
	echo "[$timestamp] $line"
done
