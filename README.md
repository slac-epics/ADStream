# ADStream module
ADStream makes it easy to configure an areaDetector camera IOC for one or more image
streams, each of which has it's own dedicated stdArray, ROI, CC, Overlay, and Process
plugin, along w/ some extra PV's to characterize the stream type, input source, height,
width, and desired update rate.

You can also do image averaging, and view and adjust 4 crosses and 4 ROI overlay boxes.
The overlays have calc records to handle binning differences between streams.

Stream types include:
* DataStream: Full rate, full res
* ViewingStream: Defaults to 10hz, (configurable), 640x560 target dimensions (configurable)
* ThumbnailStream: Always B/W,  8 bit pixels, 174x130 target dimensions, default 1hz rate

ADStream depends on ADCore, so you'll need to define the path to your ADCore release in
configure/RELEASE.   ADStream has been tested w/ ADCore versions from R2.0 and R2.1, but should
work w/ newer versions as well.

## Files built in db directory
ADStream populates the db directory w/ a combination of db files and cmd files.
The cmd files are iocsh scripts to facilitate loading the appropriate db file and configuring any
plugins which it contain.  Epics env variables are used to configure PV names and characteristics
for the plugins, and the required ENV variables are documented in each cmd file.

The db files are produced via substitution files, so each ADCore plugin type has a db file and a cmd file.

There are also cmd scripts and db files for each type of stream.

To use in an IOC, define the ADSTREAM macro in your configure/RELEASE file and add the following lines
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
* IMAGE\_XSIZE
* IMAGE\_YSIZE
* IMAGE\_NELM
* IMAGE\_BIT\_DEPTH
* IMAGE\_TYPE
* IMAGE\_FTVL

We typically define these by sourcing an env file specific to the camera model.
For example, our MantaG201B.env file, which we've added to our ADProsilica module,
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
epicsEnvSet( "IMAGE_NAME", "DATA1" )
. db/DataStream.cmd
epicsEnvSet( "IMAGE_NAME", "IMAGE1" )
. db/ViewerStream.cmd
epicsEnvSet( "IMAGE_NAME", "IMAGE2" )
. db/ViewerStream.cmd
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
