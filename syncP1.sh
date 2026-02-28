#!/bin/bash
#
# Synchronize the SmartMeter directory on p1pi to iMac
#
#
if [ "$(hostname -s)" != "iMac" ]; then
  echo "Error: This script must run on iMac (current host: $(hostname -s))." >&2
  exit 1
fi

COMMAND=/opt/local/bin/rsync
SWITCHES="-avuz"
FLAGS="--progress --stats"
SOURCE="pi@p1pi:/home/pi/Programming/SmartMeter/"
DEST="/Volumes/apfs-user/lodewijk/Archive/Programming/HomeAutomation/SmartMeter"
#
# check if the destination directory exists
if [ ! -d "${DEST}" ]; then
  echo "Error: Destination directory not found: ${DEST}" >&2
  exit 1
fi

# execute command
${COMMAND} ${SWITCHES} ${SOURCE} ${DEST} ${FLAGS}
#
# next find files in the data directory that are of size 0 and delete them, count deleted files
deleted=$(($(find "${DEST}/data" -type f -size 0 -delete -print | wc -l)))
echo "Deleted ${deleted} zero-size file(s)."
#


# now exit with success
exit 0