#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

if [ -z "${GITTED_INTRODUCED}" ]; then
    printf "Gitted 0.0.0 (any issues or ideas, submit to https://github.com/yegor256/gitted)\n\n"
    GITTED_INTRODUCED=true
    export GITTED_INTRODUCED
fi
