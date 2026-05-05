#!/usr/bin/env python3
"""Check package/index readiness for the accumulated post-battle bark payload.

This is a custody/manifest check, not a runtime runner. It intentionally fails
while f-critical payload files remain unstaged/untracked or partially staged.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

STAGES = [
    *(f"data/stages/ch01_{i:02d}_stage.tres" for i in range(2, 6)),
    *(f"data/stages/ch02_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch03_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch04_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch05_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch06_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch07_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch08_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch09a_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch09b_{i:02d}_stage.tres" for i in range(1, 6)),
    *(f"data/stages/ch10_{i:02d}_stage.tres" for i in range(1, 6)),
]

RUNNERS = [
    "scripts/dev/post_battle_bark_queue_runner.gd",
    "scripts/dev/post_battle_bark_queue_runner.gd.uid",
    "scripts/dev/post_battle_handoff_runner.gd",
    "scripts/dev/post_battle_handoff_runner.gd.uid",
    "scripts/dev/post_battle_readability_runner.gd",
    "scripts/dev/post_battle_readability_runner.gd.uid",
    "scripts/dev/check_post_battle_bark_payload_package.py",
]

DIRECT_OBJECT_DEPENDENCIES = [
    "data/objects/ch05_04_truth_shelf_index.tres",
    "data/objects/ch05_04_zero_transfer_ledger.tres",
    "data/objects/ch09a_04_east_censor_pike.tres",
    "data/objects/ch09a_04_west_cell_witness.tres",
    "data/objects/ch10_02_east_crest_control.tres",
    "data/objects/ch10_02_west_crest_control.tres",
    "data/objects/ch10_03_east_corridor_anchor.tres",
    "data/objects/ch10_03_west_corridor_anchor.tres",
]

SUPPORT_FILES = [
    "scripts/data/stage_data.gd",
    "scripts/dev/ch06_ch10_boss_surface_runner.gd",
]


def git(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True)


def status_map(paths: list[str]) -> dict[str, str]:
    cp = git("status", "--porcelain=v1", "--", *paths)
    if cp.returncode != 0:
        print(cp.stderr, file=sys.stderr)
        sys.exit(cp.returncode)
    out: dict[str, str] = {}
    for line in cp.stdout.splitlines():
        if not line:
            continue
        status = line[:2]
        path = line[3:]
        if " -> " in path:
            path = path.split(" -> ", 1)[1]
        out[path] = status
    return out


def cached_names(paths: list[str], grep: str | None = None) -> set[str]:
    args = ["diff", "--cached", "--name-only"]
    if grep:
        args.append(f"-G{grep}")
    args.extend(["--", *paths])
    cp = git(*args)
    if cp.returncode != 0:
        print(cp.stderr, file=sys.stderr)
        sys.exit(cp.returncode)
    return {line.strip() for line in cp.stdout.splitlines() if line.strip()}


def unstaged_names(paths: list[str], grep: str | None = None) -> set[str]:
    args = ["diff", "--name-only"]
    if grep:
        args.append(f"-G{grep}")
    args.extend(["--", *paths])
    cp = git(*args)
    if cp.returncode != 0:
        print(cp.stderr, file=sys.stderr)
        sys.exit(cp.returncode)
    return {line.strip() for line in cp.stdout.splitlines() if line.strip()}


def review_doc_paths() -> list[str]:
    docs = sorted(Path(ROOT, "docs/reviews").glob("2026-05-05-f*-*post-battle-bark-release-qa.md"))
    docs += sorted(Path(ROOT, "docs/reviews").glob("2026-05-05-f61-post-battle-bark-payload-packaging-qa.md"))
    return [str(p.relative_to(ROOT)) for p in docs]


def main() -> int:
    failures: list[str] = []
    warnings: list[str] = []

    docs = review_doc_paths()
    manifest = STAGES + RUNNERS + docs + DIRECT_OBJECT_DEPENDENCIES + SUPPORT_FILES
    status = status_map(manifest)

    missing = [p for p in manifest if not (ROOT / p).exists()]
    if missing:
        failures.append("missing manifest paths: " + ", ".join(missing))

    bark_cached = cached_names(STAGES, "post_battle_bark_rules")
    bark_unstaged = unstaged_names(STAGES, "post_battle_bark_rules")
    if bark_unstaged:
        failures.append(f"unstaged bark stage deltas remain: {len(bark_unstaged)} files")
    if len(bark_cached) != len(STAGES):
        failures.append(f"cached bark stage coverage is {len(bark_cached)}/{len(STAGES)} files")

    partial = [p for p, s in status.items() if s == "MM"]
    if partial:
        failures.append("partially staged files in manifest: " + ", ".join(sorted(partial)))

    untracked = [p for p, s in status.items() if s == "??"]
    if untracked:
        failures.append(f"untracked manifest paths remain: {len(untracked)} files")

    unstaged_manifest = [p for p, s in status.items() if s[1] == "M"]
    if unstaged_manifest:
        failures.append(f"unstaged manifest paths remain: {len(unstaged_manifest)} files")

    for p in docs + RUNNERS:
        path = ROOT / p
        if path.exists() and path.is_file():
            data = path.read_bytes()
            if data and not data.endswith(b"\n"):
                failures.append(f"missing final newline: {p}")
            if any(line.rstrip(b" \t") != line for line in data.splitlines()):
                failures.append(f"trailing whitespace: {p}")

    print("f61 post-battle bark payload package/index check")
    print(f"manifest_paths={len(manifest)} stages={len(STAGES)} runners={len(RUNNERS)} docs={len(docs)} direct_object_dependencies={len(DIRECT_OBJECT_DEPENDENCIES)}")
    print(f"cached_bark_stage_coverage={len(bark_cached)}/{len(STAGES)}")
    print(f"unstaged_bark_stage_deltas={len(bark_unstaged)}")
    print(f"untracked_manifest_paths={len(untracked)}")
    print(f"unstaged_manifest_paths={len(unstaged_manifest)}")

    if warnings:
        print("WARNINGS:")
        for warning in warnings:
            print(f"- {warning}")
    if failures:
        print("BLOCKED:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: f61 package/index manifest is coherent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
