#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


PROOF_ROOT = Path(__file__).resolve().parent
RIAN_ROOT = PROOF_ROOT.parents[2]

REFERENCE = RIAN_ROOT / "source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png"
SOURCES = {
    "weapon_overlay": RIAN_ROOT / "source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v02_anchor_derived.png",
    "upper_armor_overlay": RIAN_ROOT / "source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v03_lighter.png",
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


def estimate_background(image: Image.Image) -> tuple[int, int, int]:
    rgb = image.convert("RGB")
    width, height = rgb.size
    samples = []
    sample_points = [
        (0, 0),
        (width - 1, 0),
        (0, height - 1),
        (width - 1, height - 1),
        (width // 2, 0),
        (width // 2, height - 1),
    ]
    for x, y in sample_points:
        samples.append(rgb.getpixel((x, y)))
    return tuple(int(sum(channel) / len(samples)) for channel in zip(*samples))


def make_alpha(image: Image.Image, threshold: int = 34) -> Image.Image:
    rgb = image.convert("RGB")
    bg = estimate_background(rgb)
    out = Image.new("RGBA", rgb.size, (0, 0, 0, 0))
    src = rgb.load()
    dst = out.load()
    for y in range(rgb.height):
        for x in range(rgb.width):
            r, g, b = src[x, y]
            distance = abs(r - bg[0]) + abs(g - bg[1]) + abs(b - bg[2])
            if distance <= threshold:
                continue
            # Soften near-background fringes but keep linework opaque.
            alpha = 255 if distance > threshold * 2 else int(255 * (distance - threshold) / threshold)
            dst[x, y] = (r, g, b, max(0, min(255, alpha)))
    return out


def save_frames(sheet: Image.Image, out_dir: Path, prefix: str) -> list[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    paths = []
    for index, (_name, col, row) in enumerate(DIRECTIONS):
        left = col * CELL_W
        top = row * CELL_H
        frame = sheet.crop((left, top, left + CELL_W, top + CELL_H))
        out_path = out_dir / f"{prefix}_{index:02d}.png"
        frame.save(out_path)
        paths.append(str(out_path))
    return paths


def checker(size: tuple[int, int], tile: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (230, 230, 230, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(196, 196, 196, 255))
    return image


def thumb(path: Path, background: str = "solid") -> Image.Image:
    image = Image.open(path).convert("RGBA")
    image.thumbnail((384, 256), Image.Resampling.LANCZOS)
    canvas = checker((384, 256)) if background == "checker" else Image.new("RGBA", (384, 256), (238, 234, 229, 255))
    canvas.alpha_composite(image, ((384 - image.width) // 2, (256 - image.height) // 2))
    return canvas


def build_board(items: list[tuple[str, Path, str]], out_path: Path) -> None:
    pad = 24
    label_h = 34
    cols = 2
    rows = (len(items) + cols - 1) // cols
    width = pad + cols * 384 + (cols - 1) * pad + pad
    height = pad + rows * (256 + label_h) + (rows - 1) * pad + pad
    board = Image.new("RGBA", (width, height), (246, 243, 238, 255))
    draw = ImageDraw.Draw(board)
    font = ImageFont.load_default()
    for index, (label, path, background) in enumerate(items):
        col = index % cols
        row = index // cols
        x = pad + col * (384 + pad)
        y = pad + row * (256 + label_h + pad)
        draw.text((x, y), label, fill=(20, 20, 20), font=font)
        board.alpha_composite(thumb(path, background), (x, y + label_h))
        draw.rectangle((x, y + label_h, x + 384, y + label_h + 256), outline=(70, 70, 70), width=1)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    board.save(out_path)


def main() -> int:
    reference = Image.open(REFERENCE).convert("RGBA")
    manifest = {"reference": str(REFERENCE), "layers": {}}
    alpha_sheets = {}

    for layer, source in SOURCES.items():
        alpha = make_alpha(Image.open(source))
        alpha_sheets[layer] = alpha
        sheet_path = PROOF_ROOT / f"rian_{layer}_concept_alpha_sheet_v01.png"
        alpha.save(sheet_path)
        frame_dir = PROOF_ROOT / "runtime_frames" / layer
        frame_paths = save_frames(alpha, frame_dir, f"rian_{layer}_concept_alpha")
        manifest["layers"][layer] = {
            "source": str(source),
            "alpha_sheet": str(sheet_path),
            "runtime_frames": frame_paths,
            "alpha_bbox": list(alpha.getchannel("A").getbbox() or ()),
        }

    recomposite = reference.copy()
    for layer in ("upper_armor_overlay", "weapon_overlay"):
        recomposite = Image.alpha_composite(recomposite, alpha_sheets[layer])
    recomposite_path = PROOF_ROOT / "rian_existing_layer_alpha_recomposite_v01.png"
    recomposite.save(recomposite_path)
    manifest["recomposite"] = str(recomposite_path)

    board_path = RIAN_ROOT / "runtime/8dir/composite_preview/rian_existing_layer_alpha_proof_board_v01.png"
    build_board(
        [
            ("official reference", REFERENCE, "solid"),
            ("concept-alpha recomposite", recomposite_path, "solid"),
            ("weapon source v02", SOURCES["weapon_overlay"], "solid"),
            ("weapon alpha proof", PROOF_ROOT / "rian_weapon_overlay_concept_alpha_sheet_v01.png", "checker"),
            ("upper armor source v03", SOURCES["upper_armor_overlay"], "solid"),
            ("upper armor alpha proof", PROOF_ROOT / "rian_upper_armor_overlay_concept_alpha_sheet_v01.png", "checker"),
        ],
        board_path,
    )
    manifest["board"] = str(board_path)
    (PROOF_ROOT / "manifest_v01.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(board_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
