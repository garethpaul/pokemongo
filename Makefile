.PHONY: check lint test build verify

check: verify

lint:
	scripts/check-tutorial-assets.rb

test: lint

build: lint

verify: lint test build
