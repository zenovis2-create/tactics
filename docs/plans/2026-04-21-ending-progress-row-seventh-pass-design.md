# Ending Progress Row Seventh Pass Design

**Scope:** ending/credits progress row 7차

## Goal

ending/credits overlay가 phase/source만 보여 주는 수준을 넘어서,
현재 전환이 전체 단계 중 어디까지 왔는지 `progress row`로도 바로 읽히게 만든다.

## Recommended Approach

- `EndingOverlay`에 `EndingProgressLabel` 추가
- `CreditsOverlay`에 `CreditsRowLabel` 추가
- `main.gd`에서 ending type과 credits section index에 따라 progress text 분기

## Verification

- `ending_cinematic_runner.gd`에서 `2/2` progress label 확인
- `postgame_surface_runner.gd`에서 `ROW 4/4` label 확인
