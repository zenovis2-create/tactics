#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "output/imagegen/fx_16f_bundles"
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/fx_runtime_v02_1"
GODOT_ROOT = PACKAGE_ROOT / "godot"
FRAME_SIZE = 128
SOURCE_CELL_SIZE = 256
QUADRANT_SIZE = SOURCE_CELL_SIZE * 4
FPS = 18.0


@dataclass(frozen=True)
class FxSpec:
    effect_id: str
    source_bundle: str
    source_file: str
    quadrant_row: int = 0
    quadrant_col: int = 0


SPECS: tuple[FxSpec, ...] = (
    FxSpec(
        effect_id="hit_spark",
        source_bundle="fx_weapon_impacts",
        source_file="fx_weapon_impacts_8x8_4x16f_bundle_v01_grid2048_alpha.png",
    ),
    FxSpec(
        effect_id="objective_burst",
        source_bundle="fx_defense_recovery",
        source_file="fx_defense_recovery_8x8_4x16f_bundle_v01_grid2048_alpha.png",
    ),
    FxSpec(
        effect_id="mark_ring",
        source_bundle="fx_status_harm",
        source_file="fx_status_harm_8x8_4x16f_bundle_v01_grid2048_alpha.png",
    ),
    FxSpec(
        effect_id="trap_burst",
        source_bundle="fx_trap_map_objects",
        source_file="fx_trap_map_objects_8x8_4x16f_bundle_v01_grid2048_alpha.png",
    ),
    FxSpec(
        effect_id="finale_burst",
        source_bundle="fx_finale_reserved",
        source_file="fx_finale_reserved_8x8_4x16f_bundle_v01_grid2048_alpha.png",
    ),
)


def main() -> None:
    if PACKAGE_ROOT.exists():
        shutil.rmtree(PACKAGE_ROOT)

    package_manifest: dict[str, object] = {
        "schema_version": 1,
        "asset_type": "animated_fx_bundle",
        "version": "v02.1",
        "frame_size": [FRAME_SIZE, FRAME_SIZE],
        "fps": FPS,
        "effects": [],
        "notes": [
            "Built from existing imagegen alpha 8x8 4x16f bundles because OPENAI_API_KEY is unavailable for live generation.",
            "Each runtime effect uses the top-left 4x4 quadrant as a 16-frame default animation.",
        ],
    }

    for spec in SPECS:
        effect_manifest = build_effect(spec)
        package_manifest["effects"].append(effect_manifest)

    manifest_path = GODOT_ROOT / "assets/fx/fx_runtime_v02_1_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(package_manifest, indent=2) + "\n", encoding="utf-8")
    print(PACKAGE_ROOT)


def build_effect(spec: FxSpec) -> dict[str, object]:
    source_path = SOURCE_ROOT / spec.source_bundle / "v01" / spec.source_file
    if not source_path.is_file():
        raise FileNotFoundError(source_path)

    effect_root = GODOT_ROOT / "assets/fx" / spec.effect_id
    runtime_dir = effect_root / "runtime/default"
    source_dir = effect_root / "source/sheets"
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
        frame_name = f"{spec.effect_id}_default_{index:02d}.png"
        frame_path = runtime_dir / frame_name
        frame.save(frame_path)
        frames.append(str(frame_path.relative_to(effect_root)))

    contract = {
        "schema_version": 1,
        "asset_type": "animated_fx",
        "effect_id": spec.effect_id,
        "animation": "default",
        "frame_count": len(frames),
        "fps": FPS,
        "frame_size": [FRAME_SIZE, FRAME_SIZE],
        "source": str(source_copy.relative_to(effect_root)),
        "source_bundle": spec.source_bundle,
        "source_quadrant": {"row": spec.quadrant_row, "col": spec.quadrant_col},
        "frames": frames,
    }
    (effect_root / "runtime_contract_v01.json").write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")
    return {
        "effect_id": spec.effect_id,
        "source_bundle": spec.source_bundle,
        "runtime_contract": str((effect_root / "runtime_contract_v01.json").relative_to(GODOT_ROOT)),
        "frame_count": len(frames),
    }


if __name__ == "__main__":
    main()
