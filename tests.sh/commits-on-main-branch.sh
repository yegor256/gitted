#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf repo
git init repo --initial-branch=main
cd repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
touch initial.txt
git add initial.txt
git commit --no-verify -am "initial commit"
touch second.txt

env "GITTED_TESTING=true" \
    "${base}/scripts/commit" "fake-commit-message" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd repo || exit 1
git log | grep "fake-commit-message"
