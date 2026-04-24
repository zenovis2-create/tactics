# Recall Progress Row Sixth Pass Design

**Scope:** recall branch/control progress row 6차

## Goal

회상 토벌전 귀환/후일담 카드가 title/body/stamp만 보여 주는 수준을 넘어서,
어떤 분기와 제어가 완료됐는지 `progress row`로도 바로 읽히게 만든다.

## Recommended Approach

- `분기 귀환` 카드에 optional objective progress row를 추가한다.
- `제어 후일담` 카드에 control result progress row를 추가한다.
- `CampaignPanel`은 generic presentation card에서도 progress row를 렌더링한다.

## Verification

- `campaign_hunt_integration_runner.gd`에서 optional-objective/control progress row를 확인한다.
