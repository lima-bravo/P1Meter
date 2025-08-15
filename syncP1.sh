#!/bin/bash
#
# Synchronize the SmartMeter directory on p1pi to iMac
#
#
COMMAND=/opt/local/bin/rsync
SWITCHES="-avuz"
FLAGS="--progress --stats"
SOURCE="pi@p1pi:/home/pi/Programming/SmartMeter/"
DEST="/Volumes/apfs-user/lodewijk/Programming/HomeAutomation/SmartMeter"
#
# execute command
${COMMAND} ${SWITCHES} ${SOURCE} ${DEST} ${FLAGS}
#
