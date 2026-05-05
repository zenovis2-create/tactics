# AssetOps Orchestrator

AssetOps turns sprite candidates into reviewable, gateable, traceable packets.
It does not promote runtime assets automatically in v1.

## v1 Scope

- asset: Rian
- state: idle_front_right
- candidate family: v07d-compatible 16-frame source packs
- promotion focus: Path A parallel 16F lane

## Commands

```bash
python3 tools/asset_ops/asset_ops.py intake --asset rian --state idle_front_right --candidate v07d --source <source-frame-dir>
python3 tools/asset_ops/asset_ops.py qa --candidate v07d
python3 tools/asset_ops/asset_ops.py review-pack --candidate v07d
python3 tools/asset_ops/asset_ops.py gate --candidate v07d --path path-a
python3 tools/asset_ops/asset_ops.py doc --candidate v07d
python3 tools/asset_ops/asset_ops.py promotion-plan --candidate v07d --path path-a
python3 tools/asset_ops/asset_ops.py schema --candidate v07d
python3 tools/asset_ops/asset_ops.py verify --candidate v07d
python3 tools/asset_ops/asset_ops.py compare --candidate-a v07d --candidate-b v07d
```

## Runtime Policy

AssetOps v1 never copies files into `assets/characters/*/runtime/`. It only
creates manifests, review artifacts, policy verdicts, docs, and dry-run
promotion plans.

## Dependencies

- `schema`, `verify`, `compare`, and `promotion-plan` use only the Python
  standard library.
- `intake`, `qa`, and `review-pack` require Pillow for PNG inspection and
  visual artifact generation.

## v1.1 Verification Layer

- `schema` validates the manifest contract and required checkpoint fields.
- `verify` checks schema, frame files, artifacts, QA status, policy status, and
  recorded Godot runner results in one command.
- `compare` creates a structural candidate comparison report so a new candidate
  can be judged against the current known-good packet before visual review.
