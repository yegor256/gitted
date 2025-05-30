# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

.ONESHELL:
.PHONY: clean test all
SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c

TESTS = $(subst tests.sh/,,$(wildcard tests.sh/*.sh))
RESULTS = $(addprefix target/logs/,$(addsuffix .txt,$(TESTS)))
SCRIPTS = $(wildcard scripts/*)

export

all: pytest test

pytest:
	uv --color=never run pytest tests/ -v --cov=src/gitted --cov-report=term-missing

test: $(RESULTS)

.SILENT:
target/logs/%.txt: tests.sh/% $(SCRIPTS) makes/one-test.sh
	./makes/one-test.sh "$<" "$@"

clean:
	rm -rf target
