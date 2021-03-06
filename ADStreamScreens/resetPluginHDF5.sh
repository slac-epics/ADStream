#!/bin/bash
IOCNAME=`caget -t $IOC:IOCNAME`
if [ !$? -a ! -d $IOC_DATA/$IOCNAME/images ]; then
    mkdir --parents $IOC_DATA/$IOCNAME/images
    chmod a+w $IOC_DATA/$IOCNAME/images
fi
caput -S ${PLUGIN}:FilePath     "$IOC_DATA/$IOCNAME/images"
caput -S ${PLUGIN}:FileName     "test1"
caput -S ${PLUGIN}:FileTemplate	"%s%s_%d.hdf5"
caput ${PLUGIN}:FileNumber       1
caput ${PLUGIN}:FileWriteMode	"Capture"
caput ${PLUGIN}:AutoSave         1
caput ${PLUGIN}:NumCapture       100
