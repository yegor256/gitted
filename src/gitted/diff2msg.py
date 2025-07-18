# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import os
import re
from openai import OpenAI


def is_summarizable_chunk(chunk: str) -> bool:
    """
    Checks if diff chunk should be included in prompt. Skips binary files and
    .svg files.

    Args:
        chunk: Git diff chunk starting with "diff --git a/... b/..."

    Returns:
        True if chunk should be summarized, False otherwise.

    Raises:
        ValueError: If chunk has invalid git diff header format.
    """
    if re.search(r'Binary files (.+) and (.+) differ', chunk, re.IGNORECASE):
        return False
    header = chunk.split('\n', 1)[0]
    filenames = re.search(r'a/(.+) b/(.+)', header)
    if not filenames:
        raise ValueError(
            "Invalid diff chunk format: " +
            f"expected 'diff --git a/... b/...', but got: '{header}'"
        )
    filepath = filenames.group(2)
    _, extension = os.path.splitext(filepath)
    skip_extensions = {'.svg'}
    if extension in skip_extensions:
        return False
    return True


def prepare_diff(diff: str) -> str:
    """
    Filters chunks and truncates diff to avoid token limits.

    Returns:
        Filtered diff, truncated at 2000 chars if needed.
    """
    chunks = ("\n" + diff).split("\ndiff --git ")[1:]
    chunks = ['diff --git ' + c for c in chunks]
    chunks = [c for c in chunks if is_summarizable_chunk(c)]
    diff = "\n".join(chunks)
    if len(diff) > 2000:
        return diff[:2000] + "\n\n[... diff truncated ...]"
    return diff


def prepare_prompt(diff: str, msg: str) -> str:
    """
    Creates prompt for commit message generation.

    Args:
        diff: Git diff content
        msg: Existing message for inspiration

    Returns:
        Complete prompt string.
    """
    prompt = f"""
You are a programmer who cares about the quality of commit messages
in his repository.
You know how to write COMPACT and INFORMATIVE commit messages.
Now, study the changes made to a repository recently and suggest a good
commit message.
Let me show you the changes as they are printed by 'git diff':

```
{diff}
```
"""
    if msg:
        prompt += f"""

By the way, this is the commit message provided by the programmer: "{msg}".
You can use this text as the source of inspiration.
"""
    prompt += """

Return back just the commit message.
No additional explanations or meta information.
Just return one-sentence commit message, without quotation marks around.
Try to make it as short as possible, ideally under 80 characters.
Don't even finish it with a dot, just give me a single sentence.
"""
    return prompt


def generate_commit_message(diff, msg=''):
    diff = prepare_diff(diff)
    if not diff.strip():
        return 'No changes'
    if os.environ.get('GITTED_TESTING'):
        return msg
    prompt = prepare_prompt(diff, msg)
    client = OpenAI()
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=100,
        temperature=0.7
    )
    result = response.choices[0].message.content.strip()
    return result
