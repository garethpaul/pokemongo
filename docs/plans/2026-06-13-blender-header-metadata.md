# Validate Blender Header Metadata

Status: Completed

## Context

The archive validator checks only the seven-byte `BLENDER` magic prefix. A
truncated project or a header with an invalid pointer-width, endianness, or
version marker can therefore pass even though Blender cannot identify the file
format safely.

## Priority

The two character models are primary tutorial sources and cannot be recreated
from text in this repository. Their fixed 12-byte headers expose enough format
metadata for a bounded dependency-free integrity check without decoding model
blocks or requiring Blender.

## Objectives

- Require each `.blend` file to retain a complete 12-byte Blender header.
- Validate the pointer-width marker, endianness marker, and three ASCII version
  digits defined by the Blender file format.
- Require `Pikachu.blend` to retain version `272` and `Pokeball.blend` version
  `277`, and document those checked-in values in `TOOLCHAIN.md`.
- Add isolated mutations for invalid pointer width, endianness, version shape,
  version mismatch, and truncated headers.
- Preserve existing screenshot, TGA, FBX, Unity package, permission, inventory,
  and documentation behavior.
- Leave every archived binary asset unchanged.

## Scope Boundaries

- Do not decode Blender data blocks or claim the models open in a current
  Blender release.
- Do not rewrite, resave, normalize, or replace either `.blend` file.
- Do not add gems, Blender, or other binary parsing dependencies.

## Verification

- `ruby -c scripts/check-tutorial-assets.rb`
- `sh -n scripts/test-tutorial-assets.sh`
- `dash -n scripts/test-tutorial-assets.sh`
- focused Blender header mutations and all Make gates including `make check`
- validator execution from an external working directory
- Ruby 2.7 and Ruby 3.3 network-disabled container validation
- exact-base archived-asset aggregate SHA-256 comparison
- hostile mutations covering parser markers, expected versions, tests,
  guidance, plan status, and verification evidence
- `git diff --check` plus secret, captured-prompt, generated-artifact,
  specification, archived-asset, and dependency scans

## Work Completed

- Added a bounded 12-byte Blender header parser for signature, pointer-width,
  endianness, version shape, and expected per-file version checks.
- Documented the checked-in Pikachu Blender 2.72 and Pokeball Blender 2.77
  provenance in the toolchain matrix and maintenance guidance.
- Added five isolated header mutations while preserving the original generic
  Blender signature mutation and all screenshot, TGA, FBX, and Unity checks.
- Protected the plan, parser behavior, test labels, README contract, and
  toolchain version evidence in the dependency-free repository validator.
- Left every archived binary asset unchanged.

## Verification Results

- Ruby 2.7 and Ruby 3.3 `make check` passed in network-disabled containers
  against a disposable same-filesystem repository copy for isolated hard-link
  mutations; the real worktree remained untouched.
- Ruby and shell syntax, the focused integrity suite, all Make gates, and an
  external-working-directory completed-copy validation passed.
- Ten hostile mutations rejected pointer-width, endianness, version shape,
  expected version, truncation, test, toolchain, README, plan status, and
  verification-evidence drift.
- The stacked base and current archived-asset manifests both have aggregate
  SHA-256 `2fd6995034fee46406dd115b464aaab981c472b3f421bdc24fb5a3af678251f7`.
- `git diff --check` passed. Exact-base comparison confirmed all binaries,
  workflow, Makefile, ignore rules, and asset notices were unchanged; the
  secret, captured-prompt, generated-artifact, specification, archived-asset, and dependency scan passed.
