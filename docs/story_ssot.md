# Story SSOT

## 1. Purpose

This document is the source-of-truth map for story development.

Its job is to answer four questions clearly:

1. Which files are canonical for story decisions
2. Which files are mixed story/system workbench docs
3. Which chapter beats are locked, partially locked, or still draft
4. Which rules future story writing must not violate

## 2. Canon Locks

The following are currently locked and should be treated as canon unless explicitly revised.

### Core Theme

- Central question:
  - Must people erase painful memory to reach peace, or can they move forward while still remembering?

### Story-Mechanic Pillars

- `망각` is a world-defining threat, not a generic debuff theme
- `기억 조각` must always connect narrative recovery and gameplay growth
- `인연 보조` must reinforce the idea that burden shared is better than burden carried alone

### Protagonist Truth Structure

- Rian was not an innocent outsider
- Rian was tied to the empire as `제로`
- Early memory fragments must make him look worse before later context reinterprets them
- The late-game reveal is not full absolution; it is recontextualization

### Antagonist Philosophy

- Karuon must feel persuasive to broken people, not cartoonishly evil
- His ideology must be shown through citizens, clergy, and soldiers, not only through boss dialogue

### Recurring NPC

- Neri is the fixed recurring civilian callback NPC
- Neri appears first in Chapter 1, is referenced in Chapter 5, reappears in Chapter 7, and resolves in the true ending

### Campaign Connection Rule

Every chapter ending should leave behind:

- next destination evidence
- current interpretation of the recovered memory fragment
- short camp resonance dialogue

### Chapter 9 Exception

- Total campaign count remains 10 chapters
- Chapter 9 is the only structural exception
- Chapter 9 splits into:
  - Part I: `부서진 군기`
  - Part II: `기록의 심연`

## 3. Canon Source Map

### Primary Story Canon

- `master_campaign_outline.md`
  - campaign-wide integrated outline
  - chapter connection logic
  - memory-fragment interpretation ladder
  - system unlock tempo
  - ending flag summary

- `synopsis.md`
  - top-level story bible
  - theme, character roles, enemy philosophy, ending meaning

- `camp.md`
  - canonical chapter order
  - chapter titles
  - chapter centers of gravity
  - subchapter rhythm

### Chapter-Detail Canon

- `phase1.md`
  - Chapter 1 detailed implementation canon

- `phase2.md`
  - Chapter 2 detailed implementation canon
  - also contains system expansion notes

- `phase3+item.md`
  - Chapter 3 detailed implementation canon
  - also contains equipment and drop-system notes

- `phase4.md`
  - Chapter 4 story canon lives in section `2. docs/ch04_spec.md`
  - section `1` and section `3` are mixed system/UI workbench content, not primary story canon

- `phase5+@.md`
  - chapter-linking rules canon
  - incomplete-memory-fragment interpretation rule canon
  - Chapter 5 detailed story canon
  - Chapter 9 Part I / Part II structure canon
  - some item/drop notes are mixed system workbench content

- `phase6.md`
  - Chapter 6 detailed implementation canon

- `phase7.md`
  - Chapter 7 detailed implementation canon

- `phase8.md`
  - Chapter 8 detailed implementation canon

- `phase9-1.md`
  - Chapter 9 Part I detailed implementation canon

- `phase9-2.md`
  - Chapter 9 Part II detailed implementation canon

- `phase10.md`
  - Chapter 10 detailed implementation canon

### Mixed but Non-Canonical for Story Order

- `docs/final_glossary.md`
- `docs/character_sheets.md`
- `docs/ending_conditions_standard.md`
- `flag_progression_spec.md`
- `memory_fragments.md`
- `ai_behavior_spec.md`
- `boss_loot_tables.md`
- `equipment_system.md`
- `camp_ui_spec.md`
- `docs/game_spec.md`
- `docs/engineering_rules.md`
- `docs/codex_workflow.md`
- equipment and camp UI sections in `phase4.md`
- equipment/drop sections in `phase3+item.md`

These may inform implementation, but they must not override chapter order, theme, or character motivation.

## 4. Chapter Lock Status

| Chapter | Status | Current Canon Source |
| --- | --- | --- |
| 1. 이름 없는 새벽 | locked | `camp.md`, `phase1.md`, `synopsis.md` |
| 2. 부서진 국경요새 | locked | `camp.md`, `phase2.md`, `synopsis.md` |
| 3. 속삭이는 녹영숲 | partially locked | `camp.md`, `phase3+item.md`, `synopsis.md` |
| 4. 가라앉은 수도원 | partially locked | `camp.md`, `phase4.md`, `synopsis.md` |
| 5. 재의 서고 | partially locked | `camp.md`, `phase5+@.md`, `synopsis.md` |
| 6. 철성의 맹세 | partially locked | `camp.md`, `phase6.md`, `synopsis.md` |
| 7. 이름을 잃는 도시 | partially locked | `camp.md`, `phase7.md`, `synopsis.md` |
| 8. 흑견의 밤 | partially locked | `camp.md`, `phase8.md`, `synopsis.md` |
| 9. 부서진 군기 / 기록의 심연 | partially locked | `phase9-1.md`, `phase9-2.md`, `synopsis.md` |
| 10. 무명의 탑 | partially locked | `phase10.md`, `camp.md`, `synopsis.md` |

## 5. Authoring Rules

### Rule 1: No Chapter Writing Without Evidence Flow

Every new chapter doc must define:

- why the party goes there next
- what physical evidence points them there
- how that evidence changes the party's interpretation of the last memory fragment

### Rule 2: Memory Fragments Are Not Verdicts

Early and mid-game fragments must be partial, biased, or incomplete.

Do not write them as courtroom proof.
Write them as fragments that invite the wrong conclusion first, then gain context later.

### Rule 3: Camp Dialogue Must Rebind the Chapter

After major chapter beats, camp resonance dialogue should do one of three jobs:

- reframe the current clue
- show disagreement about Rian
- connect loot, clue, and theme back together

### Rule 4: System Docs Cannot Rewrite Canon

If a system/workbench document implies a different chapter order, villain role, or emotional resolution than `synopsis.md` plus this file, the story canon wins.

### Rule 5: Story First Before More Meta Systems

Until Chapters 7 to 10 are locked more fully:

- do not expand live-ops fiction
- do not let itemization dictate chapter pacing
- do not let meta systems redefine chapter identity

## 6. Immediate Story Work Priority

The highest-value remaining story tasks are:

1. Reconcile any lingering campaign one-line summaries with `master_campaign_outline.md`
2. Keep `final_glossary.md`, `character_sheets.md`, `ending_conditions_standard.md`, `flag_progression_spec.md`, and `memory_fragments.md` aligned with later phase revisions
3. Keep system expansion subordinate to the remaining story lock work
4. Only after that, expand post-clear and live-facing fiction if still desired

Those four steps should happen before major additional system expansion.
