# Next Art Production Backlog V01

## Purpose

This backlog turns the current art production system into the next concrete work queue.

The goal is not to list every desired asset.
The goal is to define the next small set of assets that will produce the most validation
per unit of work.

## Selection Rules

Items are prioritized by:

1. how much they validate the pipeline
2. how much they improve in-game readability
3. how reusable they are across multiple stages or units
4. how much they tighten class or environment language

## Recommended Queue

### 1. Enemy Raider Runtime Completion

Type: enemy character

Why first:

- the hostile lane already has a generated anchor
- it closes the gap between ally and enemy comparison
- it validates whether the enemy side can follow the same runtime pipeline cleanly

Deliverables:

- `source -> clean -> runtime` structure
- slicing manifest
- Godot preview extension or hostile preview scene

### 2. Bran Runtime Completion

Type: ally heavy class

Why now:

- Bran is the fourth ally class anchor
- heavy units are the easiest place for silhouette drift to break the style
- finishing Bran completes the ally runtime baseline set

Deliverables:

- source selection lock
- slicing manifest
- runtime frames
- optional heavy-class preview pass

### 3. Paladin Shield Rhino Pass

Type: equipment-support prop

Why now:

- this is the most reusable non-character prop anchor
- it validates Rhino blockout -> render -> review for equipment
- it supports both knight and heavy-class lanes

Deliverables:

- first Rhino blockout
- front / side / 3/4 renders
- review notes

### 4. Altar 01 Visual Pass

Type: interactable prop

Why now:

- objective props are critical to map readability
- altar language touches sacred spaces, evidence points, and objective cues
- it helps align environment and gameplay communication

Deliverables:

- concept support image or Rhino blockout
- icon extraction direction
- board-context readability review

### 5. Forest Tile 01 Card/Icon Pass

Type: terrain tile

Why now:

- tile readability is a core tactical requirement
- forest is one of the most common contrast tests against units
- this validates whether map art can support the new sprite lane without conflict

Deliverables:

- tile card candidate
- tile icon candidate
- in-engine comparison against plain tile and unit overlays

### 6. Tia Runtime Completion

Type: ally ranged class

Why now:

- Tia already has a stable style direction
- ranged classes are sensitive to silhouette and projectile clutter
- this validates move/attack rhythm for hunter-type units

Deliverables:

- source selection lock
- slicing manifest
- runtime frames
- ranger-class playback review

### 7. Enemy Skirmisher Spec And Prompt Pack

Type: enemy variant

Why now:

- the project needs more than one hostile lane to test class distance
- skirmisher behavior and shape can diverge from raider without becoming a separate game

Deliverables:

- spec
- prompt pack
- initial concept generation

### 8. Bran / Rian / Enemy Raider Comparison Pass

Type: comparative review

Why now:

- this is the first true melee-line comparison set
- it validates ally frontline vs ally heavy vs hostile infantry

Deliverables:

- short review note
- any class matrix adjustments

### 9. First Map Screenshot Assembly

Type: integration check

Why now:

- all style systems eventually need one screenshot test
- this proves whether characters, props, and tiles belong to the same screen

Deliverables:

- one composed in-engine frame with at least:
  - Serin
  - Rian
  - Tia
  - Bran
  - enemy raider
  - forest tile
  - objective prop

### 10. Art Review Sweep

Type: production checkpoint

Why now:

- prevents silent drift after early wins
- converts scattered decisions into the next stable baseline

Deliverables:

- accepted baseline list
- rejected baseline list
- next revision targets

## Recommended Execution Order

1. Enemy Raider Runtime Completion
2. Bran Runtime Completion
3. Paladin Shield Rhino Pass
4. Forest Tile 01 Card/Icon Pass
5. Altar 01 Visual Pass
6. Tia Runtime Completion
7. Enemy Skirmisher Spec And Prompt Pack
8. Bran / Rian / Enemy Raider Comparison Pass
9. First Map Screenshot Assembly
10. Art Review Sweep

## Immediate Next Best Task

If only one task is chosen next, choose:

`Enemy Raider Runtime Completion`

Reason:

- it is the shortest remaining gap
- it completes the first hostile production lane
- it upgrades the current system from “ally style lock” to “playable battlefield style lock”

