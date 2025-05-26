#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

diff=$(git diff HEAD | head -2000)

prompt="
You are a programmer who cares about the quality of commit messages in his repository.
You know how to write COMPACT and INFORMATIVE commit messages.
Now, study the changes made to a repository recently and suggest a good commit message.
I show you the changes as they are printed by 'git diff':

\`\`\`
${diff}
\`\`\`
"

if [ -n "${msg}" ]; then
  prompt="${prompt}

By the way, this is the commit message provided by the programmer: \"${msg}\".
You can use this text as the source of inspiration."
fi

prompt="${prompt}

Return back just the commit message.
No additional explanations or meta information.
Just return one-sentence commit message, without quotation marks around.
Try to make it as short as possible, ideally under 80 characters.
Don't even finish it with a dot, just give me a single sentence."

echo "${prompt}" | openai complete - | head -1
