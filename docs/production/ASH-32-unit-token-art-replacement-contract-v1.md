<!-- paperclip-fastpath:ASH-32:v1 -->
# ASH-32 Unit Token Art Replacement Contract

## Goal

Define the first production art replacement bundle for battle unit visuals without changing runtime slot names, gameplay logic, or chapter content.

This contract is limited to:

- unit token art
- matching small role icons
- six Wave 1 runtime filenames only

## Runtime Scope

Runtime files that consume this bundle:

- `/Volumes/AI/tactics/scripts/battle/unit_actor.gd`
- `/Volumes/AI/tactics/scenes/battle/Unit.tscn`
- `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

Runtime rule:

- production assets load from `assets/ui/production/...` first
- generated placeholders remain fallback only
- filenames must stay exact

## Delivery Folders

Drop final PNGs here:

- `/Volumes/AI/tactics/assets/ui/production/unit_token_art`
- `/Volumes/AI/tactics/assets/ui/production/unit_role_icons`

Do not replace files inside:

- `/Volumes/AI/tactics/assets/ui/unit_token_art_generated`
- `/Volumes/AI/tactics/assets/ui/unit_role_icons_generated`

## Wave 1 Required Files

### Token Art

- `knight.png`
- `ranger.png`
- `mystic.png`
- `vanguard.png`
- `medic.png`
- `boss.png`

### Role Icons

- `knight.png`
- `ranger.png`
- `mystic.png`
- `vanguard.png`
- `medic.png`
- `boss.png`

## Size And Format

- token art: `48x48` PNG, transparent background
- role icon: `28x28` PNG, transparent background

## Runtime Role Mapping

`UnitActor` resolves these runtime glyph families into the Wave 1 filenames:

| Runtime glyph / family | Production filename |
| --- | --- |
| `BX` | `boss.png` |
| `MD` | `medic.png` |
| `AR` | `ranger.png` |
| `MY` | `mystic.png` |
| `VG` | `vanguard.png` |
| `KN` | `knight.png` |
| `SW` | `knight.png` |
| `LN` | `knight.png` |

Implication:

- `knight.png` must cover knight, sword, and lance frontline silhouettes
- `boss.png` must read as categorically heavier than the five standard role families

## Visual Direction

- painted-symbolic, not realistic
- bold interior silhouette, not thin outline-only linework
- readable at handheld/mobile battle scale
- strong separation between ally readability and enemy threat language
- boss token should feel ritual-heavy, severe, and unmistakable even before hover or selection

Avoid:

- glossy mobile-game icon finish
- noisy interior detail that disappears at `48x48`
- boss token that feels like a recolor of a normal role
- role icons that no longer visually match the larger token family

## Acceptance Criteria

This Wave 1 bundle is acceptable only if all of the following are true:

1. The six token files and six role-icon files exist in the production override folders with exact filenames.
2. All files match the required PNG dimensions.
3. Runtime still resolves production-first and generated-second with no code changes required from the artist drop.
4. `boss` remains visibly distinct from `knight`, `ranger`, `mystic`, `vanguard`, and `medic` in representative battle snapshots.
5. Small-size readability holds for tutorial, CH03, CH07, and CH10 representative surfaces.

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
