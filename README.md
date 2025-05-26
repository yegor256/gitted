# A Few Extra Git Commands

[![DevOps By Rultor.com](https://www.rultor.com/b/yegor256/gitted)](https://www.rultor.com/p/yegor256/gitted)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/gitted/actions/workflows/uv.yml/badge.svg)](https://github.com/yegor256/gitted/actions/workflows/uv.yml)
[![PDD status](https://www.0pdd.com/svg?name=yegor256/gitted)](https://www.0pdd.com/p?name=yegor256/gitted)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/gitted)](https://hitsofcode.com/view/github/yegor256/gitted)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/gitted/blob/master/LICENSE.txt)

First, install [Python3], [Git], [pip], [gh], and [Bash]. Then:

```bash
pip install gitted
```

Then, in order to make a contribution to a GitHub repo, assuming
you've a made a fork already and cloned it:

```bash
# Start a branch, to resolve issue #42:
branch 42
# Write some code and then add+commit+push it:
push
# Pull recent changes from the main branch:
pull
# Finish working with the branch and get back to the main:
finish
```

Don't forget to define `OPENAI_API_KEY` environment variable with the
[OpenAI key].

## How to Contribute

Install `uv` and then run:

```bash
uv build
```

Should build.
If it doesn't, submit a bug report.

[Python3]: https://www.python.org/
[Git]: https://git-scm.com/
[pip]: mhttps://pypi.org/project/pip/
[gh]: https://github.com/cli/cli#installation
[Bash]: https://www.gnu.org/software/bash/
[OpenAI key]: https://platform.openai.com/api-keys
