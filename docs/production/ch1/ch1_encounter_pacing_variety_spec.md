# CH1 Encounter Pacing, Goals, and Reward Variety

## Purpose

This document owns the player-experience layer of `Chapter 1: 이름 없는 새벽` one mission at a time.

It defines:

- encounter pacing by mission
- the core gimmick each mission teaches
- primary and optional map goals
- reward intent and chapter-level reward texture
- chapter-wide variety rules so the five maps feel like a rising sequence instead of five small skirmishes

Source-of-truth priority:

1. Structural canon and chapter reward lock: `camp.md`, `master_campaign_outline.md`
2. Mission data, trigger timings, and dialogue lock: `phase1.md`
3. Emotional intent and presentation lock: `ch1_map_emotional_purpose.md`
4. Cross-team gameplay/UI/art guardrails: `ch1_handoff_gameplay_ui_art_marketing.md`
5. This document: player-facing pacing, goal texture, and reward shaping

If this document conflicts with exact coordinates, turn counts, or authored dialogue, `phase1.md` wins.

## Chapter 1 Experience Targets

- Battle length target: `5-8 minutes` for `CH01_01` to `CH01_04`, `6-9 minutes` for `CH01_05`
- Cognitive load curve: `basic actions -> escort pressure -> interaction tension -> tactical puzzle -> boss read-and-respond`
- Emotional curve: `panic -> responsibility -> unease -> competence with fear -> exposed resolve`
- Objective curve: `hold -> escort -> investigate and exit -> solve and defend -> defeat boss`
- Reward curve: `consumable safety -> escort validation -> exploration validation -> civic gratitude -> command unlock and chapter handoff`

Chapter 1 should never repeat the same closure feeling twice in a row.

- `CH01_01` ends with survival relief.
- `CH01_02` ends with fragile success from protection.
- `CH01_03` ends with information and unease.
- `CH01_04` ends with tactical accomplishment mixed with suspicion.
- `CH01_05` ends with confrontation, clarity, and forward momentum.

## Mission Variety Grid

| Map ID | Combat Role | Core Ask | Mid-Mission Pivot | Primary Goal Shape | Optional Goal Shape | Reward Feeling |
| --- | --- | --- | --- | --- | --- | --- |
| `CH01_01` | tutorial holdout | learn move, attack, heal, wait under pressure | turn-2 fire spread and turn-3 panic civilian | defend zone and keep at least one civilian alive | save both civilians | emergency relief |
| `CH01_02` | escort chase | protect weak units while advancing | rear reinforcement and Neri fear slowdown | evacuate at least two civilians in time | full escort | moral validation |
| `CH01_03` | investigation ambush | interact safely and choose when to commit | first search spawns ambush, well triggers memory shock | resolve investigations and extract | clear in 7 turns | quiet discovery |
| `CH01_04` | tactical gate puzzle | split attention across levers, angles, and hold timing | first lever opens side pressure, gate forces one-turn defense | operate both levers and hold control node | keep both militia alive | earned trust |
| `CH01_05` | boss exam | read telegraph, reposition, and punish windows | boss 60% event plus hound reinforcement | defeat Roderic | clear in 6 turns | chapter breakthrough |

## Chapter-Level Pacing Rules

### 1. No two consecutive maps may use the same dominant fail state

- `CH01_01`: fail by panic and overextension
- `CH01_02`: fail by escort collapse
- `CH01_03`: fail by wasted tempo or bad scouting
- `CH01_04`: fail by lane misallocation
- `CH01_05`: fail by ignoring telegraph and mark focus

### 2. Every mission must add one new question and reuse one prior lesson

- `CH01_01`: new `basic actions`; reused `none`
- `CH01_02`: new `escort`; reused `formation discipline`
- `CH01_03`: new `interaction and ambush`; reused `protect weak unit positioning`
- `CH01_04`: new `multi-point objective puzzle`; reused `tempo control and terrain use`
- `CH01_05`: new `boss telegraph response`; reused `escort-style protection and terrain reading`

### 3. The chapter should alternate between external pressure and internal uncertainty

- external pressure maps: `CH01_01`, `CH01_02`, `CH01_05`
- internal uncertainty maps: `CH01_03`, `CH01_04`

### 4. Optional rewards should reinforce the intended lesson, not raw aggression

- reward protection, timing, and composure
- do not reward pure enemy wipe speed in maps whose core fantasy is rescue or investigation

## Reward Policy for Chapter 1

Chapter 1 rewards should feel useful immediately but still small enough to protect the low-complexity onboarding lane.

Allowed reward types:

- consumables
- one low-complexity accessory
- chapter memory fragment or evidence payload
- formal recruit and command unlock on chapter clear

Blocked in Chapter 1:

- random drops
- permanent build branching
- equipment menu expansion beyond the locked chapter-clear unlocks
- rewards that encourage reckless kill-racing over protection play

Reward intent by tier:

- base clear reward: acknowledge success and restock safety
- optional reward: affirm the map's featured behavior
- chapter-end reward: change future tactics, not just numbers

## Mission Specs

### CH01_01 불타는 사당

Mission purpose:

- teach the absolute basics without feeling like a sandbox
- establish that saving civilians matters immediately

Pacing:

- opening `0-2 minutes`: short panic setup, first move/attack/heal decisions
- pressure spike `2-4 minutes`: turn-2 fire spread and reinforcement ask the player to stop playing linearly
- closure `4-6 minutes`: turn-3 civilian panic creates one last protection test before the hold finishes

Gimmick package:

- burning tiles punish standing still
- stair defense tile demonstrates positional value
- panic civilian moment reframes the map from "kill nearby enemy" to "stabilize the space"

Map goals:

- primary: survive until turn 4 while holding the shrine front and preserving at least one civilian
- optional: keep both civilians alive

Reward design:

- base: `응급약 x2`
- optional: one extra emergency item for perfect civilian protection
- emotional reward: the name `RIAN` and the first identity anchor

Variety note:

- this map must feel reactive and cramped, not strategic in a broad sense
- do not overpopulate it with interactables or side rewards

### CH01_02 잿빛 들판

Mission purpose:

- convert the player from "I can win fights" to "I can move a vulnerable group through danger"
- make Serin's trust rise because the player protected, not because the player killed quickly

Pacing:

- opening `0-2 minutes`: establish the escort shape and safe marching order
- pursuit phase `2-5 minutes`: enemy front pressure asks the player to screen and rotate
- rear-collapse moment `5-7 minutes`: turn-3 reinforcements and Neri slowdown force triage
- extraction `7-8 minutes`: final push to east exit should feel narrow but still recoverable

Gimmick package:

- escort icon and exit line create a clear route promise
- ash and broken carts make path choice matter without becoming a maze
- Neri fear event personalizes the escort burden

Map goals:

- primary: evacuate at least two of three civilians within the turn limit
- optional: evacuate all three, ideally with Rian personally covering Neri for the extra trust beat

Reward design:

- base: one healing refill plus simple thrown utility
- optional: one protection-flavored consumable or accessory seed
- narrative reward: Neri survival becomes a future-world continuity anchor

Variety note:

- the player should spend more turns moving east than attacking
- if combat density slows escort movement too much, the map has lost its identity

### CH01_03 폐허의 우물

Mission purpose:

- give the chapter a breath without becoming low-stakes
- teach that interaction objectives can be more important than wiping the board

Pacing:

- opening `0-2 minutes`: cautious advance and route reading
- first reveal `2-4 minutes`: first interaction turns quiet exploration into ambush response
- memory disturbance `4-6 minutes`: well interaction briefly destabilizes confidence
- extraction `6-8 minutes`: finish remaining searches and leave before attrition or overcommitment

Gimmick package:

- investigation points create intent before combat
- hidden enemies punish autopilot movement
- well interaction combines utility with narrative disturbance
- optional destructible shortcut rewards map reading

Map goals:

- primary: resolve all required investigation points and extract both leads
- optional: clear in `7 turns` to reward decisive but not reckless routing

Reward design:

- base: one resource item plus one low-power trinket that reads as scavenged, not militarized
- optional: small sustain refill for efficient route execution
- narrative reward: the chapter's first strong sense that Rian may have authored strategy, not merely survived it

Variety note:

- combat should puncture the silence, not dominate every turn
- this is the chapter's information map; keep its reward tone quieter than the others

### CH01_04 북쪽 관문

Mission purpose:

- deliver the chapter's most deliberate tactical puzzle
- prove the player can coordinate space, timing, and pressure instead of solving one lane at a time

Pacing:

- opening `0-2 minutes`: identify both levers, enemy sightlines, and the central hold problem
- split execution `2-5 minutes`: first lever activation escalates the board and forces lane ownership
- gate defense `5-7 minutes`: once the gate opens, the mission pivots from solving to holding
- payoff `7-8 minutes`: one-turn defense produces earned relief rather than attrition grind

Gimmick package:

- paired levers prevent single-lane tunnel vision
- side reinforcement after first lever stops degenerate sequencing
- high ground and ladder pressure reward target priority
- one-turn control-node defense gives a clean, understandable finale

Map goals:

- primary: activate both levers, operate the gate, then defend the control point for one turn
- optional: keep both militia NPCs alive through the operation

Reward design:

- base: small resupply for the push into the boss
- optional: one civic or militia-flavored accessory that says "the people you protected noticed"
- narrative reward: Serin's fear sharpens because Rian's tactical fluency is now undeniable

Variety note:

- this map is the chapter's highest planning density point
- it should feel more like solving a live mechanism than surviving a swarm

### CH01_05 새벽의 서약

Mission purpose:

- exam the chapter's lessons in a short boss fight
- turn Rian's unknown past from abstract unease into immediate danger

Pacing:

- opening `0-2 minutes`: establish fog, spacing, and the fact that Roderic is reading Rian specifically
- first exchanges `2-4 minutes`: boss mark telegraph teaches read-then-reposition discipline
- reveal spike `4-6 minutes`: 60% boss event plus hound reinforcements threaten collapse if the player tunnels
- finish `6-9 minutes`: identify one safe burst window and close before panic returns

Gimmick package:

- mark icon plus red-line telegraph is the chapter's first explicit boss language
- fog softens ranged pressure early so melee positioning stays readable
- hound reinforcement punishes stationary backline play after the midpoint

Map goals:

- primary: defeat Roderic
- optional: clear within `6 turns` without letting the telegraph rules become ignorable

Reward design:

- base: `Serin formal recruit`, `Rian tactical swap command`, and one small chapter-clear accessory
- optional: modest sustain item only; the real reward is system expansion and chapter progression
- narrative reward: first major memory fragment plus hard confirmation that the Empire is hunting Rian for a reason

Variety note:

- this should be the chapter's only map where "focus the boss" is the clean end state
- keep the encounter short, readable, and loaded with implication rather than making it a stat wall

## Reward Texture Across the Chapter

Use this cadence so the player feels momentum without early-system bloat:

| Map ID | Base Reward Feeling | Optional Reward Feeling | Why It Exists |
| --- | --- | --- | --- |
| `CH01_01` | emergency relief | perfect protection bonus | validates saving people in the tutorial |
| `CH01_02` | escort sustain | full rescue affirmation | proves protection is rewarded |
| `CH01_03` | scavenged utility | efficient-routing bonus | supports exploration and tempo |
| `CH01_04` | push-prep resupply | civic gratitude accessory | pays off tactical coordination |
| `CH01_05` | chapter unlock | small speed-clear top-off | reserves the real payoff for command and recruit progression |

Reward clarity rules:

- Optional rewards must be understandable from the mission fantasy alone.
- The player should be able to guess the bonus condition before seeing the result screen.
- The best Chapter 1 rewards are trust-building and safety-building, not power-spike rewards.

## Implementation Handoff Notes

For current M2 shell work:

- `CH01_02` through `CH01_05` should use this document as the player-experience target.
- Current `data/stages/ch01_02_stage.tres` through `ch01_05_stage.tres` are valid shell placeholders, but they do not yet express the full pacing and objective texture defined here.
- When stage-specific rules are expanded, preserve each map's dominant identity before adding enemy count.

Priority order for authored battle-content expansion:

1. objective scripting and failure messaging
2. mid-mission pivots and telegraphs
3. optional reward condition surfacing
4. only then encounter-density tuning

## Review Checklist

- Does each map have a distinct goal shape from the previous one?
- Does the optional reward reinforce the featured lesson instead of brute-force aggression?
- Does the mid-mission pivot arrive early enough to matter but late enough to surprise?
- Does `CH01_05` feel like a synthesis test, not a difficulty spike for its own sake?
- Does chapter completion change the player's future tactical options through recruit and command unlocks?
