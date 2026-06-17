#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

GITTED_GIT_MIN_MAJOR=2
GITTED_GIT_MIN_MINOR=13

function gitted_sanity_fail {
    printf '\n⚠️ \e[38;5;160m%s\e[0m\n' "$@" >&2
    exit 1
}

GIT_BIN="${GIT_BIN:-git}"

if ! command -v "${GIT_BIN}" > /dev/null 2>&1; then
    gitted_sanity_fail "Git is not installed: '${GIT_BIN}' command was not found in PATH"
fi

gitted_git_version_raw=$("${GIT_BIN}" --version 2>/dev/null | awk '{print $3}')
if [ -z "${gitted_git_version_raw}" ]; then
    gitted_sanity_fail "Failed to detect Git version (could not parse output of '${GIT_BIN} --version')"
fi
IFS='.' read -r gitted_git_major gitted_git_minor _ <<< "${gitted_git_version_raw}"
if ! [[ "${gitted_git_major}" =~ ^[0-9]+$ ]] || ! [[ "${gitted_git_minor}" =~ ^[0-9]+$ ]]; then
    gitted_sanity_fail "Failed to parse Git version '${gitted_git_version_raw}'"
fi
if [ "${gitted_git_major}" -lt "${GITTED_GIT_MIN_MAJOR}" ] || \
    { [ "${gitted_git_major}" -eq "${GITTED_GIT_MIN_MAJOR}" ] && [ "${gitted_git_minor}" -lt "${GITTED_GIT_MIN_MINOR}" ]; }; then
    gitted_sanity_fail "Git version ${gitted_git_version_raw} is too old; gitted requires Git ${GITTED_GIT_MIN_MAJOR}.${GITTED_GIT_MIN_MINOR}.0 or higher"
fi

if ! "${GIT_BIN}" rev-parse --git-dir > /dev/null 2>&1; then
    gitted_sanity_fail "Oops, this is not a Git repository"
fi

root=$("${GIT_BIN}" rev-parse --show-toplevel)
cd "${root}"
