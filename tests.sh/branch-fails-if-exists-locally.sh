#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf remote_repo
git init remote_repo --initial-branch=master
cd remote_repo || exit 1
git config user.email "remote@zerocracy.com"
git config user.name "Remote Author"
touch initial.txt
git add initial.txt
git commit --no-verify -am "initial commit"
cd .. || exit 1

rm -rf local_repo
git clone "file://${tmp}/remote_repo" local_repo
cd local_repo || exit 1
git branch 42

exit_code=0
env "GITTED_TESTING=true" \
    "${base}/scripts/branch" 42 2>&1 | tee "${tmp}/log.txt" || exit_code=$?

test "$exit_code" = 1
grep "Branch '42' already exists locally" "${tmp}/log.txt"
