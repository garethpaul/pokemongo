.PHONY: check lint test verify

check: verify

lint:
	scripts/check-tutorial-assets.rb

test: lint

verify: lint
