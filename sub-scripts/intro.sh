#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

if [ "$1" == '--help' ]; then
    cmd=$(basename "$0")
    var="help_${cmd}"
    help=${!var}
    if [ -z "${help}" ]; then
        echo "Usage: ${cmd} --help"
    else
        echo "${help}"
    fi
    exit
fi

if [ -z "${GITTED_INTRODUCED}" ]; then
    printf "\e[1mGitted\e[0m 0.0.12 (any issues or ideas, submit to https://github.com/yegor256/gitted)\n"
    GITTED_INTRODUCED=true
    export GITTED_INTRODUCED
fi
