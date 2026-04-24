# Save/Load Thirteenth Pass Design

**Scope:** NG+ visible defeat->title->load roundtrip 13차

## Goal

이미 고정된 `NG+ visible title load panel`과 `defeat->title->load`를 합쳐,
`NG+ source가 보이는 상태에서 패배 -> 타이틀 복귀 -> 타이틀 Load panel -> autosave/manual 선택` 경로를 별도 통합 러너로 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `ng_plus_defeat_to_title_load_runner.gd`를 추가한다.
- manual NG+ source save와 일반 autosave를 함께 seed하고, title 복귀 뒤 두 선택을 모두 검증한다.

## Verification

- `ng_plus_defeat_to_title_load_runner.gd` PASS

