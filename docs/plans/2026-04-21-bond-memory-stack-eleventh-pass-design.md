# Bond Memory Stack Eleventh Pass Design

**Scope:** support/name-call memory stack 11차

## Goal

Bond 전용 카드의 label/rail/outcome payload가 많아졌으므로,
QA와 runner가 카드 surface를 한 번에 확인할 수 있는 compact `memory_stack`을 추가한다.

## Recommended Approach

- support card에 `memory_stack` 배열을 추가한다.
- CH10 name-call card에도 `memory_stack` 배열을 추가한다.
- 기존 개별 payload는 유지한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 memory stack을 확인한다.
