# Runtime Family Codex Dossier Surface Spec V01

This document fixes the first-wave codex and dossier surfaces for live runtime
object families.

It translates the selection in
[runtime_family_codex_dossier_priority_v01.md](/Volumes/AI/tactics/docs/generated/runtime_family_codex_dossier_priority_v01.md)
into concrete UI slots.

This spec only covers the first-wave dossier families:

- `evidence`
- `bell`

## Scope

The first-wave dossier rollout should use exactly three surfaces:

1. codex entry card
2. dossier record panel
3. object reference strip

It should not introduce family-specific extra views yet.

## 1. Codex Entry Card

### Purpose

Give the player a stable, searchable object-family identity outside immediate
battle context.

### Content Rule

- one family per card
- strong title
- one-line category text
- one short explanatory paragraph

### First-Wave Mapping

| Family | Card title | Category line |
| --- | --- | --- |
| `evidence` | `Evidence Control` | `Archive witness and truth-bearing control object.` |
| `bell` | `Bell Frame` | `Civic warning and public-control ritual object.` |

### Paragraph Rule

- two sentences maximum
- explain what the object means in the world
- do not explain encounter tactics here

### Example Direction

`evidence`

- focuses on archive authority, witness logic, and seal-bound truth

`bell`

- focuses on procession pressure, public warning, and civic ritual authority

## 2. Dossier Record Panel

### Purpose

Provide a slightly denser reference surface that can sit inside a records,
archive, or chapter-dossier view.

### Content Rule

- title
- category line
- one short paragraph
- one allowed comparison pairing

### First-Wave Mapping

| Family | Allowed comparison pairing |
| --- | --- |
| `evidence` | compare against `altar`, not against `battery` |
| `bell` | compare against `altar` or `city_seal`, not against `lever` |

### Comparison Rule

- the comparison must clarify meaning, not just silhouette
- use one comparison target only
- avoid broad family walls or multi-column taxonomy here

### Reasoning

- `evidence` needs separation from generic sacred-object grammar
- `bell` needs separation from generic local mechanism grammar

## 3. Object Reference Strip

### Purpose

Give a compact companion surface for chapter sheets, record pages, or codex
subsections.

### Content Rule

- icon
- short label
- no paragraph text

### First-Wave Mapping

| Family | Strip label |
| --- | --- |
| `evidence` | `Evidence` |
| `bell` | `Bell` |

### Rule

- use this strip only as supporting navigation or quick-reference material
- it should never replace the codex entry card

## Surface Exclusions

The following are out of scope for first-wave dossier rollout:

- mission briefing cards
- objective strips
- inventory or loot slots
- battle reward summaries
- chapter-start tactical notes

Reason:

- dossier surfaces are for identity, recall, and category framing
- briefing surfaces are for action and deployment framing

## Family-Specific Guidance

### `evidence`

Best fit:

- archive codex
- object record pages
- truth / witness reference surfaces

Do not frame as:

- a generic sacred relic
- a loot object
- a terrain hazard

### `bell`

Best fit:

- civic records
- city-control dossiers
- chapter-local ritual authority references

Do not frame as:

- a generic lever replacement
- a neutral mechanism object
- a universal mission-preview symbol

## Implementation Gate

Do not expand dossier first-wave beyond `evidence` and `bell` until:

1. the two families have stable wording
2. their card treatment reads clearly without stage screenshots
3. their comparison targets are locked

## Immediate Follow-up

The next useful step after this spec is:

1. draft actual briefing text for `CH04_03`, `CH06_02`, and `CH10_05`
2. or define dossier copy blocks for `evidence` and `bell`
