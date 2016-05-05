#!/bin/bash
source /reg/g/pcds/setup/epicsenv-3.14.12.sh

PLUGIN=${CAM}:JPEG1   source ADStreamScreens/resetPluginJPEG.sh
PLUGIN=${CAM}:TIFF1   source ADStreamScreens/resetPluginTIFF.sh
PLUGIN=${CAM}:NetCDF1 source ADStreamScreens/resetPluginNetCDF.sh
PLUGIN=${CAM}:Nexus1  source ADStreamScreens/resetPluginNexus.sh
PLUGIN=${CAM}:HDF51   source ADStreamScreens/resetPluginHDF5.sh

