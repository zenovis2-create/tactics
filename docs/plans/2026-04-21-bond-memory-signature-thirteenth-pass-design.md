# Bond Memory Signature Thirteenth Pass Design

**Scope:** support/name-call memory signature 13차

## Goal

Bond 전용 카드의 memory payload가 많아졌으므로,
QA와 후속 surface가 이를 한 줄로 빠르게 읽을 수 있는 `memory_signature`를 추가한다.

## Recommended Approach

- support card에 `support|camp_handoff|support_memory` signature를 추가한다.
- CH10 name-call card에 `name_call|resolution_surface|name_call_memory` signature를 추가한다.
- 기존 개별 payload와 renderer는 유지한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 memory signature를 확인한다.
