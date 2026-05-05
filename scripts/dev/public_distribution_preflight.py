#!/usr/bin/env python3
"""Credential-safe public distribution preflight for Godot export presets.

This helper inspects committed release metadata and local tool/template readiness only.
It never reads or prints signing secret values, never writes credentials, and does not
perform exports. Use --strict to make current public-distribution blockers fail.
"""
from __future__ import annotations

import argparse
import configparser
import json
import os
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any

REQUIRED_PRESETS = ("Linux/X11", "macOS", "Android")
SECRET_FIELD_PATTERNS = (
    re.compile(r"password", re.IGNORECASE),
    re.compile(r"keystore", re.IGNORECASE),
    re.compile(r"identity", re.IGNORECASE),
    re.compile(r"apple_id", re.IGNORECASE),
    re.compile(r"team_id", re.IGNORECASE),
)
NON_SECRET_ENV_HINTS = {
    "Android": (
        "ANDROID_HOME",
        "ANDROID_SDK_ROOT",
        "JAVA_HOME",
    ),
    "macOS": (
        "DEVELOPER_DIR",
    ),
}


@dataclass
class Finding:
    severity: str
    area: str
    message: str


def add(findings: list[Finding], severity: str, area: str, message: str) -> None:
    findings.append(Finding(severity=severity, area=area, message=message))


def parse_presets(path: Path) -> dict[str, dict[str, str]]:
    parser = configparser.ConfigParser(strict=False, interpolation=None)
    parser.optionxform = str
    text = path.read_text(errors="replace")
    parser.read_string(text)
    presets: dict[str, dict[str, str]] = {}
    for section in parser.sections():
        if not re.fullmatch(r"preset\.\d+", section):
            continue
        raw_name = parser.get(section, "name", fallback="").strip()
        name = raw_name.strip('"')
        if not name:
            continue
        data = dict(parser.items(section))
        option_section = f"{section}.options"
        if parser.has_section(option_section):
            data.update(dict(parser.items(option_section)))
        presets[name] = data
    return presets


def unquote(value: str | None) -> str:
    if value is None:
        return ""
    value = value.strip()
    if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
        return value[1:-1]
    return value


def is_false(value: str | None) -> bool:
    return unquote(value).lower() == "false"


def is_true(value: str | None) -> bool:
    return unquote(value).lower() == "true"


def res_path_exists(root: Path, value: str) -> bool:
    if not value.startswith("res://"):
        return False
    return (root / value.replace("res://", "", 1)).exists()


def is_relative_build_path(value: str) -> bool:
    if not value:
        return False
    p = Path(value)
    return not p.is_absolute() and (p.parts[:1] == ("build",) or p.parts[:1] == ("dist",))


def check_secret_storage(presets: dict[str, dict[str, str]], findings: list[Finding]) -> None:
    for preset_name, data in presets.items():
        for key, raw_value in sorted(data.items()):
            value = unquote(raw_value)
            if not value:
                continue
            if any(pattern.search(key) for pattern in SECRET_FIELD_PATTERNS):
                # Identity/team-id fields are not always secrets, but they are still
                # credential-coupled. Report their presence without printing values.
                add(
                    findings,
                    "WARN",
                    preset_name,
                    f"credential-coupled field `{key}` is non-empty in export_presets.cfg; verify this is intentional and not a secret value",
                )


def check_common(root: Path, presets: dict[str, dict[str, str]], findings: list[Finding]) -> None:
    for name in REQUIRED_PRESETS:
        if name not in presets:
            add(findings, "BLOCKER", "presets", f"missing required preset `{name}`")
    for name, data in sorted(presets.items()):
        export_path = unquote(data.get("export_path"))
        if not export_path:
            add(findings, "BLOCKER", name, "export_path is empty")
        elif not is_relative_build_path(export_path):
            add(findings, "WARN", name, f"export_path `{export_path}` is not a relative build/ or dist/ path")
        platform = unquote(data.get("platform"))
        if not platform:
            add(findings, "WARN", name, "platform field is empty")
    template_dir = root.home() / "Library/Application Support/Godot/export_templates/4.6.2.stable"
    if template_dir.exists():
        add(findings, "PASS", "templates", f"Godot 4.6.2.stable export templates found at {template_dir}")
    else:
        add(findings, "WARN", "templates", f"Godot 4.6.2.stable export templates not found at {template_dir}")


def check_android(root: Path, data: dict[str, str], findings: list[Finding]) -> None:
    area = "Android"
    package_id = unquote(data.get("package/unique_name"))
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+", package_id or ""):
        add(findings, "BLOCKER", area, f"package/unique_name `{package_id}` is not a valid reverse-DNS package id")
    if not unquote(data.get("package/name")):
        add(findings, "BLOCKER", area, "package/name is empty")
    if not unquote(data.get("version/name")):
        add(findings, "BLOCKER", area, "version/name is empty")
    try:
        if int(unquote(data.get("version/code")) or "0") < 1:
            add(findings, "BLOCKER", area, "version/code must be >= 1")
    except ValueError:
        add(findings, "BLOCKER", area, f"version/code is not an integer: {unquote(data.get('version/code'))}")
    if is_false(data.get("package/signed")):
        add(findings, "BLOCKER", area, "package/signed=false; unsigned APK/AAB is internal-QA only")
    if is_false(data.get("screen/support_small")):
        add(findings, "WARN", area, "screen/support_small=false; document device exclusion or validate small-screen support before public release")
    icon_fields = (
        "launcher_icons/main_192x192",
        "launcher_icons/adaptive_foreground_432x432",
        "launcher_icons/adaptive_background_432x432",
    )
    for field in icon_fields:
        value = unquote(data.get(field))
        if not value:
            add(findings, "BLOCKER", area, f"{field} is empty")
        elif not value.startswith("res://"):
            add(findings, "BLOCKER", area, f"{field} must use res:// path, got `{value}`")
        elif not res_path_exists(root, value):
            add(findings, "BLOCKER", area, f"{field} points to missing file: {value}")
    for env_name in NON_SECRET_ENV_HINTS[area]:
        if os.environ.get(env_name):
            add(findings, "PASS", area, f"non-secret environment hint `{env_name}` is set")
        else:
            add(findings, "INFO", area, f"non-secret environment hint `{env_name}` is unset")


def check_macos(data: dict[str, str], findings: list[Finding]) -> None:
    area = "macOS"
    bundle_id = unquote(data.get("application/bundle_identifier"))
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9-]*(\.[A-Za-z][A-Za-z0-9-]*)+", bundle_id or ""):
        add(findings, "BLOCKER", area, f"application/bundle_identifier `{bundle_id}` is not a valid reverse-DNS bundle id")
    if not unquote(data.get("application/short_version")):
        add(findings, "BLOCKER", area, "application/short_version is empty")
    if not unquote(data.get("application/version")):
        add(findings, "BLOCKER", area, "application/version is empty")
    if is_false(data.get("codesign/codesign")):
        add(findings, "BLOCKER", area, "codesign/codesign=false; public macOS builds require signing")
    if is_false(data.get("notarization/notarization")):
        add(findings, "BLOCKER", area, "notarization/notarization=false; public macOS builds require notarization")
    for env_name in NON_SECRET_ENV_HINTS[area]:
        if os.environ.get(env_name):
            add(findings, "PASS", area, f"non-secret environment hint `{env_name}` is set")
        else:
            add(findings, "INFO", area, f"non-secret environment hint `{env_name}` is unset")


def check_linux(data: dict[str, str], findings: list[Finding]) -> None:
    area = "Linux/X11"
    if not unquote(data.get("binary_format/architecture")):
        add(findings, "WARN", area, "binary_format/architecture is empty")
    if not is_true(data.get("texture_format/s3tc_bptc")):
        add(findings, "WARN", area, "texture_format/s3tc_bptc is not enabled")


def build_report(root: Path, export_presets: Path) -> dict[str, Any]:
    findings: list[Finding] = []
    if not export_presets.exists():
        add(findings, "BLOCKER", "presets", f"missing export presets file: {export_presets}")
        return {"kind": "public_distribution_preflight", "root": str(root), "export_presets": str(export_presets), "findings": [asdict(f) for f in findings]}
    presets = parse_presets(export_presets)
    check_common(root, presets, findings)
    check_secret_storage(presets, findings)
    if "Android" in presets:
        check_android(root, presets["Android"], findings)
    if "macOS" in presets:
        check_macos(presets["macOS"], findings)
    if "Linux/X11" in presets:
        check_linux(presets["Linux/X11"], findings)
    counts = {severity: sum(1 for f in findings if f.severity == severity) for severity in ("BLOCKER", "WARN", "INFO", "PASS")}
    return {
        "kind": "public_distribution_preflight",
        "root": str(root),
        "export_presets": str(export_presets),
        "strict_public_ready": counts["BLOCKER"] == 0,
        "counts": counts,
        "findings": [asdict(f) for f in findings],
        "notes": [
            "Credential-safe: this helper reports only field/env presence and never prints secret values.",
            "Strict blockers are advisory unless --strict is supplied; --strict does not weaken platform_release_smoke.sh PUBLIC_DISTRIBUTION_CHECK=1.",
        ],
    }


def print_text(report: dict[str, Any]) -> None:
    print("[INFO] public distribution preflight")
    print(f"[INFO] root: {report['root']}")
    print(f"[INFO] export_presets: {report['export_presets']}")
    for finding in report["findings"]:
        print(f"[{finding['severity']}][{finding['area']}] {finding['message']}")
    counts = report.get("counts", {})
    print(
        "[INFO] counts: "
        + ", ".join(f"{key}={counts.get(key, 0)}" for key in ("BLOCKER", "WARN", "INFO", "PASS"))
    )
    if report.get("strict_public_ready"):
        print("[PASS] no public-distribution blockers detected by preflight.")
    else:
        print("[WARN] public distribution remains blocked; internal QA evidence may still be valid.")


def main() -> int:
    parser = argparse.ArgumentParser(description="Credential-safe Godot public distribution preflight")
    parser.add_argument("--root", type=Path, default=Path(os.environ.get("ROOT", "/Volumes/AI/tactics")))
    parser.add_argument("--export-presets", type=Path, default=None)
    parser.add_argument("--json", action="store_true", help="emit JSON instead of text")
    parser.add_argument("--strict", action="store_true", help="exit non-zero when public-distribution blockers are present")
    args = parser.parse_args()

    root = args.root.resolve()
    export_presets = (args.export_presets or (root / "export_presets.cfg")).resolve()
    report = build_report(root, export_presets)
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print_text(report)
    if args.strict and not report.get("strict_public_ready", False):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
