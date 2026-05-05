# Public API visual tooling 적용 메모

대상 API:
- QuickChart
- Kroki
- Shields
- xColors 계열 palette helper

적용 범위:
- 게임 runtime에는 연결하지 않음
- docs / QA / release readiness / asset tooling 보조에만 사용
- 외부 네트워크 호출은 opt-in

구현 파일:
- `/Volumes/AI/tactics/scripts/dev/public_api_visual_tools.py`

생성 예시:

```bash
python3 scripts/dev/public_api_visual_tools.py sample
```

기본 출력:
- `/Volumes/AI/tactics/docs/api_tooling/public_api_visual_tooling_demo.md`
- 현재 커밋된 demo 문서는 네트워크 상태 예시까지 남기기 위해 `sample --check-network` 형태의 출력 구조를 사용합니다. 기본 `sample`은 외부 네트워크 섹션을 생성하지 않습니다.

## QuickChart

용도:
- runner PASS/FAIL 수치 차트
- package blocker 수 차트
- chapter/runtime evidence coverage 요약

예시:

```bash
python3 scripts/dev/public_api_visual_tools.py chart \
  --labels Gate0,Runtime,Package,Public \
  --values 65,12,2,1 \
  --title "Release readiness"
```

## Kroki

용도:
- Mermaid/PlantUML 계열 다이어그램 URL 생성
- battle flow, reward pipeline, release gate map 문서화

예시:

```bash
python3 scripts/dev/public_api_visual_tools.py kroki \
  --type mermaid \
  --text 'graph TD; Runner-->Evidence; Evidence-->Report'
```

## Shields

용도:
- README/release report 상태 badge
- Gate0 PASS, Package BLOCKED, Runtime Evidence PASS 등

예시:

```bash
python3 scripts/dev/public_api_visual_tools.py badge Gate0 PASS brightgreen
python3 scripts/dev/public_api_visual_tools.py badge Package BLOCKED red
```

## xColors 계열 palette helper

public-apis의 xColors 링크는 2026-05-05 확인 시 Heroku `No such app` 응답입니다.
따라서 직접 외부 의존으로 적용하지 않고, 동일 목적의 deterministic local fallback을 적용했습니다.

용도:
- risk/counter/focus UI 색상 토큰
- faction/memory/field 색상 후보
- sprite readability palette 초안

예시:

```bash
python3 scripts/dev/public_api_visual_tools.py palette --seed risk
python3 scripts/dev/public_api_visual_tools.py palette --seed faction
```

## 외부 상태 확인

네트워크 호출이 필요할 때만 실행합니다.

```bash
python3 scripts/dev/public_api_visual_tools.py check
python3 scripts/dev/public_api_visual_tools.py sample --check-network
```

주의:
- 이 스크립트는 URL과 Markdown snippet 생성용입니다.
- Git add/commit은 하지 않았습니다.
- QuickChart/Kroki/Shields는 문서 렌더링 시 외부 이미지를 불러옵니다.
- 릴리즈 패키지에 외부 이미지 의존을 넣을 경우 별도 승인 후 PNG/SVG 캐시 전략을 정해야 합니다.
