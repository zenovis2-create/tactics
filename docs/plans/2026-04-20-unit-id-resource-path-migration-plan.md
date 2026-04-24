# Unit ID / Resource Path Migration Plan

> Closed migration artifact.
> Current execution priority lives in:
> [2026-04-20-post-migration-priority-queue.md](./2026-04-20-post-migration-priority-queue.md)
> Final migration outcome is summarized in:
> [/Volumes/AI/tactics/docs/reviews/2026-04-20-id-migration-closeout.md](/Volumes/AI/tactics/docs/reviews/2026-04-20-id-migration-closeout.md)

## 목적

현재 프로젝트에는 다음과 같은 내부 식별자 부채가 있었고, 본 문서 기준으로 canonical 전환이 완료되었다.

- 표시명은 `Kyle`인데 내부 ID는 `ally_karl`이었음
- 표시명은 `Karuon`인데 내부 ID는 `enemy_karon`, `enemy_karon_final`이었음
- CH09A 보스는 `Kyle` 보스인데 과거 파일명이 `enemy_varten_ch09a_05.tres`였음
- `Barten / Varten` 계열은 문서와 리소스가 정렬되지 않았었음

이 문서의 목적은:

1. 런타임을 깨지 않고 내부 식별자를 정리하는 순서를 고정한다.
2. 어떤 파일이 어떤 ID를 참조하는지 기준 지도를 남긴다.
3. 한 번에 치환하지 않고 단계적으로 옮기도록 한다.

## 현재 식별자 상태

### 동료

- canonical display name: `Kyle`
- canonical runtime ID: `ally_kyle`
- canonical resource path: `res://data/units/ally_kyle.tres`

주요 참조처:

- [/Volumes/AI/tactics/scripts/campaign/campaign_catalog.gd](/Volumes/AI/tactics/scripts/campaign/campaign_catalog.gd)
- [/Volumes/AI/tactics/scripts/battle/bond_service.gd](/Volumes/AI/tactics/scripts/battle/bond_service.gd)
- [/Volumes/AI/tactics/scripts/battle/ending_resolver.gd](/Volumes/AI/tactics/scripts/battle/ending_resolver.gd)
- [/Volumes/AI/tactics/data/bonds/bond_catalog.gd](/Volumes/AI/tactics/data/bonds/bond_catalog.gd)
- [/Volumes/AI/tactics/tests/test_ending_resolver.gd](/Volumes/AI/tactics/tests/test_ending_resolver.gd)
- [/Volumes/AI/tactics/scripts/dev/five_person_sortie_runner.gd](/Volumes/AI/tactics/scripts/dev/five_person_sortie_runner.gd)

### 최종 보스

- canonical display name: `Karuon`
- canonical runtime IDs:
  - `enemy_karuon`
  - `enemy_karuon_final`
- canonical resource paths:
  - `res://data/units/enemy_karuon.tres`
  - `res://data/units/enemy_karuon_final.tres`

주요 참조처:

- [/Volumes/AI/tactics/data/stages/ch10_04_stage.tres](/Volumes/AI/tactics/data/stages/ch10_04_stage.tres)
- [/Volumes/AI/tactics/data/stages/ch10_05_stage.tres](/Volumes/AI/tactics/data/stages/ch10_05_stage.tres)
- [/Volumes/AI/tactics/scripts/dev/ch10_representative_battle_controller.gd](/Volumes/AI/tactics/scripts/dev/ch10_representative_battle_controller.gd)
- [/Volumes/AI/tactics/scripts/dev/support_namecall_pipeline_runner.gd](/Volumes/AI/tactics/scripts/dev/support_namecall_pipeline_runner.gd)

### CH09A 보스

- canonical display name: `Kyle`
- canonical runtime ID inside boss resource: `enemy_kyle_1`
- canonical resource path in use:
  - `res://data/units/enemy_kyle_ch09a_05.tres`

legacy resource path still present:

- `res://data/units/enemy_varten_ch09a_05.tres`

stage currently points to the corrected path:

- [/Volumes/AI/tactics/data/stages/ch09a_05_stage.tres](/Volumes/AI/tactics/data/stages/ch09a_05_stage.tres)

### 9A 실제 보스

- canonical display name: `Barten`
- canonical runtime ID: `enemy_barten`
- canonical resource path: `res://data/units/enemy_barten.tres`

이 항목은 아직 전용 보스 패턴/스테이지 정렬이 끝나지 않았음.

## 왜 바로 치환하면 안 되는가

다음 이유로 전면 치환은 위험하다.

1. `unit_id`는 단순 표기 문자열이 아니라 저장/진척/본드/엔딩 조건의 키다.
2. `CampaignCatalog`, `BondCatalog`, `EndingResolver`, 테스트, dev runner가 모두 같은 키를 공유한다.
3. `resource path`는 stage ext_resource와 코드 preload가 동시에 잡고 있어서 한쪽만 바꾸면 바로 깨진다.
4. 일부 보스는 `display_name`, `resource path`, `unit_id`, `boss_pattern`이 서로 다른 층으로 꼬여 있다.

즉, 이 작업은 `rename`가 아니라 `migration`이다.

## 마이그레이션 원칙

1. `display_name`과 `문서 표기`는 이미 canonical에 맞췄다.
2. 다음 단계는 `resource path alias`를 먼저 안정화한다.
3. `unit_id` 변경은 마지막 단계에서만 한다.
4. 저장 데이터와 테스트를 동시에 갱신한다.
5. 한 턴에 하나의 축만 옮긴다.

## 권장 단계

### Phase 1. Alias Layer
status: completed

목표:

- 신규 canonical 경로를 만들고, 구경로는 임시 alias로 유지

예시:

- `ally_karl.tres` 유지
- `ally_kyle.tres` 추가
- 두 리소스 중 하나를 canonical source로 정하고, 다른 하나는 동일 내용으로 mirror

동일 방식:

- `enemy_karon.tres` + `enemy_karuon.tres`
- `enemy_karon_final.tres` + `enemy_karuon_final.tres`
- `enemy_varten.tres` + `enemy_barten.tres`

이 단계의 목적은 preload/stage ref가 깨지지 않게 경로 선택지를 먼저 넓히는 것이다.

### Phase 2. Catalog Dual-Read
status: completed

목표:

- 코드가 old ID와 new ID를 둘 다 읽게 만들기

수정 대상:

- [/Volumes/AI/tactics/scripts/campaign/campaign_catalog.gd](/Volumes/AI/tactics/scripts/campaign/campaign_catalog.gd)
- [/Volumes/AI/tactics/data/bonds/bond_catalog.gd](/Volumes/AI/tactics/data/bonds/bond_catalog.gd)
- [/Volumes/AI/tactics/scripts/battle/bond_service.gd](/Volumes/AI/tactics/scripts/battle/bond_service.gd)
- [/Volumes/AI/tactics/scripts/battle/ending_resolver.gd](/Volumes/AI/tactics/scripts/battle/ending_resolver.gd)

방식:

- canonical lookup key는 새 ID로 추가
- 구 ID도 temporary alias로 유지
- 로딩 시 `old -> new` 매핑 테이블을 한 곳에서 해석

예시 alias map:

```gdscript
const UNIT_ID_ALIASES := {
    &"ally_karl": &"ally_kyle",
    &"enemy_karon": &"enemy_karuon",
    &"enemy_karon_final": &"enemy_karuon_final",
    &"enemy_varten": &"enemy_barten",
    &"enemy_karl_1": &"enemy_kyle_1",
}
```

### Phase 3. Stage / Script Ref Swap
status: completed

목표:

- stage ext_resource, dev runner, tests를 canonical 경로로 교체

수정 대상:

- `data/stages/*.tres`
- `scripts/dev/*.gd`
- `tests/*.gd`

이 단계에서는 `resource path`를 바꾸되, `unit_id`는 아직 유지 가능하다.

### Phase 4. Save / Progression Migration
status: completed

목표:

- 저장 데이터와 progression key를 새 ID로 승격

수정 대상:

- progression load path
- save/load migration helper

필수 조건:

- 저장 파일 로드 시 old key가 있으면 new key로 promote
- old key는 한 버전 동안 backward compatibility 유지

### Phase 5. Runtime ID Flip
status: completed

목표:

- resource 내부 `unit_id`를 canonical ID로 실제 변경

예시:

- `ally_karl` -> `ally_kyle`
- `enemy_karon` -> `enemy_karuon`
- `enemy_karon_final` -> `enemy_karuon_final`
- `enemy_varten` -> `enemy_barten`
- `enemy_karl_1` -> `enemy_kyle_1`

이 단계 이후에만 old ID 제거를 검토한다.

## 테스트 체크리스트

### 필수

1. campaign roster에 `Kyle` 정상 표시
2. bond progression에서 `Kyle` bond 유지
3. ending resolver true ending 조건 정상 유지
4. CH09A boss load 정상
5. CH10 boss load 정상
6. old save data load 시 `Kyle / Karuon / Barten` 계열 progression 손실 없음

### 대상 파일

- [/Volumes/AI/tactics/tests/test_ending_resolver.gd](/Volumes/AI/tactics/tests/test_ending_resolver.gd)
- [/Volumes/AI/tactics/scripts/dev/five_person_sortie_runner.gd](/Volumes/AI/tactics/scripts/dev/five_person_sortie_runner.gd)
- [/Volumes/AI/tactics/scripts/dev/ch10_representative_battle_controller.gd](/Volumes/AI/tactics/scripts/dev/ch10_representative_battle_controller.gd)

## 권장 실행 순서

1. `ally_karl -> ally_kyle` alias layer
2. `enemy_karon -> enemy_karuon` alias layer
3. `enemy_varten -> enemy_barten` alias layer
4. dual-read catalog 적용
5. stage / test ref swap
6. save migration
7. runtime id flip

## 이번 턴 결론

마이그레이션 본체는 완료되었다.

현재 안전한 다음 작업은 `alias retirement readiness` 검증이다.

- old alias 제거 조건 검증
- 문서에 남은 old path / old id 안내 정리
- compatibility layer 제거 전 regression pass
