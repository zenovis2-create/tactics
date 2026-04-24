# Recall Memory Stack Eleventh Pass Design

**Scope:** recall branch/control memory stack 11차

## Goal

recall 귀환/후일담 카드의 label/rail 계층이 많아졌으므로,
QA와 runner가 카드 surface를 한 번에 읽을 수 있는 compact `memory_stack`을 추가한다.

## Recommended Approach

- `분기 귀환` 카드에 `memory_stack` 배열을 추가한다.
- `제어 후일담` 카드에도 `memory_stack` 배열을 추가한다.
- 기존 개별 payload는 유지한다.

## Verification

- `campaign_hunt_integration_runner.gd`에서 branch/control card의 memory stack을 확인한다.
