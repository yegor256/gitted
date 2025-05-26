#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Zerocracy
# SPDX-License-Identifier: MIT

set -e -o pipefail

base=$(realpath "$(dirname "$0")/..")

sh=$(realpath "$1")
log=$(realpath "$2")

test=$(basename "${sh}")
tmp=${base}/target/tmp/${test}

mkdir -p "$(dirname "${log}")"
mkdir -p "${tmp}"

if ! /bin/bash -c "cd \"${tmp}\" && exec \"${sh}\" > \"${log}\" 2>&1"; then
    cat "${log}"
    echo "❌ ${test} failed"
    exit 1
fi

echo "👍🏻 ${test} passed"
