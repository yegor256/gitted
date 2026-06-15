# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import subprocess
from unittest import mock

import pytest

from gitted import mcp_server


def test_resolve_prefers_path_executable(tmp_path):
    fake = tmp_path / "branch"
    fake.write_text("#!/bin/sh\n")
    fake.chmod(0o755)
    with mock.patch("shutil.which", return_value=str(fake)):
        assert mcp_server._resolve("branch") == str(fake)


def test_resolve_falls_back_to_local_scripts():
    with mock.patch("shutil.which", return_value=None):
        resolved = mcp_server._resolve("branch")
    assert resolved.endswith("scripts/branch")


def test_resolve_raises_when_missing(tmp_path):
    with mock.patch("shutil.which", return_value=None), \
         mock.patch.object(
             mcp_server, "_scripts_dir", return_value=tmp_path
         ):
        with pytest.raises(FileNotFoundError):
            mcp_server._resolve("absent")


def test_run_returns_combined_output(tmp_path):
    completed = subprocess.CompletedProcess(
        args=[], returncode=0, stdout="out\n", stderr="err\n"
    )
    with mock.patch.object(
        mcp_server, "_resolve", return_value="/bin/true"
    ), mock.patch("subprocess.run", return_value=completed) as runner:
        result = mcp_server._run("pull", cwd=str(tmp_path))
    assert result == "out\nerr\n"
    runner.assert_called_once()
    assert runner.call_args.kwargs["cwd"] == str(tmp_path)


def test_run_drops_empty_arguments():
    completed = subprocess.CompletedProcess(
        args=[], returncode=0, stdout="", stderr=""
    )
    with mock.patch.object(
        mcp_server, "_resolve", return_value="/bin/true"
    ), mock.patch("subprocess.run", return_value=completed) as runner:
        mcp_server._run("commit", "")
    assert runner.call_args.args[0] == ["/bin/true"]


def test_run_raises_on_nonzero_exit():
    completed = subprocess.CompletedProcess(
        args=[], returncode=2, stdout="", stderr="boom"
    )
    with mock.patch.object(
        mcp_server, "_resolve", return_value="/bin/true"
    ), mock.patch("subprocess.run", return_value=completed):
        with pytest.raises(RuntimeError, match="commit exited 2"):
            mcp_server._run("commit", "msg")


def test_build_server_registers_four_tools():
    mcp = pytest.importorskip("mcp")
    del mcp
    import asyncio

    server = mcp_server.build_server()
    assert server.name == "gitted"
    tools = asyncio.run(server.list_tools())
    names = {tool.name for tool in tools}
    assert {"branch", "commit", "pull", "push"} <= names
