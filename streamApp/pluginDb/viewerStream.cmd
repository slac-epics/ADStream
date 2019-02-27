#- viewerStream.cmd
#- This script creates, configures, and loads db records for one
#- viewer stream w/ 2x2 binning and 10hz rate

#- Configure the plugins
NDStdArraysConfigure(    "$(IMAGE_NAME)",     $(QSIZE), 0, "$(CAM_PORT)", 0, -1 )
NDPvaConfigure(          "$(IMAGE_NAME):Pva", $(QSIZE), 0, "$(CAM_PORT)", 0, "$(CAM_PV):$(IMAGE_NAME):Pva:Image", 0, 0, 0 )
NDColorConvertConfigure( "$(IMAGE_NAME):CC",  $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDROIConfigure(          "$(IMAGE_NAME):ROI", $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDOverlayConfigure(      "$(IMAGE_NAME):Over", 16,      0, "$(CAM_PORT)", 0, 8 )
NDProcessConfigure(      "$(IMAGE_NAME):Proc",$(QSIZE), 0, "$(CAM_PORT)", 0 )

#- Load the viewerStream records
dbLoadRecords( "db/viewerStream.db", "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),IMAGE_NAME=$(IMAGE_NAME),STREAM_NELM=$(STREAM_NELM),IMAGE_FTVL=$(IMAGE_FTVL),IMAGE_TYPE=$(IMAGE_TYPE)" )

