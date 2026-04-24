# Manual Play Visual Signoff Checklist V01

## Purpose

Use this checklist after the current headless visual QA suite is green.

This is the final human-pass checklist for battle presentation feel.
It exists to catch issues that scripted runners cannot judge well:

- perceived motion weight
- screen readability under stress
- landmark noticeability during live play
- whether the battle actually feels like a coherent SRPG screen

## Preconditions

Before manual review:

1. Run `/Volumes/AI/tactics/scripts/dev/headless_art_promotion_suite.sh`
2. Confirm [visual_qa_suite_report_v01.md](/Volumes/AI/tactics/docs/generated/visual_qa_suite_report_v01.md) shows `8/8` passing
3. Open a representative battle or real campaign battle in desktop runtime

Quick launch commands:

```bash
/Volumes/AI/tactics/scripts/dev/open_representative_battle.sh ch07
/Volumes/AI/tactics/scripts/dev/open_representative_battle.sh ch09b
/Volumes/AI/tactics/scripts/dev/open_representative_battle.sh ch10
```

Guided launcher:

```bash
/Volumes/AI/tactics/scripts/dev/start_manual_visual_review.sh ch07
/Volumes/AI/tactics/scripts/dev/start_manual_visual_review.sh ch09b
/Volumes/AI/tactics/scripts/dev/start_manual_visual_review.sh ch10
```

## Review Order

### 1. Unit Readability

Check:

- ally units read as battle sprites, not photo-token placeholders
- enemy raider and skirmisher also read as battle sprites
- idle silhouettes remain readable at a glance
- unit colors do not merge into the board surface

Fail if:

- a unit looks like a static portrait card
- ally and enemy units collapse into the same silhouette read
- any unit becomes hard to pick out from the ground layer

### 2. Movement Feel

Check:

- movement reads as tile-by-tile travel, not teleportation
- movement speed feels deliberate, not sluggish
- path-step walk remains readable even with multiple units nearby

Fail if:

- a move still feels like a snap
- path stepping is so slow that the battle drags
- units visually desync from the grid in a distracting way

### 3. Attack Timing

Check:

- melee attacks feel more forceful than ranged attacks
- ranged attacks feel lighter and more directional
- support or mystic actions feel like casting, not generic attack copies

Fail if:

- all attack types feel the same
- melee lacks impact
- support actions feel too violent or too similar to bow attacks

### 4. Hit / Defeat Feel

Check:

- hit reaction visibly changes pose
- defeat reaction visibly collapses or dims
- these reactions read quickly without clutter

Fail if:

- hit looks like no reaction
- defeat looks like a simple disappearance
- pose motion looks exaggerated or comedic

### 5. Board Surface

Check:

- the battlefield floor reads as a real stage surface
- forest and fortress boards clearly differ
- backdrop and board feel like one scene, not two unrelated layers

Fail if:

- the floor still feels empty or abstract
- fortress and forest are distinguishable only by tint
- backdrop feels disconnected from the board

### 6. Chapter Identity

Check on representative scenes:

- `CH07` reads as ritual city / civic warning space
- `CH09B` reads as archive / revision pressure space
- `CH10` reads as final bell / terminal ritual space

Fail if:

- chapter scenes still feel like the same generic battlefield
- shared props dominate over chapter-local landmarks
- chapter-local landmark placement is technically present but visually unimportant

### 7. HUD / Framing

Check:

- top bar and bottom panel feel anchored to the battle frame
- camera framing supports the current chapter landmark focus
- the battlefield remains readable underneath HUD panels

Fail if:

- HUD feels pasted on top of the scene
- chapter-specific framing is not noticeable
- panels cover too much important battle space

## Signoff Rule

A scene passes only if:

- no `Fail if` condition is observed
- the player can correctly describe the chapter-local landmark focus after one glance
- the battle no longer feels placeholder-driven

## Current Focus Scenes

Recommended manual signoff order:

1. `CH07` representative battle
2. `CH09B` representative battle
3. `CH10` representative battle
4. one normal battle with ranged/support usage
5. one normal battle with repeated movement and melee exchanges

## Follow-up Rule

If manual review finds problems:

- log the exact scene
- name the failed category from this checklist
- fix only that category
- rerun headless suite before the next manual pass
