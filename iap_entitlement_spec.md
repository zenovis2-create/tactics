# IAP Entitlement Spec v1
## Project: 잿빛의 기억

## 0. 범위 상태

이 문서는 **post-MVP / release-phase only** 문서다.

현재 `M0 ~ M2` 구현 레인과 첫 vertical slice에서는 아래를 실제 구현 범위로 취급하지 않는다.

- 스토어 결제 연결
- entitlement 저장/복원
- 환불/복원 처리
- DLC 접근 잠금
- 코스메틱/서포터 팩 entitlement

즉, 이 문서는 출시 준비와 이후 수익화 구현을 위한 장기 설계 문서다.

## 1. 문서 목적

이 문서는 인앱상품 구매 결과를 게임 안에서 어떻게 해금 상태로 저장하고, 복원하고, 검증하고, UI와 진행 로직에 반영할지 고정하는 문서다.

이 문서가 고정하는 것은 아래 여섯 가지다.

1. 상품 ID와 entitlement 매핑
2. 저장 구조와 정본(Source of Truth)
3. 구매 / 복원 / 실패 / 환불 시 처리 방식
4. 챕터 게이팅과 DLC 접근 규칙
5. 오프라인/온라인 상태 처리
6. Codex 구현 시 필요한 서비스와 데이터 흐름

이 문서는 `monetization_spec.md`, `data_schema.md`, `flag_progression_spec.md`, `camp_ui_spec.md`와 함께 읽는다.

---

## 2. 핵심 설계 원칙

### 2-1. 결제 상태와 서사 플래그를 섞지 않는다
구매 여부는 스토리 플래그가 아니다.

나쁜 예:
- `flag_story_full_campaign_bought`
- `flag_sys_paid_user`

좋은 예:
- `owned_iap_ids[]`
- 또는 `entitlements{}`

### 2-2. 구매 결과의 정본은 entitlement 데이터다
본편 해금 여부, DLC 소유 여부, 코스메틱 팩 소유 여부는  
항상 **스토어 상품 소유 상태**를 기준으로 본다.

스토리 플래그는 entitlement를 흉내 내면 안 된다.

### 2-3. 구매는 즉시 효과가 보여야 한다
결제 성공 후 아래는 즉시 반영되어야 한다.

- 2장 진입 가능
- DLC 카드 잠금 해제
- 코스메틱 사용 가능
- 서포터 팩 갤러리 표시

### 2-4. 복원은 항상 가능해야 한다
특히 iOS/Android에서 앱 재설치, 기기 변경, 로그인 복구 등을 고려해  
**구매 복원** 흐름을 반드시 둔다.

### 2-5. 오프라인에 강해야 한다
이미 구매한 본편 해금과 DLC는 네트워크 없이도 가능한 한 정상 접근되어야 한다.  
단, 최초 구매 확인과 복원은 온라인이 필요할 수 있다.

### 2-6. 환불/철회는 예외가 아니라 설계 항목이다
스토어에서 결제가 취소되거나 환불되면 entitlement도 정리할 수 있어야 한다.  
단, 스토리 세이브를 부수는 방식이 아니라 **접근만 잠그는 방식**이 좋다.

---

## 3. 상품 ID와 entitlement 매핑

## 3-1. 상품 ID

### 본편
- `iap_full_campaign_unlock`

### DLC
- `iap_after_story_pack_01`
- `iap_challenge_pack_01`

### 코스메틱
- `iap_cosmetic_founders_pack`

### 서포터
- `iap_supporter_pack_01`

---

## 3-2. 권장 entitlement 키

```text
ent_full_campaign
ent_after_story_pack_01
ent_challenge_pack_01
ent_cosmetic_founders_pack
ent_supporter_pack_01
```

매핑
iap_full_campaign_unlock → ent_full_campaign
iap_after_story_pack_01 → ent_after_story_pack_01
iap_challenge_pack_01 → ent_challenge_pack_01
iap_cosmetic_founders_pack → ent_cosmetic_founders_pack
iap_supporter_pack_01 → ent_supporter_pack_01

원칙

상품 ID는 스토어 SKU이고, entitlement 키는 게임 내부 논리 키다.
둘을 같은 문자열로 써도 되지만, 분리해 두는 편이 장기적으로 안전하다.

## 4. 저장 구조

### 4-1. 권장 저장 필드

ProfileSaveData에 아래 필드를 추가하는 것을 권장한다.

owned_iap_ids: Array[String]
entitlement_states: Dictionary[String, bool]
store_offer_seen_ids: Array[String]
의미
owned_iap_ids
실제로 소유 중인 스토어 상품 ID 목록
entitlement_states
게임 내부 해금 상태 캐시
store_offer_seen_ids
본편 해금 카드, DLC 추천 카드 등 노출 기록
권장 정본

가장 이상적인 정본은 아래 순서다.

스토어 영수증/구매 복원 결과
owned_iap_ids
entitlement_states는 캐시

즉:

owned_iap_ids가 사실상 로컬 정본
entitlement_states는 UI/접근 속도를 위한 편의 캐시

### 4-2. 최소 저장 예시

```json
{
  "owned_iap_ids": [
    "iap_full_campaign_unlock",
    "iap_cosmetic_founders_pack"
  ],
  "entitlement_states": {
    "ent_full_campaign": true,
    "ent_after_story_pack_01": false,
    "ent_challenge_pack_01": false,
    "ent_cosmetic_founders_pack": true,
    "ent_supporter_pack_01": false
  },
  "store_offer_seen_ids": [
    "offer_full_campaign_after_ch01"
  ]
}
```

## 5. entitlement 판정 규칙

게임 안에서는 아래 헬퍼를 쓴다.

has_entitlement(entitlement_key)
owns_iap(product_id)
can_access_chapter(chapter_id)
can_access_after_story_pack(pack_id)
can_access_challenge_pack(pack_id)
can_use_cosmetic_pack(pack_id)

### 5-1. 본편 접근
1장까지는 entitlement 필요 없음
2장부터는 ent_full_campaign == true 필요

### 5-2. 후일담 팩 접근
ent_after_story_pack_01 == true
권장 추가 조건: flag_ch10_complete == true

### 5-3. 챌린지 팩 접근
ent_challenge_pack_01 == true
권장 추가 조건: 본편 해금 보유
클리어 요구는 선택 사항

### 5-4. 코스메틱 사용
ent_cosmetic_founders_pack == true

### 5-5. 서포터 팩 사용
ent_supporter_pack_01 == true

## 6. 구매 흐름

### 6-1. 기본 구매 플로우
상품 카드 진입
가격/설명 표시
구매 버튼 탭
플랫폼 결제 호출
성공 시 영수증/구매 결과 수신
상품 ID 확인
owned_iap_ids 업데이트
entitlement_states 갱신
세이브 저장
해금 연출 / UI 리프레시

### 6-2. 성공 후 즉시 효과
본편 해금
2장 진입 잠금 해제
본편 해금 카드 숨김 또는 “구매 완료” 표시
챕터 선택 UI 갱신
DLC
DLC 카드 잠금 해제
해당 스테이지 / 메뉴 표시
코스메틱
캠프 테마 / 프레임 / UI 테마 선택 가능
서포터 팩
갤러리 / OST / 코멘터리 탭 표시

### 6-3. 구매 실패 처리
유형
사용자 취소
네트워크 실패
스토어 응답 실패
상품 조회 실패
영수증 검증 실패(추후 서버 검증 도입 시)
원칙
실패 시 entitlement 변화 없음
장면/진행도 손상 없음
명확한 메시지 출력
사용자 취소는 오류처럼 보이지 않게 처리

## 7. 구매 복원 흐름

### 7-1. 복원 버튼 위치
설정 메뉴
상점/지원 메뉴
본편 해금 카드 하단(선택)
권장 문구

구매 복원

### 7-2. 복원 플로우
사용자 복원 요청
플랫폼 복원 API 호출
구매 상품 목록 수신
owned_iap_ids 재구성
entitlement_states 재계산
저장
결과 메시지 표시

### 7-3. 복원 성공 메시지 예
본편 해금이 복원되었습니다.
코스메틱 팩이 복원되었습니다.

### 7-4. 복원 실패 메시지 예
복원 가능한 구매 내역을 찾지 못했습니다.
네트워크 상태를 확인한 뒤 다시 시도해 주세요.

## 8. 오프라인 처리

### 8-1. 이미 구매한 콘텐츠

한 번 소유 상태가 로컬에 저장되면,
오프라인에서도 entitlement를 읽어 접근 가능하게 한다.

예:

이미 산 본편은 비행기 모드에서도 계속 플레이 가능
이미 산 코스메틱도 적용 가능

### 8-2. 최초 구매

최초 구매는 플랫폼 결제가 필요하므로 온라인이 필요하다.

### 8-3. 복원

복원은 원칙적으로 온라인이 필요하다.

### 8-4. 보수적 fallback

스토어 응답이 일시적으로 안 오더라도,
이미 owned_iap_ids에 있는 상품은 바로 회수하지 않는다.
즉, 일시 네트워크 문제로 구매 콘텐츠가 갑자기 잠기면 안 된다.

## 9. 환불 / 철회 처리

### 9-1. 원칙

환불이나 구매 철회가 확인되면 entitlement를 제거할 수 있어야 한다.
하지만 이미 생성된 스토리 세이브를 깨거나 데이터 자체를 삭제하지는 않는다.

예
본편을 환불받았다고 해서 세이브의 6장 데이터가 삭제되지는 않는다.
대신 2장 이후 진입이 다시 잠길 수 있다.
이미 본 기록과 기억 로그는 남겨 둘 수 있다.
9-2. 본편 환불 시 권장 처리
ent_full_campaign = false
챕터 2 이상 진입 잠금
기존 세이브는 보관
free scope(프롤로그~1장)만 접근 허용
9-3. DLC 환불 시 권장 처리
해당 DLC 스테이지 접근 잠금
보상 아이템은 정책에 따라 두 방향 중 하나 선택
A안 — 보수적

이미 획득한 DLC 전용 코스메틱/비성능 보상은 유지

B안 — 엄격

미진입 상태만 잠그고, 이미 획득한 전용 보상은 숨김 처리

출시 1차는 A안이 더 단순하고 안전하다.

9-4. 코스메틱 환불 시
해당 코스메틱 장착 해제
선택 가능 목록에서 숨김
기본 테마로 fallback
10. 게이팅 규칙
10-1. 본편 게이팅
무료 접근 허용
프롤로그
1장
기본 캠프 허브 일부
1장 종료 인터루드
기록 탭 일부
본편 해금 필요
2장 이후 모든 메인 챕터
본편 hunt 해금(권장)
후반 제작/교정 기능(권장)
진엔딩까지 포함한 전체 흐름
이유

본편 해금이 캠페인 전체 접근권을 의미해야 한다.

10-2. hunt 접근 규칙

권장 기준:

본편 hunt는 ent_full_campaign == true 필요
무료 체험판에서는 hunt 비활성

이유:

1장 무료 체험에서 파밍 메타까지 다 열면 BM 구조가 흐려진다
hunt는 본편 몰입 이후의 유지 장치다
10-3. DLC 접근 규칙
After Story Pack
ent_after_story_pack_01 == true
그리고 flag_ch10_complete == true
Challenge Pack
ent_challenge_pack_01 == true
권장: ent_full_campaign == true
11. UI와 entitlement 연동
11-1. 본편 해금 카드 상태
미구매
“본편 계속하기”
가격 표시
구매 버튼
구매 복원 버튼
구매됨
“본편 해금 완료”
2장 진입 버튼 활성
구매 버튼 숨김
11-2. DLC 카드 상태
미구매
잠금 카드
가격과 요약 표시
구매 버튼
구매됨
“설치됨/보유 중”
진입 버튼 활성
11-3. 코스메틱 카드 상태
미구매
미리보기 가능
적용 불가
구매 버튼
구매됨
적용 버튼 활성
11-4. 서포터 팩 상태
미구매
미리보기 일부 허용 가능
구매 버튼
구매됨
갤러리 / OST / 코멘터리 메뉴 활성
12. 추천 노출 정책

상품은 아무 때나 팝업으로 밀지 않는다.

허용 노출 타이밍
1장 클리어 직후 본편 해금 제안
본편 클리어 직후 After Story 제안
hunt / 기록 / 장비 루프를 충분히 체험한 뒤 Challenge 팩 제안
기록/설정 화면에서 서포터 팩 제안
금지 노출 타이밍
전투 패배 직후
보스 드롭이 마음에 안 들었을 때
랜덤 무기 분해 직후
감정 컷신 직후 코스메틱 팝업
13. 데이터 구조 권장
13-1. SaveData 필드 추가
owned_iap_ids: Array[String]
entitlement_states: Dictionary[String, bool]
store_offer_seen_ids: Array[String]
last_restore_attempt_at: String (optional)
13-2. 정본 우선순위
현재 세션에서 복원된 스토어 구매 결과
owned_iap_ids
entitlement_states는 캐시
원칙

로드 시에는 아래 순서로 합성한다.

effective_entitlements =
  restore_session_state
  OR persisted_owned_iap_ids

그리고 그 결과를 entitlement_states에 다시 써 준다.

14. 서비스 구조 권장
14-1. StoreCatalogService

역할:

상품 메타데이터 로딩
가격 문자열 표시
상품 리스트 관리
14-2. PurchaseService

역할:

구매 요청
구매 성공/실패 처리
복원 요청
entitlement 반영
14-3. EntitlementService

역할:

has_entitlement() 제공
챕터/DLC 접근 판정
UI 상태 계산
환불/철회 시 비활성 처리
원칙

UI는 entitlement를 직접 계산하지 않는다.
항상 EntitlementService를 통해 묻는다.

15. 구현용 헬퍼

권장 함수:

has_entitlement(entitlement_key)
owns_product(product_id)
unlock_product(product_id)
revoke_product(product_id)
restore_purchases()
can_access_chapter(chapter_id)
can_access_hunt(hunt_id)
can_access_after_story(pack_id)
can_access_challenge_pack(pack_id)
can_use_cosmetic(cosmetic_pack_id)
챕터 접근 예시
can_access_chapter("ch01") -> true
can_access_chapter("ch02") -> has_entitlement("ent_full_campaign")
16. 플래그와 entitlement 연결

플래그는 entitlement의 정본이 아니지만,
노출용 기록과 연동에는 쓸 수 있다.

허용되는 연결
store_offer_seen_ids[]
flag_story_karreon_defeated가 true면 After Story 추천 카드 노출
flag_ch10_complete가 true면 After Story 진입 조건 충족
금지되는 연결
flag_sys_paid_user = true
flag_story_full_campaign_bought = true
flag_unlock_ch02 = true

이런 플래그는 entitlement와 중복된다.

17. QA 체크리스트
구매
본편 해금 구매 후 즉시 2장 접근 가능
코스메틱 구매 후 즉시 선택 가능
서포터 팩 구매 후 관련 탭 표시
저장/로드
구매 후 앱 재실행해도 유지
오프라인 재실행 시에도 유지
복원 후 정상 반영
복원
이미 산 상품이 다시 활성화됨
중복 구매가 되지 않음
실패 메시지가 명확함
환불/철회
entitlement 제거 후 접근 제한 동작
기존 세이브 파일이 손상되지 않음
코스메틱 장착 상태 fallback 정상
게이팅
무료 유저는 1장까지만
본편 유저는 2장 이후 접근 가능
DLC는 본체 없이 접근 불가
후일담은 본편 클리어 전 진입 불가
18. 출시 전 체크리스트
필수
상품 ID 확정
스토어 가격 등록
구매 / 복원 버튼 연결
entitlement 저장 로직 검증
오프라인 entitlement 유지 검증
본편 게이팅 검증
DLC 게이팅 검증
권장
디버그 purchase mock
sandbox/test environment 구매 검증
구매 실패 메시지 로컬라이징
store card copy 최종 검수
19. 최종 권장안

이 게임은 아래 구조로 entitlement를 처리하는 게 가장 좋다.

정답 구조
상품 소유: owned_iap_ids[]
런타임 해금 판정: EntitlementService
빠른 UI 표시: entitlement_states
스토리 분기: 기존 flags
구매 노출 기록: store_offer_seen_ids[]

즉,
결제는 entitlement,
서사는 flags,
콘텐츠 진행은 stage clear / unit progress
로 나누는 것이 가장 안정적이다.

이 구조를 지키면 본편 해금, DLC, 코스메틱, 서포터 팩이
서로 뒤엉키지 않고 오래 유지된다.
