#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

if [ -n "${GITTED_TESTING}" ]; then
    set -x
fi

if [ -n "${GITTED_VERBOSE}" ]; then
    set -x
fi

function title_it {
    printf '\n👉🏻 \e[1m%s\e[0m...\n' "$@"
}

function bash_it {
    printf '%q ' "$@" | /bin/bash -x
}

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Oops, this is not a Git repository"
    exit 1
fi

base=$(dirname "$0")
export base

master=master
export master

if [ -z "${GIT_BIN}" ]; then
    GIT_BIN=git
    export GIT_BIN
fi
