# Recall Memory Stack Second Pass Design

**Scope:** recall branch/control memory stack 12차

## Goal

이미 추가된 recall `memory_stack`이 rail/source/outcome까지만 요약하므로,
이번 패스에서는 `eyebrow`와 `progress`까지 포함시켜 귀환/후일담 카드를 더 완전하게 요약한다.

## Recommended Approach

- `분기 귀환` 카드 memory_stack에 `eyebrow:branch_return`, `progress:branch_return`를 추가한다.
- `제어 후일담` 카드 memory_stack에 `eyebrow:control_aftermath`, `progress:control_aftermath`를 추가한다.
- 기존 개별 payload는 유지한다.

## Verification

- `campaign_hunt_integration_runner.gd`에서 branch/control card의 expanded memory stack을 확인한다.
