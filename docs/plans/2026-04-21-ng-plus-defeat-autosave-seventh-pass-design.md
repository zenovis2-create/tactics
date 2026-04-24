# Save/Load Seventh Pass Design

**Scope:** NG+ autosave defeat recovery 7차

## Goal

이미 고정된 일반 autosave recovery와 NG+ save/load 사이에서,
`NG+ 시작 -> autosave 생성 -> 패배 -> autosave 복귀` 경로를 별도 통합 러너로 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `ng_plus_defeat_autosave_runner.gd`를 추가한다.
- NG+ source save를 seed하고, NG+ 시작 뒤 autosave를 만든 후 defeat surface에서 복귀시켜 NG+ flag 유지까지 함께 확인한다.

## Verification

- `ng_plus_defeat_autosave_runner.gd` PASS
