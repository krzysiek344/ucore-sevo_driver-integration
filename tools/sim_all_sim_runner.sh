#!/bin/bash

if [[ -z ${ROOTDIR} ]]; then
    echo "ERROR: environment not initialized"
    exit 1
fi

red="\033[0;31m"
green="\033[01;32m"
white="\033[00m"

tests="$(sim_runner.sh -l)"
for test in ${tests}; do
    printf "${test}: "
    sim_runner.sh -ct ${test} > /dev/null 2>&1
    result=$([[ "$?" == 0 ]] && echo ${green}passed${white} || echo ${red}failed${white})
    printf "${result}\n"
done
