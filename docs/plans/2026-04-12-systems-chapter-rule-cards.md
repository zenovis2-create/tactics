# Chapter Rule Cards

## 1. Purpose

This document defines the playable rule identity of each chapter.

Each chapter card answers:

- what loop pressure the player learns
- which state systems are introduced or reinforced
- how progression rewards answer that pressure
- how the boss mechanic argues a philosophy
- how the player's counterplay rebuts that philosophy

## 2. Global Rule Card Template

Use this structure for all chapter design and implementation reviews:

- Primary loop pressure
- Signature state delta
- Failure pattern to teach
- Counter-tool reward
- Boss thesis
- Player rebuttal pattern
- Telemetry checks

## 3. Chapter Cards

## Chapter 1: Awakening Under Uncertainty

Primary loop pressure:

- Learn the basic tactical rhythm under low complexity.

Signature state delta:

- Baseline action states and basic status visualization only.

Failure pattern to teach:

- Overextending one unit and breaking formation.

Counter-tool reward:

- First positional command skill that enables ally swap and safe regroup.

Boss thesis:

- "Force and speed solve all disorder."

Player rebuttal pattern:

- Use disciplined positioning and escort play, not reckless burst.

Telemetry checks:

- number of isolated unit defeats
- average turns with no support adjacency

## Chapter 2: Doubt and Responsibility

Primary loop pressure:

- Rescue triage versus route efficiency.

Signature state delta:

- Rescue state, objective timers, and early Oblivion exposure.

Failure pattern to teach:

- Optimizing for kill speed while abandoning rescue timing.

Counter-tool reward:

- Defensive accessory that stabilizes escort and objective survival.

Boss thesis:

- "Collateral is acceptable if the line is held."

Player rebuttal pattern:

- Preserve civilians while still controlling lanes.

Telemetry checks:

- rescue completion rate
- objective-failures before boss engagement

## Chapter 3: First True Loss

Primary loop pressure:

- Ambush anticipation and route uncertainty.

Signature state delta:

- Concealment, trap states, and reveal interactions.

Failure pattern to teach:

- Committing all actions before scouting.

Counter-tool reward:

- Detection and anti-trap utility that trades tempo for safety.

Boss thesis:

- "Fear and confusion decide battles before steel does."

Player rebuttal pattern:

- Probe safely, reveal threat, then collapse with coordinated units.

Telemetry checks:

- trap-trigger frequency
- turns spent in unrevealed hazard zones

## Chapter 4: Faith Versus Truth

Primary loop pressure:

- Dynamic terrain and cleanse timing.

Signature state delta:

- Water-level shifts, purification zones, and stronger Oblivion spread.

Failure pattern to teach:

- Delaying cleanse and letting stack pressure lock action economy.

Counter-tool reward:

- Reliable cleanse cadence and wet-terrain tactical bonus tools.

Boss thesis:

- "Purification means removing pain, memory included."

Player rebuttal pattern:

- Preserve agency through selective cleanse and positional discipline.

Telemetry checks:

- average Oblivion stacks at turn start
- cleanse use timing relative to spike turns

## Chapter 5: Identity Fracture

Primary loop pressure:

- Rule revision and skill sealing pressure.

Signature state delta:

- Seal zones, delayed rule pulses, and anti-control windows.

Failure pattern to teach:

- Static plans that collapse when rules shift mid-battle.

Counter-tool reward:

- Seal mitigation and one-turn flexibility command.

Boss thesis:

- "If the rules are rewritten, your will is irrelevant."

Player rebuttal pattern:

- Adaptive sequencing, preserving optionality and backup lines.

Telemetry checks:

- number of turns with all key skills sealed
- plan-break recoveries within 2 turns

## Chapter 6: Grievance Versus Trust

Primary loop pressure:

- Lane control under artillery prediction and fortress denial.

Signature state delta:

- Bombardment windows, fortification states, and choke control.

Failure pattern to teach:

- Chasing damage into predictable bombardment zones.

Counter-tool reward:

- Fortification-aware defense toolkit and survival trigger options.

Boss thesis:

- "Endurance and force erase the weak."

Player rebuttal pattern:

- Rotate frontline, hold disciplined lanes, and outlast pressure.

Telemetry checks:

- artillery-hit rate on player side
- turns spent in red telegraph zones

## Chapter 7: Is Oblivion Mercy?

Primary loop pressure:

- Multi-target rescue in spreading Oblivion fields.

Signature state delta:

- Expanding hazard fields and escalating rescue prioritization.

Failure pattern to teach:

- Tunnel vision on boss while rescue bandwidth collapses.

Counter-tool reward:

- Area support pattern that converts one emergency collapse into stabilization.

Boss thesis:

- "Forgetting suffering is compassion."

Player rebuttal pattern:

- Save under pressure and keep memory-bearing units operational.

Telemetry checks:

- rescued targets lost after first contact
- Oblivion spread triggers left uncontested

## Chapter 8: Mourning and Chosen Responsibility

Primary loop pressure:

- Infiltration with incomplete truth and identity checks.

Signature state delta:

- Intel objectives, false-positive risk, and evidence validation interactions.

Failure pattern to teach:

- Overcommitting to first interpretation of the map state.

Counter-tool reward:

- Tactical verification tool that confirms high-risk objective states.

Boss thesis:

- "Truth is whatever survives redaction."

Player rebuttal pattern:

- Verify before committing, then execute with coordinated certainty.

Telemetry checks:

- objective misclassification rate
- actions spent on verification interactions

## Chapter 9: Courage to Carry Memory Forward

Primary loop pressure:

- Multi-front final operations with resonance coordination.

Signature state delta:

- Team-linked tower states and end-state commitment tests.

Failure pattern to teach:

- Solo carry attempts that break global synchronization windows.

Counter-tool reward:

- Final command suite favoring team-presence and synchronized action chains.

Boss thesis:

- "Peace requires erasing burden, not sharing it."

Player rebuttal pattern:

- Distributed team presence and shared-risk timing windows.

Telemetry checks:

- synchronization failures per tower cycle
- units contributing to end-state trigger windows

## 4. Thematic Integrity Checks

A chapter fails thematic integrity if any of these occur:

- Boss pattern is mechanically strong but philosophically neutral.
- Counter-tool increases raw stats but does not answer chapter pressure.
- Failure cases come from hidden information instead of readable state.
- Reward loop bypasses the chapter's signature mechanic.

## 5. Sign-Off Criteria

A chapter card is approved only when:

- Systems Designer signs off loop pressure and counterplay intent.
- Gameplay Engineer confirms deterministic implementation path.
- UI Engineer confirms all relevant states are visible in-action.
- QA confirms failure patterns are reproducible and legible.

