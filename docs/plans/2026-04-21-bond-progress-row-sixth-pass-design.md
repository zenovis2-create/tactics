# Bond Progress Row Sixth Pass Design

**Scope:** support/name-call progress row 6차

## Goal

Bond 전용 카드가 style/badges/stamp만 보여 주는 수준을 넘어서,
현재 인연 단계가 어디까지 왔는지 `progress row`로도 바로 읽히게 만든다.

## Recommended Approach

- support card에 현재 지원 랭크 progress row를 추가한다.
- CH10 name-call card에도 최종 이름 부름 progress row를 추가한다.
- `CampaignPanel`은 `support_memory` / `name_call_memory` 카드에서 progress row를 렌더링한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 progress row를 확인한다.
