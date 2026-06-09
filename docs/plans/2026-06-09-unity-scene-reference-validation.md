# Unity Scene Reference Validation

Status: Completed

## Context

The collision tutorial README told readers to open `PokemonThrows`, but the
checked-in scene is `PokemonThrow.unity`. The asset checker already verified the
scene file existed, but it did not verify that tutorial instructions named the
actual scene file.

## Objectives

- Add deterministic validation for Unity scene filenames in tutorial READMEs.
- Correct the collision tutorial to reference `PokemonThrow.unity`.
- Preserve Unity-free local verification through the existing Ruby checker.
- Document the new validation guard in README, VISION, and CHANGES.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` to require Unity tutorial READMEs
  to mention their checked-in scene filenames.
- Updated `001_collisions/README.md` to point to `PokemonThrow.unity`.
- Added this completed canonical plan under `docs/plans/`.

## Verification

- `scripts/check-tutorial-assets.rb`
- `make check`
- `make verify`
- `git diff --check`
