# M4 Paperclip Issues — Staging

*생성: 2026-04-15 | 페이퍼클립 사용 가능 시 아래 이슈를 그대로 등록할 것*
*company_id: c9787aa9-7ba7-4544-bf53-4f955d53a0f3*

---

## 등록 방법

```bash
# 페이퍼클립 복구 후 각 블록을 curl로 POST
# POST http://localhost:3100/api/issues
# Content-Type: application/json
```

---

## Issue 1 — SYS-013: progression_service.gd 소유권 및 이벤트 로그

```json
{
  "company_id": "c9787aa9-7ba7-4544-bf53-4f955d53a0f3",
  "title": "SYS-013: Create progression_service.gd for meta-state ownership",
  "body": "## What\nCreate `scripts/battle/progression_service.gd` as the single owner of campaign-level meta state (Burden, Trust, Fragments, Ending Tendency).\n\n## Acceptance\n- All burden/trust updates go through the service, never written directly to ProgressionData\n- Every update emits a log entry with event name, before/after values, and reason string\n- `get_event_log()` returns the full session log\n- m4_progression_runner.gd PASS\n\n## Status\n✅ Scaffold complete at `scripts/battle/progression_service.gd`\nRunner written at `scripts/dev/m4_progression_runner.gd`",
  "status": "in_progress",
  "priority": "high",
  "tags": ["M4", "SYS-013", "engineering"]
}
```

---

## Issue 2 — SYS-014: Burden/Trust 카운터 밴드 이펙트

```json
{
  "company_id": "c9787aa9-7ba7-4544-bf53-4f955d53a0f3",
  "title": "SYS-014: Implement Burden/Trust 0-9 band effects on unit stats",
  "body": "## What\nBurden band 0-9 applies stat penalties to Rian (accuracy, evasion, damage). Trust band 0-9 applies bonuses to squad (support range, damage, status resist). Effects are hardcapped; no snowball.\n\n## Acceptance\n- `get_burden_effect()` returns correct modifier dict per band\n- `get_trust_effect()` returns correct modifier dict per band  \n- Band 9 burden includes accuracy_mod AND evasion_mod AND damage_mod\n- Band 9 trust includes support_range_bonus AND support_damage_bonus AND status_resist_bonus\n- m4_progression_runner.gd PASS\n\n## Status\n✅ Band tables defined in ProgressionService constants",
  "status": "in_progress",
  "priority": "high",
  "tags": ["M4", "SYS-014", "engineering"]
}
```

---

## Issue 3 — SYS-015: 기억 조각 → 커맨드 언락 게이트

```json
{
  "company_id": "c9787aa9-7ba7-4544-bf53-4f955d53a0f3",
  "title": "SYS-015: Memory fragment command unlock gates",
  "body": "## What\nEach chapter-end fragment recovery calls `progression_service.recover_fragment(id)` which (a) marks fragment known, (b) unlocks associated battle command, (c) emits log event.\n\n## Fragment→Command map (CH01-CH10)\n- ch01_fragment → tactical_shift\n- ch02_fragment → cover_advance\n- ch03_fragment → rally_cry\n- ch04_fragment → forced_march\n- ch05_fragment → precision_stance\n- ch06_fragment → intercept\n- ch07_fragment → name_anchor_partial\n- ch08_fragment → vanguard_break\n- ch09_fragment → memory_shield\n- ch10_fragment → name_anchor_full\n\n## Acceptance\n- Second recovery of same fragment returns `already_known: true`, no duplicate unlock\n- Fragment IDs map to correct command IDs\n- `has_command()` returns true after unlock\n- m4_progression_runner.gd PASS\n\n## Status\n✅ Unlock table and recover_fragment() implemented in ProgressionService",
  "status": "in_progress",
  "priority": "high",
  "tags": ["M4", "SYS-015", "engineering"]
}
```

---

## Issue 4 — SYS-016: 엔딩 텐던시 플래그 자동 평가

```json
{
  "company_id": "c9787aa9-7ba7-4544-bf53-4f955d53a0f3",
  "title": "SYS-016: Bind ending tendency flags to Burden/Trust thresholds",
  "body": "## What\n`_evaluate_ending_tendency()` runs after every burden/trust/fragment update and writes `ending_tendency` to ProgressionData. Tendency can be inspected from save or session state.\n\n## Threshold rules\n- `true_ending`: trust >= 7 AND burden <= 6\n- `bad_ending`: burden >= 7\n- `undetermined`: neither condition met\n\n## Acceptance\n- trust=7, burden=5 → true_ending\n- trust=0, burden=7 → bad_ending\n- trust=3, burden=4 → undetermined\n- Tendency change emits `ending_tendency_changed` log event with before/after\n- m4_progression_runner.gd PASS\n\n## Status\n✅ _evaluate_ending_tendency() implemented; thresholds defined as constants",
  "status": "in_progress",
  "priority": "high",
  "tags": ["M4", "SYS-016", "engineering"]
}
```

---

## Issue 5 — M4 러너 통과 검증

```json
{
  "company_id": "c9787aa9-7ba7-4544-bf53-4f955d53a0f3",
  "title": "M4: Run m4_progression_runner and close milestone",
  "body": "## What\nHeadless Godot로 `scripts/dev/m4_progression_runner.gd`를 실행하고 PASS 확인 후 SYS-013~016 전체 done 처리.\n\n## Command\n```bash\ngodot --headless --script scripts/dev/m4_progression_runner.gd\n```\n\n## Acceptance\n- [PASS] M4 progression runner: all assertions passed.\n- SYS-013, SYS-014, SYS-015, SYS-016 모두 done",
  "status": "todo",
  "priority": "high",
  "tags": ["M4", "milestone", "engineering"]
}
```

---

*페이퍼클립 복구 후 이 파일의 JSON 블록을 순서대로 POST하면 됨.*
*이슈 5는 러너 실행 후 결과에 따라 status를 done으로 업데이트.*
