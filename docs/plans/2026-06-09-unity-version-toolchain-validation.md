# Unity Version Toolchain Validation

Status: Completed

## Context

The tutorial archive includes Unity `ProjectVersion.txt` metadata for the
Unity-backed tutorials. `TOOLCHAIN.md` documents the editor versions humans
should use, but the asset checker only looked for broad version strings instead
of comparing the matrix to the project metadata directly.

## Objectives

- Parse Unity editor versions from checked-in `ProjectVersion.txt` files.
- Require each Unity-backed tutorial's `TOOLCHAIN.md` row to mention its exact
  editor version.
- Preserve Unity-free local verification through the existing Ruby checker.
- Document the new validation guard in README, VISION, TOOLCHAIN, and CHANGES.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` to parse `m_EditorVersion` from
  Unity project metadata.
- Added row-specific validation against `TOOLCHAIN.md`.
- Added this completed canonical plan under `docs/plans/`.

## Verification

- `scripts/check-tutorial-assets.rb`
- `make check`
- `make verify`
- `git diff --check`
