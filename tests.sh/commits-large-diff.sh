#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf repo
git init repo --initial-branch=master
cd repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
touch initial.txt
git add initial.txt
git commit --no-verify -am "initial commit"
for i in {1..5000} ; do
    printf "line %s\n" "${i}" >> large.txt
done

exit_code=0
env "GITTED_TESTING=true" \
    "OPENAI_API_KEY=fake-openai-api-key" \
    "${base}/scripts/commit" "fake-commit-message" 2>&1 | tee "${tmp}/log.txt" || exit_code=$?
cd .. || exit 1

cd repo || exit 1
test "${exit_code}" -eq 0
git log | grep "fake-commit-message"
