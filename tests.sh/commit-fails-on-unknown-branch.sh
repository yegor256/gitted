#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf repo
git init repo --initial-branch=unknown
cd repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
touch initial.txt
git add initial.txt
git commit --no-verify -am "initial commit"
touch second.txt

exit_code=0
env "GITTED_TESTING=true" \
    "${base}/scripts/commit" "fake-commit-message" 2>&1 | tee "${tmp}/log.txt" || exit_code=$?
test "$exit_code" = 1
cd .. || exit 1

cd repo || exit 1
grep "Neither 'master' nor 'main' branch found." "${tmp}/log.txt"
