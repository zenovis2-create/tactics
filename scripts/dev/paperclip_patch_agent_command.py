#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import urllib.request


API_BASE = "http://127.0.0.1:3100"


def api_get(path: str) -> dict:
    req = urllib.request.Request(f"{API_BASE}{path}")
    with urllib.request.urlopen(req, timeout=20) as resp:
        return json.loads(resp.read().decode("utf-8"))


def api_patch(path: str, body: dict) -> dict:
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(
        f"{API_BASE}{path}",
        data=data,
        method="PATCH",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=20) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: paperclip_patch_agent_command.py <agent-id> <command>", file=sys.stderr)
        return 2

    agent_id = sys.argv[1]
    command = sys.argv[2]
    agent = api_get(f"/api/agents/{agent_id}")
    adapter_config = dict(agent.get("adapterConfig") or {})
    adapter_config["command"] = command
    result = api_patch(f"/api/agents/{agent_id}", {"adapterConfig": adapter_config})
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
