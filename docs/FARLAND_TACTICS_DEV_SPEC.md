# Farland Tactics — Development Specification
## 파랜드 택틱스 개발 스펙 & 구현 체크리스트

> **문서 버전:** v2.19  
> **작성일:** 2026-04-21  
> **프로젝트:** Memory Tactics RPG (잿빛의 기억)  
> **엔진:** Godot 4.6 / GDScript  
> **현재 완성도:** ~118%

---

## 1. 프로젝트 현황 요약

### 1.1 완료된 핵심 시스템

| 시스템 | 파일 | 상태 | 비고 |
|--------|------|------|------|
| 턴제 전투 엔진 | `battle_controller.gd` (2,275줄) | 완료 | Full Phase Loop |
| 유닛 이동/공격/상호작용 | `unit_actor.gd`, `path_service.gd`, `range_service.gd` | 완료 | |
| 전투 AI | `ai_service.gd` (175줄) | 완료 | 타겟 우선순위/경로 탐색 |
| 데미지 계산 파이프라인 | `combat_service.gd` (279줄) | 완료 | 명중/방어/카운터 |
| **상태이상 시스템** | `status_service.gd` (335줄) | 완료 | v2 새로 작성 |
| **스킬 사용 UI** | `BattleHUD.tscn`, `battle_hud.gd` | 완료 | 스킬 패널+타겟팅 |
| **보스 텔레그래프 시스템** | `battle_controller.gd` (확장) | 완료 | 멀티페이즈+텔레그래프 |
| **1장 오프닝 컷신** | `cutscene_catalog.gd`, `cutscene_player.gd` | 완료 | 8 비트 |
| 장비 시스템 | `weapon_data.gd`, `armor_data.gd`, `accessory_data.gd` | 완료 | 장착/스탯 반영 |
| 스테이지 데이터 | `stage_data.gd` + 30개 `.tres` 파일 | 완료 | 1~10장 스테이지 |
| 캠프 시스템 | `camp_controller.gd`, `camp_hud.gd` | 완료 | |
| 캠페인 진행 | `campaign_controller.gd`, `campaign_state.gd` | 완료 | |
| 세이브/로드 | `save_service.gd`, `save_load_panel.gd` | 완료 | 자동저장/추천 이어하기/엔드게임 기준 표면 포함 |
| 플래그 진행 명세 | `flag_progression_spec.md` (953줄) | 완료 | 설계만 |
| 컷신 시스템 | `cutscene_player.gd`, `cutscene_overlay.gd` | 완료 | 플레이어만 |
| 타이틀/패배/결과 UI | `title_screen.gd`, `defeat_screen.gd`, `battle_result_screen.gd` | 완료 | postgame summary / ending criteria 반영 |
| 오디오 라우팅 | `bgm_router.gd`, `audio_event_router.gd` | 완료 | |
| 인연(본딩) 시스템 | `bond_service.gd` | 1차 완료 | 지원 공격/피해 분담 포함 |

### 1.2 부분 구현 / 미완성

| 시스템 | 현재 상태 | 우선순위 |
|--------|-----------|----------|
| Bond 시스템 (지원 공격/피해 분담) | 3차 구현 완료, 캠프 handoff 대화 polish 반영 | 중간 |
| 인벤토리 UI | 장착/교체/해제/판매+스택 분할 UI 완료 | 중간 |
| 상태이상 유닛 비주얼 인디케이터 | 2차 완료, 전용 상태 배지 반영 | 낮음 |
| 2~10장 컷신 콘텐츠 | stage intro/outro 1차 완료 | 중간 |
| 스킬 데이터 개별 스킬 정의 | 핵심 플레이어 스킬 로드아웃 1차 완료 | 중간 |
| 2~10장 보스 패턴 확장 | 2차 완료, 후반 보스 3차 심화+전장 규칙 개정 1차 반영 | 중간 |
| 4장 수위 변화 / 7장 시민 구조 | 2차 runtime pressure 연동 완료 | 중간 |
| 정신 지배 / 유혹 대응 | 3차 charm restraint 대응 완료 | 중간 |
| 진엔딩 판정 로직 | 3차 구현 완료, 기준 카드/타이틀/세이브 표면 반영 | 중간 |
| 스킬 레벨업 / 성장 | 미구현 | 중간 |
| 회상 토벌전 시스템 | UI+실전투+reward+CampaignPanel 통합 2차 완료, boss/stage variant 3차 반영 | 낮음 |
| 경제/판매 계층 | gold 저장+다중 인스턴스 ownership+판매 확인 3차 완료 | 중간 |

---

## 2. 구현 체크리스트

체크 박스 표기: `[ ]` 미구현 / `[S]` 부분 구현 / `[D]` 완료(설계만) / `[X]` 완료(동작)

---

### 2.1 코어 전투 (Priority: 높음)

- [X] **전투 컨트롤러 Phase Loop** — `battle_controller.gd`
  - [X] 플레이어 페이즈 / 적 페이즈 전환
  - [X] 턴 매니저 연동
  - [X] 전투 종료 판정 (승리/패배)
  - [X] Phase transition history 로깅
  - [X] Viewport 리사이즈 대응

- [X] **유닛 시스템** — `unit_actor.gd`
  - [X] 이동 / 공격 / 상호작용
  - [X] 그리드 위치 관리
  - [X] HP / 스탯 관리
  - [X] 선택/비선택 비주얼 상태
  - [X] 상태이상 비주얼 인디케이터 1차 (망각/공포/표식/매혹/DoT)

- [X] **AI 서비스** — `ai_service.gd`
  - [X] 기본 타겟팅 우선순위
  - [X] 경로 탐색 + 이동+공격 계획
  - [X] 위협도 기반 점수 매기기
  - [X] 보스 패턴별 AI 확장 1차 (2~10장 주요 보스)

- [X] **데미지 계산** — `combat_service.gd`
  - [X] 명중 판정 (망각 accuracy 패널티)
  - [X] 방어 계산 (지형 보정)
  - [X] 피해 적용
  - [X] 카운터 어택
  - [X] 상태이상 적용 (스킬 기반 / 적 타입 기반)

---

### 2.2 상태이상 시스템 (Priority: 높음)

- [X] **StatusService** — `status_service.gd` (335줄)
  - [X] 망각(Oblivion) — 스택 중첩, 명중/회피 패널티, 3스택 스킬 봉인
  - [X] 공포(Fear) — 이동 제한
  - [X] 표식(Mark) — 집중 공격 대상
  - [X] 매혹(Charm) — 아군 오인
  - [X] 지속 피해(DoT) — 턴 종료 시 피해
  - [X] 상태이상 등록/제거/중첩/지속시간 관리
  - [X] 턴 시작/종료 틱 처리
  - [X] 세린 클린스 스킬 연동 (`cleanse_stack` API)
  - [X] 텔레메트리 로깅

- [S] **CombatService 상태이상 연동**
  - [X] 스킬 기반 상태이상 적용
  - [X] 적 타입 망각 적용 (`applies_oblivion` 플래그)
  - [X] 망각 accuracy 패널티 → `_step_hit_check` 반영
  - [ ] 상태이상 해제 스킬 (세린 등) — **TODO**

- [X] **유닛 비주얼 인디케이터** — 1차 완료
  - [X] 망각: 저채도/보라 계열 surface
  - [X] 공포: shake + 색상 변화
  - [X] 표식: crosshair / aura / telegraph
  - [X] 매혹: 적색 계열 테두리
  - [X] DoT: 황색 경고 surface
  - [ ] 전용 아이콘/모자이크 아트 polish — 후속

---

### 2.3 스킬 시스템 (Priority: 높음)

- [X] **스킬 데이터** — `skill_data.gd`
  - [X] `applies_status()`, `get_status_type()`, `get_status_stacks()`
  - [X] `status_chance`, `range`, `power_modifier`
  - [S] 개별 스킬 리소스 — 다수 구현, 일부 대표 스킬 후속 필요

- [X] **스킬 사용 UI** — `BattleHUD.tscn` + `battle_hud.gd`
  - [X] 스킬 패널 (4슬롯 GridContainer)
  - [X] 토글 방식 열기/닫기
  - [X] 망각 3스택 시 스킬 비활성화
  - [X] 스킬 슬롯별 툴팁 (사거리/위력/상태이상)
  - [X] SKILL 버튼 → 패널 오픈
  - [X] MP/SP 소모 surface 1차
  - [X] MP/SP 실제 차감 2차

- [X] **스킬 타겟팅 로직** — `battle_controller.gd`
  - [X] 스킬 선택 → 사거리 highlight
  - [X] 타겟 지정 → `combat_service.resolve_attack(skill=)`
  - [X] 스킬 예고(telegraph) 연동

- [S] **대표 플레이어 스킬 로드아웃**
  - [X] 리안: `tactical_shift` (위치 교환+버프)
  - [X] 리안: `collapse_line` (직선 압박+망각 부여)
  - [X] 리안: `command_marker` (집중 공격 표식)
  - [X] 세린: `ark_breath` (단일/소범위 회복)
  - [X] 세린: `never_forget` (망각 해제+저항)
  - [X] 브란: `iron_wall` (아군 대타 축)
  - [X] 티아: `pin_shot` (공포/이동 압박)
  - [X] 에녹: `memory_burn` (광역 망각 마법)
  - [X] 카일: `comet_charge` (돌격 고위력)
  - [ ] remaining support/tactical specialization polish

---

### 2.4 보스 패턴 시스템 (Priority: 높음)

- [X] **멀티페이즈 시스템** — `battle_controller.gd`
  - [X] HP% 임계값 → 페이즈 전환 (`boss_phase_thresholds`)
  - [X] `_check_boss_phase_transitions()` — 매 적 페이즈 시작 시 체크
  - [X] `_apply_boss_phase_effects()` — 페이즈 전환 비주얼 (flash/FX)
  - [X] `_apply_boss_phase_bonuses()` — ATK/MOV 버프

- [X] **텔레그래프 시스템** — `battle_controller.gd` (확장)
  - [X] `_queue_telegraph()` — 공격 예고 등록
  - [X] `_process_telegraphs_at_enemy_phase_start()` — 카운트다운 관리
  - [X] `_resolve_telegraph_entry()` — 효과 적용 (피해+상태)
  - [X] `_get_telegraph_cells_for_pattern()` — 패턴별 셀 계산
  - [X] `_pick_boss_telegraph_action()` — 보스 행동 선택

- [X] **텔레그래프 그리드 비주얼** — `grid_cursor.gd` (확장)
  - [X] `set_telegraph_cells()` — 적색 펄싱 하이라이트
  - [X] `clear_telegraph_cells()` — 클린업

- [X] **텔레그래프 HUD 카드** — `battle_hud.gd` (확장)
  - [X] `boss_telegraph_pending` — 경고 카운트다운 표시
  - [X] `boss_telegraph_queued` — 새 텔레그래프 예고

- [X] **1장 보스 (Roderic) 패턴** — `enemy_roderic.tres`
  - [X] Normal: `boss_mark` → `boss_charge` 2턴 사이클
  - [X] Phase 1 (50% HP): `enrage` → `charge_row` 텔레그래프
  - [X] Phase 2 (25% HP): `despair` → `cross` 텔레그래프

- [S] **2장 보스 (발가르) 패턴** — `enemy_valgar.tres`
  - [X] Fortification 1차
  - [X] Phase 2 wall-breaker 흐름
  - [X] Phase 3 final-stand 버프
  - [ ] 포대 점령/외벽 파괴 심화

- [S] **3장 보스 (바실) 패턴** — `enemy_basil.tres`
  - [X] 정화 제단 purge 1차
  - [X] flooded-section 생존 objective 1차 runtime 연동
  - [X] altar purge -> flood rise 2차 pressure 연동

- [S] **4장 보스 (사리아) 패턴** — `enemy_saria.tres`
  - [X] 망각 장판 생성
  - [X] prayer dais / city seal objective 연동
  - [X] city seal + prayer dais -> `recruit_mira` 1차 runtime 연동
  - [X] civilian pressure / queue loss 2차 runtime 연동

- [S] **5장 보스 패턴**
  - [X] 화재 / 붕괴 타일 1차
  - [X] ledger collapse objective 연동
  - [ ] 턴 제한 압박 심화

- [S] **6장 보스 (발가르/도른 관련) 패턴**
  - [X] 요새 제단 / 저항 0 objective 연동
  - [ ] 포대 점령 / 외벽 파괴 심화

- [S] **7장 보스 (사리아) 패턴 확장**
  - [X] city seal / prayer dais objective 연동
  - [X] `recruit_mira` objective 1차 runtime 연동
  - [X] civilian pressure timer / Mira failure state 2차 runtime 연동
  - [X] charm forced-action 1차 runtime 연동
  - [X] `mind_control` phase -> `charm_gaze` 2차 runtime 연동
  - [X] bond-5 charm restraint 3차 대응 연동

- [S] **8장 보스 (레테) 패턴** — `enemy_lete.tres`
  - [X] smoke bomb / berserk rush 1차
  - [X] `lete_defects_alive` proxy 연동
  - [X] `lete_shadow_feint`, `lete_scatter_cover`
  - [X] `lete_black_hound_execute` 3차 압박 추가
  - [X] `berserk_rush` shadow pursuit lane rewrite
  - [X] `transfer_gate_latch` 상호작용 relief
  - [X] gate latch 2차: mark/fear pressure 해제
  - [X] gate latch 3차: execute 압박을 다시 표식 준비 단계로 강등
  - [X] gate latch 4차: 이동 보너스/연막 쿨다운 약화
  - [X] gate latch 5차: objective-state flag 강화
  - [X] gate latch 6차: phase rewrite dampening
  - [X] gate latch 7차: route-cut HUD transition surface
  - [X] gate latch 8차: relief objective hint rewrite
  - [X] gate latch 9차: relief objective text rewrite
  - [X] gate latch 10차: inventory objective line rewrite
  - [X] gate latch 11차: result summary relief entry
  - [X] gate latch 12차: result popup relief section
  - [X] gate latch 13차: objective_state relief id
  - [ ] 은신 / 암살 표식 / 분신 심화

- [S] **9A 보스 (바르텐) 패턴** — `enemy_barten.tres`
  - [X] Kyle line / shield wall / formation call 1차
  - [X] `karl_testifies` 연동
  - [ ] 삭제 구역 / 감찰 친위대 심화

- [S] **9B 보스 (멜키온) 패턴** — `enemy_melkion.tres`
  - [X] truth rewrite / memory wipe / archive mode 1차
  - [X] `melkion_truth_revealed` 연동
  - [X] `melkion_revision_field`, `melkion_revision_lock`
  - [X] `melkion_revision_sentence` 3차 압박 추가
  - [X] `archive_mode` revision terrain rewrite
  - [X] `archive_lectern` 상호작용 relief
  - [X] lectern 2차: revision mark/terrain pressure 해제
  - [X] lectern 3차: archive revision loop 약화
  - [X] lectern 4차: rewrite/setup cooldown lock
  - [X] lectern 5차: archive stabilized objective-state flag
  - [X] lectern 6차: central revision rewrite dampening
  - [X] lectern 7차: archive-stable HUD transition surface
  - [X] lectern 8차: stabilized objective hint rewrite
  - [X] lectern 9차: stabilized objective text rewrite
  - [X] lectern 10차: inventory objective line rewrite
  - [X] lectern 11차: result summary relief entry
  - [X] lectern 12차: result popup relief section
  - [X] lectern 13차: objective_state relief id
  - [ ] 전장 규칙 개정 심화

- [S] **10장 보스 (카르온) 패턴** — `enemy_karuon.tres`
  - [X] Phase 1: 왕의 칙령
  - [X] Phase 2: 마지막 이름 / name-call anchor
  - [X] Phase 3: `final_toll`
  - [X] `all_allies_name_called` proxy 연동
  - [X] `karon_bell_of_erasure` 3차 압박 추가
  - [X] `name_severance` bell pressure lane rewrite
  - [X] `anchor_chain` 상호작용 relief
  - [X] anchor chain 2차: bell mark/bond suppression 해제 + AI 약화
  - [X] anchor chain 3차: final_toll 우선도 약화
  - [X] anchor chain 4차: name_severance/final_toll cooldown lock + cut_off flag
  - [X] anchor chain 5차: final control objective-state 강화
  - [X] anchor chain 6차: bell lane rewrite dampening
  - [X] anchor chain 7차: bell-line HUD transition surface
  - [X] anchor chain 8차: opened-line objective hint rewrite
  - [X] anchor chain 9차: opened-line objective text rewrite
  - [X] anchor chain 10차: inventory objective line rewrite
  - [X] anchor chain 11차: result summary relief entry
  - [X] anchor chain 12차: result popup relief section
  - [X] anchor chain 13차: objective_state relief id
  - [ ] 종의 공명 심화

---

### 2.5 컷신 시스템 (Priority: 높음)

- [X] **컷신 플레이어** — `cutscene_player.gd`
  - [X] `play()`, `next_scene()`, `skip()`
  - [X] 비트 타입 핸들링 (text_card, black_screen, shake, battle_transition)

- [X] **컷신 오버레이** — `CutsceneOverlay.tscn`
  - [X] Panel + VBoxContainer + Label 구조

- [X] **1장 오프닝 컷신** — `cutscene_catalog.gd` + `tutorial_stage.tres`
  - [X] 8 비트 구성 (총 21.5초)
  - [X] CutsceneCatalog 등록 (`ch01_opening`)
  - [X] 튜토리얼 스테이지와 연동

- [X] **1장 컷신 추가**
  - [X] `ch01_05_intro`
  - [X] `ch01_05_outro`

- [S] **2장 컷신**
  - [X] stage intro/outro 1차
  - [ ] 회상/합류 심화 컷신

- [S] **3장 컷신**
  - [X] stage intro/outro 1차
  - [ ] 티아 합류 심화 컷신

- [S] **4장 컷신**
  - [X] stage intro/outro 1차
  - [ ] 수도원 침수 / 사리아 첫 등장 심화

- [S] **5장 컷신**
  - [X] stage intro/outro 1차
  - [ ] 에녹 합류 심화 컷신

- [S] **6장 컷신**
  - [X] stage intro/outro 1차
  - [ ] 도른 구출 심화 컷신

- [S] **7장 컷신**
  - [X] stage intro/outro 1차
  - [ ] 네리/미라 재등장 심화 컷신

- [S] **8장 컷신**
  - [X] stage intro/outro 1차
  - [ ] 레테 첫 등장 심화 컷신

- [S] **9A 컷신**
  - [X] stage intro/outro 1차
  - [ ] 카일 충성 붕괴 / 바르텐 결전 심화

- [S] **9B 컷신**
  - [X] stage intro/outro 1차
  - [ ] 노아/멜키온 / 최종 기억 복원 심화

- [S] **10장 컷신**
  - [X] stage intro/outro 1차
  - [X] 일반 결말 summary / presentation / overlay
  - [X] 진엔딩 summary / presentation / overlay
  - [X] 카르온 3페이즈 전환 시네마틱 심화

---

### 2.6 인벤토리 / 장비 시스템 (Priority: 높음)

- [X] **장비 데이터** — `weapon_data.gd`, `armor_data.gd`, `accessory_data.gd`
  - [X] 무기/방어구/악세사리 정의 구조
  - [X] 유닛 스탯 반영

- [X] **인벤토리 UI 열기/닫기** — `battle_hud.gd`
  - [X] InventoryPanel 표시
  - [X] 파티 목록 / 인벤토리 목록

- [S] **장비 슬롯 관리**
  - [X] 무기 슬롯 UI
  - [X] 방어구 슬롯 UI
  - [X] 악세사리 슬롯 UI
  - [X] 슬롯 간 장비 교체(순환)
  - [X] 장비를 풀 장비 목록에서 직접 선택 (`PopupMenu`)

- [S] **장비 해제 / 판매**
  - [X] 장비 해제 버튼
  - [X] 현재 장착 장비 판매
  - [X] 미장착 보유 장비 판매
  - [X] 판매 확인 대화상자

---

### 2.7 인연 (Bond) 시스템 (Priority: 높음)

- [S] **BondService** — `bond_service.gd`
  - [X] 인접 아군 감지
  - [X] Bond 레벨 관리 (0~5)
  - [X] Bond 3+ → 지원 공격
  - [X] Bond 5 → 피해 분담
  - [X] 결과 화면 support rank-up 대화
  - [X] HUD support rank-up 연출 surface
  - [X] 캠프 handoff support 대화 잔류
  - [X] 캠프 handoff support presentation card
  - [X] CH10 resolution name-call presentation card
  - [X] support/name-call dedicated card style + badges
  - [X] support quote / name-call callout surface
  - [X] support/name-call memory stamp surface
  - [X] support/name-call progress row surface
  - [X] support/name-call outcome line surface
  - [X] support/name-call source label surface
  - [X] support/name-call eyebrow label surface
  - [X] support/name-call memory rail surface
  - [X] support/name-call memory stack snapshot
  - [X] support/name-call expanded memory stack
  - [X] support/name-call memory signature
  - [S] Bond 컷신/대화 연동

- [S] **Bond 버프 시각화**
  - [X] support-ready / guard-ready 전장 시각화
  - [X] 지원 공격 FX
  - [X] 피해 분담 FX
  - [X] Bond 레벨별 연결선

- [S] **공명 인장 시스템** — `flag_resonance_*` 플래그
  - [X] 6인 공명 인장 획득 상태를 엔딩 판정/세이브 메타데이터에 반영
  - [X] 10장 최종전 이름 부름 / 앵커 proxy와 연동
  - [ ] 전투 중 실효과/연출 심화

---

### 2.8 캠페인 / 진행 시스템 (Priority: 중간)

- [X] **CampaignController** — `campaign_controller.gd`
  - [X] 챕터 셀렉트
  - [X] 스테이지 순차 진행

- [X] **플래그 시스템** — `flag_progression_spec.md`
  - [X] 설계 명세 완료 (953줄)
  - [X] `StageResolutionService` 실제 구현
  - [X] `EndingResolver` 구현

- [S] **메타 시스템 해금 순서**
  - 2장: inventory, accessory
  - 3장: armor
  - 4장: hunt_board
  - 5장: salvage, sigil_ledger
  - 6장: forge
  - 7장: sigil_tuning
  - 9B: select_craft, affix_calibration

---

### 2.9 회상 토벌전 시스템 (Priority: 낮음)

- [S] **회상 토벌전 해금** — `unlocked_hunt_ids`
  - [X] HuntBoard / recall UI 1차
  - [X] 바실 토벌전 battle stage bootstrap
  - [X] 사리아 토벌전 battle stage bootstrap
  - [X] 레테 토벌전 battle stage bootstrap
  - [X] 회상 토벌전 전용 결과/보상 회수 흐름 1차
  - [X] `CampaignPanel` 본 루프까지 reward/recall flow 통합
  - [X] 금화 보상 실제 저장
  - [X] 귀환 보고 / 보상 정산 카드 2차
  - [X] hunt별 optional objective / pressure variant 4차
  - [X] hunt별 evidence / materials / gold 변주 3차
  - [X] hunt Basil `backwash_surge` 후속 압박
  - [X] hunt Saria `choir_break` 후속 압박
  - [X] hunt Lete marked-target execute 우선화
  - [X] hunt별 추가 적 1기 / 차단선 / 지형 변주 1차
  - [X] hunt별 상호작용 오브젝트 1개 / 규칙 분기 1차
  - [X] hunt return summary / reward / cutscene override 분기 1차
  - [X] hunt branch presentation card 2차
  - [X] selected hunt / stage brief branch reflection 3차
  - [X] return eyebrow / title / 후일담 title branch reflection 4차
  - [X] branch/control memory stamp surface 5차
  - [X] branch/control progress row surface 6차
  - [X] branch/control outcome line surface 7차
  - [X] branch/control source label surface 8차
  - [X] branch/control eyebrow label surface 9차
  - [X] branch/control memory rail surface 10차
  - [X] branch/control memory stack snapshot
  - [X] branch/control expanded memory stack
  - [X] branch/control memory signature

---

### 2.10 엔딩 시스템 (Priority: 중간)

- [S] **엔딩Resolver**
  - [X] 일반 엔딩 조건 판정
  - [X] 진엔딩 조건 판정 (6인 공명 인장 + 이름 앵커 2+ proxy + 6인 이름 부름 기준)
  - [X] 엔딩 컷신/표면 분기 1차
  - [X] 6인 공명 인장 + 이름 앵커 + 이름 부름 기준으로 재정렬
  - [X] CH10 resolution criteria card / progress row / hint 표면 추가
  - [X] title postgame summary에 기준 진행도 노출
  - [X] save/load metadata에 공명/앵커/이름부름 진행도 노출

- [S] **일반 엔딩 컷신**
  - [X] summary / presentation / overlay 1차
  - [X] ending cinematic overlay 18차
  - [X] end credits / postgame title surface 18차
  - [ ] 리안 희생 장면
  - [S] 엔드 크레딧 롤

- [S] **진엔딩 컷신**
  - [X] summary / presentation / overlay 1차
  - [X] ending cinematic overlay 18차
  - [X] end credits / postgame title surface 18차
  - [ ] 동료들과 함께하는 장면
  - [S] 진엔드 크레딧

---

### 2.10A 경제 / 판매 시스템 (Priority: 중간)

- [S] **경제 저장 계층**
  - [X] `ProgressionData.gold`
  - [X] save/load metadata에 gold 반영
  - [X] hunt gold 보상을 실제 gold로 커밋

- [S] **판매 시스템**
  - [X] 현재 장착 장비 판매
  - [X] 미장착 보유 장비 판매
  - [X] 판매 시 gold 증가
  - [X] 판매 시 ownership 제거 + 장착 해제
  - [X] 판매 결과를 캠프 인벤토리 로그에 기록
  - [X] 판매 확인 다이얼로그
  - [X] 다중 인스턴스 ownership 기반 판매
  - [X] 동일 무기 2개 보유 -> 2인 동시 장착 계약
  - [X] 장비별 스택 분할 UI

---

### 2.11 UI/UX 개선 (Priority: 중간)

- [ ] **전투 HUD 개선**
  - [X] 상태이상 배지 (유닛 머리 위)
  - [ ] 망각 스택 수 표시
  - [ ] 스킬 MP/SP 소모
  - [ ] 버프/디버프/Duration 카운트다운

- [S] **상태이상 판독성 polish**
  - [X] 색/telegraph text 기반 primary status 표면
  - [X] 유닛 머리 위 전용 상태 배지 (`망/공/유/지/표/MK`)
  - [X] 전용 상태 아이콘 텍스처 1차 확장
  - [X] 전용 상태 아이콘 소형 아트 고도화
  - [X] 상태 배지/telegraph pulse 1차
  - [X] 상태별 pulse profile 2차
  - [X] 상태별 idle animation profile 3차
  - [X] 상태별 sustained accent cadence 4차
  - [X] 상태 해제 release profile 5차
  - [X] telegraph text shimmer 6차
  - [X] nameplate drift 7차
  - [X] telegraph icon drift 8차
  - [X] badge-text shimmer 9차
  - [X] status motion stack snapshot 10차
  - [X] status afterglow 11차
  - [X] afterglow motion stack surface 12차
  - [X] status motion signature 13차

- [S] **세이브/로드 UI 개선**
  - [X] 슬롯별 썸네일
  - [X] 진행도 표시
  - [X] 자동 세이브
  - [X] 자동저장 전용 카드
  - [X] 최신 저장 기반 추천 이어하기
  - [X] 엔드게임 기준(공명/앵커/이름부름) 메타데이터 노출
  - [X] postgame title summary / 기준 저장 source 표면

- [ ] **캠프 UI 개선**
  - [ ] 장비 관리 탭
  - [ ] 스킬 확인 탭
  - [ ] 대화 이력

---

### 2.12 테스트 / 품질 관리 (Priority: 중간)

- [ ] **단위 테스트**
  - [X] SkillLevelUpService headless 스위트
  - [X] CombatService headless 스위트
  - [X] StatusService headless 스위트
  - [X] AIService headless 스위트

- [X] **'intégration 테스트`**
  - [X] 1장 튜토리얼 엔드투엔드 (`scripts/dev/ch01_tutorial_e2e_runner.gd`)
  - [X] main save/load + battle core-loop 재개 러너
  - [X] autosave defeat recovery 러너
  - [X] defeat retry recovery 러너
  - [X] title load panel selection 러너
  - [X] manual save recovery 러너
  - [X] NG+ title start + save/load recovery 러너
  - [X] NG+ autosave defeat recovery 러너
  - [X] NG+ visible title load-panel selection 러너
  - [X] NG+ visible recommended-load selection 러너
  - [X] CampaignPanel save-panel roundtrip 러너
  - [X] CampaignPanel save-load core-loop roundtrip 러너
  - [X] defeat->title->load-panel roundtrip 러너
  - [X] NG+ visible defeat->title->load roundtrip 러너
  - [X] campaign save->title->load roundtrip 러너
  - [X] campaign save->defeat->title->load roundtrip 러너
  - [X] NG+ visible campaign save->title->load roundtrip 러너

- [X] **파랜드 택틱스 벤치마크**
  - [X] 코어 루프 성능 측정 (`scripts/dev/core_loop_perf_runner.gd`)
  - [X] AI 의사결정 시간 측정 (`scripts/dev/ai_decision_perf_runner.gd`)

---

## 3. 파일별 개발 우선순위

### 즉시 (1~2주)
1. Bond 전용 컷신/연출 14차 심화
2. recall 전투 추가 컷신/보상 분기 14차
3. 상태 표면 애니메이션 14차 심화

### 단기 (3~4주)
4. 엔딩 전용 비주얼/전환 15차 심화
5. save/load 및 core-loop 통합 테스트 15차 확장
6. 후반 보스 추가 규칙/오브젝트 16차 심화
6. save/load 및 core-loop 통합 테스트 15차 확장

### 중기 (5~8주)
7. 인챈트 / 재련 데이터 모델 확장
8. 캠프 UI 개선
13. 코어 루프 성능 계측

---

## 4. 문서 참조

| 문서 | 경로 | 용도 |
|------|------|------|
| 시놉시스 | `synopsis.md` | 스토리/캐릭터/보스 설계 |
| 플래그 진행 명세 | `flag_progression_spec.md` | 플래그/저장/분기 설계 |
| 9-1장 구현 문서 | `phase9-1.md` | 9A 장 구조/전투 설계 |
| 1장 구현 문서 | `phase1.md` (참조) | 튜토리얼 설계 |
