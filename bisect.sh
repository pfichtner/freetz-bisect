#!/bin/sh

WAIT_FOR_CONTENT='System Init'
TIMEOUT=60
SERIAL_DEV=/dev/ttyUSB0
SERIAL_SPEED=38400
IMAGES=images

power() {
   echo ">>> Switching outlet $1"
   mosquitto_pub -h mqtt -t 'cmnd/tasmota-6205/POWER1' -m "$1"
}

push_firmware() {
   echo ">>> Uploading $1"
   /tmp/tools/push_firmware $1 -f -ip 192.168.178.1
}

verify_firmware() {
   echo ">>> Waiting for \"$WAIT_FOR_CONTENT\" for $TIMEOUT seconds"
   ( tail -f -n0 $LOGFILE | tee /dev/tty & ) | timeout $TIMEOUT grep -q "$WAIT_FOR_CONTENT"
   return $?
}

rm -rf $IMAGES/*
yes "" | make oldconfig
make

rm -rf $IMAGES/latest.image
IMAGE=`cd $IMAGES && ls -t *.image | head -n1`
LOGFILE=/tmp/$IMAGE.log
SESSION_NAME=serialout-$$

touch $LOGFILE
screen -S $SESSION_NAME -dm -L -Logfile $LOGFILE $SERIAL_DEV $SERIAL_SPEED
power 'true'
push_firmware $IMAGES/$IMAGE
verify_firmware
VERIFY_RC=$?
echo ">>> verify rc: $VERIFY_RC"
screen -X -S $SESSION_NAME quit
power 'false'

[ "$VERIFY_RC" -eq 0 ] && exit 0 || exit 1

