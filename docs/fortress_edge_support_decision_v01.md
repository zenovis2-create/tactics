# Fortress Edge Support Decision V01

## Decision

`fortress_edge_01` is sufficient as the first structural support surface for the current fortress family.

It is approved as:

- the first `fortified edge / parapet support` surface
- a valid structural companion to:
  - `fortress_tile_01`
  - `fortress_tile_02`
- a reusable chapter-specific support surface for:
  - `CH02 fortress`
  - `CH06 iron keep`

It is not being treated as:

- a full fortified-wall family
- a substitute for future wall, tower, or gatehouse-specific assets

## Why This Decision Is Correct

The family now has three distinct layers:

1. fortified ground baseline
2. fortified ground variation
3. fortified edge support

That is enough breadth to stop calling the fortress lane a floor-only experiment.

Current evidence:

- [CH02FortressArtPreview.tscn](/Volumes/AI/tactics/scenes/dev/CH02FortressArtPreview.tscn)
- [ch02_fortress_art_preview.gd](/Volumes/AI/tactics/scripts/dev/ch02_fortress_art_preview.gd)
- [ch02_fortress_art_preview_runner.gd](/Volumes/AI/tactics/scripts/dev/ch02_fortress_art_preview_runner.gd)
- [CH06IronKeepPreview.tscn](/Volumes/AI/tactics/scenes/dev/CH06IronKeepPreview.tscn)
- [ch06_iron_keep_preview.gd](/Volumes/AI/tactics/scripts/dev/ch06_iron_keep_preview.gd)
- [ch06_iron_keep_preview_runner.gd](/Volumes/AI/tactics/scripts/dev/ch06_iron_keep_preview_runner.gd)
- [fortress_family_cohesion_review_v01.md](/Volumes/AI/tactics/docs/fortress_family_cohesion_review_v01.md)
- [ch02_fortress_screenshot_review_v01.md](/Volumes/AI/tactics/docs/ch02_fortress_screenshot_review_v01.md)
- [ch06_iron_keep_preview_v01.md](/Volumes/AI/tactics/docs/ch06_iron_keep_preview_v01.md)

## What This Approves

Approved:

- continue treating fortress as a `map-specific fortified family`
- use `fortress_edge_01` as the default structural support surface in fortress previews
- stop blocking fortress-family work on the claim that it still lacks any structural companion

## What This Does Not Approve

Not approved:

- promoting fortress to a global terrain baseline
- assuming no future fortified structural assets are needed
- treating one edge surface as a full wall/parapet library

## Working Conclusion

`fortress_edge_01` is enough to complete the current first-pass fortress family.

The question is no longer:

- `does the fortress family need any structural support at all?`

The question is now:

- `when does the fortress family need a second structural support surface?`

## Recommended Next Step

Do not add another fortress structural asset immediately.

Use the current family in more chapter-specific work first.

The next stronger fortress decision should only happen if:

- a new preview shows the edge surface repeating too obviously
- a chapter-specific composition demands taller or more vertical fortification language
