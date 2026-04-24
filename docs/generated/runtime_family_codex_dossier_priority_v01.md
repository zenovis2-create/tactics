# Runtime Family Codex Dossier Priority V01

This document selects which live runtime object families should appear first on
codex, dossier, and records-style UI surfaces.

It complements briefing UI planning.

Briefing surfaces answer:

- what should the player know before deployment

Codex and dossier surfaces answer:

- what should the player be able to identify, remember, and compare outside the
  immediate battle scene

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

A family belongs on codex or dossier surfaces first if:

1. it retains meaning outside direct battle pacing
2. it represents a stable chapter-local category, not just one puzzle state
3. it benefits from reference, recall, or archival framing

## Codex / Dossier First Wave

### 1. `evidence`

Reason:

- CH05 archive truth pressure is naturally records-facing
- the family already reads as a witness, seal, or archive-control category
- it benefits from explanation and recall more than from repeated briefing use

Best-fit surfaces:

- archive codex entries
- object record pages
- chapter-local reference sheets

Primary stage anchor:

- `CH05_03`

Representative object:

- [ch05_03_upper_stack_seal.tres](/Volumes/AI/tactics/data/objects/ch05_03_upper_stack_seal.tres)

### 2. `bell`

Reason:

- CH07 civic ritual pressure has stronger records and authority framing than
  deployment framing
- the family benefits from contextual explanation about warning, procession, and
  public-control meaning
- it is clearer in a dossier than in a universal mission-preview slot

Best-fit surfaces:

- civic object codex entries
- city-control dossier panels
- chapter-local ritual object references

Primary stage anchor:

- `CH07_01`

Representative object:

- [ch07_01_queue_bell.tres](/Volumes/AI/tactics/data/objects/ch07_01_queue_bell.tres)

## Codex / Dossier Second Wave

These families are valid later additions, but not the first dossier wave.

### `well`

Why second wave:

- it has strong identity, but it is more encounter-discovery-facing than
  archival-reference-facing

### `shrine`

Why second wave:

- chapter-local ritual markers benefit from codex treatment, but the family
  should first stabilize through live stage usage

### `battery`

Why second wave:

- battery objects are readable in codex, but their strongest value is still
  stage planning and battlefield pressure

## Hold For Codex / Dossier

These families should not be first-wave dossier targets.

### `floodgate`

Reason:

- flood-state machinery is more mission-logic-facing than archive-facing

### `chain_control`

Reason:

- endgame terminal-control objects are strong stage symbols, but weaker as
  reusable records categories

## Recommended Codex Matrix

| Family | Codex / dossier status | Reason |
| --- | --- | --- |
| `evidence` | First wave | archive truth and witness-control category |
| `bell` | First wave | civic ritual and public-warning category |
| `well` | Second wave | meaningful, but more discovery-facing |
| `shrine` | Second wave | useful with more stage-proven context |
| `battery` | Second wave | stronger in planning than in archive framing |
| `floodgate` | Hold | mission-logic-facing rather than records-facing |
| `chain_control` | Hold | terminal stage symbol, weak reusable dossier read |

## Surface Guidance

For first-wave dossier rollout, use exactly these surfaces:

1. codex entry card
2. dossier record panel
3. object reference strip

Do not yet use:

- mission-preview cards
- equipment inventory
- general loot or reward UI

## Immediate Follow-up

The next useful step is defining the exact dossier slots for:

1. `evidence`
2. `bell`

That means:

- title treatment
- one-line category text
- one short explanatory paragraph
- allowed comparison pairing
