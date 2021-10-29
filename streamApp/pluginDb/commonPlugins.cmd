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
NDTimeSeriesConfigure(  "Stats1_TS","$(QSIZE)",1, "Stats1", 1, $(N_TS_BUFF=23), 0, 0, 0, 0 )
NDTimeSeriesConfigure(  "Stats2_TS","$(QSIZE)",1, "Stats2", 1, $(N_TS_BUFF=23), 0, 0, 0, 0 )
NDTimeSeriesConfigure(  "Stats3_TS","$(QSIZE)",1, "Stats3", 1, $(N_TS_BUFF=23), 0, 0, 0, 0 )
NDTimeSeriesConfigure(  "Stats4_TS","$(QSIZE)",1, "Stats4", 1, $(N_TS_BUFF=23), 0, 0, 0, 0 )
NDTimeSeriesConfigure(  "Stats5_TS","$(QSIZE)",1, "Stats5", 1, $(N_TS_BUFF=23), 0, 0, 0, 0 )
NDFileTIFFConfigure(    "TIFF1",   "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0 )
NDTransformConfigure(   "Trans1",  "$(QSIZE)", 0, "$(CAM_PORT)", 0, 0, 0, 0, 0, $(MAX_THREADS=5) )

