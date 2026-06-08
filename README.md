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
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: 001_collisions, 002_characters, 003_augmented_reality, 004_slippy_maps
- Dependency and build manifests: none detected
- Entry points or build surfaces: none detected
- Test-looking files: no obvious test files detected

## Getting Started

### Prerequisites

- Git

### Setup

```bash
git clone https://github.com/garethpaul/pokemongo.git
cd pokemongo
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- No single runtime entry point was identified. Start by reading the source files and manifests listed above.

## Testing and Verification

- No dedicated automated test command was identified from the checked-in files. Verify changes by running the relevant build or manually exercising the sample.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.

## Security and Privacy Notes

- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include 001_collisions/Assets/Scripts/HitObject.cs.

## Maintenance Notes

- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.

## Existing Project Notes

Prior README summary:

> Tutorials 1. Tutorial 001 in this directory shows you how you can do some simple collision detection. 2. Tutorial 002 shows how to create characters Pikachu and Pokeball using Blender. 3. Tutorial 003 shows how to build a SLAM based AR experience. 4. Tutorial 004 shows how to create 3D mapping app with 3D objects. Pokémon is a registered trademark of Nintendo (1995 - Present).
