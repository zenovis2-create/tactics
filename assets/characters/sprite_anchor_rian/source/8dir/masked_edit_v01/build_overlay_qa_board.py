#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


PACK_ROOT = Path(__file__).resolve().parent
RIAN_ROOT = PACK_ROOT.parents[2]
OUT_PATH = RIAN_ROOT / "runtime/8dir/composite_preview/rian_masked_overlay_qa_board_v01.png"

REFERENCE = RIAN_ROOT / "source/8dir/legacy_reference/rian_8dir_sheet_source_v02.png"
WEAPON_MASK = PACK_ROOT / "masks/rian_weapon_overlay_mask_v01.png"
ARMOR_MASK = PACK_ROOT / "masks/rian_upper_armor_overlay_mask_v01.png"
WEAPON_LAYER = RIAN_ROOT / "source/8dir/weapon_overlay/rian_weapon_overlay_8dir_sheet_source_v03_masked.png"
ARMOR_LAYER = RIAN_ROOT / "source/8dir/upper_armor_overlay/rian_upper_armor_overlay_8dir_sheet_source_v04_masked.png"
RECOMPOSITE = RIAN_ROOT / "runtime/8dir/composite_preview/rian_masked_overlay_baseline_v01.png"

THUMB_SIZE = (384, 256)
PADDING = 24
LABEL_H = 34
COLS = 2


def checker(size: tuple[int, int], tile: int = 16) -> Image.Image:
    image = Image.new("RGBA", size, (230, 230, 230, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(196, 196, 196, 255))
    return image


def load_thumb(path: Path, background: str) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    image.thumbnail(THUMB_SIZE, Image.Resampling.LANCZOS)
    if background == "checker":
        canvas = checker(THUMB_SIZE)
    else:
        canvas = Image.new("RGBA", THUMB_SIZE, (238, 234, 229, 255))
    x = (THUMB_SIZE[0] - image.width) // 2
    y = (THUMB_SIZE[1] - image.height) // 2
    canvas.alpha_composite(image, (x, y))
    return canvas


def mask_preview(path: Path) -> Image.Image:
    mask = Image.open(path).convert("L")
    preview = Image.new("RGBA", mask.size, (0, 0, 0, 255))
    overlay = Image.new("RGBA", mask.size, (255, 255, 255, 255))
    preview.paste(overlay, (0, 0), mask)
    preview.thumbnail(THUMB_SIZE, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", THUMB_SIZE, (30, 30, 30, 255))
    x = (THUMB_SIZE[0] - preview.width) // 2
    y = (THUMB_SIZE[1] - preview.height) // 2
    canvas.alpha_composite(preview, (x, y))
    return canvas


def draw_tile(board: Image.Image, index: int, label: str, thumb: Image.Image) -> None:
    draw = ImageDraw.Draw(board)
    col = index % COLS
    row = index // COLS
    x = PADDING + col * (THUMB_SIZE[0] + PADDING)
    y = PADDING + row * (THUMB_SIZE[1] + LABEL_H + PADDING)
    draw.text((x, y), label, fill=(32, 32, 32), font=ImageFont.load_default())
    board.alpha_composite(thumb, (x, y + LABEL_H))
    draw.rectangle((x, y + LABEL_H, x + THUMB_SIZE[0], y + LABEL_H + THUMB_SIZE[1]), outline=(70, 70, 70), width=1)


def main() -> int:
    tiles = [
        ("official reference anchor", load_thumb(REFERENCE, "solid")),
        ("baseline recomposite", load_thumb(RECOMPOSITE, "solid")),
        ("weapon mask", mask_preview(WEAPON_MASK)),
        ("weapon overlay alpha extraction", load_thumb(WEAPON_LAYER, "checker")),
        ("upper armor mask", mask_preview(ARMOR_MASK)),
        ("upper armor overlay alpha extraction", load_thumb(ARMOR_LAYER, "checker")),
    ]
    rows = (len(tiles) + COLS - 1) // COLS
    width = PADDING + COLS * THUMB_SIZE[0] + (COLS - 1) * PADDING + PADDING
    height = PADDING + rows * (THUMB_SIZE[1] + LABEL_H) + (rows - 1) * PADDING + PADDING
    board = Image.new("RGBA", (width, height), (246, 243, 238, 255))
    for index, (label, thumb) in enumerate(tiles):
        draw_tile(board, index, label, thumb)
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    board.save(OUT_PATH)
    print(OUT_PATH)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
