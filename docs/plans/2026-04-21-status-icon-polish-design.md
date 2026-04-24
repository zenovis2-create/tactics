# Status Icon Polish Design

**Scope:** `UnitActor` 상태이상 표면에 전용 상태 배지를 추가해 battlefield readability를 높인다.

## Goal

현재 상태이상 표면은 색, telegraph text, generic telegraph icon에 의존한다.
이번 패스에서는 각 상태를 작은 전용 배지로 한 번 더 고정해, HUD 없이도 unit head-area에서 빠르게 판독되게 만든다.

## Recommended Approach

`UnitActor`에 작은 `StatusBadgeBack` + `StatusBadgeLabel` 조합을 추가한다.

- `boss_mark` → `MK`
- `mark` → `표`
- `fear` → `공`
- `charm` → `유`
- `dot` → `지`
- `oblivion` → `망`

배지는 현재 primary status가 있을 때만 보이고, 기존 nameplate/telegraph과 충돌하지 않도록 작은 칩 형태로 둔다.

## Why This Approach

- 새 이미지 자산 없이도 바로 적용 가능하다.
- headless runner에서 텍스트/visible/color contract를 검증할 수 있다.
- 기존 `TelegraphIcon`과 역할이 분리된다.

## Verification

- `scripts/dev/status_visual_runner.gd`에 배지 표시/우선순위 테스트를 먼저 추가한다.
- `scenes/battle/Unit.tscn`과 `scripts/battle/unit_actor.gd`만 수정한다.
- 최종적으로 `status_visual_runner.gd`를 다시 통과시킨다.
