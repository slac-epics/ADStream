#! /bin/bash
PRE=$1
if [ -z "$PRE" ]; then
	echo Usage: $0 PV:STREAM:PREFIX
	exit 1
fi

# Setup the common directory env variables
if [ -e ${CONFIG_SITE_TOP}/common_dirs.sh ]; then
	source ${CONFIG_SITE_TOP}/common_dirs.sh
if [ -e /reg/g/pcds/pyps/config/common_dirs.sh ]; then
	source /reg/g/pcds/pyps/config/common_dirs.sh
else
	source /afs/slac/g/pcds/config/common_dirs.sh
fi

# Setup pyca environment
export PSPKG_RELEASE=controls-basic-0.0.2
source $PSPKG_ROOT/etc/set_env.sh

python ADStreams/resetStream.sh --stream $PRE
