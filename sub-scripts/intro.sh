help_pull=$(cat << EOT
Usage: pull

We pull from the upstream branch and then also from the upstream repository.
EOT
)

help_push=$(cat << EOT
Usage: push [<message> | <branch>]

You either provide a commit message or a name of the branch you push to. If the
argument is a single integer, we treat it as a branch name. Everything else
is treated as a plain message.
EOT
)

help_branch=$(cat << EOT
Usage: branch <name>

You either provide a "message" or a name of the branch you push to. If the
argument is a single integer, we treat it as a branch name. Everything else
is treated as a plain message.
EOT
)

help_commit=$(cat << EOT
Usage: commit [<message> | <branch>]

You either provide a commit message or a name of the branch you push to. If the
argument is a single integer, we treat it as a branch name. Everything else
is treated as a plain message.
EOT
)

#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

if [ "$1" = '--help' ]; then
    cmd=$(basename "$0")
    var="help_${cmd}"
    help=${!var}
    if [ -z "${help}" ]; then
        echo "Usage: ${cmd} --help"
    else
        echo "${help}"
    fi
    exit
fi

if [ -z "${GITTED_INTRODUCED}" ]; then
    printf "\e[1mGitted\e[0m 0.0.18 (https://github.com/yegor256/gitted)\n"
    GITTED_INTRODUCED=true
    export GITTED_INTRODUCED
fi