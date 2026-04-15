class_name CutsceneOverlay
extends CanvasLayer

## 컷씬 오버레이 — 플레이 중 입력 블록, beat 표시, 스킵 처리
## layer = 128이므로 배틀 보드(layer 1~10)보다 위에서 모든 입력을 소비.

@onready var _background: ColorRect  = $Background
@onready var _player: CutscenePlayer = $CutscenePlayer
@onready var _beat_label: RichTextLabel = $Content/BeatLabel
@onready var _skip_button: Button      = $Content/SkipButton

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
    if _beat_label != null:
        _beat_label.text = ""
    if _skip_button != null:
        _skip_button.visible = data.skippable
    if _player != null:
        _player.play(data)

func is_playing() -> bool:
    return _player != null and _player.is_playing()

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
    if _beat_label == null:
        return
    var beat_type: String = String(beat.get("type", ""))
    match beat_type:
        "text_card":
            _beat_label.text = "[center]%s[/center]" % String(beat.get("text", ""))
        "fragment_flash":
            _beat_label.text = "[center][color=#C9A84C]기억 조각 복원됨[/color]\n%s[/center]" % String(beat.get("text", ""))
        "command_unlock":
            _beat_label.text = "[center][color=#7ECFCF]커맨드 해금됨[/color]\n%s[/center]" % String(beat.get("text", ""))
        "black_screen":
            _beat_label.text = ""
        _:
            _beat_label.text = ""

func _on_skip_pressed() -> void:
    if _player != null:
        _player.skip()

func _on_player_finished(cutscene_id: StringName, skipped: bool) -> void:
    visible = false
    if _beat_label != null:
        _beat_label.text = ""
    overlay_finished.emit(cutscene_id, skipped)
