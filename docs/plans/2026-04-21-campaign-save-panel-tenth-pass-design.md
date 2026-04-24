# Save/Load Tenth Pass Design

**Scope:** CampaignPanel save-panel roundtrip 10차

## Goal

타이틀/패배/NG+ 로드 경로는 이미 고정되어 있으므로,
이번 패스는 캠프 상태에서 `CampaignPanel Save 버튼 -> SaveLoadPanel -> manual save -> camp 유지` 경로를 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `campaign_save_panel_roundtrip_runner.gd`를 추가한다.
- `Main + CampaignPanel + SaveLoadPanel + SaveService` 실제 연결을 사용한다.

## Verification

- `campaign_save_panel_roundtrip_runner.gd` PASS

