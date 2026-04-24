# Recall Branch Third Pass Design

**Scope:** recall hunt branch results feeding back into selected-hunt presentation cards

## Goal

회상 토벌전의 분기 결과가 귀환 카드에서만 끝나지 않고,
같은 hunt를 다시 선택했을 때 보이는 출정/전장 카드에도 반영되게 만든다.

## Recommended Approach

- `last_hunt_result`가 현재 선택된 hunt와 같으면:
  - selected hunt card body에 최근 귀환 branch summary를 덧붙인다
  - stage brief card에 최근 제어 결과/후일담 요약을 덧붙인다
  - 필요 시 branch recap card 1장을 추가한다

## Verification

- `campaign_hunt_integration_runner.gd`에서 selected hunt card와 stage brief card가 branch-aware해졌는지 확인
- `hunt_reward_runner.gd`는 기존 branch payload 유지 확인
