# Chapter Landmark Repetition Review V01

## Purpose

This review decides whether the current chapter-local landmark families already need immediate `V02` expansion.

It does not ask whether more variants would be nice.
It asks whether repetition pressure is high enough that expansion is required now.

## Review Scope

Reviewed chapter-local landmark sets:

- `CH01`
- `CH02`
- `CH03`
- `CH04`
- `CH05`
- `CH06`
- `CH07`
- `CH08`
- `CH09B`
- `CH10`

Reference summary:

- [chapter_landmark_coverage_summary_v01.md](/Volumes/AI/tactics/docs/generated/chapter_landmark_coverage_summary_v01.md)

## Decision Summary

No chapter-local landmark family requires immediate `V02` expansion right now.

Current recommendation:

- keep all current chapter-local landmark sets at `V01`
- expand only when a real preview, screenshot, or runtime destination reveals visible repetition pressure

## Chapter Decisions

### CH01

- status: `hold`
- reason: `memory_well_01`, `scavenged_cache_01`, and `evac_handcart_01` already separate investigation, reward, and escort burden clearly
- reopen trigger: if ruined-village scenes start repeating the same stash or well silhouette too often

### CH02

- status: `hold`
- reason: `battery_emplacement_01` and `banner_mast_01` already split siege pressure from fortress identity
- reopen trigger: if multiple fortress boss or recapture scenes make banner or battery silhouettes feel copy-pasted

### CH03

- status: `watch`
- reason: forest scenes are the easiest place for landmark silhouettes to get swallowed by environment noise
- reopen trigger: if `resin_shrine_01` or `hunter_rig_01` stop reading clearly in more than one real screenshot assembly

### CH04

- status: `hold`
- reason: `floodgate_wheel_01` and `purification_basin_01` already separate water-control from purification target cleanly
- reopen trigger: if the same basin or wheel shape is reused across too many monastery beats without enough spatial contrast

### CH05

- status: `watch`
- reason: archive chapters naturally tempt repeated use of lecterns, seal frames, and desks
- reopen trigger: if CH05 archive spaces start flattening into one “important archive furniture” look

### CH06

- status: `hold`
- reason: `shield_wreck_01` and `chain_lift_winch_01` split cover from route-control engineering well
- reopen trigger: if multiple siege scenes need a second cover-family or a second machine-family silhouette to avoid visual sameness

### CH07

- status: `hold`
- reason: `bell_frame_01` and `city_seal_dais_01` already separate public warning from civic oath authority
- reopen trigger: if ritual-city scenes begin leaning too heavily on one of those two symbols

### CH08

- status: `watch`
- reason: split-line scenes are structurally narrower, so route objects can repeat faster than broader landmarks
- reopen trigger: if `split_marker_post_01` or `transfer_gate_latch_01` becomes the only readable route clue across multiple layouts

### CH09B

- status: `watch`
- reason: root-archive scenes are late-game and high-pressure, so landmark distinction matters more
- reopen trigger: if `archive_lectern_01` and `revision_core_01` begin reading like two variants of the same archive machine under pressure

### CH10

- status: `hold`
- reason: `anchor_chain_01` and `bell_dais_01` currently separate release and pressure well enough for the terminal lane
- reopen trigger: if the end-state scene needs more monumental geometry than these props can provide alone

## What To Do Next

The correct next step is not blind expansion.

The correct next step is:

1. use the current landmark sets in more real preview or runtime-adjacent surfaces
2. reopen only the chapter families marked `watch` if repetition becomes visible
3. otherwise spend effort on runtime promotion or UI destination strength

## Working Conclusion

The project has reached a point where landmark family breadth is ahead of demonstrated repetition pressure.

That means:

- `V02` expansion should now be evidence-driven
- the default next move is not more landmark generation
- the default next move is stronger review, runtime destination use, or UI-facing promotion
