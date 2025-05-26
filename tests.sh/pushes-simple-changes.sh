#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

echo "echo \"fake-commit-message\"" > openai.sh
chmod a+x openai.sh

git init repo
cd repo || exit 1
touch hello.txt

env "OPENAI_BIN=${tmp}/openai.sh" \
    "${base}/scripts/push" 2>&1 | tee "${tmp}/log.txt"

cd .. || exit 1

grep -- '--message fake-commit-message' "${tmp}/log.txt"

git log | grep 'fake-commit-message'

