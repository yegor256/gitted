# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import os
from openai import OpenAI


def generate_commit_message(diff, msg=''):
    if not diff.strip():
        return 'No changes'
    if os.environ.get('GITTED_TESTING'):
        return msg
    client = OpenAI()
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
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=100,
        temperature=0.7
    )
    result = response.choices[0].message.content.strip()
    return result
