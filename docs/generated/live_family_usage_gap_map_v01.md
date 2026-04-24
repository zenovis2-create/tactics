# Live Family Usage Gap Map V01

## Purpose

This document maps the gap between:

- intended surface usage
- currently documented or authored usage

for the current live runtime family set.

It is the first execution document for the `live family usage expansion` lane.

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

## Surface Intent vs. Current Reality

### Briefing-First Families

Target families:

- `battery`
- `floodgate`
- `chain_control`

Intended state:

- stage preview card
- mission objective strip
- tactical note panel

Current reality:

- the intended briefing copy and surface specs exist in generated docs
- stage-specific authored briefing data now exists for:
  - `CH04_03`
  - `CH06_02`
  - `CH10_05`
- briefing trigger policy now includes:
  - `CH04_03`
  - `CH06_02`
- authored usage is validated through:
  - [briefing_usage_expansion_runner.gd](/Volumes/AI/tactics/scripts/dev/briefing_usage_expansion_runner.gd)

Gap judgment:

- `closed for first pass`
- `further expansion should now be selective`

### Codex-Dossier-First Families

Target families:

- `evidence`
- `bell`

Intended state:

- codex entry card
- dossier record panel
- object reference strip

Current reality:

- the family selection and copy blocks are documented
- a concrete runtime destination now exists through:
  - `Records > Evidence`
- concrete authored entries now exist for:
  - `CH05_03`
  - `CH07_01`
- usage is validated through:
  - [records_evidence_usage_runner.gd](/Volumes/AI/tactics/scripts/dev/records_evidence_usage_runner.gd)

Gap judgment:

- `closed for first pass`
- `further codex-dossier expansion should now be selective`

### Live But Not First-Wave Surface Families

Families:

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

Current reality:

- all five are live in routing and stage data
- all five have production icon promotion
- none currently require immediate first-wave briefing or dossier expansion

Gap judgment:

- `runtime-ready`
- `usage expansion should be selective, not automatic`

## Highest-Value Gaps

### 1. Selective usage review for the remaining five live families

Why it matters most:

- the remaining live families already have runtime value
- the risk is overextending them into the wrong surfaces

Affected families:

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

### 2. Briefing-first refinement gap

Why it matters second:

- the first authored pass is in place
- the remaining work is refinement, not initial authoring

Affected family/stage pairs:

- `floodgate` -> `CH04_03`
- `battery` -> `CH06_02`
- `chain_control` -> `CH10_05`

### 3. Codex-dossier refinement gap

Why it matters third:

- the first concrete records destination is in place
- the remaining work is whether to grow beyond `Records > Evidence`

Affected family/stage pairs:

- `evidence` -> `CH05_03`
- `bell` -> `CH07_01`

## Recommended Execution Order

1. close the briefing data authoring gap
2. define the first concrete codex-dossier runtime destination
3. only then expand surface use for the remaining live families

Current state:

1. briefing data authoring gap: first pass closed
2. first concrete codex-dossier runtime destination: first pass closed
3. surface-use expansion for the remaining live families: now the main open item

## Immediate Next Step

If one concrete production move is chosen next, it should be:

- run selective usage review against:
  - `well`
  - `shrine`
  - `keeper_lectern`
  - `route_marker`
  - `latch`

## Working Conclusion

The first usage-expansion pass has now closed the highest-value authored usage gaps.

The next production gain is no longer initial authored usage.

It is disciplined selective expansion of the remaining live families.
