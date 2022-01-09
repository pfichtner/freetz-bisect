#!/bin/sh

WAIT_FOR_CONTENT='System Init'
TIMEOUT=60
SERIAL_DEV=/dev/ttyUSB0
SERIAL_SPEED=38400
IMAGES=images

power() {
   mosquitto_pub -h mqtt -t 'cmnd/tasmota-6205/POWER1' -m "$1"
}

rm -rf $IMAGES/*
yes "" | make oldconfig
make

rm -rf $IMAGES/latest.image
IMAGE=`cd $IMAGES && ls -t *.image | head -n1`
LOGFILE=/tmp/$IMAGE.log
SESSION_NAME=serialout
screen -S $SESSION_NAME -dm -L -Logfile $LOGFILE $SERIAL_DEV $SERIAL_SPEED

power 'true'
/tmp/tools/push_firmware $IMAGES/$IMAGE -f -ip 192.168.178.1

( tail -f -n0 $LOGFILE & ) | timeout $TIMEOUT grep -q "$WAIT_FOR_CONTENT"
RC=$?
screen -X -S $SESSION_NAME quit
power 'false'

[ "$RC" -eq 0 ] && exit 0
exit 1

