# Ending Eyebrow Ninth Pass Design

**Scope:** ending/credits eyebrow tier label 9차

## Goal

ending/credits overlay가 phase/source/progress/outcome만 보여 주는 수준을 넘어서,
결말 tier와 현재 roll 성격을 `eyebrow/tier label`로도 더 직접적으로 읽히게 만든다.

## Recommended Approach

- `EndingOverlay`에 `EndingEyebrowLabel` 추가
- `CreditsOverlay`에 `CreditsTierLabel` 추가
- `main.gd`에서 ending type에 따라 문구를 분기한다.

## Verification

- `ending_cinematic_runner.gd`에서 `True Ending` eyebrow 확인
- `postgame_surface_runner.gd`에서 `True Ending Roll` tier label 확인
