class_name CutscenePlayer
extends Node

## 컷씬 플레이어 — beat 시퀀스를 순서대로 재생
## 비동기 설계: play()는 반환 즉시 재생 시작, cutscene_finished 시그널로 완료 알림
## 헤드리스 환경에서도 동작 (Timer 대신 process_frame 기반 진행)

const CutsceneData = preload("res://scripts/cutscene/cutscene_data.gd")

const BEAT_TEXT_CARD: StringName = &"text_card"
const BEAT_FRAGMENT_FLASH: StringName = &"fragment_flash"
const BEAT_COMMAND_UNLOCK: StringName = &"command_unlock"
const BEAT_BLACK_SCREEN: StringName = &"black_screen"

signal cutscene_finished(cutscene_id: StringName, skipped: bool)
signal beat_started(beat_index: int, beat: Dictionary)
signal beat_finished(beat_index: int)

var _active_data: CutsceneData = null
var _current_beat_index: int = -1
var _is_playing: bool = false
var _is_skipped: bool = false
var _beat_elapsed: float = 0.0
var _event_log: Array[Dictionary] = []

## 기본 beat 재생 시간 (초). 실제 씬에서는 Timer로 대체 가능.
const DEFAULT_BEAT_DURATION: float = 3.0

func play(data: CutsceneData) -> void:
    if data == null or not data.is_valid():
        push_warning("CutscenePlayer.play(): invalid CutsceneData")
        return
    _active_data = data
    _current_beat_index = -1
    _is_playing = true
    _is_skipped = false
    _beat_elapsed = 0.0
    _event_log.append({"event": "cutscene_started", "id": data.cutscene_id})
    _advance_beat()

func skip() -> void:
    if not _is_playing or _active_data == null:
        return
    if not _active_data.skippable:
        return
    _is_skipped = true
    _finish_cutscene()

func is_playing() -> bool:
    return _is_playing

func get_current_beat() -> Dictionary:
    if _active_data == null or _current_beat_index < 0:
        return {}
    return _active_data.get_beat(_current_beat_index)

func get_event_log() -> Array[Dictionary]:
    return _event_log.duplicate()

func get_snapshot() -> Dictionary:
    return {
        "is_playing": _is_playing,
        "cutscene_id": _active_data.cutscene_id if _active_data != null else &"",
        "beat_index": _current_beat_index,
        "beat_total": _active_data.get_beat_count() if _active_data != null else 0,
        "is_skipped": _is_skipped
    }

## 헤드리스 테스트용: 현재 beat를 즉시 완료하고 다음으로 진행
func advance_beat_immediate() -> void:
    if not _is_playing:
        return
    _on_beat_complete()

# --- Private ---

func _advance_beat() -> void:
    _current_beat_index += 1
    if _active_data == null or _current_beat_index >= _active_data.get_beat_count():
        _finish_cutscene()
        return
    var beat: Dictionary = _active_data.get_beat(_current_beat_index)
    _beat_elapsed = 0.0
    _event_log.append({
        "event": "beat_started",
        "index": _current_beat_index,
        "type": beat.get("type", "")
    })
    beat_started.emit(_current_beat_index, beat)
    _process_beat(beat)

func _process_beat(beat: Dictionary) -> void:
    var beat_type: StringName = StringName(String(beat.get("type", "")))
    match beat_type:
        BEAT_FRAGMENT_FLASH:
            # 기억 조각 획득 연출 — 즉시 처리 가능 (overlay 없어도 로그 기록)
            _event_log.append({
                "event": "fragment_flash",
                "fragment_id": beat.get("fragment_id", ""),
                "text": beat.get("text", "기억 조각 복원됨")
            })
        BEAT_COMMAND_UNLOCK:
            _event_log.append({
                "event": "command_unlock",
                "command_id": beat.get("command_id", ""),
                "text": beat.get("text", "커맨드 해금됨")
            })
        _:
            pass  # text_card, black_screen은 UI 레이어에서 처리

func _on_beat_complete() -> void:
    if not _is_playing:
        return
    beat_finished.emit(_current_beat_index)
    _event_log.append({"event": "beat_finished", "index": _current_beat_index})
    _advance_beat()

func _finish_cutscene() -> void:
    _is_playing = false
    var finished_id: StringName = _active_data.cutscene_id if _active_data != null else &""
    _event_log.append({"event": "cutscene_finished", "id": finished_id, "skipped": _is_skipped})
    cutscene_finished.emit(finished_id, _is_skipped)
    _active_data = null
    _current_beat_index = -1
