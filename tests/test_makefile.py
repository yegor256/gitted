# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

import subprocess
from pathlib import Path


def test_python_source_prerequisites():
    root = Path(__file__).resolve().parent.parent
    result = subprocess.run(
        ["make", "--no-print-directory", "-f", "Makefile", "-f", "-",
         "print-python-sources"],
        input="print-python-sources:\n\t@echo $(PYS)\n",
        cwd=root, capture_output=True, text=True, check=True,
    )
    expected = sorted(
        path.relative_to(root).as_posix()
        for path in (root / "src").rglob("*.py")
    )
    assert sorted(result.stdout.split()) == expected
