# Changes

## 2026-06-08

- Added per-tutorial screenshot inventory validation so checked-in screenshots
  under `screenshots/<tutorial-id>/` stay referenced by tutorial READMEs.
- Added loose screenshot inventory validation so standalone files like
  `screenshots/001.jpg` stay documented in top-level notices.
- Added screenshot permission validation so archived image files cannot keep
  executable bits.
- Added tutorial README setup validation so critical SDK, package, camera, and
  location assumptions stay visible in the tutorial-local docs.
- Added archived asset permission validation so Blender, Unity package, FBX,
  and texture files cannot keep executable bits.
- Added Unity scene-name validation so tutorial READMEs must mention the
  checked-in `.unity` scene files they ask readers to open.
- Added Unity editor-version validation so `TOOLCHAIN.md` must match checked-in
  `ProjectVersion.txt` metadata.
- Added `TOOLCHAIN.md` and validation coverage for Unity, Blender, Kudan,
  camera, location, and map package assumptions across the tutorial sequence.
- Added `make check` as an alias for the existing tutorial asset verification gate.
- Added a Ruby tutorial inventory check for README screenshot links and expected Unity, Blender, and Unity package artifacts.
- Added `make verify` as a Unity-free local validation gate.
- Fixed the malformed screenshot width attribute in `002_characters/README.md`.
- Added canonical `docs/plans` coverage and `ASSET_NOTICES.md` validation for
  fan-project asset, trademark, and reuse assumptions.
