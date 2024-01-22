#!/bin/bash
#
# This script executes the upload to the progress database on imac.
#
# It runs in an endless loop, until killed.
#
#
SLEEP=3600 # check every hour if there is any work to do
#SLEEP=10
#
DATADIR=/home/pi/Programming/SmartMeter/data

while [ 1 ]; do
	# check if there is a p1data file in the DATADIR
	LSCNT=`ls ${DATADIR}/*| grep p1data | wc -l`
	echo "`date` : P1data file count : " ${LSCNT}
	if [ ${LSCNT} -gt 0 ]; then
		sleep 5 # to prevent race condition of processing a file still being moved
		python3 /home/pi/Programming/SmartMeter/processP1data/processp1data/processp1data.py
		if [ $? -eq 0 ]; then
			echo Process completed successfully
		fi
	fi
	sleep ${SLEEP}
done
