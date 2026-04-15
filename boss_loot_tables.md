# Boss Loot Tables v1
## Project: 잿빛의 기억

## 1. 문서 목적

이 문서는 보스별 무기 드롭 테이블, 희귀도 분포, 무기군 가중치, 고유 유니크 풀, 선호 어픽스, 금지 어픽스를 고정하는 문서다.

이 문서가 고정하는 것은 아래 여섯 가지다.

1. 보스 드롭의 전역 규칙
2. 챕터 구간별 희귀도 분포
3. 보스 철학과 드롭 테마의 연결
4. 첫 클리어 / 회상 토벌전 보상 차이
5. 보스별 무기군 가중치와 고유 유니크 풀
6. 선택 제작 / 옵션 교정과의 연결 기준

이 문서는 `equipment_system.md`, `data_schema.md`, `master_campaign_outline.md`를 전제로 한다.  
즉, 장비 구조와 랜덤 무기 규칙은 이미 정해져 있다고 보고,  
여기서는 **실제 보스가 무엇을 얼마나 떨어뜨리는지**만 고정한다.

---

## 2. 핵심 설계 원칙

### 2-1. 보스 드롭은 철학을 반영해야 한다
드롭은 단순히 강한 무기 목록이 아니다.  
플레이어는 무기 이름과 옵션을 보고 그 보스의 싸움 방식을 떠올릴 수 있어야 한다.

예:
- 사리아 → 정화 / 치유 / 정신 간섭 대응
- 레테 → 표식 / 은신 / 고립 처형
- 멜키온 → 규칙 개정 저항 / 봉인 대응 / 숨은 정보
- 카르온 → 광역 망각 대응 / 공명 유지 / 최종전 생존

### 2-2. 첫 클리어는 실망시키지 않는다
스토리 첫 클리어 보상은 **최소 희귀도 보장**과 함께  
그 장에서 막 합류한 동료 또는 그 장의 핵심 메커닉에 맞는 무기군으로 기울어진다.

즉:
- 티아 장에선 활 가중치가 높고
- 세린 장에선 지팡이 가중치가 높고
- 카일 장에선 창 가중치가 높다

### 2-3. 회상 토벌전은 반복 가능하지만 짧아야 한다
스토리 전투는 길고 밀도 있게,  
회상 토벌전은 짧고 반복 가능하게 설계한다.

따라서 회상 토벌전 보상은 아래를 따른다.

- 랜덤 무기 1개 보장
- 추가 드롭은 낮은 확률
- 문장 1개 보장
- 짧은 플레이타임 기준으로 밸런싱

### 2-4. 랜덤성은 무기에 집중한다
방어구와 악세사리는 탐색/스토리 보상 위주다.  
보스 랜덤은 기본적으로 **무기**만 담당한다.

### 2-5. 엔드게임급 옵션은 초반 풀에서 금지한다
아래 옵션은 일반 랜덤 풀에 넣지 않는다.

- 사거리 +1
- 이동 +1
- 추가 행동
- 부활
- 광역 오라
- 전장 전체 무시 효과
- 이름 앵커 무시
- 규칙 개정 완전 면역

이런 건 보스전 설계를 부순다.  
있더라도 유니크 고정 효과로 아주 제한적으로만 허용한다.

---

## 3. 전역 보상 구조

## 3-1. 보스 구간 분류

### 튜토리얼 / 프롤로그 보스
- 1장 로드릭
- 2장 하드렌 요새장

규칙:
- 랜덤 무기 드롭 없음
- 스토리 보상 / 보물상자 / 악세사리 중심

### 고정 보상 전환 보스
- 3장 케르만

규칙:
- 첫 클리어 시 **고정 테마 무기 1개**
- 메인라인에선 회상 토벌전 없음
- 랜덤 드롭 정식 개시는 4장부터

### 표준 랜덤 보스
- 4장 바실
- 5장 헤스
- 6장 발가르
- 7장 사리아
- 8장 레테
- 9A 바르텐
- 9B 멜키온

### 최종 보스
- 10장 카르온

규칙:
- 첫 클리어 최소 영웅
- 최종 회상 토벌전 해금
- 일반 보스보다 높은 유니크 비율 허용

---

## 3-2. 첫 클리어 / 회상 토벌전 기본 규칙

### 첫 클리어
- 최소 희귀도 보장
- 문장 1개 지급
- 해당 보스 회상 토벌전 해금
- 보스 테마 무기군 가중치 적용
- 스토리상 막 합류한 동료 무기군에 추가 가중치 적용 가능

### 회상 토벌전
- 최소 고급 보장
- 랜덤 무기 1개
- 추가 드롭 확률 존재
- 보스 문장 1개
- 짧은 플레이타임

### 최종 보스 첫 클리어
- 최소 영웅 보장
- 유니크 확률 상향
- 최종 회상 토벌전 해금

---

## 3-3. 보스 문장 지급 규칙

기본:
- 모든 랜덤 보스 첫 클리어: 문장 1개
- 모든 랜덤 보스 회상 토벌전 클리어: 문장 1개
- 일부 서브 목표 달성 시 +1 추가 가능

주의:
- 5장에서 문장 장부 UI가 열린다
- 하지만 4장 바실부터 문장은 **숨겨진 상태로 적립**할 수 있다
- 즉, 바실 문장은 5장 UI 해금 이후 표시된다

### 권장 hidden accrual
- 4장 바실 첫 클리어: 1 hidden sigil
- 4장 바실 토벌전: UI 해금 전에는 진입 불가
- 3장 케르만은 메인라인 랜덤 토벌이 없으므로 hidden sigil 없음

---

## 3-4. 옵션 풀 공통 규칙

### 전역 허용 어픽스 가족
- 공격 계열
- 명중 계열
- 특정 상태 대상 추가 피해
- 특정 지형 강화
- 망각 저항 보조
- 표식 대응
- 정화/해제 보조
- 방어 지형 보조
- 규칙 개정 예고/저항 보조

### 전역 금지 어픽스
```text
affix_extra_range
affix_extra_move
affix_extra_turn
affix_revive
affix_global_aura
affix_full_anchor_immunity
affix_full_revision_immunity
```

중복 금지 원칙

비슷한 효과를 주는 강한 어픽스는 서로 막는다.

예:

affix_tracker 와 affix_of_full_reveal
affix_cleansing 와 affix_double_cleanse
affix_sentinel 와 affix_rampart_core
3-5. 중복 유니크 처리 규칙

이미 얻은 유니크가 다시 나오면 아래로 대체한다.

문장 +3
기억분말 지급
유니크 재드롭 자체는 인벤토리에 추가하지 않음
이유
중복 유니크는 체감 가치가 낮다
대신 문장과 재료를 줘서 누적 진척감을 보장한다
4. 희귀도 분포 기준
4-1. 희귀도 정의
advanced : 옵션 1개
rare     : 옵션 2개
heroic   : 옵션 3개
unique   : 고정 고유 효과 / 고정 이름
첫 클리어 최소치
4~9B 보스: rare
10장 카르온: heroic
회상 토벌 최소치
4~9B 보스: advanced
10장 카르온: rare
4-2. 구간별 기본 분포
4~6장 회상 토벌전
advanced = 40
rare     = 42
heroic   = 15
unique   = 3
7~9B 회상 토벌전
advanced = 20
rare     = 50
heroic   = 23
unique   = 7
10장 회상 토벌전
rare     = 20
heroic   = 60
unique   = 20
4-3. 첫 클리어 기본 분포
4~6장 첫 클리어
rare   = 70
heroic = 24
unique = 6
7~9B 첫 클리어
rare   = 50
heroic = 35
unique = 15
10장 첫 클리어
heroic = 80
unique = 20
5. 어픽스 철학 가족

보스별 선호 어픽스를 문서적으로 통일하기 위해 아래 가족을 정의한다.

5-1. 화공 / 추격
affix_resinous
affix_hunters
affix_of_embertrail
affix_of_greenwood
5-2. 정화 / 물 / 의식
affix_cleansing
affix_clearstream
affix_of_tide
affix_psalmic
5-3. 검열 / 봉인 / 여백
affix_marginal
affix_censoring
affix_of_sealbreak
affix_of_ash
5-4. 방벽 / 질서 / 수호
affix_sentinel
affix_oathbound
affix_of_rampart
affix_of_watch
5-5. 자비 / 보호 / 기억 유지
affix_solacing
affix_hallowed
affix_of_remembrance
affix_of_procession
5-6. 표식 / 은신 / 사냥
affix_tracker
affix_shadowed
affix_of_isolation
affix_of_the_hunt
5-7. 감찰 / 돌파 / 증언 보호
affix_inspector
affix_vanguard
affix_of_breakthrough
affix_of_witness
5-8. 개정 / 정본 / 교정
affix_indexed
affix_redlined
affix_of_margin
affix_of_proof
5-9. 공명 / 월식 / 앵커
affix_resonant
affix_anchorbound
affix_of_eclipse
affix_of_remnant
6. 튜토리얼 보스 처리
6-1. 로드릭
랜덤 무기 없음
스토리 보상만
드롭 테이블 리소스 생성 안 함
6-2. 하드렌 요새장
랜덤 무기 없음
보물상자/악세사리 중심
드롭 테이블 리소스 생성 안 함
7. 3장 케르만 고정 보상 테이블

케르만은 메인라인 랜덤 드롭 보스가 아니다.
대신 첫 보스 무기 체험용 고정 보상 보스다.

리소스 ID
loot_boss_kerman_fixed
보상 구조
첫 클리어 시 1개 지급
rarity는 rare 또는 heroic-lite 고정 템플릿
랜덤 어픽스 사용 안 함
회상 토벌전 미해금 (v1 기준)
무기군 가중치
bow   = 50
sword = 30
staff = 20
tome  = 0
lance = 0
고정 풀
fixed_sword_greenwood_tracker     # 녹영 추적검
fixed_bow_resin_longbow           # 송진 장궁
fixed_staff_mist_cleansing_rod    # 안개 정화봉
희귀 고정 유니크 변형 후보
uniq_sword_leafcleaver            # 잎새를 가르는 검
uniq_bow_hidden_path              # 숨은 길의 장궁
uniq_staff_dawn_dew               # 새벽이슬 지팡이
선택 규칙
첫 클리어 기본은 고정 rare 템플릿
서브 목표 봉화 3개 소등 후 격파 달성 시 heroic-lite 템플릿 우선
문장은 메인라인에서는 지급하지 않음
선호 어픽스 가족

고정 템플릿이므로 실사용 없음.
후일 확장 시 아래 가족 사용.

affix_resinous
affix_hunters
affix_of_embertrail
affix_of_greenwood
8. 4장 바실
리소스 ID
loot_boss_basil
철학 태그
purification
ritual
drowning
memory_washing
첫 클리어
min_rarity = rare
rarity_weights:
  rare   = 70
  heroic = 24
  unique = 6
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_basil
min_rarity = advanced
rarity_weights:
  advanced = 40
  rare     = 42
  heroic   = 15
  unique   = 3
sigils = 1
bonus_drop_chance = 0.20
무기군 가중치
staff = 40
sword = 35
bow   = 25
tome  = 0
lance = 0
베이스 풀
base_sword_clearstream_vow        # 청류 성검
base_bow_pilgrim_tidebow          # 순례 장궁
base_staff_ritual_hymn_rod        # 성가 순례봉
유니크 풀
uniq_sword_wavecleaver            # 파문을 가르는 검
uniq_bow_mirrorwater              # 물거울 장궁
uniq_staff_dawnbelltower          # 새벽 종루봉
선호 어픽스
affix_cleansing
affix_clearstream
affix_of_tide
affix_psalmic
금지 어픽스
affix_tracker
affix_of_isolation
affix_vanguard
서브 목표 보정

조건:

오염 제단 3개 전부 정화 후 격파

효과:

heroic_weight_add = 5
unique_weight_add = 1
extra_sigil = 1
9. 5장 헤스
리소스 ID
loot_boss_hes
철학 태그
censorship
burning_records
sealing
redaction
첫 클리어
min_rarity = rare
rarity_weights:
  rare   = 70
  heroic = 24
  unique = 6
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_hes
min_rarity = advanced
rarity_weights:
  advanced = 40
  rare     = 42
  heroic   = 15
  unique   = 3
sigils = 1
bonus_drop_chance = 0.20
무기군 가중치
tome  = 35
staff = 30
sword = 20
bow   = 15
lance = 0
베이스 풀
base_sword_grey_margin_blade      # 회색 여백검
base_bow_censor_longbow           # 검열 장궁
base_staff_seal_pilgrim_rod       # 봉서 순례봉
base_tome_rearchive_codex         # 재기록 마도서
유니크 풀
uniq_sword_left_margin            # 남겨진 여백의 검
uniq_bow_burnt_index              # 불탄 목록의 장궁
uniq_tome_sealed_reply            # 봉인답서
선호 어픽스
affix_marginal
affix_censoring
affix_of_sealbreak
affix_of_ash
금지 어픽스
affix_clearstream
affix_of_tide
affix_anchorbound
서브 목표 보정

조건:

봉인 기록통 2개 이상 회수 후 격파

효과:

heroic_weight_add = 5
unique_weight_add = 1
extra_sigil = 1
10. 6장 발가르
리소스 ID
loot_boss_valgar
철학 태그
bastion
order
fortress
formation
첫 클리어
min_rarity = rare
rarity_weights:
  rare   = 70
  heroic = 24
  unique = 6
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_valgar
min_rarity = advanced
rarity_weights:
  advanced = 40
  rare     = 42
  heroic   = 15
  unique   = 3
sigils = 1
bonus_drop_chance = 0.20
무기군 가중치
sword = 40
staff = 30
bow   = 20
tome  = 10
lance = 0
베이스 풀
base_sword_ironwatch_blade        # 철성 파수검
base_bow_rampart_tracker          # 성루 추적궁
base_staff_oath_guard_rod         # 맹세 수호봉
base_tome_wall_logic_codex        # 방벽 해석서
유니크 풀
uniq_sword_unfailing_wall         # 무너지지 않는 검
uniq_bow_gate_sight               # 성문 사선궁
uniq_staff_iron_core_hymn         # 철심 성가봉
선호 어픽스
affix_sentinel
affix_oathbound
affix_of_rampart
affix_of_watch
금지 어픽스
affix_shadowed
affix_of_isolation
affix_redlined
서브 목표 보정

조건:

동서 카운터웨이트 모두 복구 후 격파

효과:

heroic_weight_add = 5
unique_weight_add = 1
extra_sigil = 1
11. 7장 사리아
리소스 ID
loot_boss_saria
철학 태그
mercy
purification
grief_relief
forgetting_as_grace
첫 클리어
min_rarity = rare
rarity_weights:
  rare   = 50
  heroic = 35
  unique = 15
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_saria
min_rarity = advanced
rarity_weights:
  advanced = 20
  rare     = 50
  heroic   = 23
  unique   = 7
sigils = 1
bonus_drop_chance = 0.25
무기군 가중치
staff = 40
tome  = 30
sword = 20
bow   = 10
lance = 0
베이스 풀
base_sword_relief_vow_blade       # 구휼 서약검
base_bow_procession_guard_bow     # 행렬 파수궁
base_staff_purifying_hymn_staff   # 정화 성가봉
base_tome_mercy_catechism         # 자비 문답서
유니크 풀
uniq_sword_name_knot_blade        # 이름을 묶는 검
uniq_bow_confession_longbow       # 고해의 장궁
uniq_staff_unforgetting_hymn      # 잊지 않는 성가봉
uniq_tome_requiem_catechism       # 위령 문답서
선호 어픽스
affix_solacing
affix_hallowed
affix_of_remembrance
affix_of_procession
금지 어픽스
affix_of_the_hunt
affix_tracker
affix_vanguard
서브 목표 보정

조건:

성가 샘 3개 정화 + 미라/네리 포함 지정 시민 보호

효과:

heroic_weight_add = 6
unique_weight_add = 2
extra_sigil = 1
12. 8장 레테
리소스 ID
loot_boss_lete
철학 태그
marking
stealth
isolation
predatory_forgetting
첫 클리어
min_rarity = rare
rarity_weights:
  rare   = 50
  heroic = 35
  unique = 15
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_lete
min_rarity = advanced
rarity_weights:
  advanced = 20
  rare     = 50
  heroic   = 23
  unique   = 7
sigils = 1
bonus_drop_chance = 0.25
무기군 가중치
bow   = 45
sword = 25
staff = 20
tome  = 10
lance = 0
베이스 풀
base_sword_black_hound_tracker    # 흑견 추적검
base_bow_shadow_hunt_bow          # 그림자 장궁
base_staff_night_pilgrim_rod      # 야행 순례봉
base_tome_ambush_manual           # 잠복 해독서
유니크 풀
uniq_bow_moonscar                 # 달을 긋는 장궁
uniq_sword_bloodtrail             # 혈흔 추적검
uniq_staff_nightchain_hymn        # 밤사슬 성가봉
uniq_tome_lost_path_notes         # 길잃은 해독서
선호 어픽스
affix_tracker
affix_shadowed
affix_of_isolation
affix_of_the_hunt
금지 어픽스
affix_sentinel
affix_of_rampart
affix_psalmic
서브 목표 보정

조건:

검은 봉화 3개 소등 후 격파

효과:

heroic_weight_add = 6
unique_weight_add = 2
extra_sigil = 1
13. 9A 바르텐
리소스 ID
loot_boss_barten
철학 태그
deletion
inspection
witness_erasure
military_control
첫 클리어
min_rarity = rare
rarity_weights:
  rare   = 50
  heroic = 35
  unique = 15
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_barten
min_rarity = advanced
rarity_weights:
  advanced = 20
  rare     = 50
  heroic   = 23
  unique   = 7
sigils = 1
bonus_drop_chance = 0.25
무기군 가중치
lance = 45
sword = 20
staff = 15
bow   = 10
tome  = 10
베이스 풀
base_lance_checkpoint_breaker     # 검문 돌파창
base_sword_standard_splitter      # 군기 파절검
base_bow_rearguard_cover          # 후열 엄호궁
base_staff_returning_oath         # 생환 서약봉
base_tome_inspection_register     # 봉인 판독서
유니크 풀
uniq_lance_bannerless_spear       # 깃발 없는 창
uniq_sword_returning_names        # 돌아올 이름의 검
uniq_bow_testimony_keeper         # 증언 보관궁
uniq_staff_remaining_oath         # 남은 서약봉
uniq_tome_censor_breaker          # 검열 파기서
선호 어픽스
affix_inspector
affix_vanguard
affix_of_breakthrough
affix_of_witness
금지 어픽스
affix_shadowed
affix_of_the_hunt
affix_clearstream
서브 목표 보정

조건:

감찰 봉인주 3개 전부 파괴 후 격파

효과:

heroic_weight_add = 6
unique_weight_add = 2
extra_sigil = 1
14. 9B 멜키온
리소스 ID
loot_boss_melchion
철학 태그
revision
redaction
editable_history
index_control
첫 클리어
min_rarity = rare
rarity_weights:
  rare   = 50
  heroic = 35
  unique = 15
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_melchion
min_rarity = advanced
rarity_weights:
  advanced = 20
  rare     = 50
  heroic   = 23
  unique   = 7
sigils = 1
bonus_drop_chance = 0.25
무기군 가중치
tome  = 35
staff = 35
lance = 15
sword = 10
bow   = 5
베이스 풀
base_sword_margin_revision        # 여백 수정검
base_bow_errata_longbow           # 정오표 장궁
base_staff_record_keeper_staff    # 정본 보관봉
base_tome_red_annotation_grimoire # 붉은 주해서
base_lance_revision_pike          # 개정 방첩창
유니크 풀
uniq_sword_preserved_margin       # 남겨진 여백의 검
uniq_bow_final_errata             # 최후 주석궁
uniq_staff_last_revision_staff    # 마지막 교정봉
uniq_tome_forbidden_gloss         # 금지주해서
uniq_lance_canonical_thrust       # 정본 추력창
선호 어픽스
affix_indexed
affix_redlined
affix_of_margin
affix_of_proof
금지 어픽스
affix_of_procession
affix_of_the_hunt
affix_of_rampart
서브 목표 보정

조건:

증언 코덱스 2권 이상 보존 + 붉은 주석 기둥 3개 파괴 후 격파

효과:

heroic_weight_add = 8
unique_weight_add = 2
extra_sigil = 1
15. 10장 카르온
리소스 ID
loot_boss_karon
철학 태그
erasure
resonance
nameless_peace
end_of_recurrence
첫 클리어
min_rarity = heroic
rarity_weights:
  heroic = 80
  unique = 20
sigils = 1
bonus_drop_chance = 0.0
회상 토벌전
hunt_id = hunt_karon
min_rarity = rare
rarity_weights:
  rare   = 20
  heroic = 60
  unique = 20
sigils = 1
bonus_drop_chance = 0.30
무기군 가중치
sword = 25
staff = 25
lance = 20
tome  = 15
bow   = 15
베이스 풀
base_sword_memory_guard           # 기억 수호검
base_bow_resonance_longbow        # 공명 장궁
base_staff_echo_hymn              # 되새김 성가봉
base_tome_inheritance_commentary  # 정본 계승서
base_lance_bellbreaker            # 종막 파쇄창
유니크 풀
uniq_sword_name_remains           # 이름을 남기는 검
uniq_bow_eclipse_arc              # 월식의 장궁
uniq_staff_last_chorale           # 마지막 성가봉
uniq_tome_marginless_commentary   # 여백 없는 주해서
uniq_lance_against_the_bell       # 종을 거스르는 창
선호 어픽스
affix_resonant
affix_anchorbound
affix_of_eclipse
affix_of_remnant
금지 어픽스
affix_resinous
affix_of_ash
affix_of_greenwood
서브 목표 보정

조건:

이름 앵커 4개 유지 + 6인의 이름 부름 전부 발동 후 격파

효과:

heroic_weight_add = 0
unique_weight_add = 5
extra_sigil = 1
특별 규칙
첫 클리어는 최소 heroic
회상 토벌전은 최종 엔드게임 파밍 거점
중복 유니크 보정량을 일반 보스보다 높게 준다
duplicate unique → sigils +4, 기억분말 대량 지급
16. 선택 제작 규칙과의 연결

보스 문장 10개로 선택 제작 시,
각 보스는 아래 풀 안에서만 제작할 수 있다.

제작 가능 범위
해당 보스의 base_pool_ids 기반 희귀 이상 무기
유니크는 제작 불가
어픽스는 지정 불가
무기군 지정은 이미 문장 조율 시스템으로 처리
예
boss_saria 문장 10개 → 사리아 풀의 검/활/지팡이/마도서 중 하나 제작 가능
boss_melchion 문장 10개 → 멜키온 풀의 희귀 이상 무기 1개 선택 제작 가능
특별 규칙
카르온 풀은 heroic 이상만 제작 가능
카르온 풀 선택 제작은 postgame에서만 허용
17. 옵션 교정 규칙과의 연결

9B 이후 열리는 옵션 교정은 아래 기준을 따른다.

교정 가능
rare
heroic
교정 불가
unique
fixed reward template (케르만 고정 템플릿)
교정 범위
어픽스 1개만 재굴림
선호/금지 어픽스 규칙은 보스 출신을 그대로 따른다
즉, 멜키온 무기에서 affix_of_the_hunt 같은 레테 계열 어픽스는 나올 수 없다
이유

보스 무기의 정체성을 유지하기 위해서다.

18. 구현 체크리스트
필수
1~2장 보스는 랜덤 드롭 테이블 없음
3장 케르만은 고정 보상만
4장부터 랜덤 드롭과 회상 토벌전 시작
첫 클리어 최소 희귀도 보장
회상 토벌전은 최소 고급 보장
유니크 중복은 재화로 대체
어픽스 허용/금지 규칙 구현
문장 hidden accrual 지원
서브 목표 달성 시 rarity weight 보정 지원
금지
보스 철학과 무관한 어픽스 섞기
초반 보스에서 과도한 엔드게임급 옵션 등장
첫 클리어에서 쓰레기 드롭 체감 만들기
유니크를 선택 제작 가능하게 두기
19. 빠른 요약
첫 랜덤 보스 시작
4장 바실
첫 고정 보스 무기 체험
3장 케르만
활 편향
8장 레테
창 편향
9A 바르텐
지팡이/마도서 편향
4장 바실
7장 사리아
9B 멜키온
최종 엔드게임 풀
10장 카르온
20. 최종 메모

이 프로젝트에서 보스 드롭은 단순한 파밍 테이블이 아니다.
그건 플레이어가 무엇과 싸웠는지 손에 남는 형태여야 한다.

즉,

사리아를 이기면 사람을 붙잡는 장비가 남고
레테를 이기면 흔적을 읽는 장비가 남고
멜키온을 이기면 편집을 버티는 장비가 남고
카르온을 이기면 이름을 남기는 장비가 남아야 한다

이 원칙만 지키면, 랜덤 드롭도 서사를 깨지 않고 오히려 강화한다.
