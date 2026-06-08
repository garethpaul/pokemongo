# Tutorial Toolchain Matrix

This repository is a preservation-oriented tutorial archive. The checks below
do not require Unity, Blender, AR SDKs, or map SDKs to be installed, but the
projects themselves were authored against older tools.

| Tutorial | Checked-in project evidence | Local tools needed | External SDK or package | Permission-sensitive behavior |
| --- | --- | --- | --- | --- |
| 001_collisions | `001_collisions/ProjectSettings/ProjectVersion.txt` records Unity 5.3.5f1 and `Assets/Scenes/PokemonThrow.unity` | Unity 5.3.5f1-compatible editor | Checked-in Pikachu and Pokeball assets | None beyond local game input |
| 002_characters | `002_characters/Pikachu.blend` and `002_characters/Pokeball.blend` | Blender | Export to FBX before importing into Unity | None |
| 003_augmented_reality | `003_augmented_reality/AR Example Pokemon Go/ProjectSettings/ProjectVersion.txt` records Unity 5.4.0f1 and `Assets/Scenes/PokemonScene.unity` | Unity 5.4.0f1-compatible editor and Xcode for iOS builds | Kudan AR SDK from Kudan.eu is referenced by the tutorial | Camera access is expected for AR |
| 004_slippy_maps | `004_slippy_maps/PokemonMap.unitypackage` | Unity editor compatible with the package | `PokemonMap.unitypackage` includes the map plugin assets | Map/location behavior should stay explicit and avoid hidden uploads |

## Maintenance Notes

- Keep this matrix updated when tutorial README setup steps, Unity versions, or
  package assumptions change.
- Keep `ASSET_NOTICES.md` updated when character, model, screenshot, AR, or map
  package assets are added, removed, or replaced.
- Do not commit credentials, device provisioning profiles, or SDK license files.
- Keep camera and location assumptions visible in docs and sample code.
