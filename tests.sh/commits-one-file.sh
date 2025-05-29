#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

echo "echo \"fake-message44\"" > openai.sh
chmod a+x openai.sh

rm -rf here
git init here
cd here || exit 1
touch hello.txt
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"

env "GITTED_TESTING=true" \
    "OPENAI_BIN=${tmp}/openai.sh" \
    "${base}/scripts/commit" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd here || exit 1
git log | grep 'fake-message44'
cd .. || exit 1
