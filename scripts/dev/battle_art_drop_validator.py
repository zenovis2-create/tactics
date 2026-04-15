#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json

from PIL import Image


ROOT = Path("/Volumes/AI/tactics")

GROUP_SPECS = {
    "button_icons": {
        "dir": ROOT / "assets/ui/production/button_icons",
        "expected": ["bag.png", "back.png", "wait.png", "enemy.png"],
        "size": (32, 32),
    },
    "object_icons": {
        "dir": ROOT / "assets/ui/production/object_icons",
        "expected": ["chest.png", "lever.png", "altar.png", "gate.png"],
        "size": (40, 40),
    },
    "unit_role_icons": {
        "dir": ROOT / "assets/ui/production/unit_role_icons",
        "expected": ["knight.png", "ranger.png", "mystic.png", "vanguard.png", "medic.png", "boss.png"],
        "size": (28, 28),
    },
    "unit_token_art": {
        "dir": ROOT / "assets/ui/production/unit_token_art",
        "expected": ["knight.png", "ranger.png", "mystic.png", "vanguard.png", "medic.png", "boss.png"],
        "size": (48, 48),
    },
    "tile_icons": {
        "dir": ROOT / "assets/ui/production/tile_icons",
        "expected": ["forest.png", "wall.png", "bridge.png", "highground.png", "battery.png", "cathedral.png", "bell.png"],
        "size": (24, 24),
    },
    "tile_cards": {
        "dir": ROOT / "assets/ui/production/tile_cards",
        "expected": ["plain.png", "forest.png", "wall.png", "bridge.png", "highground.png", "battery.png", "bell.png"],
        "size": (48, 48),
    },
    "fx": {
        "dir": ROOT / "assets/ui/production/fx",
        "expected": ["hit_spark.png", "mark_ring.png", "objective_burst.png"],
        "size": (64, 64),
    },
}


def inspect_file(path: Path, expected_size: tuple[int, int]) -> dict:
    if not path.exists():
        return {"exists": False, "size_ok": False, "actual_size": None}
    with Image.open(path) as img:
        size = tuple(img.size)
    return {
        "exists": True,
        "size_ok": size == expected_size,
        "actual_size": size,
    }


def build_report() -> dict:
    groups: list[dict] = []
    for name, spec in GROUP_SPECS.items():
        dir_path: Path = spec["dir"]
        expected_files: list[str] = spec["expected"]
        expected_size: tuple[int, int] = spec["size"]
        file_reports = []
        for file_name in expected_files:
            report = inspect_file(dir_path / file_name, expected_size)
            report["file"] = file_name
            file_reports.append(report)
        groups.append(
            {
                "group": name,
                "dir": str(dir_path),
                "expected_size": expected_size,
                "files": file_reports,
            }
        )
    return {"root": str(ROOT), "groups": groups}


def render_markdown(report: dict) -> str:
    lines: list[str] = []
    lines.append("# Battle Art Drop Validation")
    lines.append("")
    lines.append("Validate production override assets before runtime replacement review.")
    lines.append("")
    for group in report["groups"]:
        lines.append(f"## `{group['group']}`")
        lines.append("")
        lines.append(f"- Dir: `{group['dir']}`")
        lines.append(f"- Expected size: `{group['expected_size'][0]}x{group['expected_size'][1]}`")
        lines.append("")
        for file_report in group["files"]:
            if not file_report["exists"]:
                lines.append(f"- [ ] `{file_report['file']}` missing")
            elif not file_report["size_ok"]:
                lines.append(
                    f"- [ ] `{file_report['file']}` wrong size `{file_report['actual_size'][0]}x{file_report['actual_size'][1]}`"
                )
            else:
                lines.append(f"- [x] `{file_report['file']}` ok")
        lines.append("")
    return "\n".join(lines)


def main() -> int:
    report = build_report()
    out_json = ROOT / "docs/production/battle_art_drop_validation_v1.json"
    out_md = ROOT / "docs/reviews/2026-04-14-battle-art-drop-validation-v1.md"
    out_json.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    out_md.write_text(render_markdown(report) + "\n", encoding="utf-8")
    print(str(out_json))
    print(str(out_md))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
