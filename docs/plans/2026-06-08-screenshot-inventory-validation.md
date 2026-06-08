# Screenshot Inventory Validation

## Status: Completed

## Context

`pokemongo` preserves tutorial screenshots alongside Unity, Blender, AR, and map
assets. The existing validation gate checked that referenced README image files
exist, but it did not fail when a checked-in per-tutorial screenshot stopped
being referenced by its tutorial README.

## Objectives

- Keep validation dependency-free and independent of Unity, Blender, Xcode, or
  AR SDK installs.
- Require each checked-in screenshot under `screenshots/<tutorial-id>/` to be
  referenced by the matching numbered tutorial README.
- Keep the existing asset, toolchain, asset-notice, and canonical plan checks
  intact.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` to compare each tutorial README's
  local image references with the matching `screenshots/<tutorial-id>/` files.
- Added this completed plan under `docs/plans/`.
- Updated README, vision, and changelog notes for screenshot inventory coverage.

## Verification

- `make check`
- `make verify`
- `scripts/check-tutorial-assets.rb`
- `git diff --check`
