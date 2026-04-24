# CH02 Fortress Screenshot Assembly V01

## Purpose

This document defines the first `fortress-family` screenshot assembly target.

It is not a marketing screenshot brief.
It is a production validation frame used to answer one question:

`Does the current fortress-family ground language hold up when characters, objective props, and equipment-support cues share one frame?`

## Current Source Surface

Use:

- [CH02FortressArtPreview.tscn](/Volumes/AI/tactics/scenes/dev/CH02FortressArtPreview.tscn)
- [ch02_fortress_art_preview.gd](/Volumes/AI/tactics/scripts/dev/ch02_fortress_art_preview.gd)
- [ch02_fortress_art_preview_runner.gd](/Volumes/AI/tactics/scripts/dev/ch02_fortress_art_preview_runner.gd)

## Required Ingredients

The frame must include:

- `Rian`
- `Bran`
- `Enemy Raider`
- `Enemy Skirmisher`
- `fortress_tile_01`
- `altar_01`
- `lever_01`
- `paladin_shield`

Do not reduce this set.
The purpose of the frame is cross-surface coexistence.

## Composition Goal

The frame should communicate:

1. fortified ground family
2. ally front line
3. hostile pressure
4. sacred objective read
5. mechanical objective read
6. equipment-support world consistency

## Read Order

The intended read order is:

1. allied front line
2. hostile pressure line
3. objective objects
4. ground family
5. support equipment surface

If the floor or props read before the units, the composition is wrong.

## Required Judgments

This frame must answer:

- does `fortress_tile_01` feel distinct from forest while still remaining unit-safe?
- does `altar_01` read sacred and objective-like?
- does `lever_01` read mechanical and actionable?
- does `paladin_shield` still belong to the same world when shown beside the fortress family?
- do Rian and Bran still separate clearly from the two hostile units?

## Current Working Placement

The current preview should remain close to:

- allies on the left / center-left
- hostile units on the right
- altar toward the right objective lane
- lever offset from altar so the two interaction families do not collapse together
- paladin shield support surface on the left-lower support lane

## Pass Conditions

Pass this frame only if:

- the fortress floor reads engineered before decorative
- both altar and lever are legible without UI markers
- the two hostile units do not collapse into one role read
- Bran remains visually heavier than Rian
- the shield support surface does not feel pasted from another game

## Fail Conditions

Fail this frame if:

- the fortress tile overwhelms the units
- altar and lever read like the same object family
- hostile silhouette distance is lost
- the shield reads as a UI card unrelated to the battlefield world

## What This Frame Is For

Use this frame before deciding whether `fortress_tile_01` should:

- remain preview-only
- remain map-specific
- or be promoted further inside runtime terrain routing

## Immediate Next Decision

After this frame is reviewed, choose one:

1. keep fortress as a map-specific variant
2. expand fortress family with a second tile before any promotion
3. promote fortress to a stronger runtime role

Current recommendation:

- keep it as a map-specific variant until at least one more fortress-family support asset exists

