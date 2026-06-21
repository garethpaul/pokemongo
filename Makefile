.PHONY: check compile lint test build root-test verify

override SHELL := /bin/sh
override .SHELLFLAGS := -c

ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must not be set)
endif
override REPO_ROOT := $(shell path='$(subst ','"'"',$(MAKEFILE_LIST))'; path=$$(printf '%s' "$$path" | /usr/bin/sed 's/^ //'); directory=$$(/usr/bin/dirname -- "$$path"); CDPATH= cd -- "$$directory" && /bin/pwd -P)
export REPO_ROOT
DOTNET ?= dotnet
export DOTNET

check: compile verify

compile:
	@if command -v "$$DOTNET" >/dev/null 2>&1; then \
		DOTNET="$$DOTNET" "$$REPO_ROOT/scripts/compile-hit-object.sh"; \
	else \
		echo "dotnet unavailable; archived C# compiler gate skipped"; \
	fi

lint:
	cd "$$REPO_ROOT" && scripts/check-tutorial-assets.rb

test: lint
	cd "$$REPO_ROOT" && scripts/test-tutorial-assets.sh

build: compile lint

root-test:
	cd "$$REPO_ROOT" && scripts/test-makefile-root.sh

verify: lint test build root-test
