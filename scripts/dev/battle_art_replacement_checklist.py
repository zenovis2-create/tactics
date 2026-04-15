#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


ROOT = Path("/Volumes/AI/tactics")

GROUPS = [
    ("button_icons", ROOT / "assets/ui/icons_generated", ROOT / "assets/ui/production/button_icons"),
    ("object_icons", ROOT / "assets/ui/object_icons_generated", ROOT / "assets/ui/production/object_icons"),
    ("unit_role_icons", ROOT / "assets/ui/unit_role_icons_generated", ROOT / "assets/ui/production/unit_role_icons"),
    ("unit_token_art", ROOT / "assets/ui/unit_token_art_generated", ROOT / "assets/ui/production/unit_token_art"),
    ("tile_icons", ROOT / "assets/ui/tile_icons_generated", ROOT / "assets/ui/production/tile_icons"),
    ("tile_cards", ROOT / "assets/ui/tile_cards_generated", ROOT / "assets/ui/production/tile_cards"),
    ("fx", ROOT / "assets/ui/fx_generated", ROOT / "assets/ui/production/fx"),
]


def main() -> int:
    out_path = ROOT / "docs" / "production" / "battle_art_replacement_checklist_v1.md"
    lines: list[str] = []
    lines.append("# Battle Art Replacement Checklist")
    lines.append("")
    lines.append("Use this to track which generated battle assets have been replaced by production overrides.")
    lines.append("")
    lines.append("## Status")
    lines.append("")

    for name, generated_dir, production_dir in GROUPS:
        generated = sorted(p.name for p in generated_dir.glob("*.png"))
        production = set(p.name for p in production_dir.glob("*.png")) if production_dir.exists() else set()
        done = sum(1 for f in generated if f in production)
        total = len(generated)
        lines.append(f"### `{name}`")
        lines.append("")
        lines.append(f"- Generated count: `{total}`")
        lines.append(f"- Production replaced: `{done}`")
        lines.append(f"- Production dir: `{production_dir}`")
        lines.append("")
        for file_name in generated:
            mark = "x" if file_name in production else " "
            lines.append(f"- [{mark}] `{file_name}`")
        lines.append("")

    lines.append("## Verification After Any Replacement Batch")
    lines.append("")
    lines.append("- `scripts/dev/check_runnable_gate0.sh`")
    lines.append("- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd`")
    lines.append("- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd`")
    lines.append("- `scripts/dev/render_representative_snapshots.sh /Volumes/AI/tactics/.codex-representative-snaps`")
    lines.append("")

    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(str(out_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
