# Bond Memory Stack Second Pass Design

**Scope:** support/name-call memory stack 12차

## Goal

이미 추가된 `memory_stack`이 rail/source/outcome까지만 요약하므로,
이번 패스에서는 `eyebrow`와 `progress`까지 포함시켜 카드 surface를 더 완전하게 요약한다.

## Recommended Approach

- support card memory_stack에 `eyebrow:support_memory`, `progress:support_memory`를 추가한다.
- name-call card memory_stack에 `eyebrow:name_call_memory`, `progress:name_call_memory`를 추가한다.
- 기존 개별 payload와 renderer는 유지한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 expanded memory stack을 확인한다.
