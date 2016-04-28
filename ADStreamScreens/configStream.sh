#! /bin/bash
CAM_PV=$1
IMAGE=$2
if [ -z "$CAM_PV" -o -z "$IMAGE" ]; then
	echo Usage:   $0 CAMERA_PV_PREFIX IMAGE_NAME
	echo Example: $0 TST:GIGE:OPAL1 IMAGE2
	exit 1
fi

# Setup the common directory env variables
if [ -e ${CONFIG_SITE_TOP}/common_dirs.sh ]; then
	source ${CONFIG_SITE_TOP}/common_dirs.sh
elif [ -e /reg/g/pcds/pyps/config/common_dirs.sh ]; then
	source /reg/g/pcds/pyps/config/common_dirs.sh
else
	source /afs/slac/g/pcds/config/common_dirs.sh
fi

# Setup pyca environment
export PSPKG_RELEASE=controls-basic-0.0.2
source $PSPKG_ROOT/etc/set_env.sh

python ADStreamScreens/configStream.py --cameraPv $CAM_PV --stream $IMAGE

