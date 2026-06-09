# Tutorial README Setup Validation

Status: Completed

## Context

The top-level toolchain matrix documents Unity, Blender, Kudan, camera,
location, and package assumptions, but tutorial READMEs are the files readers
open while following each lesson. If those local READMEs omit setup or
permission-sensitive terms, readers must infer critical steps from elsewhere.

## Objectives

- Keep validation dependency-free using Ruby's standard library.
- Require each tutorial README to name its critical setup files, SDKs, packages,
  or permission-sensitive assumptions.
- Make Blender asset filenames explicit in the character tutorial.
- Make Kudan camera assumptions explicit in the AR tutorial.
- Make the map package and location assumptions explicit in the slippy-map
  tutorial.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` with tutorial README setup-term
  validation.
- Updated tutorial-local README steps for Blender assets, Kudan camera access,
  and `PokemonMap.unitypackage` location behavior.
- Updated README, VISION, SECURITY, and CHANGES notes for the setup guard.

## Verification

- `ruby -c scripts/check-tutorial-assets.rb`
- `scripts/check-tutorial-assets.rb`
- `make check`
- `make verify`
- `git diff --check`
