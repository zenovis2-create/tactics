#!/usr/bin/env python3
"""Credential-safe signing readiness checklist for Android and macOS releases.

This helper inspects export preset metadata, non-secret environment/tool presence,
and documented operator follow-up only. It intentionally never reads keystore
contents, never prints credential values, never queries/mutates the keychain, never
creates keys/profiles, never exports artifacts, and never invokes signing commands.
"""
from __future__ import annotations

import argparse
import configparser
import json
import os
import platform
import re
import shutil
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

ANDROID_SECRETISH_FIELDS = (
    "keystore/debug",
    "keystore/debug_user",
    "keystore/debug_password",
    "keystore/release",
    "keystore/release_user",
    "keystore/release_password",
)
MACOS_CREDENTIAL_FIELDS = (
    "codesign/identity",
    "codesign/installer_identity",
    "codesign/apple_team_id",
    "notarization/apple_id_name",
    "notarization/apple_id_password",
    "notarization/api_uuid",
    "notarization/api_key",
    "notarization/api_key_id",
)
ANDROID_ENV_HINTS = ("ANDROID_HOME", "ANDROID_SDK_ROOT", "JAVA_HOME")
MACOS_ENV_HINTS = ("DEVELOPER_DIR",)


@dataclass
class Check:
    status: str
    area: str
    item: str
    detail: str
    next_step: str = ""


def add(checks: list[Check], status: str, area: str, item: str, detail: str, next_step: str = "") -> None:
    checks.append(Check(status=status, area=area, item=item, detail=detail, next_step=next_step))


def unquote(value: str | None) -> str:
    if value is None:
        return ""
    value = value.strip()
    if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
        return value[1:-1]
    return value


def is_true(value: str | None) -> bool:
    return unquote(value).lower() == "true"


def parse_presets(path: Path) -> dict[str, dict[str, str]]:
    parser = configparser.ConfigParser(strict=False, interpolation=None)
    parser.optionxform = str
    parser.read_string(path.read_text(errors="replace"))
    presets: dict[str, dict[str, str]] = {}
    for section in parser.sections():
        if not re.fullmatch(r"preset\.\d+", section):
            continue
        name = unquote(parser.get(section, "name", fallback=""))
        if not name:
            continue
        data = dict(parser.items(section))
        option_section = f"{section}.options"
        if parser.has_section(option_section):
            data.update(dict(parser.items(option_section)))
        presets[name] = data
    return presets


def command_status(name: str) -> tuple[bool, str]:
    path = shutil.which(name)
    if path:
        return True, f"`{name}` is available on PATH"
    return False, f"`{name}` was not found on PATH"


def env_presence(env_names: tuple[str, ...], area: str, checks: list[Check]) -> None:
    for name in env_names:
        if os.environ.get(name):
            add(checks, "PASS", area, f"env:{name}", "environment variable is set; value intentionally not printed")
        else:
            add(checks, "INFO", area, f"env:{name}", "environment variable is unset", "Set only if your local signing/export flow requires it.")


def find_apksigner() -> bool:
    if shutil.which("apksigner"):
        return True
    for env_name in ("ANDROID_HOME", "ANDROID_SDK_ROOT"):
        root = os.environ.get(env_name)
        if not root:
            continue
        build_tools = Path(root) / "build-tools"
        if not build_tools.exists():
            continue
        for candidate in build_tools.glob("*/apksigner"):
            if candidate.exists():
                return True
    return False


def check_android(presets: dict[str, dict[str, str]], checks: list[Check]) -> None:
    area = "Android signing"
    data = presets.get("Android")
    if not data:
        add(checks, "BLOCKER", area, "export preset", "Android export preset is missing", "Create/restore the Android preset before signing readiness review.")
        return

    if is_true(data.get("package/signed")):
        add(checks, "PASS", area, "package/signed", "Android preset requests signed package output")
    else:
        add(checks, "BLOCKER", area, "package/signed", "Android preset has package/signed disabled or unset", "Enable release signing in Godot after release keystore custody is approved.")

    for field in ANDROID_SECRETISH_FIELDS:
        value_present = bool(unquote(data.get(field)))
        if value_present:
            add(checks, "WARN", area, field, "field is non-empty in export_presets.cfg; value intentionally not printed", "Confirm this is intentional and no secret value is committed.")
        else:
            add(checks, "INFO", area, field, "field is empty or absent", "Provide via secure local/operator process when performing the real signed export.")

    env_presence(ANDROID_ENV_HINTS, area, checks)
    for command in ("java", "keytool", "jarsigner"):
        ok, detail = command_status(command)
        add(checks, "PASS" if ok else "WARN", area, f"tool:{command}", detail, "Install/configure a JDK for Android release signing." if not ok else "")
    if find_apksigner():
        add(checks, "PASS", area, "tool:apksigner", "Android SDK apksigner was found by PATH or SDK build-tools discovery")
    else:
        add(checks, "WARN", area, "tool:apksigner", "Android SDK apksigner was not found", "Install Android SDK build-tools and set ANDROID_HOME/ANDROID_SDK_ROOT or PATH.")

    add(checks, "INFO", area, "operator checklist", "Do not create, inspect, or export keystores with this helper", "Operator must verify keystore custody, alias, passwords, backup, Play/App Store enrollment, and signed artifact verification outside this script.")


def check_macos(presets: dict[str, dict[str, str]], checks: list[Check]) -> None:
    area = "macOS signing/notarization"
    data = presets.get("macOS")
    if not data:
        add(checks, "BLOCKER", area, "export preset", "macOS export preset is missing", "Create/restore the macOS preset before signing readiness review.")
        return

    if platform.system() == "Darwin":
        add(checks, "PASS", area, "host OS", "running on macOS/Darwin")
    else:
        add(checks, "WARN", area, "host OS", f"running on {platform.system()}; macOS signing/notarization usually requires macOS", "Run final codesign/notarization readiness on the macOS signing host.")

    if is_true(data.get("codesign/codesign")):
        add(checks, "PASS", area, "codesign/codesign", "macOS preset requests codesigning")
    else:
        add(checks, "BLOCKER", area, "codesign/codesign", "macOS preset has codesigning disabled or unset", "Enable codesigning only when certificate custody and hardened runtime settings are approved.")
    if is_true(data.get("notarization/notarization")):
        add(checks, "PASS", area, "notarization/notarization", "macOS preset requests notarization")
    else:
        add(checks, "BLOCKER", area, "notarization/notarization", "macOS preset has notarization disabled or unset", "Enable notarization only when Apple developer credentials/API key custody is approved.")

    for field in MACOS_CREDENTIAL_FIELDS:
        value_present = bool(unquote(data.get(field)))
        if value_present:
            add(checks, "WARN", area, field, "credential-coupled field is non-empty in export_presets.cfg; value intentionally not printed", "Confirm this is intentional and not a committed secret.")
        else:
            add(checks, "INFO", area, field, "field is empty or absent", "Provide via secure local/operator process when performing the real signed export.")

    env_presence(MACOS_ENV_HINTS, area, checks)
    for command in ("xcrun", "codesign", "notarytool", "stapler"):
        ok, detail = command_status(command)
        add(checks, "PASS" if ok else "WARN", area, f"tool:{command}", detail, "Install/select Xcode command line tools on the signing host." if not ok else "")

    add(checks, "INFO", area, "keychain policy", "This helper does not run `security find-identity`, read keychains, unlock keychains, or mutate signing state", "Operator must verify Developer ID certificate, Team ID, hardened runtime, notarization credentials, staple validation, and Gatekeeper assessment outside this script.")


def build_report(root: Path, export_presets: Path) -> dict[str, Any]:
    checks: list[Check] = []
    if not export_presets.exists():
        add(checks, "BLOCKER", "presets", "export_presets.cfg", f"missing export presets file: {export_presets}", "Restore export_presets.cfg before signing readiness review.")
        presets: dict[str, dict[str, str]] = {}
    else:
        presets = parse_presets(export_presets)
        check_android(presets, checks)
        check_macos(presets, checks)
    counts = {status: sum(1 for check in checks if check.status == status) for status in ("BLOCKER", "WARN", "INFO", "PASS")}
    return {
        "kind": "signing_readiness_report",
        "root": str(root),
        "export_presets": str(export_presets),
        "credential_safety": {
            "prints_secret_values": False,
            "reads_keystore_contents": False,
            "queries_or_mutates_keychain": False,
            "creates_or_exports_credentials": False,
            "performs_signing_or_notarization": False,
        },
        "signing_ready": counts["BLOCKER"] == 0,
        "counts": counts,
        "checks": [asdict(check) for check in checks],
        "notes": [
            "Readiness is metadata/tooling guidance only; it does not prove credentials are valid.",
            "Final public readiness still requires a real signed Android export and a signed/notarized macOS artifact verified by the release operator.",
        ],
    }


def print_text(report: dict[str, Any]) -> None:
    print("[INFO] signing readiness report")
    print(f"[INFO] root: {report['root']}")
    print(f"[INFO] export_presets: {report['export_presets']}")
    print("[INFO] credential-safe: no secret values, keystore reads, keychain queries/mutations, credential creation, exports, or signing commands")
    for check in report["checks"]:
        print(f"[{check['status']}][{check['area']}][{check['item']}] {check['detail']}")
        if check.get("next_step"):
            print(f"  next: {check['next_step']}")
    counts = report.get("counts", {})
    print("[INFO] counts: " + ", ".join(f"{key}={counts.get(key, 0)}" for key in ("BLOCKER", "WARN", "INFO", "PASS")))
    if report.get("signing_ready"):
        print("[PASS] no signing-readiness blockers detected by metadata/tool checks.")
    else:
        print("[WARN] signing readiness remains blocked; see checklist above.")


def main() -> int:
    parser = argparse.ArgumentParser(description="Credential-safe Android/macOS signing readiness checklist")
    parser.add_argument("--root", type=Path, default=Path(os.environ.get("ROOT", "/Volumes/AI/tactics")))
    parser.add_argument("--export-presets", type=Path, default=None)
    parser.add_argument("--json", action="store_true", help="emit JSON instead of text")
    parser.add_argument("--strict", action="store_true", help="exit non-zero when signing-readiness blockers are present")
    args = parser.parse_args()

    root = args.root.resolve()
    export_presets = (args.export_presets or (root / "export_presets.cfg")).resolve()
    report = build_report(root, export_presets)
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print_text(report)
    if args.strict and not report.get("signing_ready", False):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
