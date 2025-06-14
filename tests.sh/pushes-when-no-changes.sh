#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf remote_repo
git init remote_repo --initial-branch=master
cd remote_repo || exit 1
touch initial.txt
git add initial.txt
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
git commit --no-verify -am "initial commit"
cd .. || exit 1

rm -rf local_repo
git clone "file://${tmp}/remote_repo" local_repo
cd local_repo || exit 1

env "GITTED_TESTING=true" \
    "${base}/scripts/push" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

grep "Nothing to commit, proceeding with push" "${tmp}/log.txt"
grep "Everything up-to-date" "${tmp}/log.txt"
