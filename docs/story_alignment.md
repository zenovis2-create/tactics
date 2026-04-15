# Story Alignment Notes

## 1. 목적

이 문서는 `idea.md`, `synopsis.md`, `camp.md`, `phase1.md`, `phase2.md` 사이의 충돌 지점을 정리하고, 앞으로 어떤 파일을 정본으로 삼을지 고정하기 위한 메모다.

## 2. 주요 충돌 정리

| 항목 | 기존 상태 | 충돌 파일 | 결정 |
| --- | --- | --- | --- |
| 오프닝 장 구조 | `synopsis.md`는 `프롤로그. 이름 없는 새벽`을 별도 구간으로 사용 | `camp.md`, `phase1.md`는 `1장. 이름 없는 새벽` 안에 흡수 | `camp.md` 기준 채택. 프롤로그 기능은 1장 내부로 통합 |
| 1장 제목 | `synopsis.md`: `1장. 부서진 국경요새` | `camp.md`, `phase1.md`: `1장. 이름 없는 새벽` | `phase1.md` 기준 채택 |
| 2장 제목 | `synopsis.md`: `2장. 속삭이는 녹영숲` | `camp.md`, `phase2.md`: `2장. 부서진 국경요새` | `phase2.md` 기준 채택 |
| 9장 구조 | 초기 `camp.md`는 9장을 5서브장 단일 구조로 유지 | `phase5+@.md`는 9장을 Part I / Part II 예외 구조로 분리 | `phase5+@.md` 기준 채택. 전체 장 수는 10장 유지, 단 9장만 2부 구조 사용 |
| 구현 레벨 문서 권한 | `synopsis.md`에도 전투 목적과 기믹이 적혀 있음 | `phase1.md`, `phase2.md`는 실제 구현용 스펙까지 포함 | 구현 상세는 `phase*.md` 우선 |
| 보물상자 및 악세사리 루프 | `synopsis.md`에는 거의 없음 | `phase2.md`에 장 길이와 수집 루프가 구체화 | 시스템 운영 규칙은 `phase2.md` 우선 |
| 혼합 문서 경계 | `phase4.md`, `phase5+@.md`는 전부 장 문서처럼 보임 | 실제로는 스토리와 시스템 설계가 함께 섞여 있음 | Story SSOT에서 story section만 정본으로 취급하고, 시스템 section은 별도 참고 문서로 취급 |

## 3. 정본 기준

| 범위 | 정본 파일 | 메모 |
| --- | --- | --- |
| 기술 선택, 엔진 방향, Codex 사용 흐름 | `idea.md` | 가장 초기의 방향성 문서 |
| 캠페인 전체 구조, 장 간 연결 논리, 기억 조각 해석 사다리, 시스템 템포 | `master_campaign_outline.md` | 통합 개요 정본 |
| 세계관 핵심 질문, 동료 설계, 적 철학, 엔딩 메시지 | `synopsis.md`, `docs/story_ssot.md` | `story_ssot.md`가 현재 정본 우선순위와 잠금 상태를 설명 |
| 장 번호, 장 제목, 장별 중심 인물, 기억 조각, 서브장 구조 | `camp.md` | 단, 9장 예외 구조는 `phase5+@.md` 기준 |
| 1장 구현 상세 | `phase1.md` | 전투 스펙, 대사, 보상, 데이터 구조 포함 |
| 2장 구현 상세와 수집 루프 규칙 | `phase2.md` | 보물상자, 악세사리, 탐색 확장 규칙 포함 |
| 3장 구현 상세와 장비/드롭 시스템 초안 | `phase3+item.md` | 3장 세부 맵 구조, 장비 슬롯, 보스 드롭, 회상 토벌전 초안 포함 |
| 4장 구현 상세 | `phase4.md` | Chapter 4 story canon은 `docs/ch04_spec.md` 구간에 해당하는 section만 우선 취급 |
| 5장 구현 상세 + 9장 구조 개정 | `phase5+@.md` | Chapter 5 story, chapter linking rules, chapter 9 split structure 정본 |
| 6장 구현 상세 | `phase6.md` | Chapter 6 detailed implementation canon |
| 7장 구현 상세 | `phase7.md` | Chapter 7 story canon, 시민/정화 대기열/사리아/네리 재등장 정본 |
| 8장 구현 상세 | `phase8.md` | Chapter 8 story canon, 레테/표식/은신/티아 감정 결론 정본 |
| 9장 Part I 구현 상세 | `phase9-1.md` | 카일 붕괴, 병사 시점 망각, 감찰 체계, 카일 합류 정본 |
| 9장 Part II 구현 상세 | `phase9-2.md` | 노아 합류, 멜키온 결전, 최종 기억 복원, 10장 연결 정본 |
| 10장 구현 상세 | `phase10.md` | 카르온 결전, 이름 앵커, 엔딩 분기, 포스트 클리어 정본 |
| 최종 용어 표준 | `docs/final_glossary.md` | 고유명사, 시스템 용어, 서술 금지어 정본 |
| 캐릭터 요약 시트 | `docs/character_sheets.md` | 캐릭터 역할/테마/보이스 표준 |
| 엔딩 분기 표준 | `docs/ending_conditions_standard.md` | 일반 엔딩/진엔딩 판정 규칙 정본 |
| 플래그 진행 표준 | `flag_progression_spec.md` | 진행 분기, 공명 인장, 영속/임시 플래그 운용 표준 |
| 기억 조각 표준 | `memory_fragments.md` | 기억 조각 순서, 현재 해석, 재맥락화, 최종 해석 표준 |
| AI 행동 표준 | `ai_behavior_spec.md` | AI 정보 범위, 점수화, 역할별 행동 원칙 정본 |
| 보스 드롭 표준 | `boss_loot_tables.md` | 보스 철학-드롭 연결, 희귀도 분포, 유니크/어픽스 테이블 정본 |
| 장비 시스템 표준 | `equipment_system.md` | 슬롯, 해금 타이밍, 랜덤 무기, 분해, 문장, 제작, 교정 정본 |
| 캠프 UI 표준 | `camp_ui_spec.md` | 허브 구조, 장비/창고/대장간/기록 화면 흐름 정본 |
| 수익화 방향 정본 | `monetization_spec.md` | 출시 이후 BM 방향, 상품 구조, 가격 가설 정본. 현재 구현 레인 비활성 |
| IAP entitlement 정본 | `iap_entitlement_spec.md` | 출시 이후 구매/복원/환불/게이팅 정본. 현재 구현 레인 비활성 |
| 스토어 자산 정본 | `store_asset_spec.md` | 출시 이후 스크린샷/메타데이터/프로모션 자산 정본. 현재 구현 레인 비활성 |
| 제품 스펙, 기술 제약, Codex 작업 규칙 | `docs/game_spec.md`, `docs/engineering_rules.md`, `docs/codex_workflow.md` | 시스템/개발 운영 정본 |

## 4. 작업 상태 기준

| 구간 | 상태 | 운영 규칙 |
| --- | --- | --- |
| 1장 | 확정 | `phase1.md`와 일치해야 함 |
| 2장 | 확정에 가까운 구현 설계 | `phase2.md`와 일치해야 함 |
| 3장 | 부분확정 | 장 번호와 구조는 `camp.md`, 구현과 장비 규칙은 `phase3+item.md` 우선 |
| 4장 | 부분확정 | `phase4.md`의 Chapter 4 story section 우선 |
| 5장 | 부분확정 | `phase5+@.md`의 Chapter 5 story section 우선 |
| 6장 | 부분확정 | `phase6.md` 우선 |
| 7장 | 부분확정 | `phase7.md` 우선 |
| 8장 | 부분확정 | `phase8.md` 우선 |
| 9장 | 부분확정 | 구조는 `phase5+@.md`, 세부는 `phase9-1.md` / `phase9-2.md` 우선 |
| 10장 | 부분확정 | `phase10.md` 우선 |

## 5. 앞으로의 동기화 규칙

- 새로운 장 요약은 먼저 `camp.md`의 번호 체계를 따른다.
- 단, 9장은 예외적으로 `Part I / Part II` 구조를 쓴다.
- 장 구현에 들어가면 `phase3.md`, `phase4.md` 같은 방식으로 별도 구현 문서를 추가한다.
- `phase3+item.md`처럼 장 구현과 시스템 확장안이 결합된 문서가 생기면, 해당 장 범위에서는 그 문서를 구현 정본으로 취급한다.
- `phase4.md`와 `phase5+@.md`처럼 혼합 문서는 story section과 system section을 분리해서 읽는다.
- `synopsis.md`는 상위 요약본이므로, 구현 상세를 직접 길게 누적하지 않는다.
- `camp.md`와 `synopsis.md`가 충돌하면 먼저 `camp.md`의 장 구조를 확인하고 `synopsis.md`를 맞춘다.
