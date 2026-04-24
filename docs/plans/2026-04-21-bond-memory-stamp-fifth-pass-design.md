# Bond Memory Stamp Fifth Pass Design

**Scope:** support/name-call memory stamp 5차

## Goal

Bond 전용 카드가 단순 대사 카드에 그치지 않고,
어느 전투/결말 단계에서 해금된 기억인지 `memory stamp`로 남기게 만든다.

## Recommended Approach

- support card에 `memory_stamp`를 추가한다.
- CH10 name-call card에도 `memory_stamp`를 추가한다.
- `CampaignPanel`은 quote/callout 위에 이 스탬프를 얇은 보조 줄로 렌더링한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 `memory_stamp`를 확인한다.
