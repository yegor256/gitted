#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

scripts="$(dirname "$0")/../sub-scripts"

# shellcheck disable=SC1090
. "${scripts}/intro.sh"
# shellcheck disable=SC1090
. "${scripts}/commons.sh"
# shellcheck disable=SC1090
. "${scripts}/sanity.sh"
