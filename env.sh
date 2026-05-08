#!/bin/bash -e

. /eda/etc/lm_license_file
. /eda/cadence/2025-26/scripts/XCELIUM_25.03.006_RHELx86.sh

export ROOTDIR=$(pwd)
export BFMS_ROOTDIR=${ROOTDIR}/hw/sim/common
export RISCV_TOOLCHAIN_ROOTDIR=/eda/gcc/riscv
export VIVADO_ROOTDIR=/eda/AMD/2025.1/Vivado

export PATH=\
${ROOTDIR}/tools:\
${RISCV_TOOLCHAIN_ROOTDIR}/bin:\
${VIVADO_ROOTDIR}/bin:\
${PATH}

export CXX=${RISCV_TOOLCHAIN_ROOTDIR}/bin/riscv32-unknown-elf-g++

_sim_runner_completions() {
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "-ct -l -t" -- "${COMP_WORDS[1]}"))
    elif [[ ${COMP_CWORD} -eq 2 && ${COMP_WORDS[1]} =~ ^(-ct|-t) ]]; then
        COMPREPLY=($(compgen -W "$(sim_runner.sh -l)" -- "${COMP_WORDS[2]}"))
    fi
}

complete -F _sim_runner_completions sim_runner.sh
