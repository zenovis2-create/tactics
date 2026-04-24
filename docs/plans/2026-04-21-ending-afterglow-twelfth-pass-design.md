# Ending Afterglow Twelfth Pass Design

**Scope:** ending/credits afterglow layer 12차

## Goal

ending/credits overlay가 rail까지 갖춘 상태에서,
전환 직후의 잔광이 남는 `afterglow layer`를 추가해 화면의 마감감을 높인다.

## Recommended Approach

- `EndingOverlay`에 `EndingAfterglow`를 추가한다.
- `CreditsOverlay`에 `CreditsAfterglow`를 추가한다.
- `main.gd`에서 ending type과 credits section index에 따라 afterglow tint를 분기한다.

## Verification

- `ending_cinematic_runner.gd`에서 true ending afterglow tint를 확인한다.
- `postgame_surface_runner.gd`에서 final credits afterglow tint를 확인한다.
