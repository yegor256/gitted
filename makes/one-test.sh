#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

base=$(realpath "$(dirname "$0")/..")

sh=$(realpath "$1")
mkdir -p "$(dirname "$2")"
touch "$2"
log=$(realpath "$2")

test=$(basename "${sh}")
tmp=${base}/target/tmp/${test}

mkdir -p "${tmp}"

if [ -z "${GITTED_BATCH}" ]; then
    printf "Running \e[1m%s\e[0m ... " "${test}"
else
    echo "Running ${test}"
fi

if ! /bin/bash -c "cd \"${tmp}\" && exec \"${sh}\" > \"${log}\" 2>&1"; then
    if [ -z "${GITTED_BATCH}" ]; then
        printf "\e[38;5;160mFAILED\e[0m\n"
    fi
    cat "${log}"
    exit 1
fi
if [ -z "${GITTED_BATCH}" ]; then
    printf "👍🏻\n"
fi
