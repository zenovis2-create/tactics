# Save/Load Eighth Pass Design

**Scope:** NG+ visible title load-panel selection 8차

## Goal

타이틀 화면에 NG+ source save가 보이는 상태에서도,
`Load panel -> manual slot / autosave selection` 경로가 정상 동작하는지 별도 통합 러너로 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `ng_plus_title_load_panel_runner.gd`를 추가한다.
- NG+ source manual save와 일반 autosave를 함께 seed하고, title에서 NG+ visibility를 유지한 채 두 로드 경로를 모두 확인한다.

## Verification

- `ng_plus_title_load_panel_runner.gd` PASS
