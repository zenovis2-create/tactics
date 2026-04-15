# Systems Execution Backlog

## 1. Purpose

This backlog operationalizes the systems design into implementation-ready work packages.

Primary scope:

- combat loops
- state systems
- progression logic
- theme-to-mechanic integrity

Primary references:

- `docs/plans/2026-04-12-systems-combat-progression-design.md`
- `docs/game_spec.md`
- `docs/engineering_rules.md`

## 2. Delivery Milestones

## M1: Deterministic Combat Core

Target outcome:

- Stable battle flow with explicit transitions and fixed resolve order.

Work packages:

- `SYS-001` Implement battle phase enum and transition map in `battle_controller.gd`.
- `SYS-002` Enforce per-unit action states (`READY`, `MOVED`, `ACTED`, `EXHAUSTED`, `DOWNED`) in `turn_manager.gd`.
- `SYS-003` Add transition reason payloads for HUD readability.
- `SYS-004` Add deterministic action resolve pipeline in `combat_service.gd`.

Acceptance criteria:

- No hidden state transition path.
- Same input sequence produces same outcome.
- Transition reason visible in debug UI and logs.

## M2: Status and Oblivion Layer

Target outcome:

- Status interactions are data-driven and predictable.

Work packages:

- `SYS-005` Create `status_service.gd` for stack, duration, and cleanse logic.
- `SYS-006` Implement Oblivion stack effects (1, 2, 3) and Clarity interaction.
- `SYS-007` Implement start-of-turn and action-resolve status hooks.
- `SYS-008` Externalize status definitions under `data/status/`.

Acceptance criteria:

- Oblivion stack behavior exactly matches design values.
- Cleanse behavior is deterministic and unit-testable.
- Status processing order is consistent across all maps.

## M3: Chapter Rule Config and Encounter Hooks

Target outcome:

- Chapter signature mechanics can be configured without script rewrites.

Work packages:

- `SYS-009` Extend `StageData` with chapter mechanic config fields.
- `SYS-010` Implement chapter rule hook dispatcher in `battle_controller.gd`.
- `SYS-011` Add map-side hazard config for spread, pulse, and objective timers.
- `SYS-012` Add challenge objective conditions for bonus rewards.

Acceptance criteria:

- Chapter mechanics load from data resources.
- At least two different chapter rule sets run in same binary without code change.
- Objective timer and hazard behavior are visible in battle debug panel.

## M4: Progression Meta (Memory, Burden, Trust)

Target outcome:

- Campaign-level consequences affect battle in controlled bands.

Work packages:

- `SYS-013` Create `progression_service.gd` ownership for meta-state updates.
- `SYS-014` Implement Burden/Trust counters with `0-9` band effects.
- `SYS-015` Implement memory-fragment command unlock gates.
- `SYS-016` Bind ending tendency flags to Burden/Trust thresholds.

Acceptance criteria:

- Burden/Trust updates are event-driven and logged.
- Command unlocks obey fragment and threshold conditions.
- Ending tendency can be inspected from save or session state.

## M5: Reward Integrity and Anti-Snowball

Target outcome:

- Rewards reinforce mechanics instead of bypassing them.

Work packages:

- `SYS-017` Add reward policy validator for chapter counter-tools.
- `SYS-018` Keep reroll-proof drop seed behavior per full re-entry.
- `SYS-019` Add rule-check encounters where mechanics beat pure stats.
- `SYS-020` Add underpowered safety valves that preserve challenge identity.

Acceptance criteria:

- Optional objective rewards meaningfully change tactics.
- No checkpoint reload exploit for drop reroll.
- Mechanic-check battles fail for rule errors even with strong stats.

## M6: Telemetry and Balance Tuning

Target outcome:

- Balance decisions are evidence-based.

Work packages:

- `SYS-021` Emit telemetry for turns-to-clear, Oblivion applied/cleansed, rescue success, command usage, failure causes.
- `SYS-022` Build chapter-level balance report script under `scripts/`.
- `SYS-023` Define target bands and alert thresholds.
- `SYS-024` Add weekly tuning review checklist.

Acceptance criteria:

- Every completed battle emits complete metric payload.
- Reports identify top 3 failure causes per chapter.
- Tuning changes require telemetry diff in review notes.

## 3. Cross-Team Contract

Systems Designer obligations:

- own rule clarity and progression coherence
- approve chapter mechanic intent before implementation lock
- sign off that boss philosophy is represented mechanically

Gameplay Engineer obligations:

- implement deterministic rule execution and service boundaries
- avoid embedding balance values directly in scene nodes

UI Engineer obligations:

- expose phase, status, and objective state clearly
- surface transition reasons and pending hazards

QA obligations:

- verify state transitions and status order with deterministic test scenarios
- verify chapter signature mechanics and counter-tools
- verify ending tendency thresholds

## 4. Validation Matrix

Pre-merge validation per milestone:

- deterministic replay check
- state transition coverage check
- status pipeline order check
- chapter config hot-swap check
- progression threshold check

Release gate for systems package:

- no unresolved `P0` or `P1` balance blockers
- all chapter signature mechanics have at least one reliable counter-tool
- telemetry pipeline confirmed on real battle runs

## 5. Sequencing and Risk

Recommended execution sequence:

1. M1 Deterministic Combat Core
2. M2 Status and Oblivion Layer
3. M3 Chapter Rule Config
4. M4 Progression Meta
5. M5 Reward Integrity
6. M6 Telemetry and Tuning

Highest risks:

- hidden transition shortcuts causing nondeterministic outcomes
- chapter gimmicks reordering global resolve steps
- meta progression overpowering tactical readability

Risk controls:

- fixed resolve pipeline contract tests
- chapter hook interface with strict boundaries
- Burden/Trust band-limited effects with hard caps

