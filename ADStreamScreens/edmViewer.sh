#!/bin/bash
#
# EDM Viewer launch script
#
# To use, define the following environment variables
#   HUTCH   Ex: amo, sxr, xpp, ...
#   IOC	    EPICS PV prefix for iocAdmin PV's
#   EVR	    EPICS PV prefix for EVR PV's
#   CH	    Channel # for EVR camera trigger
#   P 	    Prefix for Camera PV's
#   R 	    Region for Camera PV's
#			Full camera PV prefix: $(P)$(R)
#	IMAGE	Image name
#			Full image PV prefix: $(P)$(R)$(IMAGE)
#	EDM_TOP Path to edm top level camera screen
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
if [ -z "$EDM_TOP" ]; then
	echo "Please define EDM_TOP macro!"
	# Default to gige
	EDM_TOP=gigeScreens/gigeTop.edl
fi

# Providing defaults for these macros
if [ -z "$EVR" ]; then
	EVR=EVR_None
fi
if [ -z "$HUTCH" ]; then
	HUTCH=tst
fi
if [ -z "$IOC" ]; then
	IOC=IOC_None
fi
if [ -z "$CH" ]; then
	CH=999
fi

# Check for edm
which edm > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
	# Setup edm environment
	source $SETUP_SITE_TOP/epicsenv-cur.sh
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
