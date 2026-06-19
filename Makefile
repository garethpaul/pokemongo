.PHONY: check compile lint test build verify

override REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DOTNET ?= dotnet

check: compile verify

compile:
	@if command -v "$(DOTNET)" >/dev/null 2>&1; then \
		DOTNET="$(DOTNET)" "$(REPO_ROOT)/scripts/compile-hit-object.sh"; \
	else \
		echo "dotnet unavailable; archived C# compiler gate skipped"; \
	fi

lint:
	cd "$(REPO_ROOT)" && scripts/check-tutorial-assets.rb

test: lint
	cd "$(REPO_ROOT)" && scripts/test-tutorial-assets.sh

build: compile lint

verify: lint test build
