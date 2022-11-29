#!/bin/bash
# edmViewer.sh
# EDM Camera Viewer launch script
# Creates and launches a custom edm viewer based on image characteristics
#
# To use, define the following environment variables
#   HUTCH   Ex: sys0, amo, sxr, xpp, ...
#   IOC	    EPICS PV prefix for iocAdmin PV's
#   CH	    Channel # for camera trigger
#   P 	    Prefix for Camera PV's
#   R 	    Region for Camera PV's
#			Full camera PV prefix: $(P)$(R)
#	IMAGE	Image name
#			Full image PV prefix: $(P)$(R)$(IMAGE)
#	EDM_TOP Path to edm top level camera screen
#	Optional PVs depending on if you have an EVR or TPR
#   EVR	    EPICS PV prefix for EVR PV's
#   TPR_PV  EPICS PV prefix for TPR master PV's
#   TPS_PV  EPICS PV prefix for TPR slave  PV's
# Example:
# IOC=$IOC P=$P R=$R IMAGE=$IMAGE HUTCH=$HUTCH EDM_TOP=$EDM_TOP EVR=$EVR CH=$CH ADStreamScreens/edmViewer.sh

# Check that requred macros are defined
if [ -z "$P" -o -z "$R" ]; then
	echo "Please define P and R macro\'s for camera prefix!"
	echo "Full prefix is \$(P)\$(R)"
	exit
fi
if [ -z "$IMAGE" ]; then
	echo "Please define IMAGE macro!"
	echo "Typical IMAGE: IMAGE, IMAGE1, IMAGE2, ..."
	exit
fi

# TODO: Can we get these from a PV?
# IOC=$(caget -t -S ${P}${R}IOC_PV)
# EVR=$(caget -t -S ${P}${R}EVR_PV)
# TPR_PV=$(caget -t -S ${P}${R}TPR_PV)
# TPS_PV=$(caget -t -S ${P}${R}TPS_PV)
# CH=$(caget -t -S ${P}${R}TRIG_CH)
# EDM_TOP=$(caget -t -S ${P}${R}EDM_TOP)
# HUTCH=$(caget -t -S ${P}${R}HUTCH)

# Providing defaults for these macros
if [ -z "$EVR" ]; then
	EVR=EVR_None
fi
if [ -z "$TPR_PV" ]; then
	TPR_PV=TPR_None
fi
if [ -z "$TPS_PV" ]; then
	TPS_PV=TPR_None
fi
if [ -z "$HUTCH" ]; then
	HUTCH=tst
fi
# Find the directory w/ edm screen soft links
SCREEN_LINKS=.
if [ -z "$IOC" ]; then
	IOC=IOC_None
else
	APP_DIR=$(caget -t -S ${IOC}:APP_DIR)
	if [ -z "$APP_DIR" ]; then
		APP_DIR=$(caget -t -S ${IOC}:APP_DIR1)
		APP_DIR=${APP_DIR}$(caget -t -S ${IOC}:APP_DIR2)
	fi
	SCREEN_LINKS=${APP_DIR}/screenLinks
fi
if [ -z "$CH" ]; then
	CH=999
fi

if [ -z "$EDM_TOP" ]; then
	# Default to gige
	EDM_TOP=${SCREEN_LINKS}/gigeScreens/gigeTop.edl
	if [ ! -f $EDM_TOP ]; then
		echo Nonexistent EDM_TOP: $EDM_TOP
		echo Please set EDM_TOP env variable to viable edm screen.
	fi
fi

# Make sure edm is setup
if [ ! -e "$(which edm 2> /dev/null)" -o -z "$EDMOBJECTS" ]; then
	if [ -z "$SETUP_SITE_TOP" ]; then
		if [ -d /reg/g/pcds/setup ]; then
			SETUP_SITE_TOP=/reg/g/pcds/setup
		fi
	fi
	if [ -f $SETUP_SITE_TOP/epicsenv-cur.sh ]; then
		# Setup PCDS edm environment
		source $SETUP_SITE_TOP/epicsenv-cur.sh
	fi
fi
if [ ! -e "$(which edm 2> /dev/null)" -o -z "$EDMOBJECTS" ]; then
	if [ -f ${TOOLS}/script/ENVS.bash ]; then
		# Setup LCLS edm environment
		source ${TOOLS}/script/ENVS.bash 
	fi
fi

echo Creating custom edm viewer for ${P}${R}${IMAGE} ...
set verbose

# Fetch image parameters
IMG_SIZE_X=`caget -t -f0 ${P}${R}${IMAGE}:ArraySize0_RBV`
IMG_SIZE_Y=`caget -t -f0 ${P}${R}${IMAGE}:ArraySize1_RBV`
IMG_N_BITS=`caget -t -f0 ${P}${R}${IMAGE}:BitsPerPixel_RBV`
# Enforce some reasonable minimums
if [ ${IMG_SIZE_X} -lt 400 ]; then
	IMG_SIZE_X=400
fi
if [ ${IMG_SIZE_Y} -lt 400 ]; then
	IMG_SIZE_Y=400
fi
if [ ${IMG_N_BITS} -lt 2 ]; then
	IMG_N_BITS=2
fi

# Contstants derived from widget positions and sizes in template files
if [ ${IMG_SIZE_Y} -gt 500 ]; then
	TEMPLATE=landscapeViewerTemplate.edl
	V_MIN_WIDTH=840
	V_MIN_HEIGHT=552
	V_IMG_X=212
	V_IMG_Y=48
else
	TEMPLATE=wideViewerTemplate.edl
	V_MIN_WIDTH=928
	V_MIN_HEIGHT=180
	V_IMG_X=4
	V_IMG_Y=180
fi

# Compute viewer width and height
V_WIDTH=$((  ${V_IMG_X} + ${IMG_SIZE_X} + 4 ))
V_HEIGHT=$(( ${V_IMG_Y} + ${IMG_SIZE_Y} + 4 ))

# Check against minimums
V_WIDTH=$((  ${V_MIN_WIDTH}  > ${V_WIDTH}  ? ${V_MIN_WIDTH}  : ${V_WIDTH}  ))
V_HEIGHT=$(( ${V_MIN_HEIGHT} > ${V_HEIGHT} ? ${V_MIN_HEIGHT} : ${V_HEIGHT} ))
# echo Viewer: ${IMG_SIZE_X}x${IMG_SIZE_Y} Image, ${V_WIDTH}x${V_HEIGHT} Viewer

# Create name for custom viewer in /tmp
VIEWER=/tmp/${IMG_SIZE_X}x${IMG_SIZE_Y}x${IMG_N_BITS}Viewer_$$.edl
/bin/rm -f ${VIEWER}

# Create a custom viewer in /tmp
cat	ADStreamScreens/${TEMPLATE} | sed \
	-e "s/^w 999/w ${V_WIDTH}/"	\
	-e "s/^h 999/h ${V_HEIGHT}/"	\
	-e "s/^w 699/w ${IMG_SIZE_X}/"	\
	-e "s/^h 699/h ${IMG_SIZE_Y}/"	\
	-e "s/^nBitsPerPixel 8/nBitsPerPixel ${IMG_N_BITS}/"	\
	> ${VIEWER}

# Make custom viewer writable by everyone to avoid permission issues
chmod a+w ${VIEWER}

# Launch custom viewer
echo Launching custom viewer: ${VIEWER}
edm -x -eolc						\
	-m "IOC=${IOC}"					\
	-m "P=${P},R=${R}"				\
	-m "CAM=${P}"					\
	-m "EVR=${EVR}"					\
	-m "TPR_PV=${TPR_PV}"			\
	-m "TPS_PV=${TPS_PV}"			\
	-m "CH=${CH}"					\
	-m "HUTCH=${HUTCH}"				\
	-m "IMAGE=${IMAGE}"				\
	-m "EDM_TOP=${EDM_TOP}"			\
	-m "IMG_SIZE_X=${IMG_SIZE_X}"	\
	-m "IMG_SIZE_Y=${IMG_SIZE_Y}"	\
	-m "IMG_N_BITS=${IMG_N_BITS}"	\
	-m "ORIG=${VIEWER}"				\
	${VIEWER}

/bin/rm -f ${VIEWER}
