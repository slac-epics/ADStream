#!/bin/sh
if [ -z "$CONFIG_SITE_TOP" ]; then
	if [ -d /reg/g/pcds/pyps/config ]; then
		CONFIG_SITE_TOP=/reg/g/pcds/pyps/config 
	else
		CONFIG_SITE_TOP=/afs/slac/g/pcds/config 
	fi
fi
echo Entry: $0 $*
HUTCH=$1
shift
echo Running: $0 $*
$CONFIG_SITE_TOP/$HUTCH/camviewer/run_viewer.csh --instrument ${HUTCH} --pvlist $CONFIG_SITE_TOP/${HUTCH}/camviewer.cfg --rate 5 $*
