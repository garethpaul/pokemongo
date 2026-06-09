# Asset Permission Validation

Status: Completed

## Context

Screenshot files already had a permission guard, but the tutorial archive also
contains Blender, Unity package, FBX, and texture assets. Those media/archive
files should not carry executable bits because they are opened by authoring
tools, not run as scripts.

## Objectives

- Remove the executable bit from the checked-in `002_characters/Pikachu.blend`
  asset.
- Extend the tutorial asset checker to reject executable Blender, Unity package,
  FBX, and texture files.
- Preserve the existing screenshot permission guard.
- Document the broader archived asset permission rule.

## Verification

- `scripts/check-tutorial-assets.rb`
- `make lint`
- `make test`
- `make verify`
- `make check`
- `git diff --check`
