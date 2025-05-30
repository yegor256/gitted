#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

echo "echo \"fake-message9844\"" > openai.sh
chmod a+x openai.sh

rm -rf here
git init here --initial-branch=master
cd here || exit 1
echo 'abc' > hello.txt
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"

env "GITTED_TESTING=true" \
    "OPENAI_BIN=${tmp}/openai.sh" \
    "${base}/scripts/commit" 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd here || exit 1
git log | grep 'fake-message9844'
cd .. || exit 1
