#!/bin/bash
#
# EDM edtCamTop launch script
#
# To use, pass the EPICS PV prefix CAM for the camera as arg 1
#

# Check that requred macros are defined
if [ -z "$1" ]; then
	echo "edmLaunch.sh error: Please provide camera prefix as arg1!"
	exit
fi
CAM=$1

LAUNCH_EDM=$(caget -t -S ${CAM}:LAUNCH_EDM)

${LAUNCH_EDM} &
