# Execution Backlog

> Historical snapshot. Current canonical queue:
> [2026-04-20-post-migration-priority-queue.md](./2026-04-20-post-migration-priority-queue.md)

## 목적

마이그레이션, 한글화, canonical 정리 이후의 다음 작업을
`하나씩 찔끔` 진행하지 않도록, 현재 시점의 실행 큐를 단일 문서로 고정한다.

이 문서는 아래를 동시에 제공해야 한다.

1. 지금 당장 시작할 작업
2. 왜 그 작업이 먼저인지
3. 선행 조건
4. 완료 기준
5. 검증 방법

## 현재 기준 상태

- text cleanup: 완료
- campaign UI / records / stage text: 완료
- ID / resource path migration: 완료
- compatibility alias: 다음 한 버전 유지
- 주요 smoke:
  - ending
  - save/load
  - five-person sortie
  - support name-call
  - CH10 shell
  모두 green

즉, 지금은 `정리 작업`이 아니라 `runtime content / progression / systems`를 채우는 단계다.

## 우선순위 규칙

1. `진행 저장 / 챕터 인계`를 먼저 닫는다.
2. 그 다음 `보스 / 컷신`처럼 체감 큰 콘텐츠를 채운다.
3. 마지막에 `비주얼 polish / 메타 확장`을 넣는다.

## Queue A. 바로 착수

### A1. StageResolutionService 실제 연동

상태:

- 서비스 파일은 존재
- 실제 campaign 흐름에 완전히 연결되지는 않음

핵심 목표:

- 전투 결과를 progression/save/camp handoff에 실제 반영

포함 범위:

- cleared stage commit
- chapter complete flag commit
- memory/evidence/letter commit
- optional objective commit
- recruitment commit
- hunt unlock commit

선행 조건:

- 없음

완료 기준:

- 전투 클리어 후 camp로 넘어갈 때 progression state가 실제 갱신된다.
- 저장 후 다시 load해도 동일 state가 유지된다.

필수 검증:

- save/load runner
- chapter handoff smoke
- stage clear -> camp records surface 확인

### A2. CH02~CH05 컷신 콘텐츠 집행

핵심 목표:

- 2장~5장 intro/outro/합류 컷신을 실제 catalog에 채운다.

우선 대상:

1. CH02 fortress 접근 / Bran 합류
2. CH03 forest 진입 / Tia 합류
3. CH04 수도원 침수 / Saria 첫 등장
4. CH05 서고 진입 / Enoch 합류

선행 조건:

- A1 완료 권장

완료 기준:

- stage의 cutscene id가 실제 catalog 구현으로 연결된다.
- chapter shell에서 컷신이 비어 있지 않다.

필수 검증:

- chapter intro/outro smoke
- cutscene id lookup

### A3. CH02~CH05 보스 패턴 마감

핵심 목표:

- 최소 구현 상태의 보스를 chapter intent 수준까지 끌어올림

우선 대상:

1. Valgar
2. Basil
3. Saria
4. CH05 boss gimmick

선행 조건:

- A1 완료 권장

완료 기준:

- phase label만 있는 게 아니라 실제 gimmick action이 존재
- stage objective / interaction / terrain과 연결

필수 검증:

- boss runner
- chapter-specific battle smoke

## Queue B. 바로 다음

### B1. BondService 완전 연동

목표:

- 전투 / 캠프 / 엔딩 사이의 bond progression을 완전 연결

포함 범위:

- shared battle progression
- support rank up surface
- finale name-call coherence
- camp dialogue/history surface

### B2. 장비 슬롯 UI 완성

목표:

- 현재 shell 수준의 장비 UI를 실제 플레이 루프용 관리 UI로 마감

포함 범위:

- 무기 / 방어구 / 장신구 장착
- 해제
- 판매
- 교체

### B3. 상태이상 시각화

목표:

- 망각 / 공포 / 표식 / 매혹 / DoT를 HUD 없이도 판독 가능하게 만듦

## Queue C. 중기

### C1. CH06~CH10 컷신 콘텐츠

### C2. CH06~CH10 보스 패턴

### C3. 메타 시스템 완성

- 대장간
- 인챈트
- 재련

### C4. 회상 토벌전

### C5. 진엔딩 컷신

## 실행 순서

1. A1 StageResolutionService
2. A2 CH02~CH05 컷신
3. A3 CH02~CH05 보스 패턴
4. B1 BondService
5. B2 장비 슬롯 UI
6. B3 상태이상 시각화

## 착수 기준

현재 바로 시작할 작업은 `A1 StageResolutionService 실제 연동`이다.

이유:

1. progression commit이 닫히지 않으면 이후 컷신/보스 작업도 저장과 handoff가 불안정하다.
2. 현재 코드베이스에서 가장 많은 TODO를 runtime contract로 바꿀 수 있다.
3. save/load와 chapter handoff가 이미 green이므로, 바로 연결 효과를 검증하기 좋다.

## 완료 후 다음 문서 작업

`A1`이 끝나면:

1. 이 문서에서 A1 체크
2. 별도 구현 문서 또는 review note 작성
3. A2로 즉시 전환
