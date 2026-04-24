#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

tmp=$(pwd)
base=$(realpath "$(dirname "$0")/..")

rm -rf remote_repo
git init --bare remote_repo --initial-branch=master

rm -rf seed
git clone "file://${tmp}/remote_repo" seed
cd seed || exit 1
git config user.email "seed@zerocracy.com"
git config user.name "Seed Lebowski"
echo 'seed' > seed.txt
git add seed.txt
git commit --no-verify -m "seed-commit"
git push origin master
cd .. || exit 1

rm -rf racer
git clone "file://${tmp}/remote_repo" racer
cd racer || exit 1
git config user.email "alice@zerocracy.com"
git config user.name "Alice Lebowski"
echo 'alice' > alice.txt
git add alice.txt
git commit --no-verify -m "fake-alice-msg"
cd .. || exit 1

rm -rf local_b
git clone "file://${tmp}/remote_repo" local_b
cd local_b || exit 1
git config user.email "bob@zerocracy.com"
git config user.name "Bob Lebowski"
# Install a pre-push hook that lets Alice race ahead on first push
# attempt only, so that Bob's first push is rejected with "fetch first".
export RACER_DIR="${tmp}/racer"
cat > .git/hooks/pre-push <<'HOOK'
#!/bin/bash
set -e
marker="$(git rev-parse --git-dir)/race-triggered"
if [ ! -e "${marker}" ]; then
    touch "${marker}"
    (cd "${RACER_DIR}" && git push origin master) >&2
fi
exit 0
HOOK
chmod +x .git/hooks/pre-push
echo 'bob' > bob.txt

env "GITTED_TESTING=true" "RACER_DIR=${RACER_DIR}" \
    "${base}/scripts/push" fake-bob-msg 2>&1 | tee "${tmp}/log.txt"
cd .. || exit 1

cd local_b || exit 1
git log | grep 'fake-bob-msg'
git log | grep 'fake-alice-msg'
cd .. || exit 1

cd remote_repo || exit 1
git log master | grep 'fake-bob-msg'
git log master | grep 'fake-alice-msg'
