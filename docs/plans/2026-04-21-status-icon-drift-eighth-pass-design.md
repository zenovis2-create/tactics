# Status Icon Drift Eighth Pass Design

**Scope:** telegraph icon drift 8차

## Goal

status surface가 badge/text/nameplate까지 움직이는 상태에서,
`telegraph icon` 자체에도 상태별 color/alpha drift를 유지해 판독성을 한 단계 더 올린다.

## Recommended Approach

- `UnitActor`에 `status_icon` tween/profile을 추가한다.
- `charm/oblivion/mark/boss_mark`는 icon drift를 유지한다.
- `fear`는 기존 shake 중심을 유지하고 icon drift는 비활성으로 둔다.

## Verification

- `status_visual_runner.gd`에서 charm/oblivion/mark/boss_mark icon drift profile을 확인한다.
