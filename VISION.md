## Pokemongo Vision

Pokemongo is a fan-made tutorial collection for game and AR developers covering
collision detection, Blender character assets, Unity augmented reality, and
slippy-map style 3D mapping.

The repository is useful as a learning archive that groups small tutorial
steps, screenshots, Unity packages, and Blender files into a sequence of
hands-on experiments.

The goal is to preserve the tutorial value while keeping trademark, asset,
toolchain, and SDK assumptions clear.

Current baseline: `make check` verifies tutorial asset references, screenshot
inventory, toolchain matrix coverage, exact Unity editor versions,
asset-notice coverage, and canonical `docs/plans` records without requiring
Unity, Blender, Xcode, or AR SDK installs.

The current focus is:

Priority:

- Preserve the numbered tutorial structure
- Keep screenshots and asset references available and referenced
- Keep screenshot image assets non-executable
- Keep loose standalone screenshots documented in top-level notices
- Keep tutorial README scene names aligned with checked-in Unity scenes
- Keep `TOOLCHAIN.md` aligned with Unity `ProjectVersion.txt` editor versions
- Maintain `make check` and `make verify` as the local tutorial asset inventory gates
- Maintain the non-affiliation and fan-project disclaimer
- Keep asset ownership and reuse assumptions explicit in `ASSET_NOTICES.md`
- Document Unity, Blender, SDK, camera, and location assumptions for each tutorial

Next priorities:

- Expand the top-level setup matrix for required tools per tutorial
- Clarify which assets are original, third-party, placeholders, or archived media
- Add troubleshooting notes for missing SDKs and Unity package imports
- Keep each tutorial runnable independently where possible

Contribution rules:

- One PR = one focused tutorial, asset, setup, or documentation change.
- Respect trademark and asset ownership boundaries.
- Do not add commercial distribution claims.
- Include screenshots or reproduction notes for visual tutorial changes.

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

AR and mapping tutorials can involve camera, location, and device permissions.
Examples should keep permissions visible and avoid collecting or uploading user
location or camera data by default.

## What We Will Not Merge (For Now)

- Trademark-confusing branding changes
- Undocumented third-party assets
- Hidden location or camera upload behavior
- Broad engine upgrades without tutorial-specific migration notes

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
