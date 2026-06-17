# Unity Trigger Callback Signature

Status: in progress

## Problem

`001_collisions/Assets/Scripts/HitObject.cs` declares `OnTriggerEnter()` with no
parameter. Unity's documented MonoBehaviour message signature is
`OnTriggerEnter(Collider other)`, so the archived tutorial script compiles but
does not expose the supported trigger callback shape Unity dispatches.

## Requirements

1. Change the tracked tutorial source to the documented Collider-parameter
   callback signature without changing its trigger behavior.
2. Extend the compile-only UnityEngine stubs with only the required `Collider`
   type.
3. Add a static source contract and executable mutation proving the callback
   signature cannot regress while still compiling as an ordinary method.
4. Preserve collision handling, logging, source linking, output containment,
   archive validation, and all existing tutorial assets.
5. Record completed local and hosted verification truthfully without claiming
   a Unity editor runtime test.

## Implementation Units

### U1. Callback Repair

Add the documented `Collider other` parameter to `HitObject.OnTriggerEnter` and
the minimal corresponding compile stub.

### U2. Mutation-Sensitive Contract

Teach the asset checker to require the supported signature and extend the
isolated asset mutation suite with a zero-argument regression.

### U3. Guidance And Evidence

Update tutorial guidance, changelog, baseline plan registration, and this plan
with the exact verification and remaining Unity-runtime boundary.

## Verification Plan

- Run Ruby and shell syntax checks plus the focused tutorial asset suite.
- Run the fake-compiler wrapper probes and full `make check` from repository
  and external directories.
- Compile the exact linked source with `dotnet` when available; otherwise rely
  on the canonical hosted compiler jobs and record local unavailability.
- Reject hostile mutations for the source signature, stub, checker, fixture,
  guidance, and completed plan evidence.
- Audit exact diff, assets, generated artifacts, secrets, dependencies,
  workflow, modes, and whitespace before committing.

## Scope Boundaries

- Do not change trigger side effects or add score behavior.
- Do not modernize unrelated archived tutorial code or UnityScript assets.
- Do not claim scene-level physics behavior was exercised without Unity.
- Do not merge or close stacked pull requests without explicit authorization.
