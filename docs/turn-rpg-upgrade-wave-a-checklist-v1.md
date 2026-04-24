# Turn RPG Upgrade Wave A Checklist

## A1. Risk Forecast Cards
- [ ] 3-line risk card format 정의
- [ ] stage metadata 또는 extraction helper 추가
- [ ] battle-start surface 연결
- [ ] compact/mobile readability 확인
- [ ] dedicated runner 추가
- [ ] shared UI runner 회귀 확인

## A2. State Forecast Preview
- [ ] preview payload에 state change label schema 추가
- [ ] attack preview 연결
- [ ] interaction preview 연결
- [ ] telegraph/detail surface 연결
- [ ] dedicated runner 추가
- [ ] existing preview/boss runner 회귀 확인

## A3. Post-Battle Bonus EXP Pool
- [ ] bonus EXP formula 정의
- [ ] reward path 연결
- [ ] 자동 분배 규칙 구현
- [ ] summary surface 추가
- [ ] save/load persistence 확인
- [ ] deterministic runner 추가

## A4. Visible Narrative Axis Gauges
- [ ] axis set 정의
- [ ] update trigger 정의
- [ ] campaign/camp payload 추가
- [ ] camp shell gauge surface 추가
- [ ] branch 변화 반영 확인
- [ ] camp runner 회귀 확인

## A5. Narrative-to-Combat Translation Cards
- [ ] passive card schema 정의
- [ ] unlock source 목록화
- [ ] camp display 추가
- [ ] battle passive resolver hook 추가
- [ ] unlock -> battle effect runner 추가
- [ ] bond/name-call 관련 회귀 확인

## A6. Battlefield Rule Templates
- [ ] template taxonomy 문서화
- [ ] template별 contract 정의
- [ ] stage template id/tag authoring
- [ ] objective/hint/result 문구 정규화
- [ ] existing chapter mapping 작성
- [ ] boss runner taxonomy 검증

## A7. Balance Replay Metrics
- [ ] metric schema 정의
- [ ] telemetry/report path 확장
- [ ] stage-level summary 출력 추가
- [ ] benchmark/report parser 준비
- [ ] required key 검증 추가
- [ ] tuning readout markdown 포맷 결정

## A8. Modern Secret / Hint Layer
- [ ] hidden reward category 정의
- [ ] reveal rule 정의
- [ ] scout/proximity/turn cadence hook 구현
- [ ] hint text surface 연결
- [ ] reveal timing runner 추가
- [ ] optional reward fairness 검증

## Release Gate
- [ ] 각 기능별 player-facing surface 있음
- [ ] 각 기능별 dedicated validation 있음
- [ ] shared regression runner PASS
- [ ] save/load 영향 항목 persistence PASS
- [ ] docs/spec/checklist 최신화
