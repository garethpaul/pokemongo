.PHONY: check lint test build verify

check: verify

lint:
	scripts/check-tutorial-assets.rb

test: lint
	scripts/test-tutorial-assets.sh

build: lint

verify: lint test build
