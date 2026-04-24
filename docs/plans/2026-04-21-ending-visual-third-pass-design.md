# Ending Visual Third Pass Design

**Scope:** ending overlay / credits overlay fade tint third-pass polish

## Goal

ending/credits overlay가 텍스트와 accent만 다른 화면처럼 보이지 않게 만들고,
결말 타입과 credits section에 따라 화면 전체의 분위기가 바뀌는 감각을 추가한다.

## Recommended Approach

- `EndingOverlay/Fade`
  - normal ending: warm ash-black
  - true ending: cooler blue-black

- `CreditsOverlay/Fade`
  - section index에 따라 tint를 바꿔 section 전환감을 강화

## Verification

- `ending_cinematic_runner.gd`에서 true ending fade tint 확인
- `postgame_surface_runner.gd`에서 credits final-section fade tint 확인
