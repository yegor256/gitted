#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf up
git init up --initial-branch=master
cd up || exit 1
touch hello.txt
git add hello.txt
git config user.email "walter@zerocracy.com"
git config user.name "Walter Sobchak"
git commit --no-verify -am base
cd .. || exit 1

rm -rf fork
cp -R up fork

cd up
touch second.txt
git add second.txt
git commit --no-verify -am second
cd .. || exit 1

rm -rf here
git clone "file://${tmp}/fork" here
cd here || exit 1
git remote add upstream "file://${tmp}/up"

env "GITTED_TESTING=true" \
    "${base}/scripts/pull" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd here || exit 1
git log | grep 'second'
