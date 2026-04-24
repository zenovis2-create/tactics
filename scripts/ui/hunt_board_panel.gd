class_name HuntBoardPanel
extends Control

## 회상 토벌전 패널 UI

signal hunt_selected(hunt_id: StringName)

const HuntBoard = preload("res://scripts/battle/hunt_board.gd")
const HuntData = preload("res://scripts/data/hunt_data.gd")

var _hunt_board: HuntBoard = null
var _hunt_entries: Array[Dictionary] = []

@onready var hunt_list_container: VBoxContainer = $VBox/HuntListContainer
@onready var locked_message_label: Label = $VBox/LockedMessage

func _ready() -> void:
    if locked_message_label != null:
        locked_message_label.visible = false

func setup(hunt_board: HuntBoard) -> void:
    _hunt_board = hunt_board
    _hunt_entries.clear()
    _refresh_hunt_list()

func setup_entries(entries: Array[Dictionary], selected_hunt_id: StringName = &"") -> void:
    _hunt_board = null
    _hunt_entries = entries.duplicate(true)
    if selected_hunt_id != &"":
        _hunt_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
            if StringName(a.get("hunt_id", &"")) == selected_hunt_id:
                return true
            if StringName(b.get("hunt_id", &"")) == selected_hunt_id:
                return false
            return String(a.get("display_name", "")) < String(b.get("display_name", ""))
        )
    _refresh_hunt_list()

func get_layout_snapshot() -> Dictionary:
    var unlocked_ids: Array[String] = []
    for entry in _hunt_entries:
        if bool(entry.get("unlocked", false)):
            unlocked_ids.append(String(entry.get("hunt_id", "")))
    return {
        "entry_count": hunt_list_container.get_child_count() if hunt_list_container != null else 0,
        "unlocked_ids": unlocked_ids,
        "locked_message_visible": locked_message_label != null and locked_message_label.visible
    }

func _refresh_hunt_list() -> void:
    if hunt_list_container == null:
        return
    for child in hunt_list_container.get_children():
        child.queue_free()
    if _hunt_board != null:
        for hunt: HuntData in _hunt_board.get_all_hunts():
            _add_hunt_button({
                "hunt_id": hunt.hunt_id,
                "display_name": hunt.display_name,
                "difficulty": hunt.difficulty,
                "recommended_level": hunt.recommended_level,
                "reward_memory_fragment": hunt.reward_memory_fragment,
                "reward_gold": hunt.reward_gold,
                "unlocked": _hunt_board.is_unlocked(hunt.hunt_id)
            })
        return
    for entry in _hunt_entries:
        _add_hunt_button(entry)

func _add_hunt_button(entry: Dictionary) -> void:
    var hunt_id: StringName = StringName(entry.get("hunt_id", &""))
    var entry_btn: Button = Button.new()
    var is_locked: bool = not bool(entry.get("unlocked", false))
    entry_btn.text = "%s [난이도 %d / 권장 %d]" % [
        String(entry.get("display_name", hunt_id)),
        int(entry.get("difficulty", 1)),
        int(entry.get("recommended_level", 1))
    ]
    var reward_memory: String = String(entry.get("reward_memory_fragment", "")).strip_edges()
    var reward_gold: int = int(entry.get("reward_gold", 0))
    var tooltip_parts: Array[String] = [String(entry.get("description", ""))]
    if not reward_memory.is_empty():
        tooltip_parts.append("기억 보상: %s" % reward_memory)
    if reward_gold > 0:
        tooltip_parts.append("보상 금화: %d" % reward_gold)
    entry_btn.tooltip_text = "\n".join(tooltip_parts).strip_edges()
    if is_locked:
        entry_btn.text += " 🔒"
        entry_btn.disabled = true
        entry_btn.modulate = Color(0.5, 0.5, 0.5)
    else:
        entry_btn.pressed.connect(_create_hunt_pressed_callback(hunt_id))
    hunt_list_container.add_child(entry_btn)

func _create_hunt_pressed_callback(hunt_id: StringName) -> Callable:
    return func() -> void:
        _on_hunt_entry_button_pressed(hunt_id)

func _on_hunt_entry_button_pressed(hunt_id: StringName) -> void:
    if _hunt_board != null:
        if not _hunt_board.is_unlocked(hunt_id):
            _show_locked_message()
            return
    else:
        var is_unlocked: bool = false
        for entry in _hunt_entries:
            if StringName(entry.get("hunt_id", &"")) == hunt_id:
                is_unlocked = bool(entry.get("unlocked", false))
                break
        if not is_unlocked:
            _show_locked_message()
            return
    hunt_selected.emit(hunt_id)

func _show_locked_message() -> void:
    if locked_message_label != null:
        locked_message_label.visible = true
        var tween: Tween = create_tween()
        tween.tween_interval(2.0)
        tween.tween_callback(func() -> void:
            if locked_message_label != null:
                locked_message_label.visible = false
        )
