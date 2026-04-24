# Fun Upgrade Implementation Checklist

> Source spec: `docs/plans/2026-04-24-fun-upgrade-reference-spec.md`

## Operating Rules

- Work in order unless a blocker requires a smaller prerequisite.
- Keep each implementation slice small and runner-backed.
- Do not pull/rebase/push during feature implementation unless explicitly requested.
- Save/load runner suites must run serially.
- After core battle changes, run the relevant runner first, then the final gate when the slice is complete.

---

## Phase 0 — Baseline and guardrails

- [x] Confirm current branch state.
  - Command: `git status --short --branch`
- [x] Confirm final gate starts green.
  - Command: `python3 /tmp/tactics_final_gate.py`
  - Expected: `TOTAL=37 PASS=37 FAIL=0`
- [x] Create or confirm a safety branch/tag before implementation.
  - Current known backup: `backup/pre-release-split-20260424-142928`
- [x] Confirm target files for first slice.
  - Likely files:
    - `scripts/battle/battle_controller.gd`
    - `scripts/battle/battle_hud.gd`
    - `scripts/dev/lategame_boss_pattern_runner.gd`
    - `scripts/dev/ch06_ch10_boss_surface_runner.gd`
    - new `scripts/dev/boss_lock_break_runner.gd`

---

## Phase 1 — Boss Lock Break foundation

### 1.1 Runtime state model

- [x] Add minimal boss lock state storage.
  - File: `scripts/battle/battle_controller.gd`
  - Add dictionary like `boss_lock_state_by_unit`.
- [x] Add helper to create lock state.
  - Candidate function: `_start_boss_lock(unit, action_id, display_name, countdown, locks_required, failure_text, break_text)`
- [x] Add helper to clear lock state on battle end/stage reset.
- [x] Add snapshot helper for runner/HUD.
  - Candidate: `get_boss_lock_state_snapshot()`

Verification:

- [x] Run parse check for changed scripts.
- [x] Add initial runner assertion that lock state can be created and read.

### 1.2 Lock progress events

- [x] Add helper to increment lock progress.
  - Candidate: `_progress_boss_lock(unit, lock_type, amount := 1)`
- [x] Support first lock types:
  - `strike`
  - `skill`
  - `object`
  - `name`
  - `cleanse`
- [x] Mark `broken = true` when all requirements are met.
- [x] Ensure excess progress is capped at required amount.

Verification:

- [x] Runner asserts partial progress.
- [x] Runner asserts completed lock becomes broken.

### 1.3 Hook strike/skill/object/name/cleanse into progress

- [x] Direct attack hook progresses `strike` when target is locked boss.
- [x] Skill hook progresses `skill` when target is locked boss.
- [x] Interaction hook progresses `object` for relevant boss lock.
- [x] Name command/name-call hook progresses `name`.
- [x] Cleanse/status reduction hook progresses `cleanse`.

Verification:

- [x] `boss_lock_break_runner.gd` covers at least one hook per lock type using controlled calls.

### 1.4 Boss-specific lock definitions

- [x] CH06_05 Valgar lock:
  - `strike` x1
  - `object` x1
- [x] CH07_05 Saria lock:
  - `name` x1
  - `cleanse` x1
- [x] CH08_05 Lete lock:
  - `object` x1
  - `skill` x1
- [x] CH09B_05 Melkion lock:
  - `object` x1
  - `name` or `skill` x1
- [x] CH10_05 Karuon lock:
  - `object` x2
  - `name` x1

Verification:

- [x] `boss_lock_break_runner.gd` covers all target bosses.
- [x] Existing boss runners still pass.

### 1.5 Broken/failure outcome

- [x] Broken lock downgrades or cancels charged action.
- [x] Failed lock applies existing pressure, not instant wipe.
- [x] Result/transition text records whether lock was broken.

Verification:

- [x] Runner asserts broken lock changes action outcome.
- [x] Runner asserts unbroken lock still behaves predictably.

---

## Phase 2 — Enemy intent clarity

### 2.1 HUD snapshot and text

- [x] Add lock/intent text to HUD surface.
  - File: `scripts/battle/battle_hud.gd`
- [x] Include:
  - action display name
  - countdown
  - progress `current/required`
  - failure consequence
  - break reward
- [x] Add snapshot field for headless assertions.

Verification:

- [x] `boss_lock_break_runner.gd` asserts HUD intent text includes action and lock requirements.

### 2.2 Boss intent examples

- [x] Valgar text mentions fortify/order pressure.
- [x] Saria text mentions forgetting/charm pressure.
- [x] Lete text mentions chase/pincer pressure.
- [x] Melkion text mentions archive rewrite.
- [x] Karuon text mentions Final Toll / bell / anchor.

Verification:

- [x] `lategame_boss_pattern_runner.gd` still passes.
- [x] `ch06_ch10_boss_surface_runner.gd` still passes.

---

## Phase 3 — Memory / Oblivion clarity

### 3.1 Threshold copy

- [x] Define readable stack threshold labels:
  - 0: normal
  - 1: warning
  - 2: restricted / unstable
  - 3: severe / recoverable
- [x] Surface the label in HUD or status snapshot.

Verification:

- [x] `status_service_runner.gd` or a new focused runner asserts threshold labels.

### 3.2 Recovery hooks

- [x] Name command can reduce or block memory pressure where appropriate.
- [x] Stage object relief text explains memory pressure reduction.
- [x] Result screen can mention memory recovery when relevant.

Verification:

- [x] `true_ending_runner.gd` passes.
- [x] `ending_criteria_ui_runner.gd` passes.
- [x] `postgame_surface_runner.gd` passes.

---

## Phase 4 — Pre-battle planning upgrade

### 4.1 Briefing threat fields

- [x] Add or reuse briefing payload fields:
  - `primary_threat`
  - `formation_hint`
  - `first_turn_warning`
  - `useful_counterplay`
- [x] Add copy for CH06_05 through CH10_05 first.

Verification:

- [x] Shell runners CH06 through CH10 pass.
- [x] CH10_05 briefing still advances to battle.

### 4.2 Briefing UI assertion

- [x] Runner asserts briefing body includes at least one threat/counterplay hint for CH10_05.
- [x] No overflow/empty body regression.

Verification:

- [x] `ch10_shell_runner.gd` passes.
- [x] `campaign_save_to_title_load_runner.gd` passes if campaign panel payload changed.

---

## Phase 5 — Bonus EXP / result reward upgrade

### 5.1 Result tags

- [x] Add result tags:
  - MVP
  - Resolved object
  - Broke boss lock
  - Used name call
  - Cleansed oblivion
- [x] Keep current bonus EXP formula unchanged in first pass.

Verification:

- [x] `battle_result_runner.gd` passes.
- [x] `campaign_save_load_core_loop_runner.gd` passes.

### 5.2 Recommendation copy

- [x] Add “recommended bonus target” copy for underleveled units if data is available.
- [x] If data is not reliable, add only non-mechanical reward copy.

Verification:

- [x] `save_load_runner.gd` passes.
- [x] `battle_result_runner.gd` passes.

---

## Phase 6 — Unit matchup / terrain identity surface

### 6.1 Terrain identity hints

- [ ] Add chapter-specific terrain hint copy without changing formulas.
- [ ] Prioritize:
  - CH03 forest
  - CH04 flooded monastery
  - CH05 archive
  - CH10 final tower

Verification:

- [ ] Relevant shell runners pass.
- [ ] Visual/HUD runners pass if text surface changed.

### 6.2 Unit role readability

- [ ] Expose role/type labels in unit snapshot or HUD if already available.
- [ ] Avoid damage formula changes in this phase.

Verification:

- [ ] `ui_screens_runner.gd` passes.
- [ ] `ch02_ch05_boss_pattern_runner.gd` passes.

---

## Phase 7 — Recall battles / memory revisit

### 7.1 First memory trial

- [ ] Pick one target boss first: recommended Saria or Karuon.
- [ ] Add recall/memory trial entry using existing recall/hunt infrastructure.
- [ ] Ensure it cannot corrupt main campaign progression.

Verification:

- [ ] `recall_hunt_runner.gd` or related recall runner passes.
- [ ] `save_load_core_loop_runner.gd` passes.

### 7.2 Expand to major bosses

- [ ] Basil memory trial.
- [ ] Saria memory trial.
- [ ] Lete memory trial.
- [ ] Melkion memory trial.
- [ ] Karuon memory trial.

Verification:

- [ ] Recall runner covers all entries.
- [ ] Final gate passes.

---

## Phase 8 — Battle UI command shortcuts

### 8.1 Command hint surface

- [ ] Add selected-unit command hint text:
  - Attack
  - Skill
  - Wait
  - Guard / Name Anchor
  - Interact when adjacent
- [ ] Keep existing click flow intact.

Verification:

- [ ] `manual_input_click_runner.gd` passes.
- [ ] `ui_screens_runner.gd` passes.

### 8.2 Optional shortcut input

- [ ] Only after hint surface is stable, add actual shortcut input mapping.
- [ ] Must not break mouse/touch-first flow.

Verification:

- [ ] Manual input runner passes.
- [ ] Final gate passes.

---

## Phase 9 — Final release candidate verification

- [ ] Run focused runner for the last changed feature.
- [ ] Run final gate.
  - Command: `python3 /tmp/tactics_final_gate.py`
  - Expected: `TOTAL=37 PASS=37 FAIL=0`
- [ ] Review `git diff --stat`.
- [ ] Create small commit for the completed phase.
- [ ] Update this checklist status if any phase is deferred.

---

## First execution recommendation

Start with:

1. Phase 1.1 Runtime state model
2. Phase 1.2 Lock progress events
3. New `boss_lock_break_runner.gd`

Do not start with all five bosses at once. First prove one lock path, then expand.
