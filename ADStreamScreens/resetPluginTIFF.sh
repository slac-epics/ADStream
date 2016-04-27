#!/bin/bash
if [ ! -d /tmp/${PLUGIN} ]; then
    mkdir --parents /tmp/${PLUGIN}
    chmod a+w /tmp/${PLUGIN}
fi
caput -S ${PLUGIN}:FilePath      "/tmp/${PLUGIN}"
caput -S ${PLUGIN}:FileName      "test1"
caput -S ${PLUGIN}:FileTemplate  "%s%s_%d.tif"
caput ${PLUGIN}:FileNumber       1
caput ${PLUGIN}:ResetPlugin.PROC 1
