#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "output/imagegen/equipment_overlay_16f_bundles"
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/equipment_overlays_runtime_v02_1"
GODOT_ROOT = PACKAGE_ROOT / "godot"
FRAME_SIZE = 128
SOURCE_CELL_SIZE = 256
QUADRANT_SIZE = SOURCE_CELL_SIZE * 4
FPS = 11.0


@dataclass(frozen=True)
class EquipmentOverlaySpec:
    overlay_id: str
    layer: str
    source_bundle: str
    source_file: str
    quadrant_row: int
    quadrant_col: int
    source_label: str


SPECS: tuple[EquipmentOverlaySpec, ...] = (
    EquipmentOverlaySpec("weapon_sword", "weapon", "equipment_overlay_weapons", "equipment_overlay_weapons_4x16f_bundle_v01_grid2048_alpha.png", 0, 0, "sword overlay"),
    EquipmentOverlaySpec("weapon_lance", "weapon", "equipment_overlay_weapons", "equipment_overlay_weapons_4x16f_bundle_v01_grid2048_alpha.png", 0, 1, "lance overlay"),
    EquipmentOverlaySpec("weapon_bow", "weapon", "equipment_overlay_weapons", "equipment_overlay_weapons_4x16f_bundle_v01_grid2048_alpha.png", 1, 0, "bow overlay"),
    EquipmentOverlaySpec("weapon_staff", "weapon", "equipment_overlay_weapons", "equipment_overlay_weapons_4x16f_bundle_v01_grid2048_alpha.png", 1, 1, "staff overlay"),
    EquipmentOverlaySpec("armor_heavy", "armor", "equipment_overlay_armor_accessory", "equipment_overlay_armor_accessory_4x16f_bundle_v01_grid2048_alpha.png", 0, 0, "heavy armor overlay"),
    EquipmentOverlaySpec("armor_light_cloak", "armor", "equipment_overlay_armor_accessory", "equipment_overlay_armor_accessory_4x16f_bundle_v01_grid2048_alpha.png", 0, 1, "light cloak overlay"),
    EquipmentOverlaySpec("accessory_relic", "accessory", "equipment_overlay_armor_accessory", "equipment_overlay_armor_accessory_4x16f_bundle_v01_grid2048_alpha.png", 1, 0, "relic accessory overlay"),
    EquipmentOverlaySpec("accessory_shield", "accessory", "equipment_overlay_armor_accessory", "equipment_overlay_armor_accessory_4x16f_bundle_v01_grid2048_alpha.png", 1, 1, "shield overlay"),
)


def main() -> None:
    if PACKAGE_ROOT.exists():
        shutil.rmtree(PACKAGE_ROOT)

    package_manifest: dict[str, object] = {
        "schema_version": 1,
        "asset_type": "equipment_overlay_animation_bundle",
        "version": "v02.1",
        "frame_size": [FRAME_SIZE, FRAME_SIZE],
        "fps": FPS,
        "overlays": [],
        "notes": [
            "Built from existing imagegen alpha 4x16f equipment overlay bundles.",
            "Runtime overlays are synchronized to UnitActor character frame indices rather than played as independent animation clocks.",
        ],
    }

    for spec in SPECS:
        package_manifest["overlays"].append(build_overlay(spec))

    manifest_path = GODOT_ROOT / "assets/equipment_overlays/equipment_overlays_runtime_v02_1_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(package_manifest, indent=2) + "\n", encoding="utf-8")
    print(PACKAGE_ROOT)


def build_overlay(spec: EquipmentOverlaySpec) -> dict[str, object]:
    source_path = SOURCE_ROOT / spec.source_bundle / "v01" / spec.source_file
    if not source_path.is_file():
        raise FileNotFoundError(source_path)

    overlay_root = GODOT_ROOT / "assets/equipment_overlays" / spec.overlay_id
    runtime_dir = overlay_root / "runtime/default"
    source_dir = overlay_root / "source/sheets"
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
        frame_name = f"{spec.overlay_id}_default_{index:02d}.png"
        frame_path = runtime_dir / frame_name
        frame.save(frame_path)
        frames.append(str(frame_path.relative_to(overlay_root)))

    contract = {
        "schema_version": 1,
        "asset_type": "equipment_overlay_animation",
        "overlay_id": spec.overlay_id,
        "layer": spec.layer,
        "animation": "default",
        "frame_count": len(frames),
        "fps": FPS,
        "frame_size": [FRAME_SIZE, FRAME_SIZE],
        "source": str(source_copy.relative_to(overlay_root)),
        "source_bundle": spec.source_bundle,
        "source_label": spec.source_label,
        "source_quadrant": {"row": spec.quadrant_row, "col": spec.quadrant_col},
        "frames": frames,
    }
    (overlay_root / "runtime_contract_v01.json").write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")
    return {
        "overlay_id": spec.overlay_id,
        "layer": spec.layer,
        "source_label": spec.source_label,
        "runtime_contract": str((overlay_root / "runtime_contract_v01.json").relative_to(GODOT_ROOT)),
        "frame_count": len(frames),
    }


if __name__ == "__main__":
    main()
