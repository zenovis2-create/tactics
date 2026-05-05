#!/usr/bin/env python3
"""Public API visual tooling adapters for local QA/release documentation.

This script intentionally avoids mutating project runtime files. It generates
Markdown snippets and URL-safe links for external, no-auth visual APIs:
QuickChart, Kroki, Shields, and xColors-style palette assistance.

Network calls are opt-in. Default output is deterministic and safe for docs.
"""
from __future__ import annotations

import argparse
import base64
import json
import sys
import urllib.parse
import urllib.request
import zlib
from dataclasses import dataclass
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
DOCS_DIR = ROOT / "docs" / "api_tooling"

QUICKCHART_BASE = "https://quickchart.io/chart"
KROKI_BASE = "https://kroki.io"
SHIELDS_BASE = "https://img.shields.io/badge"
XCOLORS_PUBLIC_APIS_URL = "https://x-colors.herokuapp.com/"


@dataclass(frozen=True)
class Badge:
    label: str
    message: str
    color: str


def quote_path_part(value: str) -> str:
    return urllib.parse.quote(value.replace("-", "--"), safe="")


def shields_url(label: str, message: str, color: str = "blue", style: str = "flat") -> str:
    path = f"{quote_path_part(label)}-{quote_path_part(message)}-{quote_path_part(color)}.svg"
    return f"{SHIELDS_BASE}/{path}?style={urllib.parse.quote(style)}"


def quickchart_url(labels: list[str], values: list[int], title: str) -> str:
    config = {
        "type": "bar",
        "data": {
            "labels": labels,
            "datasets": [
                {
                    "label": title,
                    "data": values,
                    "backgroundColor": ["#2f6fed", "#24a148", "#f1c21b", "#da1e28", "#8a3ffc"],
                }
            ],
        },
        "options": {
            "title": {"display": True, "text": title},
            "legend": {"display": False},
            "scales": {"yAxes": [{"ticks": {"beginAtZero": True, "precision": 0}}]},
        },
    }
    query = urllib.parse.urlencode({"c": json.dumps(config, ensure_ascii=False, separators=(",", ":"))})
    return f"{QUICKCHART_BASE}?{query}"


def kroki_encoded_url(diagram_type: str, diagram_text: str, output_format: str = "svg") -> str:
    compressed = zlib.compress(diagram_text.encode("utf-8"), 9)
    payload = base64.urlsafe_b64encode(compressed).decode("ascii").rstrip("=")
    return f"{KROKI_BASE}/{diagram_type}/{output_format}/{payload}"


def local_palette(seed: str = "risk") -> list[dict[str, str]]:
    palettes = {
        "risk": [
            {"name": "safe", "hex": "#24a148", "usage": "low risk / pass"},
            {"name": "watch", "hex": "#f1c21b", "usage": "warning / review"},
            {"name": "danger", "hex": "#da1e28", "usage": "high risk / blocked"},
            {"name": "counter", "hex": "#ff832b", "usage": "counter forecast"},
            {"name": "focus", "hex": "#2f6fed", "usage": "selected unit / focus"},
        ],
        "faction": [
            {"name": "ash", "hex": "#6f6f6f", "usage": "neutral/ash faction"},
            {"name": "ember", "hex": "#d95d39", "usage": "enemy pressure"},
            {"name": "oath", "hex": "#4c78a8", "usage": "ally command"},
            {"name": "memory", "hex": "#8a3ffc", "usage": "memory stone / command unlock"},
            {"name": "field", "hex": "#59a14f", "usage": "field treasure / terrain"},
        ],
    }
    return palettes.get(seed, palettes["risk"])


def check_url_status(url: str, timeout: float = 8.0) -> tuple[str, str]:
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "tactics-public-api-tooling/1.0"})
        with urllib.request.urlopen(req, timeout=timeout) as response:
            return "PASS", f"HTTP {response.status} {response.headers.get('content-type', '')}".strip()
    except Exception as exc:  # external API availability is non-critical
        return "WARN", f"{type(exc).__name__}: {exc}"


def build_sample_markdown(include_network_check: bool = False) -> str:
    badges = [
        Badge("Gate0", "PASS", "brightgreen"),
        Badge("Package", "BLOCKED", "red"),
        Badge("Runtime Evidence", "PASS", "brightgreen"),
        Badge("Public Release", "BLOCKED", "orange"),
    ]
    chart = quickchart_url(
        labels=["Gate0", "Runtime", "Package", "Public"],
        values=[65, 12, 2, 1],
        title="Release readiness sample",
    )
    mermaid = """graph TD
  A[Focused Runner PASS] --> B[QA Evidence]
  B --> C[Release Readiness Report]
  C --> D{Package Ready?}
  D -->|No| E[BLOCKED: package/index]
  D -->|Yes| F[Candidate Release]
""".strip()
    kroki = kroki_encoded_url("mermaid", mermaid)
    palette = local_palette("risk")

    lines = [
        "# Public API visual tooling demo",
        "",
        "이 문서는 QuickChart, Kroki, Shields, xColors 계열 적용 smoke sample입니다.",
        "게임 runtime에는 연결하지 않고 docs/QA/release 보조용으로만 사용합니다.",
        "",
        "## Shields badges",
        "",
    ]
    for badge in badges:
        url = shields_url(badge.label, badge.message, badge.color)
        lines.append(f"![{badge.label}: {badge.message}]({url})")
        lines.append(f"- {badge.label}: {url}")
    lines.extend([
        "",
        "## QuickChart",
        "",
        f"![Release readiness sample]({chart})",
        "",
        f"URL: {chart}",
        "",
        "## Kroki Mermaid",
        "",
        f"![Release flow]({kroki})",
        "",
        f"URL: {kroki}",
        "",
        "Source:",
        "```mermaid",
        mermaid,
        "```",
        "",
        "## xColors / local palette fallback",
        "",
        "public-apis의 xColors 링크는 2026-05-05 기준 Heroku `No such app` 응답이라 직접 의존하지 않습니다.",
        "대신 동일 목적의 palette adapter를 로컬 fallback으로 적용했습니다.",
        "",
        "| token | hex | usage |",
        "|---|---:|---|",
    ])
    for item in palette:
        lines.append(f"| {item['name']} | `{item['hex']}` | {item['usage']} |")

    if include_network_check:
        lines.extend(["", "## Optional network availability check", ""])
        for name, url in [
            ("QuickChart", chart),
            ("Kroki", kroki),
            ("Shields", shields_url("smoke", "ok", "green")),
            ("xColors", XCOLORS_PUBLIC_APIS_URL),
        ]:
            status, detail = check_url_status(url)
            lines.append(f"- {name}: {status} — {detail}")

    lines.append("")
    return "\n".join(lines)


def command_sample(args: argparse.Namespace) -> int:
    out = Path(args.output) if args.output else DOCS_DIR / "public_api_visual_tooling_demo.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(build_sample_markdown(include_network_check=args.check_network), encoding="utf-8")
    print(out)
    return 0


def command_badge(args: argparse.Namespace) -> int:
    print(shields_url(args.label, args.message, args.color, args.style))
    return 0


def command_chart(args: argparse.Namespace) -> int:
    labels = [x.strip() for x in args.labels.split(",") if x.strip()]
    values = [int(x.strip()) for x in args.values.split(",") if x.strip()]
    if len(labels) != len(values):
        raise SystemExit("labels and values must have the same length")
    print(quickchart_url(labels, values, args.title))
    return 0


def command_kroki(args: argparse.Namespace) -> int:
    text = Path(args.file).read_text(encoding="utf-8") if args.file else args.text
    print(kroki_encoded_url(args.type, text, args.format))
    return 0


def command_palette(args: argparse.Namespace) -> int:
    print(json.dumps(local_palette(args.seed), ensure_ascii=False, indent=2))
    return 0


def command_check(args: argparse.Namespace) -> int:
    targets = {
        "quickchart": quickchart_url(["smoke"], [1], "Smoke"),
        "kroki": kroki_encoded_url("mermaid", "graph TD; A-->B"),
        "shields": "https://img.shields.io/badge/smoke-ok-green.svg",
        "xcolors": XCOLORS_PUBLIC_APIS_URL,
    }
    failed = 0
    for name, url in targets.items():
        status, detail = check_url_status(url)
        print(f"{name}: {status} {detail}")
        if status != "PASS" and name != "xcolors":
            failed += 1
    return 1 if failed else 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("sample", help="write sample Markdown integration doc")
    p.add_argument("--output", default="")
    p.add_argument("--check-network", action="store_true")
    p.set_defaults(func=command_sample)

    p = sub.add_parser("badge", help="print Shields badge URL")
    p.add_argument("label")
    p.add_argument("message")
    p.add_argument("color", nargs="?", default="blue")
    p.add_argument("--style", default="flat")
    p.set_defaults(func=command_badge)

    p = sub.add_parser("chart", help="print QuickChart URL")
    p.add_argument("--labels", required=True, help="comma-separated labels")
    p.add_argument("--values", required=True, help="comma-separated integer values")
    p.add_argument("--title", default="Tactics chart")
    p.set_defaults(func=command_chart)

    p = sub.add_parser("kroki", help="print Kroki encoded diagram URL")
    p.add_argument("--type", default="mermaid")
    p.add_argument("--format", default="svg")
    p.add_argument("--text", default="graph TD; A-->B")
    p.add_argument("--file", default="")
    p.set_defaults(func=command_kroki)

    p = sub.add_parser("palette", help="print local xColors-style palette fallback JSON")
    p.add_argument("--seed", default="risk", choices=["risk", "faction"])
    p.set_defaults(func=command_palette)

    p = sub.add_parser("check", help="optional external availability check")
    p.set_defaults(func=command_check)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
