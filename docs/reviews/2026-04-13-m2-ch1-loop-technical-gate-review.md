# M2 Chapter 1 Loop Technical Gate Review (2026-04-13)

## Scope

Review target:

- `production_backlog.md` M2 section
- `phase1.md`
- `camp.md`
- `camp_ui_spec.md`
- `data_schema.md`
- current repo surface under `scenes/`, `scripts/`, and `data/`
- active implementation tickets `ASH-21`, `ASH-22`, and `ASH-23`

## Verdict

The M2 lane is correctly aimed at Chapter 1 loop completion, but it needs a strict ownership split to stay maintainable.

- Current repo baseline is still primarily M1 battle/runtime infrastructure.
- M2 work should add chapter flow glue, lightweight camp entry, and read-only record views.
- M2 should not introduce persistence, equipment meta, monetization, or broader post-MVP camp systems.

## Current Repo Baseline

Present now:

- battle runtime scenes and services
- one tutorial stage resource
- interactive object support
- no `scenes/ui/camp` or `scripts/ui/camp` layer yet
- no `data/text/` authored cutscene, memory, evidence, or letter payloads yet
- no visible chapter progression/session state module yet

This is acceptable as a starting point for M2, but it means the integration contract must be explicit before implementation spreads across multiple tickets.

## Ownership Split

### `ASH-22` gameplay/content layer

Own:

- Chapter 1 battle-content resources and stage-specific rules for `CH01_02` through `CH01_05`
- battle-local triggers, spawn timing, interactables, and win/loss data
- content hooks that emit progression results

Do not own:

- global chapter routing
- camp scene transitions
- camp UI layout
- persistence

### `ASH-21` integration layer

Own:

- main scene wiring into the campaign shell
- stage registry / stage-chain lookup
- stage chain order
- battle clear to cutscene to camp transition routing
- in-memory chapter session state
- minimal progression glue for recruit/evidence/memory unlock propagation

Do not own:

- battle-map authored content for individual stages
- CampHub screen composition
- save/load
- equipment/inventory/meta systems

### `ASH-23` camp/UI layer

Own:

- `CampHub` scene flow
- party summary presentation
- memory/evidence/letter read-only views
- post-clear camp entry presentation

Do not own:

- source-of-truth progression calculations
- recruit/evidence unlock rules
- save/load behavior
- equipment, inventory, forge, or hunt flows from later milestones

## Required Technical Contract

M2 should use a single volatile session-state owner for chapter flow.

Required rules:

1. Keep Chapter 1 progression in memory only for M2.
2. Do not write save files or introduce save schema coupling.
3. Keep `StageData` battle-local; do not overload it with full chapter routing or camp UI state.
4. Expose progression results as explicit data/events that CampHub can read without re-deriving logic.
5. Treat memory/evidence/letter views as read-only surfaces over authored data plus current session unlock state.

Recommended module boundary:

- `scripts/progression/` or `scripts/campaign/` for chapter session state and routing
- `data/text/` for authored cutscene, memory, evidence, and letter payloads
- `scripts/ui/camp/` and `scenes/ui/camp/` for CampHub presentation only

## Scope Guard

Allowed for M2:

- Chapter 1 stage chain
- minimal cutscene handoff
- camp entry after clear
- Serin formal recruit reflection in party summary
- evidence/memory/letter read-only skeletons
- next-destination explanation grounded in evidence log

Blocked for M2:

- save/load
- inventory and equipment flows
- monetization, DLC, store entitlements
- random-drop expansion
- post-Chapter-1 meta systems
- broad camp menu expansion beyond the minimal M2 record hub

## Risks

### Integration junk-drawer risk

If `ASH-21` starts owning authored content or UI state directly, it will become an unmaintainable glue layer.

### Premature persistence risk

`camp_ui_spec.md` describes later save-connected behavior, but `production_backlog.md` explicitly keeps M2 session-only. M2 must not backdoor persistence through convenience helpers.

### Camp overbuild risk

`camp_ui_spec.md` is a full-campaign document. `ASH-23` should implement only the M2 subset: hub entry, party summary, and record views.

## M2 Done Gates

Before M2 can be called technically complete, require all of the following:

1. `CH01_01` through `CH01_05` can be played in one session with valid transitions.
2. Battle clear can route into the required interlude/camp step without manual scene hacking.
3. Serin formal recruitment is reflected in the session state and camp summary.
4. Memory/evidence/letter views render from authored data plus current unlock state.
5. No persistence, equipment meta, or monetization code is introduced to satisfy the above.
6. Existing runnable checks still pass after each handoff.
