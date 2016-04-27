# dataStream.cmd

# Configure the plugins
NDStdArraysConfigure(    "$(IMAGE_NAME)",     $(QSIZE), 0, "$(CAM_PORT)", 0, -1 )
NDColorConvertConfigure( "$(IMAGE_NAME):CC",  $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDROIConfigure(          "$(IMAGE_NAME):ROI", $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDOverlayConfigure(      "$(IMAGE_NAME):Over", 16,      0, "$(CAM_PORT)", 0, 8 )

# Load the dataStream records
dbLoadRecords( "db/dataStream.db",      "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),IMAGE_NAME=$(IMAGE_NAME),IMAGE_NELM=$(IMAGE_NELM),IMAGE_FTVL=$(IMAGE_FTVL),IMAGE_TYPE=$(IMAGE_TYPE)" )

