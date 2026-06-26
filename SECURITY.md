# Security Policy

## Supported Versions

The supported security scope for `pokemongo` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: A series of tutorials on the basics of replicating Pokémon Go

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/pokemongo` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be a public sample, documentation, or utility project. The active security scope is the code and documentation on the default branch.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- No primary dependency manifest was detected in the repository root. If dependencies are added later, include a manifest and prefer reproducible installation instructions.

## Service and API Notes

For web services, APIs, sockets, or scraping workflows, prioritize reports involving authentication bypass, authorization errors, injection, server-side request forgery, unsafe deserialization, credential leakage, data exposure, or denial-of-service conditions. Use test accounts and minimal proof-of-concept traffic only.

Screenshot image assets should stay non-executable so archived media cannot be
confused with runnable tutorial scripts or tools.
Unity project files, source files, material files, and `.meta` files should
also stay non-executable because they are source or data inputs in this archive.
Tutorial-local setup docs should keep camera and location assumptions visible
near the steps that ask readers to open AR or map examples.
Numbered tutorial directories should stay contiguous and listed in the top-level
README so readers do not miss permission-sensitive AR or location examples.
Recursive asset validation is anchored to this repository so checks do not
inspect unrelated caller-directory files. Hosted validation uses read-only
repository access, a pinned checkout action without persisted credentials, and
explicit CODEOWNERS review routing.
Tutorial README image validation also confines resolved local targets to the
repository, rejecting both lexical path escapes and symlinks to outside files.
The dependency-free gate checks recognizable signatures for archived images,
Blender projects, binary FBX models, and gzip-compressed Unity packages so text
placeholders or truncated replacements do not pass as tutorial assets.
TGA texture headers and pixel payload sizes are checked before archived texture
files are trusted as complete uncompressed true-color images.
Complete Blender header metadata is validated before archived model sources are
trusted, including pointer-width, endianness, and version markers.
Binary FBX models must retain their recorded header version, matching footer
version, zeroed footer padding, and terminal footer magic so prefixed or
truncated replacements fail before import.
Unity package tar members must keep safe relative paths and regular file or
directory typeflags so path traversal, hardlink, symlink, or special-device
entries cannot pass as ordinary tutorial package content.
The C# compiler gate builds the tracked collision script against narrow
compile-only UnityEngine stubs so syntax and referenced symbol regressions fail
in hosted CI. UnityScript remains manual, and passing this gate does not prove
safe Unity import or runtime behavior.
The static validator separately preserves the supported Collider-parameter
trigger callback signature so a compiling but undispatchable method cannot
silently replace it.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
