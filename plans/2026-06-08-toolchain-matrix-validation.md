# Toolchain Matrix Validation

## Status

Completed

## Context

The tutorial archive had deterministic asset checks, but setup assumptions were
spread across individual README files. The Unity project versions, Blender
asset requirements, AR SDK requirement, and map package were not summarized in a
single maintenance surface.

## Objectives

- Add a top-level `TOOLCHAIN.md` matrix for the four numbered tutorials.
- Record checked-in Unity editor versions where project files provide them.
- Document Blender, Kudan, map package, camera, and location assumptions.
- Extend the existing Ruby validation gate to require matrix coverage.
- Keep validation independent of Unity, Blender, Xcode, and SDK installs.

## Verification

- `make verify`
- `scripts/check-tutorial-assets.rb`
- `git diff --check`
