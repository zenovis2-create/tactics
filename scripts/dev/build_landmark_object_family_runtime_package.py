#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/landmark_object_families_v02_1"
GODOT_ROOT = PACKAGE_ROOT / "godot"


@dataclass(frozen=True)
class LandmarkObjectFamilySpec:
    family_id: str
    prop_id: str
    icon_source: Path
    production_icon: str
    object_ids: tuple[str, ...]


SPECS: tuple[LandmarkObjectFamilySpec, ...] = (
    LandmarkObjectFamilySpec(
        family_id="civic_seal",
        prop_id="city_seal_dais_01",
        icon_source=ROOT / "assets/props/city_seal_dais_01/runtime/city_seal_dais_01_icon_v01.png",
        production_icon="assets/ui/production/object_icons/city_seal_dais.png",
        object_ids=("ch07_05_city_seal",),
    ),
)


def main() -> None:
    if PACKAGE_ROOT.exists():
        shutil.rmtree(PACKAGE_ROOT)
    PACKAGE_ROOT.mkdir(parents=True, exist_ok=True)
    (PACKAGE_ROOT / ".gdignore").write_text(
        "Asset Forge handoff package; ignore package staging files during Godot project import.\n",
        encoding="utf-8",
    )

    manifest: dict[str, object] = {
        "schema_version": 1,
        "asset_type": "landmark_object_family_bundle",
        "version": "v02.1",
        "outputs": {
            "production_icon_mode": "RGBA",
            "production_icon_size": [256, 256],
        },
        "families": [],
        "notes": [
            "Promotes cleaned runtime prop icons into BattleArtCatalog production object icon lookup.",
            "Keeps chapter object routing explicit; gameplay objective flags remain keyed by object_id.",
        ],
    }

    for spec in SPECS:
        manifest["families"].append(_build_family(spec))

    manifest_path = GODOT_ROOT / "assets/props/landmark_object_families_v02_1_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(PACKAGE_ROOT)


def _build_family(spec: LandmarkObjectFamilySpec) -> dict[str, object]:
    if not spec.icon_source.is_file():
        raise FileNotFoundError(spec.icon_source)

    icon = Image.open(spec.icon_source).convert("RGBA")
    icon = ImageEnhance.Contrast(icon).enhance(1.08)
    icon = ImageEnhance.Sharpness(icon).enhance(1.08)
    icon = icon.filter(ImageFilter.UnsharpMask(radius=0.6, percent=65, threshold=3))

    icon_path = GODOT_ROOT / spec.production_icon
    icon_path.parent.mkdir(parents=True, exist_ok=True)
    icon.save(icon_path)

    source_copy = GODOT_ROOT / "assets/props" / spec.prop_id / "runtime" / spec.icon_source.name
    source_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(spec.icon_source, source_copy)

    return {
        "family_id": spec.family_id,
        "prop_id": spec.prop_id,
        "object_ids": list(spec.object_ids),
        "source_icon": str(source_copy.relative_to(GODOT_ROOT)),
        "production_icon": str(icon_path.relative_to(GODOT_ROOT)),
        "size": list(icon.size),
        "mode": icon.mode,
    }


if __name__ == "__main__":
    main()
