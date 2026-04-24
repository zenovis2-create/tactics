# Spec Gap Execution Backlog

> For Hermes: Use subagent-driven-development skill to implement this plan task-by-task.

Goal: 감사 기준으로 실제 미구현 항목만 추려, 문서 드리프트를 제외한 실행 백로그를 우선순위대로 정리한다.

Architecture: 이미 구현된 레인(headless-first visual/runtime, core shell, 일부 support/briefing/3-star)은 재구현하지 않는다. 실제 부재 기능, 미완 심화, 출시 차단 검증만 남긴다.

Tech Stack: Godot 4.6, GDScript, headless runners, campaign shell, battle controller, progression/save pipeline

---

## Priority 0 — 출시 판단 차단 항목

### Task P0-1: 세이브 지원 범위 최종 확정
Objective: 현재 빌드가 세이브 지원인지 세션 기반인지 문서/QA 기준을 하나로 고정한다.

Status: 완료 (2026-04-23)

Files:
- Review: `docs/2026-04-18-final-release-qa-checklist.md`
- Review: `scripts/battle/save_service.gd`
- Review: `scripts/dev/save_load_runner.gd`
- Modify: 릴리즈 기준 문서 1곳

Done when:
- 세이브 지원 여부가 한 문장으로 확정됨
- QA 체크리스트 4-1 또는 4-2 중 하나만 남김
- 현재 러너 범위와 충돌하지 않음

Resolution:
- 현재 릴리즈 후보는 `세이브 지원 빌드`로 확정
- 근거 러너: `save_load_runner.gd`, `save_load_core_loop_runner.gd`, `campaign_save_load_core_loop_runner.gd` PASS
- 반영 문서: `docs/2026-04-18-final-release-qa-checklist.md`

### Task P0-2: EndingResolver 기준 단일화
Objective: 엔딩 판정 기준을 문서와 구현 중 하나로 통일한다.

Status: 완료 (2026-04-23)

Files:
- Review: `docs/2026-04-18-final-release-qa-checklist.md`
- Review: `scripts/battle/ending_resolver.gd`
- Review: `tests/test_ending_resolver.gd`
- Modify: 엔딩 기준 문서 1곳

Done when:
- 진엔딩/일반엔딩 기준이 문서 1개 기준으로 고정됨
- 테스트 명세와 설명 문구가 모순되지 않음

Resolution:
- 표준 기준 문서 = `docs/ending_conditions_standard.md`
- 구현 기준 = `scripts/battle/ending_resolver.gd`
- 검증 기준 = `tests/test_ending_resolver.gd` PASS
- 최종 진엔딩 조건 = `공명 인장 6개` + `이름 앵커 2개 이상 유지` + `6인의 이름 부름 전부 발동`

### Task P0-3: shell runner vs 수동 플레이 차이 검증
Objective: 자동 통과와 수동 UX 누락 가능성을 별도 체크리스트로 닫는다.

Files:
- Review: `docs/2026-04-18-final-release-qa-checklist.md`
- Review: `scripts/dev/headless_dev_smoke.sh`
- Modify: QA 체크 문서 또는 리뷰 문서

Done when:
- shell runner 통과만으로 닫히지 않는 수동 확인 항목이 명시됨
- CH02~CH10 shell flow의 수동 대응 범위가 기록됨

---

## Priority 1 — 실제 기능 미구현

### Task P1-1: Hidden Recruit 3종 구현 여부 확정 및 착수
Objective: Lete/Mira/Melkion ally recruit 축의 실제 부재를 채운다.

Missing evidence:
- `data/units/ally_lete.tres` 없음
- `data/units/ally_mira.tres` 없음
- `data/units/ally_melkion_ally.tres` 없음
- `scripts/dev/hidden_recruit_runner.gd` 없음

Files:
- Create: `data/units/ally_lete.tres`
- Create: `data/units/ally_mira.tres`
- Create: `data/units/ally_melkion_ally.tres`
- Modify: `scripts/campaign/campaign_catalog.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/interactive_object_actor.gd`
- Create: `scripts/dev/hidden_recruit_runner.gd`

Done when:
- 3명 모두 unlock path 존재
- campaign roster 반영
- runner green

### Task P1-2: Dialogue Choice System 구현 여부 확정 및 착수
Objective: Post-Sprint7 choice system 부재를 메운다.

Missing evidence:
- `MODE_CHOICE` 미확인
- `choice_system_runner.gd` 미확인
- choice persistence/state 흔적 미확인

Files:
- Modify: `scripts/campaign/campaign_state.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/campaign/campaign_panel.gd`
- Modify: `scripts/data/progression_data.gd`
- Modify: `scripts/campaign/campaign_shell_dialogue_catalog.gd`
- Create: `scripts/dev/choice_system_runner.gd`

Done when:
- choice state 진입/저장/적용 동작
- 5개 분기 최소 headless 검증

### Task P1-3: Permadeath / Retreat 옵션 존재 여부 확정
Objective: 문서 priority item으로 적힌 permadeath/retreat가 실제 범위인지, 삭제 대상인지, 구현 대상인지 결정한다.

Files:
- Review: `docs/FARLAND_TACTICS_POST_SPRINT7_FEATURE_SPEC.md`
- Review: 전투/캠페인 관련 코드
- Modify: spec 또는 backlog 문서

Done when:
- 구현한다 / 범위에서 뺀다 둘 중 하나로 결정
- 유령 요구사항 제거

### Task P1-4: Post-Game Encyclopedia 존재 여부 확정
Objective: encyclopedia가 실제 요구사항인지 드롭된 아이디어인지 확정한다.

Files:
- Review: `docs/FARLAND_TACTICS_POST_SPRINT7_FEATURE_SPEC.md`
- Review: 캠프/기록/UI 코드
- Modify: spec 또는 backlog 문서

Done when:
- 구현 대상이면 파일/러너 계획이 생김
- 아니면 문서에서 제외됨

---

## Priority 2 — 부분 구현에서 멈춘 핵심 기능

### Task P2-1: Skill Levelup 배틀 연결
Objective: DEV_SPEC의 "스킬 레벨업 / 성장 미구현"을 실제 배틀 루프와 연결한다.

Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:50`
- `docs/FARLAND_TACTICS_CHECKLIST.md:56`

Files:
- Review: `scripts/battle/skill_levelup_service.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/progression_service.gd`
- Modify: 결과/UI surface 관련 파일
- Add/extend runner

Done when:
- 배틀 종료/행동 결과가 skill growth로 연결
- 기존 `SkillLevelUpService`가 isolated utility가 아니라 runtime feature가 됨

### Task P2-2: 상태이상 해제 스킬 TODO 종료
Objective: 상태이상 해제 스킬 TODO를 닫는다.

Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:110`

Files:
- Review: `scripts/battle/combat_service.gd`
- Review: `scripts/battle/status_service.gd`
- Review: `data/skills/never_forget.tres` 등
- Add/extend runner

Done when:
- cleanse skill이 실제 status removal과 UI refresh까지 검증됨

### Task P2-3: HUD/Camp 미완 surface 정리
Objective: DEV_SPEC 하단의 HUD/Camp 개선 항목 중 ship-critical한 것만 닫는다.

Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:520~557`

Candidate scope:
- 망각 스택 수 표시
- 버프/디버프 duration countdown
- 캠프 대화 이력

Done when:
- 릴리즈 필수 surface만 우선 완료 또는 범위 제외 처리

---

## Priority 3 — 후반 보스/심화 미완 항목

### Task P3-1: CH06 발가르 포대/외벽 심화
Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:209`
- `docs/FARLAND_TACTICS_CHECKLIST.md:29`

### Task P3-2: CH08 레테 은신/암살/분신 심화
Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:238`
- `docs/FARLAND_TACTICS_CHECKLIST.md:31`

### Task P3-3: CH09A 바르텐 삭제구역/감찰친위대 심화
Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:243`
- `docs/FARLAND_TACTICS_CHECKLIST.md:32`

### Task P3-4: CH09B 멜키온 전장 규칙 개정 심화
Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:264`
- `docs/FARLAND_TACTICS_CHECKLIST.md:33`

### Task P3-5: CH10 카르온 공명/이름절단 심화
Evidence:
- `docs/FARLAND_TACTICS_DEV_SPEC.md:286,411`
- `docs/FARLAND_TACTICS_CHECKLIST.md:34`

Done when for each:
- gimmick action exists
- objective/HUD/result linkage exists
- dedicated runner exists or 기존 boss runner 확장됨

---

## Priority 4 — 문서 드리프트 정리

### Task P4-1: Post-Sprint7 spec 체크박스 현실화
Objective: 이미 구현된 support/briefing/3-star 항목은 체크 상태를 갱신하고, 미구현 항목만 남긴다.

Evidence already present:
- `data/support_conversations.gd`
- `scripts/battle/bond_service.gd`
- `scripts/campaign/campaign_state.gd`
- `scripts/campaign/campaign_controller.gd`
- `scripts/dev/briefing_runner.gd`
- `scripts/dev/three_star_runner.gd`
- `scripts/dev/support_namecall_pipeline_runner.gd`

Done when:
- 문서만 읽어도 실제 구현 상태를 오해하지 않음

### Task P4-2: DEV_SPEC와 CHECKLIST 상충 항목 정리
Objective: 이미 완료된 항목과 미완 항목의 표현을 맞춘다.

Done when:
- 동일 기능이 문서마다 완료/미완으로 갈리지 않음

---

## 실행 순서 권장

1. P0-1 ~ P0-3
2. P1-1, P1-2
3. P2-1, P2-2
4. P4-1, P4-2
5. P3 보스 심화 묶음

---

## 현재 즉시 착수 추천 3건

1. 세이브 범위 확정
2. EndingResolver 기준 단일화
3. Hidden Recruit 구현 착수
