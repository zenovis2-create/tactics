# AI Behavior Spec v1
## Project: 잿빛의 기억

## 1. 문서 목적

이 문서는 적, 중립, 게스트, 보스가 전투 중 어떻게 판단하고 움직일지를 고정하는 문서다.

이 문서가 고정하는 것은 아래 여섯 가지다.

1. AI가 사용하는 정보의 범위
2. 행동 선택 순서
3. 공통 점수화 규칙
4. 역할별 AI 프로필
5. NPC / 구조 대상 / 보스의 특수 규칙
6. 공정성과 재현성을 위한 제한

이 문서는 `core_combat_spec.md`를 전제로 한다.  
즉, 전투 계산식과 상태이상 규칙은 이미 정해져 있다고 보고,  
AI는 그 규칙을 **어떻게 활용할지**만 정의한다.

---

## 2. 핵심 설계 원칙

### 2-1. AI는 영리해야 하지만 치사하면 안 된다
플레이어가 패배했을 때 이렇게 느끼는 것이 목표다.

- “아, 저 행동은 이해된다.”
- “내가 그 자리에 서 있으면 위험했겠네.”
- “다음엔 저 패턴을 읽고 대응할 수 있겠다.”

반대로 아래 느낌은 실패다.

- “왜 저걸 알지?”
- “내가 아직 안 연 정보까지 쓰네?”
- “그냥 치팅하는 것 같다.”

### 2-2. AI는 읽히는 규칙으로 움직인다
적은 역할에 맞는 우선순위를 가진다.

- 병사는 전선을 유지하고
- 궁수는 약한 뒤열을 노리고
- 흑견은 고립된 적을 잡고
- 사리아는 시민을 정화 원형으로 유도하고
- 멜키온은 전장 규칙 자체를 뒤엎고
- 카르온은 이름 앵커를 끊고 공명을 분해한다

즉, 적 행동은 “개별 적의 성격”보다 **역할과 철학**을 더 강하게 반영해야 한다.

### 2-3. AI는 비공개 정보를 쓰지 않는다
AI는 아래만 안다.

- 현재 자신이 시야로 확인 가능한 유닛
- 이미 공개된 오브젝트 상태
- 자기 편이 예고한 보스 패턴
- 스테이지 목표와 자기 역할
- 이미 드러난 함정, 문, 수위, 탑 상태

AI는 아래를 기본적으로 모른다.

- 아직 열지 않은 상자 위치의 보상
- 아직 발각되지 않은 은신 아군
- 플레이어가 다음 턴 무엇을 할지
- 아직 공개되지 않은 숨은 통로
- 미발동 스테이지 이벤트의 미래 상태

예외가 필요한 경우는 **스크립트 보스 패턴**에서만 허용한다.  
그 경우도 플레이어에게 반드시 텔레그래프가 보여야 한다.

### 2-4. 같은 입력에는 같은 출력이 나와야 한다
동일한 전장, 동일한 위치, 동일한 상태에서  
AI가 매번 완전히 다른 행동을 하면 테스트와 밸런싱이 무너진다.

따라서 AI는 기본적으로 **결정적(deterministic)**이어야 한다.  
동점일 때만 고정 시드 기반 tie-break를 허용한다.

### 2-5. AI는 목적을 가진다
모든 적은 아래 셋 중 하나 이상을 갖는다.

- 공격 목적
- 방어 목적
- 오브젝트 목적

예를 들어:
- 바실은 제단을 살려 망각 압박을 유지하려 한다
- 발가르는 중앙 광장을 지키며 전열을 세운다
- 레테는 승리보다 고립 처형을 우선한다
- 바르텐은 증언자와 구조 대상을 삭제하려 든다

즉, AI는 단순히 “가장 가까운 적을 때린다”가 아니다.

### 2-6. AI는 실패했을 때도 의미 있게 실패해야 한다
허술한 AI가 갑자기 멍청하게 멈추거나,  
합리적 선택이 없다고 해서 제자리 대기만 반복하면 전투가 무너진다.

따라서 AI는 좋은 선택이 없더라도 아래 중 하나는 하도록 설계한다.

- 목표 지점으로 접근
- 아군 오라 범위로 복귀
- 방어 지형 선점
- 다음 턴 유리한 각도 확보
- 위험 오브젝트 보호

---

## 3. AI 정보 모델

AI는 각 턴 시작 시 `BattleContext`를 읽는다고 가정한다.

```text
BattleContext
- visible_enemies[]
- visible_allies[]
- known_neutrals[]
- visible_objects[]
- objective_state
- active_field_effects[]
- current_turn
- current_phase
- revealed_traps[]
- predicted_hazard_zones[]
- script_flags[]
```

3-1. visible_enemies

AI가 시야 또는 감지 효과로 인식 가능한 적

3-2. visible_objects

AI가 상호작용/파괴 대상으로 삼을 수 있는 오브젝트
예:

제단
봉인주
공명탑
이름 앵커
성가 샘
검문 봉화
증언 코덱스
3-3. predicted_hazard_zones

이미 예고된 위험 구역
예:

포격 예정 구역
보스 광역기 예고 범위
다음 턴 수위 상승 위치
다음 턴 전장 개정 예상 범위

AI도 이 정보를 읽을 수 있다.
단, 플레이어가 본 것만큼만 읽는다.

3-4. Script Flags

보스와 스테이지가 갖는 명시적 스크립트 상태
예:

boss_phase_2_started
revision_cycle_b
anchor_west_broken
saria_springs_2_alive

이건 “비공개 미래 정보”가 아니라 현재 스테이지 상태다.

4. AI 행동 레이어

AI는 한 번에 생각하지 않고, 아래 4개 레이어를 순서대로 통과한다.

4-1. Script Layer

강제 스크립트 행동이 있는지 먼저 본다.

예:

로드릭 체력 60% 이하 시 증원 호출
바실이 제단이 2개 이상 남으면 익수 찬가 우선
멜키온이 개정핵이 살아 있으면 전장 개정 패턴 우선
카르온 2페이즈에서 이름 앵커 공격 루틴 진입
4-2. Objective Layer

해당 적의 목적을 평가한다.

예:

시민을 정화 원형으로 유도해야 하는가
구조 대상을 처치해야 하는가
제단을 살려야 하는가
검문선을 유지해야 하는가
봉화/탑을 지켜야 하는가
4-3. Tactical Layer

그 턴에 어떤 행동이 가장 큰 전술 이득인지 계산한다.

예:

치명타 가능
처치 가능
표식 후 연계 가능
힐/정화 가치 높음
봉인/침묵으로 핵심 스킬 차단 가능
4-4. Safety Layer

행동 이후의 생존성을 평가한다.

예:

불길 타일 위 종료
3명에게 둘러싸이는 위치
정화 구역에서 벗어나 망각 3중첩 위험
힐러가 보호 없이 전진
흑견이 은신 없이 적진 한가운데 남음
5. 행동 선택 흐름

AI의 표준 흐름은 아래로 고정한다.

5-1. 턴 시작
상태이상과 턴 시작 효과 해석
강제 이동 해석
행동 불가 여부 확인
스크립트 상태 전환 여부 확인
5-2. 후보 생성

AI는 아래 후보를 만든다.

제자리 기본 공격
이동 후 기본 공격
이동 후 스킬 사용
이동 후 지원/치유
이동 후 상호작용
이동 후 대기
스크립트 강제 행동
5-3. 후보 필터링

아래는 후보에서 제거한다.

사거리/LoS 위반
자신이 못 쓰는 스킬
쿨다운/차지 부족
존재하지 않는 오브젝트 대상
스테이지 규칙상 금지된 상호작용
자살 확률이 지나치게 높은 이동
5-4. 점수화

남은 후보에 공통 점수식을 적용한다.

5-5. 결정

최고 점수 행동을 고른다.
동점일 때는 tie-break 규칙을 적용한다.

5-6. 실행

행동 후 다시 “추가 행동 가능 여부”를 확인한다.
예:

after_action_move
free_interact
보스 phase script
6. 공통 점수식

모든 행동은 아래 점수축을 가진다.

ActionScore =
  ObjectiveScore
  + KillScore
  + DamageScore
  + StatusScore
  + SupportScore
  + PositionScore
  + ScriptScore
  - RiskScore
  - WasteScore

각 항목은 기본적으로 아래 기준을 가진다.

6-1. ObjectiveScore

행동이 스테이지 목표를 얼마나 진전시키는가

기준값
필수 오브젝트 파괴: +90
구조 대상 처치 가능: +85
시민을 정화 원형으로 1칸이라도 더 유도: +50
이름 앵커 타격 가능: +70
검문선 유지 타일 점령: +45
제단/봉인주/성가 샘 보존에 기여: +40
대피선 차단: +35
비고

보스와 commander_support AI는 이 항목 가중치가 높다.

6-2. KillScore

이번 행동으로 적을 쓰러뜨릴 가능성

기준값
확정 처치: +80
높은 확률 처치(명중 80%+): +60
2인 연계 시 다음 행동 처치 확정: +40
구조 대상/증언자/NPC 처치: +추가 20~40
힐러/지휘관 처치: +추가 15~25
우선 타깃 태그
critical_npc
healer
commander
support_core
isolated
marked
6-3. DamageScore

처치까지는 아니어도 의미 있는 압박인가

기준값
대상 HP의 50% 이상: +30
대상 HP의 30~49%: +20
다음 적이 마무리하기 쉬운 체력으로 만드는 경우: +15
보호 반응이나 버프를 강제로 빼는 경우: +10
감점
1 피해만 넣고 끝나는 공격: -10
딜보다 상호작용이 중요한 턴인데 굳이 딜: -15
6-4. StatusScore

상태이상이 전술적으로 의미 있는가

기준값
Forget 2 → 3중첩: +35
Forget 0 → 1중첩: +10
Mark 부여 후 후속 연계 가능: +25
Seal로 핵심 스킬 차단: +30
Silence로 세린/에녹/노아 차단: +25
Fear로 반격 봉쇄: +18
Lure로 시민/NPC를 정화 원형 쪽으로 당김: +20
Burn으로 이동 제약 구간 압박: +12
감점
이미 같은 상태가 충분한 대상에 중복 사용: -10
보스 phase script보다 덜 중요한 상태를 남발: -15
6-5. SupportScore

치유, 정화, 버프, 보호의 가치

기준값
보스나 핵심 장교를 죽음에서 살림: +60
Forget 3중첩 아군 해제: +50
구조 성공에 직접 기여하는 힐/보호: +40
표식 제거 또는 정신 간섭 해제: +25
다음 턴 lethal 방지용 Guard/Barrier: +30
감점
5~10% HP만 회복하는 과힐: -10
danger zone 안에서 자기 힐만 하고 포지션 망침: -12
6-6. PositionScore

행동 후 남는 타일의 가치

기준값
숲/고지/방어 지형 점유: +8 ~ +20
목표 오브젝트 인접 종료: +15
commander 오라 범위 유지: +12
healer 보호 범위 유지: +10
assassin이 은신 유지 가능한 타일로 종료: +18
archer가 LoS 확보 + 보호 타일: +15
감점
불길 타일 종료: -40
다음 턴 예고 광역 구역 종료: -35
고립 종료(2칸 내 아군 없음)이며 profile이 고립형이 아님: -15
이동만 하고 의미 없는 빈 타일 종료: -8
6-7. ScriptScore

보스/특수 AI 전용 가중치

기준값
패턴 루프 유지: +20 ~ +100
phase 전환 조건 충족: +25
보조 목표 압박 강화: +20
연출 우선 턴: +50
비고

보스는 ScriptScore가 매우 크다.
단, ScriptScore가 있다고 해서 Suicide Rule을 무시하진 않는다.

6-8. RiskScore

행동 후 위험 부담

기준값
다음 플레이어 턴 확정 lethal 범위: +60 위험
2명 이상에게 동시에 반격/집중됨: +25 위험
healer가 전열 밖으로 노출됨: +30 위험
boss tether/anchor 범위 이탈: +20 위험
표식 상태로 적진 한복판 종료: +15 위험
비고

Tank/Guard 계열은 RiskScore를 덜 두려워한다.
Assassin/Archer/Healer는 더 크게 본다.

6-9. WasteScore

의미 없이 자원을 낭비하는 행동

기준값
차지형 스킬을 가치 없이 사용: -20
heal/cleanse가 별 의미 없는 대상에게 들어감: -12
같은 턴에 이미 충분히 봉쇄된 대상을 또 봉인: -10
목표 오브젝트를 때려도 깨지지 않고 딜 가치도 낮음: -8
7. Tie-break 규칙

동점일 때는 아래 순서로 결정한다.

확정 처치가 있는 행동 우선
스테이지 목표와 더 직접 연결된 행동 우선
limited resource를 덜 쓰는 행동 우선
더 안전한 종료 위치 우선
더 짧은 이동 경로 우선
더 위쪽 / 더 왼쪽 타일 우선
(완전 결정적 처리를 위해 좌표 순 고정)

즉, AI는 동점일 때도 “매번 다르게” 행동하지 않는다.

8. 정보 제한과 공정성 규칙
8-1. 은신 적 처리

AI는 기본적으로 은신 적을 타깃할 수 없다.

예외:

인접한 경우
reveal 효과를 가진 스킬/패시브 사용
같은 턴 아군이 이미 드러냈음
스크립트 보스가 특정 페이즈에서 일시 reveal 권한을 가짐
8-2. 안개 / 시야 제한

AI도 시야 제한을 받는다.
단, commander 또는 beacon 네트워크로 공유 시야가 있는 스테이지는 예외적으로 더 넓은 정보를 얻을 수 있다.

8-3. 미공개 함정

AI는 공개되지 않은 함정을 모른다.
다만 해당 세력의 고유 함정이라면 배치한 본인만 알고 있다.

예:

흑견부대가 설치한 암살 덫은 흑견이 안다
숲 일반 병사는 그 덫을 정확히 모를 수 있다
8-4. 플레이어 입력 예측 금지

AI는 “플레이어가 다음 턴 어떤 유닛을 움직일지”를 모른다.
오직 현재 보이는 배치와 위협 범위만 본다.

8-5. 보스의 지도 치트 금지

보스도 아래는 모르면 안 된다.

아직 열리지 않은 비밀방 위치를 “직접 공격 대상”으로 삼는 것
아직 획득 안 한 보물상자 보상 종류를 알고 우선 대응하는 것
reveal되지 않은 노아/티아 위치를 광역기 중심점으로 정확히 지정하는 것
9. 이동 규칙
9-1. 기본 이동 평가

AI는 도달 가능한 모든 종료 타일을 완전 탐색하지 않아도 되지만,
최소한 아래 후보를 검토해야 한다.

현 위치
최단 공격 가능 타일
최단 스킬 가능 타일
방어 지형 타일
오브젝트 인접 타일
commander/support 범위 유지 타일
위협 최소 타일
9-2. 금지 이동

기본적으로 아래는 금지한다.

이유 없이 불길 타일 종료
즉시 lethal이 확정되는 광역 예고 구역 종료
오브젝트를 지켜야 하는 AI가 그 오브젝트에서 너무 멀어짐
healer가 전열보다 앞에 서는 이동
assassin이 처치도 못 하면서 은신 없이 전진
9-3. 허용 이동

아래는 위험해도 허용한다.

boss lethal 또는 objective lethal 확보
구조 대상/NPC 처치가 전투 승리에 직접 연결
phase script가 강제하는 위치 이동
마지막 앵커 타격 직전
commander가 결판용 돌진 패턴 진입
9-4. 실패-완충 이동

좋은 행동이 없을 때 AI는 아래 중 하나를 한다.

가장 가까운 방어 지형으로 이동
힐러/지휘 오라 범위로 복귀
목표 타일과의 거리를 줄임
다음 턴 사거리 각을 잡는 타일로 이동
고립 해소를 위해 아군 쪽으로 붙음
10. 공통 타깃 우선순위 태그

모든 유닛/오브젝트는 아래 전술 태그를 가질 수 있다.

commander
healer
support_core
ranged_fragile
tank
critical_npc
escort_target
witness
anchor
altar
codex
beacon
tower

AI는 profile마다 이 태그 가중치를 다르게 읽는다.

예:

assassin_black_hound → isolated, marked, ranged_fragile, witness 선호
deletion_commander → witness, escort_target, critical_npc 선호
fortress_guard → altar, beacon, tower, choke point 선호
11. 역할별 기본 AI 프로필

아래 프로필은 AIProfileData.role 기준의 표준 행동 템플릿이다.

11-1. melee_grunt
역할

기본 근접병

목표 성향
전선 유지
가까운 적 압박
commander 오라 안에서 싸움
우선순위
가까운 적 공격
처치 가능한 후열 공격
보호 없는 적 압박
목표 타일 유지
행동 특징
스킬이 있어도 기본 공격 우선
저체력일 때도 완전 후퇴하지 않고 방어 지형 선호
혼자 깊이 들어가지 않음
가중치
Aggression: 1.0
Safety: 0.8
Objective: 0.7
Formation: 1.0
11-2. shield_guard
역할

방패병 / 탱커 / 문지기

목표 성향
좁은 길목 점유
보호 반응 유지
오브젝트 방어
우선순위
목표 타일 점유
인접 아군 보호
적 이동 차단
느리지만 안정적으로 공격
행동 특징
딜보다 위치를 우선
방어 지형 점유 점수를 크게 받음
commander 또는 boss와의 인접을 선호
가중치
Aggression: 0.7
Safety: 1.2
Objective: 1.2
Formation: 1.3
11-3. lancer_officer
역할

돌격 창병 / 장교형 선봉

목표 성향
직선 돌격
고립된 적 또는 후열 찌르기
진형 돌파
우선순위
3칸 이상 이동 후 강한 타격
low DEF / ranged target 압박
commander 지시 타깃 추격
돌격 후 비교적 안전한 선에 복귀
행동 특징
직선 경로 가치를 높게 봄
돌격로가 없다면 무리하게 진입하지 않고 다음 턴 각도 잡기 가능
카일 계열과 상위 commander가 자주 사용
가중치
Aggression: 1.3
Safety: 0.8
Objective: 0.9
Formation: 0.8
11-4. archer_control
역할

궁수 / 후열 압박 / 구조 대상 처형

목표 성향
fragile target 공격
marked target 마무리
안전한 LoS 유지
우선순위
healer / support_core / critical_npc 공격
marked target 마무리
이동 없이 사선 유지 가능한 타일 선호
위험하면 후퇴 사격
행동 특징
절대 전열 앞에 서지 않음
LoS와 safety를 동시에 본다
고지 점유 가치를 크게 본다
가중치
Aggression: 1.1
Safety: 1.2
Objective: 0.8
Formation: 0.9
11-5. healer_chanter
역할

성가병 / 치유사 / 버프 지원

목표 성향
boss 또는 elite 유지
Forget / Seal 해제
시민/NPC 유도 또는 보호
우선순위
핵심 아군 생존
boss script 유지용 버프
표식 제거 / 망각 완화
직접 공격은 마지막 선택
행동 특징
heal threshold를 가진다
체력 55% 이하 우선 힐
중요한 boss/elite는 70% 이하에서도 힐
과힐을 싫어함
danger zone 안에서 무의미한 힐 금지
가중치
Aggression: 0.4
Safety: 1.3
Objective: 1.0
Support: 1.5
11-6. assassin_black_hound
역할

흑견 암살자 / 표식 사냥 / 고립 처형

목표 성향
isolated target 제거
mark → follow-up
reveal되기 전까지 생존
우선순위
고립된 후열
marked target
witness / escort_target
kill 후 은신 복귀
행동 특징
처치 또는 매우 높은 value가 아니면 은신을 함부로 풀지 않음
reveal 후에도 다음 턴 은신 복귀 위치를 계산
allied crowd보다 edge lane을 선호
player가 anti-assassin 장비를 많이 갖춘 경우에도 무리 진입은 줄어듦
가중치
Aggression: 1.4
Safety: 1.0
Objective: 0.8
IsolationBias: 1.6
11-7. commander_support
역할

장교 / 지휘병 / 전장 유지

목표 성향
부대 전체 효율 상승
목표 타일/오브젝트 유지
kill보다 formation
우선순위
군기 / 봉화 / objective 유지
아군 버프
marked target 집중
직접 공격
행동 특징
자기 생존보다 지휘 범위를 우선할 때가 많음
지휘 오라 안에 병력이 몇 명 남는지 평가
commander가 죽으면 병사 패턴이 바뀌도록 설계 가능
가중치
Aggression: 0.8
Safety: 1.0
Objective: 1.3
Formation: 1.4
11-8. turret_operator
역할

포대 / 발리스타 / 고정 오브젝트 공격자

목표 성향
구조 대상/NPC 차단
choke point 폭격
clustered targets 압박
행동 특징
이동 거의 없음
지정 영역 또는 사거리 내 최고 가치 타깃 계산
예고형 포대는 predicted hazard로 1턴 전 표시
11-9. boss_controller
역할

보스 전용 상위 프로필

목표 성향
개별 턴 최적화보다 패턴 유지
보조 목표 압박
전장 기믹 유지
시네마틱 전환과 전술적 공정성 동시 달성
특징
Script Layer 비중이 매우 큼
특정 HP threshold에서 패턴 테이블 전환
행동 하나의 가치보다 “다음 턴 판짜기”를 더 높게 본다
12. NPC / 민간인 / 구조 대상 AI
12-1. civilian_flee
역할

겁에 질린 시민, 피난민

목표 성향
가장 가까운 safe zone으로 이동
유도/성가/정화 원형에 영향을 받을 수 있음
규칙
기본적으로 공격하지 않음
danger tile을 가능하면 피함
compel 또는 chant 영향 시 잘못된 방향으로 갈 수 있음
플레이어 인접 상호작용으로 경로 교정 가능
12-2. injured_survivor
역할

부상자 / 병사 / 수감자

규칙
초반에는 이동 없음
구조/상호작용 후 이동 시작
HP 낮으면 danger avoidance 강함
일정 턴 안에 안 구하면 고정 페널티 또는 사망 가능
12-3. guest_ally_standard
역할

게스트 동료

규칙
플레이어 세력으로 행동하지만 수동 조작 불가인 경우 사용
생존 우선 + 간단한 support 우선
스토리상 죽으면 안 되는 경우 risk tolerance를 낮게 둔다
13. 상태이상 대응 규칙
13-1. Forget 대응

AI는 Forget을 아래처럼 해석한다.

적이 플레이어에게 거는 입장
Forget 2 이상인 대상은 hit chance가 좋아져 집중 가치가 높아진다
Forget 2 → 3중첩 가능하면 status score 가중치를 크게 준다
세린/노아 같은 정화 핵심 대상에 Forget 누적 우선
AI 자신이 당한 입장
self Forget 3이면 signature/command 봉인에 맞춰 기본 행동으로 후퇴/대기
healer/chant 계열은 self cleanse 또는 support를 우선 평가
13-2. Mark 대응
mark 부여 후 같은 턴 연계 가능하면 mark 행동 가치 상승
이미 marked target이 있으면 follow-up unit이 우선 타깃
black_hound, archer_control, boss_controller는 marked target 가중치가 큼
13-3. Silence / Seal 대응
스킬 의존도가 높은 프로필은 기본 공격/이동 가치 재평가
healer_chanter가 Silence면 Safety 우선 후퇴
commander_support가 Seal이면 objective tile 점유 쪽으로 행동 전환
13-4. Fear 대응
Fear 상태면 반격 불가이므로, forward aggression 대폭 감소
melee_grunt, lancer_officer는 방어 지형이나 아군 인접 위치를 선호
13-5. Sleep 대응
행동 불가
깨어난 직후 턴에는 retaliation risk가 크므로 safety 우선
boss는 Sleep 면역 또는 감쇠 권장
13-6. Stealth 대응
reveal 수단이 없으면 마지막 확인 위치 근처만 경계
black_hound mirror match나 special sensor unit만 예외적으로 적극 탐지
14. 보스 스크립트 일반 규칙
14-1. 보스는 “최고 딜”보다 “패턴 유지”를 우선할 수 있다

예:

바실은 제단이 살아 있으면 당장 더 세게 때릴 수 있어도 물 수위 조절을 우선
멜키온은 lethal보다 다음 개정 예고를 먼저 깔 수 있음
카르온은 딜보다 이름 앵커를 끊는 행동을 우선할 수 있음
14-2. 예고 없는 강패턴 금지

보스도 AI지만, 플레이어가 읽을 수 있어야 한다.

14-3. 보스는 2턴 연속 완전히 같은 핵심 패턴을 반복하지 않는다

특히 광역 패턴, 전장 개정 패턴은 반복 피로를 줄인다.

14-4. 보스는 서브 목표 압박을 인지한다

예:

플레이어가 성가 샘을 모두 정화하려 하면 사리아가 샘 보호 가치 상승
플레이어가 증언 코덱스를 지키면 멜키온이 코덱스 쪽 압박 강화
플레이어가 이름 앵커를 유지하면 카르온이 앵커 파괴 가치 상승
14-5. 보스 스크립트도 안전 규칙을 완전히 무시하지 않는다

보스는 위험한 위치에 설 수 있지만, 아래는 금지한다.

의미 없이 불길/즉사성 환경 위 종료
스크립트 없이 홀로 player surround 안으로 진입
다음 페이즈가 남았는데 자살적 행동으로 패턴을 깨는 것
15. 개별 보스 패턴 규칙
15-1. 로드릭 (boss_rodrick)
역할

초기 추격형 보스

기본 패턴
표식 → 추격참
안전한 선에서 정찰병과 협공
체력 60% 이하 시 증원 호출 1회
AI 우선순위
저체력/후열 표식
추격 사정권 확보
리안 포획 가능성 있는 위치 선점
무리 진입 금지
의도

보스 패턴 읽기와 표식 대응의 입문

15-2. 케르만 (boss_kerman)
역할

화공 지휘형 보스

기본 패턴
송진 화살로 경로 오염
봉화 유지 시 공격 강화
플레이어가 모여 있으면 화염선 우선
AI 우선순위
봉화 유지
이동 경로를 불길로 나눔
호위 대상/시민 경로 차단
저체력 대상 처형
특별 규칙
봉화 0개면 공격성 하락, 후퇴 사격 증가
숲/수액 지형 활용 가치 상승
15-3. 바실 (boss_basil)
역할

수위 조작 + 제단 유지 보스

기본 패턴
제단이 2개 이상이면 익수 찬가 가치 상승
물살 밀치기로 깊은 물/오염 구역 유도
수위 조절로 길 닫기/열기
AI 우선순위
제단 보존
물살로 밀쳐 위치 붕괴
저항 낮은 대상에 Forget 압박
플레이어가 정화 루트를 타면 그쪽 차단
특별 규칙
물 타일 위에서 공격 정확도 보너스 가정 가능
제단이 모두 파괴되면 직접 공격 비중 증가
15-4. 헤스 (boss_hes)
역할

검열 + 소각 보스

기본 패턴
엄폐/서가를 불길로 바꾸기
버프나 스킬 의존 캐릭터 봉인
기록통 회수를 방해
AI 우선순위
구조/회수 대상 차단
엄폐 타일 제거
스킬 핵심 캐릭터 봉인
탈출 경로 화염 압박
특별 규칙
기록통 근처 적에게는 direct pressure 가치 상승
fire spread 스크립트와 AI가 충돌하지 않게 패턴 루프 고정
15-5. 발가르 (boss_valgar)
역할

요새 중심 방어 보스

기본 패턴
중앙 광장 유지
방패병과 인접 시 방어 오라
카운터웨이트 복구 전에는 측면 포대 가치 상승
AI 우선순위
핵심 거점 유지
플레이어 전열 붕성 타격
포대/방패병과 formation 유지
너무 깊게 chase 하지 않음
특별 규칙
체력 60% 이하 전까지 central hold 성향 강함
이후 성문 파괴와 돌격병 투입 스크립트
15-6. 사리아 (boss_saria)
역할

정화/유도/군중 통제 보스

기본 패턴
시민/NPC를 정화 원형으로 유도
성가 샘을 지키며 망각 축적
직접 처치보다 안정화/유도 우선
AI 우선순위
성가 샘 유지
시민 흐름 재유도
세린 / 노아 / 정화 핵심 대상 압박
체력 60% 이하에서 침묵 구역 확장
특별 규칙
시민이 전장에 남아 있으면 시민 가치 가중치 크게 상승
시민이 다 안전하면 공격적 성향 증가
15-7. 레테 (boss_lete)
역할

은신 암살 보스

기본 패턴
고립 대상 mark
은신 상태 유지
kill 가능할 때만 reveal
봉화 네트워크로 이동
AI 우선순위
isolated + ranged_fragile
marked target
witness / escort_target
kill 후 은신 복귀 또는 beacon teleport
특별 규칙
2턴 연속 같은 위치 근처에 머무르지 않음
anti-stealth 장비가 많으면 더 넓게 rotate
체력 60% 이하에서 친위대 증원 후 사냥망 확대
15-8. 바르텐 (boss_barten)
역할

증언 삭제 / 구조 대상 처형 보스

기본 패턴
삭제 구역 지정
구조 장교, 증언 문서 운반자 우선 표적
카일 전환 전에는 카일 부대도 disposable로 계산
AI 우선순위
witness / escort_target 삭제
감찰 봉인주 유지
player support_core 압박
구조 대상 근처 deletion zone 생성
특별 규칙
카일 전환 이벤트 전후로 전장 평가 변경
카일이 전환하면 바르텐이 카일을 high-value target으로 재설정
15-9. 멜키온 (boss_melchion)
역할

전장 개정 보스

기본 패턴
개정핵 유지 시 개정 우선
코덱스 파괴 압박
스킬 봉인과 여백 구역 확장
lethal보다 “판을 불리하게 재작성”하는 행동 선호
AI 우선순위
개정핵 / 붉은 주석 기둥 유지
증언 코덱스 압박
에녹 / 노아 / 리안 같은 맥락 복원자 차단
lethal 기회가 있으면 execution
특별 규칙
같은 revision type 연속 2회 금지
개정 예고를 먼저 보여 준 뒤 적용
코덱스가 2권 다 안전하면 멜키온이 더 공격적으로 변함
15-10. 카르온 (boss_karon_phase1, boss_karon_phase2)
1페이즈: 왕의 칙령
역할

왕 / 지휘자 / 전장 통치자

기본 패턴
칙령봉 유지
이름 횃불 압박
플레이어가 뭉치면 광역 억제
퍼지면 단절 압박
AI 우선순위
칙령봉 유지
이름 횃불 파괴 또는 봉쇄
세린/노아/리안 압박
친위대 소환으로 전장 균형 유지
2페이즈: 마지막 이름
역할

앵커 붕괴 + 광역 망각 보스

기본 패턴
이름 앵커 공격
공백 타일 확장
단절된 아군에게 추가 압박
종막 파동으로 전체 망각 누적
AI 우선순위
이름 앵커 끊기
앵커에서 멀어진 유닛 처벌
리안 압박
노아/세린 등 회복 앵커 차단
특별 규칙
앵커가 2개 이상 남아 있으면 앵커 타깃 가치 상승
앵커가 거의 다 부서지면 리안 집중 공격 전환
이름 부름 발동 후엔 해당 패턴 카운터를 일정 턴 완화
16. NPC 보호 / 처형 로직

이 프로젝트는 구조전이 많으므로 중요하다.

16-1. AI가 NPC를 노리는 경우

아래 조건 중 하나면 NPC 가중치가 급상승할 수 있다.

스테이지 목표가 escort 방해
boss philosophy가 witness 삭제
marked / lured 상태 NPC
low HP NPC
보호자와 분리된 NPC
16-2. AI가 NPC를 무시하는 경우
boss script상 object 우선 턴
NPC가 이미 안전지대 도달
NPC를 치는 것보다 player core 처치가 더 큰 가치
16-3. 과도한 억까 방지

NPC를 노리는 AI도 아래를 지킨다.

예고 없이 장거리 즉사 콤보 금지
같은 턴 3명 이상이 한 NPC만 집중해 즉사시키는 패턴은 특정 scripted fight 외 제한
구조 가능 턴 1개 이상 보장 권장
17. 위험 허용도(Risk Tolerance)

각 프로필은 위험 허용도가 다르다.

매우 낮음
healer_chanter
civilian_flee
injured_survivor
낮음
archer_control
commander_support
보통
melee_grunt
shield_guard
높음
lancer_officer
assassin_black_hound
특수
boss_controller
보스는 RiskScore를 무시하는 게 아니라, ScriptScore가 더 커질 수 있다
18. 구현용 점수 파라미터 권장치

초기 구현용 기본값이다.
정확한 수치는 테스트로 조정하되, 문법은 유지한다.

SCORE_KILL_CONFIRMED = 80
SCORE_KILL_HIGH_CHANCE = 60
SCORE_DAMAGE_HEAVY = 30
SCORE_DAMAGE_MEDIUM = 20
SCORE_APPLY_MARK = 25
SCORE_FORGET_TO_3 = 35
SCORE_SEAL_CORE = 30
SCORE_HEAL_SAVE_CORE = 60
SCORE_GUARD_SAVE_CORE = 30
SCORE_DESTROY_REQUIRED_OBJECT = 90
SCORE_HIT_CRITICAL_NPC = 85
SCORE_HOLD_OBJECTIVE_TILE = 45
SCORE_SAFE_TERRAIN = 12
RISK_FIRE_TILE = 40
RISK_PREDICTED_AOE = 35
RISK_ISOLATED_END = 15
WASTE_BAD_CHARGE_USE = 20
WASTE_OVERHEAL = 10
프로필별 배수 예시
melee_grunt:
  objective_mult = 0.9
  risk_mult = 0.8

shield_guard:
  objective_mult = 1.2
  position_mult = 1.3
  risk_mult = 0.7

archer_control:
  kill_mult = 1.1
  position_mult = 1.2
  risk_mult = 1.2

healer_chanter:
  support_mult = 1.5
  risk_mult = 1.3
  kill_mult = 0.5

assassin_black_hound:
  kill_mult = 1.2
  status_mult = 1.2
  isolation_mult = 1.6
  risk_mult = 1.0

commander_support:
  objective_mult = 1.3
  formation_mult = 1.4
  risk_mult = 1.0

boss_controller:
  script_mult = 2.0
  objective_mult = 1.4
  risk_mult = 0.8
19. 단계별 협공 규칙

AI는 완전한 풀 전역 최적화를 하지 않는다.
대신 아래 정도의 가벼운 협공은 허용한다.

19-1. 같은 턴 marked target 집중

이미 표식이 붙은 대상은 후속 AI들이 우선순위를 높게 본다.

19-2. support-first coordination

보스/elite가 체력 50% 이하일 때 healer_chanter가 먼저 힐하고,
이후 melee가 전선 유지 행동을 선택할 수 있다.

19-3. deletion chain

바르텐, 레테 계열은 witness/escort_target에 대해
같은 턴 2연계까지는 허용하되 3연계 즉사 패턴은 제한한다.

19-4. anchor pressure

카르온은 이름 앵커 하나를 여러 적이 동시에 칠 수 있다.
하지만 같은 턴에 모든 앵커를 다 집중 타격하는 패턴은 금지한다.

20. AI 런타임 플래그 규칙

AI는 아래 런타임 상태를 읽을 수 있다.

temp_mark_focus_target_id
temp_anchor_priority_side
temp_boss_script_cycle
temp_witness_escape_started
temp_revision_next_type
원칙
이 값들은 전투 런타임 또는 stage state에만 존재
영속 플래그로 승격 금지
AI는 이 값을 통해 “누굴 집중할지”, “이번 턴 어떤 패턴을 쓸지”를 조절할 수 있다
21. AIProfileData와의 연결 규칙

data_schema.md의 AIProfileData는 아래 구조를 권장한다.

AIProfileData
- id
- role
- aggression
- objective_bias
- self_preservation
- formation_bias
- support_bias
- target_tag_weights
- tile_tag_weights
- retreat_threshold_hp_pct
- preferred_skill_ids[]
- forbidden_skill_tags[]
- script_group_id
예시: black hound profile
id: ai_black_hound_assassin
role: assassin_black_hound
aggression: 85
objective_bias: 55
self_preservation: 70
formation_bias: 20
support_bias: 10
target_tag_weights:
  isolated: 40
  marked: 30
  ranged_fragile: 25
  witness: 20
tile_tag_weights:
  forest: 15
  shadow: 20
  fire: -40
retreat_threshold_hp_pct: 35
preferred_skill_ids:
  - skill_black_moon_mark
  - skill_shadow_reap
forbidden_skill_tags:
  - hold_position_only
script_group_id: script_black_hound_standard
22. 안티-프러스트레이션 규칙
22-1. Healer Loop 방지

적 힐러가 영원히 뒤에서 과힐만 반복해 전투가 늘어지면 안 된다.

규칙:

같은 대상에게 의미 없는 힐 2턴 연속 금지
boss/elite가 아닌 일반 적의 과힐 임계치 높게 설정
22-2. Assassin Stall 방지

레테 계열이 계속 숨어만 있으면 전투가 지루해진다.

규칙:

2턴 이상 무의미한 대기/이동 반복 금지
일정 턴마다 처형 각 또는 표식 각을 강제 탐색
22-3. Commander Turtle 방지

commander가 지나치게 objective만 지켜서 게임이 멈추면 안 된다.

규칙:

플레이어가 핵심 목표에 충분히 접근하면 commander도 능동 패턴으로 전환
22-4. Boss Script Lock 방지

보스가 스크립트 때문에 실질적으로 바보가 되면 안 된다.

규칙:

ScriptScore는 크지만, 아예 무가치한 행동을 강제하면 안 됨
최소 damage / status / objective 의미가 있는 패턴만 스크립트 후보로 허용
23. 테스트 체크리스트

AI 구현 후 최소 아래 케이스를 QA한다.

공통
같은 전장 상태에서 같은 행동을 반복 재현하는가
AI가 reveal되지 않은 은신 유닛을 직접 타깃하지 않는가
danger zone을 이유 없이 밟지 않는가
healer가 과힐 루프에 빠지지 않는가
구조전
시민/NPC를 목표로 삼는 보스가 실제로 구조 압박을 주는가
하지만 예고 없는 즉사 콤보는 피하는가
레테
고립된 대상에 제대로 mark → follow-up 하는가
anti-stealth 장비 앞에서 패턴이 너무 바보처럼 무너지지 않는가
멜키온
전장 개정이 예고 후 발동하는가
같은 개정만 반복하지 않는가
코덱스 압박과 플레이어 압박을 균형 있게 하는가
카르온
1페이즈는 칙령과 횃불 유지가 중심인가
2페이즈는 이름 앵커가 실제 타깃이 되는가
이름 부름 발동 후 대응 창이 생기는가
24. Codex 구현 규칙

Codex가 AI를 구현할 때는 아래 원칙을 지킨다.

24-1. 스킬 개별 하드코딩보다 태그와 프로필을 우선 쓴다

예:

“사리아는 무조건 시민을 노린다”보다
boss_saria + commander_support + target_tag_weights[civilian] + script_group

이렇게 가는 편이 확장성이 높다.

24-2. 보스 예외는 Script Layer로 넣고, Tactical Layer를 깨지 않는다

예외 패턴은 허용하지만, 일반 AI 규칙을 완전히 무시하게 만들지 않는다.

24-3. StageData와 AIProfileData를 분리한다
StageData는 언제 어떤 이벤트가 발동하는지
AIProfileData는 그 유닛이 평소에 어떤 선택을 하는지
24-4. 로그를 남긴다

개발 빌드에서는 행동 결정 이유를 요약 로그로 남기는 것을 권장한다.

예:

[AI] boss_lete chose skill_black_moon_mark on serin
reason: target_isolated + marked_setup + safe_restealth_tile
25. 최종 메모

이 프로젝트의 AI는 “최적으로 둔다”가 목적이 아니다.
목적은 아래를 만족시키는 것이다.

역할이 선명하고
패턴이 읽히며
플레이어가 배울 수 있고
보스의 철학이 행동으로 드러나며
같은 전투를 다시 해도 납득 가능한 결과가 나오는 것
즉, 좋은 AI의 기준은 “강함”보다 의미 있는 위협이다.
