# Tutorial Toolchain Matrix

This repository is a preservation-oriented tutorial archive. The checks below
do not require Unity, Blender, AR SDKs, or map SDKs to be installed, but the
projects themselves were authored against older tools.

The C# compiler gate uses .NET 8 and compile-only UnityEngine stubs to build the
tracked `001_collisions/Assets/Scripts/HitObject.cs`. UnityScript remains manual,
and full project import still requires the historical Unity editor listed below.

| Tutorial | Checked-in project evidence | Local tools needed | External SDK or package | Permission-sensitive behavior |
| --- | --- | --- | --- | --- |
| 001_collisions | `001_collisions/ProjectSettings/ProjectVersion.txt` records Unity 5.3.5f1, `Assets/Scenes/PokemonThrow.unity`, `Pikachu.FBX` records binary FBX 7300, and `pokeball2.fbx` records binary FBX 7400 | Unity 5.3.5f1-compatible editor | Checked-in Pikachu and Pokeball assets | None beyond local game input |
| 002_characters | `002_characters/Pikachu.blend` records Blender 2.72 and `002_characters/Pokeball.blend` records Blender 2.77 | Compatible Blender releases | Export to FBX before importing into Unity | None |
| 003_augmented_reality | `003_augmented_reality/AR Example Pokemon Go/ProjectSettings/ProjectVersion.txt` records Unity 5.4.0f1 and `Assets/Scenes/PokemonScene.unity` | Unity 5.4.0f1-compatible editor and Xcode for iOS builds | Kudan AR SDK from Kudan.eu is referenced by the tutorial | Camera access is expected for AR |
| 004_slippy_maps | `004_slippy_maps/PokemonMap.unitypackage` | Unity editor compatible with the package | `PokemonMap.unitypackage` includes the map plugin assets | Map/location behavior should stay explicit and avoid hidden uploads |

## Maintenance Notes

- Keep this matrix updated when tutorial README setup steps, Unity versions, or
  package assumptions change.
- Keep Unity editor versions aligned with checked-in `ProjectVersion.txt`
  metadata for Unity-backed tutorials.
- Keep `ASSET_NOTICES.md` updated when character, model, screenshot, AR, or map
  package assets are added, removed, or replaced.
- Do not commit credentials, device provisioning profiles, or SDK license files.
- Keep camera and location assumptions visible in docs and sample code.
