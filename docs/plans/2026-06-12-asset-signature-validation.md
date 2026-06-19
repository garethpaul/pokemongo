# Archived Asset Signature Validation

Status: Completed

## Context

The tutorial validator checks that screenshots, Blender projects, the Unity
package, and FBX models exist, but a truncated or text replacement with the
same filename passes. These binary files are the primary archived tutorial
artifacts and cannot be reconstructed from the repository's source text.

## Priority

Failing closed on recognizable file signatures catches corruption and bad
placeholder replacements before they are published or merged. The check stays
dependency-free and does not claim to parse or execute legacy Unity content.

## Objectives

- Validate PNG and JPEG screenshot signatures according to their extensions.
- Validate Blender, gzip-compressed Unity package, and binary FBX signatures.
- Add portable mutation tests that replace each asset type with invalid bytes.
- Run the mutation suite from `make test` and the canonical `make check` gate.
- Protect the implementation, tests, documentation, and completed plan from
  silent removal.
- Leave all archived binary assets unchanged.

## Verification

- `ruby -c scripts/check-tutorial-assets.rb`
- `sh -n scripts/test-tutorial-assets.sh`
- `dash -n scripts/test-tutorial-assets.sh`
- `make lint`
- `make test`
- `make build`
- `make verify`
- `make check`
- `git diff --check`

## Work Completed

- The validator checks every archived PNG/JPEG screenshot, Blender project,
  Unity package, and FBX model against its expected binary signature.
- The mutation suite uses isolated hard-linked repository copies and replaces
  one artifact per format without changing the working tree or binary archive.
- `make test` and therefore `make check` run the corruption mutations.
- The validator protects the test wiring, README contract, completed plan, and
  mutation labels from silent removal.
- All archived binary assets remain unchanged.

## Verification Results

- `ruby -c scripts/check-tutorial-assets.rb` passed.
- `sh -n scripts/test-tutorial-assets.sh` passed.
- `dash -n scripts/test-tutorial-assets.sh` passed.
- `scripts/test-tutorial-assets.sh` passed all five corruption mutations.
- `make lint`, `make test`, `make build`, `make verify`, and `make check`
  passed with Ruby 2.7.0.
- Caller-independent validator execution from `/` passed.
- All 10 hostile plan, documentation, wiring, mutation, and implementation
  guardrail changes were rejected.
- `git diff --check` passed.
- The aggregate SHA-256 over archived screenshots, Blender projects, Unity
  packages, and FBX models remained
  `2c37f5a1d8a9f7d9ce1f9fa2408b95745f9c1438db769c22091fb59a4624b22e`.
