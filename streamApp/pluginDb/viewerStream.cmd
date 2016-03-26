# viewerStream.cmd
# This script creates, configures, and loads db records for one
# viewer stream w/ 2x2 binning and 10hz rate

# Configure the plugins
NDROIConfigure(          "$(IMAGE_NAME):ROI", $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDColorConvertConfigure( "$(IMAGE_NAME):CC",  $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDStdArraysConfigure(    "$(IMAGE_NAME)",     $(QSIZE), 0, "$(CAM_PORT)", 0, -1 )

# Load the viewerStream records
dbLoadRecords( "db/viewerStream.db", "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),IMAGE_NAME=$(IMAGE_NAME),IMAGE_NELM=$(IMAGE_NELM),IMAGE_FTVL=$(IMAGE_FTVL),IMAGE_TYPE=$(IMAGE_TYPE)" )

# Temporary for backward compatibility
NDROIConfigure( "ROI6", $(QSIZE), 0, "$(CAM_PORT)", 0 )
dbLoadRecords(  "db/pluginROI.db",  "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),N=6" )

