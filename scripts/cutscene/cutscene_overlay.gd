class_name CutsceneOverlay
extends CanvasLayer

## 컷씬 오버레이 — 플레이 중 입력 블록, beat 표시, 스킵 처리
## layer = 128이므로 배틀 보드(layer 1~10)보다 위에서 모든 입력을 소비.

@onready var _background: ColorRect  = $Background
@onready var _player: CutscenePlayer = $CutscenePlayer
@onready var _header_label: Label = $Content/HeaderLabel
@onready var _meta_label: Label = $Content/MetaLabel
@onready var _beat_label: RichTextLabel = $Content/BeatLabel
@onready var _skip_button: Button      = $Content/SkipButton

const DEFAULT_BACKGROUND_COLOR := Color(0, 0, 0, 0.85)

signal overlay_finished(cutscene_id: StringName, skipped: bool)

func _ready() -> void:
    visible = false
    if _skip_button != null:
        _skip_button.pressed.connect(_on_skip_pressed)
    if _player != null:
        _player.cutscene_finished.connect(_on_player_finished)
        _player.beat_started.connect(_on_beat_started)

## 컷씬 시작
func play_cutscene(data) -> void:
    if data == null:
        return
    visible = true
    if _background != null:
        _background.color = DEFAULT_BACKGROUND_COLOR
    if _header_label != null:
        _header_label.text = ""
        _header_label.visible = false
    if _meta_label != null:
        _meta_label.text = ""
        _meta_label.visible = false
    if _beat_label != null:
        _beat_label.text = ""
    if _skip_button != null:
        _skip_button.visible = data.skippable
    if _player != null:
        _player.play(data)

func is_playing() -> bool:
    return _player != null and _player.is_playing()

func advance_immediate() -> void:
    if _player != null and _player.is_playing():
        _player.advance_beat_immediate()

func get_snapshot() -> Dictionary:
    var player_snapshot: Dictionary = _player.get_snapshot() if _player != null else {}
    return {
        "visible": visible,
        "is_playing": is_playing(),
        "header": _header_label.text if _header_label != null else "",
        "meta": _meta_label.text if _meta_label != null else "",
        "text": _beat_label.text if _beat_label != null else "",
        "cutscene_id": player_snapshot.get("cutscene_id", &""),
        "beat_index": player_snapshot.get("beat_index", -1),
        "beat_total": player_snapshot.get("beat_total", 0)
    }

## 입력 소비 — 컷씬 재생 중이면 모든 입력 블록
func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    get_viewport().set_input_as_handled()

    # 클릭/터치/스페이스로 beat 진행
    var advance := false
    if event is InputEventMouseButton and event.pressed:
        advance = true
    elif event is InputEventScreenTouch and event.pressed:
        advance = true
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
            advance = true

    if advance and _player != null and _player.is_playing():
        _player.advance_beat_immediate()

# --- 시그널 핸들러 ---

func _on_beat_started(beat_index: int, beat: Dictionary) -> void:
    _apply_visual_beat_metadata(beat)
    if _beat_label == null:
        return
    var beat_type: String = String(beat.get("type", ""))
    var text: String = String(beat.get("text", ""))
    var speaker: String = String(beat.get("speaker", "")).strip_edges()
    match beat_type:
        "text_card":
            if not speaker.is_empty():
                _beat_label.text = "[center][b]%s[/b]\n%s[/center]" % [speaker, text]
            else:
                _beat_label.text = "[center]%s[/center]" % text
        "fragment_flash":
            _beat_label.text = "[center][color=#C9A84C]기억 조각 복원됨[/color]\n%s[/center]" % text
        "command_unlock":
            _beat_label.text = "[center][color=#7ECFCF]커맨드 해금됨[/color]\n%s[/center]" % text
        "black_screen":
            _beat_label.text = "[center]%s[/center]" % text if not text.is_empty() else ""
        _:
            _beat_label.text = ""

func _on_skip_pressed() -> void:
    if _player != null:
        _player.skip()

func _on_player_finished(cutscene_id: StringName, skipped: bool) -> void:
    visible = false
    if _background != null:
        _background.color = DEFAULT_BACKGROUND_COLOR
    if _header_label != null:
        _header_label.text = ""
        _header_label.visible = false
        _header_label.modulate = Color.WHITE
    if _meta_label != null:
        _meta_label.text = ""
        _meta_label.visible = false
        _meta_label.modulate = Color.WHITE
    if _beat_label != null:
        _beat_label.text = ""
    overlay_finished.emit(cutscene_id, skipped)

func _apply_visual_beat_metadata(beat: Dictionary) -> void:
    if _background != null and beat.has("background_color"):
        _background.color = Color(beat.get("background_color", DEFAULT_BACKGROUND_COLOR))
    elif _background != null:
        _background.color = DEFAULT_BACKGROUND_COLOR
    if _header_label != null:
        _header_label.text = String(beat.get("header", ""))
        _header_label.visible = not _header_label.text.is_empty()
        _header_label.modulate = Color(beat.get("header_color", Color.WHITE)) if beat.has("header_color") else Color.WHITE
    if _meta_label != null:
        var meta_parts: PackedStringArray = []
        var speaker: String = String(beat.get("speaker", "")).strip_edges()
        var mood: String = String(beat.get("mood", "")).strip_edges()
        if not speaker.is_empty():
            meta_parts.append(speaker)
        if not mood.is_empty():
            meta_parts.append(mood)
        _meta_label.text = "  /  ".join(meta_parts)
        _meta_label.visible = not _meta_label.text.is_empty()
        _meta_label.modulate = Color(beat.get("meta_color", Color.WHITE)) if beat.has("meta_color") else Color.WHITE
