# pokemongo

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/pokemongo` is a public sample, documentation, or utility project. A series of tutorials on the basics of replicating Pokémon Go

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: C# (1), JavaScript (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `001_collisions` - source or example code
- `002_characters` - source or example code
- `003_augmented_reality` - source or example code
- `004_slippy_maps` - source or example code
- `ASSET_NOTICES.md` - asset ownership and fan-project usage notes
- `CHANGES.md` - notable maintenance changes
- `docs/plans` - completed engineering plans in the canonical location
- `Makefile` - local verification entry points
- `TOOLCHAIN.md` - Unity, Blender, AR SDK, and map package assumptions
- `plans` - completed maintenance plans
- `scripts` - deterministic tutorial inventory checks
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: 001_collisions, 002_characters, 003_augmented_reality, 004_slippy_maps, scripts
- Dependency and build manifests: Makefile
- Entry points or build surfaces: Makefile
- Test-looking files: scripts/check-tutorial-assets.rb

## Getting Started

### Prerequisites

- Git
- Ruby and `make`

### Setup

```bash
git clone https://github.com/garethpaul/pokemongo.git
cd pokemongo
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Start with the numbered tutorial directories in order.
- Review `ASSET_NOTICES.md` before reusing, replacing, or redistributing
  checked-in character, model, screenshot, AR, or map-package assets.
- Check `TOOLCHAIN.md` before opening a tutorial in Unity or Blender.
- Open Unity projects from `001_collisions` and `003_augmented_reality` with a compatible Unity editor.
- Open Blender assets from `002_characters`, and import `004_slippy_maps/PokemonMap.unitypackage` from Unity.
- `screenshots/001.jpg` is a standalone legacy overview screenshot; per-tutorial
  screenshots live under `screenshots/<tutorial-id>/`.

## Testing and Verification

- Run `make check` or `make verify` before committing tutorial structure, screenshot, or asset-reference changes.
- The verification gate checks README image references, the expected Unity,
  Blender, and Unity package artifacts, per-tutorial screenshot inventory, the
  Unity scene names referenced by tutorial READMEs, the top-level toolchain
  matrix, and asset-notice coverage without requiring Unity to be installed.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.

## Security and Privacy Notes

- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include 001_collisions/Assets/Scripts/HitObject.cs.

## Maintenance Notes

- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `TOOLCHAIN.md` for tutorial setup and permission-sensitive assumptions.
- See `ASSET_NOTICES.md` for asset ownership and fan-project usage notes.
- See `CHANGES.md` for maintenance history.
- See `docs/plans/2026-06-08-asset-notices-baseline.md` for the current
  canonical completed engineering plan.
- See `docs/plans/2026-06-08-screenshot-inventory-validation.md` for the
  screenshot inventory guard.
- See `docs/plans/2026-06-09-loose-screenshot-inventory.md` for standalone
  screenshot documentation checks.
- See `docs/plans/2026-06-09-unity-scene-reference-validation.md` for tutorial
  Unity scene-name validation.
- See `plans/2026-06-08-toolchain-matrix-validation.md` for the current
  toolchain matrix validation baseline.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
