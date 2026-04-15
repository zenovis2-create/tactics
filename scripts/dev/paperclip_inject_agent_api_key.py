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


def api_post(path: str, body: dict | None = None) -> dict:
    data = json.dumps(body or {}).encode("utf-8")
    req = urllib.request.Request(
        f"{API_BASE}{path}",
        data=data,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
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
    if len(sys.argv) != 2:
        print("usage: paperclip_inject_agent_api_key.py <agent-id>", file=sys.stderr)
        return 2

    agent_id = sys.argv[1]
    agent = api_get(f"/api/agents/{agent_id}")
    key = api_post(f"/api/agents/{agent_id}/keys", {"name": "runtime-process-key"})
    api_key = key.get("token")
    if not api_key:
        print("failed to create agent api key", file=sys.stderr)
        return 1

    adapter_config = dict(agent.get("adapterConfig") or {})
    env_map = dict(adapter_config.get("env") or {})
    env_map["PAPERCLIP_API_KEY"] = {"type": "plain", "value": api_key}
    adapter_config["env"] = env_map
    updated = api_patch(f"/api/agents/{agent_id}", {"adapterConfig": adapter_config})
    print(json.dumps({"agentId": agent_id, "updated": True, "status": updated.get("status")}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
