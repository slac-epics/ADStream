#
# MonoFullViewer.cmd
#
# This script creates, configures, and loads db records for one
# monochrome viewer w/ no binning or pixel size reduction

########## PCDS standard image w/ ROI plugin ############
# Create an ROI plugin for our standard image
epicsEnvSet( "QSIZE", "5" )
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "5" )
< db/pluginROI.cmd

# Create a Std Image plugin, set to get data from it's ROI plugin
epicsEnvSet( "PLUGIN_SRC", "ROI5" )
epicsEnvSet( "IMAGE_NAME", "IMAGE1" )
< db/pluginImage.cmd

