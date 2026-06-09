# Loose Screenshot Inventory

## Status: Completed

## Context

The tutorial README checks cover screenshots stored under
`screenshots/<tutorial-id>/`, but the repository also contains
`screenshots/001.jpg` at the top level of the screenshots directory. Standalone
assets like this can become unattributed if they are not listed in top-level
archive notes.

## Goals

- Detect root-level files under `screenshots/`.
- Require every loose screenshot to be documented in `README.md`.
- Require every loose screenshot to be documented in `ASSET_NOTICES.md`.
- Preserve the existing per-tutorial screenshot inventory guard.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` to inventory loose screenshots.
- Documented `screenshots/001.jpg` in the README and asset notices.
- Added this completed plan under `docs/plans/`.

## Verification

- `scripts/check-tutorial-assets.rb`
- `make check`
- `make verify`
- `git diff --check`
