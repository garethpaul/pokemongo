.PHONY: check lint test build verify

override REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

check: verify

lint:
	cd "$(REPO_ROOT)" && scripts/check-tutorial-assets.rb

test: lint
	cd "$(REPO_ROOT)" && scripts/test-tutorial-assets.sh

build: lint

verify: lint test build
