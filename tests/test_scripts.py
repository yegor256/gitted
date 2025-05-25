# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import subprocess
import os
import sys
import pytest
from pathlib import Path

def script_path(name):
    return Path(__file__).parent.parent / "scripts" / name

def run_script(script_name, args=None, cwd=None):
    script = str(script_path(script_name))
    if sys.platform == "win32":
        cmd = ["bash", script]
    else:
        cmd = [script]
    if args:
        cmd.extend(args)
    return subprocess.run(cmd, capture_output=True, text=True, cwd=cwd, shell=(sys.platform == "win32"))

def test_scripts_exist():
    for script in ["push", "pull", "branch"]:
        path = script_path(script)
        assert path.exists(), f"Script {script} does not exist"
        if sys.platform != "win32":
            assert os.access(path, os.X_OK), f"Script {script} is not executable"

def test_scripts_have_shebang():
    for script in ["push", "pull", "branch"]:
        path = script_path(script)
        with open(path, 'r') as f:
            first_line = f.readline().strip()
            assert first_line == "#!/usr/bin/env bash", f"Script {script} missing proper shebang"

def test_push_script_help():
    result = run_script("push", ["--help"])
    assert result.returncode != 0 or "push" in result.stdout.lower() or "push" in result.stderr.lower()

def test_pull_script_help():
    result = run_script("pull", ["--help"])
    assert result.returncode != 0 or "pull" in result.stdout.lower() or "pull" in result.stderr.lower()

def test_branch_script_no_args():
    import tempfile
    with tempfile.TemporaryDirectory() as tmpdir:
        result = run_script("branch", cwd=tmpdir)
        assert result.returncode != 0
