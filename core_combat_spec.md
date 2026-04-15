# Core Combat Spec v1
## Project: 잿빛의 기억

## 1. 문서 목적

이 문서는 전투 시스템의 **캠페인 기준 정본 문서**다.  
캠페인 문서, 장비 문서, AI 문서, 개별 장 스펙 문서는 모두 이 문서의 전투 규칙을 기준으로 작성한다.

다만 이 문서는 `MVP 수직 슬라이스`와 `캠페인 확장 규칙`을 함께 담는다.
즉, 모든 항목이 첫 구현 단계에 바로 들어가야 한다는 뜻은 아니다.

문서 위계는 아래처럼 고정한다.

1. `docs/game_spec.md`
   - 현재 MVP 범위와 비범위를 고정한다.
2. `docs/engineering_rules.md`
   - 현재 구현 방식, 데이터 계약, 우선순위를 고정한다.
3. `core_combat_spec.md`
   - 위 두 문서 범위를 넘지 않는 선에서 캠페인용 전투 규칙을 표준화한다.
4. `master_campaign_outline.md`, `phase*.md`
   - 어떤 규칙이 어느 장에서 열리는지와 연출 맥락을 고정한다.

이 문서가 고정하는 것은 아래 항목이다.

1. 전투의 기본 흐름과 페이즈 순서
2. 유닛 1턴의 행동 규칙
3. 전투 계산식
4. 지형 / 상태이상 / 상호작용 오브젝트 규칙
5. 보스 패턴의 공정성 기준
6. 밸런스 목표와 구현 우선순위
7. MVP와 캠페인 확장 규칙의 경계

---

## 2. 핵심 설계 원칙

전투 시스템은 아래 원칙을 절대 기준으로 삼는다.

### 2-1. 읽히는 전투
- 플레이어는 대부분의 결과를 **행동 전에 예측**할 수 있어야 한다.
- 숨은 규칙, 숨은 보정, 숨은 난수는 최소화한다.
- “왜 맞았는지 / 왜 죽었는지 / 왜 실패했는지”가 항상 설명 가능해야 한다.

### 2-2. 한 번의 교환, 명확한 결과
- 기본 전투는 **1회 공격 + 조건부 1회 반격** 구조로 간다.
- 속도에 따른 연속공격, 복잡한 추격 계산은 기본 규칙에서 제외한다.
- 연속행동, 재이동, 추가타는 **스킬 / 보스 기믹 / 인연 보조**로만 허용한다.

### 2-3. 상태이상과 지형이 수치보다 중요하다
- 단순 ATK, DEF 수치 싸움보다
  - 망각
  - 표식
  - 은신
  - 정화 / 오염
  - 고지 / 숲 / 포대
  같은 전장 요소가 더 중요해야 한다.

### 2-4. 공정성 있는 보스전
- 강한 기술은 반드시 **텔레그래프**를 준다.
- 갑작스러운 전장 개정, 즉사급 광역기, 구조 실패는 사전 예고 없이 발동하지 않는다.
- 최종전조차 “대응 수단이 있는 위협”이어야 한다.

### 2-5. 모바일 우선
- 규칙은 깊되 입력은 단순해야 한다.
- 한 유닛 1턴은 가급적 `이동 → 행동 → 종료` 흐름으로 읽혀야 한다.
- 드래그보다 탭, 숨은 계산보다 미리보기 우선.

---

## 3. 범위와 비범위

### 이 문서 범위
- 메인 캠페인 전투
- 회상 토벌전 전투
- 보물상자 / 레버 / 구조 / 보스 기믹이 있는 SRPG 전투
- MVP에서 먼저 구현할 최소 전투 루프
- 이후 캠페인에서 확장할 상태이상 / 오브젝트 / 최종전 규칙

### 이 문서 비범위
- 성장식
- 스탯 레벨업 곡선
- 상점 경제
- 확률형 드롭 세부 수치
- 컷신 연출 길이
- AI 상세 우선순위 전체
  - 향후 별도 `ai_behavior_spec.md`로 분리 가능
  - 현재는 `docs/game_spec.md`의 MVP AI와 이 문서의 공정성 원칙을 따른다

### 3-1. MVP 최소 구현 범위

첫 수직 슬라이스에서 반드시 필요한 전투 규칙은 아래다.

- 정사각형 그리드
- 4방향 이동
- 8x8 기본 맵
- 2 아군 / 2 적
- Plain / Forest / Wall
- 선택 → 이동 → 공격 또는 대기
- 인접 기본 공격
- 1회 반격
- 승리 / 패배 조건
- 가장 가까운 적에게 접근하는 단순 AI
- 선택 유닛 / 이동 가능 칸 / 공격 가능 상태 / 턴 페이즈 UI

### 3-2. 캠페인 확장 범위

아래는 캠페인용 확장 규칙이며, MVP 이후 단계적으로 붙인다.

- 상태이상 다층 구조
- 지휘 명령과 보조 공격
- LoS 기반 원거리 판정
- 공격형 오브젝트
- 전장 개정
- 이름 앵커 / 공명탑
- 최종전 전용 이름 부름

---

## 4. 전장 기본 전제

### 4-1. 그리드
- 전장은 **정사각형 격자**
- 구현 기준 좌표는 좌상단 `(0,0)`의 엔진 좌표계로 고정한다
- 문서에서 사람이 읽기 쉽게 1-based 번호를 쓸 수는 있지만, 데이터/배치/디버그 기준은 항상 0-based다
- 이동은 **4방향(상하좌우)** 기준
- 사거리 계산은 **맨해튼 거리** 기준

### 4-2. 라인 오브 사이트(Line of Sight)
- `LoS`는 원거리/특수 스킬용 확장 규칙이다
- MVP 기본 근접 전투는 `LoS` 없이도 동작해야 한다
- 기본 단일 원거리 공격은 `LoS`를 확인한다
- `LoS`를 막는 것:
  - 벽
  - 닫힌 문
  - 닫힌 성문
  - 높은 봉쇄 오브젝트
- `LoS`를 막지 않는 것:
  - 일반 유닛
  - 낮은 엄폐물
  - 숲
  - 연기/안개
- `ignore_los` 태그가 있는 스킬은 예외

### 4-3. 낙하 / 고저차
- 기본 규칙상 **낙사 없음**
- 절벽, 다리, 성루는 지형 보정과 이동 제약으로만 표현
- 추후 특정 스테이지에서만 예외 규칙을 데이터로 구현 가능

---

## 5. 유닛 기본 스탯

전투에서 직접 쓰는 기본 스탯은 아래로 고정한다.

- `HP`
- `ATK`
- `DEF`
- `RES`
- `HIT`
- `AVO`
- `CRIT`
- `MOVE`

### 파생 개념
- `Range Min / Max`: 무기 또는 스킬 데이터에서 제공
- `Crit Guard`: 기본적으로 `floor(RES / 2)` + 버프/지형 보정
- `Flat Damage Reduction`: 방어 스킬, 액세서리, 보호 효과 등으로 별도 계산
- `Status Resist`: 기본 스탯이 아니라 상태/장비/지형 효과로 처리

### 해석 기준
- `ATK`: 물리/마법/치유를 포함한 기본 작용력
- `DEF`: 물리 방어
- `RES`: 마법 방어 + 정신/기억 계열 저항의 기초값
- `HIT`: 명중 보정
- `AVO`: 회피 보정
- `CRIT`: 치명 확률 기초값

---

## 6. 무기 타입 기본 정의

초기 기준 무기 타입은 아래 5개로 고정한다.

- `Sword`
- `Lance`
- `Bow`
- `Staff`
- `Tome`

### 기본 역할
- `Sword`: 근접 범용
- `Lance`: 돌격 / 장교형 / 전열 압박
- `Bow`: 원거리 / 표식 / 정찰 / 처형
- `Staff`: 치유 / 정화 / 보호
- `Tome`: 마법 공격 / 봉인 / 전장 간섭

### 기본 무기 사거리 권장값
- 검: 1
- 창: 1
- 활: 2~3
- 지팡이: 1~2
- 마도서: 2

실제 사거리는 무기 개별 데이터가 우선한다.

MVP 구현 메모:

- 첫 수직 슬라이스는 인접 기본 공격 중심이므로 모든 무기 타입을 다 구현할 필요는 없다.
- 다만 데이터 구조는 위 5개 타입 확장을 견딜 수 있게 잡는다.

---

## 7. 페이즈 구조

전투의 기본 라운드 구조는 아래로 고정한다.

1. **Round Start Events**
2. **Player Phase**
3. **Guest / Neutral Phase**
4. **Enemy Phase**
5. **Round End Events**

### Round Start Events
- 턴 수 증가
- 예약된 스테이지 이벤트 확인
- 다음 페이즈 예고 표시
- 환경 텔레그래프 갱신

### Phase Start Events
각 페이즈 시작 시 아래를 처리한다.
- 해당 진영 시작 대사 / 이벤트
- 예약 증원 등장
- 예약 환경 효과 발동
- 보스 예고 패턴 갱신

### Phase End Events
- 페이즈 종료 체크
- 예약된 `next phase start` 효과 등록
- 일부 AI/환경 상태 갱신

---

## 8. 유닛 1턴 구조

유닛의 한 턴은 아래 순서로 처리한다.

1. **턴 시작 처리**
2. **이동**
3. **주 행동(Main Action)**
4. **대기(Wait) 또는 종료**
5. **턴 종료 처리**

### 8-1. 턴 시작 처리
- 턴 시작형 상태이상 / 타일 보정 확인
- 강제 이동 효과(`Lure`, 일부 보스 유도) 처리
- 시작 시 회복 / 정화 / 공명 효과 처리
- 행동 불가 상태면 바로 턴 종료

### 8-2. 이동
- 이동은 `MOVE` 범위 내에서 1회
- 기본 이동은 4방향
- 이동 후 아직 행동 전이라면 **이동 취소 가능**
- 단, 아래 경우 이동 취소 불가:
  - 숨은 함정 발동
  - 이벤트 트리거 타일 진입
  - 상호작용으로 지도 상태가 바뀜
  - 적 반응형 기믹 발동

### 8-3. 주 행동(Main Action)
주 행동은 아래 중 하나만 선택 가능하다.

- 기본 공격
- 스킬 사용
- 지휘 명령(Command)
- 지원/치유
- 아이템 사용
- 상호작용
- 대기

### 8-4. 종료
- 주 행동을 사용하면 기본적으로 그 유닛의 턴은 종료된다
- `after_action_move`, `free_interact`, `reposition_after_action` 태그가 있는 스킬/장비만 예외를 만든다

---

## 9. 행동 타입 정의

### 9-1. Basic Attack
- 현재 장비한 무기의 기본 공격
- 반격 가능
- 치명 가능
- 상태이상 부여는 무기/패시브/스킬 태그가 있을 때만 가능

### 9-2. Skill
- 무기 기반 또는 직업 기반 능동 스킬
- `cooldown` 또는 `battle charges` 사용
- 공격형 / 디버프형 / 이동형 / 봉인형 포함
- 스킬마다 `damage_type`, `range`, `tags`, `telegraph` 보유 가능

### 9-3. Support
- 치유 / 해제 / 버프 / 보호
- 아군 대상 지원은 기본적으로 **명중 판정 없음**
- 적 대상 디버프 지원은 스킬 데이터에 따라 명중 판정 사용 가능

### 9-4. Command
- 리안 등 특정 유닛의 지휘형 스킬
- 기본적으로 `battle charges` 사용
- 반격 없음
- 범위와 효과는 스킬 데이터에 따름
- `Forget 3중첩` 상태에서는 `signature` 또는 `command` 태그 스킬 사용 불가

### 9-5. Item
- 소비형 아이템 사용
- 기본적으로 주 행동 1회를 소비
- 아이템 효과는 고정 수치 또는 태그 기반
- 단, MVP 수직 슬라이스에서는 아이템 행동을 비활성화해도 된다

### 9-6. Interact
- 레버, 상자, 문, 구조 대상, 제어판, 공명탑 조작 등
- 기본적으로 주 행동 1회를 소비하고 유닛 턴 종료
- 예외:
  - `free_interact` 태그
  - 특정 액세서리(예: 관문공의 링)

### 9-7. Wait
- 남은 행동을 포기하고 턴 종료
- “이동 후 대기”도 정상 행동으로 취급

---

## 10. 행동 자원 규칙

### 10-1. 기본
- MP는 사용하지 않는다
- 능동 스킬은 `cooldown` 또는 `charges per battle`
- 아이템은 전투 중 사용 시 인벤토리/소모품 스택 차감

### 10-2. Cooldown
- 스킬 사용 후 `current_cooldown = max_cooldown`
- 쿨다운은 **해당 유닛 턴 종료 시 1 감소**

### 10-3. Charges
- 지휘 명령, 일부 보스 카운터 스킬, 특별 장비 스킬은 `charges per battle` 사용
- 전투 종료 전 회복되지 않음
- 특수 이벤트 또는 장비/패시브로 추가 회복 가능

---

## 11. 기본 전투 계산식

## 11-1. 명중 판정

```text
HitScore =
  Attacker.FinalHIT
  + Weapon.HIT
  + Action.HIT_Mod
  + Terrain.OffenseHitBonus
  + Status/Buff Modifiers

AvoScore =
  Defender.FinalAVO
  + Terrain.AvoBonus
  + Status/Buff Modifiers

HitChance = clamp(HitScore - AvoScore, 5, 95)
```

규칙

- 아군 대상 치유/버프는 기본적으로 명중 판정 없음
- `certain_hit` 태그 스킬은 `HitChance = 100`
- 오브젝트 공격은 기본적으로 명중 판정 없음, 자동 적중

## 11-2. 치명 판정

```text
CritGuard =
  floor(Defender.FinalRES / 2)
  + Terrain.CritGuardBonus
  + Buff Modifiers

CritChance =
  clamp(
    Attacker.FinalCRIT
    + Weapon.CRIT
    + Action.CRIT_Mod
    - CritGuard,
    0,
    35
  )
```

규칙

- 치명은 명중 성공 이후에만 판정
- 기본 치명 배율: 최종 피해 x `1.5`, 올림 처리
- `true damage`, 환경 피해, 오브젝트 공격은 기본적으로 치명 불가

## 11-3. 피해 계산

물리 공격

```text
AttackPower =
  Attacker.FinalATK
  + Weapon.MT
  + Action.PowerFlat
  + Buff/Situational Bonuses

DefensePower =
  Defender.FinalDEF
  + Terrain.DefBonus
  + Buff/Situational Bonuses
```

마법/정신 공격

```text
AttackPower =
  Attacker.FinalATK
  + Weapon.MT
  + Action.PowerFlat
  + Buff/Situational Bonuses

DefensePower =
  Defender.FinalRES
  + Terrain.ResBonus
  + Buff/Situational Bonuses
```

기본 공식

```text
RawDamage = AttackPower - DefensePower
PctMultiplier = product of tag/trait/status modifiers
FinalDamage =
  max(
    1,
    floor(RawDamage * PctMultiplier)
    + FlatDamageBonus
    - FlatDamageReduction
  )
```

주의

- `RawDamage <= 0` 이어도 기본 공격/유해 스킬은 최소 `1` 피해
- `status_only`, `support_only` 스킬은 피해 없이 상태만 줄 수 있음
- `true damage`는 `DEF`, `RES` 무시, 치명 불가

## 11-4. 치유 계산

```text
HealAmount =
  Action.HealBase
  + floor(Attacker.FinalATK * Action.HealRatio)
  + FlatHealBonus

FinalHeal =
  max(1, floor(HealAmount * HealReceivedMultiplier))
```

권장값

- 단일 치유 기본 `HealRatio`: `0.35 ~ 0.5`
- 범위 치유 기본 `HealRatio`: `0.2 ~ 0.3`

## 11-5. 상태이상 부여 규칙

기본 원칙:

- 공격이 적중하면 상태이상도 적용
- 별도 확률을 쓰는 상태이상은 스킬 설명에 명시
- 상태이상 저항은 장비 / 액세서리 / 지형 / 버프 / 보스 패시브로 처리

## 12. 반격 / 보호 / 보조 공격

### 12-1. 반격(Counter)

아래 조건을 모두 만족하면 1회 반격 가능하다.

수비자가 선공 공격 후 생존
수비자가 실제 공격 거리에서 반격 가능한 무기/스킬 보유
Sleep, Fear, Stun equivalent, cannot_counter 태그 상태가 아님
공격이 AoE, 환경 피해, 함정, 상호작용 피해가 아님
반격 규칙
반격은 1회만 발생
반격에 다시 반격은 발생하지 않음
반격도 명중/치명 판정을 정상적으로 사용
12-2. 보호(Guard / Protect)

기본 시스템에는 “보호 반응”을 지원한다.
모든 유닛이 가능한 것은 아니고, guard_reaction 태그가 있는 스킬/패시브/장비만 사용한다.

보호 발동 조건
보호자와 대상이 인접
보호자가 행동 불가 상태 아님
단일 타깃 공격임
공격이 ignore_guard 태그가 아님
보호 결과
보호자가 공격 대상을 대신 받음
상태이상도 보호자가 대신 받음
광역 공격은 대신 맞기 불가
12-3. 인연 보조(Bond Assist) — P1 이후

초기 MVP에는 필수 아님.
본 캠페인 확장 규칙으로 지원한다.

기본 규칙
인연 등급이 조건 이상인 아군이 인접해 있고
해당 아군이 무기 사거리 내이며
그 턴에 보조를 아직 쓰지 않았다면
주 공격 후 50% 위력 보조 공격 1회 가능
제한
치명 없음
반격 유발 없음
광역/지휘 스킬엔 기본 미적용
13. 지형 규칙

지형은 `MVP 필수 메타데이터`와 `확장 보정값`으로 나눠 처리한다.

MVP 필수 메타데이터:

- `move_cost`
- `terrain_type`
- `blocked`

확장 보정값:

- `defense_bonus`
- `avoid_bonus`
- `resist_bonus`
- `crit_guard_bonus`
- `offense_hit_bonus`

즉, 모든 전장에 모든 보정값이 당장 필요하다는 뜻은 아니다.
현재 엔지니어링 기준에서 우선 구현하는 것은 `move_cost`, `terrain_type`, `blocked`다.

13-1. 기본 지형
Plain
이동 비용 1
보정 없음
Forest
이동 비용 2
캠페인 확장 기준으로 AVO/DEF 보정 가능
High Ground / Stairs
이동 비용 2
해당 칸에서 시작한 원거리 공격 HIT +10
AVO +5
Wall / Closed Gate
통행 불가
LoS 차단
Shallow Water
이동 비용 2
DEF -1
일부 화상/불길 상호작용에 사용 가능
Deep Water
기본 통행 불가
특정 스테이지/스킬/유닛 태그가 있을 때만 통행
Bridge / Causeway
이동 비용 1
보정 없음
스테이지 기믹 우선 적용 가능
Ash
이동 비용 2
AVO -10
Fire Tile
이동 비용 1
턴 종료 시 3 True Damage
Purified Tile
이동 비용 1
턴 시작 시 Forget 1중첩 해제
Contaminated Tile
이동 비용 1
턴 종료 시 Forget 1중첩 부여
13-2. 데이터 기반 필드 효과

고정 지형 외에도 스테이지 전용 구역 효과를 지원한다.

이 항목은 `P2 이후` 확장 규칙이다.
MVP에서는 필수 아님.

예:

Silence Zone
Blank Zone
Anchor Zone
Resonance Pulse Zone
Command Lock Zone
구현 원칙
지형과 별개로 FieldEffectData를 중첩 적용 가능
한 타일에 지형 1개 + 필드 효과 N개 가능
필드 효과는 다음 타입을 지원해야 한다.
턴 시작 효과
턴 종료 효과
해당 칸 위 능력치 보정
스킬 태그 금지 / 약화
UI 텍스트 표시
14. 상태이상 규칙
14-1. Forget (망각)

이 게임의 핵심 상태이상. 최대 3중첩.

기본 효과
1중첩: HIT -6, AVO -6
2중첩: 누적 HIT -12, AVO -12, 비기본 액티브 스킬 위력 -10%
3중첩: 누적 HIT -18, AVO -18, signature 및 command 태그 스킬 사용 불가
규칙
최대 3중첩
기본적으로 자연 회복 없음
정화/치유/이름 앵커/특수 액세서리/보스전 전용 기믹으로 제거
같은 턴에 여러 번 중첩 가능
14-2. Mark (표식)

집중 공격의 핵심 상태.

효과
표식 대상은 적에게 HIT +10 보정 제공
특정 스킬/무기/AI가 표식 대상 우선
일부 스킬은 표식 대상에게 추가 피해 또는 추가 효과
지속
기본 1턴
대상의 다음 턴 종료 시 제거
14-3. Silence (침묵)
support, chant, staff, tome_magic 태그 스킬 사용 불가
기본 공격 가능
기본 1턴
14-4. Seal (봉인)
basic_attack, item, interact, wait 외 액티브 스킬 사용 불가
기본 1턴
14-5. Fear (공포)
MOVE -1
AVO -10
반격 불가
기본 1턴
14-6. Lure / Compel (유도)
대상 턴 시작 시, 유도 원점 또는 유도 구역 쪽으로 강제 1칸 이동
이동 성공 시 남은 MOVE -1
경로가 없으면 강제 이동 실패, 대신 AVO -10
NPC에게는 AI 목적지 가중치 변경으로 적용
14-7. Burn (화상)
턴 종료 시 3 Damage
불길 타일 위에서 종료 시 추가 +2 Damage
기본 2턴
물 / 정화 계열 효과로 즉시 제거 가능
14-8. Sleep (수면)
이동, 행동, 반격 불가
기본 1턴
직접 피해를 받으면 즉시 해제
해제된 턴에는 AVO -10
14-9. Stealth (은신) — P1 이후
적이 인접하지 않으면 직접 타깃 불가
AoE, reveal, true sight, 특정 장비/스킬은 예외
공격, 큰 상호작용, 적 인접 종료 시 은신 해제
은신 유닛은 윤곽 힌트 또는 그림자 UI로만 표시 가능
15. 상호작용 오브젝트 규칙
15-1. Chest
기본적으로 Interact로 개방
공격으로 파괴 불가
열면 즉시 보상 획득 또는 전투 종료 후 정산용 플래그 저장
15-2. Lever / Console / Switch
기본적으로 Interact
스테이지 상태 변경:
문 개방
수위 변화
봉화 해제
포대 정지
지름길 활성화
기본적으로 상호작용 후 유닛 턴 종료
15-3. Gate / Door
locked, sealed, destructible, controlled 타입 구분
일부는 열쇠/상호작용
일부는 공격 파괴
일부는 특정 이벤트 후 자동 개방
15-4. Destructible Object

예:

바리케이드
제단
공명탑
봉인주
붉은 주석 기둥
규칙
HP, DEF, RES 보유 가능
기본적으로 상태이상 면역
명중 판정 없음, 자동 적중
치명 없음
반격 없음
단, turret 태그가 있으면 반격 또는 페이즈 공격 가능
15-5. Ballista / Stage Weapon
스테이지 오브젝트로 처리
지정 타일 점유 + 상호작용 시 특수 공격 사용
사용 후 기본적으로 유닛 턴 종료
사거리, 위력, 텔레그래프 여부는 스테이지 데이터에 따름
15-6. Name Anchor / Resonance Tower

최종장 및 특수 스테이지용 핵심 오브젝트.

Name Anchor
주변 일정 반경에 보호 오라 제공
망각 축적 완화 또는 제거
보스가 파괴 목표로 삼을 수 있음
Resonance Tower
광역 파동 / 망각 펄스 / 전장 개정 트리거
공격 파괴 또는 특정 상호작용으로 무력화
16. 보스 설계 규칙
16-1. 텔레그래프 규칙

아래 공격은 반드시 최소 1회 예고한다.

광역 고위력 기술
강제 이동 / 지형 파괴
전장 전체 디버프
즉사급 또는 전멸급 연출
페이즈 전환 후 첫 핵심 기술
예고 수단
바닥 범위 표시
스킬명 배너
보스 대사
턴 타이머
UI 경고 아이콘
16-2. 보스 공정성 원칙
예고 없는 원턴 전멸 금지
소환된 적이 즉시 치명 콤보를 넣는 구조 금지
보조 목표 실패가 곧 즉사로 이어지지 않게 할 것
플레이어가 최소 두 가지 대응 수단을 가지게 할 것
위치 이동
장치 파괴
정화
끊기
보호
16-3. 페이즈 전환
기본 보스: 1~2회
최종 보스: 최대 3회
페이즈 전환 시
체력 잠금
대사
환경 변화
패턴 테이블 교체
를 허용
원칙
페이즈 전환은 플레이어 턴 중간이 아니라 행동 해석 완료 후 처리
전환 직후 즉시 광역 확정타를 넣지 않는다
전환 직후 최소 1턴의 대응 여지를 둔다
16-4. 전장 개정형 보스

멜키온, 카르온 같은 보스는 전장 규칙을 바꾼다.

필수 규칙
개정 내용은 최소 1턴 전에 예고
바뀌는 항목은 1회에 1~2개까지만
개정은 플레이어가 읽을 수 있는 텍스트로 표시
예: “다음 턴, 정화와 오염 구역이 뒤바뀝니다”
17. 난이도 / 밸런스 목표
17-1. 전투 시간 목표
소형 전투: 6~10분
중형 전투: 10~15분
보스전: 14~20분
최종전 파트: 15~20분
17-2. TTK(Time to Kill) 목표
일반 적
중립 상성 / 평범한 장비 기준
전열 유닛: 3~4히트에 쓰러져야 함
후열 유닛: 2~3히트에 쓰러져야 함
엘리트 적
전열: 4~5히트
후열: 3~4히트
보스
단순 딜 누적이 아니라
기믹 해제
장치 파괴
패턴 대응
를 포함해 5~8턴 이상 버티는 구조가 적당
17-3. 명중 목표
일반 적의 플레이어 상대
전열 상대로 55~75%
후열 상대로 70~90%
플레이어의 일반 적 상대
기본 70~90%
숲, 은신, 표식, 디버프가 있으면 크게 흔들릴 수 있음
17-4. 치유 목표
단일 치유 1회는 전열 HP의 30~45% 회복
광역 치유는 15~30%
치유 1회가 전투를 역전시키되, 탱크를 무한 유지시키면 안 됨
17-5. 망각 압박 기준
1~2장: 제한적 사용, 튜토리얼 수준
3~4장: 일부 적/기믹에서 간헐적 사용
5~7장: 중형 보스와 스테이지 핵심 기믹으로 사용
8~10장: 핵심 압박 축으로 사용
주의

정화/해제 수단이 없는 스테이지에서 Forget 3중첩을 과하게 뿌리지 않는다.

18. 챕터 구간별 적 수치 밴드

정확한 수치는 데이터 문서에서 조정하되, 대략 밴드는 아래를 기준으로 한다.

18-1. 초기 구간 (1~2장)
일반 적
HP: 18~26
ATK: 6~10
DEF: 1~4
RES: 0~3
HIT: 70~82
AVO: 5~12
보스
HP: 34~48
ATK: 10~14
18-2. 중초반 구간 (3~5장)
일반 적
HP: 24~34
ATK: 9~14
DEF: 3~6
RES: 2~6
HIT: 76~90
AVO: 10~18
보스
HP: 48~72
ATK: 14~20
18-3. 중반 구간 (6~8장)
일반 적
HP: 30~42
ATK: 13~19
DEF: 5~9
RES: 4~8
HIT: 82~96
AVO: 14~24
보스
HP: 70~110
ATK: 18~26
18-4. 후반 구간 (9~10장)
일반 적
HP: 36~50
ATK: 17~24
DEF: 7~12
RES: 6~12
HIT: 88~102
AVO: 18~28
보스
HP: 110~180
ATK: 24~34
주의

후반 보스 체력은 단순 수치로 늘리지 않는다.
장치, 전장 개정, 앵커, 페이즈를 통해 체감 난도를 만든다.

19. 플레이어 유닛 전투 역할 기준

각 유닛은 기본적으로 아래 역할을 가진다.

리안
기동형 지휘관
위치 교환, 약점 열기, 전술 재배치
세린
치유 / 정화 / 보호
망각 해제의 핵심
브란
탱커 / 대신 맞기 / 좁은 길목 장악
티아
정찰 / 표식 응징 / 은신 대응 / 고립 처형
에녹
전장 간섭 / 봉인 / 정보 해독
카일
돌격 / 장교형 딜러 / 직선 파괴
노아
예고 확인 / 공명 안정 / 완전 삭제 저지

이 역할을 무시하는 밸런스 조정은 피한다.
특정 장비로 약간 흔들 수는 있어도, 완전히 뒤집지는 않는다.

20. 패배 / 다운 / 생존 규칙
20-1. 플레이어 유닛
HP가 0 이하가 되면 Downed
전투에서 이탈
기본적으로 전투 후 복귀
특정 스테이지는 개별 패배 조건이 우선
예: “세린 사망 시 패배”
20-2. 적 유닛 / 일반 NPC
HP 0 이하 시 즉시 제거
20-3. 구조 대상
스테이지 데이터가 critical_npc = true면 사망 시 패배
아니면 단순 구조 실패로 처리 가능
20-4. 동시 처리
공격과 반격으로 양측이 동시에 HP 0 이하가 되면
선공자 먼저 판정
반격은 이미 선언되었으면 그대로 해석
그 뒤 동시 다운 처리
21. 구현 우선순위
21-1. P0 (반드시 먼저)
이동 / 취소 / 대기
기본 공격
기본 반격
선택 유닛 표시
이동 가능 칸 미리보기
공격 가능 대상 표시
Plain / Forest / Wall
승리 / 패배 조건
단순 Enemy AI
모바일 우선 HUD
21-2. P1 (캠페인 초중반 필수)
단일 치유
상자 / 레버 / 문
Forget / Mark / Burn
불길 / 정화 타일
Seal / Silence / Fear / Sleep
Stealth
Destructible objects
Ballista / stage weapons
Command skills
Guest / Neutral phase
보호 반응
공명탑 / 봉인주 등 공격형 오브젝트
21-3. P2 (후반/최종전용)
전장 개정
Blank Zone / Anchor Zone
이름 앵커
광역 규칙 반전
인연 보조
최종전 전용 이름 부름
22. 추천 Enum / 태그 목록
ActionType:
BASIC_ATTACK
SKILL
SUPPORT
COMMAND
ITEM
INTERACT
WAIT
DamageType:
PHYSICAL
MYSTIC
TRUE
HEAL
STATUS_ONLY
TerrainTag:
PLAIN
FOREST
HIGH_GROUND
WALL
CLOSED_GATE
SHALLOW_WATER
DEEP_WATER
BRIDGE
ASH
FIRE
PURIFIED
CONTAMINATED
FieldEffectTag:
SILENCE_ZONE
BLANK_ZONE
ANCHOR_ZONE
RESONANCE_ZONE
COMMAND_LOCK_ZONE
StatusId:
FORGET
MARK
SILENCE
SEAL
FEAR
LURE
BURN
SLEEP
STEALTH
SkillTags:
SIGNATURE
COMMAND
IGNORE_LOS
IGNORE_GUARD
AFTER_ACTION_MOVE
FREE_INTERACT
CERTAIN_HIT
CANNOT_COUNTER
OBJECT_ONLY
ALLY_ONLY
ENEMY_ONLY
23. 전투 해석 순서 의사코드
23-1. 유닛 턴 시작
start_unit_turn(unit):
  apply_start_of_turn_tile_effects(unit)
  apply_start_of_turn_status_effects(unit)
  resolve_forced_movement(unit)
  if unit.cannot_act:
    end_unit_turn(unit)
23-2. 행동 실행
resolve_action(actor, action, target):
  validate_range_and_los(actor, action, target)
  lock_movement_if_needed(actor)

  if action.type == SUPPORT and action.targets_ally:
    apply_support_effects()
  elif action.targets_object:
    deal_object_damage()
  else:
    roll_hit()
    if hit:
      roll_crit()
      deal_damage()
      apply_on_hit_status()
      check_defeat()

      if target_can_counter():
        resolve_counterattack()

  spend_action_resource(actor, action)
  mark_actor_acted(actor)
23-3. 유닛 턴 종료
end_unit_turn(unit):
  apply_end_of_turn_tile_effects(unit)
  apply_end_of_turn_status_effects(unit)
  reduce_cooldowns(unit)
  clear_one_turn_flags(unit)
23-4. 페이즈 종료
end_phase(faction):
  resolve_phase_end_events()
  spawn_scheduled_units_if_any()
  advance_to_next_phase()
24. 문서 사용 규칙

이 문서를 읽고 다른 문서를 쓸 때는 아래 형식을 따른다.

장 문서에서 전투 규칙을 적을 때
새 규칙을 만들지 말고, 이 문서의 항목을 참조한다
예:
“Forget 3중첩 시 signature 스킬 봉인”
“Fire Tile 종료 피해 3”
“Interact는 기본적으로 턴 종료”
새 예외 규칙을 만들 때

반드시 아래 순서로 적는다.

기본 규칙
예외 규칙
예외가 필요한 이유
UI 예고 방식

예고 없는 예외는 금지한다.

25. 최종 메모

이 전투 시스템의 핵심은 복잡한 수치 시뮬레이션이 아니다.
핵심은 아래 네 가지다.

이동의 선택
지형의 의미
망각과 이름의 압박
읽히는 보스전

즉 플레이어가 매 턴 이렇게 생각하게 만들면 된다.

어디로 움직일까
누구를 지킬까
무엇을 먼저 끊을까
지금 잃으면 안 되는 이름은 무엇인가

이 질문이 끝까지 유지되면, 캠페인의 전투는 서사와 같은 방향으로 굴러간다.
