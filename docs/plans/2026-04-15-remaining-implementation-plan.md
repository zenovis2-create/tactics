# Remaining Implementation Plan

*작성: 2026-04-15 | 대상: 출시 전 미완성 시스템 전체*

> **읽는 법:** 각 섹션은 독립적으로 착수할 수 있다.
> 단, 의존 관계가 있는 경우 `requires:` 태그로 표시했다.
> 체크박스는 완료 시 체크한다.

---

## 1. 망각(망각) 스택 실제 발동

**목표:** 적 AI가 망각 스택을 실제로 적용하고, CombatService 명중 판정이 accuracy_mod를 반영한다.

**연관 파일:**
- `scripts/battle/ai_service.gd`
- `scripts/battle/combat_service.gd`
- `scripts/battle/battle_controller.gd`
- `scripts/battle/status_service.gd`

**설계 규칙:**
- 망각을 적용하는 적은 특정 역할(Eroder 유형)만 — 모든 적이 쌓으면 게임이 무너진다
- 스택 1: accuracy -5%, 스택 2: accuracy -10% evasion -5%, 스택 3: 스킬 봉인
- 히트 판정: `_step_hit_check`가 `oblivion_accuracy_mod`를 읽어서 RNG 없이 threshold 기반 결정
- 스택 상태는 HUD에 표시되어야 한다 (stack badge on unit token)

### 체크리스트

#### 1-A. 적 AI 망각 적용
- [x] `ai_service.gd`에 `ACTION_APPLY_OBLIVION` 액션 타입 추가 *(BattleController에서 인터셉트 방식으로 구현)*
- [x] `_pick_enemy_action()`에서 Eroder 유형 적이 대상을 골라 망각 적용 선택하는 로직 작성
- [x] `battle_controller.gd`의 `_apply_enemy_action()`에서 `apply_oblivion` 처리 — `status_service.apply_stack()` 호출
- [x] 적 데이터(`unit_data.gd`)에 `applies_oblivion: bool` 필드 추가
- [x] 테스트용 적 unit_data 리소스 1개에 `applies_oblivion = true` 설정 *(enemy_skirmisher.tres)*

#### 1-B. CombatService 명중 판정
- [x] `combat_service.gd`의 `_step_hit_check()`에 `context["oblivion_accuracy_mod"]` 읽기 추가
- [x] 명중 판정 로직: `hit_chance = 100 + oblivion_accuracy_mod` → threshold ≤ 0 이면 miss (결정론적)
- [x] miss 시 `reason = "oblivion_accuracy_zero"` 반환

#### 1-C. HUD 망각 표시
- [x] `battle_hud.gd`에 선택 유닛 이름에 `[망각 ×N]` 배지 표시 (0이면 숨김)
- [x] `get_layout_snapshot()`에 `oblivion_badge_visible` 키 포함

#### 1-D. 텔레메트리 연결
- [x] `apply_stack()` 호출 시 `telemetry_service.record_oblivion_applied(amount)` 호출
- [x] cleanse는 향후 healer 구현 시 연결 *(record_oblivion_cleansed 메서드 준비 완료)*

#### 1-E. 러너 업데이트
- [x] `status_oblivion_runner.gd` 신규 작성 — 8개 어서션 PASS
- [x] `bash scripts/dev/check_runnable_gate0.sh` PASS
- [x] `m3_ui_runner.gd` PASS (oblivion_applied=2 텔레메트리 확인됨)

---

## 2. 캠프 허브 (Camp Hub)

**목표:** 전투 사이에 편성, 장비, 기록(기억/물증/편지)을 확인하고 다음 전투를 준비하는 화면.

**연관 스펙:** `camp_ui_spec.md`, `camphub-records-m2-design.md`, `battle-camp-meta-ux-design.md`

**연관 파일:**
- `scripts/` 새 파일: `camp/camp_controller.gd`, `camp/camp_data.gd`
- `scenes/` 새 파일: `camp/CampScene.tscn`, `camp/CampHUD.tscn`
- `scripts/main.gd` (씬 전환 연결)

**설계 규칙 (camp_ui_spec.md 기준):**
- 캠프 진입 순서: 보상 팝업 → 기억 조각/물증 획득 연출 → 영입 연출 → 허브 자유 탐색
- 메인 허브 7개 축: 편성 / 장비 / 창고 / 분해 / 회상토벌 / 대장간 / 기록
- 모바일 우선: 드래그 없음, 바텀시트, 한 화면에 정보 과부하 금지
- UI는 계산 안 하고 표시만 — 모든 계산은 서비스 레이어

### 체크리스트

#### 2-A. 데이터 레이어
- [x] `scripts/data/camp_data.gd` — 캠프 상태 리소스 (해금된 기능, 현재 챕터, 보류 중인 알림)
- [x] `scripts/camp/camp_controller.gd` — 캠프 진입 흐름 오케스트레이터
  - `enter_camp(stage_clear_result: Dictionary)` — 보상/기억 시퀀스 → 허브
  - `get_camp_summary()` — 편성/장비/기록 상태 스냅샷 반환

#### 2-B. 씬 구조
- [x] `scenes/camp/CampScene.tscn` 생성 — 최소 구조: 배경, CampHUD, 씬 루트
- [x] `scenes/camp/CampHUD.tscn` 생성 — 7개 탭 버튼 + 선택된 패널 영역
- [x] `scripts/camp/camp_hud.gd` — 탭 전환, 활성 패널 표시/숨김

#### 2-C. 편성 패널 (Sortie)
- [x] 현재 출격 가능한 동료 목록 표시 (CampaignPanel Party 섹션과 연동)
- [ ] 동료 선택/해제 UI (최대 출격 인원 표시) *(CampaignPanel에서 처리, 추가 UI 추후)*
- [x] 편성 확정 → 다음 스테이지에 반영되는 저장 흐름 (CampaignController 기존 구조)

#### 2-D. 기록 패널 (Records)
- [x] 기억(memory) 목록 — CampData.pending_memory_entries (ProgressionData 연동)
- [x] 물증(evidence) 목록 — CampData.pending_evidence_entries
- [x] 편지(letters) 목록 — CampData.pending_letter_entries
- [ ] 각 항목 탭 시 상세 텍스트 바텀시트 표시 *(미래 UI 작업)*

#### 2-E. 씬 전환 연결
- [x] CampaignController._enter_camp_state()에서 CampController.enter_camp() 호출
- [ ] main.gd 씬 전환 (현재 오버레이 방식으로 동작 중; 별도 씬 전환은 추후)

#### 2-F. 검증
- [x] `camp_runner.gd` 8개 어서션 PASS
- [x] Gate 0 PASS 확인

---

## 3. 컷씬 / 기억 연출

**목표:** 챕터 시작/종료 컷씬, 기억 조각 표면화 애니메이션을 재생하는 시스템.

**연관 스펙:** `memory_fragments.md`, `trailer-beat-sheets.md`

**연관 파일:**
- 새 파일: `scripts/cutscene/cutscene_player.gd`, `scripts/cutscene/cutscene_data.gd`
- `scripts/data/stage_data.gd` — `start_cutscene_id`, `clear_cutscene_id` 필드 이미 있음
- `scripts/battle/progression_service.gd` — fragment 회수 후 연출 트리거

**설계 규칙:**
- 컷씬 = 텍스트 카드 시퀀스 + 선택적 이미지 (production art 없어도 텍스트만으로 작동)
- 기억 조각 연출 = 전용 오버레이 애니메이션 (검은 화면 → fragment 번쩍임 → 커맨드 해금 메시지)
- 스킵 가능해야 함 (모든 컷씬에 스킵 버튼)
- 내용은 `data/cutscenes/` 디렉토리의 리소스 파일로 외부화

### 체크리스트

#### 3-A. 데이터 구조
- [x] `scripts/cutscene/cutscene_data.gd` — beat 기반 컷씬 리소스 (text_card/fragment_flash/command_unlock/black_screen)
- [x] `data/cutscenes/` 디렉토리 + `cutscene_catalog.gd` (코드 기반 팩토리)
- [x] CH01 start/clear 컷씬 + fragment_flash 리소스 3개 작성

#### 3-B. 플레이어 구현
- [x] `scripts/cutscene/cutscene_player.gd` — play() / skip() / advance_beat_immediate() / get_snapshot()
- [x] `scenes/cutscene/CutsceneOverlay.tscn` — 전체화면 오버레이 씬

#### 3-C. 기억 조각 전용 연출
- [x] `fragment_flash` beat 타입 처리 — 이벤트 로그에 기록
- [x] `command_unlock` beat 타입 처리
- [x] BattleController._on_battle_victory()에서 fragment_flash 연출 트리거 연결
- [ ] 연출 중 입력 차단 *(UI 레이어 작업, 추후)*

#### 3-D. 배틀/캠프 흐름 연결
- [x] `_on_battle_victory()`에서 `stage_data.clear_cutscene_id` → CutsceneCatalog.get_cutscene() → play()
- [x] BattleController에 cutscene_player 서비스 추가 (_init_meta_services)
- [ ] `start_cutscene_id` 전투 전 재생 *(추후)*

#### 3-E. 검증
- [x] `cutscene_runner.gd` 8개 어서션 PASS
- [x] Gate 0 PASS 확인

---

## 4. 동료별 Bond 레벨

**목표:** 6인 동료 각각의 신뢰 레벨(0-5)을 추적하고, 인접 지원 공격/데미지 공유/상태 저항을 실제로 발동한다.

**연관 스펙:** `storefront-metadata-variants.md` (bond system 언급), `systems-execution-backlog.md` (Trust SYS-014)

**연관 파일:**
- 새 파일: `scripts/battle/bond_service.gd`, `scripts/data/bond_data.gd`
- `scripts/battle/progression_service.gd` — Trust 밴드와 연동
- `scripts/battle/battle_controller.gd` — 지원 공격 발동

**설계 규칙 (스토어 설명 + 시스템 백로그 기준):**
- Bond 레벨 0-5: 각 레벨은 개인 아크 완료 조건과 연결
- Bond 3 이상: 인접 시 지원 공격 발동 가능
- Bond 5: 최종 보스 Name Anchor 조건 참여 가능
- 6인: Serin, Bran, Tia + 나머지 3인 (마스터 캠페인 아웃라인 참조)
- Trust(ProgressionService) = 전체 팀 평균 bond의 함수 — 개별 bond가 선행

### 체크리스트

#### 4-A. 데이터 레이어
- [ ] `scripts/data/bond_data.gd` — 동료별 bond 리소스
  - `companion_id: StringName`
  - `bond_level: int` (0-5)
  - `arc_flags_required: Array[StringName]` — 이 아크 플래그가 충족되어야 다음 레벨
- [ ] `scripts/battle/bond_service.gd`
  - `get_bond(companion_id) -> int`
  - `apply_bond_delta(companion_id, delta, reason)` — 이벤트 로그 포함
  - `get_support_range(companion_id) -> int` — bond 레벨 기반
  - `can_support_attack(unit_a, unit_b) -> bool` — 인접 + bond 3 이상
  - `get_squad_trust_average() -> float` — ProgressionService.trust 업데이트용
  - `get_name_anchor_eligible() -> Array[StringName]` — bond 5 동료 목록

#### 4-B. 6인 동료 초기 bond 데이터
- [ ] `data/bonds/serin_bond.tres` 생성 (bond_level=0, arc_flags 정의)
- [ ] `data/bonds/bran_bond.tres` 생성
- [ ] `data/bonds/tia_bond.tres` 생성
- [ ] 나머지 3인 bond 리소스 생성 (master_campaign_outline.md 참조)

#### 4-C. 인접 지원 공격
- [ ] `battle_controller.gd`에서 플레이어 공격 해결 시 인접 아군 중 bond 3 이상인 동료 탐색
- [ ] 조건 충족 시 `_resolve_support_attack(supporter, target)` 호출 — 별도 데미지 적용
- [ ] 지원 공격 시 HUD에 "지원 공격!" 표시
- [ ] 텔레메트리: `record_command_use(&"support_attack")`

#### 4-D. Trust 연동
- [ ] `BattleController._on_battle_victory()` 또는 캠프 진입 시 `bond_service.get_squad_trust_average()` 호출
- [ ] 결과를 `progression_service.apply_trust_delta()` 에 반영 (이벤트 기반, 매 배틀마다 소량)

#### 4-E. Name Anchor 기믹 플레이스홀더
- [ ] `bond_service.get_name_anchor_eligible()` 구현 완료
- [ ] CH10 보스 runner에서 "bond 5 동료 없으면 Name Anchor 불발" 어서션 추가 (True Ending 게이트)

#### 4-F. 검증
- [ ] `bond_runner.gd` — bond delta, 지원 공격 조건, name anchor 조건 어서션
- [ ] Gate 0 PASS 확인

---

## 5. 저장/불러오기 UI 흐름

**목표:** 플레이어가 세이브/로드를 실제로 사용할 수 있는 UI 진입점을 만든다.

**requires:** 캠프 허브 (섹션 2) — 저장은 주로 캠프에서 발생

**연관 파일:**
- `scripts/battle/save_service.gd` — 이미 구현됨
- `scripts/main.gd` — 씬 루트, 게임 오버 시 불러오기 진입점
- 새 파일: `scenes/ui/SaveLoadPanel.tscn`, `scripts/ui/save_load_panel.gd`

**설계 규칙:**
- 저장: 캠프 허브 → 설정 → 저장 (자동저장 + 수동저장 슬롯 3개)
- 불러오기: 타이틀 화면 또는 패배 화면에서 진입
- 슬롯 카드: 챕터 번호, 저장 시각, burden/trust 요약 (sidecar JSON에서 읽음)
- 삭제 확인 다이얼로그 필수

### 체크리스트

#### 5-A. 저장 패널 UI
- [ ] `scenes/ui/SaveLoadPanel.tscn` 생성
  - 슬롯 3개 카드 (슬롯 0, 1, 2)
  - 각 카드: 챕터, 저장 시각, burden/trust 수치, "저장" / "불러오기" / "삭제" 버튼
- [ ] `scripts/ui/save_load_panel.gd`
  - `refresh_slots()` — `save_service.peek_slot(n)`으로 각 슬롯 정보 읽기
  - `_on_save_pressed(slot)` — `save_service.save_progression(data, slot)`
  - `_on_load_pressed(slot)` — `save_service.load_progression(slot)` → ProgressionService에 적용
  - `_on_delete_pressed(slot)` — 확인 다이얼로그 → `save_service.delete_slot(slot)`

#### 5-B. 캠프 허브 연결
- [ ] 캠프 허브 설정 탭 또는 우측 상단 버튼에서 SaveLoadPanel 열기
- [ ] 캠프 진입 시 자동저장 (슬롯 0 = autosave 예약)

#### 5-C. 타이틀/패배 화면 연결
- [ ] 타이틀 화면에 "불러오기" 버튼 추가 → SaveLoadPanel (로드 모드)
- [ ] 패배 화면에 "마지막 저장으로" 버튼 추가 → 슬롯 0 자동로드

#### 5-D. ProgressionService 로드 적용
- [ ] `main.gd`에서 `save_service.load_progression(slot)` 결과를 `progression_service.load_data(data)` 에 전달하는 흐름 완성
- [ ] 로드 후 배틀/캠프 씬 상태가 ProgressionData 기준으로 초기화되는지 확인

#### 5-E. 검증
- [ ] 저장 → 앱 재시작 시뮬레이션 → 불러오기 → burden/trust/fragment 일치 확인 headless 테스트
- [ ] Gate 0 PASS 확인

---

## 6. Production Art + 실제 오디오

**목표:** generated placeholder를 production 에셋으로 교체한다.

**연관 스펙:** `art-replacement-priority.md`, `art-production-briefs.md`, `artist-handoff-onepager.md`

**연관 파일:**
- `assets/ui/production/` — 교체 대상 드롭 폴더 (현재 전부 비어 있음)
- `scripts/dev/battle_art_drop_validator.py` — 드롭 후 무결성 검증 스크립트
- `scripts/dev/battle_art_replacement_checklist.py` — 교체 현황 체크

### Art 체크리스트 (교체 우선순위 순)

#### Tier 1 — 최우선 (단 1회 아트 스프린트로 가장 큰 품질 점프)
- [ ] **유닛 토큰 아트** — `assets/ui/production/unit_token_art/` 드롭
  - 역할별 엠블럼: Vanguard, Scout, Healer, Knight, Striker, Support
  - 보스 토큰 패밀리
  - 드롭 후 `battle_art_drop_validator.py` 실행
- [ ] **오브젝트 아이콘** — `assets/ui/production/object_icons/`
  - 보물상자, 레버/제어휠, 제단/의식 앵커, 문/게이트
- [ ] **전투 FX** — `assets/ui/production/fx/`
  - 근접 히트 스파크, 보스 마크 링, 목표 해결 버스트

#### Tier 2 — 높은 영향
- [ ] **특수 지형 오버레이** — `assets/ui/production/tile_icons/`
  - forest, wall, highground
  - cathedral, hymn, bell
  - battery, floodgate, bridge
- [ ] **배틀 HUD 아이콘** — `assets/ui/production/button_icons/`
  - 가방(인벤토리), 뒤로, 대기, 적턴/종료

#### Tier 3 — 마무리
- [ ] 보드 프레임/테두리/장식
- [ ] 배경 앰비언트 모티프 (CH03 숲, CH07 의식 아치, CH10 탑 링)

#### Tier 4 — 이후
- [ ] 캐릭터별 토큰/초상화 컷인 (art volume 크므로 별도 스프린트)
- [ ] 풀 타일셋 교체 (절차적 보드 → tilemap 전환 검토 필요)

### 아트 드롭 후 게이트
- [ ] `python3 scripts/dev/battle_art_drop_validator.py` PASS
- [ ] `bash scripts/dev/check_runnable_gate0.sh` PASS
- [ ] `godot --headless --script scripts/dev/m1_playtest_runner.gd` PASS
- [ ] `godot --headless --script scripts/dev/m3_ui_runner.gd` PASS
- [ ] `bash scripts/dev/render_representative_snapshots.sh` 실행 → contact sheet 육안 확인

### 오디오 체크리스트

#### 6-A. 사운드 에셋 수령 준비
- [ ] 아티스트에게 전달할 오디오 브리프 확인 (`store_asset_spec.md` 참조)
- [ ] 필요한 SFX 목록 확정:
  - 전투: hit_confirm, miss, counter_hit, boss_mark, boss_charge, state_player_phase, state_enemy_phase
  - 망각: oblivion_stack_apply, oblivion_stack_cleanse
  - 캠프: 탭 전환, 편성 확정, 장비 장착
  - 기억 조각: fragment_reveal_stinger (벨 계열)
  - UI: 버튼 탭, 패널 열기/닫기
- [ ] BGM 브리프: "dark SRPG, 벨 모티프, 단조 스트링 리드" (trailer-beat-sheets.md 기준)

#### 6-B. 오디오 통합
- [ ] `audio/sfx/` 디렉토리 구조 정리 (placeholder → production 교체)
- [ ] `scripts/battle/sfx_trigger_integration_runner.gd` 재실행 PASS 확인
- [ ] 망각 스택 apply/cleanse에 SFX 연결
- [ ] 기억 조각 연출에 fragment_reveal_stinger 연결

---

## 전체 진행 현황 요약

| # | 항목 | 현재 상태 | 착수 조건 |
|---|------|-----------|-----------|
| 1 | 망각 스택 실제 발동 | 서비스 구현 완료, 미연결 | 즉시 착수 가능 |
| 2 | 캠프 허브 | 설계 문서 있음, 코드 없음 | 즉시 착수 가능 |
| 3 | 컷씬/기억 연출 | 설계 문서 있음, 코드 없음 | 즉시 착수 가능 |
| 4 | Bond 레벨 | 서비스 미구현 | 1번 이후 권장 |
| 5 | 저장/불러오기 UI | SaveService 완료, UI 없음 | 2번(캠프) 이후 |
| 6 | Production art + 오디오 | 전부 placeholder | 아티스트 납품 대기 |

**엔지니어링으로만 처리 가능한 것: 1, 4**
**씬/UI 작업 포함: 2, 3, 5**
**외부 의존(아티스트): 6**

---

*이 파일을 체크리스트로 운용한다. 각 섹션 착수 시 Paperclip 이슈를 생성하고 done 처리 시 여기 체크박스를 업데이트할 것.*
