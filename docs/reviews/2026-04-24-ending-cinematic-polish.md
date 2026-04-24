# Ending Cinematic Polish Review
## Date: 2026-04-24

## 조사 결과
- `ending_resolver.gd`와 `tests/test_ending_resolver.gd`의 진엔딩 판정 자체는 이미 공명/이름 앵커/이름 부름 기준으로 정렬되어 있었다.
- 실제 미완료 지점은 판정이 아니라 연출이었다.
  - `CutsceneOverlay`는 beat 텍스트 한 줄만 표시해서 엔딩/진엔딩 컷신이 장면 헤더, 화자, 감정 상태 없이 평면적으로 보였다.
  - `black_screen` beat의 텍스트도 화면에 거의 드러나지 않아 엔딩 도입 문장이 약했다.
  - CH10 엔딩 컷신 데이터는 대사만 있고 phase/speaker/mood 같은 연출 메타데이터가 비어 있었다.

## 수행 내용
1. `CutsceneOverlay.tscn`/`cutscene_overlay.gd`
   - HeaderLabel, MetaLabel을 추가했다.
   - beat별 `header`, `speaker`, `mood`, `background_color`, `header_color`, `meta_color`를 해석하도록 확장했다.
   - `black_screen` beat도 도입 텍스트를 실제로 노출하도록 바꿨다.
   - snapshot에 `header`, `meta`를 넣어 headless runner 검증이 가능하게 했다.

2. `cutscene_catalog.gd`
   - `ch10_normal_resolution_cinematic`
   - `ch10_true_resolution_cinematic`
   - `ch10_true_companion_scene`
   위 세 컷신에 phase header / speaker / mood / 팔레트 메타데이터를 추가했다.
   - 대사 본문은 유지하면서 presentation layer만 강화해 다른 축과 충돌하지 않도록 범위를 제한했다.

3. 러너 강화
   - `ending_cinematic_runner.gd`, `true_ending_runner.gd`에 header/meta 검증을 추가해 실제 고도화가 런타임에 반영되는지 체크하도록 보강했다.

## 검증 포인트
- normal ending: 리안 희생 beat에서 화자/감정 메타가 노출되는지 확인
- true ending: 이름 인계 beat header/meta가 노출되는지 확인
- true companion scene: companion header와 mood 메타가 살아 있는지 확인

## 리스크
- `CutsceneOverlay`가 전역 컷신 오버레이이므로 이후 다른 컷신도 새 header/meta 필드를 사용할 수 있다. 기존 컷신은 필드가 없어도 안전하도록 optional 처리했다.
- UI 노드가 늘어나면서 실제 화면 레이아웃에서 줄바꿈이 길어질 수 있으나, 이번 변경은 엔딩 컷신 중심이며 기존 텍스트 흐름은 유지했다.
