#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from shutil import copy2
from datetime import datetime


ROOT = Path("/Volumes/AI/tactics")
OUT_DIR = ROOT / "docs" / "production" / "handoff_pack"

FILES = [
    ROOT / "docs/plans/2026-04-14-art-replacement-priority.md",
    ROOT / "docs/plans/2026-04-14-art-production-briefs.md",
    ROOT / "docs/plans/2026-04-14-artist-handoff-onepager.md",
    OUT_DIR / "ASH-17-key-art-brief-v1.md",
    OUT_DIR / "ASH-31-battle-fx-replacement-contract-v1.md",
    ROOT / "docs/production/ASH-32-unit-token-art-replacement-contract-v1.md",
    OUT_DIR / "ASH-36-technical-art-ingest-contract-v1.md",
    ROOT / "docs/production/key_art_prompt_pack_v1.md",
    ROOT / "docs/production/battle_art_filename_matrix_v1.md",
    ROOT / "assets/ui/production/README.md",
    ROOT / "docs/production/battle_art_manifest_v1.json",
    ROOT / "docs/production/battle_art_replacement_checklist_v1.md",
    ROOT / "docs/production/battle_art_drop_validation_v1.json",
    ROOT / "docs/reviews/2026-04-14-battle-art-audit-v1.md",
    ROOT / "docs/reviews/2026-04-14-battle-art-drop-validation-v1.md",
    ROOT / ".codex-representative-snaps/tutorial00000001.png",
    ROOT / ".codex-representative-snaps/ch0300000001.png",
    ROOT / ".codex-representative-snaps/ch0700000001.png",
    ROOT / ".codex-representative-snaps/ch1000000001.png",
    ROOT / ".codex-representative-snaps/ch02_0400000001.png",
    ROOT / ".codex-representative-snaps/ch09a_0100000001.png",
    ROOT / ".codex-representative-snaps/ch04_0100000001.png",
    ROOT / ".codex-representative-snaps/ch08_0100000001.png",
    ROOT / ".codex-representative-snaps/representative_contact_sheet.png",
]


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    copied: list[str] = []
    for src in FILES:
        if not src.exists():
            continue
        dest = OUT_DIR / src.name
        if src.resolve() != dest.resolve():
            copy2(src, dest)
        copied.append(src.name)

    index = OUT_DIR / "README.md"
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    lines = [
        "# Battle Art Handoff Pack",
        "",
        f"Generated: {now}",
        "",
        "## Included Files",
        "",
    ]
    for name in copied:
        lines.append(f"- `{name}`")
    lines += [
        "",
        "## Suggested Reading Order",
        "",
        "1. `2026-04-14-artist-handoff-onepager.md`",
        "2. `ASH-36-technical-art-ingest-contract-v1.md`",
        "3. `ASH-32-unit-token-art-replacement-contract-v1.md`",
        "4. `ASH-31-battle-fx-replacement-contract-v1.md`",
        "5. `ASH-17-key-art-brief-v1.md`",
        "6. `2026-04-14-art-production-briefs.md`",
        "7. `2026-04-14-art-replacement-priority.md`",
        "8. `battle_art_replacement_checklist_v1.md`",
        "9. `2026-04-14-battle-art-audit-v1.md`",
        "10. `representative_contact_sheet.png`",
        "",
        "## Runtime Gate",
        "",
        "- `scripts/dev/check_runnable_gate0.sh`",
        "- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd`",
        "- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd`",
        "- `scripts/dev/render_representative_snapshots.sh /Volumes/AI/tactics/.codex-representative-snaps`",
        "",
    ]
    index.write_text("\n".join(lines), encoding="utf-8")
    print(str(OUT_DIR))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
