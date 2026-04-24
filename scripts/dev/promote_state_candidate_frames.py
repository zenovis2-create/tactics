#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from PIL import Image


FRAME_W = 256
FRAME_H = 256
FRAMES = [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (0, 1), (1, 1), (2, 1)]


def export_state(root: Path, prefix: str, state: str, source_name: str) -> None:
    image = Image.open(root / "source" / source_name).convert("RGBA")
    out_dir = root / "runtime_v02_layered_candidate" / state
    out_dir.mkdir(parents=True, exist_ok=True)
    for frame_index, (cell_x, cell_y) in enumerate(FRAMES):
        left = cell_x * FRAME_W
        top = cell_y * FRAME_H
        frame = image.crop((left, top, left + FRAME_W, top + FRAME_H))
        out_path = out_dir / f"{prefix}_{state}_{frame_index:02d}.png"
        frame.save(out_path)
        print(out_path)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--prefix", required=True)
    ap.add_argument("--idle", required=True)
    ap.add_argument("--attack", required=True)
    ap.add_argument("--move")
    ap.add_argument("--cast")
    args = ap.parse_args()

    root = Path(args.root)
    export_state(root, args.prefix, "idle", args.idle)
    if args.move:
        export_state(root, args.prefix, "move", args.move)
    if args.cast:
        export_state(root, args.prefix, "cast", args.cast)
    export_state(root, args.prefix, "attack", args.attack)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
