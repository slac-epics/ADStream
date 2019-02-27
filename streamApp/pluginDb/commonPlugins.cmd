#-
#- commonPlugins.cmd
#-
#- This script creates, configures, and loads db records for our
#- default set of plugins
epicsEnvSet( "QSIZE", "5" )

#- Create a couple of Color Conversion plugins
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginColorConvert.cmd
epicsEnvSet( "N", "2" )
< db/pluginColorConvert.cmd

#- Create an HDF5 File plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginHDF5.cmd

#- Create a JPEG File plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginJPEG.cmd

#- GraphicsMagick not supported in areaDetector 1.9 for RHEL due to compiler issues
#- Create a Magick plugin, set it to get data from the camera
#-epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
#-epicsEnvSet( "N", "1" )
#-< db/pluginMagick.cmd

#- Create a NetCDF plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginNetCDF.cmd

#- Create a Nexus plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginNexus.cmd

#- Create an Overlay plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginOverlay.cmd

#- Create a Process plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginProcess.cmd

#- Create 4 ROI plugins
#- Set them to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginROI.cmd
epicsEnvSet( "N", "2" )
< db/pluginROI.cmd
epicsEnvSet( "N", "3" )
< db/pluginROI.cmd
epicsEnvSet( "N", "4" )
< db/pluginROI.cmd

#- Create 5 Statistics plugins
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginStats.cmd
epicsEnvSet( "N", "2" )
< db/pluginStats.cmd
epicsEnvSet( "N", "3" )
< db/pluginStats.cmd
epicsEnvSet( "N", "4" )
< db/pluginStats.cmd
epicsEnvSet( "N", "5" )
< db/pluginStats.cmd

#- Create a TIFF plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginTIFF.cmd

#- Create a Transform plugin, set it to get data from the camera
epicsEnvSet( "PLUGIN_SRC", "$(CAM_PORT)" )
epicsEnvSet( "N", "1" )
< db/pluginTransform.cmd

