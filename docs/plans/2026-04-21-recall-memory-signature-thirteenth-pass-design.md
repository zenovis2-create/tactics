# Recall Memory Signature Thirteenth Pass Design

**Scope:** recall branch/control memory signature 13차

## Goal

recall 귀환/후일담 카드의 memory payload가 많아졌으므로,
QA와 후속 surface가 이를 한 줄로 빠르게 읽을 수 있는 `memory_signature`를 추가한다.

## Recommended Approach

- `분기 귀환` 카드에 `branch_return|return_surface|branch_return` signature를 추가한다.
- `제어 후일담` 카드에 `control_aftermath|control_surface|control_aftermath` signature를 추가한다.
- 기존 개별 payload와 renderer는 유지한다.

## Verification

- `campaign_hunt_integration_runner.gd`에서 branch/control card의 memory signature를 확인한다.
