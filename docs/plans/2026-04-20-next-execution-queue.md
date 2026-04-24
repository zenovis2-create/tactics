# Next Execution Queue

> Historical snapshot. Current canonical queue:
> [2026-04-20-post-migration-priority-queue.md](./2026-04-20-post-migration-priority-queue.md)

## 목적

마이그레이션 / 한글화 / canonical 정리가 끝난 현재 시점에서,
다음 개발 작업을 흩어진 TODO가 아니라 `즉시 집행 가능한 큐`로 고정한다.

이 문서는 다음 조건을 만족해야 한다.

1. 지금 당장 손대야 할 순서를 보여 준다.
2. 선행 조건과 검증 기준이 같이 붙어 있다.
3. 한 작업을 끝내면 바로 다음 작업으로 넘어갈 수 있다.

## 현재 기준

- ID / resource path migration: 완료
- 핵심 player-facing text cleanup: 완료
- campaign UI / records / stage text cleanup: 완료
- alias compatibility: 유지

즉, 지금은 `정리 작업`보다 `기능/콘텐츠 집행` 단계다.

## 실행 원칙

1. `전투/진행`을 깨는 작업을 먼저
2. 그 다음 `보스/컷신`처럼 콘텐츠 체감이 큰 작업
3. 마지막에 `시각 polish`와 `확장 시스템`

## Queue A. 즉시 착수

### A1. StageResolutionService 실제 구현

목표:

- battle 결과를 chapter/camp progression에 실제 반영

포함 범위:

- flag commit
- evidence / memory / letter commit
- optional objective result commit
- reward handoff contract 정리

선행 조건:

- 없음

완료 기준:

- battle clear -> camp handoff에서 progression flag가 실제로 저장됨
- save/load 후에도 동일 상태 유지

검증:

- existing save/load runners
- chapter handoff smoke

### A2. 2장~5장 컷신 콘텐츠 집행

목표:

- 현재 비어 있는 chapter cutscene TODO를 실제 data로 채움

우선 대상:

1. `CH02`
2. `CH03`
3. `CH04`
4. `CH05`

선행 조건:

- A1 완료 권장

완료 기준:

- intro / outro / 핵심 합류 컷신이 실제 catalog에 존재
- stage와 cutscene id가 연결됨

검증:

- chapter shell runner
- cutscene load smoke

### A3. 2장~5장 보스 패턴 완성

목표:

- 현재 최소 구현 상태의 보스를 chapter intent 수준까지 끌어올림

우선 대상:

1. `Valgar`
2. `Basil`
3. `Saria`
4. Chapter 5 boss gimmick

선행 조건:

- A1 완료 권장

완료 기준:

- phase 이름만 있는 상태가 아니라 실제 gimmick action 존재
- stage objective / interactive object와 연결됨

검증:

- boss runner
- chapter-specific battle smoke

## Queue B. 바로 다음 묶음

### B1. BondService 완전 구현

목표:

- 지원 공격 / bond progression / camp conversation / name-call 계층을 완전 연결

완료 기준:

- battle/camp/ending 사이에서 bond가 끊기지 않음
- support surface / result surface / finale name call 일관

### B2. 인벤토리 장비 슬롯 UI 완성

목표:

- 현재 campaign/camp shell의 슬롯 UI를 실제 장비 관리 흐름으로 마감

포함 범위:

- 무기 슬롯
- 방어구 슬롯
- 장신구 슬롯
- 장착 해제 / 교체 / 판매

### B3. 상태이상 시각화

목표:

- 망각 / 공포 / 표식 / 매혹 / DoT를 유닛 상에 명확히 표시

완료 기준:

- HUD 없이도 상태가 즉시 판독됨

## Queue C. 중기

### C1. 6장~10장 컷신 콘텐츠 집행

### C2. 6장~10장 보스 패턴 완성

### C3. 메타 시스템 완성

- 대장간
- 인챈트
- 재련

### C4. 회상 토벌전 시스템

### C5. 진엔딩 컷신 / 엔딩 완성

## 추천 실행 순서

1. `A1 StageResolutionService`
2. `A2 CH02~05 cutscene pack`
3. `A3 CH02~05 boss pack`
4. `B1 BondService`
5. `B2 Inventory slot UI`
6. `B3 Status visuals`

## 지금 당장 시작할 한 작업

가장 먼저 시작할 작업은 `A1 StageResolutionService 실제 구현`이다.

이유:

1. progression commit이 약하면 이후 컷신/보스 작업도 결과가 저장되지 않는다.
2. chapter handoff, reward log, flag progression이 모두 여기에 걸려 있다.
3. 지금 코드베이스 상태에서 가장 많은 TODO를 실제 runtime contract로 닫아 준다.
