# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

"""MCP server exposing the four gitted commands as tools."""

import shutil
import subprocess
from pathlib import Path
from typing import Any, Optional


def _scripts_dir() -> Path:
    return Path(__file__).resolve().parent.parent.parent / "scripts"


def _resolve(name: str) -> str:
    on_path = shutil.which(name)
    if on_path:
        return on_path
    local = _scripts_dir() / name
    if local.exists():
        return str(local)
    raise FileNotFoundError(
        f"Cannot find '{name}' on PATH or in {_scripts_dir()}"
    )


def _run(name: str, *args: str, cwd: Optional[str] = None) -> str:
    cmd = [_resolve(name), *[a for a in args if a]]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        cwd=cwd,
        check=False,
    )
    output = (result.stdout or "") + (result.stderr or "")
    if result.returncode != 0:
        raise RuntimeError(
            f"{name} exited {result.returncode}: {output}"
        )
    return output


def build_server() -> Any:
    """Build the FastMCP server and register the four tools."""
    from mcp.server.fastmcp import FastMCP
    server = FastMCP("gitted")

    @server.tool()
    def branch(name: str, cwd: Optional[str] = None) -> str:
        """Create a branch named after the given GitHub issue number."""
        return _run("branch", name, cwd=cwd)

    @server.tool()
    def commit(message: str = "", cwd: Optional[str] = None) -> str:
        """Add and commit pending changes with the given message."""
        return _run("commit", message, cwd=cwd)

    @server.tool()
    def pull(cwd: Optional[str] = None) -> str:
        """Pull from origin and merge master from upstream when present."""
        return _run("pull", cwd=cwd)

    @server.tool()
    def push(message: str = "", cwd: Optional[str] = None) -> str:
        """Commit pending changes and push the branch to origin."""
        return _run("push", message, cwd=cwd)

    return server


def main() -> None:
    """Entry point for the `gitted-mcp` console script."""
    build_server().run()


if __name__ == "__main__":
    main()
