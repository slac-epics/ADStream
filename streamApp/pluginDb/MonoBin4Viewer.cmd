#
# MonoBin4Viewer.cmd
#
# This script creates, configures, and loads db records for one
# monochrome viewer w/ 4x4 binning

########## PCDS standard image w/ ROI plugin ############
# Create an ROI plugin for our standard image
epicsEnvSet( "QSIZE", "5" )
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
# TODO: epicsEnvSet( "PLUGIN_ROI", 4 )
epicsEnvSet( "N", "7" )
< db/pluginROI.cmd

# Create a Std Image plugin, set to get data from it's ROI plugin
epicsEnvSet( "PLUGIN_SRC", "ROI7" )
epicsEnvSet( "IMAGE_NAME", "THUMBNAIL" )

# Configure the plugin
NDStdArraysConfigure( "$(IMAGE_NAME)", $(QSIZE), 0, "$(PLUGIN_SRC)", 0, -1)
# Load the plugin records
dbLoadRecords( "db/pluginImage.db",  "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),PLUGIN_SRC=$(PLUGIN_SRC),IMAGE_NAME=$(IMAGE_NAME),IMAGE_NELM=$(IMAGE_NELM),IMAGE_BIT_DEPTH=8,IMAGE_FTVL=UCHAR,IMAGE_TYPE=Int8" )

