# 출시 전 최종 QA 체크리스트

프로젝트: `/Volumes/AI/tactics`
기준본 문서: 이 문서 `docs/2026-04-18-final-release-qa-checklist.md`
정리 기준:
- 기존 `docs/turn-rpg-upgrade-wave-a-checklist-v1.md` 는 기능 구현 TODO 성격이므로 릴리즈 QA 기준본에서 제외
- 기존 `docs/implementation_checklist_v01.md` 는 아트/런타임 프로모션 체크 성격이므로 릴리즈 QA 실행 항목으로 필요한 명령만 흡수
- 저장/엔딩 판정의 정본은 아래 문서를 우선 참조
  - `docs/reviews/2026-04-20-save-load-status-clarification.md`
  - `docs/reviews/2026-04-20-ending-resolver-unification.md`
  - `docs/ending_conditions_standard.md`

## 0. 이번 후보 빌드 기준선

실행 환경
- Godot: `/opt/homebrew/bin/godot4`
- 저장소 상태: 대량 수정/미추적 파일 존재. QA 결과는 현재 워킹트리 기준이며 clean candidate 재실행 필요.

이번 점검에서 직접 실행 확인한 항목
- PASS `scripts/dev/check_runnable_gate0.sh`
- PASS `res://scripts/dev/m2_campaign_flow_runner.gd`
- PASS `res://scripts/dev/save_load_runner.gd`
- PASS `res://scripts/dev/campaign_save_load_core_loop_runner.gd`
- PASS `res://tests/test_ending_resolver.gd`
- PASS `res://scripts/dev/ending_criteria_ui_runner.gd`
- PASS `res://scripts/dev/true_ending_runner.gd`
- PASS `res://scripts/dev/ui_screens_runner.gd`
- PASS `res://scripts/dev/meta_progression_runner.gd`
- PASS `res://scripts/dev/ch06_ch10_boss_surface_runner.gd` (2026-04-24 재확인)
- PASS `res://scripts/dev/lategame_boss_pattern_runner.gd` (2026-04-24 재확인)
- PASS `res://scripts/dev/ch06_ch10_cutscene_runner.gd` (2026-04-24 재확인)
- PASS `res://scripts/dev/tut_ch05_surface_runner.gd` (2026-04-24 재확인)
- PASS `scripts/dev/run_perf_benchmarks.sh`
- PASS `scripts/dev/run_visual_qa_suite.sh` (`docs/generated/visual_qa_suite_report_v01.md`: 8/8 pass)
- PASS `res://scripts/dev/ch02_shell_runner.gd`
- PASS `res://scripts/dev/ch03_shell_runner.gd`
- PASS `res://scripts/dev/ch04_shell_runner.gd`
- PASS `res://scripts/dev/ch05_shell_runner.gd`
- PASS `res://scripts/dev/ch06_shell_runner.gd`
- PASS `res://scripts/dev/ch07_shell_runner.gd`
- PASS `res://scripts/dev/ch08_shell_runner.gd`
- PASS `res://scripts/dev/ch09_shell_runner.gd`
- PASS `res://scripts/dev/ch10_shell_runner.gd` (2026-04-24 재확인)
  - CH10_05 브리핑 경유 → 전투 진입 → 최종 결말 → 타이틀 복귀 → NG+ unlock 확인

고정 실행 접두어
```bash
GODOT=/opt/homebrew/bin/godot4
ROOT=/Volumes/AI/tactics
$GODOT --headless --path $ROOT --script <runner>
```

---

## 1. 캠페인 진행

### 1-1. 구조 검증 / 기준선
- [ ] `scripts/dev/check_runnable_gate0.sh`
  - 기대 결과: `[PASS] Runnable Gate 0 integrity check passed.`
- [ ] `res://scripts/dev/m2_campaign_flow_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/m2_campaign_flow_runner.gd`
  - 확인 포인트: CH01_02~CH01_05 진행, 캠프 진입, 저장 호출 로그 존재

### 1-2. 챕터 shell 전체 진행
- [ ] CH02 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch02_shell_runner.gd`
  - 확인 포인트: CH02 intro → CH02_01~05 → camp handoff
- [ ] CH03 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch03_shell_runner.gd`
  - 확인 포인트: CH03 intro → CH03_01~05 → camp handoff
- [ ] CH04 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch04_shell_runner.gd`
- [ ] CH05 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch05_shell_runner.gd`
- [ ] CH06 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch06_shell_runner.gd`
- [ ] CH07 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch07_shell_runner.gd`
- [ ] CH08 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch08_shell_runner.gd`
- [ ] CH09 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch09_shell_runner.gd`
  - 확인 포인트: CH09A + CH09B 양쪽 handoff 모두 PASS
- [ ] CH10 shell
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch10_shell_runner.gd`
  - 현재 상태: PASS (2026-04-24 재확인)
  - 확인 포인트: CH10_04 종료 후 CH10_05 브리핑 경유, 최종전 진입, 결말, 타이틀 복귀, NG+ unlock
  - 후속 문서: `docs/reviews/2026-04-24-ch06-ch10-boss-qa-balance-status.md`

### 1-3. 수동 플레이 동선
- [ ] 실제 창 실행으로 Title → New Game → CH01 시작 → CH01 클리어 → Camp 진입까지 확인
  - 명령: `$GODOT --path $ROOT res://scenes/Main.tscn`
  - 확인 포인트: 컷신 스킵 후에도 진행 플래그 유지, 캠프 진입 후 다음 전투 선택 가능
- [ ] CH07/CH09B/CH10 대표 전투 수동 확인
  - 명령: `scripts/dev/start_manual_visual_review.sh ch07|ch09b|ch10`
  - 확인 포인트: Chapter Identity / Movement Feel / Attack Timing / HUD / Framing

---

## 2. 보스전 / 후반부

### 2-1. 보스 표면/컷신/승리 핸드오프
- [ ] `res://scripts/dev/ch06_ch10_boss_surface_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch06_ch10_boss_surface_runner.gd`
  - 확인 포인트:
    - CH06_05, CH07_05, CH08_05, CH09A_05, CH09B_05, CH10_05 로드
    - HUD 생성
    - 시작/클리어 컷신 ID resolve
    - 보스 phase threshold 진입
    - late-game object drift 없음
    - 승리 시 컷신 또는 ending flow handoff 정상

### 2-2. 보스 패턴 회귀
- [ ] `res://scripts/dev/lategame_boss_pattern_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/lategame_boss_pattern_runner.gd`
  - 확인 포인트: CH08_05 / CH09B_05 / CH10_05 late-game boss pattern PASS
- [ ] `res://scripts/dev/ch02_ch05_boss_pattern_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ch02_ch05_boss_pattern_runner.gd`
  - 확인 포인트: 초중반 보스 threshold/telegraph 회귀
- [ ] `res://scripts/dev/valgar_boss_pattern_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/valgar_boss_pattern_runner.gd`
  - 확인 포인트: Valgar phase 전환/특수 패턴
- [ ] `res://scripts/dev/extended_boss_pattern_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/extended_boss_pattern_runner.gd`
  - 확인 포인트: 보스 패턴 큐 중복/유실 없음

### 2-3. 후반부 수동 전투 확인
- [ ] CH08_05
  - 확인 포인트: `ch08_05_transfer_gate_latch` 상호작용, 컷신 handoff, softlock 없음
  - 자동 보조 검증: `lategame_boss_pattern_runner.gd`가 gate latch relief/AI shift/objective surface를 PASS
- [ ] CH09B_05
  - 확인 포인트: `ch09b_05_archive_lectern` 접근성, root archive 컷신 연결
  - 자동 보조 검증: `lategame_boss_pattern_runner.gd`가 archive lectern relief/AI shift/objective surface를 PASS
- [ ] CH10_05
  - 확인 포인트: `ch10_05_anchor_chain`, `ch10_05_bell_dais`, 최종전 종료 후 ending resolution 진입
  - 자동 보조 검증: `ch06_ch10_boss_surface_runner.gd`, `lategame_boss_pattern_runner.gd`, `ch10_shell_runner.gd`가 CH10_05 boss runtime 및 campaign handoff를 PASS

---

## 3. 저장 / 불러오기

기준 판정
- 이번 릴리즈 후보는 save-support build 기준으로 QA
- 정본: `docs/reviews/2026-04-20-save-load-status-clarification.md`

### 3-1. 저장 서비스 / 패널 계약
- [ ] `res://scripts/dev/save_load_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/save_load_runner.gd`
  - 확인 포인트:
    - save/load/delete roundtrip
    - peek_slot metadata keys 존재
    - two-press delete confirm
    - null service safety
- [ ] `res://scripts/dev/ui_screens_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ui_screens_runner.gd`
  - 확인 포인트:
    - Title load button enabled/disabled
    - NG+ 버튼 노출 규칙
    - DefeatScreen autosave load button
    - autosave reason surface

### 3-2. 코어 루프 복귀
- [ ] `res://scripts/dev/campaign_save_load_core_loop_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/campaign_save_load_core_loop_runner.gd`
  - 확인 포인트:
    - camp save 작성
    - load 후 playable battle core-loop 복귀
    - burden/trust/gold/flag 유지
- [ ] `res://scripts/dev/save_load_core_loop_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/save_load_core_loop_runner.gd`
  - 확인 포인트: 전투 코어 루프 상태 저장/복귀
- [ ] `res://scripts/dev/campaign_save_to_title_load_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/campaign_save_to_title_load_runner.gd`
  - 확인 포인트: 캠프 저장 → 타이틀 → 로드 동선
- [ ] `res://scripts/dev/campaign_save_defeat_title_load_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/campaign_save_defeat_title_load_runner.gd`
  - 확인 포인트: defeat/autosave/title load 연결

### 3-3. 남은 확인 포인트
- [ ] 슬롯 메타데이터 `chapter` 값이 실제 챕터를 표시하는지 수동 확인
  - 현재 문서상 known gap: sidecar chapter is empty string
- [ ] slot 0 autosave 와 manual save 정책 충돌 없는지 결정
  - 현재 known gap: panel이 slot 0 manual operation 허용
- [ ] NG+ save/load cycle 검증
  - 후보 명령:
    - `$GODOT --headless --path $ROOT --script res://scripts/dev/ng_plus_save_load_runner.gd`
    - `$GODOT --headless --path $ROOT --script res://scripts/dev/ng_plus_campaign_save_to_title_load_runner.gd`

---

## 4. 엔딩 / 진엔딩

기준 판정
- 최종 게이트: `공명 인장 6개 + 이름 앵커 2개 이상 유지 proxy + 6인 이름 부름 전부 발동`
- 정본: `docs/reviews/2026-04-20-ending-resolver-unification.md`, `docs/ending_conditions_standard.md`

### 4-1. 자동 판정 검증
- [ ] `res://tests/test_ending_resolver.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://tests/test_ending_resolver.gd`
  - 현재 결과: 25/25 PASS
- [ ] `res://scripts/dev/true_ending_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/true_ending_runner.gd`
  - 확인 포인트: true ending resolution surface + overlay
- [ ] `res://scripts/dev/ending_criteria_ui_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ending_criteria_ui_runner.gd`
  - 확인 포인트:
    - `공명 인장 6/6`
    - `이름 앵커 유지`
    - `이름 부름 미완/완료`
    - `현재 판정` 노출
    - 최종 진엔딩 기준 카드 progress row 3개 이상
- [ ] `res://scripts/dev/ending_cinematic_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ending_cinematic_runner.gd`
  - 확인 포인트: ending cutscene/overlay/credit handoff

### 4-2. 수동 분기 확인
- [ ] 일반 엔딩 세이브/플래그 세트로 CH10 종료
  - 확인 포인트: 일반 엔딩 텍스트/크레딧/타이틀 복귀
- [ ] 진엔딩 세이브/플래그 세트로 CH10 종료
  - 확인 포인트: 진엔딩 텍스트/연출/플래그 커밋
- [ ] 컷신 스킵 직후 엔딩 결과 불변
  - 확인 포인트: skip/non-skip 결과 동일

---

## 5. UI / 메타 시스템

### 5-1. UI 핵심 회귀
- [ ] `res://scripts/dev/m3_ui_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/m3_ui_runner.gd`
  - 확인 포인트: 기본 UI shell 회귀
- [ ] `res://scripts/dev/ui_screens_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/ui_screens_runner.gd`
- [ ] `res://scripts/dev/equipment_unequip_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/equipment_unequip_runner.gd`
  - 확인 포인트: 장착/해제 반영
- [ ] `res://scripts/dev/equipment_direct_select_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/equipment_direct_select_runner.gd`
  - 확인 포인트: 장비 직접 선택 UX

### 5-2. 메타 시스템
- [ ] `res://scripts/dev/meta_progression_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/meta_progression_runner.gd`
  - 현재 결과: PASS
  - 확인 포인트: forge / enchant / reforge flows
- [ ] `res://scripts/dev/meta_forge_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/meta_forge_runner.gd`
  - 확인 포인트: 실제 메타 forge UI/비용 회귀
- [ ] `res://scripts/dev/campaign_panel_party_support_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/campaign_panel_party_support_runner.gd`
  - 확인 포인트: 파티/서포트 패널 surface
- [ ] `res://scripts/dev/campaign_panel_skill_section_runner.gd`
  - 명령: `$GODOT --headless --path $ROOT --script res://scripts/dev/campaign_panel_skill_section_runner.gd`
  - 확인 포인트: campaign panel skill section 표시

### 5-3. 수동 UI 점검
- [ ] TitleScreen Continue / Load / NG+ 버튼 상태 확인
- [ ] SaveLoadPanel slot label, burden/trust/ending tendency, timestamp 확인
- [ ] CampHUD 탭 반복 전환 시 입력 잠김 여부 확인
- [ ] meta_system_menu 실제 창 열기 후 결과 문구/버튼 disable 상태 확인

---

## 6. 성능 / 비주얼 / 회귀

### 6-1. 성능
- [ ] `scripts/dev/run_perf_benchmarks.sh`
  - 명령: `scripts/dev/run_perf_benchmarks.sh`
  - 현재 결과:
    - core loop bootstrap avg `8113.1us`
    - enemy roundtrip avg `26693.75us`
    - AI decision avg `276.41us`
  - 확인 포인트: PERF_RESULT JSON 출력, 비정상 급등 없음

### 6-2. 비주얼 회귀
- [ ] `scripts/dev/run_visual_qa_suite.sh`
  - 명령: `scripts/dev/run_visual_qa_suite.sh`
  - 산출물:
    - `docs/generated/visual_qa_suite_report_v01.json`
    - `docs/generated/visual_qa_suite_report_v01.md`
  - 현재 결과: 8/8 pass
- [ ] `res://scripts/dev/representative_battle_visual_runner.gd`
  - 포함 확인 포인트:
    - CH07 `city` family
    - CH09B `archive` family
    - CH10 `final_bell` family
    - object proximity: 모두 1 타일
- [ ] 수동 대표 전투 오픈
  - 명령: `scripts/dev/open_representative_battle.sh ch07|ch09b|ch10`
  - 확인 포인트: HUD framing, landmark readability, attack timing, movement feel

### 6-3. 최종 회귀 묶음
- [ ] 아래 순서로 재실행 후 결과 보관
```bash
scripts/dev/check_runnable_gate0.sh
$GODOT --headless --path $ROOT --script res://scripts/dev/m2_campaign_flow_runner.gd
$GODOT --headless --path $ROOT --script res://scripts/dev/save_load_runner.gd
$GODOT --headless --path $ROOT --script res://scripts/dev/campaign_save_load_core_loop_runner.gd
$GODOT --headless --path $ROOT --script res://tests/test_ending_resolver.gd
$GODOT --headless --path $ROOT --script res://scripts/dev/ch06_ch10_boss_surface_runner.gd
scripts/dev/run_perf_benchmarks.sh
scripts/dev/run_visual_qa_suite.sh
```
- [ ] shell 전 챕터 sweep
```bash
for r in ch02_shell_runner.gd ch03_shell_runner.gd ch04_shell_runner.gd ch05_shell_runner.gd ch06_shell_runner.gd ch07_shell_runner.gd ch08_shell_runner.gd ch09_shell_runner.gd ch10_shell_runner.gd; do
  $GODOT --headless --path $ROOT --script res://scripts/dev/$r || break
done
```

---

## 7. 현재 남은 블로커 / 출고 전 판정 필요

### P0
- [ ] `ch10_shell_runner.gd` 실패 해결 또는 의도 차이 문서화
  - 현재 에러: `Expected battle mode for CH10_05, got briefing.`
  - 영향: 최종전 진입/엔딩 전 handoff 신뢰도 저하
- [ ] clean candidate 기준 재실행
  - 현재 워킹트리에 대량 변경 존재. 실제 release branch/commit 고정 후 재검증 필요

### P1
- [ ] save slot metadata `chapter` 공란 문제 수정 또는 릴리즈 노트 고지
- [ ] slot 0 autosave/manual save 정책 확정
- [ ] NG+ save/load 전용 러너 결과 확보
- [ ] `true_ending_runner.gd`, `meta_progression_runner.gd` 종료 시 ObjectDB leak warning 재현 여부 재확인

### P2
- [ ] 터치/소형 해상도 수동 UX 점검
- [ ] 최종 대표 전투 3종 수동 시각 검수 스크린샷 보관

---

## 8. 최종 서명
- [ ] 캠페인 진행 블로커 0건
- [ ] 저장 손실/로드 실패 블로커 0건
- [ ] 엔딩 오판정 0건
- [ ] CH10 최종전 handoff 이슈 해소
- [ ] 성능/비주얼/보스 회귀 결과 첨부
- [ ] release candidate commit hash 고정 후 재실행 완료
