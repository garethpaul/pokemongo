# Unity Package Gzip Integrity

## Status

Completed

## Problem

The tutorial validator checks only the two-byte gzip signature of
`004_slippy_maps/PokemonMap.unitypackage`. A truncated stream or a payload with
an invalid gzip CRC can therefore pass static validation even though Unity and
standard archive tools cannot extract it.

## Requirements

1. Read the complete Unity package through Ruby's gzip implementation so
   truncated streams, invalid checksums, and invalid uncompressed sizes fail.
2. Preserve the existing signature diagnostic for files that are not gzip
   archives and add one stable diagnostic for corrupt gzip containers.
3. Add isolated mutations for truncation and checksum corruption, and protect
   the executable fixtures and validator contract from silent removal.
4. Keep validation dependency-free, caller-directory independent, and
   compatible with the repository's supported Ruby runtime.

## Scope Boundaries

- Do not modify or regenerate `PokemonMap.unitypackage` or other archived
  tutorial assets.
- Do not require Unity, Blender, network access, or external archive commands.
- Do not redesign unrelated image, Blender, FBX, metadata, or workflow checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification Completed

- Ruby 2.7.0 passed syntax checks, the focused tutorial asset suite, full
  `make check`, and the absolute-Makefile `make check` from an external
  working directory.
- Ruby 3.3 passed the full `make check` in the official network-disabled
  container with read-only Git metadata and same-filesystem isolated fixtures;
  the post-run asset and worktree audit confirmed no source mutation.
- Focused fixtures rejected a truncated stream, invalid CRC and size footers,
  and trailing bytes while the checked-in archive remained readable in
  bounded 64 KiB chunks.
- Thirteen isolated hostile mutations were rejected across complete-stream
  reading, trailing-byte detection, validator invocation, executable fixture
  wiring, corruption behavior, public documentation, and completed evidence.
- Final `git diff --check`, generated-artifact, credential-pattern,
  conflict-marker, dependency-drift, workflow, and archived-asset audits
  passed. `PokemonMap.unitypackage` remained byte-identical at SHA-256
  `ad4c5a1ad2ceb1324a4264254773f0a458ae7204d4fd001b43b6996ad91ce1da`.
