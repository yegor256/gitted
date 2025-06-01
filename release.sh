#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

# This script is called by RULTOR from .rultor.yml

tag=$1
token=$2

base=$(dirname "$0")

if ! [[ "${tag}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo 'The tag must be in SemVer'
    exit 1
fi

versioned=(
    "${base}/pyproject.toml"
    "${base}/src/gitted/__init__.py"
    "${base}/sub-scripts/intro.sh"
)
for f in "${versioned[@]}"; do
    sed -i "s/0\.0\.0/${tag}/g" "${f}"
    git add "${f}"
done
git commit --no-verify -m "version set to ${tag}"

while IFS= read -r f; do
    n=$(basename "${f}")
    n=${n%.*}
    printf '%s=%s(cat << EOT\n%s\nEOT\n)\n\n%s' "help_${n}" "\$" "$(cat "${f}")" "$(cat "${base}/sub-scripts/intro.sh")" > "${base}/sub-scripts/intro.sh"
done < <(find help -type f -name '*.txt')
git add "${base}/sub-scripts/intro.sh"
git commit --no-verify -m "help messages moved into the intro.sh"

pip install --progress-bar=off uv
GITTED_BATCH=true GITTED_TESTING=true make -e

while IFS= read -r f; do
    temp=$(mktemp)
    while IFS= read -r line; do
        if [[ "${line}" =~ all\.sh ]]; then
            while IFS= read -r sub; do
                echo "# Imported from $(basename "${sub}") when releasing:"
                cat "${sub}"
            done < <(find "${base}/sub-scripts/" -type f -name '*.sh' -not -name 'all.sh')
        else
            echo "${line}"
        fi
    done < "${f}" > "${temp}"
    mv "${temp}" "${f}"
    chmod a+x "${f}"
done < <(find "${base}/scripts" -type f)

uv --color=never build --no-build-logs
if [ -n "${token}" ]; then
    uv --color=never run python -m twine upload dist/* -u __token__ -p "${token}"
else
    echo "The token is not provided, can't release"
    exit 1
fi
