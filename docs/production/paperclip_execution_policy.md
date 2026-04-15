# Paperclip Execution Policy

## Purpose

This document defines how the active Paperclip company should execute production work in `잿빛의 기억`.
It exists to prevent broad issues from stalling, to keep active lanes inside scope, and to ensure that progress is measured by concrete outputs rather than vague activity.

## Core Rules

### 1. Umbrella vs Child Issues

- Broad production themes belong in umbrella issues.
- Real execution belongs in child issues.
- Umbrella issues should be used by coordination and sequencing owners.
- Child issues should be used by implementation or asset owners.

### 2. WIP Limit

- Execution agents should hold at most one `in_progress` child issue at a time.
- Extra child issues should remain `todo` until the current active child is closed or blocked.
- Coordination owners may keep multiple umbrella issues open if they are sequencing work rather than directly producing deliverables.

### 3. Artifact-First Completion

- A child issue is not complete because it was discussed.
- A child issue is complete when it leaves one or more concrete outputs:
  - code file
  - scene file
  - runner
  - review doc
  - production md
  - image artifact
  - audio cue map
- Every completed child should make it easy to point to the result by path.

### 4. Runner-Backed Execution

- Gameplay and UI changes should add or reuse a runner whenever practical.
- If a change cannot be verified by an existing runner or gate, the owner should either:
  - add a small validation path, or
  - leave a blocker comment naming the missing validation.

### 5. Blocker Comment Contract

- Every blocker comment should include:
  - exact missing dependency
  - next owner
  - expected output
  - resume condition
- Blockers without routing details are treated as incomplete analysis.

## Scope Locks

### Active Production Scope

- CampHub loadout UX
- chapter gimmick production passes
- map readability kits
- in-game SFX cue maps
- in-game icon packs
- in-game FX and telegraph packs
- chapter cutscene, dialogue, and event presentation passes

### Out Of Scope

- save/load and other large state systems
- monetization, IAP, storefront, and publishing execution
- community, liveops, and marketing operations
- story canon rewrites

## Save/Load Freeze

- Save/load remains frozen until the production lanes above stabilize.
- It should not be reopened casually as a convenience task.
- Reopening should happen only after the active production lanes have enough stable runners and presentation/UI flow is no longer shifting every cycle.

## Current Operating Pattern

- Keep umbrella issues for:
  - sequencing
  - dependency routing
  - scope fences
- Keep child issues for:
  - chapter-specific gimmicks
  - concrete UI passes
  - asset sub-packs
  - chapter-specific presentation passes

## Success Condition

Paperclip execution is considered healthy when:

- active child issues are small
- each active lane is producing concrete outputs
- blocked work is routed clearly
- nightly automation keeps moving from one agent to the next without dying on the first heartbeat
