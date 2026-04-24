# Alias Retirement Checklist

> Closed migration follow-up checklist.
> Current execution priority lives in:
> [2026-04-20-post-migration-priority-queue.md](./2026-04-20-post-migration-priority-queue.md)
> Final migration outcome is summarized in:
> [/Volumes/AI/tactics/docs/reviews/2026-04-20-id-migration-closeout.md](/Volumes/AI/tactics/docs/reviews/2026-04-20-id-migration-closeout.md)

## 목적

`Phase 1`부터 `Phase 5`까지의 식별자 마이그레이션은 끝났다.
이 문서는 남아 있는 old alias를 언제, 어떤 순서로 제거할지 결정하기 위한 최종 체크리스트다.

이 문서가 다루는 old alias:

- `ally_karl`
- `enemy_karon`
- `enemy_karon_final`
- `enemy_varten`
- `enemy_karl_1`
- old resource paths:
  - `ally_karl.tres`
  - `enemy_karon.tres`
  - `enemy_karon_final.tres`
  - `enemy_varten.tres`
  - `enemy_varten_ch09a_05.tres`

## 현재 상태

- canonical runtime IDs:
  - `ally_kyle`
  - `enemy_karuon`
  - `enemy_karuon_final`
  - `enemy_barten`
  - `enemy_kyle_1`

- compatibility layers still active:
  - alias resource files
  - `UNIT_ID_ALIASES`
  - bond alias handling
  - ending alias handling
  - progression/save migration

## 현재 결정

- old alias는 **다음 한 버전 동안 유지**한다.
- 이유:
  - save/load migration smoke가 이제 막 green이 됨
  - canonical 경로 전환 직후라 실제 사용자 save 표본이 더 필요함
  - 지금 단계에서 alias 제거 이득보다 compatibility 유지 이득이 더 큼

다음 검토 시점:

- 다음 릴리스 직전
- 또는 old save 표본 1회 이상 검증 후

## 제거 전 필수 조건

### Save / Load

- [x] old save created with `ally_karl` loads correctly
- [x] old save created with `enemy_karon` / `enemy_karon_final` keys loads correctly
- [x] save sidecar metadata remains readable after canonical save
- [x] save/load runner passes after alias removal candidate patch

### Campaign / Roster

- [x] campaign roster shows `Kyle` exactly once
- [x] CH09A camp roster and sortie assignment pass
- [x] NG+ roster build still works

### Bond / Ending

- [x] `Kyle` bond progression survives migration
- [x] `rian_kyle` support conversation works
- [x] true ending still passes with canonical companion IDs only
- [x] old `rian_karl` save data promotes cleanly

### Boss / Stage

- [x] CH09A boss stage loads with canonical boss path only
- [x] CH10_04 loads with canonical boss path only
- [x] CH10_05 loads with canonical final boss path only
- [x] support name-call pipeline runner still passes

### Tests / Runners

- [x] [test_ending_resolver.gd](/Volumes/AI/tactics/tests/test_ending_resolver.gd) passes
- [x] [save_load_runner.gd](/Volumes/AI/tactics/scripts/dev/save_load_runner.gd) passes
- [x] [five_person_sortie_runner.gd](/Volumes/AI/tactics/scripts/dev/five_person_sortie_runner.gd) passes
- [x] [ch10_representative_battle_controller.gd](/Volumes/AI/tactics/scripts/dev/ch10_representative_battle_controller.gd) loads without lookup regressions

## 권장 제거 순서

### Step 1. Documentation Cleanup

- [x] docs에서 old resource path 표기를 canonical로 교체
- [x] migration plan에 완료 상태 주석 추가

### Step 2. Code Alias Tightening

- [ ] `campaign_catalog.gd`에서 old canonical fallback path 제거 여부 검토
- [ ] `bond_catalog.gd` / `bond_service.gd` / `ending_resolver.gd`에서 alias read를 feature flag로 묶을지 결정

### Step 3. Resource Retirement

- [ ] `enemy_varten_ch09a_05.tres` 삭제 후보 처리
- [ ] `ally_karl.tres` 삭제 후보 처리
- [ ] `enemy_karon.tres` 삭제 후보 처리
- [ ] `enemy_karon_final.tres` 삭제 후보 처리
- [ ] `enemy_varten.tres` 삭제 후보 처리

### Step 4. Alias Removal

- [ ] `UNIT_ID_ALIASES` 제거
- [ ] save migration helper를 compatibility-only branch로 축소
- [ ] old key regression test 추가 후 최종 삭제

### Step 5. Hold Period Review

- [x] 이번 버전은 alias 유지로 결정
- [ ] 다음 릴리스 직전 old alias 제거 재검토
- [ ] 실제 사용자 save 표본 기준 migration 확인

## 제거 금지 조건

다음 중 하나라도 충족되면 old alias를 제거하지 않는다.

- [ ] old save migration 검증이 자동화되지 않음
- [ ] CH09A / CH10 boss runner가 불안정함
- [ ] roster / bond / ending smoke가 모두 green이 아님
- [ ] 문서에서 old id/path를 아직 정본처럼 안내하고 있음

## 이번 턴 결론

현재 기준으로 safe action은 `alias를 유지한 채 다음 릴리스까지 관찰`하는 것이다.

즉:

1. old alias는 다음 한 버전 동안 유지
2. canonical path는 이미 주 경로로 사용
3. 주요 smoke 검증은 완료되었고, 다음 단계는 실제 save 표본을 본 뒤 삭제 여부를 결정하는 것이다
