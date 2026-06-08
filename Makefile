.PHONY: lint test verify

lint:
	scripts/check-tutorial-assets.rb

test: lint

verify: lint
