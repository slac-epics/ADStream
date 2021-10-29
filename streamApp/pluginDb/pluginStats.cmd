#-
#- pluginStats.cmd
#-
#- Required env vars
#-	CAM			- PV Prefix for all camera related PV's
#-	N			- Plugin number, must be unique if more than one Stats plugin
#-	PLUGIN_SRC	- Which port should this plugin get its data from
#-	IMAGE_XSIZE	- Max SizeX for image
#-	IMAGE_YSIZE	- Max SizeY for image
#-
#- Optional env vars
#-   RATE_SMOOTH	- Smoothing factor for plugin rate, default 0.0, no smoothing
#-   TSE			- Timestamp source for PV's that update for each image, default -2, driver
#-	HIST_SIZE	- Histogram size, default 256
#-	NCHANS		- Statistics array size, default 2048

#- Configure the plugin
#- NDStatsConfigure( portName, queueSize, blockingCallbacks, dataSrcPortName, addr, maxBuffers, maxMemory, priority, stackSize, maxThreads )
#- NDTimeSeriesConfigure( portName, queueSize, blockingCallbacks, dataSrcPortName, addr, maxSignals, maxBuffers, maxMemory, priority, stackSize )
#- Set maxBuffers to 0 for unlimited buffers
#- Set maxMemory  to 0 for unlimited memory allocation
#- Set priority   to 0  for default priority
#- Set stackSize  to 0  for default stackSize
NDStatsConfigure( "Stats$(N)", $(QSIZE), 0, "$(PLUGIN_SRC)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDTimeSeriesConfigure( "Stats$(N)_TS", $(QSIZE), 1, "Stats$(N)", 1, $(N_TS_BUFF=23), 0, 0, 0, 0 )

#- Load the plugin records
dbLoadRecords( "db/pluginStats.db",  "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),N=$(N),XSIZE=$(IMAGE_XSIZE),YSIZE=$(IMAGE_YSIZE)" )
