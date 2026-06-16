#!/bin/bash
#
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# This script extracts warnings and errors from the synthesis
# and implementation logs to a single log file.
# Run from the project root directory.

PROJECT_PATH="${ROOTDIR}/hw/fpga/build"
LOG_FILE="${ROOTDIR}/results/warning_summary.log"

mkdir -p "${ROOTDIR}/results"

SYNTH_IGNORE='a^'
IMPL_IGNORE='a^'

printf '%b\n' 'Warnings, critical warnings and errors from synthesis and implementation\n' > "$LOG_FILE"
printf '%b\n\n' "Created: $(date '+%F %T')" >> "$LOG_FILE"

printf '%b\n' '----SYNTHESIS----' >> "$LOG_FILE"
SYNTH_LOG=$(find "$PROJECT_PATH" -path "*/synth_1/runme.log" | head -n 1)

if [[ -n "$SYNTH_LOG" && -f "$SYNTH_LOG" ]]; then
    if ! grep -hEv "$SYNTH_IGNORE" "$SYNTH_LOG" | grep -E 'CRITICAL WARNING|WARNING|ERROR' >> "$LOG_FILE"
    then
        printf 'CLEAR :)\n' >> "$LOG_FILE"
    fi
else
    printf 'No synthesis log file found!\n' >> "$LOG_FILE"
fi

printf '%b\n' '\n----IMPLEMENTATION----' >> "$LOG_FILE"
IMPL_LOG=$(find "$PROJECT_PATH" -path "*/impl_1/runme.log" | head -n 1)

if [[ -n "$IMPL_LOG" && -f "$IMPL_LOG" ]]; then
    if ! grep -hEv "$IMPL_IGNORE" "$IMPL_LOG" | grep -E 'CRITICAL WARNING|WARNING|ERROR' >> "$LOG_FILE"
    then
        printf 'CLEAR :)\n' >> "$LOG_FILE"
    fi
else
    printf 'No implementation log file found!\n' >> "$LOG_FILE"
fi
