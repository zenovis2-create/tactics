# Interaction Object Family Placement Rules V01

## Purpose

This document locks how the current interaction object families should be used on maps.

It exists because the project now has three distinct object lanes:

- `altar_01`
- `lever_01`
- `gate_control_01`

Without placement rules, they could still collapse into interchangeable “things the player presses.”

## Current Family Set

### Sacred Objective Family

- baseline: `altar_01`
- reads as ritual, evidence, purification, memory, or holy objective

### Mechanical Interaction Family

- baseline: `lever_01`
- reads as local mechanism, immediate device control, or small-scale battlefield action

### Route / System Control Family

- baseline: `gate_control_01`
- reads as larger infrastructure logic, route state, gate state, or battlefield-system change

## Placement Principle

The object family must tell the player what kind of interaction they are approaching before the UI confirms it.

Read priority:

1. family type
2. local gameplay meaning
3. narrative layer

If the player must wait for text or marker color before understanding what kind of object they are looking at, placement has failed.

## Family Rules

### 1. Altar Placement Rules

Use altar when the object should feel:

- sacred
- memory-bearing
- ceremonial
- truth- or purification-adjacent

Place altar:

- where the object can own a local focal zone
- slightly separated from generic clutter
- with enough breathing room that it feels intentional

Do not use altar:

- for small route toggles
- for generic machinery
- for purely military controls

### 2. Lever Placement Rules

Use lever when the object should feel:

- local
- immediate
- hand-operated
- mechanical but not infrastructural

Place lever:

- near the change it controls
- on side walls, machinery edges, or local choke zones
- where one unit clearly stepping over to it makes tactical sense

Do not use lever:

- as the main chapter landmark
- as a sacred focal point
- as the control for huge route logic unless it is one visible part of a larger system

### 3. Gate-Control Placement Rules

Use gate control when the object should feel:

- infrastructural
- route-defining
- larger than one lever
- tied to a gate, barricade, lift, portcullis, or defense-state system

Place gate control:

- close enough to the route it changes that the connection is believable
- in fortified, engineered, or system-heavy spaces
- where the player can infer “this changes the map state”

Do not use gate control:

- for tiny local interactions
- as a sacred or archival object
- in places where no larger route/system consequence exists

## Coexistence Rules

### Altar + Lever

- altar is the ritual or memory anchor
- lever is the nearby local mechanism
- they may coexist, but must not look like the same interaction category

### Lever + Gate Control

- lever handles local machine action
- gate control handles larger system action
- if both are present, gate control should look more infrastructural

### Altar + Gate Control

- altar is sacred intention
- gate control is route or state engineering
- if both appear in one map, their placement should make that thematic contrast obvious

## Chapter-Fit Guidance

### Fortress / Iron Keep Maps

Prefer:

- `lever_01`
- `gate_control_01`

Use altar only if the map has a chapel, reliquary, oath space, or sacred memory beat.

### Monastery / Sacred Ruin Maps

Prefer:

- `altar_01`

Use lever or gate control only if the sacred space is fused with visible machinery or flood-state systems.

### Archive / Evidence Maps

Prefer:

- altar-like or evidence-table family for knowledge/sacred truth anchors
- gate-control only when archive systems physically change map routes

### Forest / Wilderness Maps

Use sparingly:

- lever only if hunter traps or local devices justify it
- altar only for shrine/memory points
- gate-control only if the map includes engineered ruins or remnants

## Failure Cases

Reject placement if:

- altar is used as generic machinery
- lever becomes the visual center of a major sacred scene
- gate control is so small or local that it reads like a lever
- two object families sit so close together that their silhouettes merge
- family identity depends only on color

## Immediate Use

Use this document when:

- assembling map-specific previews
- choosing which object family belongs in a stage shell
- deciding whether a new object should derive from altar, lever, or gate-control

## Related Files

- `/Volumes/AI/tactics/assets/props/altar_01/`
- `/Volumes/AI/tactics/assets/props/lever_01/`
- `/Volumes/AI/tactics/assets/props/gate_control_01/`
- `/Volumes/AI/tactics/docs/environment_equipment_runtime_promotion_plan_v01.md`
- `/Volumes/AI/tactics/docs/ch02_fortress_screenshot_assembly_v01.md`

