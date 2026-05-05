#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/ui_production_surfaces_v02_1"
GODOT_ROOT = PACKAGE_ROOT / "godot"
TILE_CARD_SIZE = (48, 48)
TILE_ICON_SIZE = (24, 24)


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
        "asset_type": "ui_production_surface_bundle",
        "version": "v02.1",
        "outputs": {
            "tile_card_size": list(TILE_CARD_SIZE),
            "tile_icon_size": list(TILE_ICON_SIZE),
            "tile_card_mode": "RGBA",
            "tile_icon_mode": "RGBA",
            "object_icon_mode": "RGBA",
        },
        "tile_cards": [],
        "tile_icons": [],
        "object_icons": [],
        "promotions": [],
        "notes": [
            "Normalizes production UI surface assets for BattleArtCatalog preferred lookup.",
            "Derives missing production tile icons from production tile cards so generated fallbacks are no longer needed for terrain UI.",
            "Promotes generated object icons missing from production without changing their display contract.",
        ],
    }

    normalized_cards = _normalize_tile_cards(manifest)
    _derive_tile_icons(normalized_cards, manifest)
    _normalize_and_promote_object_icons(manifest)

    manifest_path = GODOT_ROOT / "assets/ui/production/ui_production_surfaces_v02_1_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(PACKAGE_ROOT)


def _normalize_tile_cards(manifest: dict[str, object]) -> dict[str, Image.Image]:
    source_dir = ROOT / "assets/ui/production/tile_cards"
    if not source_dir.is_dir():
        raise FileNotFoundError(source_dir)

    outputs: dict[str, Image.Image] = {}
    for source_path in sorted(source_dir.glob("*.png")):
        image = Image.open(source_path).convert("RGBA")
        if image.size != TILE_CARD_SIZE:
            image = image.resize(TILE_CARD_SIZE, Image.Resampling.LANCZOS)

        output_path = GODOT_ROOT / source_path.relative_to(ROOT)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        image.save(output_path)
        outputs[source_path.name] = image

        manifest["tile_cards"].append(
            {
                "id": source_path.stem,
                "source": str(source_path.relative_to(ROOT)),
                "output": str(output_path.relative_to(GODOT_ROOT)),
                "size": list(image.size),
                "mode": image.mode,
            }
        )
    return outputs


def _derive_tile_icons(cards: dict[str, Image.Image], manifest: dict[str, object]) -> None:
    for file_name, card in cards.items():
        icon = card.resize(TILE_ICON_SIZE, Image.Resampling.LANCZOS)
        icon = ImageEnhance.Contrast(icon).enhance(1.12)
        icon = ImageEnhance.Sharpness(icon).enhance(1.1)
        icon = icon.filter(ImageFilter.UnsharpMask(radius=0.5, percent=70, threshold=2))

        output_path = GODOT_ROOT / "assets/ui/production/tile_icons" / file_name
        output_path.parent.mkdir(parents=True, exist_ok=True)
        icon.save(output_path)

        manifest["tile_icons"].append(
            {
                "id": Path(file_name).stem,
                "source": "assets/ui/production/tile_cards/%s" % file_name,
                "output": str(output_path.relative_to(GODOT_ROOT)),
                "size": list(icon.size),
                "mode": icon.mode,
            }
        )


def _normalize_and_promote_object_icons(manifest: dict[str, object]) -> None:
    production_dir = ROOT / "assets/ui/production/object_icons"
    generated_dir = ROOT / "assets/ui/object_icons_generated"
    if not production_dir.is_dir():
        raise FileNotFoundError(production_dir)
    if not generated_dir.is_dir():
        raise FileNotFoundError(generated_dir)

    production_names = {path.name for path in production_dir.glob("*.png")}
    icon_sources = list(sorted(production_dir.glob("*.png")))
    for generated_path in sorted(generated_dir.glob("*.png")):
        if generated_path.name in production_names:
            continue
        icon_sources.append(generated_path)
        manifest["promotions"].append(
            {
                "id": generated_path.stem,
                "from": str(generated_path.relative_to(ROOT)),
                "to": "assets/ui/production/object_icons/%s" % generated_path.name,
            }
        )

    for source_path in icon_sources:
        image = Image.open(source_path).convert("RGBA")
        output_path = GODOT_ROOT / "assets/ui/production/object_icons" / source_path.name
        output_path.parent.mkdir(parents=True, exist_ok=True)
        image.save(output_path)

        manifest["object_icons"].append(
            {
                "id": source_path.stem,
                "source": str(source_path.relative_to(ROOT)),
                "output": str(output_path.relative_to(GODOT_ROOT)),
                "size": list(image.size),
                "mode": image.mode,
            }
        )


if __name__ == "__main__":
    main()
