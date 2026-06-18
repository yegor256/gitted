#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf there
git init --bare there --initial-branch=master

rm -rf seed
git clone "file://${tmp}/there" seed
cd seed || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
touch hello.txt
git add hello.txt
git commit --no-verify -am init
git push origin master
cd .. || exit 1

cat > there/hooks/pre-receive <<'HOOK'
#!/bin/sh
echo "pre-receive hook rejects push" >&2
exit 1
HOOK
chmod +x there/hooks/pre-receive

rm -rf here
git clone "file://${tmp}/there" here
cd here || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"

exit_code=0
env "GITTED_TESTING=true" \
    "${base}/scripts/branch" 42 2>&1 | tee "${tmp}/log.txt" || exit_code=$?

test "${exit_code}" = 1
grep -q "Pushing to the origin/42 branch" "${tmp}/log.txt"
