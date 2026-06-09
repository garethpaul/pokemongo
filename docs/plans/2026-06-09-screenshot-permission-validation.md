# Screenshot Permission Validation

Status: Completed

## Context

The tutorial archive keeps screenshots as checked-in evidence for each numbered
tutorial. One screenshot was stored with executable bits even though it is an
image asset, which can confuse asset reviews and make archived media look like
runnable project tooling.

## Objectives

- Reject executable permissions on files under `screenshots/`.
- Remove the executable bit from `screenshots/004/001.jpg`.
- Keep the validation dependency-free and Unity-free.
- Document the permission guard in README, VISION, SECURITY, and CHANGES.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` to fail when screenshot files have
  any executable bit set.
- Normalized `screenshots/004/001.jpg` to non-executable file permissions.
- Added this completed plan under `docs/plans/`.

## Verification

- `scripts/check-tutorial-assets.rb`
- `make check`
- `make verify`
- `git diff --check`
