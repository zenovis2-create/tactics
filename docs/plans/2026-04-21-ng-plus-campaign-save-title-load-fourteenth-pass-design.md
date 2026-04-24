# Save/Load Fourteenth Pass Design

**Scope:** NG+ visible campaign save -> title -> load 14차

## Goal

이미 고정된 `campaign save -> title load`와 `NG+ visible title load`를 합쳐,
NG+ source가 보이는 상태에서 캠프 저장 슬롯이 타이틀 복귀 뒤에도 정상적으로 load path를 통해 battle core-loop로 이어지는지 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `ng_plus_campaign_save_to_title_load_runner.gd`를 추가한다.
- NG+ source metadata가 보이는 상태에서 `camp save -> title -> load panel -> same manual slot load` 흐름을 검증한다.

## Verification

- `ng_plus_campaign_save_to_title_load_runner.gd` PASS

