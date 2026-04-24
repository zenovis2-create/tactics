# Runtime Object Family UI Surface Scope V01

This note defines where the current live runtime object families should appear
outside stage logic.

It exists to answer three questions:

1. which families are stage-only for now
2. which families should already appear in player-facing UI
3. which surfaces should stay shared rather than chapter-local

Current live runtime families:

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

Shared baseline families that remain broadly reusable:

- `altar`
- `lever`
- `gate_control`

## Surface Classes

### 1. Production object icon path

This is the lowest-risk shared runtime surface.

Current live chapter-local icons already promoted:

- [memory_well.png](/Volumes/AI/tactics/assets/ui/production/object_icons/memory_well.png)
- [battery_emplacement.png](/Volumes/AI/tactics/assets/ui/production/object_icons/battery_emplacement.png)
- [resin_shrine.png](/Volumes/AI/tactics/assets/ui/production/object_icons/resin_shrine.png)
- [floodgate_wheel.png](/Volumes/AI/tactics/assets/ui/production/object_icons/floodgate_wheel.png)
- [truth_dais.png](/Volumes/AI/tactics/assets/ui/production/object_icons/truth_dais.png)
- [bell_frame.png](/Volumes/AI/tactics/assets/ui/production/object_icons/bell_frame.png)
- [anchor_chain.png](/Volumes/AI/tactics/assets/ui/production/object_icons/anchor_chain.png)
- [archive_lectern.png](/Volumes/AI/tactics/assets/ui/production/object_icons/archive_lectern.png)
- [split_marker_post.png](/Volumes/AI/tactics/assets/ui/production/object_icons/split_marker_post.png)
- [transfer_gate_latch.png](/Volumes/AI/tactics/assets/ui/production/object_icons/transfer_gate_latch.png)

Status:

- `well`: live
- `battery`: live
- `shrine`: live
- `floodgate`: live
- `evidence`: live
- `bell`: live
- `chain_control`: live
- `keeper_lectern`: live
- `route_marker`: live
- `latch`: live

### 2. In-battle object markers

This is the highest-priority live surface because it directly affects tactical
readability.

Current rule:

- every live runtime family must support an in-battle marker contract
- these should remain distinct from `altar`, `lever`, and `gate_control`

Already covered in code:

- [interactive_object_actor.gd](/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd)

### 3. Stage-authored object data

This is the second live surface because it proves the family is not just visual.

Current authored usage:

- `well`: [ch01_03_ruined_well.tres](/Volumes/AI/tactics/data/objects/ch01_03_ruined_well.tres)
- `battery`: [ch06_02_west_battery_winch.tres](/Volumes/AI/tactics/data/objects/ch06_02_west_battery_winch.tres), [ch06_02_east_battery_winch.tres](/Volumes/AI/tactics/data/objects/ch06_02_east_battery_winch.tres)
- `shrine`: [ch03_01_west_trail_marker.tres](/Volumes/AI/tactics/data/objects/ch03_01_west_trail_marker.tres), [ch03_01_east_trail_marker.tres](/Volumes/AI/tactics/data/objects/ch03_01_east_trail_marker.tres)
- `floodgate`: [ch04_03_west_sluice_wheel.tres](/Volumes/AI/tactics/data/objects/ch04_03_west_sluice_wheel.tres), [ch04_03_east_sluice_wheel.tres](/Volumes/AI/tactics/data/objects/ch04_03_east_sluice_wheel.tres)
- `evidence`: [ch05_03_upper_stack_seal.tres](/Volumes/AI/tactics/data/objects/ch05_03_upper_stack_seal.tres)
- `bell`: [ch07_01_queue_bell.tres](/Volumes/AI/tactics/data/objects/ch07_01_queue_bell.tres)
- `chain_control`: [ch10_05_anchor_chain.tres](/Volumes/AI/tactics/data/objects/ch10_05_anchor_chain.tres)
- `keeper_lectern`: [ch09b_05_archive_lectern.tres](/Volumes/AI/tactics/data/objects/ch09b_05_archive_lectern.tres)
- `route_marker`: [ch08_01_east_signal_post.tres](/Volumes/AI/tactics/data/objects/ch08_01_east_signal_post.tres)
- `latch`: [ch08_05_transfer_gate_latch.tres](/Volumes/AI/tactics/data/objects/ch08_05_transfer_gate_latch.tres)

### 4. Object codex / dossier UI

This is a medium-priority surface.

Recommendation:

- add only families with clear gameplay identity
- do not add chapter-local families just because they have icons

Promote first:

- `well`
- `battery`
- `shrine`
- `evidence`

Promote second:

- `floodgate`
- `bell`
- `chain_control`
- `keeper_lectern`

Reason:

- the first group reads as stable object categories even outside chapter context
- the second group still depends more heavily on stage framing or chapter-local mediation

Hold for codex-first promotion:

- `route_marker`
- `latch`

Reason:

- both are highly legible in battle and stage logic
- but both are still weaker as codex-grade standalone categories than the families above

### 5. Stage preview / mission briefing UI

This is a high-value but selective surface.

Use when:

- the object is central to the stage contract
- the object changes how the player reads the encounter before deployment

Good fits:

- `battery` in siege-pressure stages
- `floodgate` in water-state stages
- `chain_control` in terminal-control stages
- `route_marker` in route-commitment stages

Conditional fits:

- `bell` only if CH07 briefing explicitly foregrounds civic control pressure
- `evidence` only if CH05 archive truth pressure is part of the briefing promise
- `latch` only if the release-state relief is central to pre-battle planning

### 6. Generic inventory / loot UI

Do not use live object families here by default.

Reason:

- these are interaction-object families, not portable equipment families
- reusing them in loot or inventory UI would blur the line between scene grammar
  and collectible item grammar

## Recommended Surface Matrix

| Family | Battle marker | Stage data | Briefing UI | Codex UI | Inventory UI |
| --- | --- | --- | --- | --- | --- |
| `well` | Yes | Yes | Conditional | Yes | No |
| `battery` | Yes | Yes | Yes | Yes | No |
| `shrine` | Yes | Yes | Conditional | Yes | No |
| `floodgate` | Yes | Yes | Yes | Conditional | No |
| `evidence` | Yes | Yes | Conditional | Yes | No |
| `bell` | Yes | Yes | Conditional | Conditional | No |
| `chain_control` | Yes | Yes | Yes | Conditional | No |
| `keeper_lectern` | Yes | Yes | No | Conditional | No |
| `route_marker` | Yes | Yes | Conditional | Conditional | No |
| `latch` | Yes | Yes | Conditional | No | No |

## Practical Rule Set

1. A live runtime family must first prove itself in `battle marker + stage data`.
2. Briefing UI is allowed only when the family is central to pre-battle planning.
3. Codex UI is allowed only when the family still reads clearly outside chapter
   staging.
4. Inventory UI should keep using equipment grammar, not interaction-object
   grammar.

## Immediate Follow-up

The most useful next pass is not adding more families.

It is selecting which existing live families should appear on:

1. stage preview cards
2. object codex / dossier records
3. any future mission-intro summary surfaces
