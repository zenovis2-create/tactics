# Status Badge Text Ninth Pass Design

**Scope:** status badge-text shimmer 9차

## Goal

status surface가 icon/text/nameplate까지 움직이는 상태에서,
`status badge text` 자체에도 상태별 cadence를 넣어 근거리 판독성을 더 높인다.

## Recommended Approach

- `UnitActor`에 `status_badge_text` tween/profile을 추가한다.
- `charm/oblivion/mark/boss_mark`는 badge-text shimmer를 유지한다.
- `fear`는 기존 shake 중심을 유지하고 badge-text shimmer는 비활성으로 둔다.

## Verification

- `status_visual_runner.gd`에서 charm/oblivion/mark/boss_mark badge-text shimmer profile을 확인한다.
