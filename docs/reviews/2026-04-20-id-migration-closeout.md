# ID Migration Closeout

## 상태

- `Phase 1` alias resource: 완료
- `Phase 2` catalog dual-read: 완료
- `Phase 3` stage / dev / test canonical ref swap: 완료
- `Phase 4` save / progression migration: 완료
- `Phase 5` runtime canonical ID flip: 완료

## canonical 기준

### 동료

- display name: `Kyle`
- runtime id: `ally_kyle`
- canonical resource: `res://data/units/ally_kyle.tres`

### 최종 보스

- display name: `Karuon`
- runtime ids:
  - `enemy_karuon`
  - `enemy_karuon_final`
- canonical resources:
  - `res://data/units/enemy_karuon.tres`
  - `res://data/units/enemy_karuon_final.tres`

### 9A 보스

- display name: `Barten`
- runtime id: `enemy_barten`
- canonical resource: `res://data/units/enemy_barten.tres`

### CH09A Kyle 보스

- display name: `Kyle`
- runtime id: `enemy_kyle_1`
- canonical resource: `res://data/units/enemy_kyle_ch09a_05.tres`

## 검증 결과

- [test_ending_resolver.gd](/Volumes/AI/tactics/tests/test_ending_resolver.gd): pass
- [save_load_runner.gd](/Volumes/AI/tactics/scripts/dev/save_load_runner.gd): pass
- [five_person_sortie_runner.gd](/Volumes/AI/tactics/scripts/dev/five_person_sortie_runner.gd): pass
- [support_namecall_pipeline_runner.gd](/Volumes/AI/tactics/scripts/dev/support_namecall_pipeline_runner.gd): pass
- [ch10_shell_runner.gd](/Volumes/AI/tactics/scripts/dev/ch10_shell_runner.gd): pass

## 운영 결정

- old alias는 다음 한 버전 동안 유지
- 이유:
  - old save compatibility smoke는 green이지만, 실제 사용자 save 표본 관찰 기간이 아직 필요함
  - canonical 경로는 이미 주 경로로 전환 완료
  - 지금 시점의 추가 삭제 작업은 위험 대비 이득이 작음

## 남은 후속 작업

1. 다음 릴리스 직전 old alias 제거 재검토
2. 실제 save 표본으로 migration 재확인
3. 새 기능 작업 중 old id/path 신규 사용 금지
