#-
#- commonPlugins.cmd
#-
#- This script creates, configures, and loads db records for our
#- default set of plugins

dbLoadRecords( "db/commonPlugins.db", "CAM=$(CAM_PV),CAM_PORT=$(CAM_PORT),XSIZE=$(IMAGE_XSIZE),YSIZE=$(IMAGE_YSIZE)" )

NDColorConvertConfigure("CC1",     "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) ))
NDColorConvertConfigure("CC2",     "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) ))
NDFileHDF5Configure(    "HDF51",   "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0 )
NDFileJPEGConfigure(    "JPEG1",   "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0 )
NDFileNetCDFConfigure(  "NetCDF1", "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0 )
NDFileNexusConfigure(   "Nexus1",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0 )
NDOverlayConfigure(     "Over1",   "$(QSIZE)", 0, "$(CAM_PORT)", 0, 8, 0, 0, 0, 0, $(MAX_THREADS=5) ))
NDProcessConfigure(     "Proc1",   "$(QSIZE)", 0, "$(CAM_PORT)", 0 )
NDROIConfigure(         "ROI1",    "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDROIConfigure(         "ROI2",    "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDROIConfigure(         "ROI3",    "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDROIConfigure(         "ROI4",    "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDStatsConfigure(       "Stats1",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDStatsConfigure(       "Stats2",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDStatsConfigure(       "Stats3",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDStatsConfigure(       "Stats4",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDStatsConfigure(       "Stats5",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )
NDFileTIFFConfigure(    "TIFF1",   "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0 )
NDTransformConfigure(   "Trans1",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )

