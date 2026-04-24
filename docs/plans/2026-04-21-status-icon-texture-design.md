# Status Icon Texture Design

**Scope:** `UnitActor` status badge에 상태별 소형 텍스처 아이콘 추가

## Goal

현재 상태 배지는 텍스트 코드만으로 primary status를 표시한다.
이번 패스에서는 작은 아이콘 텍스처를 추가해, 문자에 의존하지 않고도 상태를 더 빠르게 구분하게 만든다.

## Recommended Approach

- `UnitActor`에 `StatusBadgeIcon` 노드를 추가한다.
- `TelegraphTextureLibrary`가 상태별 소형 procedural icon texture를 생성/캐시한다.
- 배지 텍스트는 유지하고, 아이콘은 그 왼쪽에 붙인다.

## Status Mapping

- `boss_mark` → `status_boss_mark`
- `mark` → `status_mark`
- `fear` → `status_fear`
- `charm` → `status_charm`
- `dot` → `status_dot`
- `oblivion` → `status_oblivion`

## Verification

- `scripts/dev/status_visual_runner.gd`에 배지 아이콘 visibility/kind 실패 테스트를 먼저 추가한다.
- 최종적으로 `status_visual_runner.gd`를 다시 통과시킨다.
