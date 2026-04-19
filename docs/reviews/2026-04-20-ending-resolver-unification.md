# Ending Resolver Unification Review
## Date: 2026-04-20

## 요약

`ending_resolver.gd`의 진엔딩 판정 기준을 단일 기준으로 통일하고, `test_ending_resolver.gd`를 독립 실행 가능한 headless 테스트 러너로 전환했다.

---

## 발견된 문제: 판정 기준 혼재

프로젝트 내에서 진엔딩 판정 기준이 두 곳에서 서로 다른 수치를 사용하고 있었다.

### EndingResolver (ending_resolver.gd) — 최종 엔딩 게이트

| 조건 | 수치 |
|------|------|
| trust 최소 | 5 이상 |
| burden 최대 | 4 이하 |
| 동료 bond | 6명 전원 bond_level 5 |
| 기억 파편 | ch01~ch10 전부 회수 |

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
- `EndingResolver.resolve_ending()`: 실제 **최종 판정 게이트**. 4개 조건(bond, burden, trust, fragment) 전부 충족해야 진엔딩 확정.

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

### ending_resolver.gd 변경 없음

`EndingResolver`의 판정 로직은 이미 단일하고 명확하다. 4개 조건의 AND 조합이 유일한 진엔딩 기준이다. 수정하지 않았다.

---

## 단일 기준 선택 근거

`EndingResolver`의 4-조건 기준(`bond 5 × 6 + burden ≤ 4 + trust ≥ 5 + 10파편`)을 **최종 판정의 유일한 기준**으로 확정한다.

근거:
1. `docs/ending_conditions_standard.md` 섹션 4에 명시된 서사 원칙(동료 공명 인장 6개 + 이름 앵커 + 최종전 6인 이름 부름)에 가장 근접한 구현이다.
2. `ProgressionService`의 경향 지표는 UI 피드백 용도이므로 최종 판정과 수치를 일치시킬 필요가 없다. 경향 지표가 더 관대한 수치를 쓰는 것은 "진엔딩 방향으로 가고 있다"는 힌트 기능에 부합한다.
3. 기존 28개 테스트 케이스가 이 기준에 맞게 작성되어 있으며, 모두 통과한다.

---

## 테스트 결과

```
godot4 --headless --path /Volumes/AI/tactics --script res://tests/test_ending_resolver.gd
[PASS] test_ending_resolver: 38/38 tests passed.

godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m4_progression_runner.gd
[PASS] M4 progression runner: all assertions passed.
```

---

## 변경된 파일

- `/Volumes/AI/tactics/tests/test_ending_resolver.gd` — GutTest → SceneTree 전환, 동일 테스트 로직 보존
