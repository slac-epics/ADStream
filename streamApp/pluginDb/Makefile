TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

# Create and install image stream DB Files
DB += dataStream.db
DB += viewerStream.db
DB += thumbnailStream.db

# Create and install DB Files for plugin sets
DB += commonPlugins.db
DB += pcdsPlugins.db

# Create and install individual plugin DB Files
DB += pluginColorConvert.db
DB += pluginHDF5.db
DB += pluginImage.db
DB += pluginJPEG.db
DB += pluginMagick.db
DB += pluginNetCDF.db
DB += pluginNexus.db
DB += pluginOverlay.db
DB += pluginProcess.db
DB += pluginROI.db
DB += pluginStats.db
DB += pluginTIFF.db
DB += pluginTransform.db

# Install viewer cmd scripts
DB_INSTALLS += $(TOP)/streamApp/pluginDb/dataStream.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/viewerStream.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/thumbnailStream.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/MonoBin2Viewer.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/MonoBin4Viewer.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/MonoFullViewer.cmd

# Install plugin set cmd scripts
DB_INSTALLS += $(TOP)/streamApp/pluginDb/commonPlugins.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pcdsPlugins.cmd

# Install individual plugin cmd scripts
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginColorConvert.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginHDF5.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginImage.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginJPEG.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginMagick.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginNetCDF.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginNexus.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginOverlay.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginProcess.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginROI.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginStats.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginTIFF.cmd
DB_INSTALLS += $(TOP)/streamApp/pluginDb/pluginTransform.cmd

# Create and install image stream archive Files
ARCHIVE += dataStream.archive
ARCHIVE += viewerStream.archive
ARCHIVE += thumbnailStream.archive

# Create and install plugin set archive files
ARCHIVE += commonPlugins.archive
ARCHIVE += pcdsPlugins.archive

# Create and install individual plugin archive Files
ARCHIVE += pluginColorConvert.archive
ARCHIVE += pluginHDF5.archive
ARCHIVE += pluginImage.archive
ARCHIVE += pluginJPEG.archive
ARCHIVE += pluginMagick.archive
ARCHIVE += pluginNetCDF.archive
ARCHIVE += pluginNexus.archive
ARCHIVE += pluginOverlay.archive
ARCHIVE += pluginProcess.archive
ARCHIVE += pluginROI.archive
ARCHIVE += pluginStats.archive
ARCHIVE += pluginTIFF.archive
ARCHIVE += pluginTransform.archive

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

