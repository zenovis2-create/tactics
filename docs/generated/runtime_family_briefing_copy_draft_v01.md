# Runtime Family Briefing Copy Draft V01

This document provides stage-ready first-wave briefing copy for the three
selected runtime families:

- `floodgate`
- `battery`
- `chain_control`

It is derived from:

- [runtime_family_briefing_ui_priority_v01.md](/Volumes/AI/tactics/docs/generated/runtime_family_briefing_ui_priority_v01.md)
- [runtime_family_briefing_surface_spec_v01.md](/Volumes/AI/tactics/docs/generated/runtime_family_briefing_surface_spec_v01.md)

This is draft copy, not final localization.

## Output Format

Each stage gets:

1. preview label
2. objective strip
3. tactical note

The wording is intentionally short so it can survive briefing-panel constraints.

## CH04_03

### Family

- `floodgate`

### Preview Label

- `Flood Control`

### Objective Strip

- `Secure the flood controls.`

### Tactical Note

- `Flood controls can change route safety. Expect terrain state to shift after interaction.`

### Intent

- this should make the player think about route-state change before deployment
- it should not read like lore or shrine text

## CH06_02

### Family

- `battery`

### Preview Label

- `Battery Line`

### Objective Strip

- `Disable the battery line.`

### Tactical Note

- `Battery emplacements pressure the central line. Avoid open advance without cover.`

### Intent

- this should warn about line pressure and deployment geometry
- it should read as a siege problem, not a generic mechanism problem

## CH10_05

### Family

- `chain_control`

### Preview Label

- `Anchor Chain`

### Objective Strip

- `Release the anchor chain.`

### Tactical Note

- `The anchor chain governs the final route. Securing it changes the endgame approach.`

### Intent

- this should frame the object as endgame control, not as background machinery
- it should hint that route relief changes the final push

## Writing Guardrails

Apply these rules if the copy is later revised:

1. keep the preview label to a short noun phrase
2. keep the objective strip imperative and concrete
3. keep the tactical note to one or two short sentences
4. avoid lore adjectives unless they change planning value
5. do not let the wording drift toward codex or dossier tone

## Candidate Wiring Target

If this copy is promoted into briefing data, the likely implementation home is:

- [campaign_shell_dialogue_catalog.gd](/Volumes/AI/tactics/scripts/campaign/campaign_shell_dialogue_catalog.gd)

Related validation path:

- [briefing_runner.gd](/Volumes/AI/tactics/scripts/dev/briefing_runner.gd)

## Immediate Follow-up

The next useful step is either:

1. convert this copy into actual briefing catalog entries
2. draft codex / dossier copy blocks for `evidence` and `bell`
