<!-- paperclip-fastpath:ASH-31:v1 -->
# ASH-31 Battle FX Replacement Contract

## Goal

Define the first production replacement bundle for battle VFX without changing combat math, encounter scripting, or runtime hook names.

This contract is limited to:

- hit spark family
- boss mark ring
- objective burst
- one counter-hit variant only if the artist supplies it as an optional later-wave extra

## Runtime Scope

Runtime files that consume this bundle:

- `/Volumes/AI/tactics/scenes/battle/BattleScene.tscn`
- `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`
- `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

Runtime rule:

- production assets load from `assets/ui/production/fx` first
- generated placeholders remain fallback only
- filenames must stay exact

## Delivery Folder

Drop final PNGs here:

- `/Volumes/AI/tactics/assets/ui/production/fx`

Do not replace files inside:

- `/Volumes/AI/tactics/assets/ui/fx_generated`

## Wave 1 Required Files

- `hit_spark.png`
- `mark_ring.png`
- `objective_burst.png`

Optional later-wave additions, not required for this contract:

- `counter_hit_spark.png` or a documented alternate export
- guard, heal, miss, buff, or ambient effect variants

## Size And Format

- PNG with transparency
- built for small battlefield presentation, not full-screen splash framing
- preserve strong brightness separation against dark battlefield backgrounds

## Hook Mapping

| Runtime event | Required filename | Notes |
| --- | --- | --- |
| standard hit feedback | `hit_spark.png` | must read clearly on both ally and enemy cells |
| marked / boss threat telegraph | `mark_ring.png` | must not obscure the token silhouette at gameplay scale |
| objective secured / objective pulse | `objective_burst.png` | should read as objective energy, not generic magic impact |

## Visual Direction

- painterly-symbolic, not generic mobile particle glitter
- bright center with controlled falloff
- readable on CH03 forest, CH07 ritual city, and CH10 tower pressure scenes
- mark ring should feel ominous and ritual-heavy, not celebratory
- objective burst should feel tactical and sacred, not like a fireball impact

Avoid:

- over-detailed particle dust that collapses at gameplay size
- pure white flashes that wash out tokens and terrain badges
- reused identical treatment across hit, mark, and objective states

## Acceptance Criteria

1. The three Wave 1 FX files exist in `/Volumes/AI/tactics/assets/ui/production/fx` with exact filenames.
2. Runtime still loads production-first and generated-second with no code changes required from the asset drop.
3. `hit_spark` remains readable without covering unit identity.
4. `mark_ring` reads as threat and ritual pressure at gameplay scale.
5. `objective_burst` reads as objective feedback and remains visually distinct from `hit_spark`.

## Validation

After any asset drop for this contract, run:

- `python3 /Volumes/AI/tactics/scripts/dev/battle_art_drop_validator.py`
- `bash /Volumes/AI/tactics/scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd`
- `/Volumes/AI/tactics/scripts/dev/render_representative_snapshots.sh /Volumes/AI/tactics/.codex-representative-snaps`

## Related References

- `/Volumes/AI/tactics/docs/plans/2026-04-14-art-production-briefs.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-14-artist-handoff-onepager.md`
- `/Volumes/AI/tactics/docs/production/battle_art_filename_matrix_v1.md`
- `/Volumes/AI/tactics/docs/production/battle_art_replacement_checklist_v1.md`
- `/Volumes/AI/tactics/docs/production/handoff_pack/ASH-36-technical-art-ingest-contract-v1.md`
