# Turn RPG Upgrade Design

**Scope:** turn-rpg case-study synthesis를 현재 Farland Tactics/잿빛의 기억 코드베이스에 맞는 업그레이드 로드맵으로 정리한다.

## Goal

프로젝트를 "시스템 수가 많은 SRPG"에서
"판단이 잘 보이고, 실패가 학습으로 바뀌며, 서사와 전투가 직접 연결되는 현대형 서사 SRPG"로 업그레이드한다.

핵심 방향은 다음 5축이다.

1. 정보 투명성 강화
2. 성장/출전 피로 완화
3. 서사 -> 전투 보상 번역
4. 재사용 가능한 전장 규칙 템플릿화
5. 데이터 기반 밸런스 조정

## Recommended Approach

### Wave A — 바로 구현

#### A1. Risk Forecast Cards
- 전투 시작 시 맵 핵심 위험 3개를 카드형으로 노출한다.
- 내용은 `위험`, `실패 조건`, `완충 수단` 3줄 고정으로 제한한다.
- 기존 objective / telegraph / transition surface를 재활용한다.

#### A2. State Forecast Preview
- 행동 preview가 damage/range만이 아니라 state change를 보여주게 만든다.
- 예: `침수 지연`, `표식 해제`, `boss pressure 약화`, `구조 턴 +1`.
- battle preview payload와 interaction preview에 이벤트 라벨을 추가한다.

#### A3. Post-Battle Bonus EXP Pool
- 전투 종료 후 보너스 EXP 풀을 지급해 저기여/저레벨 유닛을 보정한다.
- 기존 reward/progression/save 흐름에 붙인다.
- 수동 분배는 후속으로 두고 v1은 자동 분배 우선.

#### A4. Visible Narrative Axis Gauges
- 기억/희생/진실/신뢰 같은 서사 축을 camp summary에 가시적으로 노출한다.
- 전체 수치보다 방향성과 band 중심으로 표현한다.
- branch 결과를 체감시키는 목적이며 스포일러는 피한다.

#### A5. Narrative-to-Combat Translation Cards
- 컷신/인연/이벤트가 전투 passive 카드 형태의 보상으로 번역되게 만든다.
- 예: charm restraint 강화, guard-share 강화, name-call recovery window.
- story reward를 lore text가 아니라 tactical option으로 전환한다.

#### A6. Battlefield Rule Templates
- late-game encounter를 보스별 bespoke script가 아니라 `template + modifier`로 정리한다.
- 초기 템플릿 후보:
  - pressure line defense
  - rescue timer
  - seal/anchor break
  - central control
  - chain reaction prevention
  - delayed collapse/flood

#### A7. Balance Replay Metrics
- stage별 평균 턴수, objective 성공률, boss phase 진입 턴, 상태이상 통계, 주요 실패 원인을 남긴다.
- difficulty와 clarity를 분리해 조정 가능한 보고층을 만든다.

#### A8. Modern Secret / Hint Layer
- hidden reward를 brute-force가 아니라 progressive hint로 노출한다.
- scout affinity, proximity, turn cadence를 활용한다.

### Wave B — 후속
- Resonance / Memory / Bond tactical resource화
- Memory erosion long-term pressure
- Meta rewind lite
- Boss-only anti-repetition constraints
- Injury-based bench depth

### Wave C — 축소/제한
- BG3식 광범위 환경 상호작용은 도입하지 않는다.
- 허용되는 축소판은 2~3개 invariant rule만:
  - fire/oil
  - water/shock
  - push/fall

## Implementation Principles

1. **Clarity over Coolness**
- 멋보다 읽힘이 우선이다.

2. **Preview before punishment**
- 플레이어에게 벌을 주기 전에 결과를 먼저 보여준다.

3. **Narrative must convert into play**
- 관계와 기억은 전투에서 느껴져야 한다.

4. **Template first, bespoke later**
- 새 챕터 규칙은 템플릿으로 먼저 모델링한다.

5. **No feature without validation**
- 새 기능은 runner/test/benchmark와 함께 들어간다.

## Sequence

1. Risk Forecast Cards
2. State Forecast Preview
3. Post-Battle Bonus EXP Pool
4. Visible Narrative Axis Gauges
5. Narrative-to-Combat Translation Cards
6. Battlefield Rule Templates
7. Balance Replay Metrics
8. Modern Secret / Hint Layer

## Verification

각 Wave A 항목은 최소 다음을 갖춰야 한다.

- dedicated runner or test 1개
- shared regression runner touchpoint 1개
- player-facing surface 1개
- save/load 영향 시 persistence check 1개

## Expected Outcome

이 업그레이드가 완료되면 프로젝트는:
- 첫 플레이에서 더 잘 읽히고
- 파티 운용 피로가 줄고
- 서사 보상이 전투에서 체감되며
- late-game encounter authoring cost가 낮아지고
- 밸런싱이 감이 아니라 데이터로 돌아가게 된다.
