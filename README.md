# ADStream module
ADStream makes it easy to configure an areaDetector camera IOC for one or more image
streams, each of which has it's own dedicated stdArray, ROI, CC, Overlay, and Process
plugin, along w/ some extra PV's to characterize the stream type, input source, height,
width, and desired update rate.

You can also do image averaging, and view and adjust 4 crosses and 4 ROI overlay boxes.
The overlays have calc records to handle binning differences between streams.
A python script is used to reconfigure each stream's plugin chain as needed to produce the desired result.

ADStream currently assumes one camera per IOC, w/ camera PORT named CAM, and commonPlugins loaded
to provide other stream input sources.

Stream types include:
* DataStream: Full rate, full res
* ViewingStream: Defaults to 10hz, (configurable), 640x560 target dimensions (configurable), subject to bandwidth limits
* ThumbnailStream: Always B/W,  8 bit pixels, 174x130 target dimensions, default 1hz rate

Stream PV's:
The STREAM prefix for stream PV's is $(CAM):$(IMAGE)
PV example: CAMR:FEE1:1692:IMAGE1:StreamType
* $(STREAM):StreamType	 - Enum: Data, Viewer, or Thumbnail
* $(STREAM):StreamInput	 - Enum: CAM,ROI1,ROI2,ROI3,ROI4,Proc1,Trans1,CC1,CC2
* $(STREAM):StreamHeight - Longout: Desired image height in pixels, 0 to default based on StreamType and StreamInput
* $(STREAM):StreamWidth  - Longout: Desired image width  in pixels, 0 to default based on StreamType and StreamInput
* $(STREAM):StreamRate   - Float: Desired image rate in hz, 0 to default based on StreamType and StreamInput

To enable/disable cross and ROI box overlays:
* $(STREAM):Cross1Use	- Enum: No or Yes
* $(STREAM):Cross2Use	- Enum: No or Yes
* $(STREAM):Cross3Use	- Enum: No or Yes
* $(STREAM):Cross4Use	- Enum: No or Yes
* $(STREAM):Box1Use	    - Enum: No or Yes
* $(STREAM):Box2Use	    - Enum: No or Yes
* $(STREAM):Box3Use	    - Enum: No or Yes
* $(STREAM):Box4Use	    - Enum: No or Yes

Some limited Image processing can be enabled for each stream.
* $(STREAM):Proc:EnableBackground - Enum: Disable or Enable background subtraction
* $(STREAM):Proc:SaveBackground   - Enum: No or Yes, toggle on/off to save a new background image
* $(STREAM):Proc:EnableFilter     - Enum: Disable or Enable image averaging
* $(STREAM):Proc:NumFilter        - Number of images to average

To reconfigure the stream plugins for current StreamInput and other stream PV settings, run the python script:
ADStreamScreens/configStream.py  CameraPVPrefix  ImageName
Ex. ADStreamScreens/configStream.py CAMR:FEE1:1692  IMAGE1

The configStream.py script will automatically insert a color correction plugin if needed,
followed by an ROI plugin if needed to do any binning.
If Image processing is enabled, the Proc plugin comes next.
Then if any crosses or boxes are enabled, the Overlay plugin.
Finally, a stdArray plugin is used to provide the output image.
If no additional plugins are needed, stdArray could get it's input directly from the camera.

Coordinates for the 4 ROI boxes assume you're using the 4 ROI plugins from common plugins, each using CAM as their NDArrayPort.
* $(CAM):ROI1:MinX
* $(CAM):ROI1:MinY
* $(CAM):ROI1:SizeX
* $(CAM):ROI1:SizeY
* $(CAM):ROI2:MinX
...
* $(CAM):ROI4:SizeY

To load a set of 4 cross PV's for your camera, use dbLoadRecords( db/cross.db, CAM=$(CAM) )
* $(CAM):Cross1MinX
* $(CAM):Cross1MinY
* $(CAM):Cross1SizeX
* $(CAM):Cross1SizeY
* $(CAM):Cross2MinX
...
* $(CAM):Cross4SizeY

HW vs SW ROI and Binning:
ADCore supports many ways to handle ROI and binning.
Here is how ADStream does ROI and binning for each stream.
1.  HW ROI and binning
	These PV's are not supported by all drivers, but when available can increase
	frame rates and reduce resource consumption for all plugins.
	$(CAM):BinX		- Camera and/or driver X binning factor
	$(CAM):BinY		- Camera and/or driver Y binning factor
	$(CAM):MinX		- Camera and/or driver X ROI start
	$(CAM):MinY		- Camera and/or driver Y ROI start
	$(CAM):SizeX	- Camera and/or driver X ROI size
	$(CAM):SizeY	- Camera and/or driver Y ROI size
	Each of these has an _RBV equivalent which the driver sets to the
	actual HW ROI and/or binning.
	i.e.  You may Set $(CAM):BinX to 5, but if the camera/driver doesn't
	support that, $(CAM):BinX_RBV may be 1

2.  Software ROI
	ADStream uses the 4 ROI plugins from common plugins to select 4 ROI regions using
	camera pixel coordinates after any HW ROI or binning have been applied.
	$(CAM):ROI1:MinX	- Software ROI1 X start
	$(CAM):ROI1:MinY	- Software ROI1 Y start
	$(CAM):ROI1:SizeX	- Software ROI1 X size
	$(CAM):ROI1:SizeY	- Software ROI1 Y size
	$(CAM):ROI2:MinX	- Software ROI2 X start
	...
	$(CAM):ROI4:SizeY	- Software ROI4 Y size
	Again each has an _RBV equivalent which the plugin sets to the actual readback value.
	ADStream doesn't use the binning available via these 4 ROI plugins from commonPlugins.

3.  Software binning
	ADStream allows each stream to do it's own binning
	$(STREAM):ROI:BinX	- Set by configStream.py based on StreamInput and StreamType
	$(STREAM):ROI:BinY	- Set by configStream.py based on StreamInput and StreamType
	$(STREAM):ROI:MinX	- Set by configStream.py based on StreamInput and stream binning
	$(STREAM):ROI:MinY	- Set by configStream.py based on StreamInput and stream binning
	$(STREAM):ROI:SizeX	- Set by configStream.py based on StreamInput and stream binning
	$(STREAM):ROI:SizeY	- Set by configStream.py based on StreamInput and stream binning
	Again each has an _RBV equivalent which the plugin sets to the actual readback value.
	These values can be set manually as well, but may get stepped on the next time
	configStream.py runs.

As is normal for ADCore, the image width and height for every ArrayData waveform produced
by StdArray plugins are directly available via these PV's:
	$(STREAM):ArraySize0_RBV
	$(STREAM):ArraySize1_RBV
For color RGB images, ArraySize0_RBV will be 3 and the image width and height are in
ArraySize1_RBV and ArraySize2_RBV respectively.


Building ADStream:

ADStream depends on ADCore, so you'll need to define the path to your ADCore release in
configure/RELEASE or configure/RELEASE.local.
ADStream has been tested w/ ADCore versions R2.0, R2.1, and R2.6
but should work w/ newer versions as well.

## Files built in db directory
ADStream populates the db directory w/ a combination of db files and cmd files.
The cmd files are iocsh scripts to facilitate loading the appropriate db file or files and configuring any
plugins which it loads.  Epics env variables are used to configure PV names and characteristics
for the plugins, and the required ENV variables are documented in each cmd file.

The db files are produced via substitution files, so each ADCore plugin type has a db file and a cmd file.

There are also cmd scripts and db files for each type of stream.

To use in an IOC, define the ADSTREAM macro in one of your RELEASE files and add the following lines
in your App/Db/Makefile:
```
DB_INSTALLS += $(wildcard $(ADSTREAM)/db/*.cmd)
DB_INSTALLS += $(wildcard $(ADSTREAM)/db/*.db)
```

In your st.cmd file, you'll need to define macros for the camera base prefix and port.
For example:
```
epicsEnvSet( "CAM",      "TST:GIGE:BASLER2" )
epicsEnvSet( "CAM_PORT", "CAM" )
```

Most of the remaining required env variables characterize the camera characteristics:
* IMAGE_XSIZE
* IMAGE_YSIZE
* IMAGE_NELM
* IMAGE_BIT_DEPTH
* IMAGE_TYPE
* IMAGE_FTVL
* STREAM_NELM

STREAM_NELM is often set the same as IMAGE_NELM but can be reduced if desired
to ensure the data transfered via EPICS CA isn't too large even if variable sized
arrays aren't supported.

We typically define these by sourcing an env file specific to the camera model.
For example, our MantaG146C.env file, which we've added to our ADProsilica module,
looks like this:
```
#
# ----- Manta G146C ENV Vars -----
#
epicsEnvSet( "IMAGE_FTVL",      "UCHAR"     )
epicsEnvSet( "IMAGE_TYPE",      "Int8"      )
epicsEnvSet( "IMAGE_BIT_DEPTH", "12"        )
epicsEnvSet( "IMAGE_XSIZE",     "1388"      )
epicsEnvSet( "IMAGE_YSIZE",     "1038"      )
epicsEnvSet( "IMAGE_NELM",      "4322232"   )   # X*Y (B/W) or X*Y*3 (Color)
```

In st.cmd, you can then install as many image streams as desired by defining the common env variables
and then adding lines like this:
```
# Add DataStream named DATA1
epicsEnvSet( "IMAGE_NAME", "DATA1" )
. db/DataStream.cmd

# Add ViewerStreams named IMAGE1 and IMAGE2
epicsEnvSet( "VIEWER_NELM", $(IMAGE_NELM) )
epicsEnvSet( "IMAGE_NAME", "IMAGE1" )
. db/ViewerStream.cmd
epicsEnvSet( "IMAGE_NAME", "IMAGE2" )
. db/ViewerStream.cmd

# Add a ThumbnailStream named THUMBNAIL
epicsEnvSet( "THUMBNAIL_NELM", $(IMAGE_NELM) )
epicsEnvSet( "IMAGE_NAME", "THUMBNAIL" )
. db/ThumbnailStream.cmd
```

Individual plugins can be loaded by defining macros N and PLUGIN\_SRC, along w/ any plugin specific macros,
and sourcing the appropriate cmd script.
For example, you can load an additional Stats plugin like this:
```
epicsEnvSet( "N", 2 )
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
. db/pluginStats.cmd
```

## EDM usage
From edm, the way it works is that any buttons that change stream characteristics are stacked
on top of shell widgets that run the configStream.py script, which is found in the same
directory as the edm screens and located at run-time via a soft link ADStreamScreens/configStream.py.
The script works it's way through the stream's plugins, setting NDArrayPort, plugin enables,
minCallbackTime, binning, etc as needed to  produce the desired result with only the needed
plugins in the chain.

There are also buttons to create a new custom edm screen and switch to it if the stdArray
output dimensions change.

The 4 ROI regions and 4 cross locations and sizes are shared between all image streams and
configured using unbinned camera pixels.    Overlays to show these are scaled down by the
appropriate bin factor and selected region for each image stream. Each of the cross and ROI box
overlays can be turned on and off independently for each stream. Image averaging and color
conversion can also be configured independently for each stream.

We typically load these streams w/ ADCore's commonPlugins set, and use it's 4 ROI plugins
for each of the 4 ROI regions that the streams can view.   The stream input can also be configured
to view the commonPlugins: Trans1, Proc1, CC1, CC2, as well as the camera port. 

