# Farland Tactics — Phase 3 Feature Specs (Ideas A-J)

## Completion Checklist

### SPEC-A: Enemy Perspective Chapter
- [ ] **A-1** `EnemyPerspectiveManager.gd` 생성 — 스위치 컨트롤러
- [ ] **A-2** `enemy_perspective` 모드 플래그 in `battle_controller.gd`
- [ ] **A-3** CH07 레오니카 챕터에 Enemy Perspective 미션 타입 추가
- [ ] **A-4** `EnemyCommander.gd` — AI指挥官 로직 (우호적 AI 응답)
- [ ] **A-5** Mirror Mode UI 토글 — "적의 눈으로 보기" 버튼
- [ ] **A-6** Enemy Perspective 결과 → `progression_data.gd`에 `mirror_battles_won` 필드
- [ ] **A-7** CH07 미러 모드 클리어 시 고유 엔딩 크레딧: "류온도 언젠가 이 편이었다"
- [ ] **A-8** Runner: `enemy_perspective_runner.gd` 작성
- [ ] **A-9** Runner 검증 — godot headless 통과

---

### SPEC-B: World State Cascading Decisions
- [ ] **B-1** `progression_data.gd`에 `world_state_bits` Dict — 키-밸류 의사결정 추적
- [ ] **B-2** `DecisionPoint.gd` 신호 시스템 — 전투 전/중/후 hooks
- [ ] **B-3** `CascadeCalculator.gd` — 의사결정 → 챕터 N후 세계 상태影响 计算
- [ ] **B-4** 각 챕터별 DecisionPoint CSV/리소스 정의 (위치, 선택지, cascade 효과)
- [ ] **B-5** CH04-06 레오니카 가문 관련 3개 cascading decision 포인트
- [ ] **B-6** CH08-10 세계 재구성 관련 5개 cascading decision 포인트
- [ ] **B-7** `LedgerEntry`의 A/B choice → world_state_bits 변환 로직
- [ ] **B-8** CH10 최종전에서 "당신의 선택이 이 결말을 만들었다" 참조 메시지
- [ ] **B-9** World State Viewer UI — 엔드크레딧에 "[[당신이 만든 세계]]"
- [ ] **B-10** Runner: `world_state_cascade_runner.gd` 작성
- [ ] **B-11** Runner 검증

---

### SPEC-C: Bond Death Endings ⭐ 최우선
- [ ] **C-1** `BondEndingRegistry.gd` — 페어별 엔딩 데이터
- [ ] **C-2** `BattleController.gd`에 동시 사망 감지 로직 (`fallen_pairs[]`)
- [ ] **C-3** Rian+Noah 페어 엔딩: "함광" 시퀀스
- [ ] **C-4** Lete+Mira 페어 엔딩: "separated twins" 시퀀스
- [ ] **C-5** Melkion+??? 페어 엔딩: "philosopher's choice"
- [ ] **C-6** Random pair 폴백 엔딩: "we'll meet again"
- [ ] **C-7** 10초 슬로우모션 + 화면 어두워짐 이펙트
- [ ] **C-8** Pair Memorial 비석 생성 — 공유 비석 스프라이트
- [ ] **C-9** MemorialScene에 pair_section 탭 추가
- [ ] **C-10** EncyclopediaTabs에 Bond Endings 탭 추가
- [ ] **C-11** NG+ 시 Bond Ending 히스토리 이월
- [ ] **C-12** Runner: `bond_death_ending_runner.gd` 작성
- [ ] **C-13** Runner 검증

---

### SPEC-D: Evolving Battlefield Dynamics
- [ ] **D-1** `BattleFieldEvolution.gd` — 턴 기반 지형 변화 엔진
- [ ] **D-2** `EvolutionEvent.gd` — 각 변화 이벤트 정의
- [ ] **D-3** CH06 Castle Siege: 5턴 후 외벽 붕괴 이벤트
- [ ] **D-4** CH08 Dark Forest: 3턴마다 나무 쓰러짐 랜덤 이벤트
- [ ] **D-5** CH10 Final: 플레이어 행동에 반응하는 적 전략 변화
- [ ] **D-6** `tile_change_effect.gd` — 지형 변화 시각화 (파편, 연기)
- [ ] **D-7** `EvolutionWarningUI.gd` — "지형이 불안정합니다" HUD 알림
- [ ] **D-8** 유닛 포지션 재계산 — 변화된 지형의 유효성 검증
- [ ] **D-9** 전략적 의미: 빠른 승리 vs 장기전 계획 선택지 제공
- [ ] **D-10** Runner: `evolving_battlefield_runner.gd` 작성
- [ ] **D-11** Runner 검증

---

### SPEC-E: Async Multiplayer Tactics
- [ ] **E-1** `TacticalNote.gd` — 플레이어 설계 전술 저장은 Resource
- [ ] **E-2** `TacticalNoteManager.gd` — 생성/편집/삭제 UI
- [ ] **E-3** 전술 노트 네이밍 + 태그 시스템
- [ ] **E-4** (서버 의존) 온라인 저장 API 스텁 — `TacticsServer.gd`
- [ ] **E-5** 다른 플레이어 전술을 적으로再就业 — "용의 특공대" 보스 변형
- [ ] **E-6** 플레이어 설계자 이름이 보스 네임에 표시: "『홍길동의 특공대』"
- [ ] **E-7** 전술의 난이도 등급 — 설계자의 سابق 전적 기반
- [ ] **E-8** **오프라인 모드**: 서버 없이 local에서 전술 노트 활용
- [ ] **E-9** Encyclopedia의 "명명한 전술" 서브섹션
- [ ] **E-10** Runner: `async_tactics_runner.gd` (로컬 모드만)
- [ ] **E-11** Runner 검증

---

### SPEC-F: Commander's Tactical Flaw
- [ ] **F-1** `TacticalFlawDetector.gd` — 플레이어 반복 실수 패턴 감지
- [ ] **F-2** `CommanderProfile.gd` — 결점 트레이트 데이터
- [ ] **F-3** 실수 유형 분류: 후위 집착, 측면 무시, 날씨 무시, 유닛 전사
- [ ] **F-4** 3회 반복 → 결점 부여阀值
- [ ] **F-5** 결점이 指官官 스탯에 미치는 영향 정의
- [ ] **F-6** "완고" 결점: 후위 유닛 전투력 -10%
- [ ] **F-7** "공격적" 결점: 선프트 比 -15%
- [ ] **F-8** "고집" 결점: 날씨 효과 2배
- [ ] **F-9** "연민" 결점: 사망 유닛 30%几率 부상
- [ ] **F-10** World Timeline과 연동 — Ledger 선택이 결점 해소에도 영향
- [ ] **F-11** Commander Profile UI — "당신의 指官风格" 표시
- [ ] **F-12** Runner: `commander_flaw_runner.gd` 작성
- [ ] **F-13** Runner 검증

---

### SPEC-G: Ashes of the Fallen ⭐ 감성 임팩트
- [ ] **G-1** `AshesCollection.gd` — 적 유해 수집 시스템
- [ ] **G-2** 적 유닛 defeat 시 `last_words` 필드 참조
- [ ] **G-3** `AshesCollected[]` — MemorialWall scene용 배열
- [ ] **G-4** 적 유닛당 3개 음성 라인: defeat, retreat, death
- [ ] **G-5** MemorialWall scene — 적 유해 전용 구역
- [ ] **G-6** "적도 누군가의 아이다" 서사적 메시지
- [ ] **G-7** BestiaryPage에 적 유닛 정보 자동 추가
- [ ] **G-8** Ashes 희귀도 시스템 — 일반/희귀/전설 적 유해
- [ ] **G-9** 희귀 유해 수집 시 고유 아이템/스킬 보상
- [ ] **G-10** Encyclopedia의 "역사의 그림자" 탭 — 적 유해 기록
- [ ] **G-11** NG+ 시 Ashes 보존
- [ ] **G-12** Runner: `ashes_fallen_runner.gd` 작성
- [ ] **G-13** Runner 검증

---

### SPEC-H: Living Chronicle Engine ⭐ 스토리 핵심
- [ ] **H-1** `ChronicleEntry.gd` — 챕터별 연대기 엔트리
- [ ] **H-2** `ChronicleGenerator.gd` — 플레이 내용 → 서사 변환
- [ ] **H-3** 전투 로그 기반 자동 문체 선택 로직
- [ ] **H-4** 조용한 전략 → 시적 문체
- [ ] **H-5** 공격적 플레이 → 군인다운 문체
- [ ] **H-6** 플레이어 행동 패턴 감지 → Chronicle 어조 변화
- [ ] **H-7** CH07 ChronicleEntry: "류온, 성벽 위에서"
- [ ] **H-8** CH08 ChronicleEntry: "레오니카의 마지막"
- [ ] **H-9** CH10 ChronicleEntry: "선택한 사람들"
- [ ] **H-10** Chronicle Viewer UI — 책 형태 인터페이스
- [ ] **H-11** Chronicle 텍스트 자동 음성화 스텁 (TTS 플래그)
- [ ] **H-12** NG+ 시 ChronicleHistory 이월 + 새 Chronicle 추가
- [ ] **H-13** Runner: `living_chronicle_runner.gd` 작성
- [ ] **H-14** Runner 검증

---

### SPEC-I: Tactical Spotlight Moments ⭐ 전투 몰입
- [ ] **I-1** `SpotlightManager.gd` — 전투 중 특별 순간 감지
- [ ] **I-2** Triple Kill 감지: 1턴 3명 처치
- [ ] **I-3** Last Stand 감지: HP 5% 이하에서 적 처치
- [ ] **I-4** Weather Master 감지: 1턴에 3가지 날씨 효과 활용
- [ ] **I-5** Sacrifice Play 감지: 아군 살리려 스스로 사망
- [ ] **I-6** Triple Kill 시퀀스: 5초 슬로우 + "Carnage" 텍스트
- [ ] **I-7** Last Stand 시퀀스: 화면 붉어짐 + "Stubborn heart"
- [ ] **I-8** Weather Master 시퀀스: "Harmony with nature"
- [ ] **I-9** Sacrifice Play 시퀀스: 10초 슬로우 + 이별 대사
- [ ] **I-10** BGM 전환 시스템 — 일반 → 감정적 BGM
- [ ] **I-11** 全屏 반전 이펙트
- [ ] **I-12** Spotlight 히스토리 → Encyclopedia에 기록
- [ ] **I-13** Battle Result Screen에 Spotlight 모먼트 하이라이트
- [ ] **I-14** Runner: `tactical_spotlight_runner.gd` 작성
- [ ] **I-15** Runner 검증

---

### SPEC-J: Heirloom Legacy System ⭐终极 메타 시스템 (GI 5000)
- [ ] **J-1** `HeirloomData.gd` — 가문 유산 데이터 구조
- [ ] **J-2** 1周目 끝: "Farland의 노래" 자동 생성
- [ ] **J-3** 플레이어 선택 기반 서사적 요약 생성 로직
- [ ] **J-4** 2周目 시작: 가문의 상징 선택 UI
- [ ] **J-5** 가문 스킬 시스템 — 1周목 성취 → 2周목 스킬
- [ ] **J-6** 가문의 저주 시스템 — 1周목 유닛 사망 → 2周목 보스 강화
- [ ] **J-7** 가문의 용사 — 1周목 숨은 유닛 → 2周목 후원자
- [ ] **J-8** NG+ BadgeCurrency + Narrative 메타 통합
- [ ] **J-9** Heirloom Tree UI — 가문의系譜 visualization
- [ ] **J-10** CH10 최종전에 1周目/2周목 분기
- [ ] **J-11** "당신의 여정" 최종 엔딩 크레딧
- [ ] **J-12** 모든 SPEC-A~I를 J에 통합하는 마스터 플래그
- [ ] **J-13** NG+ 복수 회차 시 가문 등급 상승 (3周목 → 가문장)
- [ ] **J-14** Runner: `heirloom_legacy_runner.gd` 작성
- [ ] **J-15** Runner 검증

---

## Implementation Priority Order

```
1. [C] Bond Death Endings       — 감성 임팩트 최대, 기존 memorial 확장
2. [I] Tactical Spotlight       — 전투 몰입도 급격히 향상
3. [G] Ashes of the Fallen     — 적 유닛에 감정 부여, 기존 enemy 데이터 활용
4. [H] Living Chronicle        — 스토리 자동 생성, 기존 dialogue 시스템 활용
5. [J] Heirloom Legacy         —终极 메타, 다른 SPEC을 관통하는 종착점
6. [A] Enemy Perspective       — 높음 난이도, CH07 보스 레오니카 연계
7. [F] Commander's Flaw         —指官官 개성 시스템, strategic depth 추가
8. [B] World State Cascade     — 복잡한 의존성, 기존 Ledger 확장
9. [D] Evolving Battlefield    — 전술적 깊이, 기존 terrain 시스템 활용
10. [E] Async Multiplayer     — 서버 의존, 오프라인 스텁 우선
```

## Cross-Spec Dependencies

```
SPEC-J (Heirloom) requires: SPEC-C, SPEC-H, SPEC-G
SPEC-I (Spotlight) enhances: SPEC-C, SPEC-G
SPEC-B (Cascade) enables: SPEC-F, SPEC-J
SPEC-A (Enemy View) requires: SPEC-B (world state)
```

## Runner Pattern (공통)

모든 SPEC에는 반드시:
1. `scripts/dev/[feature]_runner.gd` 작성
2. `godot --headless --path . --script scripts/dev/[feature]_runner.gd` 통과
3. 커밋 전 모든 previous runners 재실행确认

---

**Total: 143 checklist items across 10 specs**
