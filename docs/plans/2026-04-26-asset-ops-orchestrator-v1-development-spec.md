# AssetOps Orchestrator v1 Development Spec

Date: 2026-04-26

Status: `planned_ready_for_implementation`

## Purpose

Build a small asset-specific pipeline controller that turns sprite candidates
into reviewable, gateable, traceable asset packets.

The v1 target is narrow on purpose:

```text
asset: Rian
state: idle_front_right
candidate family: v07d / future compatible candidates
runtime path focus: Path A parallel 16F lane
```

The tool should reduce human work to three checkpoints:

1. keep or discard a candidate
2. choose a promotion path
3. approve runtime copy after all gates pass

## Problem Definition

The current project can generate and review sprite candidates, but the process
still relies on manual memory for too many production rules.

Known failure paths:

- direct overwrite of `assets/characters/sprite_anchor_rian/runtime/idle/`
- promotion of `8F` downsample output because it matches frame count
- using viewport capture PNGs as sprite frames
- reusing failed component/reorder/blended-inbetween approaches
- advancing without explicit frame-count, canvas, scale, and playback ownership

Known success paths:

- `v07d` hard-pixel bridge preserves the preferred loop candidate
- Godot preview and capture runners catch engine-level issues
- Path A can preserve `16F` motion quality while keeping current runtime fallback
- `BattleArtCatalog` can already load arbitrary state directories
- `UnitActor` now has a preferred idle-lane hook and fallback behavior

## Product Shape

`AssetOps Orchestrator` is not an image generator. It is a controller around
generation, QA, review packaging, policy gating, promotion planning, and memory.

Generation is treated as an adapter. The core tool accepts candidates from:

- built-in image generation
- manual pixel edits
- Aseprite/Piskel exports
- Rhino/render outputs
- existing source frame folders

Every candidate must pass the same intake and gate rules regardless of origin.

## v1 Non-Goals

- no automatic runtime overwrite
- no broad multi-character support
- no web dashboard
- no Godot editor plugin
- no semantic identity classifier beyond measurable sprite QA
- no direct image generation workflow inside the v1 core

## Proposed File Layout

```text
tools/asset_ops/
  asset_ops.py
  README.md
  rules/
    common_sprite_motion.json
    rian_idle_front_right.json
  templates/
    manifest.json
    repo_doc.md
    obsidian_note.md
  adapters/
    imagegen_adapter.md
    manual_edit_adapter.md
scripts/dev/
  asset_ops_godot_preview_runner.gd
  asset_ops_runtime_gate_runner.gd
docs/generated/
  asset_ops_<candidate>_<stage>.md
```

## CLI Contract

### `intake`

```bash
python3 tools/asset_ops/asset_ops.py intake \
  --asset rian \
  --state idle_front_right \
  --candidate v07d \
  --source assets/characters/sprite_anchor_rian/source/motion_sprites/idle_front_right_v01/export_gate_review_v07d/frames_96_pivot_stabilized
```

Responsibilities:

- validate source directory exists
- count PNG frames
- validate naming sort order
- validate frame dimensions
- detect missing or extra files
- create candidate manifest
- record source lineage

### `qa`

```bash
python3 tools/asset_ops/asset_ops.py qa --candidate v07d
```

Responsibilities:

- detect duplicate frames
- compute adjacent-frame delta
- compute loop-boundary delta
- compute non-transparent bounding box per frame
- compute bbox jitter
- flag frame-size mismatch
- write QA metrics into manifest
- produce pass/warn/block verdicts

### `review-pack`

```bash
python3 tools/asset_ops/asset_ops.py review-pack --candidate v07d
```

Responsibilities:

- create sheet
- create strip
- create loop GIF
- create QA board
- create Godot preview packet inputs
- preserve deterministic versioned output names

### `gate`

```bash
python3 tools/asset_ops/asset_ops.py gate --candidate v07d --path path-a
```

Responsibilities:

- apply shared sprite rules
- apply `rian_idle_front_right` rules
- block direct runtime overwrite
- block `8F` downsample promotion as Path A
- block viewport-capture-as-frame usage
- confirm required review evidence exists
- emit promotion readiness verdict

### `doc`

```bash
python3 tools/asset_ops/asset_ops.py doc --candidate v07d
```

Responsibilities:

- create repo doc under `docs/generated/`
- create Obsidian-ready note body
- summarize `what_worked`
- summarize `what_to_avoid`
- list artifacts and next gate

### `promotion-plan`

```bash
python3 tools/asset_ops/asset_ops.py promotion-plan --candidate v07d --path path-a
```

Responsibilities:

- create a dry-run copy plan
- list expected runtime destination folders
- list code owners and runner requirements
- write explicit approval checkpoint
- never copy files in v1

## Manifest Contract

Each candidate owns a manifest:

```json
{
  "schema_version": 1,
  "asset": "rian",
  "state": "idle_front_right",
  "candidate_id": "v07d",
  "source_path": "...",
  "frame_count": 16,
  "frame_size": "96x96",
  "origin": "source_review_candidate",
  "lineage": {
    "carry_forward": [
      "v07d hard-pixel bridge",
      "lower-body stability",
      "pivot stability"
    ],
    "avoid": [
      "component63 bridge",
      "reorder probe",
      "blended true in-between",
      "direct runtime overwrite"
    ]
  },
  "qa": {
    "duplicate_frames": [],
    "max_adjacent_delta": null,
    "loop_boundary_delta": null,
    "bbox_jitter": null,
    "verdict": "pending"
  },
  "policy": {
    "path": "path-a",
    "verdict": "pending",
    "blocked_reasons": []
  },
  "artifacts": [],
  "human_checkpoints": {
    "candidate_keep": "pending",
    "promotion_path": "pending",
    "runtime_copy_approval": "pending"
  }
}
```

## Ruleset Design

### `common_sprite_motion.json`

Common rules:

- source frames must be PNG
- all frames must have identical dimensions
- duplicate frames are warnings unless they occur at a known hold point
- loop-boundary delta above threshold is warning or block depending on state
- bbox center drift above threshold is warning
- frame count mismatch is block
- runtime copy is blocked unless explicit promotion approval exists

### `rian_idle_front_right.json`

Rian-specific rules:

- expected source frame count: `16`
- expected source frame size: `96x96`
- preferred promotion path: `path-a`
- proposed runtime lane key: `idle_16f_review`
- fallback runtime lane: `idle`
- blocked paths: `direct_overwrite`, `8f_downsample_promotion`
- accepted lineage: `v07d_hard_pixel_bridge`
- rejected lineage: `component63_bridge`, `reorder_probe`, `blended_true_inbetween`

## Architecture

```text
Candidate Source
  -> intake
  -> manifest
  -> qa
  -> review-pack
  -> gate
  -> promotion-plan
  -> docs/wiki
  -> human approval
  -> future promote command
```

Python owns deterministic file analysis and packet generation.

Godot owns runtime truth:

- preview scene load
- runtime state load
- character playback
- viewport capture
- fallback behavior

## Human Intervention Model

Human checkpoints:

1. `candidate_keep`: approve or archive after review pack
2. `promotion_path`: choose `path-a` or `path-b`
3. `runtime_copy_approval`: approve controlled copy after all gates pass

Everything else should be automatic.

## Implementation Phases

### Phase 1: Skeleton and Manifest

Goal: create the CLI shell and stable manifest contract.

Tasks:

- create `tools/asset_ops/asset_ops.py`
- create `tools/asset_ops/README.md`
- create manifest load/save helpers
- implement `intake`
- implement candidate output directory convention
- add basic CLI validation errors

Acceptance:

- `intake` creates a manifest for v07d
- manifest records frame count and frame size
- no runtime files are touched

### Phase 2: QA Metrics

Goal: make the tool useful before any visual review.

Tasks:

- implement duplicate frame detection
- implement frame delta metrics
- implement loop-boundary delta
- implement bounding box extraction
- implement bbox jitter warning
- write metrics back into manifest

Acceptance:

- v07d source pack produces non-empty QA metrics
- duplicate/loop/bbox warnings are machine-readable
- QA command exits nonzero only for block-level errors

### Phase 3: Review Pack

Goal: generate the artifacts humans actually need.

Tasks:

- create sheet builder
- create strip builder
- create loop GIF builder
- create QA board builder
- standardize filenames
- write generated artifact paths into manifest

Acceptance:

- review pack is deterministic
- output can be regenerated without overwriting source
- manifest lists every generated artifact

### Phase 4: Policy Gate

Goal: encode success and failure cases as rules.

Tasks:

- create `common_sprite_motion.json`
- create `rian_idle_front_right.json`
- implement rule loading
- implement blocked-path checks
- implement Path A readiness checks
- emit gate verdict into manifest

Acceptance:

- direct runtime overwrite plan is blocked
- 8F downsample promotion is blocked for Path A
- v07d source candidate can reach `review_ready` or `gate_ready`

### Phase 5: Godot Runner Integration

Goal: bind Python packet generation to Godot runtime truth.

Tasks:

- add Godot preview runner adapter command
- add runtime gate runner adapter command
- run existing `rian_idle_path_a_fallback_behavior_runner.gd`
- run existing `rian_idle_runtime_promotion_contract_runner.gd`
- store runner pass/fail in manifest

Acceptance:

- Godot runner results are captured in manifest
- failing runner blocks promotion readiness
- current fallback behavior remains verified

### Phase 6: Docs and Wiki

Goal: make the pipeline memory durable.

Tasks:

- create repo doc template
- create Obsidian note template
- implement `doc`
- include `what_worked`
- include `what_to_avoid`
- include artifact links and next gate

Acceptance:

- repo doc is generated under `docs/generated/`
- Obsidian-ready note body is generated
- no manual reconstruction of artifact paths is needed

### Phase 7: Promotion Dry Run

Goal: generate an explicit copy plan without copying files.

Tasks:

- implement `promotion-plan`
- list target runtime folders
- list code owner files
- list required runners
- require human approval field

Acceptance:

- dry-run plan is complete
- runtime copy remains disabled in v1
- blocked candidates cannot produce a promotion-ready plan

## Development Checklist

### Repository Setup

- [x] Create `tools/asset_ops/`
- [x] Create `tools/asset_ops/rules/`
- [x] Create `tools/asset_ops/templates/`
- [x] Create `tools/asset_ops/adapters/`
- [x] Add `tools/asset_ops/README.md`

### CLI Foundation

- [x] Implement argument parser
- [x] Implement common path resolver
- [x] Implement candidate ID normalization
- [x] Implement manifest read/write
- [x] Implement stable output directory convention
- [x] Add clear error messages for missing files

### Intake

- [ ] Validate source directory
- [ ] List PNG frames in sorted order
- [ ] Validate all frames load
- [ ] Validate identical frame dimensions
- [ ] Count frames
- [ ] Write initial manifest
- [ ] Record lineage carry-forward entries
- [ ] Record lineage avoid entries

### QA

- [ ] Detect duplicate frames
- [ ] Compute adjacent-frame delta
- [ ] Compute max adjacent delta
- [ ] Compute loop-boundary delta
- [ ] Extract alpha/non-background bbox
- [ ] Compute bbox center drift
- [ ] Compute bbox size drift
- [ ] Emit warning/block verdicts
- [ ] Store QA metrics in manifest

### Review Pack

- [ ] Generate 4x4 sheet for 16F candidates
- [ ] Generate horizontal strip
- [ ] Generate loop GIF
- [ ] Generate QA metrics board
- [ ] Preserve source frames untouched
- [ ] Add artifact paths to manifest

### Policy Gate

- [ ] Load common ruleset
- [ ] Load asset/state-specific ruleset
- [ ] Block direct runtime overwrite
- [ ] Block capture PNG frame usage
- [ ] Block 8F downsample promotion for Path A
- [ ] Require Godot preview evidence
- [ ] Require candidate manifest
- [ ] Emit final gate verdict

### Godot Integration

- [ ] Run fallback behavior runner
- [ ] Run runtime promotion contract runner
- [ ] Run Path A prerequisite runner
- [ ] Store runner status in manifest
- [ ] Fail gate when required runner fails

### Documentation

- [ ] Generate repo doc
- [ ] Generate Obsidian-ready note
- [ ] Include artifact links
- [ ] Include `What Worked`
- [ ] Include `What To Avoid`
- [ ] Include `Next Gate`

### Promotion Dry Run

- [ ] Generate target runtime folder list
- [ ] Generate required copy operation list
- [ ] Generate post-copy runner list
- [ ] Require explicit approval field
- [ ] Keep actual copy disabled in v1

## Acceptance Test Matrix

Required before v1 is considered complete:

- [ ] `intake` works for v07d source frames
- [ ] `qa` writes measurable metrics
- [ ] `review-pack` creates visual artifacts
- [ ] `gate --path path-a` blocks known bad paths
- [ ] `doc` creates repo documentation
- [ ] Godot fallback behavior runner passes
- [ ] Godot runtime contract runner passes
- [ ] `git diff --check` passes
- [ ] no runtime idle files are modified by any v1 command

## Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Tool grows too broad too early | Slows implementation | v1 supports only Rian idle_front_right |
| Metrics become false authority | Bad visual candidates pass | Treat metrics as gate inputs, not final aesthetic judgment |
| Runtime copy happens too early | Existing assets regress | v1 only emits dry-run promotion plans |
| Rules live only in docs | Failures repeat | Encode rules in JSON and gate logic |
| Godot and Python disagree | Review artifacts mislead | Godot runner results override promotion readiness |

## First Implementation Order

1. Build `asset_ops.py intake`
2. Add manifest schema and v07d fixture path
3. Build `qa`
4. Build `gate` with blocked path rules
5. Add repo doc generation
6. Wire existing Godot runners into manifest
7. Add review-pack generation
8. Add dry-run promotion plan

## Definition of Done

AssetOps v1 is done when one command sequence can turn the existing v07d source
candidate into a complete review and gate packet without touching runtime:

```bash
python3 tools/asset_ops/asset_ops.py intake --asset rian --state idle_front_right --candidate v07d --source assets/characters/sprite_anchor_rian/source/motion_sprites/idle_front_right_v01/export_gate_review_v07d/frames_96_pivot_stabilized
python3 tools/asset_ops/asset_ops.py qa --candidate v07d
python3 tools/asset_ops/asset_ops.py review-pack --candidate v07d
python3 tools/asset_ops/asset_ops.py gate --candidate v07d --path path-a
python3 tools/asset_ops/asset_ops.py doc --candidate v07d
python3 tools/asset_ops/asset_ops.py promotion-plan --candidate v07d --path path-a
python3 tools/asset_ops/asset_ops.py schema --candidate v07d
python3 tools/asset_ops/asset_ops.py verify --candidate v07d
python3 tools/asset_ops/asset_ops.py compare --candidate-a v07d --candidate-b v07d
```

Expected final state:

- candidate manifest exists
- QA metrics exist
- review artifacts exist
- gate verdict exists
- repo doc exists
- promotion plan exists
- manifest schema validates
- one-command verification passes
- candidate comparison report can be generated
- runtime copy is still not performed

## v1.1 Verification Extension

Implemented after the initial v1 packet:

- `schema` validates the manifest contract before downstream automation trusts it.
- `verify` runs the single-command preflight for schema, frame paths, artifact
  paths, QA status, policy status, and Godot runner records.
- `compare` generates a structural comparison report between two candidates.

This keeps the operating balance: automation gathers evidence and blocks
structural failures, while humans only decide visual keep/discard and runtime
copy approval.
