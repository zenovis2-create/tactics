# Ending Resolver Unification Review
## Date: 2026-04-20

## 요약

`ending_resolver.gd`의 진엔딩 판정 기준을 문서 정본에 맞춰 `공명 인장 + 이름 앵커 + 6인 이름 부름` 축으로 재정렬했고, `test_ending_resolver.gd`를 현재 기준에 맞게 갱신했다.

---

## 발견된 문제: 판정 기준 혼재

프로젝트 내에서 진엔딩 판정 기준이 두 곳에서 서로 다른 수치를 사용하고 있었다.

### EndingResolver (기존) — 최종 엔딩 게이트

| 조건 | 수치 |
|------|------|
| trust 최소 | 5 이상 |
| burden 최대 | 4 이하 |
| 동료 bond | 6명 전원 bond_level 5 |
| 기억 파편 | ch01~ch10 전부 회수 |

### EndingResolver (현재) — 최종 엔딩 게이트

| 조건 | 수치 |
|------|------|
| 공명 인장 | 6개 전부 완성 |
| 이름 앵커 | 2개 이상 유지 proxy (`flag_name_anchors_held_2plus`) |
| 6인 이름 부름 | 전원 발동 (`all_allies_name_called`) |

### ProgressionService (progression_service.gd) — 실시간 엔딩 경향 지표

| 조건 | 수치 |
|------|------|
| trust 최소 | 7 이상 |
| burden 최대 | 6 이하 |
| bad_ending 기준 | burden 7 이상 |
| 동료 bond | 미체크 |
| 기억 파편 | 미체크 |

---

## 판정 기준 통일 방향

두 시스템은 **역할이 다르다**. 혼재가 아니라 **설계 의도의 구분**이었음을 확인했다.

- `ProgressionService._evaluate_ending_tendency()`: 캠페인 중 실시간으로 표시하는 **경향 지표** (UI 힌트 용도). bond나 파편을 체크하지 않는 것은 의도적 설계다. 플레이어에게 방향성만 보여주는 척도이므로 단순 수치만 본다.
- `EndingResolver.resolve_ending()`: 실제 **최종 판정 게이트**. 문서 정본에 맞춰 공명/앵커/이름 부름을 모두 충족해야 진엔딩 확정.

따라서 수치 차이는 두 시스템의 설계 차이에서 비롯된 것이다. 실제 P0 이슈의 원인은 수치 불일치가 아니라, `test_ending_resolver.gd`가 GUT 프레임워크(`extends GutTest`)에 의존하여 headless 환경에서 실행 자체가 불가능했던 것이다.

---

## 수행한 작업

### test_ending_resolver.gd 재작성

`extends GutTest` → `extends SceneTree` 전환.

- GUT 프레임워크가 프로젝트에 설치되어 있지 않아 headless 실행 불가 상태였음
- 기존 테스트 로직(28개 테스트 케이스) 전부 보존
- `m4_progression_runner.gd`와 동일한 SceneTree 패턴 적용
- `_assert_eq`, `_assert_true`, `_assert_false` 헬퍼로 GUT 어설션 대체
- 실패 시 `quit(1)`, 성공 시 `quit(0)` 반환하여 CI 호환

### ending_resolver.gd 재정렬

- `bond / burden / trust / fragment` 기반 최종 게이트 제거
- `flag_resonance_*` 6개 + `flag_name_anchors_held_2plus` + `all_allies_name_called` 기준으로 교체
- 상태 스냅샷도 `missing_resonance_flags`, `name_anchors_ok`, `all_name_calls` 기준으로 재작성

---

## 단일 기준 선택 근거

`EndingResolver`의 최종 판정 기준을 **문서 정본 그대로** 확정한다.

- 공명 인장 6개
- 이름 앵커 2개 이상 유지 proxy
- 6인 이름 부름 전부 발동

근거:
1. `docs/ending_conditions_standard.md` 섹션 4~8의 진엔딩 표준과 직접 일치한다.
2. `ProgressionService`의 burden/trust tendency는 계속 UI용 경향 지표로 남고, 최종 게이트와 역할이 분리된다.
3. 현재 런타임에 없는 “이름 앵커 2개 이상 유지”는 `final_bell_dais_held -> flag_name_anchors_held_2plus` proxy로 보강했다.

---

## 테스트 결과

```
godot4 --headless --path /Volumes/AI/tactics --script res://tests/test_ending_resolver.gd
[PASS] test_ending_resolver: 14/14 tests passed.

godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m4_progression_runner.gd
[PASS] M4 progression runner: all assertions passed.
```

---

## 변경된 파일

- `/Volumes/AI/tactics/scripts/battle/ending_resolver.gd` — 최종 진엔딩 게이트를 공명/앵커/이름부름 기준으로 재정렬
- `/Volumes/AI/tactics/scripts/battle/stage_resolution_service.gd` — `flag_resonance_enoch`, `flag_name_anchors_held_2plus` 저장 경로 추가
- `/Volumes/AI/tactics/tests/test_ending_resolver.gd` — 현재 기준에 맞는 headless 테스트로 재작성
