#!/bin/bash -e
#
# Copyright (C) 2026  AGH University of Krakow
#

function usage {
    echo "usage: $(basename "$0") [options]"
    echo "  options:"
    echo "      -c,                 console mode"
    echo "      -l,                 list available tests"
    echo "      -t <test_name>,     execute test"
    exit 1
}

if [[ -z ${ROOTDIR} ]]; then
    echo "ERROR: environment not initialized"
    exit 1
fi

if [[ $# -eq 0 ]]; then
    usage
fi

export console_mode=false

while getopts clt: option; do
    case ${option} in
        c) console_mode=true;;
        l) list_available_test=true;;
        t) test_name=${OPTARG};;
        *) usage;;
    esac
done

cd ${ROOTDIR}/hw/sim

if [[ ${list_available_test} ]]; then
    find . -type f -name commands.tcl -printf '%h\n' | sed 's|^\./||'
    exit 0
fi

if [[ -z ${test_name} ]]; then
    echo "ERROR: test name not specified"
    usage
fi

if [[ ! -d ${test_name} ]]; then
    echo "ERROR: incorrect test name"
    exit 1
fi

cd ${test_name}
git clean -fXd .

if [[ -f sw/Makefile ]]; then
    make -C sw
fi

optargs=""

if [[ ${console_mode} == "false" ]]; then
    optargs+="-gui"
fi

xrun -64bit -access +r  ${mode} -f ${test_name}.f -input commands.tcl ${optargs} -define TSMC_CM_UNIT_DELAY
