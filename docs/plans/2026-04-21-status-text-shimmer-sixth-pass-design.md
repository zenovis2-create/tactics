# Status Text Shimmer Sixth Pass Design

**Scope:** telegraph text shimmer 6차

## Goal

status surface가 아이콘/배지 중심으로만 움직이는 상태에서 한 단계 더 올라가,
활성 상태 동안 `TelegraphLabel` 자체에도 상태별 cadence를 남긴다.

## Recommended Approach

- `UnitActor`에 `status_text` tween/profile을 추가한다.
- `charm/dot/oblivion/mark/boss_mark`는 text shimmer를 유지한다.
- `fear`는 기존 shake 중심을 유지하고 text shimmer는 비활성으로 둔다.

## Verification

- `status_visual_runner.gd`에서 charm/oblivion/mark/boss_mark text shimmer profile을 확인한다.
