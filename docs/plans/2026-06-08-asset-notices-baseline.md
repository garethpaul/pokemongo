# Asset Notices Baseline

## Status: Completed

## Context

`pokemongo` is a fan-made tutorial archive with Unity scenes, Blender files,
screenshots, and a Unity package that reference well-known game, AR, and map
concepts. The existing validation gate covered tutorial files and toolchain
assumptions, but there was no canonical `docs/plans` record and no maintained
asset-notice surface for reuse and non-affiliation assumptions.

## Objectives

- Add a completed engineering plan under `docs/plans`.
- Add an `ASSET_NOTICES.md` surface for fan-project, ownership, and reuse notes.
- Extend `make check` so asset-notice coverage is validated without Unity,
  Blender, Xcode, or AR SDK installs.
- Keep the existing tutorial artifact and toolchain matrix checks intact.

## Work Completed

- Added `ASSET_NOTICES.md` with tutorial-by-tutorial asset surfaces and
  maintenance rules.
- Added `docs/plans/2026-06-08-asset-notices-baseline.md`.
- Extended `scripts/check-tutorial-assets.rb` to require asset-notice rows,
  fan-project/non-affiliation terms, and the completed canonical plan.
- Updated README, TOOLCHAIN, VISION, and CHANGES documentation.

## Verification

- `make check`
- `make verify`
- `scripts/check-tutorial-assets.rb`
- `git diff --check`

## Follow-Up Candidates

- Replace placeholder or third-party character assets with clearly owned
  tutorial assets.
- Add per-tutorial asset-origin notes when future edits touch specific files.
