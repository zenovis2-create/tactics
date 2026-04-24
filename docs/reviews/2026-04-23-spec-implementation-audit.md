# 2026-04-23 Spec Implementation Audit

## 결론

프로젝트는 "일부 구현 레인 완료" 상태이지만, "스펙 문서 전부 구현 완료" 상태는 아니다.

## 판정 기준

분류는 4가지로 나눈다.

- 완료: 문서가 주장하는 범위와 현재 구현/검증 흔적이 대체로 일치
- 부분 완료: 핵심 축은 구현됐지만 문서 자체에 미구현 체크가 남아 있거나 일부 후속이 남음
- 문서 드리프트: 문서의 체크리스트와 실제 코드/러너/명명 사이 불일치가 큼
- 미완료 검증: 구현 일부와 별개로 출시/최종 QA 체크가 닫히지 않음

## 문서별 매트릭스

| 문서 | 판정 | 근거 |
|---|---|---|
| `docs/implementation_scope_spec_v01.md` | 완료 | 문서 자체가 현재 lane의 정의와 완료조건을 서술하고, `Current Status`에서 이미 만족한다고 명시함 |
| `docs/implementation_checklist_v01.md` | 완료(해당 lane) | `[x]` 35개, `[ ]` 14개지만 남은 항목은 promotion rule / stop condition 같은 운영 체크 성격이 큼. phase-complete lane과 합치됨 |
| `docs/implementation_completion_review_v01.md` | 완료(해당 lane) | active implementation 종료 및 maintenance mode 진입 선언 문서 |
| `docs/FARLAND_TACTICS_DEV_SPEC.md` | 부분 완료 | `[X]` 278개, `[S]` 38개, `[ ]` 23개. 문서 내부에 `부분 구현 / 미완성` 섹션과 TODO가 명시됨 |
| `docs/FARLAND_TACTICS_POST_SPRINT7_FEATURE_SPEC.md` | 문서 드리프트 + 부분 완료 | 체크박스는 `[ ]` 80개로 전부 미체크처럼 보이나, 실제 코드는 support/briefing/3-star 일부 구현 흔적 존재 |
| `docs/game_spec.md` | 사실상 초과 달성 | 원래 MVP spec인데 현재 프로젝트는 save/load, equipment, campaign, cutscene 등 비목표 범위까지 이미 확장됨 |
| `docs/2026-04-18-final-release-qa-checklist.md` | 미완료 검증 | `[ ]` 140개, 오픈 리스크 6건. 출시 readiness 문서로는 닫히지 않음 |

## 핵심 증거

### 1. implementation lane 완료 근거

- `docs/implementation_scope_spec_v01.md:224`
  - "The current lane now satisfies the above definition."
- `docs/implementation_completion_review_v01.md:5`
  - maintenance mode로 들어갈 만큼 완료되었다고 명시

### 2. DEV_SPEC는 아직 100% 완료 아님

- `docs/FARLAND_TACTICS_DEV_SPEC.md:37`
  - `부분 구현 / 미완성`
- `docs/FARLAND_TACTICS_DEV_SPEC.md:50`
  - `스킬 레벨업 / 성장 | 미구현`
- `docs/FARLAND_TACTICS_DEV_SPEC.md:110`
  - 상태이상 해제 스킬 TODO
- `docs/FARLAND_TACTICS_DEV_SPEC.md:189,205,209,238,243,264,286`
  - 보스 심화/전장 규칙 심화/컷신 심화 등 미완 체크 존재
- `docs/FARLAND_TACTICS_DEV_SPEC.md:520~557`
  - HUD 개선, 캠프 UI 개선 등 미완 체크 존재

### 3. Post-Sprint7 문서는 실제 구현과 어긋난다

실제 구현 흔적:
- `scripts/battle/bond_service.gd`
  - `support_ranks`, `shared_battles`, `get_support_talk()` 존재
- `data/support_conversations.gd`
  - support conversation 데이터 파일 존재
- `scripts/campaign/campaign_state.gd`
  - `MODE_BRIEFING` 존재
- `scripts/campaign/campaign_controller.gd`
  - `_should_show_briefing()`, `_enter_briefing_state()` 존재
- `scripts/dev/briefing_runner.gd` 존재
- `scripts/dev/three_star_runner.gd` 존재
- `scripts/dev/support_namecall_pipeline_runner.gd` 존재

하지만 문서상 체크는 대부분 미체크:
- `docs/FARLAND_TACTICS_POST_SPRINT7_FEATURE_SPEC.md`
  - `[ ]` 80개, `[X]` 0개

즉, 이 문서는 "미구현"이라기보다 "체크리스트 갱신이 안 된 상태 + 일부 기능명 드리프트"로 보는 편이 정확하다.

### 4. Post-Sprint7의 실제 미구현/부재 흔적

검색 기준 현재 부재:
- `data/units/ally_lete.tres` 없음
- `data/units/ally_mira.tres` 없음
- `data/units/ally_melkion_ally.tres` 없음
- `scripts/dev/hidden_recruit_runner.gd` 없음
- `permadeath`, `encyclopedia`, `dialogue choice`, `badge of heroism` 관련 명시적 구현 흔적 미확인

따라서 Post-Sprint7 문서 전체를 완료로 볼 수는 없다.

### 5. 출시 QA는 아직 닫히지 않음

- `docs/2026-04-18-final-release-qa-checklist.md`
  - `[ ]` 140개
- `docs/2026-04-18-final-release-qa-checklist.md:220~227`
  - save/load 범위 확정 필요
  - EndingResolver 기준 일치 검증 필요
  - shell runner와 수동 플레이 일치 재검증 필요

## 체크 수치 요약

- `FARLAND_TACTICS_DEV_SPEC.md`
  - `[X]` 278 / `[S]` 38 / `[ ]` 23
- `FARLAND_TACTICS_POST_SPRINT7_FEATURE_SPEC.md`
  - `[ ]` 80
- `implementation_checklist_v01.md`
  - `[x]` 35 / `[ ]` 14
- `2026-04-18-final-release-qa-checklist.md`
  - `[ ]` 140

## 최종 판정

"스펙 문서 전부 다 구현됐다"는 표현은 부정확하다.

더 정확한 표현은 아래와 같다.

- headless-first visual/runtime implementation lane: 완료
- core game systems and campaign shell: 대부분 구현
- master dev spec: 부분 완료
- post-sprint feature expansion spec: 일부 구현 + 문서 드리프트 + 일부 실제 미구현
- release QA / final signoff: 미완료
