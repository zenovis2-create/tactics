# Visual QA Operating Memo V01

## Current State

- visual QA suite: `8/8` pass
- primary report:
  - [visual_qa_suite_report_v01.md](/Volumes/AI/tactics/docs/generated/visual_qa_suite_report_v01.md)
  - [visual_qa_suite_report_v01.json](/Volumes/AI/tactics/docs/generated/visual_qa_suite_report_v01.json)

## Locked Preview Families

- `CH07` -> `city`
  - `bell_frame_01`
  - `city_seal_dais_01`
- `CH09B` -> `archive`
  - `archive_lectern_01`
  - `revision_core_01`
  - `truth_dais_01`
- `CH10` -> `final_bell`
  - `anchor_chain_01`
  - `bell_dais_01`

## Representative Battle Snapshot

- `CH07`
  - family: `city`
  - proximity:
    - `city_seal`: `1`
    - `prayer_dais`: `1`
  - camera zoom: `0.90`
- `CH09B`
  - family: `archive`
  - proximity:
    - `archive_lectern`: `1`
  - camera zoom: `0.91`
- `CH10`
  - family: `final_bell`
  - proximity:
    - `anchor_chain`: `1`
    - `bell_dais`: `1`
  - camera zoom: `0.88`

## Runtime Presentation Now Covered

- ally/enemy sprite-first rendering
- path-step walk movement
- hit / defeat pose feedback
- attack FX
- attack camera timing split:
  - melee
  - ranged
  - support
- board surface family split
- backdrop family split
- board-anchored HUD composition
- preview vs battle family alignment
- representative battle landmark proximity

## Operating Rule

Before manual signoff:

1. run `/Volumes/AI/tactics/scripts/dev/headless_art_promotion_suite.sh`
2. confirm this memo still matches [visual_qa_suite_report_v01.md](/Volumes/AI/tactics/docs/generated/visual_qa_suite_report_v01.md)
3. run manual review with:
   - [manual_play_visual_signoff_checklist_v01.md](/Volumes/AI/tactics/docs/generated/manual_play_visual_signoff_checklist_v01.md)
   - [manual_play_feedback_template_v01.md](/Volumes/AI/tactics/docs/generated/manual_play_feedback_template_v01.md)

## Next Real Gate

The next meaningful step is not more automatic polish.

It is one manual play note in this format:

```text
장면:
항목:
문제:
```
