# Ending Outcome Line Eighth Pass Design

**Scope:** ending/credits outcome line 8차

## Goal

ending/credits overlay가 phase/source/progress만 보여 주는 수준을 넘어서,
이 결말과 현재 credits section이 실제로 무엇을 남기는지 `outcome line`으로도 읽히게 만든다.

## Recommended Approach

- `EndingOverlay`에 `EndingOutcomeLabel` 추가
- `CreditsOverlay`에 `CreditsOutcomeLabel` 추가
- `main.gd`에서 ending type과 credits section index에 따라 outcome text 분기

## Verification

- `ending_cinematic_runner.gd`에서 true ending outcome line 확인
- `postgame_surface_runner.gd`에서 final credits outcome line 확인
