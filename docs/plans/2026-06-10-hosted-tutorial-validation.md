# Hosted Tutorial Validation

Status: Completed

## Context

The Unity-free tutorial asset validator was available only as a local gate and
resolved all globs from the caller's working directory. Running the script from
another directory could inspect unrelated files while reporting the repository
assets as missing, and pushes or pull requests did not run the canonical gate.

## Work Completed

- Anchored `scripts/check-tutorial-assets.rb` to its repository before it reads
  files or expands recursive asset globs.
- Added fixed-runner GitHub Actions validation for pushes to `master` and pull
  requests without installing Unity, Blender, Xcode, or third-party packages.
- Limited the workflow token to read-only contents access and pinned the
  checkout action to a reviewed commit.
- Extended the validator to preserve the hosted workflow contract and this
  completed maintenance plan.

## Verification

- `scripts/check-tutorial-assets.rb`
- `(cd / && /path/to/scripts/check-tutorial-assets.rb)`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
