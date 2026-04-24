# Ending Visual Second Pass Design

**Scope:** ending overlay / credits overlay visual second pass

## Goal

현재 ending/credits overlay는 문구와 subtitle, eyebrow까지는 갖췄지만,
section 전환감과 결말별 시그널이 아직 약하다.

이번 패스는 작은 고정 UI 요소만 추가해 장면 전환감을 더 강하게 만든다.

## Recommended Approach

- `EndingOverlay`
  - 결말 tier를 직접 보여 주는 `EndingSigilLabel` 추가
  - normal/true ending에 따라 다른 짧은 sigil 코드 표시

- `CreditsOverlay`
  - section count를 시각적으로 보여 주는 `CreditsProgressLabel` 추가
  - `1/4`, `2/4` 식으로 현재 구간을 표시

## Verification

- `ending_cinematic_runner.gd`에서 ending sigil 존재/문구 확인
- `postgame_surface_runner.gd`에서 credits progress 존재/최종값 확인
