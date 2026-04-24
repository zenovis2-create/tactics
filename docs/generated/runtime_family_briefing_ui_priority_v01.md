# Runtime Family Briefing UI Priority V01

This note selects which live runtime object families should appear first on
stage preview cards, mission briefings, and other pre-battle summary surfaces.

It is intentionally narrower than the full runtime family list.

The question is not whether a family is live.

The question is whether showing it before deployment improves tactical planning.

## Current Live Runtime Families

- `well`
- `battery`
- `shrine`
- `floodgate`
- `evidence`
- `bell`
- `chain_control`
- `keeper_lectern`
- `route_marker`
- `latch`

## Selection Rule

A family should appear in briefing UI only if all three conditions hold:

1. the object is central to the stage contract
2. the player can change decisions based on that information before deployment
3. the icon still reads clearly without in-scene staging

## Briefing UI First Wave

These are the families that should be allowed first on mission-preview and
briefing surfaces.

### 1. `battery`

Reason:

- siege-pressure stages are easier to read when the battery line is explicit
- artillery or line-control pressure changes deployment and route choice
- the icon remains legible at small briefing scale

Primary stage fit:

- `CH06_02`

Representative authored objects:

- [ch06_02_west_battery_winch.tres](/Volumes/AI/tactics/data/objects/ch06_02_west_battery_winch.tres)
- [ch06_02_east_battery_winch.tres](/Volumes/AI/tactics/data/objects/ch06_02_east_battery_winch.tres)

### 2. `floodgate`

Reason:

- water-state control is a strategic promise, not just a scene detail
- showing it early helps players anticipate route-state changes
- the family has a strong mechanical read distinct from `gate_control`

Primary stage fit:

- `CH04_03`

Representative authored objects:

- [ch04_03_west_sluice_wheel.tres](/Volumes/AI/tactics/data/objects/ch04_03_west_sluice_wheel.tres)
- [ch04_03_east_sluice_wheel.tres](/Volumes/AI/tactics/data/objects/ch04_03_east_sluice_wheel.tres)

### 3. `chain_control`

Reason:

- terminal release and bell-line suppression are endgame planning signals
- the object has clear pre-battle importance, not just runtime interaction value
- it gives CH10 a stronger mission identity before stage start

Primary stage fit:

- `CH10_05`

Representative authored object:

- [ch10_05_anchor_chain.tres](/Volumes/AI/tactics/data/objects/ch10_05_anchor_chain.tres)

## Briefing UI Second Wave

These families are valid, but should wait until first-wave usage is stable.

### `evidence`

Why second wave:

- archive truth pressure is important, but it is more narrative-facing than
  route-planning-facing
- better suited to dossier and codex surfaces than universal briefing use

### `bell`

Why second wave:

- CH07 queue-bell logic is real, but its meaning depends more heavily on city
  ritual framing than on immediate tactical planning
- use only when the stage intro explicitly foregrounds procession or public
  control pressure

## Hold For Briefing UI

These families are live, but should not be standard briefing UI elements.

### `well`

Reason:

- investigation and memory disturbance usually read better in-stage than in a
  pre-battle card
- it is more discovery-facing than deployment-facing

### `shrine`

Reason:

- hidden ritual and route-reading marker logic is valuable during play, but less
  reliable as a generic pre-briefing symbol
- better used in codex or chapter-specific explainer surfaces first

## Recommended Briefing Matrix

| Family | Briefing status | Reason |
| --- | --- | --- |
| `battery` | First wave | Strong route and pressure planning signal |
| `floodgate` | First wave | Water-state and route-state planning signal |
| `chain_control` | First wave | Endgame terminal-control planning signal |
| `evidence` | Second wave | More narrative-facing than deployment-facing |
| `bell` | Second wave | Valid but depends on stronger chapter framing |
| `well` | Hold | Discovery-facing, not deployment-facing |
| `shrine` | Hold | Better in codex or chapter explainer surfaces |

## Immediate Follow-up

The next useful step is not adding more families to briefing UI.

It is defining the exact briefing surfaces for the first wave:

1. stage preview card
2. mission objective strip
3. chapter intro / tactical note panel
