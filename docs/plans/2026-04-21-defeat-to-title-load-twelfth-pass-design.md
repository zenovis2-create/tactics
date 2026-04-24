# Save/Load Twelfth Pass Design

**Scope:** defeat-to-title load-panel roundtrip 12차

## Goal

패배 화면에서 타이틀로 돌아간 뒤에도,
타이틀의 Load panel 경로가 autosave/manual 선택 모두에서 정상적으로 battle core-loop를 복원하는지 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `defeat_to_title_load_runner.gd`를 추가한다.
- 흐름은 `defeat surface -> title return -> title load panel -> autosave load -> manual load` 순서로 검증한다.

## Verification

- `defeat_to_title_load_runner.gd` PASS

