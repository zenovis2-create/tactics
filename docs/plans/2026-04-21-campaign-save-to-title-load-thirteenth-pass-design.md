# Save/Load Thirteenth Pass Design

**Scope:** campaign save -> title -> load roundtrip 13차

## Goal

캠프에서 저장한 수동 슬롯이 타이틀 복귀 뒤에도 정상적으로 load path를 통해 battle core-loop로 이어지는지 별도 통합 러너로 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `campaign_save_to_title_load_runner.gd`를 추가한다.
- `camp save -> title return -> title load panel -> manual slot load` 흐름을 검증한다.

## Verification

- `campaign_save_to_title_load_runner.gd` PASS

