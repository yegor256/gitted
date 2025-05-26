# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

.ONESHELL:
.PHONY: clean test all
.SHELLFLAGS := -e -o pipefail -c

TESTS = $(subst tests.sh/,,$(wildcard tests.sh/*.sh))
RESULTS = $(addprefix target/,$(addsuffix .rt,$(TESTS)))

all: test

test: $(RESULTS)

target/%.rt: tests.sh/% | target
	bash -c "$<"
	echo "$?" > "$@"

target:
	mkdir -p "$@"

clean:
	rm -rf target
