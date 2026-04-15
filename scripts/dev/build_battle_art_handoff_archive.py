#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import subprocess


ROOT = Path("/Volumes/AI/tactics")
HANDOFF_DIR = ROOT / "docs" / "production" / "handoff_pack"
ARCHIVE_PATH = ROOT / "docs" / "production" / "battle_art_handoff_pack_v1.zip"


def main() -> int:
    if not HANDOFF_DIR.exists():
        raise SystemExit(f"missing handoff pack directory: {HANDOFF_DIR}")

    if ARCHIVE_PATH.exists():
        ARCHIVE_PATH.unlink()

    subprocess.run(
        [
            "/usr/bin/ditto",
            "-c",
            "-k",
            "--norsrc",
            str(HANDOFF_DIR),
            str(ARCHIVE_PATH),
        ],
        check=True,
    )

    print(str(ARCHIVE_PATH))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
