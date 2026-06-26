# README Image Root Boundary

Status: Completed

## Problem

Tutorial README image tags were accepted when `File.file?` found their target,
even if a relative path escaped the repository or an in-repository symlink
resolved to an external file. That allowed documentation integrity checks to
depend on files outside the reviewed checkout.

## Design

- Preserve remote HTTP and HTTPS images as the existing explicit exception.
- Preserve local shared screenshots such as `../screenshots/001/001.png`.
- Reject a lexical path escape before counting or opening the image.
- Resolve existing local targets and reject a symlink escape.
- Keep missing in-repository image reporting unchanged.

## Alternatives

- Restricting images to each tutorial directory would break the established
  shared screenshot layout.
- Continuing existence-only validation leaves the checkout boundary porous.
- Rejecting every symlink in the repository would broaden this focused change
  beyond README image ownership.

## Verification

- Confirm the lexical escape mutation fails before implementation because the
  validator accepts an additional external image.
- Run isolated lexical path escape and symlink escape mutations.
- Run Ruby syntax, `make check`, every Make alias, and the absolute-Makefile
  gate from an external directory.
- Confirm the hosted Ruby and .NET gate passes on the exact PR head.

## Scope Boundaries

- Do not modify tutorial assets, README screenshot locations, Unity projects,
  archived source behavior, package contents, or toolchain versions.

## Work Completed

- Added lexical and resolved-path containment before local README images are
  counted or opened.
- Added isolated external-file and symlink escape regressions.
- Added mutation-sensitive source, test, guidance, changelog, and plan
  contracts.

## Verification Completed

- Pre-fix evidence confirmed an external image reference was accepted.
- Ruby 2.7 and Ruby 3.3 syntax plus the complete isolated asset mutation suite
  passed.
- `make check` passed with Ruby and .NET 8, including compilation of the exact
  archived `HitObject.cs`, from the repository and an external directory.
- The Make root and hostile control-variable suite passed.
- Removing the repository-boundary call restored the defect and failed the
  lexical escape mutation.
- A locale-less container exposed an existing BOM-sensitive C# source regex;
  the complete gate passed under `C.UTF-8`, matching hosted Ubuntu.
