# 2026-04-14 Godot Architecture Review

## Scope

- Reviewed scene ownership, battle shell composition, and campaign-flow structure.
- Verified the project remains runnable after a targeted campaign-architecture split.

## Runtime Gate

- `godot4 --headless --path /Volumes/AI/tactics --quit-after 2`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m2_campaign_flow_runner.gd`

Result:

- Headless boot passes.
- Milestone 1 playtest runner passes.
- Milestone 2 campaign flow runner passes.

## Findings

1. `scenes/Main.tscn` and [scripts/main.gd](/Volumes/AI/tactics/scripts/main.gd:1) are correctly limited to top-level wiring.
2. [scripts/battle/battle_controller.gd](/Volumes/AI/tactics/scripts/battle/battle_controller.gd:1) is large, but its responsibilities still align with explicit battle orchestration and service coordination.
3. [scripts/campaign/campaign_controller.gd](/Volumes/AI/tactics/scripts/campaign/campaign_controller.gd:1) had accumulated too much static authored lookup data for party catalog and chapter stage ordering, violating the project rule that authored campaign content should not keep growing inside controller scripts.
4. [scripts/campaign/campaign_panel.gd](/Volumes/AI/tactics/scripts/campaign/campaign_panel.gd:1) remains presentation-focused and does not currently own progression logic, which is correct.

## Structural Changes Applied

- Added [scripts/campaign/campaign_catalog.gd](/Volumes/AI/tactics/scripts/campaign/campaign_catalog.gd:1) for static unit, equipment, and preview lookups.
- Added [scripts/campaign/campaign_chapter_registry.gd](/Volumes/AI/tactics/scripts/campaign/campaign_chapter_registry.gd:1) for chapter ids, chapter rank, and ordered stage flows.
- Updated [scripts/campaign/campaign_controller.gd](/Volumes/AI/tactics/scripts/campaign/campaign_controller.gd:1) to delegate static lookup concerns into those registries.

## Current Risk

- `CampaignController` still owns a very large volume of authored chapter copy, reward tables, record tables, and camp presentation content.
- This is no longer a runnable-gate issue, but it is the next architecture pressure point and will keep slowing review and milestone-safe edits if left in place.

## Recommended Next Split

1. Move chapter-authored text, reward logs, record logs, unlock tables, and presentation-card content into a dedicated campaign content registry or resources under `data/`.
2. Leave `CampaignController` responsible only for:
   - chapter/session state
   - mode transitions
   - panel payload assembly from registry data
   - battle handoff wiring
