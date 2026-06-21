# Safe Makefile Root Resolution

Status: Completed

## Context

The Makefile ignored `REPO_ROOT` overrides but trusted caller-controlled
`MAKEFILE_LIST`. Replacing that automatic variable redirected tutorial asset
validation and the optional archived C# compiler gate outside the reviewed
checkout.

## Scope Boundaries

- Do not change tutorial assets, Unity metadata, archived sample behavior, or
  the supported .NET 8 compiler contract.
- Preserve dependency-free Ruby and shell validation.
- Keep Unity editor execution and UnityScript compilation out of scope.

## Work Completed

- Reject command-line and environment replacement of `MAKEFILE_LIST` and
  preloaded `MAKEFILES`; pin the shell used by Make.
- Canonicalize the checked-in Makefile directory through quoted POSIX tools.
- Export the canonical root and optional compiler command so shell recipes
  consume them as data instead of interpolating them into shell source.
- Add dependency-free shell coverage for all six pre-existing public Make
  targets plus the root regression gate itself.
- Include the root policy in `make verify` and `make check`.

## Verification Completed

- `make lint`, `make test`, `make build`, `make root-test`, `make verify`, and
  `make check` passed with the local compiler gate explicitly skipped because
  .NET was unavailable.
- All target and `REPO_ROOT` override cases passed from a temporary checkout
  path containing spaces, an apostrophe, and a literal backtick command.
- Real lint and skipped-compiler invocations proved the shell-active checkout
  path and hostile `DOTNET` values remained inert.
- Command-line and environment `MAKEFILE_LIST`, `MAKEFILES`, `SHELL`, and `DOTNET`
  attacks failed closed, were overridden by policy, or remained inert data.
- Tutorial assets and archived source files remained byte-identical.
