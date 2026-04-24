# Save/Load Fourteenth Pass Design

**Scope:** campaign save -> defeat -> title -> load roundtrip 14차

## Goal

이미 고정된 `camp save -> title load`와 `defeat -> title load`를 합쳐,
캠프에서 저장한 슬롯이 패배 화면을 거쳐 타이틀로 돌아간 뒤에도 정상적으로 load path를 통해 battle core-loop로 이어지는지 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `campaign_save_defeat_title_load_runner.gd`를 추가한다.
- `camp save -> defeat surface -> title return -> title load panel -> same slot load` 흐름을 검증한다.

## Verification

- `campaign_save_defeat_title_load_runner.gd` PASS

