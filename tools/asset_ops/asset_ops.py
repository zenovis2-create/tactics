#!/usr/bin/env python3
"""AssetOps v1 CLI for sprite candidate intake, QA, review packs, gates, and docs."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import shutil
import subprocess
import sys
from datetime import date
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
TOOL_ROOT = Path(__file__).resolve().parent
REGISTRY_PATH = TOOL_ROOT / "asset_ops_registry.json"
RULES_DIR = TOOL_ROOT / "rules"
TEMPLATES_DIR = TOOL_ROOT / "templates"
Image = None
ImageChops = None
ImageDraw = None
ImageFont = None


class AssetOpsError(RuntimeError):
    pass


def require_pillow() -> None:
    global Image, ImageChops, ImageDraw, ImageFont
    if Image is not None:
        return
    try:
        from PIL import Image as PILImage
        from PIL import ImageChops as PILImageChops
        from PIL import ImageDraw as PILImageDraw
        from PIL import ImageFont as PILImageFont
    except ModuleNotFoundError as exc:
        raise AssetOpsError(
            "Pillow is required for image-processing commands. Install it with `python3 -m pip install Pillow`, "
            "or run a non-image command such as `schema`/`verify`."
        ) from exc
    Image = PILImage
    ImageChops = PILImageChops
    ImageDraw = PILImageDraw
    ImageFont = PILImageFont


def rel(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise AssetOpsError(f"Missing JSON file: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def require_type(issues: list[str], data: dict[str, Any], key: str, expected_type: type | tuple[type, ...]) -> None:
    if key not in data:
        issues.append(f"missing_key:{key}")
        return
    if not isinstance(data[key], expected_type):
        names = (
            "|".join(t.__name__ for t in expected_type)
            if isinstance(expected_type, tuple)
            else expected_type.__name__
        )
        issues.append(f"invalid_type:{key}:expected_{names}")


def validate_manifest_schema(manifest: dict[str, Any]) -> tuple[list[str], list[str]]:
    issues: list[str] = []
    warnings: list[str] = []
    required_types: list[tuple[str, type | tuple[type, ...]]] = [
        ("schema_version", int),
        ("asset", str),
        ("state", str),
        ("candidate_id", str),
        ("source_path", str),
        ("output_dir", str),
        ("origin", str),
        ("frame_count", int),
        ("frame_size", str),
        ("frames", list),
        ("lineage", dict),
        ("qa", dict),
        ("policy", dict),
        ("artifacts", list),
        ("godot_runners", list),
        ("human_checkpoints", dict),
    ]
    for key, expected_type in required_types:
        require_type(issues, manifest, key, expected_type)

    if manifest.get("schema_version") != 1:
        issues.append(f"unsupported_schema_version:{manifest.get('schema_version')}")
    if not manifest.get("asset"):
        issues.append("empty_asset")
    if not manifest.get("state"):
        issues.append("empty_state")
    if not manifest.get("candidate_id"):
        issues.append("empty_candidate_id")
    if not manifest.get("source_path"):
        issues.append("empty_source_path")
    if not manifest.get("output_dir"):
        issues.append("empty_output_dir")
    if isinstance(manifest.get("frames"), list) and manifest.get("frame_count") != len(manifest["frames"]):
        issues.append(f"frame_count_mismatch:declared_{manifest.get('frame_count')}:actual_{len(manifest['frames'])}")

    qa = manifest.get("qa", {})
    if isinstance(qa, dict):
        for key in ["verdict", "duplicate_frames", "warnings", "blocked_reasons"]:
            if key not in qa:
                issues.append(f"missing_key:qa.{key}")
        if qa.get("verdict") not in {"pending", "intake_ready", "pass", "warn", "blocked"}:
            issues.append(f"invalid_qa_verdict:{qa.get('verdict')}")
    policy = manifest.get("policy", {})
    if isinstance(policy, dict):
        for key in ["path", "verdict", "blocked_reasons", "warnings"]:
            if key not in policy:
                issues.append(f"missing_key:policy.{key}")
        if policy.get("verdict") not in {"pending", "gate_ready", "warn", "blocked"}:
            issues.append(f"invalid_policy_verdict:{policy.get('verdict')}")

    checkpoints = manifest.get("human_checkpoints", {})
    if isinstance(checkpoints, dict):
        for key in ["candidate_keep", "promotion_path", "runtime_copy_approval"]:
            if key not in checkpoints:
                warnings.append(f"missing_checkpoint:{key}")
            elif checkpoints[key] not in {"pending", "approved", "rejected", "locked"}:
                warnings.append(f"unknown_checkpoint_state:{key}:{checkpoints[key]}")
    return sorted(set(issues)), sorted(set(warnings))


def load_registry() -> dict[str, str]:
    if not REGISTRY_PATH.exists():
        return {}
    return json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))


def write_registry(registry: dict[str, str]) -> None:
    write_json(REGISTRY_PATH, registry)


def resolve_manifest(candidate: str, manifest_arg: str | None = None) -> Path:
    if manifest_arg:
        path = (REPO_ROOT / manifest_arg).resolve()
        if not path.exists():
            raise AssetOpsError(f"Manifest not found: {path}")
        return path
    registry = load_registry()
    if candidate not in registry:
        raise AssetOpsError(f"Candidate {candidate!r} is not registered. Run intake first.")
    path = (REPO_ROOT / registry[candidate]).resolve()
    if not path.exists():
        raise AssetOpsError(f"Registered manifest is missing: {path}")
    return path


def load_manifest(candidate: str, manifest_arg: str | None = None) -> tuple[Path, dict[str, Any]]:
    path = resolve_manifest(candidate, manifest_arg)
    return path, load_json(path)


def save_manifest(path: Path, manifest: dict[str, Any]) -> None:
    write_json(path, manifest)


def source_output_dir(source: Path) -> Path:
    return source.resolve().parent / "asset_ops_v01"


def png_files(source: Path) -> list[Path]:
    if not source.exists() or not source.is_dir():
        raise AssetOpsError(f"Source directory not found: {source}")
    files = sorted(p for p in source.iterdir() if p.is_file() and p.suffix.lower() == ".png")
    if not files:
        raise AssetOpsError(f"No PNG frames found in source directory: {source}")
    return files


def image_size(path: Path) -> tuple[int, int]:
    require_pillow()
    with Image.open(path) as img:
        return img.size


def file_hash(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def load_rules(asset: str, state: str) -> tuple[dict[str, Any], dict[str, Any]]:
    common = load_json(RULES_DIR / "common_sprite_motion.json")
    specific_name = f"{asset}_{state}.json"
    specific = load_json(RULES_DIR / specific_name)
    return common, specific


def add_artifact(manifest: dict[str, Any], kind: str, path: Path) -> None:
    artifacts = manifest.setdefault("artifacts", [])
    entry = {"kind": kind, "path": rel(path)}
    if entry not in artifacts:
        artifacts.append(entry)


def command_intake(args: argparse.Namespace) -> int:
    source = (REPO_ROOT / args.source).resolve()
    frames = png_files(source)
    common, specific = load_rules(args.asset, args.state)
    sizes = [image_size(path) for path in frames]
    first_size = sizes[0]
    blocked: list[str] = []
    warnings: list[str] = []

    if bool(common["rules"].get("require_identical_frame_size", True)) and any(size != first_size for size in sizes):
        blocked.append("frame_size_mismatch")
    expected_count = int(specific.get("expected_source_frame_count", 0))
    if expected_count and len(frames) != expected_count:
        blocked.append(f"expected_{expected_count}_frames_got_{len(frames)}")
    expected_size = tuple(specific.get("expected_source_frame_size", []))
    if expected_size and first_size != expected_size:
        blocked.append(f"expected_size_{expected_size[0]}x{expected_size[1]}_got_{first_size[0]}x{first_size[1]}")

    manifest = load_json(TEMPLATES_DIR / "manifest.json")
    out_dir = source_output_dir(source)
    manifest.update(
        {
            "asset": args.asset,
            "state": args.state,
            "candidate_id": args.candidate,
            "source_path": rel(source),
            "output_dir": rel(out_dir),
            "frame_count": len(frames),
            "frame_size": f"{first_size[0]}x{first_size[1]}",
            "frames": [{"index": i, "file": rel(path), "size": f"{sizes[i][0]}x{sizes[i][1]}"} for i, path in enumerate(frames)],
        }
    )
    manifest["lineage"] = specific.get("lineage", manifest.get("lineage", {}))
    manifest["qa"]["blocked_reasons"] = blocked
    manifest["qa"]["warnings"] = warnings
    manifest["qa"]["verdict"] = "blocked" if blocked else "intake_ready"

    manifest_path = out_dir / "asset_ops_manifest_v01.json"
    save_manifest(manifest_path, manifest)
    registry = load_registry()
    registry[args.candidate] = rel(manifest_path)
    write_registry(registry)
    print(rel(manifest_path))
    return 1 if blocked else 0


def bbox_for_image(img: Image.Image) -> tuple[int, int, int, int] | None:
    require_pillow()
    rgba = img.convert("RGBA")
    alpha = rgba.getchannel("A")
    bbox = alpha.getbbox()
    if bbox:
        return bbox
    return rgba.convert("RGB").getbbox()


def image_delta(a: Image.Image, b: Image.Image) -> int:
    require_pillow()
    diff = ImageChops.difference(a.convert("RGBA"), b.convert("RGBA"))
    hist = diff.convert("L").histogram()
    return int(sum(value * count for value, count in enumerate(hist)))


def command_qa(args: argparse.Namespace) -> int:
    manifest_path, manifest = load_manifest(args.candidate, args.manifest)
    frames = [(REPO_ROOT / frame["file"]).resolve() for frame in manifest["frames"]]
    images = [Image.open(path).convert("RGBA") for path in frames]
    hashes: dict[str, list[int]] = {}
    for i, path in enumerate(frames):
        hashes.setdefault(file_hash(path), []).append(i)
    duplicates = [group for group in hashes.values() if len(group) > 1]

    adjacent_deltas = [image_delta(images[i], images[i + 1]) for i in range(len(images) - 1)]
    loop_boundary_delta = image_delta(images[-1], images[0]) if len(images) > 1 else 0
    bboxes = [bbox_for_image(img) for img in images]
    centers: list[tuple[float, float]] = []
    sizes: list[tuple[int, int]] = []
    for bbox in bboxes:
        if bbox is None:
            centers.append((0.0, 0.0))
            sizes.append((0, 0))
            continue
        left, top, right, bottom = bbox
        centers.append(((left + right) / 2.0, (top + bottom) / 2.0))
        sizes.append((right - left, bottom - top))
    center_jumps = [
        math.dist(centers[i], centers[i + 1])
        for i in range(len(centers) - 1)
    ]
    size_jumps = [
        abs(sizes[i][0] - sizes[i + 1][0]) + abs(sizes[i][1] - sizes[i + 1][1])
        for i in range(len(sizes) - 1)
    ]

    warnings = list(manifest.get("qa", {}).get("warnings", []))
    blocked = list(manifest.get("qa", {}).get("blocked_reasons", []))
    if duplicates:
        warnings.append("duplicate_frames_detected")
    if center_jumps and max(center_jumps) > 4.0:
        warnings.append("bbox_center_jitter_over_4px")

    manifest["qa"].update(
        {
            "verdict": "blocked" if blocked else ("warn" if warnings else "pass"),
            "duplicate_frames": duplicates,
            "adjacent_deltas": adjacent_deltas,
            "max_adjacent_delta": max(adjacent_deltas) if adjacent_deltas else 0,
            "loop_boundary_delta": loop_boundary_delta,
            "bbox_jitter": {
                "max_center_jump": max(center_jumps) if center_jumps else 0.0,
                "max_size_jump": max(size_jumps) if size_jumps else 0,
                "bboxes": [list(bbox) if bbox else null_bbox() for bbox in bboxes],
            },
            "warnings": sorted(set(warnings)),
            "blocked_reasons": sorted(set(blocked)),
        }
    )
    save_manifest(manifest_path, manifest)
    for img in images:
        img.close()
    print(manifest["qa"]["verdict"])
    return 1 if manifest["qa"]["verdict"] == "blocked" else 0


def null_bbox() -> list[int]:
    return [0, 0, 0, 0]


def output_dir(manifest: dict[str, Any]) -> Path:
    return (REPO_ROOT / manifest["output_dir"]).resolve()


def load_frame_images(manifest: dict[str, Any]) -> list[Image.Image]:
    require_pillow()
    return [Image.open((REPO_ROOT / frame["file"]).resolve()).convert("RGBA") for frame in manifest["frames"]]


def command_review_pack(args: argparse.Namespace) -> int:
    manifest_path, manifest = load_manifest(args.candidate, args.manifest)
    out_dir = output_dir(manifest) / "review_pack_v01"
    out_dir.mkdir(parents=True, exist_ok=True)
    images = load_frame_images(manifest)
    if not images:
        raise AssetOpsError("Manifest has no frames.")
    frame_w, frame_h = images[0].size
    candidate = manifest["candidate_id"]

    cols = 4 if len(images) == 16 else min(8, len(images))
    rows = math.ceil(len(images) / cols)
    sheet = Image.new("RGBA", (cols * frame_w, rows * frame_h), (0, 0, 0, 0))
    for i, img in enumerate(images):
        sheet.paste(img, ((i % cols) * frame_w, (i // cols) * frame_h), img)
    sheet_path = out_dir / f"asset_ops_{candidate}_sheet_v01.png"
    sheet.save(sheet_path)

    strip = Image.new("RGBA", (len(images) * frame_w, frame_h), (0, 0, 0, 0))
    for i, img in enumerate(images):
        strip.paste(img, (i * frame_w, 0), img)
    strip_path = out_dir / f"asset_ops_{candidate}_strip_v01.png"
    strip.save(strip_path)

    gif_frames = [img.resize((frame_w * 4, frame_h * 4), Image.Resampling.NEAREST) for img in images]
    gif_path = out_dir / f"asset_ops_{candidate}_loop_4x_v01.gif"
    gif_frames[0].save(gif_path, save_all=True, append_images=gif_frames[1:], duration=100, loop=0, disposal=2)

    qa_board_path = out_dir / f"asset_ops_{candidate}_qa_board_v01.png"
    create_qa_board(manifest, sheet.convert("RGBA"), qa_board_path)

    add_artifact(manifest, "sheet", sheet_path)
    add_artifact(manifest, "strip", strip_path)
    add_artifact(manifest, "loop_gif", gif_path)
    add_artifact(manifest, "qa_board", qa_board_path)
    save_manifest(manifest_path, manifest)
    for img in images + gif_frames:
        img.close()
    print(rel(out_dir))
    return 0


def create_qa_board(manifest: dict[str, Any], sheet: Image.Image, out_path: Path) -> None:
    require_pillow()
    width, height = 1280, 860
    board = Image.new("RGB", (width, height), (34, 32, 28))
    draw = ImageDraw.Draw(board)
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 34)
        head_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 22)
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 18)
    except Exception:
        title_font = head_font = font = ImageFont.load_default()
    draw.text((32, 28), f"AssetOps QA Board: {manifest['candidate_id']}", fill=(240, 226, 185), font=title_font)
    draw.text((34, 78), f"{manifest['asset']} / {manifest['state']} / {manifest['frame_count']} frames / {manifest['frame_size']}", fill=(208, 198, 164), font=font)
    max_sheet_w, max_sheet_h = 720, 420
    sheet_copy = sheet.copy()
    sheet_copy.thumbnail((max_sheet_w, max_sheet_h), Image.Resampling.NEAREST)
    board.paste(sheet_copy.convert("RGB"), (32, 130))
    qa = manifest.get("qa", {})
    lines = [
        f"QA verdict: {qa.get('verdict', 'pending')}",
        f"Duplicate groups: {len(qa.get('duplicate_frames', []))}",
        f"Max adjacent delta: {qa.get('max_adjacent_delta', 'pending')}",
        f"Loop boundary delta: {qa.get('loop_boundary_delta', 'pending')}",
        f"Max bbox center jump: {qa.get('bbox_jitter', {}).get('max_center_jump', 'pending')}",
        f"Warnings: {', '.join(qa.get('warnings', [])) or 'none'}",
        f"Blocked: {', '.join(qa.get('blocked_reasons', [])) or 'none'}",
    ]
    x, y = 790, 140
    draw.text((x, y), "Metrics", fill=(240, 226, 185), font=head_font)
    y += 42
    for line in lines:
        draw.text((x, y), line, fill=(224, 215, 188), font=font)
        y += 30
    out_path.parent.mkdir(parents=True, exist_ok=True)
    board.save(out_path)


def command_gate(args: argparse.Namespace) -> int:
    manifest_path, manifest = load_manifest(args.candidate, args.manifest)
    _common, specific = load_rules(manifest["asset"], manifest["state"])
    blocked: list[str] = []
    warnings: list[str] = []

    if args.path != specific.get("preferred_promotion_path"):
        warnings.append(f"path_{args.path}_differs_from_preferred_{specific.get('preferred_promotion_path')}")
    if args.path == "path-a":
        if int(manifest.get("frame_count", 0)) != int(specific.get("expected_source_frame_count", 0)):
            blocked.append("path_a_requires_16_source_frames")
        if manifest.get("frame_size") != "96x96":
            blocked.append("path_a_requires_96x96_source_frames")
    source_path = manifest.get("source_path", "")
    if "/runtime/idle" in source_path or source_path.startswith("assets/characters/sprite_anchor_rian/runtime/idle"):
        blocked.append("direct_runtime_overwrite_source_blocked")
    if "godot_capture_review" in source_path:
        blocked.append("capture_png_as_sprite_frame_source_blocked")

    for evidence in specific.get("required_capture_evidence", []):
        if not (REPO_ROOT / evidence).exists():
            blocked.append(f"missing_capture_evidence:{evidence}")

    qa_verdict = manifest.get("qa", {}).get("verdict", "pending")
    if qa_verdict == "blocked":
        blocked.append("qa_blocked")
    if qa_verdict == "pending":
        warnings.append("qa_not_run")

    runner_results = run_required_godot_runners(args.path)
    manifest["godot_runners"] = runner_results
    for result in runner_results:
        if result["status"] != "pass":
            blocked.append(f"godot_runner_failed:{result['runner']}")

    manifest["policy"] = {
        "path": args.path,
        "verdict": "blocked" if blocked else ("warn" if warnings else "gate_ready"),
        "blocked_reasons": sorted(set(blocked)),
        "warnings": sorted(set(warnings)),
    }
    save_manifest(manifest_path, manifest)
    print(manifest["policy"]["verdict"])
    return 1 if manifest["policy"]["verdict"] == "blocked" else 0


def run_required_godot_runners(path: str) -> list[dict[str, Any]]:
    if path != "path-a":
        return []
    runners = [
        "scripts/dev/rian_idle_path_a_parallel_16f_prereq_runner.gd",
        "scripts/dev/rian_idle_path_a_fallback_behavior_runner.gd",
        "scripts/dev/rian_idle_runtime_promotion_contract_runner.gd",
    ]
    godot_bin = shutil.which("godot") or shutil.which("godot4")
    results: list[dict[str, Any]] = []
    if godot_bin is None:
        return [{"runner": runner, "status": "fail", "error": "godot_not_found"} for runner in runners]
    for runner in runners:
        command = [godot_bin, "--headless", "--path", str(REPO_ROOT), "--script", runner]
        completed = subprocess.run(command, cwd=REPO_ROOT, capture_output=True, text=True, check=False)
        results.append(
            {
                "runner": runner,
                "status": "pass" if completed.returncode == 0 else "fail",
                "returncode": completed.returncode,
                "stdout_tail": completed.stdout.strip().splitlines()[-3:],
                "stderr_tail": completed.stderr.strip().splitlines()[-5:],
            }
        )
    return results


def render_list(items: list[str]) -> str:
    if not items:
        return "- none"
    return "\n".join(f"- `{item}`" if "/" in item or item.endswith(".png") else f"- {item}" for item in items)


def artifact_lines(manifest: dict[str, Any]) -> list[str]:
    return [artifact["path"] for artifact in manifest.get("artifacts", [])]


def render_template(template_name: str, values: dict[str, str]) -> str:
    text = (TEMPLATES_DIR / template_name).read_text(encoding="utf-8")
    for key, value in values.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def command_doc(args: argparse.Namespace) -> int:
    manifest_path, manifest = load_manifest(args.candidate, args.manifest)
    status = manifest.get("policy", {}).get("verdict", manifest.get("qa", {}).get("verdict", "pending"))
    values = {
        "date": str(date.today()),
        "status": status,
        "asset": manifest["asset"],
        "state": manifest["state"],
        "candidate_id": manifest["candidate_id"],
        "source_path": manifest["source_path"],
        "qa_verdict": manifest.get("qa", {}).get("verdict", "pending"),
        "policy_verdict": manifest.get("policy", {}).get("verdict", "pending"),
        "what_worked": render_list(manifest.get("lineage", {}).get("carry_forward", [])),
        "what_to_avoid": render_list(manifest.get("lineage", {}).get("avoid", [])),
        "artifacts": render_list(artifact_lines(manifest)),
        "next_gate": "Run `promotion-plan` after human path approval." if status != "blocked" else "Resolve blocked reasons before promotion planning.",
    }
    repo_doc = render_template("repo_doc.md", values)
    repo_path = REPO_ROOT / "docs" / "generated" / f"asset_ops_{manifest['candidate_id']}_candidate_report_v01.md"
    repo_path.write_text(repo_doc, encoding="utf-8")
    obsidian_note = render_template("obsidian_note.md", values)
    note_path = output_dir(manifest) / f"asset_ops_{manifest['candidate_id']}_obsidian_note_v01.md"
    note_path.write_text(obsidian_note, encoding="utf-8")
    add_artifact(manifest, "repo_doc", repo_path)
    add_artifact(manifest, "obsidian_note_body", note_path)
    save_manifest(manifest_path, manifest)
    print(rel(repo_path))
    return 0


def command_promotion_plan(args: argparse.Namespace) -> int:
    manifest_path, manifest = load_manifest(args.candidate, args.manifest)
    policy_verdict = manifest.get("policy", {}).get("verdict", "pending")
    blocked = policy_verdict == "blocked"
    plan = {
        "schema_version": 1,
        "candidate_id": manifest["candidate_id"],
        "path": args.path,
        "status": "blocked" if blocked else "dry_run_ready",
        "runtime_copy_enabled": False,
        "blocked_reasons": manifest.get("policy", {}).get("blocked_reasons", []),
        "target_runtime_folders": [
            "assets/characters/sprite_anchor_rian/runtime/idle_16f_review/"
        ] if args.path == "path-a" else [],
        "code_owners": [
            "scripts/battle/unit_actor.gd",
            "scripts/battle/battle_art_catalog.gd"
        ],
        "required_runners": [
            "scripts/dev/rian_idle_path_a_fallback_behavior_runner.gd",
            "scripts/dev/rian_idle_runtime_promotion_contract_runner.gd",
            "scripts/dev/character_animation_ready_runner.gd",
            "scripts/dev/ally_battle_sprite_runner.gd"
        ],
        "approval_required": "runtime_copy_approval"
    }
    plan_path = output_dir(manifest) / "promotion_plan_v01.json"
    write_json(plan_path, plan)
    md_path = output_dir(manifest) / "promotion_plan_v01.md"
    md_path.write_text(render_promotion_plan_md(plan), encoding="utf-8")
    add_artifact(manifest, "promotion_plan_json", plan_path)
    add_artifact(manifest, "promotion_plan_md", md_path)
    save_manifest(manifest_path, manifest)
    print(rel(md_path))
    return 1 if blocked else 0


def command_schema(args: argparse.Namespace) -> int:
    _manifest_path, manifest = load_manifest(args.candidate, args.manifest)
    issues, warnings = validate_manifest_schema(manifest)
    result = {
        "candidate_id": manifest.get("candidate_id", args.candidate),
        "status": "blocked" if issues else ("warn" if warnings else "pass"),
        "issues": issues,
        "warnings": warnings,
    }
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 1 if issues else 0


def missing_frame_paths(manifest: dict[str, Any]) -> list[str]:
    missing: list[str] = []
    for frame in manifest.get("frames", []):
        path = REPO_ROOT / frame.get("file", "")
        if not path.exists():
            missing.append(frame.get("file", ""))
    return missing


def missing_artifact_paths(manifest: dict[str, Any]) -> list[str]:
    missing: list[str] = []
    for artifact in manifest.get("artifacts", []):
        path = REPO_ROOT / artifact.get("path", "")
        if not path.exists():
            missing.append(artifact.get("path", ""))
    return missing


def command_verify(args: argparse.Namespace) -> int:
    manifest_path, manifest = load_manifest(args.candidate, args.manifest)
    issues, warnings = validate_manifest_schema(manifest)
    frame_misses = missing_frame_paths(manifest)
    artifact_misses = missing_artifact_paths(manifest)
    if frame_misses:
        issues.extend(f"missing_frame:{path}" for path in frame_misses)
    if artifact_misses:
        issues.extend(f"missing_artifact:{path}" for path in artifact_misses)

    qa_verdict = manifest.get("qa", {}).get("verdict", "pending")
    policy_verdict = manifest.get("policy", {}).get("verdict", "pending")
    if qa_verdict in {"pending", "intake_ready"}:
        warnings.append(f"qa_not_final:{qa_verdict}")
    if qa_verdict == "blocked":
        issues.append("qa_blocked")
    if policy_verdict == "pending":
        warnings.append("gate_not_run")
    if policy_verdict == "blocked":
        issues.append("policy_blocked")

    runner_results = manifest.get("godot_runners", [])
    if policy_verdict == "gate_ready" and not runner_results:
        warnings.append("gate_ready_without_recorded_godot_runners")
    for result in runner_results:
        if result.get("status") != "pass":
            issues.append(f"godot_runner_failed:{result.get('runner', 'unknown')}")

    status = "blocked" if issues else ("warn" if warnings else "pass")
    verification = {
        "status": status,
        "issues": sorted(set(issues)),
        "warnings": sorted(set(warnings)),
        "checked_at": str(date.today()),
    }
    manifest["verification"] = verification
    save_manifest(manifest_path, manifest)
    print(json.dumps(verification, indent=2, ensure_ascii=False))
    return 1 if issues else 0


def candidate_summary(manifest: dict[str, Any]) -> dict[str, Any]:
    qa = manifest.get("qa", {})
    policy = manifest.get("policy", {})
    return {
        "candidate_id": manifest.get("candidate_id"),
        "frame_count": manifest.get("frame_count"),
        "frame_size": manifest.get("frame_size"),
        "qa_verdict": qa.get("verdict"),
        "policy_verdict": policy.get("verdict"),
        "warning_count": len(qa.get("warnings", [])) + len(policy.get("warnings", [])),
        "blocked_count": len(qa.get("blocked_reasons", [])) + len(policy.get("blocked_reasons", [])),
        "duplicate_groups": len(qa.get("duplicate_frames", [])),
        "max_adjacent_delta": qa.get("max_adjacent_delta"),
        "loop_boundary_delta": qa.get("loop_boundary_delta"),
        "max_center_jump": qa.get("bbox_jitter", {}).get("max_center_jump"),
        "max_size_jump": qa.get("bbox_jitter", {}).get("max_size_jump"),
        "godot_pass_count": sum(1 for result in manifest.get("godot_runners", []) if result.get("status") == "pass"),
        "godot_fail_count": sum(1 for result in manifest.get("godot_runners", []) if result.get("status") != "pass"),
    }


def numeric_delta(a: Any, b: Any) -> Any:
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return b - a
    return None


def command_compare(args: argparse.Namespace) -> int:
    _path_a, manifest_a = load_manifest(args.candidate_a, args.manifest_a)
    _path_b, manifest_b = load_manifest(args.candidate_b, args.manifest_b)
    summary_a = candidate_summary(manifest_a)
    summary_b = candidate_summary(manifest_b)
    metrics = [
        "frame_count",
        "frame_size",
        "qa_verdict",
        "policy_verdict",
        "warning_count",
        "blocked_count",
        "duplicate_groups",
        "max_adjacent_delta",
        "loop_boundary_delta",
        "max_center_jump",
        "max_size_jump",
        "godot_pass_count",
        "godot_fail_count",
    ]
    comparison = {
        "schema_version": 1,
        "candidate_a": summary_a,
        "candidate_b": summary_b,
        "deltas": {metric: numeric_delta(summary_a.get(metric), summary_b.get(metric)) for metric in metrics},
        "recommendation": compare_recommendation(summary_a, summary_b),
    }
    out_dir = output_dir(manifest_b)
    json_path = out_dir / f"asset_ops_compare_{summary_a['candidate_id']}_vs_{summary_b['candidate_id']}_v01.json"
    md_path = out_dir / f"asset_ops_compare_{summary_a['candidate_id']}_vs_{summary_b['candidate_id']}_v01.md"
    write_json(json_path, comparison)
    md_path.write_text(render_compare_md(comparison), encoding="utf-8")
    add_artifact(manifest_b, "candidate_compare_json", json_path)
    add_artifact(manifest_b, "candidate_compare_md", md_path)
    manifest_b_path = resolve_manifest(args.candidate_b, args.manifest_b)
    save_manifest(manifest_b_path, manifest_b)
    print(rel(md_path))
    return 0


def compare_recommendation(a: dict[str, Any], b: dict[str, Any]) -> str:
    if b["blocked_count"] > 0 or b["godot_fail_count"] > 0:
        return "keep_candidate_a_until_b_blockers_are_resolved"
    if a["blocked_count"] > 0 and b["blocked_count"] == 0:
        return "prefer_candidate_b"
    if b["policy_verdict"] == "gate_ready" and a["policy_verdict"] != "gate_ready":
        return "prefer_candidate_b"
    if b["warning_count"] > a["warning_count"]:
        return "keep_candidate_a_unless_visual_review_overrides"
    if b.get("max_center_jump") and a.get("max_center_jump") and b["max_center_jump"] > a["max_center_jump"]:
        return "keep_candidate_a_unless_motion_quality_is_visually_better"
    return "candidate_b_is_safe_to_review_against_candidate_a"


def render_compare_md(comparison: dict[str, Any]) -> str:
    a = comparison["candidate_a"]
    b = comparison["candidate_b"]
    lines = [
        "# AssetOps Candidate Compare",
        "",
        f"Candidate A: `{a['candidate_id']}`",
        f"Candidate B: `{b['candidate_id']}`",
        "",
        f"Recommendation: `{comparison['recommendation']}`",
        "",
        "## Metrics",
        "",
        "| metric | candidate A | candidate B | delta B-A |",
        "| --- | --- | --- | --- |",
    ]
    for metric, delta in comparison["deltas"].items():
        lines.append(f"| `{metric}` | `{a.get(metric)}` | `{b.get(metric)}` | `{delta}` |")
    lines.extend(
        [
            "",
            "## Use",
            "",
            "Use this comparison as a structural screen only. Final keep/discard still requires visual review of the generated review packs.",
            "",
        ]
    )
    return "\n".join(lines)


def render_promotion_plan_md(plan: dict[str, Any]) -> str:
    return "\n".join(
        [
            "# AssetOps Promotion Plan v01",
            "",
            f"Status: `{plan['status']}`",
            "",
            f"Candidate: `{plan['candidate_id']}`",
            f"Path: `{plan['path']}`",
            f"Runtime copy enabled: `{plan['runtime_copy_enabled']}`",
            "",
            "## Target Runtime Folders",
            "",
            render_list(plan["target_runtime_folders"]),
            "",
            "## Code Owners",
            "",
            render_list(plan["code_owners"]),
            "",
            "## Required Runners",
            "",
            render_list(plan["required_runners"]),
            "",
            "## Blocked Reasons",
            "",
            render_list(plan["blocked_reasons"]),
            "",
            "## Approval",
            "",
            f"Required checkpoint: `{plan['approval_required']}`",
            "",
        ]
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="AssetOps v1 sprite candidate pipeline")
    sub = parser.add_subparsers(dest="command", required=True)

    intake = sub.add_parser("intake")
    intake.add_argument("--asset", required=True)
    intake.add_argument("--state", required=True)
    intake.add_argument("--candidate", required=True)
    intake.add_argument("--source", required=True)
    intake.set_defaults(func=command_intake)

    for name, func in [
        ("qa", command_qa),
        ("review-pack", command_review_pack),
        ("doc", command_doc),
        ("schema", command_schema),
        ("verify", command_verify),
    ]:
        cmd = sub.add_parser(name)
        cmd.add_argument("--candidate", required=True)
        cmd.add_argument("--manifest")
        cmd.set_defaults(func=func)

    gate = sub.add_parser("gate")
    gate.add_argument("--candidate", required=True)
    gate.add_argument("--path", required=True)
    gate.add_argument("--manifest")
    gate.set_defaults(func=command_gate)

    promotion = sub.add_parser("promotion-plan")
    promotion.add_argument("--candidate", required=True)
    promotion.add_argument("--path", required=True)
    promotion.add_argument("--manifest")
    promotion.set_defaults(func=command_promotion_plan)

    compare = sub.add_parser("compare")
    compare.add_argument("--candidate-a", required=True)
    compare.add_argument("--candidate-b", required=True)
    compare.add_argument("--manifest-a")
    compare.add_argument("--manifest-b")
    compare.set_defaults(func=command_compare)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return int(args.func(args))
    except AssetOpsError as exc:
        print(f"[asset_ops] {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
