# Runtime Family Briefing Surface Spec V01

This document fixes the first-wave briefing surfaces for live runtime object
families.

It translates the selection in
[runtime_family_briefing_ui_priority_v01.md](/Volumes/AI/tactics/docs/generated/runtime_family_briefing_ui_priority_v01.md)
into concrete UI slots.

It is meant to guide briefing implementation, not expand the family list.

## Scope

This spec only covers the first-wave briefing families:

- `battery`
- `floodgate`
- `chain_control`

These correspond to current primary stage fits:

- `battery` -> `CH06_02`
- `floodgate` -> `CH04_03`
- `chain_control` -> `CH10_05`

Related briefing system references:

- [FARLAND_TACTICS_POST_SPRINT7_FEATURE_SPEC.md](/Volumes/AI/tactics/docs/FARLAND_TACTICS_POST_SPRINT7_FEATURE_SPEC.md)
- [briefing_runner.gd](/Volumes/AI/tactics/scripts/dev/briefing_runner.gd)

## Surface Set

The first wave should use exactly three briefing surfaces:

1. stage preview card
2. mission objective strip
3. tactical note panel

It should not add new family-specific surfaces yet.

## 1. Stage Preview Card

### Purpose

Give the player a fast visual read of the stage-defining interaction object
before deployment.

### Content Rule

- show one dominant family icon only
- use the family only if it is central to the stage contract
- pair it with one short label, not a sentence block

### First-Wave Mapping

| Stage family | Preview label | Why it belongs here |
| --- | --- | --- |
| `battery` | `Battery Line` | signals siege pressure and line-control risk |
| `floodgate` | `Flood Control` | signals route-state and water-state change |
| `chain_control` | `Anchor Chain` | signals terminal release and bell-line suppression |

### Visual Rule

- icon first
- short noun phrase second
- no chapter-lore paragraph inside the preview card

## 2. Mission Objective Strip

### Purpose

Make the stage contract legible in one line before battle starts.

### Content Rule

- this strip may mention the family only if the object is tied to a primary or
  explicit secondary objective
- use verb-oriented phrasing

### First-Wave Mapping

| Stage family | Objective-strip pattern |
| --- | --- |
| `battery` | `Disable the battery line.` |
| `floodgate` | `Secure the flood controls.` |
| `chain_control` | `Release the anchor chain.` |

### Writing Rule

- imperative verb first
- one object noun second
- avoid lore wording like `sacred`, `ancient`, `forgotten`, or `ominous`
  in this strip

## 3. Tactical Note Panel

### Purpose

Explain why the object matters to deployment planning.

### Content Rule

- this panel is the only first-wave slot allowed to carry a short explanatory
  sentence
- explanation must change how the player thinks about terrain, route, or tempo

### First-Wave Mapping

| Stage family | Tactical-note pattern |
| --- | --- |
| `battery` | `Battery emplacements pressure the central line. Avoid open advance without cover.` |
| `floodgate` | `Flood controls can change route safety. Expect terrain state to matter after interaction.` |
| `chain_control` | `The anchor chain governs the final route. Securing it changes the endgame approach.` |

### Length Rule

- one sentence preferred
- two short sentences maximum
- if a note needs more than that, it belongs in chapter dialogue or codex, not
  in briefing UI

## Surface Exclusions

The following are explicitly out of scope for first-wave briefing rollout:

- dossier cards
- codex entries
- inventory or loot surfaces
- chapter-lore detail panes
- multi-family comparison blocks

Reason:

- first-wave briefing must stay action-facing and deployment-facing
- these extra surfaces would blur the difference between briefing, codex, and
  archive UI

## Stage-by-Stage First-Wave Usage

### `CH04_03`

- preview card: `floodgate`
- objective strip: `Secure the flood controls.`
- tactical note: route-state warning tied to water control

### `CH06_02`

- preview card: `battery`
- objective strip: `Disable the battery line.`
- tactical note: line-pressure and cover warning

### `CH10_05`

- preview card: `chain_control`
- objective strip: `Release the anchor chain.`
- tactical note: terminal-route warning

## Implementation Gate

Do not expand first-wave briefing surfaces to other families until:

1. the three first-wave families render cleanly in briefing mode
2. the wording survives runner-based validation
3. the panel remains readable without turning into codex UI

## Immediate Follow-up

The next useful step after this spec is:

1. define codex / dossier first-wave families
2. wire briefing data text for `CH04_03`, `CH06_02`, and `CH10_05`
3. verify briefing snapshots once those stage strings are authored
