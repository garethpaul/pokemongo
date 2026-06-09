# Tutorial Image Alt Validation

Status: Completed

## Context

Tutorial READMEs use HTML image tags for screenshots. The existing validation
already keeps screenshot files present, referenced, and sized, but it did not
require alternate text for readers using non-visual or plain-text tools.

## Objectives

- Keep validation dependency-free in `scripts/check-tutorial-assets.rb`.
- Require every tutorial README screenshot image tag to include quoted,
  non-empty `alt` text.
- Add meaningful alt text to the checked-in tutorial screenshots.
- Document the new guard in README, VISION, and CHANGES.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` to reject image tags missing a
  quoted, non-empty `alt` attribute.
- Added the new canonical docs plan to the validator's required plan coverage.
- Updated all tutorial README screenshot image tags with descriptive alt text.
- Updated top-level maintenance documentation for the new accessibility guard.

## Verification

- `ruby -c scripts/check-tutorial-assets.rb`
- `scripts/check-tutorial-assets.rb`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
