---
title: Location-Independent Make Gates
type: fix
date: 2026-06-14
---

# Location-Independent Make Gates

Status: Planned

## Summary

Make tutorial archive validation target the repository that owns the Makefile
from any caller directory.

## Problem Frame

The Ruby validator and shell mutation harness already support explicit roots,
but the Makefile launches both through caller-relative paths. Absolute Makefile
invocation therefore fails before either portable tool can run.

## Requirements

- R1. Derive an override-protected absolute repository root from the loaded
  Makefile.
- R2. Run the validator and mutation harness from that root while preserving
  all alias dependencies.
- R3. Add exact validator contracts for root derivation and both rooted recipes.
- R4. Preserve every tutorial, screenshot, Unity project, Blender file, Unity
  package, FBX, TGA, workflow, dependency, and historical plan.

## Assumptions

- GNU Make in the hosted Ubuntu lane supports the fleet root pattern.
- The validator and mutation harness retain their independent root mechanisms;
  Make only supplies reliable invocation location.

## Implementation Units

### U1. Root tutorial verification

**Files:** `Makefile`

Use one override-protected repository root for the validator and mutation
harness without changing the target graph.

**Test scenarios:**

- Run all aliases from the repository root and through the absolute Makefile
  path from `/tmp` with a conflicting root override.
- Validate on Ruby 2.7 and Ruby 3.3.

### U2. Enforce and record the contract

**Files:** `scripts/check-tutorial-assets.rb`,
`docs/plans/2026-06-14-location-independent-make.md`

Require exact root and recipe fragments, reject isolated mutations, and record
completed evidence after final validation.

**Test scenarios:**

- Mutate root derivation and each rooted recipe independently.
- Run Ruby and shell syntax plus the complete asset mutation suite.
- Confirm all 15 archived binary paths remain byte-identical to the stacked
  base and that documentation, workflow, and prior plans have no diff.

## Scope Boundaries

- No tutorial code, documentation, screenshots, or archived asset changes.
- No Unity, Blender, Kudan, camera, location, or device runtime claims.
- No dependency or workflow changes.

## Verification

Completion requires root and external gates on Ruby 2.7 and 3.3, three isolated
hostile Make mutations, shell/Ruby syntax, and exact archived-asset preservation.
