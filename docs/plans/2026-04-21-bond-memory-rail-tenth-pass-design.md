# Bond Memory Rail Tenth Pass Design

**Scope:** support/name-call memory rail 10차

## Goal

Bond 전용 카드가 label 계층만 갖는 수준을 넘어서,
ending/credits와 같은 `memory rail` 시각 언어를 공유하게 만든다.

## Recommended Approach

- support card에 `memory_rail: support` payload를 추가한다.
- CH10 name-call card에 `memory_rail: name_call` payload를 추가한다.
- `CampaignPanel`은 support/name-call memory card에서 rail marker를 얇은 accent bar로 렌더링한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 memory rail marker를 확인한다.
