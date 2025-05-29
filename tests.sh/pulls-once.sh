#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf there
git init there
cd there || exit 1
touch hello.txt
git add hello.txt
git commit --no-verify -am start987
cd .. || exit 1

rm -rf here
git clone "file://${tmp}/there" here
cd here || exit 1
touch second.txt
git add second.txt

env "GITTED_TESTING=true" \
    "${base}/scripts/pull" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd here || exit 1
git log | grep 'start987'
cd .. || exit 1
