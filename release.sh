#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

# This script is called by RULTOR from .rultor.yml

tag=$1
token=$2

if ! [[ "${tag}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo 'The tag must be in SemVer'
    exit 1
fi

sed -i "s/0\.0\.0/${tag}/g" pyproject.toml
git add pyproject.toml
sed -i "s/0\.0\.0/${tag}/g" src/gitted/__init__.py
git add src/gitted/__init__.py
sed -i "s/0\.0\.0/${tag}/g" sub-scripts/intro.sh
git add sub-scripts/intro.sh
git commit -m "version set to ${tag}"

pip install --progress-bar=off uv
GITTED_BATCH=true GITTED_TESTING=true make -e

while IFS= read -r f; do
    n=$(basename "${f}")
    n=${n%.*}
    printf '%s=%s(cat << EOT\n%s\nEOT\n)\n\n%s' "help_${n}" "\$" "$(cat "${f}")" "$(cat sub-scripts/intro.sh)" > sub-scripts/intro.sh
done < <(find help -type f -name '*.txt')

while IFS= read -r f; do
    temp=$(mktemp)
    while IFS= read -r line; do
        if [[ "${line}" =~ commons\.sh ]]; then
            cat sub-scripts/commons.sh
        elif [[ "${line}" =~ intro\.sh ]]; then
            cat sub-scripts/intro.sh
        elif [[ "${line}" =~ sanity\.sh ]]; then
            cat sub-scripts/sanity.sh
        else
            echo "${line}"
        fi
    done < "${f}" > "${temp}"
    mv "${temp}" "${f}"
    chmod a+x "${f}"
done < <(find scripts -type f)

uv --color=never build --no-build-logs
uv --color=never run python -m twine upload dist/* -u __token__ -p "${token}"
