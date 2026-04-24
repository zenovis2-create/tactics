# Status Afterglow Eleventh Pass Design

**Scope:** status afterglow 11차

## Goal

상태가 해제될 때 release만 짧게 지나가고 바로 끊기는 상태에서,
방금 사라진 상태의 잔향을 짧게 남기는 `afterglow` layer를 추가한다.

## Recommended Approach

- `UnitActor`에 `status_afterglow` tween/profile을 추가한다.
- primary status가 비워질 때 직전 상태 기준으로 afterglow를 실행한다.
- snapshot에 `status_afterglow_active`, `status_afterglow_profile`를 노출한다.

## Verification

- `status_visual_runner.gd`에서 charm clear / boss_mark clear 후 afterglow profile을 확인한다.
