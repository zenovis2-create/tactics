# Serin Battle-State Pilot Review V01

## Scope

Review target:

- `/Volumes/AI/tactics/docs/generated/serin_battle_state_comparison_board_v01.png`

Compared:

- legacy
- layered

States:

- `idle`
- `cast`
- `attack`

## Verdict

The `Serin` battle-state pilot is good enough to keep as the current layered
candidate set.

The layered version is stronger than legacy in class readability and body
presence.

## Findings

### 1. `idle` preserves support-first identity

The layered `idle` keeps:

- robe read
- staff read
- calm support posture

and stays inside the same world grammar as the current layered baseline.

### 2. `cast` is materially stronger than legacy

The layered `cast` keeps the body readable and avoids the old failure mode of
letting magical emphasis dominate the entire frame.

Current judgment:

- valid support/caster pilot state

### 3. `attack` stays support-lane compatible

The layered `attack` reads as a lighter support-lane action instead of drifting
into frontline melee or offensive-mage spectacle.

Current judgment:

- acceptable pilot-candidate attack state

## Promotion Guidance

Current pilot-candidate source set:

- `source/serin_idle_sheet_source_v02_layered.png`
- `source/serin_cast_sheet_source_v03_layered.png`
- `source/serin_attack_sheet_source_v03_layered.png`

Current runtime-candidate frame export:

- `runtime_v02_layered_candidate/idle/`
- `runtime_v02_layered_candidate/cast/`
- `runtime_v02_layered_candidate/attack/`

## Working Conclusion

The pilot has passed the minimum bar for:

- clean candidate generation
- candidate runtime slicing
- legacy-vs-layered comparison

Next correct move:

1. keep this as the current `Serin` state pilot candidate
2. move to `Tia` state pilot
