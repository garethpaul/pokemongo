# TGA Texture Integrity Validation

Status: Completed

## Context

The tutorial archive contains four `.tga` character textures used by the first
Unity project. The repository already checks their permissions, but its binary
integrity gate covers only PNG, JPEG, Blender, Unity package, and FBX files. A
truncated or text-replaced TGA therefore passes `make check` and fails later
when a reader imports the archived model.

TGA does not define a universal magic signature. The checked-in textures are
uncompressed true-color images, so validation must parse the 18-byte header,
require nonzero dimensions and a supported pixel depth, and prove the file is
large enough for the declared image ID and pixel payload.

## Priority

This closes the only known archived binary class that is inventoried but not
integrity-checked. It protects irreplaceable tutorial inputs with the existing
dependency-free Ruby and shell toolchain and does not require historical Unity
or Blender installations.

## Objectives

- Validate every checked-in TGA texture as an uncompressed true-color image.
- Reject short headers, unsupported image types or pixel depths, zero-sized
  images, and payloads shorter than the dimensions declare.
- Add isolated mutations for malformed headers and truncated pixel data.
- Protect the implementation, test wiring, documentation, and completed plan
  against silent removal.
- Preserve every archived binary asset byte-for-byte.

## Implementation Units

### U1. Structural TGA validation

**Files:** `scripts/check-tutorial-assets.rb`

**Goal:** Detect malformed or truncated checked-in TGA textures without adding
dependencies or claiming full image decoding.

**Approach:** Parse the fixed TGA header using binary reads and little-endian
fields. Require image type 2, nonzero width and height, 24-bit or 32-bit pixels,
no color map, and enough bytes for the image ID plus declared pixel payload.
Apply the check to every `.tga` file already covered by the asset inventory.

### U2. Corruption regression coverage

**Files:** `scripts/test-tutorial-assets.sh`

**Goal:** Prove header and payload corruption fail through the canonical test
gate while leaving the working tree and archived assets untouched.

**Approach:** Extend the existing isolated hard-linked mutation harness with
header-field and truncated-payload cases. Preserve the existing `Makefile`
wiring, keep the tests portable to POSIX shell, and run them through `make test`
and `make check`.

### U3. Fail-closed repository contracts and documentation

**Files:** `scripts/check-tutorial-assets.rb`, `README.md`, `SECURITY.md`,
`VISION.md`, `CHANGES.md`, `AGENTS.md`,
`docs/plans/2026-06-12-tga-integrity-validation.md`

**Goal:** Make the new integrity boundary durable and visible to maintainers.

**Approach:** Register the completed plan, require the exact mutation labels and
TGA validation contract, and document the structural check alongside existing
archived asset validation. Historical claims and toolchain boundaries remain
unchanged.

## Verification

- `ruby -w -c scripts/check-tutorial-assets.rb`
- `sh -n scripts/test-tutorial-assets.sh`
- `dash -n scripts/test-tutorial-assets.sh`
- `make lint`
- `make test`
- `make build`
- `make verify`
- `make check`
- validator invocation outside the repository working directory
- hostile TGA implementation, mutation, plan, and documentation changes
- aggregate SHA-256 proving archived binary assets are unchanged
- workflow YAML parsing and `git diff --check`

## Work Completed

- Added dependency-free structural validation for every `.tga` asset, requiring
  an 18-byte header, no color map, uncompressed true-color image type, nonzero
  dimensions, 24-bit or 32-bit pixels, and a complete declared pixel payload.
- Added isolated mutations for generic and short headers, color maps, image
  types, zero dimensions, pixel depths, and truncated payloads. The mutation
  harness proves the unmodified repository baseline before exercising corrupt
  copies.
- Registered this completed plan and protected the implementation, test labels,
  baseline prerequisite, and README integrity contract from silent removal.
- Updated contributor, security, vision, README, and changelog documentation.

## Verification Results

- `ruby -w -c scripts/check-tutorial-assets.rb`, `sh -n
  scripts/test-tutorial-assets.sh`, and `dash -n
  scripts/test-tutorial-assets.sh` passed.
- The focused mutation suite rejected malformed and short headers, color maps,
  unsupported image types, zero dimensions, unsupported pixel depths, and
  truncated TGA pixel data in isolated copies.
- The validator passed against the unmodified exact-file copy.
- All 15 archived PNG, JPEG, Blender, Unity package, FBX, and TGA assets match
  the base commit at aggregate SHA-256
  `2fd6995034fee46406dd115b464aaab981c472b3f421bdc24fb5a3af678251f7`.
- `make lint`, `make test`, `make build`, `make verify`, and `make check`
  passed on the completed worktree.
- Validator execution from `/`, workflow YAML parsing, README SVG parsing,
  Ruby and shell syntax checks, and `git diff --check` passed.
- All 15 hostile implementation, mutation, plan, baseline-proof, and README
  contract removals were rejected.

## Boundaries

- Do not modify archived TGA, PNG, JPEG, Blender, Unity package, or FBX files.
- Do not add image libraries, gems, package-manager state, or network access.
- Do not claim full TGA decoding, Unity import compatibility, or visual output
  verification.
- Preserve the existing remediation PR and canonical exact-head evidence.
