#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf sub
git init sub --initial-branch=master
cd sub || exit 1
git config user.email "sub@zerocracy.com"
git config user.name "Sub Author"
touch sub-file.txt
git add sub-file.txt
git commit --no-verify -am "submodule initial"
cd .. || exit 1

rm -rf origin
git init --bare origin --initial-branch=master
cd origin || exit 1
git config uploadpack.allowFilter true
cd .. || exit 1

rm -rf foo
git clone "file://${tmp}/origin" foo
cd foo || exit 1
git config user.email "foo@zerocracy.com"
git config user.name "Foo Author"
touch root.txt
git add root.txt
git commit --no-verify -am "foo initial"
git -c protocol.file.allow=always submodule add "file://${tmp}/sub" sub
git commit --no-verify -am "added submodule"
git push origin master
mkdir bar
cd bar || exit 1

env "GITTED_TESTING=true" "GIT_ALLOW_PROTOCOL=file" \
    "${base}/scripts/pull" 2>&1 | tee "${tmp}/log.txt"

grep 'Updating 1 submodule' "${tmp}/log.txt"
