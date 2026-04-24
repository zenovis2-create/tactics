"""
Slice Serin sprite-sheet source files into runtime frames using a fixed 256x256 grid.

This is intentionally simple:
- it assumes cleanup already happened or the source sheet is good enough
- it crops whole cells based on an explicit selection manifest
- it does not try to auto-detect pivots or remove whitespace

Edit `frame_selection_v01.json` if you want different frame picks.
"""

from __future__ import annotations

import json
from pathlib import Path

try:
    from PIL import Image
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Pillow is required. Install with: python3 -m pip install pillow"
    ) from exc


ROOT = Path("/Volumes/AI/tactics/assets/characters/sprite_anchor_serin")
CONFIG_PATH = ROOT / "frame_selection_v01.json"


def load_config() -> dict:
    with CONFIG_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def crop_cell(image: Image.Image, cell_x: int, cell_y: int, width: int, height: int) -> Image.Image:
    left = cell_x * width
    top = cell_y * height
    right = left + width
    bottom = top + height
    return image.crop((left, top, right, bottom))


def export_state(state_name: str, state_cfg: dict, width: int, height: int) -> None:
    source_path = ROOT / state_cfg["source"]
    output_dir = ROOT / state_cfg["output_dir"]
    prefix = state_cfg["prefix"]
    frames = state_cfg["frames"]

    ensure_dir(output_dir)

    image = Image.open(source_path).convert("RGBA")

    for frame_index, cell in enumerate(frames):
        cell_x, cell_y = cell
        frame = crop_cell(image, cell_x, cell_y, width, height)
        output_path = output_dir / f"{prefix}_{frame_index:02d}.png"
        frame.save(output_path)
        print(f"[{state_name}] saved {output_path}")


def main() -> None:
    config = load_config()
    width = int(config["frame_width"])
    height = int(config["frame_height"])

    for state_name, state_cfg in config["states"].items():
        export_state(state_name, state_cfg, width, height)


if __name__ == "__main__":
    main()

