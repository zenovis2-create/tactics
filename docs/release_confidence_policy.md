# Release Confidence Policy

This document defines the QA test priorities and promotion gates for any build or patch candidate.

Use it alongside `docs/milestone_runnable_gates.md`:

- `milestone_runnable_gates.md` defines milestone-specific scope expectations.
- This document defines whether a candidate is safe to move forward.

## 1. Promotion States

### Patch-ready

A targeted fix can move forward only when:

- the candidate passes `P0` structural integrity
- the candidate passes every automated runner that exercises the changed system
- the candidate passes every runner in the same player-facing surface if the fix touched shared orchestration, save-free session state, or UI composition
- no new crash, softlock, broken routing, or content-resolution error is introduced
- manual smoke confirms the reported bug is fixed and no obvious adjacent regression remains

### Build-ready

A broader build candidate can move forward only when:

- the candidate passes `P0`, `P1`, and the active-lane gate set in `P2`
- the candidate passes all `P3` suites for any content families touched by the build
- manual smoke is complete for the active lane
- no open `critical` or `high` severity gameplay regression remains in the scoped content
- out-of-scope systems were not added as a shortcut to satisfy the gate

### Demo-ready / release-ready

A public-facing candidate can move forward only when:

- the build-ready gate is green
- platform/export validation for the target surface is complete
- touch readability and session-completion smoke are verified on the target play surface
- known issues are either fixed or explicitly accepted by leadership with no progression-loss risk

## 2. Test Priority Ladder

Always run tests in this order. Do not spend time on broader content suites while a higher tier is red.

### `P0` Structural integrity

Purpose: prove the project still boots and all resource references resolve.

Must pass on every candidate:

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . --quit`

Stop condition:

- any missing file, broken `res://` reference, parse error, or boot failure blocks promotion immediately

### `P1` Core loop stability

Purpose: prove the baseline combat loop still works.

Must pass on every build candidate and on any patch that touches battle flow, shared services, or turn-state logic:

- `godot4 --headless --path . --script res://scripts/dev/m1_core_loop_contract_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m1_playtest_runner.gd`

Stop condition:

- any failure in selection, movement, attack/wait resolution, phase transitions, or victory/defeat handling blocks promotion

### `P2` Active-lane progression gate

Purpose: prove the currently shippable production lane is still coherent end to end.

Must pass on every build candidate for the current Chapter 1 shell and on any patch that touches campaign flow, camp state, or shell UI:

- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m3_ui_runner.gd`

Manual smoke required:

- one full player path through the active lane
- one camp/session review of the player-facing reward and records surfaces
- one readability pass on desktop-sized and mobile-sized layouts when UI changed

Stop condition:

- any broken stage routing, empty camp surface, unreadable state cue, or shell softlock blocks promotion

### `P3` Change-targeted regression families

Purpose: prove deeper systems remain stable without requiring every lane to run on every small patch.

Run every relevant family touched by the change:

- Invoke each runner as `godot4 --headless --path . --script <runner>`.

#### Loadout / roster / camp interaction

- `res://scripts/dev/equipment_slot_runner.gd`
- `res://scripts/dev/equipment_restriction_runner.gd`
- `res://scripts/dev/accessory_equipment_runner.gd`
- `res://scripts/dev/midgame_accessory_runner.gd`
- `res://scripts/dev/lategame_accessory_runner.gd`
- `res://scripts/dev/final_chapter_accessory_runner.gd`
- `res://scripts/dev/final_equipment_slot_runner.gd`
- `res://scripts/dev/sortie_assignment_runner.gd`
- `res://scripts/dev/three_person_sortie_runner.gd`
- `res://scripts/dev/four_person_sortie_runner.gd`
- `res://scripts/dev/five_person_sortie_runner.gd`

#### Boss pattern / gimmick behavior

- `res://scripts/dev/ch01_05_boss_runner.gd`
- `res://scripts/dev/extended_boss_pattern_runner.gd`
- `res://scripts/dev/ch06_line_control_runner.gd`

#### Authored objective chains / chapter scenario rules

- `res://scripts/dev/ch02_fortress_controls_runner.gd`
- `res://scripts/dev/ch03_forest_investigation_runner.gd`
- `res://scripts/dev/ch04_flood_route_runner.gd`
- `res://scripts/dev/ch05_archive_pressure_runner.gd`
- `res://scripts/dev/ch07_procession_control_runner.gd`
- `res://scripts/dev/ch08_route_pressure_runner.gd`
- `res://scripts/dev/ch08_production_runner.gd`
- `res://scripts/dev/ch09a_broken_standard_runner.gd`
- `res://scripts/dev/ch09b_revision_runner.gd`
- `res://scripts/dev/ch10_tower_chain_runner.gd`

#### Later-campaign shell continuity

- `res://scripts/dev/ch02_shell_runner.gd`
- `res://scripts/dev/ch03_shell_runner.gd`
- `res://scripts/dev/ch04_shell_runner.gd`
- `res://scripts/dev/ch05_shell_runner.gd`
- `res://scripts/dev/ch06_shell_runner.gd`
- `res://scripts/dev/ch07_shell_runner.gd`
- `res://scripts/dev/ch08_shell_runner.gd`
- `res://scripts/dev/ch09_shell_runner.gd`
- `res://scripts/dev/ch10_shell_runner.gd`

#### Presentation / feedback integration

- `res://scripts/dev/battle_telegraph_runtime_runner.gd`
- `res://scripts/dev/sfx_trigger_integration_runner.gd`

#### Data scaffold / compatibility integrity

- `res://scripts/dev/class_job_scaffold_runner.gd`

Stop condition:

- any runner covering the touched family failing is a promotion blocker, even if `P0` through `P2` are green

## 2.5 Required Gates By Change Surface

Choose gates by the highest-risk surface touched. If a change spans multiple surfaces, run the union of every required gate below.

### Scene wiring / resources / boot path

Required gates:

- `P0`

Examples:

- `.tscn` ext_resource changes
- `.tres` script/resource reference changes
- `project.godot` boot path changes
- scene composition changes under `Main`, battle, cutscene, or camp roots

### Battle orchestration / turn state / AI / shared services

Required gates:

- `P0`
- `P1`
- `P2` if the change can alter how battle completion hands off into shell progression

Examples:

- `BattleController`
- `AIService`
- movement, action-state, target-selection, or victory/defeat flow

### Campaign progression / cutscene handoff / CampHub shell

Required gates:

- `P0`
- `P1`
- `P2`

Examples:

- ordered stage routing
- cutscene-to-stage or stage-to-camp transitions
- campaign payload generation
- CampHub mode, recommendation, section, badge, or records-surface behavior

### Loadout / roster / inventory / sortie rules

Required gates:

- `P0`
- `P3` loadout / roster / camp interaction family
- `P2` as well when the touched data is rendered in the active CampHub lane

Examples:

- equipment slot restrictions
- accessory assignment
- roster composition
- sortie capacity or deployment rules

### Boss scripts / gimmicks / encounter-specific rule hooks

Required gates:

- `P0`
- `P1`
- `P3` boss pattern / gimmick family
- `P2` as well when the encounter is inside the active Chapter 1 shell

Examples:

- interactive-object resolution tied to encounter flow
- boss phase behavior
- chapter rule hooks that change win-condition or combat rhythm

### Authored stage objectives / interactable chains / chapter scenario rules

Required gates:

- `P0`
- `P1`
- `P3` authored objective chains / chapter scenario rules family
- `P2` as well when the touched scenario is inside the active Chapter 1 shell

Examples:

- stage-specific objective text or objective-state transitions
- authored interaction count, order, or gate-open sequencing
- chapter battle rules that depend on authored interactables rather than generic combat flow

### HUD feedback / telegraph / audio-event routing

Required gates:

- `P0`
- `P1` when the change touches battle HUD timing or phase messaging
- `P2` when the change is visible in camp or shell UI
- `P3` presentation / feedback integration family

Examples:

- telegraph cards, preview textures, or telegraph labels
- audio cue routing across battle, camp, or shell surfaces
- HUD state cues whose failure would mislead the player even when progression still technically works

### Data scaffold / class-job compatibility

Required gates:

- `P0`
- `P3` data scaffold / compatibility integrity family
- `P3` loadout / roster / camp interaction family as well when the change alters equip compatibility or roster behavior

Examples:

- `UnitData`, `ClassData`, or `JobData` compatibility wiring
- allowed weapon or armor type resolution
- scaffold changes that can silently invalidate future roster/loadout behavior

### Later-chapter shell or content continuity

Required gates:

- `P0`
- `P3` later-campaign shell continuity family for every chapter touched

Examples:

- later chapter route tables
- chapter-specific camp payloads
- post-Chapter-1 shell continuity fixes

## 3. Severity-Based Quality Gates

Promotion is blocked when any of the following remain reproducible in scoped content:

- `Critical`: crash, hard lock, corrupted session state, impossible progression, or missing required scene/data payload
- `High`: wrong stage order, broken battle completion, broken recruit/unlock propagation, invalid equipment restriction, or boss-pattern failure that changes encounter resolution
- `Medium`: misleading UI state, missing badge/count, incorrect recommendation text, or readability issue that does not block completion
- `Low`: cosmetic mismatch, copy issue, minor animation/layout polish issue

Rules:

- `Critical` and `High` defects must be fixed before any build or patch moves forward.
- `Medium` defects can ship only if explicitly accepted and documented, and only when they do not hide state the player needs to progress.
- `Low` defects never override a red automated gate.

## 4. What Must Be True Before Promotion

Before a build or patch moves forward, all of the following must be true:

1. The candidate still boots headless and resolves all resources.
2. Every automated gate required by the changed surface has passed in the candidate workspace.
3. The candidate was smoke-tested on the player path most likely to expose the changed behavior.
4. No regression was waived merely because it exists in later content; touched-family runners still decide promotion.
5. The change did not pull new meta systems, persistence behavior, or release-phase scope into the current lane as a shortcut.
6. QA can state which exact commands were run, which manual path was covered, and which known issues remain.
7. The required gate set was selected from the changed surface, not from the author's estimate of likely impact.
8. If a shared controller or payload producer changed, adjacent player-facing surfaces were exercised even when the reported bug looked isolated.

## 5. Minimum Evidence to Attach to a Gate Decision

Every promotion decision should record:

- commit or candidate identifier
- commands run
- pass/fail result per tier
- manual smoke path covered
- unresolved issues and accepted risk, if any

Without this evidence, the candidate is not considered promoted.
