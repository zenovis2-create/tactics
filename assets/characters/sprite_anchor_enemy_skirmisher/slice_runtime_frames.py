from pathlib import Path
import json

try:
    from PIL import Image
except ImportError as exc:  # pragma: no cover
    raise SystemExit("Pillow is required. Install with: python3 -m pip install pillow") from exc

ROOT = Path("/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher")


def main() -> None:
    config = json.loads((ROOT / "frame_selection_v01.json").read_text())
    width = int(config["frame_width"])
    height = int(config["frame_height"])
    for state_name, state_cfg in config["states"].items():
        image = Image.open(ROOT / state_cfg["source"]).convert("RGBA")
        output_dir = ROOT / state_cfg["output_dir"]
        output_dir.mkdir(parents=True, exist_ok=True)
        for frame_index, (cell_x, cell_y) in enumerate(state_cfg["frames"]):
            left = cell_x * width
            top = cell_y * height
            frame = image.crop((left, top, left + width, top + height))
            output_path = output_dir / f"{state_cfg['prefix']}_{frame_index:02d}.png"
            frame.save(output_path)
            print(f"[{state_name}] saved {output_path}")


if __name__ == "__main__":
    main()
