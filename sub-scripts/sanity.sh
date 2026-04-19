#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    fail_it "Oops, this is not a Git repository"
fi
