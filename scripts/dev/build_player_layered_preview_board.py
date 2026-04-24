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
    ap.add_argument("--out", required=True)
    ap.add_argument("--gap", type=int, default=48)
    args = ap.parse_args()

    entries = [
        ("Rian", load_rgba(Path(args.rian))),
        ("Serin", load_rgba(Path(args.serin))),
        ("Tia", load_rgba(Path(args.tia))),
        ("Bran", load_rgba(Path(args.bran))),
    ]

    cell_w = max(img.width for _, img in entries)
    cell_h = max(img.height for _, img in entries)
    gap = args.gap

    board = Image.new("RGBA", (cell_w * 2 + gap * 3, cell_h * 2 + gap * 3), (245, 242, 240, 255))
    draw = ImageDraw.Draw(board)

    positions = [
        (gap, gap),
        (cell_w + gap * 2, gap),
        (gap, cell_h + gap * 2),
        (cell_w + gap * 2, cell_h + gap * 2),
    ]

    for (label, img), (x, y) in zip(entries, positions):
        paste_x = x + (cell_w - img.width) // 2
        paste_y = y + (cell_h - img.height) // 2
        board.alpha_composite(img, (paste_x, paste_y))
        draw.text((x, y - 22), label, fill=(48, 48, 48, 255))

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    board.save(out_path)
    print(out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
