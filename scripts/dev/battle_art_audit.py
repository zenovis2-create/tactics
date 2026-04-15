#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import argparse
import json


ROOT = Path("/Volumes/AI/tactics")

ASSET_GROUPS = {
    "button_icons": ROOT / "assets/ui/icons_generated",
    "object_icons": ROOT / "assets/ui/object_icons_generated",
    "unit_role_icons": ROOT / "assets/ui/unit_role_icons_generated",
    "unit_token_art": ROOT / "assets/ui/unit_token_art_generated",
    "tile_icons": ROOT / "assets/ui/tile_icons_generated",
    "tile_cards": ROOT / "assets/ui/tile_cards_generated",
    "fx": ROOT / "assets/ui/fx_generated",
}

PRODUCTION_OVERRIDE_DIRS = {
    "button_icons": ROOT / "assets/ui/production/button_icons",
    "object_icons": ROOT / "assets/ui/production/object_icons",
    "unit_role_icons": ROOT / "assets/ui/production/unit_role_icons",
    "unit_token_art": ROOT / "assets/ui/production/unit_token_art",
    "tile_icons": ROOT / "assets/ui/production/tile_icons",
    "tile_cards": ROOT / "assets/ui/production/tile_cards",
    "fx": ROOT / "assets/ui/production/fx",
}

INTEGRATION_FILES = {
    "button_icons": [
        ROOT / "scripts/battle/battle_hud.gd",
        ROOT / "scenes/battle/BattleHUD.tscn",
        ROOT / "scripts/battle/battle_art_catalog.gd",
    ],
    "object_icons": [
        ROOT / "scripts/battle/interactive_object_actor.gd",
        ROOT / "scenes/battle/InteractiveObject.tscn",
        ROOT / "scripts/battle/battle_art_catalog.gd",
    ],
    "unit_role_icons": [
        ROOT / "scripts/battle/unit_actor.gd",
        ROOT / "scenes/battle/Unit.tscn",
        ROOT / "scripts/battle/battle_art_catalog.gd",
    ],
    "unit_token_art": [
        ROOT / "scripts/battle/unit_actor.gd",
        ROOT / "scenes/battle/Unit.tscn",
        ROOT / "scripts/battle/battle_art_catalog.gd",
    ],
    "tile_icons": [
        ROOT / "scripts/battle/battle_board.gd",
        ROOT / "scripts/battle/battle_art_catalog.gd",
    ],
    "tile_cards": [
        ROOT / "scripts/battle/battle_board.gd",
        ROOT / "scripts/battle/battle_art_catalog.gd",
    ],
    "fx": [
        ROOT / "scripts/battle/battle_controller.gd",
        ROOT / "scenes/battle/BattleScene.tscn",
        ROOT / "scripts/battle/battle_art_catalog.gd",
    ],
}


def summarize_group(name: str, path: Path) -> dict:
    files = sorted(p.name for p in path.glob("*.png")) if path.exists() else []
    override_dir = PRODUCTION_OVERRIDE_DIRS.get(name)
    override_files = sorted(p.name for p in override_dir.glob("*.png")) if override_dir and override_dir.exists() else []
    effective_sources = {}
    for file_name in files:
        if file_name in override_files:
            effective_sources[file_name] = "production"
        else:
            effective_sources[file_name] = "generated"
    return {
        "group": name,
        "path": str(path),
        "exists": path.exists(),
        "count": len(files),
        "files": files,
        "production_override_path": str(override_dir) if override_dir else "",
        "production_override_count": len(override_files),
        "production_override_files": override_files,
        "effective_sources": effective_sources,
        "integration_files": [str(p) for p in INTEGRATION_FILES.get(name, [])],
    }


def build_report() -> dict:
    return {
        "root": str(ROOT),
        "groups": [summarize_group(name, path) for name, path in ASSET_GROUPS.items()],
    }


def render_markdown(report: dict) -> str:
    lines: list[str] = []
    lines.append("# Battle Art Audit")
    lines.append("")
    lines.append("## Scope")
    lines.append("")
    lines.append(f"- Root: `{report['root']}`")
    lines.append("- Purpose: enumerate current battle art replacement groups and their runtime integration points.")
    lines.append("")
    lines.append("## Groups")
    lines.append("")

    for group in report["groups"]:
        lines.append(f"### `{group['group']}`")
        lines.append("")
        lines.append(f"- Path: `{group['path']}`")
        lines.append(f"- Exists: `{group['exists']}`")
        lines.append(f"- File count: `{group['count']}`")
        lines.append(f"- Production override path: `{group['production_override_path']}`")
        lines.append(f"- Production override count: `{group['production_override_count']}`")
        if group["files"]:
            lines.append("- Files:")
            for file_name in group["files"]:
                lines.append(f"  - `{file_name}`")
        else:
            lines.append("- Files: none")
        if group["production_override_files"]:
            lines.append("- Production override files:")
            for file_name in group["production_override_files"]:
                lines.append(f"  - `{file_name}`")
        if group["effective_sources"]:
            lines.append("- Effective source:")
            for file_name, source in group["effective_sources"].items():
                lines.append(f"  - `{file_name}` -> `{source}`")
        if group["integration_files"]:
            lines.append("- Runtime integration:")
            for file_path in group["integration_files"]:
                lines.append(f"  - `{file_path}`")
        lines.append("")

    lines.append("## Recommended First Replacement Sprint")
    lines.append("")
    lines.append("1. `unit_token_art` and `unit_role_icons`")
    lines.append("2. `object_icons`")
    lines.append("3. `fx`")
    lines.append("")
    lines.append("## Verification")
    lines.append("")
    lines.append("- `scripts/dev/check_runnable_gate0.sh`")
    lines.append("- `scripts/dev/m1_playtest_runner.gd`")
    lines.append("- `scripts/dev/m3_ui_runner.gd`")
    lines.append("- `scripts/dev/render_representative_snapshots.sh`")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write-json", dest="write_json")
    parser.add_argument("--write-md", dest="write_md")
    args = parser.parse_args()

    report = build_report()
    rendered_json = json.dumps(report, indent=2, ensure_ascii=False)
    rendered_md = render_markdown(report)

    if args.write_json:
        Path(args.write_json).write_text(rendered_json + "\n", encoding="utf-8")
    if args.write_md:
        Path(args.write_md).write_text(rendered_md + "\n", encoding="utf-8")

    if not args.write_json and not args.write_md:
        print(rendered_json)
    else:
        if args.write_json:
            print(args.write_json)
        if args.write_md:
            print(args.write_md)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
