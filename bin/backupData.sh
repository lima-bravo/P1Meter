#!/bin/bash
#
# Backup the data directory to iMac via rsync
#
#

RSYNC=/usr/bin/rsync
LOCAL=/home/pi/Programming/SmartMeter/data/
REMOTE=lodewijk@imac.lan:/zfs/lodewijk/Archive/Programming/HomeAutomation/SmartMeter/data/
FLAGS="--stats --progress"

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

# now execute the rsync command

${RSYNC} -avuz ${LOCAL} ${REMOTE} ${FLAGS}

# check the exit status
if [ $? -ne 0 ]; then
	echo "rsync failed, not deleting backed up data."
	exit 1
fi

# now find and delete all files in the local directory that are older than 30 days
find ${LOCAL} -type f -mtime +30 -print # -delete

# check the exit status
if [ $? -ne 0 ]; then
	echo "deletion failed"
	exit 1
fi

# now exit with success
exit 0