# Bond Source Label Eighth Pass Design

**Scope:** support/name-call source label 8차

## Goal

Bond 전용 카드가 현재 결과만 보여 주는 수준을 넘어서,
이 기억이 어떤 surface 경로에서 올라온 것인지 `source label`로도 읽히게 만든다.

## Recommended Approach

- support card에 `Camp Handoff` source label을 추가한다.
- CH10 name-call card에 `Resolution Surface` source label을 추가한다.
- `CampaignPanel`은 support/name-call memory 카드에서 source label을 별도 줄로 렌더링한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 source label을 확인한다.
