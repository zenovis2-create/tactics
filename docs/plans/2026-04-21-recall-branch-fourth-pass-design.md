# Recall Branch Fourth Pass Design

**Scope:** recall return card titling/eyebrow branch refinement

## Goal

회상 토벌전 branch 결과가 body 텍스트만 바꾸는 수준을 넘어서,
귀환 카드 자체의 eyebrow/title에서도 즉시 읽히게 만든다.

## Recommended Approach

- `last_hunt_result.branch_summary`가 있으면
  - return card eyebrow를 `분기 귀환`으로 승격
  - return card title에 branch 의미를 반영
  - return scene card eyebrow/title도 branch-aware하게 바꾼다

## Verification

- `campaign_hunt_integration_runner.gd`에서 branch-aware title/eyebrow 확인
