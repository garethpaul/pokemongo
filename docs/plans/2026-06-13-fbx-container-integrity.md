# Validate Binary FBX Container Integrity

Status: Completed

## Context

The tutorial validator checks only the 23-byte binary FBX magic prefix. A file
with the right prefix can still pass after truncation, a format-version change,
footer-version disagreement, footer-padding corruption, or loss of the terminal
FBX footer magic.

## Priority

The checked-in Pikachu and Pokeball FBX models are primary Unity tutorial
sources that cannot be reconstructed from text in this repository. Their binary
FBX headers and fixed footer structure provide a bounded integrity contract
without decoding scene nodes or requiring Autodesk tooling.

## Objectives

- Require complete binary FBX headers and preserve the checked-in format
  versions: 7300 for `Pikachu.FBX` and 7400 for `pokeball2.fbx`.
- Require the footer version to match the header version, preserve the zeroed
  footer padding, and retain the terminal 16-byte FBX footer magic.
- Add isolated mutations for header-version mismatch, footer-version mismatch,
  footer-padding corruption, truncation, and trailing bytes.
- Document the checked-in FBX versions in `TOOLCHAIN.md` and maintenance
  guidance.
- Preserve all existing screenshot, Blender, TGA, Unity package, permission,
  inventory, workflow, and documentation behavior.
- Leave every archived binary asset unchanged.

## Scope Boundaries

- Do not parse FBX nodes, properties, geometry, materials, or embedded media.
- Do not rewrite, export, normalize, or replace either FBX file.
- Do not add gems, FBX SDKs, or other binary parsing dependencies.

## Verification

- `ruby -c scripts/check-tutorial-assets.rb`
- `sh -n scripts/test-tutorial-assets.sh`
- `dash -n scripts/test-tutorial-assets.sh`
- focused FBX mutations and all Make gates including `make check`
- validator execution from an external working directory
- Ruby 2.7 and Ruby 3.3 network-disabled container validation
- exact-base archived-asset aggregate SHA-256 comparison
- hostile mutations covering parser constants, expected versions, tests,
  guidance, plan status, and verification evidence
- `git diff --check` plus secret, captured-prompt, generated-artifact,
  specification, archived-asset, and dependency scans

## Work Completed

- Added a bounded binary FBX parser for the fixed signature, little-endian
  header version, matching footer version, zeroed footer padding, and terminal
  footer magic.
- Recorded the checked-in 7300/7400 versions in toolchain and maintenance
  guidance and protected the parser, tests, plan, and evidence contracts in the
  repository validator.
- Added six hard-link-safe FBX mutations without modifying either archived
  model.

## Verification Results

- Ruby 2.7 and Ruby 3.3 `make check` passed; Ruby 3.3 ran in a read-only,
  network-disabled container against a disposable writable repository copy.
- Ruby and POSIX shell syntax, all Make gates, and validator execution from an
  external working directory passed.
- The 20-case asset integrity suite passed, including six isolated FBX version,
  footer, padding, truncation, and trailing-byte mutations.
- Ten additional hostile mutations rejected parser constants and checks, test
  contracts, toolchain/README guidance, plan status, and verification-evidence
  drift.
- All 15 archived binary paths are byte-identical to stacked base
  `1c59a74e6fef7f62c94dac22502028fcac88c165`, with aggregate SHA-256
  `2fd6995034fee46406dd115b464aaab981c472b3f421bdc24fb5a3af678251f7`.
- `git diff --check` passed; protected workflow, Makefile, ignore rules, and
  notices were unchanged, and the secret, captured-prompt, generated-artifact, specification, archived-asset, and dependency scan passed.
