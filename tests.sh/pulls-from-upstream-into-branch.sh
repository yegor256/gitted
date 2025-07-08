#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf upstream
git init upstream --initial-branch=master
cd upstream || exit 1
git config user.email "upstream@zerocracy.com"
git config user.name "Upstream Author"
touch master-first.txt
git add master-first.txt
git commit --no-verify -am "upstream master first"
cd .. || exit 1

rm -rf origin
cp -R upstream origin

rm -rf local
git clone "file://${tmp}/origin" local
cd local || exit 1
git remote add upstream "file://${tmp}/upstream"
git config user.email "local@zerocracy.com"
git config user.name "Local Author"
git checkout -b 42
git push origin 42
touch 42-first.txt
git add 42-first.txt
git commit --no-verify -am "local 42 first"
cd .. || exit 1

cd upstream || exit 1
touch master-second.txt
git add master-second.txt
git commit --no-verify -am "upstream master second"
cd .. || exit 1

cd local || exit 1
env "GITTED_TESTING=true" \
    "${base}/scripts/pull" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd local || exit 1
test "$(git branch --show-current)" = "42"
git log | grep "upstream master first"
git log | grep "upstream master second"
git log | grep "local 42 first"
