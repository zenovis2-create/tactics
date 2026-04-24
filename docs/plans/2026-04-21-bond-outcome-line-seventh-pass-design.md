# Bond Outcome Line Seventh Pass Design

**Scope:** support/name-call outcome line 7차

## Goal

Bond 전용 카드가 현재 상태만 보여 주는 수준을 넘어서,
이 기억이 실제로 어떤 결과 surface를 열었는지 `outcome line`으로 남기게 만든다.

## Recommended Approach

- support card에 캠프 handoff 결과를 설명하는 `outcome_line`을 추가한다.
- CH10 name-call card에 resolution 결과를 설명하는 `outcome_line`을 추가한다.
- `CampaignPanel`은 support/name-call memory 카드에서 outcome line을 별도 줄로 렌더링한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 outcome line을 확인한다.
