# Android Export Validation v1

**Date:** 2026-04-15  
**Godot version:** 4.6.2.stable.official.71f334935  
**Host:** macOS arm64 (Apple Silicon)  
**Preset name:** Android

## Export Command

```bash
godot --headless --export-debug "Android" build/android/memory-tactics-demo.apk
```

## Result

- **Status:** SUCCESS
- **Output artifact:** `build/android/memory-tactics-demo.apk`
- **APK size:** 33 MB
- **Build type:** debug (unsigned)

## Configuration

- **Package ID:** `com.ashenbell.memorytactics`
- **App name:** 잿빛의 기억
- **Version name:** 0.1.0  
- **Version code:** 1
- **Architecture:** arm64-v8a
- **Texture format:** etc2_astc (Android-native)
- **Java SDK:** `/opt/homebrew/opt/openjdk@17` (OpenJDK 17.0.18)
- **Android SDK:** `/Users/daehan/Library/Android/sdk`
- **Gradle build:** disabled (default Godot APK template)

## Pre-Export Gate Status

| Check | Result |
|---|---|
| `check_runnable_gate0.sh` | PASS |
| `m1_core_loop_contract_runner.gd` | PASS |
| `m2_campaign_flow_runner.gd` | PASS |
| `m3_ui_runner.gd` | PASS |
| `touch_input_runner.gd` | PASS |

## Touch Input Validation (Headless)

`touch_input_runner.gd` 결과 — 모든 5개 항목 PASS:

- `touch_tap_on_unit`: InputEventScreenTouch 주입, 크래시 없음
- `touch_drag_scroll`: InputEventScreenDrag 시퀀스 주입, 크래시 없음
- `multi_touch_pinch`: 두 손가락 동시 터치 주입, 크래시 없음
- `touch_hud_button_area`: HUD 영역 터치 주입, 크래시 없음
- `battle_phase_valid_after_touch`: 터치 후 배틀 phase 정상 유지

## Known Gaps (On-Device Not Yet Performed)

실기 디바이스 설치 및 플레이테스트는 아직 미수행. 다음 검증이 남아 있음:

- 실기 Android 디바이스 APK 설치 및 부팅
- 터치 타겟 크기 / 오패커티 가독성 확인
- 텍스트 밀도 확인 (다양한 DPI)
- 1회 Ch01 완주 플레이스루
- 메모리/성능 이상 여부 확인
- 한국어 텍스트 렌더링 확인

## Next Steps

1. Android 디바이스에 APK 사이드로드하여 부팅 확인
2. Ch01 스테이지 1개 이상 완주
3. 결과를 `docs/reviews/2026-04-15-android-device-smoke-v1.md`에 기록
4. 문제 발견 시 `docs/reviews/` 하위에 이슈 기록 후 수정
