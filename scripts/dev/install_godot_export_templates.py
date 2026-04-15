#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import shutil
import sys
import tempfile
import urllib.request
import zipfile


VERSION = "4.6.2.stable"
URL = "https://godot-releases.nbg1.your-objectstorage.com/4.6.2-stable/Godot_v4.6.2-stable_export_templates.tpz"
TARGET_DIR = pathlib.Path.home() / "Library/Application Support/Godot/export_templates" / VERSION


def main() -> int:
    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmpdir:
        archive_path = pathlib.Path(tmpdir) / "export_templates.tpz"
        with urllib.request.urlopen(URL) as response, archive_path.open("wb") as handle:
            shutil.copyfileobj(response, handle)
        with zipfile.ZipFile(archive_path) as zf:
            zf.extractall(TARGET_DIR)
    nested_dir = TARGET_DIR / "templates"
    if nested_dir.is_dir():
        for child in nested_dir.iterdir():
            shutil.move(str(child), TARGET_DIR / child.name)
        nested_dir.rmdir()
    print(f"Installed export templates to {TARGET_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
