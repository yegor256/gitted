#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

echo "echo \"fake-commit-message\"" > openai.sh
chmod a+x openai.sh

rm -rf there
git init there --initial-branch=foo

rm -rf here
git init here
cd here || exit 1
touch hello.txt
git remote add origin "file://${tmp}/there"

env "OPENAI_BIN=${tmp}/openai.sh" \
    "${base}/scripts/push" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

grep -- '--message fake-commit-message' "${tmp}/log.txt"

cd here || exit 1
git log | grep 'fake-commit-message'
cd .. || exit 1

cd there || exit 1
git checkout master
git log | grep 'fake-commit-message'
cd .. || exit 1
