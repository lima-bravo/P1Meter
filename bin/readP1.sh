#!/bin/bash
#
# This script should be run by the /etc/rc.local script at startup inside a GNU screen
#
#
BASEDIR=/home/pi/Programming/SmartMeter/readSerial
COMMAND="/usr/bin/python3 -u ./readP1.py"  # -u puts python in unbuffered mode and allows it to stream to the tee log
NICE="nice -n -19 " # use the nice command to start the process at a high priority and reduce buffer timeouts
RUNNING=-1
TEEFILE="readP1.log"


checkIfRunning() {
  RESULT=`ps -ef | grep "${COMMAND}" | grep -v grep`

  if [ "${RESULT}" == "" ]; then
    echo "Not running"
    RUNNING=0
  else
    echo "${COMMAND} running"
    RUNNING=1
  fi

}


loop() {
  while [ 1 ]; do
    # cleanup the directoru and move all p1data files to the data directory
    for f in p1data.*; do
	if [[ -f $f ]]; then
		mv $f ../data/
	fi
    done

    # now process the log file
    if [ -e ${TEEFILE} ]; then
      DATESTRING=`date +'%s'`
      mv ${TEEFILE} ../data/${TEEFILE}.${DATESTRING}
    fi	
    ${COMMAND} | tee ${TEEFILE}
    sleep 1
  done
}


#
# Main Body
#
cd ${BASEDIR}

checkIfRunning

if [ ${RUNNING} -eq 0 ]; then
  loop
fi

