#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf here
git init here --initial-branch=master
cd here || exit 1
echo '123' > abc.txt
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
git add .
git commit --no-verify -am 'abc'

(env "GITTED_TESTING=true" "${base}/scripts/commit" fake-message8799 2>&1 || true) | tee "${tmp}/log.txt"
cd .. || exit 1

cd here || exit 1
test "$(git rev-list --count HEAD)" == 1
cd .. || exit 1
