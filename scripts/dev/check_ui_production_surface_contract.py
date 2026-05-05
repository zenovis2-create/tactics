#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
TILE_CARD_SIZE = (48, 48)
TILE_ICON_SIZE = (24, 24)
OBJECT_ICON_ALLOWED_SIZES = {(40, 40), (256, 256)}


def main() -> None:
    tile_card_dir = ROOT / "assets/ui/production/tile_cards"
    tile_icon_dir = ROOT / "assets/ui/production/tile_icons"
    object_icon_dir = ROOT / "assets/ui/production/object_icons"
    generated_object_icon_dir = ROOT / "assets/ui/object_icons_generated"

    _check_png_dir(tile_card_dir, TILE_CARD_SIZE, "tile card")
    _check_png_dir(tile_icon_dir, TILE_ICON_SIZE, "tile icon")

    tile_cards = {path.name for path in tile_card_dir.glob("*.png")}
    tile_icons = {path.name for path in tile_icon_dir.glob("*.png")}
    missing_tile_icons = sorted(tile_cards - tile_icons)
    if missing_tile_icons:
        raise SystemExit("Missing production tile icons: %s" % ", ".join(missing_tile_icons))

    for icon_path in sorted(object_icon_dir.glob("*.png")):
        image = Image.open(icon_path)
        if image.mode != "RGBA":
            raise SystemExit("%s must be RGBA, got %s" % (icon_path, image.mode))
        if image.size not in OBJECT_ICON_ALLOWED_SIZES:
            raise SystemExit("%s expected 40x40 or 256x256, got %s" % (icon_path, image.size))

    generated_names = {path.name for path in generated_object_icon_dir.glob("*.png")}
    production_names = {path.name for path in object_icon_dir.glob("*.png")}
    missing_object_icons = sorted(generated_names - production_names)
    if missing_object_icons:
        raise SystemExit("Generated object icons not promoted to production: %s" % ", ".join(missing_object_icons))

    manifest_path = ROOT / "assets/ui/production/ui_production_surfaces_v02_1_manifest.json"
    if not manifest_path.is_file():
        raise SystemExit("%s is missing" % manifest_path)

    print("[PASS] ui production surface contract validated.")


def _check_png_dir(path: Path, expected_size: tuple[int, int], label: str) -> None:
    if not path.is_dir():
        raise SystemExit("%s is missing" % path)
    files = sorted(path.glob("*.png"))
    if not files:
        raise SystemExit("%s has no PNG files" % path)

    for image_path in files:
        image = Image.open(image_path)
        if image.size != expected_size:
            raise SystemExit("%s expected %s %s, got %s" % (image_path, label, expected_size, image.size))
        if image.mode != "RGBA":
            raise SystemExit("%s expected RGBA %s, got %s" % (image_path, label, image.mode))


if __name__ == "__main__":
    main()
