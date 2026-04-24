# Status Accent Fourth Pass Design

**Scope:** 상태 표면 지속형 accent layer 4차

## Goal

상태 표면이 `pulse -> idle`까지만 있는 상태에서 한 단계 더 올라가,
활성 상태 동안 `badge / telegraph / crosshair`에 짧고 반복적인 accent cadence를 유지하게 만든다.

## Recommended Approach

- `UnitActor`에 별도 `status accent` 루프를 추가한다.
- snapshot에 `status_accent_active`, `status_accent_profile`를 노출한다.
- `fear`는 기존 shake 중심을 유지하고 accent를 비활성으로 둔다.
- `charm/dot/oblivion/mark/boss_mark`는 각기 다른 accent profile을 가진다.

## Verification

- `status_visual_runner.gd`에서 상태별 accent profile surface를 확인한다.
