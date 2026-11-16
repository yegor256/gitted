# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import re
from pathlib import Path


def test_workflow_actions_use_stable_versions():
    workflows = Path(__file__).parent.parent / '.github' / 'workflows'
    for workflow in workflows.iterdir():
        if workflow.suffix not in {'.yml', '.yaml'}:
            continue
        for action in re.findall(
            r'^\s*(?:-\s*)?uses:\s*([^\s#]+)',
            workflow.read_text(), re.MULTILINE
        ):
            action = action.strip('\"\'')
            if action.startswith(('./', 'docker://')):
                continue
            reference = action.rsplit('@', 1)[-1]
            assert re.fullmatch(
                r'(?:v?\d+(?:\.\d+){0,2}|[0-9a-f]{40})', reference
            ), f'{workflow.name}: {action} must use a version tag or SHA'
