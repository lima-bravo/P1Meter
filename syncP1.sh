#!/bin/bash
#
# Synchronize the SmartMeter directory on p1pi to iMac
#
#
COMMAND=/usr/bin/rsync
SWITCHES="-avuz"
FLAGS="--progress --stats"
SOURCE="pi@p1pi:/home/pi/Programming/SmartMeter/"
DEST="/zfs/lodewijk/Programming/SmartMeter/"
#
# execute command
${COMMAND} ${SWITCHES} ${SOURCE} ${DEST} ${FLAGS}
#
