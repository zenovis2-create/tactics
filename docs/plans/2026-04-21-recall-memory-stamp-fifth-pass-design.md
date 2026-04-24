# Recall Memory Stamp Fifth Pass Design

**Scope:** recall branch memory stamp 5차

## Goal

회상 토벌전 분기 카드가 body/title만 달라지는 수준을 넘어서,
어떤 hunt의 어떤 제어/선택 목표가 귀환 결과를 만든 것인지 `memory stamp`로 남기게 만든다.

## Recommended Approach

- `CampController`가 branch 결과에 stamp 메타데이터를 실어 준다.
- `CampaignController`가 귀환/후일담 카드에 해당 stamp를 연결한다.
- `CampaignPanel`은 stamp가 있는 카드에 얇은 보조 줄을 렌더링한다.

## Verification

- `campaign_hunt_integration_runner.gd`에서 optional-objective stamp와 control stamp를 확인한다.
