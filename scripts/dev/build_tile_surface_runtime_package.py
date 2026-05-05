#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/tile_surfaces_runtime_v02_1"
GODOT_ROOT = PACKAGE_ROOT / "godot"
CARD_SIZE = 48
ICON_SIZE = 24


@dataclass(frozen=True)
class TileSurfaceSpec:
    terrain_id: str
    source_path: Path
    source_label: str
    card_alpha_target: float


SPECS: tuple[TileSurfaceSpec, ...] = (
    TileSurfaceSpec(
        terrain_id="forest",
        source_path=ROOT / "output/imagegen/forest_tile_01/v02/forest_tile_01_battlefield_candidate_v02.png",
        source_label="forest tile 01 battlefield candidate v02",
        card_alpha_target=0.28,
    ),
    TileSurfaceSpec(
        terrain_id="wall",
        source_path=ROOT / "output/imagegen/fortress_tile_01/v01/fortress_tile_01_candidate_v01.png",
        source_label="fortress tile 01 candidate v01 promoted as wall/keep surface",
        card_alpha_target=0.22,
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
        "asset_type": "tile_surface_runtime_bundle",
        "version": "v02.1",
        "outputs": {
            "tile_card_size": [CARD_SIZE, CARD_SIZE],
            "tile_icon_size": [ICON_SIZE, ICON_SIZE],
        },
        "tiles": [],
        "notes": [
            "Built from existing imagegen terrain candidates.",
            "Promotes large source concepts into actual BattleBoard production tile card/icon contracts.",
        ],
    }

    for spec in SPECS:
        manifest["tiles"].append(build_tile_surface(spec))

    manifest_path = GODOT_ROOT / "assets/ui/production/tile_surface_runtime_v02_1_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(PACKAGE_ROOT)


def build_tile_surface(spec: TileSurfaceSpec) -> dict[str, object]:
    if not spec.source_path.is_file():
        raise FileNotFoundError(spec.source_path)

    source_dir = GODOT_ROOT / "assets/environment/tile_surface_sources" / spec.terrain_id
    source_dir.mkdir(parents=True, exist_ok=True)
    source_copy = source_dir / spec.source_path.name
    shutil.copy2(spec.source_path, source_copy)

    image = Image.open(spec.source_path).convert("RGBA")
    card = _make_tile_card(image)
    icon = _make_tile_icon(image)

    card_path = GODOT_ROOT / "assets/ui/production/tile_cards" / f"{spec.terrain_id}.png"
    icon_path = GODOT_ROOT / "assets/ui/production/tile_icons" / f"{spec.terrain_id}.png"
    card_path.parent.mkdir(parents=True, exist_ok=True)
    icon_path.parent.mkdir(parents=True, exist_ok=True)
    card.save(card_path)
    icon.save(icon_path)

    return {
        "terrain_id": spec.terrain_id,
        "source": str(source_copy.relative_to(GODOT_ROOT)),
        "source_label": spec.source_label,
        "card": str(card_path.relative_to(GODOT_ROOT)),
        "icon": str(icon_path.relative_to(GODOT_ROOT)),
        "card_alpha_target": spec.card_alpha_target,
    }


def _make_tile_card(image: Image.Image) -> Image.Image:
    cropped = _center_square_crop(image)
    cropped = cropped.resize((CARD_SIZE, CARD_SIZE), Image.Resampling.LANCZOS)
    cropped = ImageEnhance.Color(cropped).enhance(0.88)
    cropped = ImageEnhance.Contrast(cropped).enhance(1.08)
    cropped = ImageEnhance.Sharpness(cropped).enhance(1.12)
    return cropped


def _make_tile_icon(image: Image.Image) -> Image.Image:
    cropped = _center_square_crop(image)
    cropped = cropped.resize((ICON_SIZE, ICON_SIZE), Image.Resampling.LANCZOS)
    cropped = ImageEnhance.Color(cropped).enhance(0.95)
    cropped = ImageEnhance.Contrast(cropped).enhance(1.22)
    cropped = cropped.filter(ImageFilter.UnsharpMask(radius=0.7, percent=90, threshold=3))
    return cropped


def _center_square_crop(image: Image.Image) -> Image.Image:
    width, height = image.size
    side = min(width, height)
    left = (width - side) // 2
    top = (height - side) // 2
    return image.crop((left, top, left + side, top + side))


if __name__ == "__main__":
    main()
