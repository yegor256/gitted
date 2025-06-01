#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

while IFS= read -r f; do
    # shellcheck disable=SC1090
    . "${f}"
done < <(find "$(dirname "$0")/../sub-scripts" -type f -name '*.sh' -not -name "all.sh")
