#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

env "${base}/scripts/commit" --help 2>&1 | tee "${tmp}/log.txt"

grep 'Usage:' "${tmp}/log.txt"
