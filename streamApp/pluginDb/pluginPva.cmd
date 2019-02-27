#-
#- pluginPva.cmd
#-
#- Required env vars
#-	CAM			- PV Prefix for all camera related PV's
#-	N			- Plugin number, must be unique if more than one Pva plugin
#-	PLUGIN_SRC	- Which port should this plugin get its data from

#- Configure the plugin
#- NDPvaConfigure( portName, queueSize, blockingCallbacks, dataSrcPortName, addr, pvName, maxMemory, priority, stackSize )
#- Set maxMemory  to 0 for unlimited memory allocation
#- Set priority   to 0  for default priority
#- Set stackSize  to 0  for default stackSize
NDPvaConfigure( "Pva$(N)", $(QSIZE), 0, "$(PLUGIN_SRC)", 0, "$(P)$(R)Pva$(N):Image", 0, 0, 0 )

#- Load the plugin records
dbLoadRecords( "db/pluginPva.db",  "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),N=$(N)" )

