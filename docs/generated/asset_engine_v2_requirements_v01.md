# Asset Engine V2 Requirements V01

## Purpose

This document defines the next requirements for evolving the current
`asset-engine` from a general image-processing tool into a game-asset
conversion engine that matches this tactics project.

The current engine is already useful for:

- validation
- background removal
- normalization
- variant generation
- sheet or preview building

The missing layer is game-specific asset intent.

In other words:

- current engine = image-processing engine
- target engine = game-asset contract engine

## Product Goal

The engine should be able to take an input image or generated image set and
convert it into outputs that are immediately useful for this game's runtime,
UI, and production review flow.

That means the engine must understand:

- what kind of asset it is
- which game surfaces it is meant for
- what constraints those surfaces impose

## Non-Goals

This version should not try to:

- replace manual art direction entirely
- guarantee perfect directional synthesis from a single illustration
- solve all image generation problems internally

Directional generation support may exist as a helper workflow, but the engine
should focus first on turning already-created art into reliable game assets.

## Core Requirements

### 1. Asset Output Profiles

The engine must support explicit output profiles for this game's main asset
classes.

Minimum profiles:

- `character_8dir_sprite`
- `character_turnaround_sheet`
- `runtime_object_icon`
- `terrain_tile`
- `briefing_support_art`
- `records_support_art`
- `integration_preview`

Each profile must define:

- canvas size
- padding
- anchor or pivot convention
- background rule
- filename pattern
- output directory pattern

Reason:

- the engine must stop behaving like a generic image utility
- it must produce outputs with game-specific contracts

### 2. Sprite Post-Processing

The engine must support stronger sprite cleanup and normalization for direct
game use.

Minimum operations:

- alpha fringe cleanup
- transparent edge cleanup
- safe crop
- fixed-canvas padding
- pivot placement
- sprite canvas normalization
- silhouette-preserving resize

Reason:

- this is the most common failure point between “good image” and “usable game asset”

### 3. Surface-Aware Derivatives

The engine must be able to derive multiple game-facing outputs from a single
cleaned source.

Minimum derivative set:

- object icon
- briefing crop
- records or dossier crop
- runtime integration preview

Reason:

- current workflow still relies too much on manual interpretation of which crop
  belongs to which destination

### 4. Family-Aware Validation

The engine should validate whether a produced asset still fits its family.

Minimum checks:

- silhouette strength
- contrast strength
- over-detail risk
- scale drift
- crop drift

Target family examples:

- `well / shrine / floodgate / latch`
- `battery / bell / chain_control`
- `evidence / keeper_lectern`

Reason:

- the game now uses family-level runtime contracts
- asset validation should reflect that

### 5. Direction and View Support

The engine should support directional asset workflows, but as a second-tier
feature after output profiles and cleanup.

Minimum support:

- turnaround sheet splitting
- direction sheet assembly
- per-view normalization
- per-view validation

Desired helper workflows:

- `front + side -> normalized turnaround sheet`
- `generated 4-view sheet -> split + pad + export`

Reason:

- directional generation itself may come from external image generation
- but once views exist, the engine should be able to process them reliably

### 6. Metadata and Manifest

The engine should persist game-facing metadata for each asset.

Minimum fields:

- asset id
- family
- asset class
- intended surfaces
- source path
- clean path
- runtime outputs
- validation status
- version

Reason:

- a game asset pipeline becomes difficult to scale without structured metadata

### 7. Validation Hooks For Game Runtime

The engine should support downstream validation against the game runtime.

Minimum integration goals:

- output file presence checks
- icon loadability checks
- runtime path compatibility checks
- optional runner handoff metadata

Reason:

- the last mile is not just “image exists”
- it is “image can actually be consumed by runtime and UI”

## Functional Requirements

### FR-1 Profile-Based Export

Given an input image and a chosen output profile, the engine must export files
that conform to that profile's canvas, padding, naming, and path contract.

### FR-2 Cleanup Pipeline

Given a source image, the engine must produce a cleaned intermediate suitable
for later runtime exports.

### FR-3 Derivative Bundle Export

Given a cleaned image, the engine must be able to emit a bundle of derivatives
for different game surfaces.

### FR-4 Family Validation Report

Given an output and an intended family, the engine should emit a validation
report that flags likely drift or usability risk.

### FR-5 Directional Sheet Processing

Given a directional or turnaround sheet, the engine must normalize and split it
into per-view outputs suitable for later sprite or review workflows.

### FR-6 Asset Manifest Update

Each successful conversion should update or emit structured metadata describing
the asset outputs.

## UX Requirements

### UX-1 Minimal Inputs

The engine should require only:

- input path
- project slug
- output profile

with optional family and surface hints.

### UX-2 Predictable Output

The user should be able to predict:

- what files will be created
- where they will be created
- which profile rules were applied

### UX-3 Review Visibility

The engine should provide enough output for quick review:

- generated files
- manifest or report
- preview image or animation where relevant

## Technical Requirements

### TR-1 Deterministic File Layout

Output locations must be deterministic and profile-based.

### TR-2 Idempotent Re-Runs

Running the same command twice should not create ambiguous duplicates unless
versioning rules explicitly request a new version.

### TR-3 Explicit Versioning

All generated outputs should support versioned naming.

### TR-4 Safe Intermediate Artifacts

Intermediate files should not overwrite source inputs.

### TR-5 Runtime-Friendly Formats

Outputs must prefer formats that are already friendly to the current game
runtime and asset loading paths.

## Prioritized Roadmap

### Phase 1

Highest priority:

- output profiles
- sprite cleanup and normalization
- surface-aware derivatives

Reason:

- these directly improve production value right away

### Phase 2

Second priority:

- metadata and manifest
- family-aware validation
- runtime validation hooks

Reason:

- these make the pipeline scale and reduce drift

### Phase 3

Third priority:

- directional sheet processing
- stronger view-based workflows

Reason:

- useful, but downstream of stable output contracts

## Acceptance Standard

This effort succeeds when:

1. a single clean input can reliably produce the game's target outputs
2. those outputs land in predictable locations with predictable naming
3. the engine can tell the difference between a visually acceptable image and a
   game-usable asset
4. the outputs are easier to route into runtime and UI than the current manual flow

## Working Conclusion

Asset Engine V2 should be built around game-asset contracts, not around generic
image manipulation alone.
