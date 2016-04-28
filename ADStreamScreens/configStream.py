#!/bin/env python
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

def caGetValue( pvName, verbose=True ):
    try:
        # See if this PV exists
        pv	= Pv( pvName )
        pv.connect(0.1)
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

def reconfigDataStream( cameraPvName, streamName, verbose=False ):
    streamPvName = cameraPvName + ":" + streamName
    caPutValue( streamPvName + ":NDArrayPort", "CAM" )
    caPutValue( streamPvName + ":MinCallbackTime", 0.0 )
    caPutValue( streamPvName + ":EnableCallbacks", 1 )
    caPutValue( streamPvName + ":CC:EnableCallbacks", 0 )
    caPutValue( streamPvName + ":ROI:EnableCallbacks", 0 )
    caPutValue( streamPvName + ":Over:EnableCallbacks", 0 )

def reconfigThumbnailStream( cameraPvName, streamName, verbose=False ):
    streamPvName = cameraPvName + ":" + streamName
    imageWidth	= caGetValue( cameraPvName + ":ArraySizeX_RBV" )
    imageHeight	= caGetValue( cameraPvName + ":ArraySizeY_RBV" )
    imageColor	= caGetValue( cameraPvName + ":ColorMode_RBV" )
    imageBits	= caGetValue( cameraPvName + ":BitsPerPixel_RBV" )
    streamWidth	= caGetValue( streamPvName + ":StreamWidth" )
    streamHeight= caGetValue( streamPvName + ":StreamHeight" )
    streamRate	= caGetValue( streamPvName + ":StreamRate" )
    ccEnabled	= caGetValue( streamPvName + ":CC:EnableCallbacks" )
    overEnabled	= caGetValue( streamPvName + ":Over:EnableCallbacks" )

    if not imageBits:
        imageBits = 16
    tgtBits = imageBits

    minCallbackTime = 0.9
    if streamRate > 0:
        minCallbackTime = 1 / streamRate
    if not streamHeight:
        streamHeight = 174
    if not streamWidth:
        if imageHeight:
            streamWidth = int(imageWidth * (float(streamHeight) / imageHeight))
        else:
            streamWidth = 130
    if verbose:
        print "Image is %d x %d, Thumbnail target %d x %d" % ( imageWidth, imageHeight, streamWidth, streamHeight )

    binning = 1
    if imageWidth > streamWidth or imageHeight > streamHeight:
        xRatio = float(imageWidth)  / streamWidth
        yRatio = float(imageHeight) / streamHeight

        # If ratio is between 1.1 and 2.1, bin by 2
        binX = int( round( xRatio + 0.4) )
        binY = int( round( yRatio + 0.4) )
        binning = max( binX, binY )
        if verbose:
            print "Image/Stream width ratio = %f, height ratio = %f, binning %dx%d" % ( xRatio, yRatio, binning, binning )

    upStreamPort	= "CAM"
    if imageColor >= 1 or ccEnabled:
        # Use CC
        caPutValue( streamPvName + ":CC:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":CC:NDArrayPort", upStreamPort )
        caPutValue( streamPvName + ":CC:ColorModeOut", "Mono" )
        upStreamPort = streamName + ":CC"
    else:
        caPutValue( streamPvName + ":CC:EnableCallbacks", 0 )

    if binning > 1:
        # Use ROI
        caPutValue( streamPvName + ":ROI:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":ROI:NDArrayPort", upStreamPort )
        caPutValue( streamPvName + ":ROI:EnableX", 1 )
        caPutValue( streamPvName + ":ROI:EnableY", 1 )
        caPutValue( streamPvName + ":ROI:BinX", binning )
        caPutValue( streamPvName + ":ROI:BinY", binning )
        caPutValue( streamPvName + ":ROI:EnableScale", 1 )
        caPutValue( streamPvName + ":ROI:DataTypeOut", "UInt8" )
        tgtBits	 = 8
        scale = binning * binning
        if imageBits > tgtBits:
            scale = scale * ( 2 ** (imageBits - tgtBits) )
        if verbose:
            print "imageBits = %d, tgtBits = %d, scale = %d" % ( imageBits, tgtBits, scale )
        caPutValue( streamPvName + ":ROI:Scale", scale )
        upStreamPort = streamName + ":ROI"
    else:
        caPutValue( streamPvName + ":ROI:EnableCallbacks", 0 )

    if overEnabled:
        # Use Overlays
        caPutValue( streamPvName + ":Over:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":Over:NDArrayPort", upStreamPort )
        upStreamPort = streamName + ":Over"
    else:
        caPutValue( streamPvName + ":Over:EnableCallbacks", 0 )

    caPutValue( streamPvName + ":EnableCallbacks", 1 )
    caPutValue( streamPvName + ":NDArrayPort", upStreamPort )
    caPutValue( streamPvName + ":MinCallbackTime", minCallbackTime )
    caPutValue( streamPvName + ":CC:MinCallbackTime", minCallbackTime )
    caPutValue( streamPvName + ":ROI:MinCallbackTime", minCallbackTime )
    caPutValue( streamPvName + ":Over:MinCallbackTime", minCallbackTime )

def reconfigViewerStream( cameraPvName, streamName, verbose=False ):
    streamPvName = cameraPvName + ":" + streamName
    imageWidth	= caGetValue( cameraPvName + ":ArraySizeX_RBV" )
    imageHeight	= caGetValue( cameraPvName + ":ArraySizeY_RBV" )
    imageColor	= caGetValue( cameraPvName + ":ColorMode_RBV" )
    imageBits	= caGetValue( cameraPvName + ":BitsPerPixel_RBV" )
    streamWidth	= caGetValue( streamPvName + ":StreamWidth" )
    streamHeight= caGetValue( streamPvName + ":StreamHeight" )
    streamRate	= caGetValue( streamPvName + ":StreamRate" )
    ccEnabled	= caGetValue( streamPvName + ":CC:EnableCallbacks" )
    overEnabled	= caGetValue( streamPvName + ":Over:EnableCallbacks" )

    if not imageBits:
        imageBits = 16
    tgtBits = imageBits

    minCallbackTime = 0.1
    if streamRate > 0:
        minCallbackTime = 1 / streamRate
    if not streamHeight:
        streamHeight = 640
    if not streamWidth:
        if imageHeight:
            streamWidth = int(imageWidth * (float(streamHeight) / imageHeight))
        else:
            streamWidth = 560
    if verbose:
        print "Image is %d x %d, Viewer target %d x %d" % ( imageWidth, imageHeight, streamWidth, streamHeight )

    binning = 1
    if imageWidth > streamWidth or imageHeight > streamHeight:
        xRatio = float(imageWidth)  / streamWidth
        yRatio = float(imageHeight) / streamHeight

        # If ratio is between 1.1 and 2.1, bin by 2
        binX = int( round( xRatio + 0.4) )
        binY = int( round( yRatio + 0.4) )
        binning = max( binX, binY )
        if verbose:
            print "Image/Stream width ratio = %f, height ratio = %f, binning %dx%d" % ( xRatio, yRatio, binning, binning )

    upStreamPort	= "CAM"
    if ccEnabled:
        # Use CC
        caPutValue( streamPvName + ":CC:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":CC:NDArrayPort", upStreamPort )
        ccOut = caGetValue( streamPvName + ":CC:ColorModeOut_RBV" )
        if ccOut == 0:
            imageBits	 = 8
        upStreamPort = streamName + ":CC"
    else:
        caPutValue( streamPvName + ":CC:EnableCallbacks", 0 )

    if binning > 1:
        # Use ROI
        caPutValue( streamPvName + ":ROI:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":ROI:NDArrayPort", upStreamPort )
        caPutValue( streamPvName + ":ROI:EnableX", 1 )
        caPutValue( streamPvName + ":ROI:EnableY", 1 )
        caPutValue( streamPvName + ":ROI:BinX", binning )
        caPutValue( streamPvName + ":ROI:BinY", binning )
        caPutValue( streamPvName + ":ROI:EnableScale", 1 )
        roiDataType = caGetValue( streamPvName + ":ROI:DataTypeOut" )
        if roiDataType < 2:
            tgtBits	 = 8
        scale = binning * binning
        if imageBits > tgtBits:
            scale = scale * ( 2 ** (imageBits - tgtBits) )
        if verbose:
            print "imageBits = %d, tgtBits = %d, scale = %d" % ( imageBits, tgtBits, scale )
        caPutValue( streamPvName + ":ROI:Scale", scale )
        caPutValue( streamPvName + ":ROI:DataTypeOut", "Automatic" )
        upStreamPort = streamName + ":ROI"
    else:
        caPutValue( streamPvName + ":ROI:EnableCallbacks", 0 )

    if overEnabled:
        # Use Overlays
        caPutValue( streamPvName + ":Over:EnableCallbacks", 1 )
        caPutValue( streamPvName + ":Over:NDArrayPort", upStreamPort )
        upStreamPort = streamName + ":Over"
    else:
        caPutValue( streamPvName + ":Over:EnableCallbacks", 0 )

    caPutValue( streamPvName + ":EnableCallbacks", 1 )
    caPutValue( streamPvName + ":NDArrayPort", upStreamPort )
    caPutValue( streamPvName + ":MinCallbackTime", minCallbackTime )
    caPutValue( streamPvName + ":CC:MinCallbackTime", minCallbackTime )
    caPutValue( streamPvName + ":ROI:MinCallbackTime", minCallbackTime )
    caPutValue( streamPvName + ":Over:MinCallbackTime", minCallbackTime )

def reconfigStream( cameraPvName, streamName, verbose=False ):
    streamPvName = cameraPvName + ":" + streamName
    streamType	= caGetValue( streamPvName + ":StreamType" )
    if streamType is None:
        print "Unable to reconfigure stream %s" % ( streamPvName )
        return
    if verbose:
        print "StreamType = %s" % streamType
    if streamType == TY_STREAM_DATA:
        reconfigDataStream( cameraPvName, streamName, verbose=verbose )
    elif streamType == TY_STREAM_THUMBNAIL:
        reconfigThumbnailStream( cameraPvName, streamName, verbose=verbose )
    else:
        reconfigViewerStream( cameraPvName, streamName, verbose=verbose )
    return

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
        imageSizeXPv = Pv( cameraPvName + ":ArraySizeX_RBV" )
        imageSizeXPv.connect(0.1)
        imageSizeXPv.get( timeout=1.0 )
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
