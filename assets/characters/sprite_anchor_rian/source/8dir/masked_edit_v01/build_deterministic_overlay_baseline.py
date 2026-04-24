#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops


PACK_ROOT = Path(__file__).resolve().parent
RIAN_ROOT = PACK_ROOT.parents[2]
SOURCE_REFERENCE = RIAN_ROOT / "source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png"

LAYERS = {
    "weapon_overlay": {
        "mask": PACK_ROOT / "masks/rian_weapon_overlay_mask_v01.png",
        "source": RIAN_ROOT / "source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v03_masked.png",
        "clean": RIAN_ROOT / "clean/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_clean_v03_masked.png",
        "runtime_dir": RIAN_ROOT / "runtime/8dir/weapon_overlay",
        "runtime_prefix": "rian_weapon_overlay",
        "remove_background": False,
    },
    "upper_armor_overlay": {
        "mask": PACK_ROOT / "masks/rian_upper_armor_overlay_mask_v01.png",
        "source": RIAN_ROOT / "source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v04_masked.png",
        "clean": RIAN_ROOT / "clean/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_clean_v04_masked.png",
        "runtime_dir": RIAN_ROOT / "runtime/8dir/upper_armor_overlay",
        "runtime_prefix": "rian_upper_armor_overlay",
        "remove_background": True,
    },
}

CELL_W = 384
CELL_H = 512
DIRECTIONS = [
    ("front", 0, 0),
    ("front_right", 1, 0),
    ("right", 2, 0),
    ("back_right", 3, 0),
    ("back", 0, 1),
    ("back_left", 1, 1),
    ("left", 2, 1),
    ("front_left", 3, 1),
]


def remove_reference_background(layer: Image.Image, mask: Image.Image) -> Image.Image:
    """Drop the warm sheet background inside masks so overlays stay compositable."""
    pixels = layer.load()
    mask_pixels = mask.load()
    width, height = layer.size
    for y in range(height):
        for x in range(width):
            if mask_pixels[x, y] == 0:
                continue
            r, g, b, a = pixels[x, y]
            # The official sheet background is a warm low-saturation off-white.
            # Keep dark linework and colored gear; clear only near-background pixels.
            bright = r > 205 and g > 198 and b > 190
            low_contrast = max(r, g, b) - min(r, g, b) < 30
            warm_neutral = abs(r - g) < 22 and abs(g - b) < 28
            if bright and low_contrast and warm_neutral:
                pixels[x, y] = (r, g, b, 0)
    return layer


def extract_masked_layer(reference: Image.Image, mask: Image.Image, remove_background: bool) -> Image.Image:
    layer = Image.new("RGBA", reference.size, (0, 0, 0, 0))
    layer.paste(reference, (0, 0), mask)
    if remove_background:
        return remove_reference_background(layer, mask)
    return layer


def save_runtime_frames(sheet: Image.Image, out_dir: Path, prefix: str) -> list[Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    paths = []
    for index, (_direction, col, row) in enumerate(DIRECTIONS):
        left = col * CELL_W
        top = row * CELL_H
        frame = sheet.crop((left, top, left + CELL_W, top + CELL_H))
        out_path = out_dir / f"{prefix}_{index:02d}.png"
        frame.save(out_path)
        paths.append(out_path)
    return paths


def build_difference_preview(reference: Image.Image, outputs: dict[str, Image.Image]) -> Image.Image:
    preview = reference.copy()
    for layer in outputs.values():
        preview = Image.alpha_composite(preview, layer)
    return ImageChops.multiply(preview, Image.new("RGBA", preview.size, (255, 255, 255, 255)))


def main() -> int:
    reference = Image.open(SOURCE_REFERENCE).convert("RGBA")
    outputs: dict[str, Image.Image] = {}
    manifest = {
        "source_reference": str(SOURCE_REFERENCE),
        "cell_size": [CELL_W, CELL_H],
        "directions": [{"name": name, "col": col, "row": row} for name, col, row in DIRECTIONS],
        "layers": {},
    }

    for layer_name, cfg in LAYERS.items():
        mask = Image.open(cfg["mask"]).convert("L")
        if mask.size != reference.size:
            raise SystemExit(f"mask size mismatch for {layer_name}: {mask.size} != {reference.size}")
        layer = extract_masked_layer(reference, mask, bool(cfg["remove_background"]))
        outputs[layer_name] = layer

        cfg["source"].parent.mkdir(parents=True, exist_ok=True)
        cfg["clean"].parent.mkdir(parents=True, exist_ok=True)
        layer.save(cfg["source"])
        layer.save(cfg["clean"])
        frame_paths = save_runtime_frames(layer, cfg["runtime_dir"], cfg["runtime_prefix"])
        bbox = mask.getbbox()
        manifest["layers"][layer_name] = {
            "mask": str(cfg["mask"]),
            "source": str(cfg["source"]),
            "clean": str(cfg["clean"]),
            "runtime_dir": str(cfg["runtime_dir"]),
            "runtime_frames": [str(path) for path in frame_paths],
            "mask_bbox": list(bbox) if bbox else None,
        }

    preview_path = RIAN_ROOT / "runtime/8dir/composite_preview/rian_masked_overlay_baseline_v01.png"
    preview_path.parent.mkdir(parents=True, exist_ok=True)
    build_difference_preview(reference, outputs).save(preview_path)
    manifest["preview"] = str(preview_path)
    (PACK_ROOT / "deterministic_overlay_baseline_manifest_v01.json").write_text(
        json.dumps(manifest, indent=2) + "\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
