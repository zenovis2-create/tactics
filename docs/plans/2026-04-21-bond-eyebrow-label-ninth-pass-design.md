# Bond Eyebrow Label Ninth Pass Design

**Scope:** support/name-call eyebrow label 9차

## Goal

Bond 전용 카드가 source/outcome만 보여 주는 수준을 넘어서,
카드 종류 자체를 `Support Memory`, `Name-Call Memory` 같은 eyebrow label로 더 직접적으로 읽히게 만든다.

## Recommended Approach

- support card에 `Support Memory` eyebrow label을 추가한다.
- CH10 name-call card에 `Name-Call Memory` eyebrow label을 추가한다.
- `CampaignPanel`은 support/name-call memory 카드에서 eyebrow label을 별도 줄로 렌더링한다.

## Verification

- `support_namecall_pipeline_runner.gd`에서 support/name-call card의 eyebrow label을 확인한다.
