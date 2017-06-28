#!/bin/env python
##############################################################################
## This file is part of 'ADStream'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ADStream', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################
# pyca script for python 2.7.2

from psp.Pv import Pv
import pyca
import sys
import psp

from psp.options import Options

showCAErrors		= False
TY_STREAM_DATA		= 0
TY_STREAM_VIEWER	= 1
TY_STREAM_THUMBNAIL	= 2

def printPvNameValue( pvName ):
    try:
        pv = Pv( pvName )
        pv.connect(0.1)
        pv.get()
        if isinstance( pv.value, str ):
            print "%s \"%-.30s\"" % ( pv.name, pv.value )
        else:
            print "%s %-.30s" % ( pv.name, pv.value )
    except pyca.pyexc, msg:
        if showCAErrors:
            print >> sys.stderr, "failed: pyca exception: ", msg
        pass
    except pyca.caexc, msg:
        print >> sys.stderr, "failed: channel access exception: ", msg
    except Exception, msg:
        print >> sys.stderr, "failed:", msg.__class__.__name__, "exception: ", msg

def tupleToString( tupleValue ):
    if isinstance( tupleValue, str ):
        return tupleValue
    # Remove any invalid characters
    for item in tupleValue:
        if item > 255:
            tupleValue.remove(item)

    # Isolate the null terminated string, if any
    if tupleValue.count(0) == 0:
        end = len(tupleValue)
    else:
        end = tupleValue.index(0)

    # Convert remaining bytes to a string
    stringRet = ''.join( map( chr, tupleValue[0:end] ) )
    return stringRet

def stringToTuple( strValue ):
    if not isinstance( strValue, str ):
        raise TypeError, "stringToTuple value is not a string"

    # Convert the string to a bytearray
    newByteArray = bytearray( strValue, 'ascii', 'ignore' )
    return tuple(newByteArray)

def caGetValue( pvName, verbose=True, timeout=0.1 ):
    try:
        # See if this PV exists
        pv	= Pv( pvName )
        pv.connect( timeout )
        pv.get()
        return pv.value
    except Exception, msg:
        if verbose:
            print "Unable to connect to PV: %s" % pvName
        if showCAErrors:
            print >> sys.stderr, "failed: pyca exception: ", msg
        return None


def caPutArray( pvName, value, timeout=-1.0):
    try:
        tmo = float(timeout)
        # See if this PV exists
        pv	= Pv( pvName )
        pv.connect( 1.0 )

        # Convert value to the appropriate type for this PV
        # Assumption is that PV is a waveform record
        if isinstance( value, str ):
            # Convert string values to a tuple
            value = stringToTuple( value )
        if not isinstance( value, tuple ):
            raise TypeError, "Pv.put Error: value not a tuple for waveform PV"
        if len(value) != len(pv.value):
            raise TypeError, "Pv.put Error: Element count mismatch"

        pv.put_data(value, tmo)

    except Exception, msg:
        if verbose:
            print "Unable to connect to PV:", pvName
        if showCAErrors:
            print >> sys.stderr, "failed: pyca exception: ", msg
        return

def caPutValue( pvName, value, verbose=True ):
    try:
        # See if this PV exists
        pv	= Pv( pvName )
        pv.connect( 1.0 )
        pv.put( value, timeout=1.0 )
    except Exception, msg:
        if verbose:
            print "Unable to connect to PV:", pvName
        if showCAErrors:
            print >> sys.stderr, "failed: pyca exception: ", msg
        return

def reconfigStream( cameraPvName, streamName, verbose=False ):
    streamPvName	= cameraPvName + ":" + streamName
    try:
        streamTypePv = Pv( streamPvName + ":StreamType" )
        streamTypePv.connect(0.5)
        streamTypePv.get( timeout=1.0 )
    except Exception, msg:
        if verbose:
            print "Stream %s not found." % streamName
        return

    # Fetch the stream's type and input port
    streamType		= caGetValue( streamPvName + ":StreamType" )
    streamPort		= caGetValue( streamPvName + ":StreamPort" )
    streamNELM		= caGetValue( streamPvName + ":ArrayData.NELM" )
    upStreamPort	= "CAM"
    if streamPort:
        upStreamPort = streamPort

    # Determine the sourcePvName
    if upStreamPort	== "CAM":
        sourcePvName = cameraPvName
        pluginType	= None
    else:
        # This stream's input is another plugin
        sourcePvName	= cameraPvName + ":" + upStreamPort

        # Make sure the plugin they asked for is enabled
        caPutValue( sourcePvName + ":EnableCallbacks", 1 )
        pluginType = caGetValue( sourcePvName + ":PluginType_RBV", verbose=False )

    if pluginType == "NDPluginProcess":
        sourceWidth		= caGetValue( sourcePvName + ":ArraySize0_RBV" )
        sourceHeight	= caGetValue( sourcePvName + ":ArraySize1_RBV" )
    else:
        sourceWidth		= caGetValue( sourcePvName + ":ArraySizeX_RBV" )
        sourceHeight	= caGetValue( sourcePvName + ":ArraySizeY_RBV" )
    sourceColor		= caGetValue( sourcePvName + ":ColorMode_RBV" )
    sourceBits		= caGetValue( sourcePvName + ":BitsPerPixel_RBV" )

    streamWidth		= caGetValue( streamPvName + ":StreamWidth" )
    streamHeight	= caGetValue( streamPvName + ":StreamHeight" )
    streamRate		= caGetValue( streamPvName + ":StreamRate" )
    avgEnabled		= caGetValue( streamPvName + ":Proc:EnableFilter", verbose=False )
    ccEnabled		= False # TODO: caGetValue( streamPvName + ":UseCC" )
    cross1Enabled	= caGetValue( streamPvName + ":Cross1:Use" )
    cross2Enabled	= caGetValue( streamPvName + ":Cross2:Use" )
    cross3Enabled	= caGetValue( streamPvName + ":Cross3:Use" )
    cross4Enabled	= caGetValue( streamPvName + ":Cross4:Use" )
    box1Enabled		= caGetValue( streamPvName + ":Box1:Use" )
    box2Enabled		= caGetValue( streamPvName + ":Box2:Use" )
    box3Enabled		= caGetValue( streamPvName + ":Box3:Use" )
    box4Enabled		= caGetValue( streamPvName + ":Box4:Use" )
    overEnabled     = ( cross1Enabled | cross2Enabled | cross3Enabled | cross4Enabled |
                        box1Enabled   | box2Enabled   | box3Enabled   | box4Enabled   )

    if streamType == TY_STREAM_DATA:
        defCallbackTime = 0.0
        minCallbackTime = 0.0
        defStreamWidth	= sourceWidth
        defStreamHeight = sourceHeight
        maxStreamWidth	= sourceWidth
        maxStreamHeight = sourceHeight
        maxBits			= 16
        monoOnly		= False
    elif streamType == TY_STREAM_THUMBNAIL:
        defCallbackTime = 0.9
        minCallbackTime = 0.2
        defStreamWidth	= 174
        defStreamHeight = 130
        maxStreamWidth	= min( 200, sourceWidth )
        maxStreamHeight = min( 200, sourceHeight )
        maxBits			= 8
        monoOnly		= True
    else: # streamType == TY_STREAM_VIEWER
        defCallbackTime = 0.1
        minCallbackTime = 0.0
        defStreamHeight = 560
        defStreamWidth	= 640
        maxStreamWidth	= min( 1024, sourceWidth )
        maxStreamHeight = min( 1080, sourceHeight )
        maxBits			= 16
        monoOnly		= False

    # Check against streamNELM
    if  maxStreamWidth * maxStreamHeight > streamNELM:
        maxStreamWidth	= int(streamNELM / 2)
        maxStreamHeight = int(streamNELM / 2)

    # Set callbackTime
    callbackTime = defCallbackTime
    if streamRate > 0:
        callbackTime = 1 / streamRate
    if  callbackTime < minCallbackTime:
        callbackTime = minCallbackTime

    # Set streamHeight
    if not streamHeight:
        streamHeight = defStreamHeight
    if  streamHeight > maxStreamHeight:
        streamHeight = maxStreamHeight

    # Set streamWidth
    if not streamWidth:
        if sourceHeight:
            streamWidth = int(sourceWidth * (float(streamHeight) / sourceHeight))
        else:
            streamWidth = defStreamHeight
    if  streamWidth > maxStreamWidth:
        streamWidth = maxStreamWidth

    if verbose:
        print "%s image is %d x %d, target %d x %d" % ( streamPort,
                sourceWidth, sourceHeight, streamWidth, streamHeight )

    binning = 1
    if sourceWidth > streamWidth or sourceHeight > streamHeight:
        xRatio = float(sourceWidth)  / streamWidth
        yRatio = float(sourceHeight) / streamHeight

        # If ratio is between 1.1 and 2.1, bin by 2
        binX = int( round( xRatio + 0.4) )
        binY = int( round( yRatio + 0.4) )
        binning = max( binX, binY )
        if verbose:
            print "Source/Stream width ratio = %f, height ratio = %f, binning %dx%d" % ( xRatio, yRatio, binning, binning )

    # Check for Bayer mode conversion turned off
    if sourceColor == 1: # Bayer
        caPutValue( cameraPvName + ":BayerConvert", 1 ) # RGB1
        
    if ccEnabled or ( monoOnly and sourceColor >= 1 ):
        # Use CC
        caPutValue( streamPvName + ":CC:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":CC:NDArrayPort", upStreamPort )
        ccOut = caGetValue( streamPvName + ":CC:ColorModeOut_RBV" )
        if ccOut == 0:
            sourceBits	 = 8
        upStreamPort = streamName + ":CC"
    else:
        caPutValue( streamPvName + ":CC:EnableCallbacks", 0 )

    if not sourceBits:
        sourceBits = 16
    tgtBits = sourceBits
    if  tgtBits > maxBits:
        tgtBits = maxBits

    if binning > 1 or tgtBits < sourceBits:
        # Use ROI
        caPutValue( streamPvName + ":ROI:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":ROI:NDArrayPort", upStreamPort )
        caPutValue( streamPvName + ":ROI:EnableX", 1 )
        caPutValue( streamPvName + ":ROI:EnableY", 1 )
        caPutValue( streamPvName + ":ROI:BinX", binning )
        caPutValue( streamPvName + ":ROI:BinY", binning )
        caPutValue( streamPvName + ":ROI:EnableScale", 1 )
        if  tgtBits == 8:
            caPutValue( streamPvName + ":ROI:DataTypeOut", "UInt8" )
        else:
            caPutValue( streamPvName + ":ROI:DataTypeOut", "Automatic" )

        scale = binning * binning
        if sourceBits > tgtBits:
            scale = scale * ( 2 ** (sourceBits - tgtBits) )
        if verbose:
            print "sourceBits = %d, tgtBits = %d, scale = %d" % ( sourceBits, tgtBits, scale )
        caPutValue( streamPvName + ":ROI:Scale", scale )
        upStreamPort = streamName + ":ROI"
    else:
        caPutValue( streamPvName + ":ROI:EnableCallbacks", 0 )
        caPutValue( streamPvName + ":ROI:BinX", 1 )
        caPutValue( streamPvName + ":ROI:BinY", 1 )

    avgNum = 1
    if avgEnabled:
        # Use Recursive Averaging Filter in Process plugin
        avgNum		= caGetValue( streamPvName + ":Proc:NumFilter" )
    if avgNum > 1:
        caPutValue( streamPvName + ":Proc:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":Proc:NDArrayPort", upStreamPort )
        upStreamPort = streamName + ":Proc"
    else:
        caPutValue( streamPvName + ":Proc:EnableCallbacks", 0 )

    if overEnabled:
        # Use Overlays
        caPutValue( streamPvName + ":Over:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":Over:NDArrayPort", upStreamPort )
        upStreamPort = streamName + ":Over"
    else:
        caPutValue( streamPvName + ":Over:EnableCallbacks", 0 )

    # Make sure we don't have zero size for ROI and crosses
    if  caGetValue( cameraPvName + ":ROI1:SizeX_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI1:SizeX", 10 )
    if  caGetValue( cameraPvName + ":ROI1:SizeY_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI1:SizeY", 10 )
    if  caGetValue( cameraPvName + ":ROI2:SizeX_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI2:SizeX", 10 )
    if  caGetValue( cameraPvName + ":ROI2:SizeY_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI2:SizeY", 10 )
    if  caGetValue( cameraPvName + ":ROI3:SizeX_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI3:SizeX", 10 )
    if  caGetValue( cameraPvName + ":ROI3:SizeY_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI3:SizeY", 10 )
    if  caGetValue( cameraPvName + ":ROI4:SizeX_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI4:SizeX", 10 )
    if  caGetValue( cameraPvName + ":ROI4:SizeY_RBV" ) == 0:
        caPutValue( cameraPvName + ":ROI4:SizeY", 10 )
    if  caGetValue( cameraPvName + ":Cross1SizeX" ) == 0:
        caPutValue( cameraPvName + ":Cross1SizeX", 10 )
    if  caGetValue( cameraPvName + ":Cross1SizeY" ) == 0:
        caPutValue( cameraPvName + ":Cross1SizeY", 10 )
    if  caGetValue( cameraPvName + ":Cross2SizeX" ) == 0:
        caPutValue( cameraPvName + ":Cross2SizeX", 10 )
    if  caGetValue( cameraPvName + ":Cross2SizeY" ) == 0:
        caPutValue( cameraPvName + ":Cross2SizeY", 10 )
    if  caGetValue( cameraPvName + ":Cross3SizeX" ) == 0:
        caPutValue( cameraPvName + ":Cross3SizeX", 10 )
    if  caGetValue( cameraPvName + ":Cross3SizeY" ) == 0:
        caPutValue( cameraPvName + ":Cross3SizeY", 10 )
    if  caGetValue( cameraPvName + ":Cross4SizeX" ) == 0:
        caPutValue( cameraPvName + ":Cross4SizeX", 10 )
    if  caGetValue( cameraPvName + ":Cross4SizeY" ) == 0:
        caPutValue( cameraPvName + ":Cross4SizeY", 10 )

    caPutValue( streamPvName + ":EnableCallbacks", 1 )
    caPutValue( streamPvName + ":NDArrayPort",			upStreamPort )
    caPutValue( streamPvName + ":MinCallbackTime",		callbackTime )
    caPutValue( streamPvName + ":CC:MinCallbackTime",	callbackTime )
    caPutValue( streamPvName + ":ROI:MinCallbackTime",	callbackTime )
    caPutValue( streamPvName + ":Over:MinCallbackTime",	callbackTime )

# ----------------------------------------------------------------------
if __name__ == "__main__":

    options = Options( ['cameraPv', 'stream'], [], ['verbose'] )
    try:
        options.parse()
    except Exception, msg:
        options.usage( str(msg) )
        sys.exit()

    cameraPvName = options.cameraPv
    streamName	 = options.stream
    try:
        camSizeXPv = Pv( cameraPvName + ":ArraySizeX_RBV" )
        camSizeXPv.connect(0.1)
        camSizeXPv.get( timeout=1.0 )
    except Exception, msg:
        print "Camera not accessible: ", msg
        sys.exit()

    verbose = False
    if options.verbose is not None:
        verbose = True
    if streamName != 'all':
        reconfigStream( cameraPvName, streamName, verbose=verbose )
    else:
        showCAErrors = False
        reconfigStream( cameraPvName, "DATA1",		verbose=verbose )
        reconfigStream( cameraPvName, "IMAGE1",		verbose=verbose )
        reconfigStream( cameraPvName, "IMAGE2",		verbose=verbose )
        reconfigStream( cameraPvName, "THUMBNAIL",	verbose=verbose )
        reconfigStream( cameraPvName, "DATA2",		verbose=verbose )
        reconfigStream( cameraPvName, "IMAGE3",		verbose=verbose )

    # Done
