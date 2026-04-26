#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf shadow
mkdir shadow
for tool in awk basename cat chmod cp cut dirname grep gpg head ls mkdir mktemp mv printf rm sed sort tail tee touch tr wc which; do
    full=$(command -v "${tool}" || true)
    if [ -n "${full}" ]; then
        ln -sf "${full}" "shadow/${tool}"
    fi
done

exit_code=0
env -i \
    HOME="${HOME}" \
    "GITTED_TESTING=true" \
    "GITTED_BATCH=true" \
    "PATH=${tmp}/shadow" \
    /bin/bash "${base}/scripts/branch" "1" 2>&1 | tee "${tmp}/log.txt" || exit_code=$?

test "${exit_code}" = 1
grep -q "'git' command was not found" "${tmp}/log.txt"
