---
title: Compile the archived C# tutorial source
type: testing
date: 2026-06-16
status: completed
execution: code
---

# Compile the archived C# tutorial source

## Goal

Provide a documented executable compiler command for the checked-in C# script
without requiring a licensed Unity editor or claiming that obsolete UnityScript
and complete Unity projects compile on a current toolchain.

## Requirements

- Compile the actual `HitObject.cs` file, not a copied test implementation.
- Keep compile-only UnityEngine stubs limited to symbols referenced by that file.
- Use an SDK-style .NET 8 project with no package dependencies.
- Keep restore/build outputs outside the repository and clean them on every exit.
- Run the compiler gate from `make check` and `make build` when `dotnet` exists.
- Install .NET through an immutable official action pin in hosted CI.
- Preserve the existing Unity-free asset and archive-integrity suite unchanged.

## Verification Completed

- Repository and external-directory Make gates passed with explicit timeouts.
- Fake-compiler success, exit-7 failure, signal-143 cleanup, argument capture,
  and temporary-output cleanup probes passed locally.
- Nine hostile mutations were rejected across linked source, Unity API stubs,
  SDK target, Make wiring, workflow pinning, runner cleanup, documentation, and
  completed plan evidence, plus the tracked compiler-project ignore exception.
- Ruby and shell syntax, diff checks, executable modes, artifact scans, and
  changed-line credential-pattern scans passed.
- The local host lacks `dotnet`. On implementation head
  `7cc145f4cd4dc5c4d8e9e1ad19b12f7ffb86703e`, hosted push run `27644043193`
  and hosted pull-request compiler check run `27644050768` passed; both logs
  recorded the C# build succeeding with zero errors before the asset suite.
