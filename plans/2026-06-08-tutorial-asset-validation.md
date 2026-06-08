# Tutorial Asset Validation

## Status

Completed

## Context

`pokemongo` is a tutorial archive with Unity projects, Blender files,
screenshots, and a Unity package. The repository had no deterministic local
validation command, and one tutorial README had a malformed screenshot image
attribute.

## Objectives

- Add a validation command that does not require Unity or Blender.
- Check that tutorial README screenshot links resolve to checked-in files.
- Check that expected Unity scenes, Blender files, and Unity package artifacts
  remain present.
- Fix the malformed image width attribute in the characters tutorial.
- Provide `make verify` as a single local gate.

## Verification

- `make verify`
- `scripts/check-tutorial-assets.rb`
- `git diff --check`

## Follow-Up Candidates

- Add a top-level matrix of Unity, Blender, AR SDK, and map SDK requirements.
- Record the Unity editor versions needed for each sample.
- Document asset origin and licensing assumptions per tutorial.
