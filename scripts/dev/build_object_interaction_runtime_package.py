#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "output/imagegen/object_16f_bundles"
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/object_interactions_runtime_v02_1"
GODOT_ROOT = PACKAGE_ROOT / "godot"
FRAME_SIZE = 128
SOURCE_CELL_SIZE = 256
QUADRANT_SIZE = SOURCE_CELL_SIZE * 4
FPS = 14.0


@dataclass(frozen=True)
class ObjectInteractionSpec:
    object_type: str
    source_bundle: str
    source_file: str
    quadrant_row: int
    quadrant_col: int
    source_label: str


SPECS: tuple[ObjectInteractionSpec, ...] = (
    ObjectInteractionSpec("chest", "object_interactions_core", "object_interactions_core_4x16f_bundle_v01_grid2048_alpha.png", 0, 0, "chest open"),
    ObjectInteractionSpec("lever", "object_interactions_core", "object_interactions_core_4x16f_bundle_v01_grid2048_alpha.png", 0, 1, "lever pull"),
    ObjectInteractionSpec("altar", "object_interactions_core", "object_interactions_core_4x16f_bundle_v01_grid2048_alpha.png", 1, 0, "altar activate"),
    ObjectInteractionSpec("gate", "object_interactions_core", "object_interactions_core_4x16f_bundle_v01_grid2048_alpha.png", 1, 1, "gate open close"),
    ObjectInteractionSpec("door", "object_interactions_core", "object_interactions_core_4x16f_bundle_v01_grid2048_alpha.png", 1, 1, "gate open close"),
    ObjectInteractionSpec("floodgate", "object_interactions_stage", "object_interactions_stage_4x16f_bundle_v01_grid2048_alpha.png", 0, 0, "floodgate release"),
    ObjectInteractionSpec("bell", "object_interactions_stage", "object_interactions_stage_4x16f_bundle_v01_grid2048_alpha.png", 0, 1, "bell swing"),
    ObjectInteractionSpec("evidence", "object_interactions_stage", "object_interactions_stage_4x16f_bundle_v01_grid2048_alpha.png", 1, 0, "evidence sparkle"),
    ObjectInteractionSpec("keeper_lectern", "object_interactions_stage", "object_interactions_stage_4x16f_bundle_v01_grid2048_alpha.png", 1, 1, "keeper lock unlock"),
    ObjectInteractionSpec("gate_control", "object_interactions_archive", "object_interactions_archive_4x16f_bundle_v01_grid2048_alpha.png", 0, 1, "gate control glyph activate"),
    ObjectInteractionSpec("well", "object_interactions_archive", "object_interactions_archive_4x16f_bundle_v01_grid2048_alpha.png", 1, 0, "city seal dais pulse"),
    ObjectInteractionSpec("battery", "object_interactions_archive", "object_interactions_archive_4x16f_bundle_v01_grid2048_alpha.png", 0, 1, "gate control glyph activate"),
    ObjectInteractionSpec("shrine", "object_interactions_archive", "object_interactions_archive_4x16f_bundle_v01_grid2048_alpha.png", 0, 0, "archive seal break"),
    ObjectInteractionSpec("chain_control", "object_interactions_core", "object_interactions_core_4x16f_bundle_v01_grid2048_alpha.png", 1, 1, "gate open close"),
    ObjectInteractionSpec("route_marker", "object_interactions_archive", "object_interactions_archive_4x16f_bundle_v01_grid2048_alpha.png", 1, 0, "city seal dais pulse"),
    ObjectInteractionSpec("latch", "object_interactions_archive", "object_interactions_archive_4x16f_bundle_v01_grid2048_alpha.png", 0, 1, "gate control glyph activate"),
)


def main() -> None:
    if PACKAGE_ROOT.exists():
        shutil.rmtree(PACKAGE_ROOT)

    package_manifest: dict[str, object] = {
        "schema_version": 1,
        "asset_type": "object_interaction_animation_bundle",
        "version": "v02.1",
        "frame_size": [FRAME_SIZE, FRAME_SIZE],
        "fps": FPS,
        "object_types": [],
        "notes": [
            "Built from existing imagegen alpha 4x16f object interaction bundles.",
            "Every InteractiveObjectData object_type gets a 16-frame runtime animation; secondary types reuse the closest existing source motion.",
        ],
    }

    for spec in SPECS:
        package_manifest["object_types"].append(build_object_interaction(spec))

    manifest_path = GODOT_ROOT / "assets/objects/interactions/object_interactions_runtime_v02_1_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(package_manifest, indent=2) + "\n", encoding="utf-8")
    print(PACKAGE_ROOT)


def build_object_interaction(spec: ObjectInteractionSpec) -> dict[str, object]:
    source_path = SOURCE_ROOT / spec.source_bundle / "v01" / spec.source_file
    if not source_path.is_file():
        raise FileNotFoundError(source_path)

    object_root = GODOT_ROOT / "assets/objects/interactions" / spec.object_type
    runtime_dir = object_root / "runtime/interact"
    source_dir = object_root / "source/sheets"
    runtime_dir.mkdir(parents=True, exist_ok=True)
    source_dir.mkdir(parents=True, exist_ok=True)

    source_copy = source_dir / spec.source_file
    shutil.copy2(source_path, source_copy)

    image = Image.open(source_path).convert("RGBA")
    frames: list[str] = []
    origin_x = spec.quadrant_col * QUADRANT_SIZE
    origin_y = spec.quadrant_row * QUADRANT_SIZE

    for index in range(16):
        col = index % 4
        row = index // 4
        box = (
            origin_x + col * SOURCE_CELL_SIZE,
            origin_y + row * SOURCE_CELL_SIZE,
            origin_x + (col + 1) * SOURCE_CELL_SIZE,
            origin_y + (row + 1) * SOURCE_CELL_SIZE,
        )
        frame = image.crop(box).resize((FRAME_SIZE, FRAME_SIZE), Image.Resampling.LANCZOS)
        frame_name = f"{spec.object_type}_interact_{index:02d}.png"
        frame_path = runtime_dir / frame_name
        frame.save(frame_path)
        frames.append(str(frame_path.relative_to(object_root)))

    contract = {
        "schema_version": 1,
        "asset_type": "object_interaction_animation",
        "object_type": spec.object_type,
        "animation": "interact",
        "frame_count": len(frames),
        "fps": FPS,
        "frame_size": [FRAME_SIZE, FRAME_SIZE],
        "source": str(source_copy.relative_to(object_root)),
        "source_bundle": spec.source_bundle,
        "source_label": spec.source_label,
        "source_quadrant": {"row": spec.quadrant_row, "col": spec.quadrant_col},
        "frames": frames,
    }
    (object_root / "runtime_contract_v01.json").write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")
    return {
        "object_type": spec.object_type,
        "source_bundle": spec.source_bundle,
        "source_label": spec.source_label,
        "runtime_contract": str((object_root / "runtime_contract_v01.json").relative_to(GODOT_ROOT)),
        "frame_count": len(frames),
    }


if __name__ == "__main__":
    main()
