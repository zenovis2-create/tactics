#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import urllib.request
import urllib.error


API_BASE = "http://127.0.0.1:3100"


def resume(agent_id: str) -> dict:
    req = urllib.request.Request(
        f"{API_BASE}/api/agents/{agent_id}/resume",
        data=b"",
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=20) as resp:
        body = resp.read().decode("utf-8")
        return json.loads(body)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: paperclip_resume_agents.py <agent-id> [<agent-id> ...]", file=sys.stderr)
        return 2
    for agent_id in sys.argv[1:]:
        try:
            result = resume(agent_id)
            print(json.dumps(result, ensure_ascii=False))
        except urllib.error.HTTPError as exc:
            print(exc.read().decode("utf-8"), file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
