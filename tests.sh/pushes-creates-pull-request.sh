#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")
real_git=$(command -v git)

rm -rf bin upstream_repo remote_repo local_repo gh.log log.txt
mkdir -p bin
cat > bin/git <<GIT
#!/bin/bash
if [ "\$1" = "remote" ] && [ "\$2" = "get-url" ] && [ "\$3" = "origin" ]; then
    echo "git@github.com:forker/gitted.git"
    exit 0
fi
if [ "\$1" = "remote" ] && [ "\$2" = "get-url" ] && [ "\$3" = "upstream" ]; then
    echo "https://github.com/yegor256/gitted.git"
    exit 0
fi
exec "${real_git}" "\$@"
GIT
chmod +x bin/git

cat > bin/gh <<'GH'
#!/bin/bash
printf '%s\n' "$*" >> "${GH_LOG}"
if [ "$1" = "pr" ] && [ "$2" = "list" ]; then
    echo 0
    exit 0
fi
if [ "$1" = "pr" ] && [ "$2" = "create" ]; then
    exit 0
fi
exit 1
GH
chmod +x bin/gh

git init upstream_repo --initial-branch=master
cd upstream_repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
touch readme.txt
git add readme.txt
git commit --no-verify -m init
cd .. || exit 1

git init --bare remote_repo --initial-branch=master
git clone "file://${tmp}/remote_repo" local_repo
cd local_repo || exit 1
git config user.email "jeff@zerocracy.com"
git config user.name "Jeff Lebowski"
git remote add upstream "file://${tmp}/upstream_repo"
git pull upstream master
git checkout -b 46
echo 'abc' > hello.txt

env "GITTED_TESTING=true" "PATH=${tmp}/bin:${PATH}" "GIT_BIN=${tmp}/bin/git" "GH_LOG=${tmp}/gh.log" \
    "${base}/scripts/push" fake-message 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

grep 'pr list --repo yegor256/gitted --head forker:46 --state open --json number --jq length' "${tmp}/gh.log"
grep 'pr create --repo yegor256/gitted --head forker:46 --fill' "${tmp}/gh.log"
