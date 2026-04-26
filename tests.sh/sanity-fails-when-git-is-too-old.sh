#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf repo stubs
git init repo --initial-branch=master
cd repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
touch initial.txt
git add initial.txt
git commit --no-verify -am "initial commit"
cd .. || exit 1

mkdir stubs
cat > stubs/git <<'EOF'
#!/bin/bash
if [ "$1" = "--version" ]; then
    echo "git version 1.5.0"
    exit 0
fi
exec /usr/bin/env -i PATH="${ORIG_PATH}" git "$@"
EOF
chmod +x stubs/git

cd repo || exit 1
exit_code=0
env "GITTED_TESTING=true" \
    "ORIG_PATH=${PATH}" \
    "PATH=${tmp}/stubs:${PATH}" \
    "${base}/scripts/branch" "1" 2>&1 | tee "${tmp}/log.txt" || exit_code=$?

test "${exit_code}" = 1
grep -q 'too old' "${tmp}/log.txt"
grep -q '1.5.0' "${tmp}/log.txt"
