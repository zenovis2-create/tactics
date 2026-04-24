# Ending Visual Fourth Pass Design

**Scope:** ending/credits overlay progression pips

## Goal

ending/credits overlay가 텍스트와 색상뿐 아니라,
현재 장면이 어느 지점까지 왔는지 시각적으로 바로 읽히게 만든다.

## Recommended Approach

- `EndingOverlay`
  - small `EndingPipRow` with 2 pips
  - normal ending: first pip active
  - true ending: both pips active

- `CreditsOverlay`
  - small `CreditsPipRow` with 4 pips
  - current credits section index에 따라 active pip 갱신

## Verification

- `ending_cinematic_runner.gd`에서 true ending pip state 확인
- `postgame_surface_runner.gd`에서 final credits pip state 확인
