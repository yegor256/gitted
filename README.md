# Git Autopilot for a Primitive Git Flow

[![DevOps By Rultor.com](https://www.rultor.com/b/yegor256/gitted)](https://www.rultor.com/p/yegor256/gitted)

[![make](https://github.com/yegor256/gitted/actions/workflows/make.yml/badge.svg)](https://github.com/yegor256/gitted/actions/workflows/make.yml)
[![PDD status](https://www.0pdd.com/svg?name=yegor256/gitted)](https://www.0pdd.com/p?name=yegor256/gitted)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/gitted)](https://hitsofcode.com/view/github/yegor256/gitted)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/gitted/blob/master/LICENSE.txt)

If all you need to do with Git is making branches, pushing, and syncing,
  this collection of command-line commands may simplify your workflow.
Well, it simplifies mine, a [hundred](https://github.com/yegor256)
  times per day.

First, install [Python3], [Git], [pip], [gh], and [Bash]. Then:

```bash
pip install gitted
```

Then, in order to make a contribution to a GitHub repo, assuming
  you've a made a [fork] already and cloned it (in the command line):

1. Start a branch, to resolve issue no. 42 (for example):

  ```bash
  branch 42
  ```

1. Write some code and then add+commit it (no push):

  ```bash
  commit
  ```

1. Write some code and then add+commit+push it:

  ```bash
  push
  ```

1. Pull recent changes from the `master` of the upstream:

  ```bash
  pull
  ```

Don't forget to define `OPENAI_API_KEY` environment variable with the
[OpenAI key].
Also, don't forget to authenticate with `gh auth`.

## Conventions

In order to work smoothly, you have to respect a few conventions:

* Branch names are always integers, equal to GitHub issue numbers
* The main branch is `master`
* All commits are GPG-signed ([how?][gpg])
* The `origin` is the fork, while the `upstream` is the main repo ([why?][fork])

Maybe in future versions we make it configurable.
However, at the moment, that's what we have.

## How to Contribute

Install [GNU make] and [uv]. Then, run:

```bash
make
```

Should build.
If it doesn't, submit a bug report.

[GNU make]: https://www.gnu.org/software/make/
[uv]: https://github.com/astral-sh/uv
[Python3]: https://www.python.org/
[Git]: https://git-scm.com/
[pip]: https://pypi.org/project/pip/
[gh]: https://github.com/cli/cli#installation
[Bash]: https://www.gnu.org/software/bash/
[OpenAI key]: https://platform.openai.com/api-keys
[fork]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/configuring-a-remote-repository-for-a-fork
[gpg]: https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits
[fork]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo
