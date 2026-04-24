from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageChops, ImageStat
import json

ROOT = Path("/tmp/tactics-visual-captures")
DIFF_DIR = ROOT / "diffs"
REPORT_PATH = ROOT / "chapter_visual_diff_report.json"
PAIRINGS = [
    ("ch07_preview.png", "ch07_battle.png", "ch07"),
    ("ch09b_preview.png", "ch09b_battle.png", "ch09b"),
    ("ch10_preview.png", "ch10_battle.png", "ch10"),
]


def ensure_exists(path: Path) -> None:
    if not path.exists():
        raise FileNotFoundError(path)


def compute_pair(left_path: Path, right_path: Path, label: str) -> dict:
    ensure_exists(left_path)
    ensure_exists(right_path)
    left = Image.open(left_path).convert("RGBA")
    right = Image.open(right_path).convert("RGBA")
    if left.size != right.size:
        right = right.resize(left.size)

    diff = ImageChops.difference(left, right)
    stat = ImageStat.Stat(diff)
    mean_rgba = stat.mean
    mean_abs = sum(mean_rgba[:3]) / 3.0

    DIFF_DIR.mkdir(parents=True, exist_ok=True)
    diff_path = DIFF_DIR / f"{label}_diff.png"
    diff.save(diff_path)

    return {
        "label": label,
        "preview": str(left_path),
        "battle": str(right_path),
        "diff": str(diff_path),
        "size": {"width": left.size[0], "height": left.size[1]},
        "mean_abs_diff_rgb": mean_abs,
        "mean_rgba": mean_rgba,
    }


def main() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    results = []
    for left_name, right_name, label in PAIRINGS:
        results.append(compute_pair(ROOT / left_name, ROOT / right_name, label))
    REPORT_PATH.write_text(json.dumps({"pairs": results}, ensure_ascii=False, indent=2))
    print(REPORT_PATH)


if __name__ == "__main__":
    main()
