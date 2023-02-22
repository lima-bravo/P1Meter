#!/bin/bash
#
# This script should be run by the /etc/rc.local script at startup inside a GNU screen
#
#
BASEDIR=/home/pi/Programming/SmartMeter/readSerial
COMMAND="/usr/bin/python -u ./readP1.py"  # -u puts python in unbuffered mode and allows it to stream to the tee log
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
    if [ -e ${TEEFILE} ]; then
      DATESTRING=`date +'%s'`
      mv ${TEEFILE} ../data/${TEEFILE}.${DATESTRING}
    fi	
    ${COMMAND} | egrep -v "E1 |E2 |T1 |T2 |P1 |P2 " | tee ${TEEFILE}
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

