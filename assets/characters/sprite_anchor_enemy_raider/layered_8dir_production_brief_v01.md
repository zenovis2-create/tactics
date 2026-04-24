# Enemy Raider Layered 8Dir Production Brief V01

## Goal

Migrate Enemy Raider from a flat directional-prep lane into a layered 8-direction
hostile baseline lane.

This brief is subordinate to the anchor-first rule.

## Frozen Anchor

Use this anchor for all future image-to-image derivation:

- `source/8dir/anchor/enemy_raider_anchor_8dir_sheet_source_v01.png`

## Required Layers

- `base_body`
- `base_outfit`
- `weapon_overlay`
- `upper_armor_overlay`

Optional in the first hostile baseline:

- `shield_overlay`

## Direction Set

- `front`
- `front_right`
- `right`
- `back_right`
- `back`
- `back_left`
- `left`
- `front_left`

## Read Goal

Enemy Raider must still read as:

- hostile melee pressure first
- rigid authority infantry second
- ember-red enemy cue third

The main risks are:

- drifting toward ally swordsman warmth
- collapsing into generic bandit styling
- losing pressure once gear is separated

## Layer Guidance

### `base_body`

Keep:

- head
- face
- hair or helmetless identity mass if visible
- body mass
- hostile stance structure

Must not carry:

- weapon
- large upper armor shell
- shield read

### `base_outfit`

Keep:

- under-cloth hostile infantry base
- lower-body cloth and boot silhouette
- stable non-swappable enemy cloth read if identity-essential

Must avoid:

- ally-command cloth
- decorative hero mantle

### `weapon_overlay`

Keep:

- melee weapon only

Must remain:

- compact
- threatening
- readable at gameplay scale

### `upper_armor_overlay`

Keep:

- chest armor
- shoulder armor
- upper-body hostile infantry mass that should visibly change

Must avoid:

- heavy defender shell that belongs to a different enemy role
- noble knight silhouette

### `shield_overlay`

Optional in first pass.

If generated later, it should add pressure without replacing the lane's core
melee-infantry read.

## Legacy Sheet Rule

Current flat `8dir` material remains:

- reference-only
- not final production contract

No layered output is final until it is derived from the lane anchor.
