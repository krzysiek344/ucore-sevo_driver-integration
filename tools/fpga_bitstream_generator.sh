#!/bin/bash -e
#
# Copyright (C) 2025  AGH University of Krakow
#

cd ${ROOTDIR}/sw/app
make

cd ${ROOTDIR}/hw/fpga
git clean -fXd .
vivado -mode tcl -source ucore.tcl
