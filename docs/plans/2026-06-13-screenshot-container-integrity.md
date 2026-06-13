# Screenshot Container Integrity Validation

Status: Completed

## Context

The tutorial validator checks PNG and JPEG leading signatures, but a truncated
file or a PNG with corrupted chunk data still passes when its first bytes are
unchanged. Screenshots are primary archived tutorial evidence and cannot be
reconstructed from the legacy Unity projects with the repository's current
dependency-free toolchain.

## Priority

Validating complete image containers catches storage corruption and partial
asset replacement before publication. PNG exposes deterministic chunk lengths,
CRC values, and an end marker that Ruby's standard library can verify. JPEG
files have a required end-of-image marker that provides a bounded truncation
guard without adding an image-processing dependency.

## Prioritized Engineering Backlog

1. Validate complete PNG chunk framing, CRCs, and terminal `IEND` chunks now.
2. Require JPEG screenshots to retain their terminal end-of-image marker.
3. Add full pixel decoding only if a maintained dependency can preserve the
   repository's legacy Ruby compatibility and offline checks.

## Objectives

- Reject truncated PNG and JPEG screenshots that retain valid leading bytes.
- Reject PNG payload corruption through per-chunk CRC validation.
- Require PNG files to end exactly after one terminal `IEND` chunk.
- Add isolated mutation tests for each failure mode.
- Preserve existing signature, permission, inventory, and documentation gates.
- Leave every archived screenshot unchanged.
- Run the contract through `make test` and the canonical `make check` gate.

## Scope Boundaries

- Do not decode or compare screenshot pixels.
- Do not add gems, system image tools, or network access.
- Do not rewrite or recompress archived images.
- Do not modify TGA validation covered by the separate texture-integrity work.

## Verification

- `ruby -c scripts/check-tutorial-assets.rb`
- `sh -n scripts/test-tutorial-assets.sh`
- `dash -n scripts/test-tutorial-assets.sh`
- `scripts/test-tutorial-assets.sh`
- `make lint`
- `make test`
- `make build`
- `make verify`
- `make check`
- validator execution from outside the repository working directory
- archived screenshot aggregate SHA-256 comparison with the base commit
- `git diff --check`

## Work Completed

- Added bounds-checked PNG chunk traversal with CRC validation, required
  `IHDR` and `IDAT` structure, and an exact terminal `IEND` requirement.
- Added JPEG end-of-image marker validation to reject retained-header
  truncation.
- Added isolated PNG payload-corruption, truncation, trailing-byte, and JPEG
  truncation mutations that break hard links before modifying fixtures.
- Made the mutation suite require a clean baseline before exercising corrupt
  fixtures.
- Protected the implementation, mutation labels, README contract, completed
  plan, and plan inventory in the repository validator.
- Left every archived screenshot unchanged.

## Verification Results

- `ruby -c scripts/check-tutorial-assets.rb` passed.
- `sh -n scripts/test-tutorial-assets.sh` and
  `dash -n scripts/test-tutorial-assets.sh` passed.
- `scripts/test-tutorial-assets.sh` passed all nine integrity mutations.
- `make lint`, `make test`, `make build`, `make verify`, and `make check`
  passed.
- Validator execution from `/` passed with an explicit `TUTORIAL_ROOT`.
- The base and current screenshot Git-tree aggregate SHA-256 values both equal
  `904d3ac703519f7811a4e7745209a5f43f9749675ce3737bf26f3796f7b37f96`.
- `git diff --check` passed.
