from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path("/Volumes/AI/tactics")
GODOT = "godot4"
TMP_REPORT_PATH = Path("/tmp/tactics-visual-qa-report.json")
GENERATED_DIR = ROOT / "docs" / "generated"
JSON_REPORT_PATH = GENERATED_DIR / "visual_qa_suite_report_v01.json"
MD_REPORT_PATH = GENERATED_DIR / "visual_qa_suite_report_v01.md"

RUNNERS = [
    "res://scripts/dev/chapter_visual_alignment_runner.gd",
    "res://scripts/dev/battle_visual_qa_runner.gd",
    "res://scripts/dev/representative_battle_visual_runner.gd",
    "res://scripts/dev/ch07_ritual_city_preview_runner.gd",
    "res://scripts/dev/ch09b_root_archive_preview_runner.gd",
    "res://scripts/dev/ch10_final_bell_preview_runner.gd",
    "res://scripts/dev/attack_camera_timing_runner.gd",
    "res://scripts/dev/movement_animation_runner.gd",
]


def run_runner(path: str) -> dict:
    cmd = [GODOT, "--headless", "--path", str(ROOT), "--script", path]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    summary = None
    for line in proc.stdout.splitlines():
        if line.startswith("VISUAL_QA_SUMMARY="):
            try:
                summary = json.loads(line.split("=", 1)[1])
            except Exception:
                summary = {"parse_error": True, "raw": line}
    return {
        "runner": path,
        "returncode": proc.returncode,
        "stdout": proc.stdout.strip(),
        "stderr": proc.stderr.strip(),
        "status": "pass" if proc.returncode == 0 else "fail",
        "summary": summary,
    }


def build_markdown(results: list[dict]) -> str:
    passed = sum(1 for item in results if item["status"] == "pass")
    failed = len(results) - passed
    lines = [
        "# Visual QA Suite Report V01",
        "",
        f"- total runners: `{len(results)}`",
        f"- passed: `{passed}`",
        f"- failed: `{failed}`",
        "",
        "## Runner Results",
        "",
    ]
    for item in results:
        lines.append(f"### `{item['runner']}`")
        lines.append(f"- status: `{item['status']}`")
        lines.append(f"- return code: `{item['returncode']}`")
        if item.get("summary"):
            lines.append("- summary:")
            lines.append("```json")
            lines.append(json.dumps(item["summary"], ensure_ascii=False, indent=2))
            lines.append("```")
        if item["stdout"]:
            lines.append("- stdout:")
            lines.append("```text")
            lines.append(item["stdout"])
            lines.append("```")
        if item["stderr"]:
            lines.append("- stderr:")
            lines.append("```text")
            lines.append(item["stderr"])
            lines.append("```")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> None:
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    results = [run_runner(path) for path in RUNNERS]
    payload = {"results": results}
    json_text = json.dumps(payload, ensure_ascii=False, indent=2)
    markdown_text = build_markdown(results)

    TMP_REPORT_PATH.write_text(json_text)
    JSON_REPORT_PATH.write_text(json_text)
    MD_REPORT_PATH.write_text(markdown_text)
    print(JSON_REPORT_PATH)
    print(MD_REPORT_PATH)


if __name__ == "__main__":
    main()
