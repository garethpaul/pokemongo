# Unity Package Gzip Integrity

## Status

In Progress

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

## Verification

- Run the focused tutorial asset suite and full `make check` from the
  repository and an external working directory.
- Reject isolated gzip truncation, checksum, implementation, fixture, and plan
  mutations.
- Audit the exact diff, asset hashes, generated artifacts, credential patterns,
  conflict markers, dependency drift, and workflow drift before commit.
