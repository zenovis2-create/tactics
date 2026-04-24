# Farland Tactics — Quick Checklist
## 파랜드 택틱스 개발 체크리스트 (간단판)

> 마지막 업데이트: 2026-04-17

---

## 현재 완료: 38/72 항목 (~53%)

---

## 🔴 즉시 (1~2주)

### 컷신 (12/22)
- [X] `ch01_opening`, `ch01_start`, `ch01_clear`, `ch01_fragment_flash`
- [X] `ch02_01_intro`, `ch02_05_intro`, `ch02_05_outro`
- [X] `ch03_01_intro`, `ch03_05_intro`, `ch03_05_outro`
- [X] `ch04_01_intro`, `ch04_05_intro`, `ch04_05_outro`
- [X] `ch05_01_intro`, `ch05_05_intro`, `ch05_05_outro`
- [X] `ch06_01_intro` ~ `ch10_true_ending` (카탈로그 내 전체 등록 완료)
- [ ] 스테이지 .tres 와 클리어 컷신 연동 점검

### 보스 패턴 (5/10)
- [X] 1장 Roderic: mark→charge / enrage→charge_row / despair→cross
- [X] 2장 발가르: 방어진+포대 / 돌진 / 결전버프
- [X] 3장 바실: 침수/수위변화 / 정화제단
- [X] 4장 사리아: 망각장판 / 시민구조
- [X] 5장: 화재/붕괴타일 / 턴제한
- [ ] 6장 발가르: 포대점령 / 외벽파괴
- [ ] 7장 사리아: 시민대기열 / 정신지배
- [ ] 8장 레테: 은신/암살 / 분신/재집결
- [ ] 9A 바르텐: 삭제구역 / 감찰친위대
- [ ] 9B 멜키온: 전장규칙개정
- [ ] 10장 카르온: 왕의칙령 / 공백화 / 이름절단

### 시스템 (7/8)
- [X] `StageResolutionService` — 플래그 기반 진행 커밋
- [X] `EndingResolver` — 일반/진엔딩 판정
- [X] BondService 완전 구현 (지원공격/피핵분담/공격뽐너스)
- [X] 인벤토리 장비 슬롯 UI (무기/방어구/악세서리)
- [X] 상태이상 유닛 비주얼 (망각색상/공포떨림/표식)
- [X] 개별 스킬 리소스 31개
- [X] AI 보스 패턳별 확장 (2~5장)
- [ ] 4장 수위변화 / 7장 시민구조 전투 기믹 완성

---

## 🟡 단기 (3~4주)

### 시스템 (0/6)
- [ ] 5장 화재/붕괴타일 + 턴제한 전투 기믹
- [ ] 회상 토벌전 HuntBoard + 바실/사리아/레테
- [ ] 메타 시스템 (대장간/인챈트/재련) 완전 구현
- [ ] 인연 Bond 비주얼 (연결선/FX) — 기본 완료, 세부 FX 개선
- [ ] 엔딩 컷신 분기 로직
- [ ] 스킬 레벨업 연동 (SkillLevelUpService 배틀 연결)

---

## 🟢 완료 (38/72)

### 컷신 (12/22)
- [X] 1~10장 인트로/아웃트로 카탈로그 등록

### 보스 패턴 (5/10)
- [X] 1~5장 기본 패턴 + 텔레그래프

### 시스템 (21/40)
- [X] 턴제 전투 엔진
- [X] 유닛 이동/공격/상호작용
- [X] 전투 AI
- [X] CombatService 데미지 파이프라인
- [X] StatusService — 망각/공포/표식/매혹/DoT
- [X] CombatService 상태이상 연동
- [X] 멀티페이즈 보스 시스템
- [X] 텔레그래프 시스템 (그리드+HUD)
- [X] SkillData + HUD 스킬 패널
- [X] 스킬 타겟팅 로직
- [X] 장비 데이터 시스템
- [X] 인벤토리 열기/닫기 + 장비 슬롯 교체
- [X] CampaignController
- [X] 플래그 시스템 설계 명세
- [X] BondService 스켈레톤 + 전투 연동
- [X] CampController/HUD
- [X] SaveService
- [X] CutscenePlayer/Overlay
- [X] EndingResolver
- [X] StageResolutionService
- [X] SkillLevelUpService (스크립트 완료)

---

## 체크리스트 체크 방법

```
총 항목: 72개
완료:    38개  → 53%
단기:    11개  → 15%
즉시:    23개  → 32%
```

**완성 목표: 80% (58/72)** — 4주 소요 예상
