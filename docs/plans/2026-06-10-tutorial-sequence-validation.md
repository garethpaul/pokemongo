# Tutorial Sequence Validation

Status: Completed

## Context

The tutorial asset checker discovered numbered tutorial directories dynamically,
but it did not verify that the archive sequence stayed contiguous or that each
discovered tutorial remained visible in the top-level README. A skipped number
or undocumented tutorial directory could make the preserved tutorial flow harder
to follow.

## Objectives

- Validate that tutorial directory IDs are contiguous from `001`.
- Validate that each discovered tutorial directory is listed in the top-level
  README.
- Keep the validation dependency-free in `scripts/check-tutorial-assets.rb`.
- Document the guard in README, SECURITY, VISION, and CHANGES.

## Work Completed

- Added tutorial sequence validation to the Ruby tutorial asset checker.
- Added top-level README coverage checks for every discovered tutorial
  directory.
- Recorded the completed validation guard under `docs/plans/`.

## Verification

- `scripts/check-tutorial-assets.rb`
- `make check`
- `make verify`
- `git diff --check`
