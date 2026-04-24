# Late-Game Rule Object Design

**Scope:** CH08_05, CH09B_05, CH10_05 late-game boss stages에 상호작용 오브젝트 기반 규칙 심화 추가

## Goal

후반 보스전이 보스 phase/action만으로 진행되는 전투처럼 보이지 않게 만들고,
플레이어가 직접 전장 규칙을 바꿀 수 있는 오브젝트를 추가해 전술 밀도를 높인다.

## Recommended Approach

각 스테이지에 상호작용 오브젝트 1개씩을 추가한다.

- CH08_05: `transfer_gate_latch`
  - 추격 협로를 열어 레테의 shadow pursuit 라인을 재배치한다.

- CH09B_05: `archive_lectern`
  - revision rewrite를 잠시 고정시켜 아군이 이동할 수 있는 안전 셀을 만든다.

- CH10_05: `anchor_chain`
  - bell pressure lane 일부를 무효화해 최종 종단 접근선을 다시 연다.

## Verification

- `ch06_ch10_boss_surface_runner.gd`에서 오브젝트 authoring을 검증한다.
- `lategame_boss_pattern_runner.gd`에서 오브젝트 상호작용 후 battlefield mutation 완화 효과를 검증한다.
