#!/bin/sh
if [ -z "$CONFIG_SITE_TOP" ]; then
	if [ -d /reg/g/pcds/pyps/config ]; then
		CONFIG_SITE_TOP=/reg/g/pcds/pyps/config 
	else
		CONFIG_SITE_TOP=/afs/slac/g/pcds/config 
	fi
fi
echo Entry: $0 $*
HUTCH=`awk '{print tolower($0)}' <<< $1`
#Note that $HUTCH should be lowercase for this script!

shift
echo Running: $0 $*
$CONFIG_SITE_TOP/$HUTCH/camviewer/run_viewer.csh --instrument ${HUTCH} --pvlist $CONFIG_SITE_TOP/${HUTCH}/camviewer.cfg --rate 5 $*
