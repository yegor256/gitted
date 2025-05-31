#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf there
git init there --initial-branch=foo

rm -rf here
git init here --initial-branch=master
cd here || exit 1
touch hello.txt
git remote add origin "file://${tmp}/there"
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"

env "GITTED_TESTING=true" \
    "${base}/scripts/push" fake-commit-message 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd here || exit 1
git log | grep 'fake-commit-message'
cd .. || exit 1

cd there || exit 1
git checkout master
git log | grep 'fake-commit-message'
