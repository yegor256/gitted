# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

.ONESHELL:
.PHONY: clean test all pytest ruff flake8 mypy
SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c

PYS = $(wildcard src/**.py)
TESTS = $(subst tests.sh/,,$(wildcard tests.sh/*.sh))
RESULTS = $(addprefix target/logs/,$(addsuffix .txt,$(TESTS)))
SCRIPTS = $(wildcard scripts/*)

export

all: ruff flake8 mypy pytest test

ruff: $(PYS)
	uv --color=never run ruff check src/ tests/

flake8: $(PYS)
	uv --color=never run flake8 src/ tests/

mypy: $(PYS)
	uv --color=never run mypy src/ tests/

pytest: $(PYS)
	uv --color=never run pytest tests/ -v --cov=src/gitted --cov-report=term-missing --color=no

test: $(RESULTS) $(PYS)

.SILENT:
target/logs/%.txt: tests.sh/% $(SCRIPTS) makes/one-test.sh
	./makes/one-test.sh "$<" "target/log.txt"
	mkdir -p "$$(dirname "$@")"
	cp target/log.txt "$@"

clean:
	rm -rf target
