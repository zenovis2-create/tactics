#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from PIL import Image, ImageDraw


def load_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rian-portrait", required=True)
    ap.add_argument("--rian-token", required=True)
    ap.add_argument("--serin-portrait", required=True)
    ap.add_argument("--serin-token", required=True)
    ap.add_argument("--tia-portrait", required=True)
    ap.add_argument("--tia-token", required=True)
    ap.add_argument("--bran-portrait", required=True)
    ap.add_argument("--bran-token", required=True)
    ap.add_argument("--raider-portrait", required=True)
    ap.add_argument("--raider-token", required=True)
    ap.add_argument("--skirmisher-portrait", required=True)
    ap.add_argument("--skirmisher-token", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    entries = [
        ("Rian", load_rgba(Path(args.rian_portrait)), load_rgba(Path(args.rian_token))),
        ("Serin", load_rgba(Path(args.serin_portrait)), load_rgba(Path(args.serin_token))),
        ("Tia", load_rgba(Path(args.tia_portrait)), load_rgba(Path(args.tia_token))),
        ("Bran", load_rgba(Path(args.bran_portrait)), load_rgba(Path(args.bran_token))),
        ("Raider", load_rgba(Path(args.raider_portrait)), load_rgba(Path(args.raider_token))),
        ("Skirmisher", load_rgba(Path(args.skirmisher_portrait)), load_rgba(Path(args.skirmisher_token))),
    ]

    portrait_w = 256
    portrait_h = 256
    token_scale = 4
    token_w = 48 * token_scale
    token_h = 48 * token_scale
    cols = 3
    gap = 36
    title_h = 28
    cell_h = title_h + portrait_h + 16 + token_h
    cell_w = portrait_w
    rows = 2

    board = Image.new(
        "RGBA",
        (gap + cols * (cell_w + gap), gap + rows * (cell_h + gap)),
        (245, 242, 240, 255),
    )
    draw = ImageDraw.Draw(board)

    for idx, (label, portrait, token) in enumerate(entries):
        row = idx // cols
        col = idx % cols
        x = gap + col * (cell_w + gap)
        y = gap + row * (cell_h + gap)
        draw.text((x, y), label, fill=(48, 48, 48, 255))

        portrait_fit = portrait.resize((portrait_w, portrait_h), Image.LANCZOS)
        board.alpha_composite(portrait_fit, (x, y + title_h))

        token_fit = token.resize((token_w, token_h), Image.NEAREST)
        token_x = x + (cell_w - token_w) // 2
        token_y = y + title_h + portrait_h + 16
        board.alpha_composite(token_fit, (token_x, token_y))

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    board.save(out_path)
    print(out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
