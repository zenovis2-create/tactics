#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from PIL import Image, ImageDraw


def load_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def fit(img: Image.Image, width: int, height: int) -> Image.Image:
    return img.resize((width, height), Image.LANCZOS)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--idle-v01", required=True)
    ap.add_argument("--idle-v02", required=True)
    ap.add_argument("--cast-v01", required=True)
    ap.add_argument("--cast-v02", required=True)
    ap.add_argument("--attack-v01", required=True)
    ap.add_argument("--attack-v02", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    rows = [
        ("Idle", load_rgba(Path(args.idle_v01)), load_rgba(Path(args.idle_v02))),
        ("Cast", load_rgba(Path(args.cast_v01)), load_rgba(Path(args.cast_v02))),
        ("Attack", load_rgba(Path(args.attack_v01)), load_rgba(Path(args.attack_v02))),
    ]

    cell_w = 384
    cell_h = 256
    gap = 32
    title_h = 26
    label_w = 96
    board_w = label_w + gap * 4 + cell_w * 2
    board_h = gap + len(rows) * (title_h + cell_h + gap)
    board = Image.new("RGBA", (board_w, board_h), (245, 242, 240, 255))
    draw = ImageDraw.Draw(board)

    draw.text((label_w + gap, 8), "Legacy", fill=(48, 48, 48, 255))
    draw.text((label_w + gap * 2 + cell_w, 8), "Layered", fill=(48, 48, 48, 255))

    for idx, (label, left_img, right_img) in enumerate(rows):
        y = gap + idx * (title_h + cell_h + gap)
        draw.text((16, y + 8), label, fill=(48, 48, 48, 255))
        board.alpha_composite(fit(left_img, cell_w, cell_h), (label_w + gap, y + title_h))
        board.alpha_composite(fit(right_img, cell_w, cell_h), (label_w + gap * 2 + cell_w, y + title_h))

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    board.save(out_path)
    print(out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
