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
    printf '\n👉 \e[1m%s\e[0m...\n' "$@"
}

function warn_it {
    printf '\n⚠️ \e[38;5;160m%s\e[0m\n' "$@"
}

function fail_it {
    warn_it "$@"
    exit 1
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

function retry_it {
    local message="$1"
    local cmd="$2"
    local max="${3:-10}"
    local attempt=1
    while (( attempt <= max )); do
        title_it "${message} (attempt no.${attempt}/${max})"
        eval "$cmd" && return 0
        if [ -n "${GITTED_TESTING}" ]; then
            exit 1
        fi
        attempt=$(( attempt + 1 ))
        sleep 1
    done
    fail_it "Command failed after ${max} attempts: ${cmd}"
}

base=$(dirname "$0")
export base

branches="$(git branch --format='%(refname:short)')"
if [ -z "${branches}" ]; then
    master="$(git symbolic-ref --short HEAD 2>/dev/null || exit 1)"
elif echo "$branches" | grep -qx 'master'; then
    master=master
elif echo "$branches" | grep -qx 'main'; then
    master=main
else
    fail_it "Neither 'master' nor 'main' branch found."
fi
export master

if [ -z "${GIT_BIN}" ]; then
    GIT_BIN=git
    export GIT_BIN
fi
