#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

exit_code=0
env -i \
    HOME="${HOME}" \
    "GITTED_TESTING=true" \
    "GITTED_BATCH=true" \
    "GIT_BIN=definitely-missing-git" \
    "PATH=${PATH}" \
    /bin/bash "${base}/scripts/branch" "1" 2>&1 | tee "${tmp}/log.txt" || exit_code=$?

test "${exit_code}" = 1
grep -q "'definitely-missing-git' command was not found" "${tmp}/log.txt"
