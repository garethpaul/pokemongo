# Unity Metadata Validation

Status: Completed

## Context

The augmented-reality tutorial preserved its Unity scene without the companion
`.meta` file or directory metadata. Unity would therefore assign new GUIDs when
the project was imported, making serialized references unstable across clones.
The existing archive check validated file presence and permissions but did not
detect missing or orphaned Unity metadata.

## Objectives

- Restore stable metadata for the augmented-reality scene and its directory.
- Require every checked-in Unity asset and asset directory to have a matching
  `.meta` file.
- Reject orphaned `.meta` files whose asset no longer exists.
- Require valid, unique Unity GUIDs across the archived projects.
- Keep the validation dependency-free and runnable without Unity.

## Work Completed

- Added unique, stable GUID metadata for `Assets/Scenes` and
  `Assets/Scenes/PokemonScene.unity` in the augmented-reality tutorial.
- Extended `scripts/check-tutorial-assets.rb` to validate Unity metadata pairs
  recursively under every numbered tutorial's `Assets` directory and reject
  malformed or duplicate GUIDs.
- Documented the archive invariant in README and CHANGES.

## Verification

- `ruby -c scripts/check-tutorial-assets.rb`
- `make check`
- Removed a scene `.meta` file in a mutation check and confirmed `make check`
  rejected the missing metadata.
- Added orphan metadata in a mutation check and confirmed `make check` rejected
  it.
- Reused an existing GUID in a mutation check and confirmed `make check`
  rejected the duplicate.
- `git diff --check`
