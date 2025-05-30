# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

from setuptools import setup, find_packages

setup(
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    scripts=[
        "scripts/branch",
        "scripts/commit",
        "scripts/pull",
        "scripts/push"
    ],
)
