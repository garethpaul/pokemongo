# Unity Project Permission Validation

Status: Completed

## Context

The tutorial asset check already rejects executable screenshots and archived
media files, but Unity project metadata, scene files, material files, and Unity
script files could still gain executable bits without failing the offline gate.
Those files are data or source inputs, not runnable scripts in this repository.

## Objectives

- Reject executable bits on checked-in Unity scenes, project settings, material
  files, source files, and `.meta` files.
- Keep validation offline and dependency-free in `scripts/check-tutorial-assets.rb`.
- Add a static `make build` target for the Unity-free tutorial validation gate.
- Document the guard in README, VISION, SECURITY, and CHANGES.

## Work Completed

- Extended `scripts/check-tutorial-assets.rb` to scan Unity project files,
  metadata, materials, C# files, and UnityScript files for executable bits.
- Added the new canonical docs plan to the validator's required plan coverage.
- Added `make build` as a static tutorial validation alias and wired `verify`
  through lint, test, and build.
- Updated project documentation and maintenance notes for the new permission
  guard.

## Verification

- Temp-copy red check with executable `ProjectSettings.asset`.
- Red `make build` before adding the target.
- `ruby -c scripts/check-tutorial-assets.rb`
- `scripts/check-tutorial-assets.rb`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
