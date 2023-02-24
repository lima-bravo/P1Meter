#!/bin/bash
#
#


RSYNC=/usr/bin/rsync
LOCAL=/zfs/lodewijk/Programming/SmartMeter/
REMOTE=pi@p1pi.lan:/home/pi/Programming/SmartMeter/
FLAGS="--stats --progress"


get() {
	${RSYNC} -avuz ${REMOTE} ${LOCAL} ${FLAGS}
}

put() {
	${RSYNC} -avuz ${LOCAL} ${REMOTE} ${FLAGS} --exclude processed --exclude data
}


case "$1" in
	'get')
		get
		;;
	'put')
		put
		;;
	*)
		echo "Usage: $0 {get|put}"
		exit 1
		;;
esac

exit 0 
