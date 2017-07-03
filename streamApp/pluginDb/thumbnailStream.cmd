# thumbnailStream.cmd
# This script creates, configures, and loads db records for one
# monochrome thumbnail viewer w/ 4x4 binning and 1hz rate

# Configure the plugins
NDStdArraysConfigure(    "$(IMAGE_NAME)",     $(QSIZE), 0, "$(CAM_PORT)", 0, -1 )
NDColorConvertConfigure( "$(IMAGE_NAME):CC",  $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDROIConfigure(          "$(IMAGE_NAME):ROI", $(QSIZE), 0, "$(CAM_PORT)", 0 )
NDOverlayConfigure(      "$(IMAGE_NAME):Over", 16,      0, "$(CAM_PORT)", 0, 8 )
NDProcessConfigure(      "$(IMAGE_NAME):Proc",$(QSIZE), 0, "$(CAM_PORT)", 0 )

# Load the image stream records
dbLoadRecords( "db/thumbnailStream.db", "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),IMAGE_NAME=$(IMAGE_NAME),STREAM_NELM=$(STREAM_NELM)" )

