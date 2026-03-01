#!/bin/bash
#
# If LOGFILE exists, runs tail -f on it and filters lines containing E2 (solar generation).
# Tail's stderr (e.g. "file has been replaced" after log rotation) is suppressed.
#
LOGFILE=/home/pi/Programming/SmartMeter/readSerial/readP1.log

if [[ ! -e "$LOGFILE" ]]; then
	echo "LOGFILE not found: $LOGFILE" >&2
	exit 1
fi
# write a note to stdout that the E2 monitor is starting
echo "Starting E2 monitor"
# Suppress tail's stderr (e.g. "file has been replaced" after log rotation)
tail -F "$LOGFILE" 2>/dev/null | while read -r line; do
	if [[ $line =~ .*E2.* ]]; then
		timestamp=$(date "+%y%m%d@%H%M%S")
		echo "[$timestamp] $line"
	fi
done
