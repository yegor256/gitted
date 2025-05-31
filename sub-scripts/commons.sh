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

function warn_it {
    printf '\n⚠️ \e[38;5;160m%s\e[0m\n' "$@"
}

function bash_it {
    printf '%q ' "$@" | /bin/bash -x
}

function plural {
    printf "%s %s" "$1" "$2"
    if [ "$1" != '1' ]; then
        printf 's'
    fi
}

base=$(dirname "$0")
export base

master=master
export master

if [ -z "${GIT_BIN}" ]; then
    GIT_BIN=git
    export GIT_BIN
fi
