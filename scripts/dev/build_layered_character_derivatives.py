#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from PIL import Image


def load_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def alpha_bbox(img: Image.Image):
    alpha = img.getchannel("A")
    return alpha.getbbox()


def extract_direction_cell(img: Image.Image, direction: str) -> Image.Image:
    mapping = {
        "front": (0, 0),
        "front_right": (1, 0),
        "right": (2, 0),
        "back_right": (3, 0),
        "back": (0, 1),
        "back_left": (1, 1),
        "left": (2, 1),
        "front_left": (3, 1),
    }
    col, row = mapping[direction]
    cell_w = img.width // 4
    cell_h = img.height // 2
    left = col * cell_w
    top = row * cell_h
    return img.crop((left, top, left + cell_w, top + cell_h))


def crop_to_square(img: Image.Image, bbox, *, center_bias_y: float = 0.5, pad_ratio: float = 0.12) -> Image.Image:
    left, top, right, bottom = bbox
    w = right - left
    h = bottom - top
    size = int(max(w, h) * (1 + pad_ratio * 2))

    cx = (left + right) / 2
    cy = top + h * center_bias_y

    crop_left = int(round(cx - size / 2))
    crop_top = int(round(cy - size / 2))
    crop_right = crop_left + size
    crop_bottom = crop_top + size

    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    src_left = max(0, crop_left)
    src_top = max(0, crop_top)
    src_right = min(img.width, crop_right)
    src_bottom = min(img.height, crop_bottom)

    region = img.crop((src_left, src_top, src_right, src_bottom))
    paste_x = src_left - crop_left
    paste_y = src_top - crop_top
    out.alpha_composite(region, (paste_x, paste_y))
    return out


def build_portrait(img: Image.Image, size: int) -> Image.Image:
    cell = extract_direction_cell(img, "front_right")
    bbox = alpha_bbox(cell)
    if bbox is None:
        return Image.new("RGBA", (size, size), (0, 0, 0, 0))
    square = crop_to_square(cell, bbox, center_bias_y=0.24, pad_ratio=0.20)
    return square.resize((size, size), Image.LANCZOS)


def build_token(img: Image.Image, size: int) -> Image.Image:
    cell = extract_direction_cell(img, "front")
    bbox = alpha_bbox(cell)
    if bbox is None:
        return Image.new("RGBA", (size, size), (0, 0, 0, 0))
    square = crop_to_square(cell, bbox, center_bias_y=0.44, pad_ratio=0.10)
    return square.resize((size, size), Image.LANCZOS)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--composite", required=True)
    ap.add_argument("--portrait-out", required=True)
    ap.add_argument("--token-out", required=True)
    ap.add_argument("--portrait-size", type=int, default=1024)
    ap.add_argument("--token-size", type=int, default=48)
    args = ap.parse_args()

    composite = load_rgba(Path(args.composite))
    portrait = build_portrait(composite, args.portrait_size)
    token = build_token(composite, args.token_size)

    portrait_out = Path(args.portrait_out)
    token_out = Path(args.token_out)
    portrait_out.parent.mkdir(parents=True, exist_ok=True)
    token_out.parent.mkdir(parents=True, exist_ok=True)
    portrait.save(portrait_out)
    token.save(token_out)
    print(portrait_out)
    print(token_out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
