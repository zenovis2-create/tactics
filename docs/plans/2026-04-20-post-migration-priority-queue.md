# Post-Migration Priority Queue

## 목적

ID/resource migration, text cleanup, campaign UI cleanup 이후의 다음 개발을
산발적인 TODO가 아니라 `즉시 집행 가능한 큐`로 고정한다.

이 문서는 다음을 한 번에 제공한다.

1. 지금 가장 먼저 해야 할 작업
2. 왜 그 작업이 먼저인지
3. 선행 조건
4. 완료 기준
5. 검증 기준

## 현재 기준 상태

- canonical ID / resource path migration: 완료
- save / load / ending / CH10 shell smoke: green
- stage/cutscene/campaign/player-facing text cleanup: 완료
- alias compatibility layer: 다음 한 버전 유지

즉, 지금은 `정리 작업`이 아니라 `runtime content / progression / battle depth`를 채우는 단계다.

## 우선순위 규칙

1. progression / chapter handoff를 먼저 닫는다.
2. 그 다음 컷신/보스처럼 체감이 큰 콘텐츠를 채운다.
3. 마지막에 비주얼 polish와 메타 시스템을 확장한다.

## Queue A. 즉시 착수

### A1. StageResolutionService 실제 연동

상태:

- 완료

목표:

- battle 결과를 progression/save/camp handoff에 실제 반영

포함 범위:

- cleared stage commit
- chapter complete flag commit
- memory/evidence/letter commit
- optional objective commit
- recruit / hunt / resonance commit

완료 기준:

- battle clear 후 camp로 넘어갈 때 progression 상태가 실제 갱신됨
- save/load 후에도 유지됨
- records / reward / chapter handoff와 모순이 없음

검증:

- `save_load_runner.gd`
- `three_star_runner.gd`
- chapter handoff smoke

완료 결과:

- `ProgressionData`에 progression commit 필드 추가
- `StageResolutionService`를 current runtime contract에 맞게 정리
- `CampaignController._commit_stage_rewards()` 앞단에 실제 resolve 연결
- `save_load_runner.gd` pass
- `three_star_runner.gd` pass

### A2. CH02~CH05 컷신 콘텐츠 집행

상태:

- 1차 완료

목표:

- 2장~5장의 intro/outro/합류 컷신을 실제 catalog에 채움

우선 대상:

1. CH02 fortress 접근 / Bran 합류
2. CH03 forest 진입 / Tia 합류
3. CH04 수도원 침수 / 사리아 철학 첫 노출
4. CH05 서고 진입 / Enoch 합류

선행 조건:

- A1 완료 권장

완료 기준:

- stage의 cutscene id가 실제 catalog 구현을 가리킴
- chapter shell에서 비어 있는 컷신 구간이 사라짐

검증:

- cutscene lookup smoke
- chapter shell runner

완료 결과:

- CH02~CH05 stage의 `start_cutscene_id` / `clear_cutscene_id` 40개가 모두 실제 catalog 구현을 가리킴
- `CutsceneCatalog`에 CH02~CH05 intro/outro 텍스트 컷신 추가
- cutscene id lookup missing 0건 확인

### A3. CH02~CH05 보스 패턴 마감

상태:

- 2차 완료

목표:

- 현재 최소 구현 상태의 보스를 chapter intent 수준으로 끌어올림

우선 대상:

1. Valgar
2. Basil
3. Saria
4. CH05 boss gimmick

선행 조건:

- A1 완료 권장

완료 기준:

- phase label만 있는 것이 아니라 실제 gimmick action 존재
- stage objective / interaction / terrain과 연결

검증:

- chapter-specific battle smoke
- boss runner

완료 결과:

- `CH02_05`
  - `hardren_trap_salvo`에 runtime counter 추가
  - 함정 발동 3회 시 `activate_3_traps` flag 실작동
- `CH03_05`
  - `no_structures_destroyed`를 stage bootstrap 시 활성화
  - `shrine_burn` phase의 `resin_ignition`이 구조 보존 목표를 실제로 깨뜨림
  - `ally_scout`가 보스 마무리 시 `tia_defeats_enemy_boss` flag 실작동
- `CH05_05`
  - `archive_collapse`에 ledger counter 추가
  - 붕괴 3회 시 `collect_3_ledger_entries` flag 실작동
  - `defeat_boss_without_noah_dying`는 Noah runtime 부재 동안 no-casualty proxy로 유지
- 전용 검증 러너 `ch02_ch05_boss_pattern_runner.gd` 추가 및 pass

## Queue B. 바로 다음

### B1. BondService 완전 연동

상태:

- 1차 완료

목표:

- 전투 / 캠프 / 엔딩 사이의 bond progression을 완전 연결

포함 범위:

- shared battle progression
- support rank up surface
- finale name-call coherence
- camp dialogue / history surface

완료 결과:

- support rank progression / result surface / finale name-call 유지
- Bond 5 피해 분담 1차 구현
- `bond_runner.gd` pass
- `support_namecall_pipeline_runner.gd` pass

### B2. 장비 슬롯 UI 완성

상태:

- 2차 완료

목표:

- 현재 shell 수준의 장비 UI를 실제 플레이 루프용 관리 UI로 마감

포함 범위:

- 무기 / 방어구 / 장신구 장착
- 해제
- 판매
- 교체

완료 결과:

- weapon / armor / accessory cycle 유지
- weapon / armor / accessory unequip 추가
- `ui_screens_runner.gd` pass
- `five_person_sortie_runner.gd` pass

메모:

- 판매는 아직 경제/통화 계층이 없어서 보류
- 현재 단계에서는 `관리 가능 상태`까지 달성
- `PopupMenu` 기반 직접 선택 UI까지 완료
- `equipment_direct_select_runner.gd` pass

### B3. 상태이상 시각화

상태:

- 1차 완료

목표:

- 망각 / 공포 / 표식 / 매혹 / DoT를 HUD 없이도 판독 가능하게 만듦

완료 결과:

- `SkillData`에 상태 메타데이터 필드/헬퍼 추가
- `UnitActor`에 상태 시각 컨텍스트 추가
- 보스 표식과 별개로 일반 `mark` 상태도 crosshair / aura / telegraph로 표출
- `oblivion / fear / charm / dot / mark`를 actor 레이어에서 직접 판독 가능하게 정리
- `fear`는 경미한 shake, `oblivion`은 저채도 보라 표면, `charm`은 적색 테두리, `dot`는 황색 경고 surface로 구분
- `status_visual_runner.gd` 추가 및 pass

## Queue C. 중기

### C1. CH06~CH10 컷신 콘텐츠

상태:

- 1차 완료

목표:

- CH06~CH10 전 스테이지의 intro/outro 컷신 공백 제거

완료 결과:

- `CutsceneCatalog`에 CH06~CH10 stage intro/outro 텍스트 컷신을 전부 연결
- `CH10_05`는 기존 최종 보스 인트로를 유지하고, 나머지 `CH06_01~CH10_04` 전 구간을 catalog 기반으로 채움
- 후반부 stage의 `start_cutscene_id` / `clear_cutscene_id` missing 0건 확인
- `ch10_shell_runner.gd` pass

### C2. CH06~CH10 보스 패턴

상태:

- 2차 완료

완료 결과:

- `CH08_05`
  - `berserk_rush` phase를 `lete_defects_alive` proxy flag와 연결
  - `lete_shadow_feint`, `lete_scatter_cover` 추가
  - `no_black_hound_casualties` runtime 유지/해제 연동
- `CH09A_05`
  - `formation_call` 진입 시 `karl_testifies` flag 실작동
- `CH09B_05`
  - `truth_rewrite / archive_mode`를 `melkion_truth_revealed`와 연결
  - `melkion_revision_field` / `melkion_revision_lock` 추가
  - `noah_survives`는 Noah runtime 부재 동안 no-casualty proxy로 유지
- `CH10_05`
  - name-call anchor spawn 시 파티 생존 조건 아래 `all_allies_name_called` flag 실작동
  - final Karuon 3-phase 체감 강화
    - `royal_edict`
    - `name_severance`
    - `final_toll`
- 전용 검증 러너 `lategame_boss_pattern_runner.gd` 추가 및 pass
- `support_namecall_pipeline_runner.gd` / `ch10_shell_runner.gd` 회귀 없음

### C3. 메타 시스템 완성

상태:

- 2차 완료

- 대장간
- 인챈트
- 재련

완료 결과:

- `ForgeService`
  - 후반 재료를 쓰는 제작 레시피 추가
    - `Valtor Command Lance`
    - `Keeper Root Staff`
    - `Eclipse Resonance Blade`
    - `Revision Guard Cloak`
    - `Bellward Plate`
    - `Tower Ward Signet`
- `ReforgeService`
  - 무료 장신구 보정 제거
  - 실제 재료를 소모하는 paid reforge 추가
- `경제/판매`
  - progression gold 저장 계층 추가
  - hunt gold 보상을 실제 gold로 커밋
  - 현재 장착 장비 판매 flow 추가
  - 미장착 보유 장비 판매 flow 추가
  - 인벤토리 스택 선택 popup 추가
  - 다중 인스턴스 ownership을 `xN / 미장착 / 장착` 라벨로 직접 표출
  - sale 결과를 캠프 인벤토리 로그에 기록
  - 판매 확인 다이얼로그 추가
- `CampaignController / CampaignPanel`
  - 장신구 보정 가능 여부를 재료 기준으로 판정
  - 보정 툴팁에 실제 소모 재료 표기
  - 보정 결과를 캠프 인벤토리 로그에 기록
- `CampaignPanel`
  - gold surface 추가
  - sell 버튼 추가
- 전용 검증 러너 `economy_sell_runner.gd` 추가 및 pass
- 전용 검증 러너 `meta_forge_runner.gd` 추가 및 pass
- `ui_screens_runner.gd` / `final_chapter_accessory_runner.gd` 회귀 없음

### C4. 회상 토벌전 시스템

상태:

- 2차 완료

완료 결과:

- `CampController`
  - progression의 `unlocked_hunt_ids`를 읽어 recall hunt snapshot 구성
  - `open_recall_tab()`, `select_hunt()`, `get_selected_hunt_stage_id()` 추가
- `CampData`
  - `recall_hunt_entries`, `selected_hunt_id` 추가
- `CampHud`
  - `recall` 탭에 실제 hunt 목록 연결
  - snapshot에 recall entry count / selected hunt id 추가
- `HuntBoardPanel`
  - backend `HuntBoard` 없이도 entry snapshot만으로 렌더 가능하도록 확장
  - unlocked/locked 상태, 권장 레벨, 보상 툴팁 표출
- 전용 검증 러너 `recall_hunt_runner.gd` 추가 및 pass
- `s3_camp_save_tab_runner.gd` / `camp_runner.gd` 회귀 없음
- `HUNT_BASIL / HUNT_SARIA / HUNT_LETE`
  - 실제 `StageData` resource 추가
  - `HuntStageRegistry` 추가
  - `CampController.launch_selected_hunt_battle()`로 실전투 bootstrap 연결
- `hunt reward`
  - `CampController.resolve_hunt_victory()` 추가
  - memory/evidence/cleared flag commit
  - gold를 실제 progression gold에 커밋
  - `CampaignPanel` 본 루프까지 reward/recall flow 통합
- 전용 검증 러너 `hunt_reward_runner.gd` 추가 및 pass
- 전용 검증 러너 `hunt_battle_runner.gd` 추가 및 pass

### C5. 진엔딩 컷신

상태:

- 2차 완료

완료 결과:

- `CampaignContentRegistry`
  - `CH10_TRUE_RESOLUTION_DIALOGUE` 추가
- `CutsceneCatalog`
  - `ch10_normal_resolution_cinematic`
  - `ch10_true_resolution_cinematic`
  추가
- `CampaignController`
  - true ending일 때 resolution summary/body/dialogue/cards가 일반 결말과 다르게 분기
  - 진엔딩 presentation cards를 3장으로 확장
- `Main`
  - true ending return-to-title overlay를 `True End / 모든 이름이 남다` 문구로 분기
  - title 복귀 전에 ending cutscene overlay 시퀀스를 자동 재생
- 전용 검증 러너 `true_ending_runner.gd` 추가 및 pass
- 전용 검증 러너 `ending_cinematic_runner.gd` 추가 및 pass
- `ch10_shell_runner.gd` / `ui_screens_runner.gd` 회귀 없음

## 현재 추천 순서

1. `endgame criteria` 추가 polish
2. `recall boss variant` 추가 심화
3. `autosave / postgame save-load` 추가 polish
4. `recall 전투` 추가 변주

## 지금 바로 시작할 작업

가장 먼저 시작할 작업은 `endgame criteria` 추가 polish다.

이유:

1. 세이브 슬롯 썸네일, autosave 전용 슬롯 분리, 엔드게임 기준 progress row/icon/pip/hint polish, postgame save/load 판독성 polish, autosave 추천 재개 지점 표시, recall stage/cinematic/card 변주, CH04/CH07 pressure 심화, recall boss variant 추가 심화는 현재 구현/검증이 끝났다.
2. 다음 남은 체감 가치는 엔드게임 기준 카드를 더 직관적인 표면으로 다듬는 것이다.
3. 현재 resolution panel, criteria payload, card styling 구조를 그대로 재사용할 수 있어 구현 리스크가 낮다.
