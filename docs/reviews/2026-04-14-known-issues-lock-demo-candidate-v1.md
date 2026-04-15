# Known Issues Lock For Demo Candidate v1 (2026-04-14)

## Purpose

This file locks the currently accepted issues for the internal demo candidate lane.

Only issues listed here are accepted as non-blocking for the current candidate.
Anything outside this list should be treated as a new regression or promotion blocker.

## Accepted Known Issues

### 1. Save/load is intentionally unavailable

Status:

- accepted

Reason:

- save/load remains explicitly frozen by the current architecture gate
- the active demo slice is intended to be session-based only

Player impact:

- users cannot resume progress after quitting
- the candidate must be positioned as an internal/demo slice, not a persistent build

### 2. Placeholder audio assets remain in the runtime

Status:

- accepted

Reason:

- the current runtime uses placeholder `.wav` cues routed through `AudioEventRouter`
- the cue-routing surface is validated, but the sounds are still temporary

Player impact:

- audio feedback is present and functional
- final mix quality and sonic identity are not final

### 3. Several visual runtime assets are still concept-derived

Status:

- accepted

Reason:

- telegraph textures, portrait anchors, and some CampHub previews come from production concept sheets and cutout packs
- they are suitable for readability and interaction validation, but not final art lock

Player impact:

- the game reads correctly
- final presentation polish is still pending for a ship-quality build

### 4. Export packaging is host-template blocked

Status:

- accepted for repo readiness
- not accepted for final demo package creation

Reason:

- `export_presets.cfg` now exists in-repo
- the current macOS host is missing matching Godot export templates for `4.6.2.stable`

Player impact:

- the repository is prepared for export
- a packaged desktop build cannot yet be generated on this host until templates are installed

## Non-Accepted Issues

The following remain promotion blockers and are **not** accepted:

- any failed Gate 0 integrity check
- any failed chapter shell runner
- any failed CampHub/UI runner
- any failed battle telegraph runtime runner
- any failed SFX trigger integration runner
- any issue that hides progression state or breaks chapter-to-camp handoff

## Test Priorities

Priority order for release confidence on this candidate:

### P0. Candidate integrity and progression

- Gate 0 integrity check passes with no missing required data or boot-time breakage
- chapter shell runner passes end-to-end
- chapter-to-camp handoff remains visible and deterministic
- no regression causes a stuck state, soft-lock, or invisible progression failure

### P1. Demo-path gameplay confidence

- CampHub/UI runner passes
- battle telegraph runtime runner passes
- SFX trigger integration runner passes
- no accepted issue expands beyond its locked scope or severity

### P2. Packaging and presentation confidence

- export configuration remains present and correct in-repo
- placeholder audio and concept-derived visuals remain known-only polish debt, not functional regressions
- host-template availability is checked before claiming packaged-build readiness

## Quality Gates

### Patch gate

A patch may move forward only if all of the following are true:

- no new issue is introduced outside the accepted known-issues list
- all P0 checks pass
- all touched systems have an explicit smoke result, not an assumption
- any changed accepted issue is re-evaluated for scope, severity, and workaround status
- the patch does not turn a repo-readiness limitation into a runtime blocker

### Build candidate gate

A build candidate may move forward only if all of the following are true:

- patch gate is already satisfied
- all P1 checks pass on the intended demo path
- there is no unresolved blocker in progression, CampHub/UI, battle telegraph runtime, or SFX routing
- accepted issues are re-listed exactly and nothing else is being implicitly tolerated
- candidate positioning is stated clearly as internal playable, export-ready repo, or packaged build

### Packaged build gate

A packaged build may move forward only if all of the following are true:

- build candidate gate is already satisfied
- matching Godot `4.6.2.stable` export templates are installed on the host
- a real packaging run completes on the target host without new errors
- the produced artifact is launch-verified at least once after packaging

## Move-Forward Rules

Before a build or patch advances, these statements must all be true:

- known accepted issues are written down, finite, and unchanged by accident
- no stop-ship item is open
- every required runner was executed recently enough to support this exact candidate
- release notes distinguish accepted debt from blocked promotion criteria
- confidence is based on observed test evidence, not repo state alone

## Candidate Position

Current interpretation:

- internal playable candidate: yes
- export-configured repository: yes
- host-packaged demo build from this workstation: not yet

## Release Gate Note

This known-issues lock is sufficient for keeping the internal demo lane moving.
It is not sufficient for calling the build export-complete until the host template blocker is cleared.
