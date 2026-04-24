#!/usr/bin/env python3
from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path
from PIL import Image


def _within_bg_tolerance(rgb: tuple[int, int, int], bg: tuple[int, int, int], tol: int) -> bool:
    return (
        abs(rgb[0] - bg[0]) <= tol
        and abs(rgb[1] - bg[1]) <= tol
        and abs(rgb[2] - bg[2]) <= tol
    )


def _detect_bg_color(img: Image.Image) -> tuple[int, int, int]:
    samples = [
        img.getpixel((0, 0))[:3],
        img.getpixel((img.width - 1, 0))[:3],
        img.getpixel((0, img.height - 1))[:3],
        img.getpixel((img.width - 1, img.height - 1))[:3],
    ]
    return tuple(sum(px[i] for px in samples) // len(samples) for i in range(3))


def _clear_edge_connected_background(img: Image.Image, bg: tuple[int, int, int], tol: int) -> None:
    px = img.load()
    w, h = img.size
    seen: set[tuple[int, int]] = set()
    q: deque[tuple[int, int]] = deque()

    for x in range(w):
        q.append((x, 0))
        q.append((x, h - 1))
    for y in range(h):
        q.append((0, y))
        q.append((w - 1, y))

    while q:
        x, y = q.popleft()
        if (x, y) in seen:
            continue
        seen.add((x, y))
        rgba = px[x, y]
        if not _within_bg_tolerance(rgba[:3], bg, tol):
            continue
        px[x, y] = (rgba[0], rgba[1], rgba[2], 0)
        if x > 0:
            q.append((x - 1, y))
        if x < w - 1:
            q.append((x + 1, y))
        if y > 0:
            q.append((x, y - 1))
        if y < h - 1:
            q.append((x, y + 1))


def load_as_rgba(path: Path, bg_threshold: int) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    bg = _detect_bg_color(img)
    tol = max(8, 255 - bg_threshold)
    _clear_edge_connected_background(img, bg, tol)
    return img


def compose(base: Image.Image, layers: list[Image.Image]) -> Image.Image:
    out = base.copy()
    for layer in layers:
        out.alpha_composite(layer)
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-body", required=True)
    ap.add_argument("--base-outfit", required=True)
    ap.add_argument("--weapon-overlay", required=True)
    ap.add_argument("--upper-armor-overlay", required=True)
    ap.add_argument("--shield-overlay")
    ap.add_argument("--out", required=True)
    ap.add_argument("--bg-threshold", type=int, default=232)
    args = ap.parse_args()

    base = load_as_rgba(Path(args.base_body), args.bg_threshold)
    outfit = load_as_rgba(Path(args.base_outfit), args.bg_threshold)
    weapon = load_as_rgba(Path(args.weapon_overlay), args.bg_threshold)
    armor = load_as_rgba(Path(args.upper_armor_overlay), args.bg_threshold)
    layers = [outfit, armor, weapon]
    if args.shield_overlay:
        layers.append(load_as_rgba(Path(args.shield_overlay), args.bg_threshold))

    out = compose(base, layers)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out.save(out_path)
    print(out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
