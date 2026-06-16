# Unity Package Tar Integrity

## Status Completed

## Problem

`PokemonMap.unitypackage` is a gzip-compressed tar archive. The current guard
fully validates the gzip stream, but a corrupt tar header can be recompressed
with a valid gzip CRC and still pass. A disposable first-header mutation is
accepted by the repository validator while `tar -tzf` rejects it.

## Requirements

- R1. Validate the decompressed tar stream without loading the 93 MB payload
  into memory.
- R2. Require complete 512-byte headers, valid header checksums, valid octal
  sizes, complete padded member payloads, and the two-zero-block terminator.
- R3. Preserve the existing gzip signature, corruption, and trailing-byte
  diagnostics.
- R4. Add isolated mutations for bad tar checksum, malformed size, truncated
  payload, nonzero member padding, and missing terminator while keeping the
  gzip stream valid.
- R5. Protect implementation, executable fixtures, documentation, and truthful
  completed evidence through the canonical static gate.
- R6. Keep the archived Unity package and all other tutorial assets unchanged.

## Scope Boundaries

- Do not parse Unity package member semantics or import the package in Unity.
- Do not shell out to platform-specific tar implementations.
- Do not buffer the complete decompressed archive.
- Do not merge or close stacked pull requests without explicit authorization.

## Technical Design

- Extend the existing gzip streaming pass with exact 512-byte tar block reads.
- Treat checksum bytes as spaces when calculating the POSIX tar header sum.
- Parse checksum and size fields as bounded octal values and stream-skip each
  member through its 512-byte padding boundary.
- Require two consecutive zero headers and only zero padding afterward.
- Map inner framing/checksum failures to one stable Unity package tar error,
  while retaining the outer gzip error categories.

## Implementation Units

- **Validator:** `scripts/check-tutorial-assets.rb`
- **Executable fixtures:** `scripts/test-tutorial-assets.sh`
- **Contracts and evidence:** validator static checks, `README.md`, `CHANGES.md`,
  and this plan.

## Work Completed

- Added a streaming tar reader for 512-byte headers and padded member payloads
  inside the existing gzip validation pass.
- Added octal size parsing, POSIX header checksum verification, two-zero-block
  termination, and zero-only trailing archive padding checks.
- Added valid-gzip fixtures for checksum corruption, malformed size, oversized
  payload framing, nonzero member padding, and missing tar termination.
- Protected the executable parser, fixtures, documentation, and completed plan
  evidence through the canonical repository validator.

## Verification Completed

- Ruby 2.7.0 passed syntax checks, the focused tutorial asset mutation suite,
  repository-root `make check`, and the external-directory `make check` through
  the absolute Makefile path.
- Ruby 3.3 remains hosted-only in this environment; exact-head pull-request
  evidence is recorded separately in the repository tracker.
- The clean archive passed streaming gzip and tar validation; five valid-gzip
  but invalid-tar fixtures were rejected with the stable tar diagnostic.
- Ten isolated hostile mutations were rejected across tar block reads, octal
  parsing, checksum calculation, member padding, termination, fixture wiring,
  documentation, and completed status.
- Final `git diff --check`, artifact, credential-pattern, conflict-marker,
  binary, large-file, mode, archived-asset hash, and whitespace audits passed.
  `PokemonMap.unitypackage` remained byte-identical at SHA-256
  `ad4c5a1ad2ceb1324a4264254773f0a458ae7204d4fd001b43b6996ad91ce1da`.

## Risks

- Historical tar writers may use extension records; the framing validator must
  accept all member types and validate only generic container structure.
- Tar numeric fields have legacy encodings; this archived package uses octal
  fields, so broader base-256 support is outside this narrow repair.
