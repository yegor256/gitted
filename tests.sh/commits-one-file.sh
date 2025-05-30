#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf here
git init here --initial-branch=master
cd here || exit 1
touch first.txt
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
git add .
git commit --no-verify -am 'start'
touch second.txt

env "GITTED_TESTING=true" \
    "${base}/scripts/commit" fake-message44 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd here || exit 1
git log | grep 'fake-message44'
cd .. || exit 1
