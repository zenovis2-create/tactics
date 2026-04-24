#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent
OUT_DIR = ROOT / "masks"
SHEET_SIZE = (1536, 1024)
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

# Relative polygons within a 384x512 direction cell.
WEAPON_POLYGONS = {
    "front": [(26, 482), (56, 492), (145, 322), (119, 308)],
    "front_right": [(18, 474), (50, 487), (142, 315), (116, 300)],
    "right": [(34, 444), (67, 459), (158, 334), (133, 312)],
    "back_right": [(274, 324), (302, 306), (370, 470), (340, 484)],
    "back": [(267, 310), (298, 295), (368, 457), (338, 474)],
    "back_left": [(250, 323), (280, 307), (354, 455), (326, 472)],
    "left": [(29, 493), (60, 506), (157, 346), (130, 329)],
    "front_left": [(101, 356), (134, 340), (242, 494), (210, 510)],
}

WEAPON_HILT_BOXES = {
    "front": (70, 296, 140, 372),
    "front_right": (76, 286, 146, 360),
    "right": (102, 300, 170, 360),
    "back_right": (244, 292, 318, 363),
    "back": (242, 276, 315, 350),
    "back_left": (224, 292, 296, 360),
    "left": (98, 316, 166, 382),
    "front_left": (96, 326, 168, 392),
}

UPPER_ARMOR_BOXES = {
    "front": (118, 148, 272, 252),
    "front_right": (116, 148, 278, 252),
    "right": (144, 150, 268, 260),
    "back_right": (112, 150, 262, 266),
    "back": (108, 152, 276, 270),
    "back_left": (120, 150, 270, 266),
    "left": (126, 150, 252, 264),
    "front_left": (120, 148, 280, 258),
}

FACE_GUARD_BOXES = {
    "front": (118, 38, 256, 150),
    "front_right": (116, 40, 256, 150),
    "right": (126, 40, 260, 150),
    "back_right": (120, 40, 262, 152),
    "back": (112, 40, 266, 154),
    "back_left": (114, 40, 266, 154),
    "left": (118, 40, 258, 152),
    "front_left": (118, 40, 260, 150),
}


def offset_points(points: list[tuple[int, int]], col: int, row: int) -> list[tuple[int, int]]:
    return [(x + col * CELL_W, y + row * CELL_H) for x, y in points]


def offset_box(box: tuple[int, int, int, int], col: int, row: int) -> tuple[int, int, int, int]:
    x0, y0, x1, y1 = box
    return (x0 + col * CELL_W, y0 + row * CELL_H, x1 + col * CELL_W, y1 + row * CELL_H)


def build_weapon_mask() -> Image.Image:
    mask = Image.new("L", SHEET_SIZE, 0)
    draw = ImageDraw.Draw(mask)
    for direction, col, row in DIRECTIONS:
        draw.polygon(offset_points(WEAPON_POLYGONS[direction], col, row), fill=255)
        draw.rounded_rectangle(offset_box(WEAPON_HILT_BOXES[direction], col, row), radius=10, fill=255)
    return mask


def build_upper_armor_mask() -> Image.Image:
    mask = Image.new("L", SHEET_SIZE, 0)
    draw = ImageDraw.Draw(mask)
    for direction, col, row in DIRECTIONS:
        draw.rounded_rectangle(offset_box(UPPER_ARMOR_BOXES[direction], col, row), radius=28, fill=255)
        # Keep the face and hair protected even where the armor edit box is broad.
        draw.rectangle(offset_box(FACE_GUARD_BOXES[direction], col, row), fill=0)
    return mask


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    build_weapon_mask().save(OUT_DIR / "rian_weapon_overlay_mask_v01.png")
    build_upper_armor_mask().save(OUT_DIR / "rian_upper_armor_overlay_mask_v01.png")
    metadata = {
        "sheet_size": SHEET_SIZE,
        "cell_size": [CELL_W, CELL_H],
        "directions": [{"name": name, "col": col, "row": row} for name, col, row in DIRECTIONS],
        "mask_contract": {
            "white": "editable region",
            "black": "protected reference anchor region",
        },
        "source_of_truth": "../legacy_reference/rian_8dir_sheet_source_v02.png",
    }
    (ROOT / "mask_layout_v01.json").write_text(json.dumps(metadata, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
