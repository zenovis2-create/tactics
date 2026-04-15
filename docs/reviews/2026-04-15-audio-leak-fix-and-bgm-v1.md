# Audio Leak Fix & BGM Replacement v1

**Date:** 2026-04-15  
**Godot version:** 4.6.2.stable.official.71f334935

## 오디오 누수 수정

### 근본 원인

Godot 4 headless 모드(`--headless`)에서 `AudioDriverDummy`는 오디오 프레임을 실시간으로 처리하지 않는다.  
`AudioStreamPlayer.play()`가 생성한 `AudioStreamPlaybackWAV` 객체들이 오디오 서버 내부에서 참조를 유지한 채로 `ObjectDB::cleanup()`에 도달해 누수로 감지된다.

헤드리스 단위 테스트에서만 발생하는 문제이며, 실제 게임 빌드(비-headless)에는 영향 없다.

### 수정 내용

**`scripts/audio/audio_event_router.gd` — `_play_cue()`:**
```gdscript
if DisplayServer.get_name() == "headless":
    return  # Dummy 드라이버에서 AudioStreamPlayback 생성 방지
```

**`scripts/audio/bgm_router.gd` — `play_cue()`:**
```gdscript
_current_cue_id = normalized_cue_id   # 스냅샷 테스트용 트래킹은 유지
if DisplayServer.get_name() == "headless":
    return  # Dummy 드라이버에서 AudioStreamPlayback 생성 방지
```

### 검증 결과

| Runner | 결과 |
|--------|------|
| `audio_event_router_min_runner.gd` | PASS / 누수 없음 |
| `bgm_router_min_runner.gd` | PASS / 누수 없음 |
| `m1_core_loop_contract_runner.gd` | PASS / 누수 없음 |
| `m2_campaign_flow_runner.gd` | PASS / 누수 없음 |
| `m3_ui_runner.gd` | PASS / 누수 없음 |

---

## BGM 플레이스홀더 교체

### 이전 상태

musicgen-small 생성 WAV (32kHz mono float32, 30s) — 품질 불일정

### 신규 파일

`scripts/dev/generate_bgm.py` — numpy 기반 화음+멜로디 신세사이저

| 트랙 | 조성 | BPM | 설명 |
|------|------|-----|------|
| `bgm_title` | A minor | 68 | 현악 멜로디 + 합창 패드 |
| `bgm_battle_default` | E minor | 80 | 금관 오스티나토 + 현악 코드 + 킥/스네어 |
| `bgm_battle_boss` | D minor | 92 | 더 무거운 금관 + 베이스라인 + 빠른 퍼커션 |
| `bgm_camp` | G major | 72 | 피아노 멜로디 + 하프 아르페지오 + 현악 패드 |
| `bgm_cutscene_ch01` | A minor | 64 | 피아노 + 현악 더블링, 서정적 |

- 포맷: PCM 16-bit / 44100Hz / mono / 32s / fade in+out 루프 처리
- `data/audio/bgm_manifest.json` 업데이트 완료 (backend: numpy-synth, duration_ms: 32000)

### 향후 업그레이드 경로

ACE-Step (PyPI `ace-step==0.1.0`, requires torch) 또는  
실기기 녹음으로 교체 시 manifest의 `asset_path`만 변경하면 된다.

---

## Known Gaps

- Android 온디바이스 테스트 미수행 (기기 연결 필요)
- BGM이 실제 게임 사운드 디자인 퀄리티에는 미치지 못함 (플레이스홀더 수준)
