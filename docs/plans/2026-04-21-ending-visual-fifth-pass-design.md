# Ending Visual Fifth Pass Design

**Scope:** 엔딩/크레딧 phase label 5차

## Goal

기존 `accent / fade / pips / eyebrow / progress` 위에,
현재 엔딩 전환이 어떤 단계인지 문구로도 바로 읽히는 `phase label`을 추가한다.

## Recommended Approach

- `EndingOverlay`에 `EndingPhaseLabel`을 추가한다.
- `CreditsOverlay`에 `CreditsPhaseLabel`을 추가한다.
- `main.gd`에서 ending type과 credits section index에 따라 phase text를 분기한다.
- 기존 색/텍스트/진행 row 구조는 유지하고, 한 줄만 추가한다.

## Verification

- `ending_cinematic_runner.gd`에서 true ending phase label을 확인한다.
- `postgame_surface_runner.gd`에서 final credits phase label을 확인한다.
