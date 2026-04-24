# Save/Load Eleventh Pass Design

**Scope:** CampaignPanel save-load core-loop roundtrip 11차

## Goal

10차가 camp save entrypoint를 고정했으므로,
이번 패스는 같은 수동 저장 슬롯을 load path로 복원해 battle core-loop까지 재개되는지 검증한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `campaign_save_load_core_loop_runner.gd`를 추가한다.
- `CampaignPanel Save -> SaveLoadPanel save -> same panel load -> battle core-loop action` 흐름을 검증한다.

## Verification

- `campaign_save_load_core_loop_runner.gd` PASS

