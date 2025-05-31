#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf here
git init here --initial-branch=master
cd here || exit 1

env "GITTED_TESTING=true" \
    "${base}/scripts/pull" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1
