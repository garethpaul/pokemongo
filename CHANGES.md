# Changes

## 2026-06-12

- Added dependency-free TGA header and pixel-payload integrity checks with
  isolated malformed-header and truncated-payload mutations.
- Added dependency-free signature checks and corruption mutations for PNG/JPEG
  screenshots, Blender projects, binary FBX models, and Unity packages.

## 2026-06-10

- Added hosted Unity-free tutorial validation with read-only permissions and a
  pinned checkout action.
- Disabled hosted checkout credential persistence, added CODEOWNERS, and made
  the validator reject extra workflows or write permissions.
- Extended hosted validation to every pushed branch so remediation commits are
  checked before a pull request is opened.
- Anchored recursive asset validation to the repository so invocation from
  another directory cannot scan unrelated files.
- Added tutorial sequence validation so numbered tutorial directories must stay
  contiguous from `001` and listed in the top-level README.
- Restored stable Unity metadata for the augmented-reality scene and added
  asset-to-`.meta` pairing validation across checked-in Unity projects.

## 2026-06-09

- Added tutorial screenshot alt-text validation for README image tags.
- Added Unity project file permission validation so scenes, settings,
  materials, source files, and `.meta` files cannot keep executable bits.
- Added a static `make build` gate for Unity-free tutorial validation.

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
