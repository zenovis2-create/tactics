# Ending Memory Rail Tenth Pass Design

**Scope:** ending/credits memory rail 10차

## Goal

ending/credits overlay가 점형 pip만 보여 주는 수준을 넘어서,
진행 축 자체를 더 직접적으로 읽히게 하는 `memory rail`을 추가한다.

## Recommended Approach

- `EndingOverlay`에 `EndingMemoryRail` 추가
- `CreditsOverlay`에 `CreditsMemoryRail` 추가
- `main.gd`에서 ending type, credits section index에 따라 rail tint를 분기한다.

## Verification

- `ending_cinematic_runner.gd`에서 ending rail tint 확인
- `postgame_surface_runner.gd`에서 credits rail tint 확인
