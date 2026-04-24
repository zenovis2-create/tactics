# Status Nameplate Drift Seventh Pass Design

**Scope:** status nameplate drift 7차

## Goal

status surface가 badge/icon/text까지만 움직이는 상태에서,
유닛 이름판(backplate)에도 상태별 cadence를 넣어 원거리 판독성을 더 높인다.

## Recommended Approach

- `UnitActor`에 `status_nameplate` tween/profile을 추가한다.
- `charm/oblivion/mark/boss_mark`는 nameplate drift를 유지한다.
- `fear`는 기존 shake 중심을 유지하고 nameplate drift는 비활성으로 둔다.

## Verification

- `status_visual_runner.gd`에서 charm/oblivion/mark/boss_mark nameplate drift profile을 확인한다.
