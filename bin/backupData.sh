#!/bin/bash
#
# Backup the data directory to iMac via rsync
#
#

RSYNC=/usr/bin/rsync
LOCAL=/home/pi/Programming/SmartMeter/data/
REMOTE=lodewijk@imac.lan:/Volumes/apfs-user/lodewijk/Archive/Programming/HomeAutomation/SmartMeter/data/
FLAGS="--stats --progress"

# check if we are on host p1pi
if [ "$(hostname -s)" != "p1pi" ]; then
	echo "Error: This script must run on p1pi (current host: $(hostname -s))." >&2
	exit 1
fi
# check if rsync exists
if [ ! -x ${RSYNC} ]; then
	echo "rsync not found"
	exit 1
fi

# check if local directory exists
if [ ! -d ${LOCAL} ]; then
	echo "local directory not found"
	exit 1
fi  

deleted=$(($(find "${LOCAL}" -type f -size 0 -delete -print | wc -l)))
echo "Deleted ${deleted} zero-size file(s)."

# now execute the rsync command

${RSYNC} -avuz ${LOCAL} ${REMOTE} ${FLAGS}

# check the exit status
if [ $? -ne 0 ]; then
	echo "rsync failed, not deleting backed up data."
	exit 1
fi

# now find and delete all files in the local directory that are older than 30 days
deleted=$(($(find ${LOCAL} -type f -mtime +30 -print -delete | wc -l)))
echo "Deleted ${deleted} files older than 30 days."

# now exit with success
exit 0