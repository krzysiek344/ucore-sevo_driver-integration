#!/bin/bash -e
#
# Copyright (C) 2025  AGH University of Krakow
#

if [[ -z ${ROOTDIR} ]];then 
    echo "ERROR: enviroment not initialized"
    exit 1 
fi 

mkdir -p ${ROOTDIR}/results

cd ${ROOTDIR}/sw/app
make

cd ${ROOTDIR}/hw/fpga
git clean -fXd .
vivado -mode tcl -source ucore.tcl

cd ${ROOTDIR}
find hw/fpga/build -name "*.bit" -exec cp {} results/ \;

./tools/warning_summary.sh 


