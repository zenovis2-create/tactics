#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from PIL import Image


ROOT = Path("/Volumes/AI/tactics/assets/characters/sprite_anchor_serin")
FRAME_W = 256
FRAME_H = 256
FRAMES = [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (0, 1), (1, 1), (2, 1)]
STATES = {
    "idle": "serin_idle_sheet_source_v02_layered.png",
    "cast": "serin_cast_sheet_source_v03_layered.png",
    "attack": "serin_attack_sheet_source_v03_layered.png",
}


def export_state(state: str, source_name: str) -> None:
    image = Image.open(ROOT / "source" / source_name).convert("RGBA")
    out_dir = ROOT / "runtime_v02_layered_candidate" / state
    out_dir.mkdir(parents=True, exist_ok=True)
    for frame_index, (cell_x, cell_y) in enumerate(FRAMES):
        left = cell_x * FRAME_W
        top = cell_y * FRAME_H
        frame = image.crop((left, top, left + FRAME_W, top + FRAME_H))
        out_path = out_dir / f"serin_{state}_{frame_index:02d}.png"
        frame.save(out_path)
        print(out_path)


def main() -> int:
    for state, source_name in STATES.items():
        export_state(state, source_name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
