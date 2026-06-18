#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf remote_repo
git init --bare remote_repo --initial-branch=master

rm -rf seed_repo
git clone "file://${tmp}/remote_repo" seed_repo
cd seed_repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
echo 'seed' > seed.txt
git add seed.txt
git commit --no-verify -m "seed-master-msg"
git push origin master
cd .. || exit 1

rm -rf local_repo
git clone "file://${tmp}/remote_repo" local_repo
cd local_repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
git checkout -b 813
echo 'abc' > hello.txt
git add hello.txt
git commit --no-verify -m "fake-new-branch-msg"

env "GITTED_TESTING=true" \
    "${base}/scripts/push" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

grep 'does not exist at origin yet, skipping pull' "${tmp}/log.txt"

cd remote_repo || exit 1
git log 813 | grep 'fake-new-branch-msg'
