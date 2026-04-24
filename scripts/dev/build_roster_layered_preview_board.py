#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from PIL import Image, ImageDraw


def load_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rian", required=True)
    ap.add_argument("--serin", required=True)
    ap.add_argument("--tia", required=True)
    ap.add_argument("--bran", required=True)
    ap.add_argument("--raider", required=True)
    ap.add_argument("--skirmisher", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--gap", type=int, default=40)
    args = ap.parse_args()

    entries = [
        ("Rian", load_rgba(Path(args.rian))),
        ("Serin", load_rgba(Path(args.serin))),
        ("Tia", load_rgba(Path(args.tia))),
        ("Bran", load_rgba(Path(args.bran))),
        ("Raider", load_rgba(Path(args.raider))),
        ("Skirmisher", load_rgba(Path(args.skirmisher))),
    ]

    cols = 3
    rows = 2
    cell_w = max(img.width for _, img in entries)
    cell_h = max(img.height for _, img in entries)
    gap = args.gap
    title_h = 28
    board_w = cell_w * cols + gap * (cols + 1)
    board_h = (cell_h + title_h) * rows + gap * (rows + 1)

    board = Image.new("RGBA", (board_w, board_h), (245, 242, 240, 255))
    draw = ImageDraw.Draw(board)

    for idx, (label, img) in enumerate(entries):
        row = idx // cols
        col = idx % cols
        x = gap + col * (cell_w + gap)
        y = gap + row * (cell_h + title_h + gap)
        draw.text((x, y), label, fill=(48, 48, 48, 255))
        paste_x = x + (cell_w - img.width) // 2
        paste_y = y + title_h + (cell_h - img.height) // 2
        board.alpha_composite(img, (paste_x, paste_y))

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    board.save(out_path)
    print(out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
