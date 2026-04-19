class_name InteractiveObjectActor
extends Node2D

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const InteractiveObjectData = preload("res://scripts/data/interactive_object_data.gd")
const OBJECT_VISUAL_CONTRACTS := {
    "altar": {
        "icon": "altar.png",
        "marker_active": Color(0.933333, 0.721569, 0.239216, 0.9),
        "marker_resolved": Color(0.572549, 0.482353, 0.262745, 0.55),
        "inner_active": Color(0.352941, 0.282353, 0.121569, 0.95),
        "inner_resolved": Color(0.262745, 0.223529, 0.141176, 0.72),
        "accent": Color(1.0, 0.882353, 0.505882, 0.96)
    },
    "shrine": {
        "icon": "altar.png",
        "marker_active": Color(0.521569, 0.65098, 0.92549, 0.92),
        "marker_resolved": Color(0.341176, 0.411765, 0.619608, 0.58),
        "inner_active": Color(0.192157, 0.231373, 0.392157, 0.96),
        "inner_resolved": Color(0.14902, 0.180392, 0.286275, 0.74),
        "accent": Color(0.803922, 0.878431, 1.0, 0.98)
    },
    "chest": {
        "icon": "chest.png",
        "marker_active": Color(0.933333, 0.721569, 0.239216, 0.9),
        "marker_resolved": Color(0.572549, 0.482353, 0.262745, 0.55),
        "inner_active": Color(0.352941, 0.282353, 0.121569, 0.95),
        "inner_resolved": Color(0.262745, 0.223529, 0.141176, 0.72),
        "accent": Color(1.0, 0.882353, 0.505882, 0.96)
    },
    "gate": {
        "icon": "gate.png",
        "marker_active": Color(0.698039, 0.505882, 0.25098, 0.9),
        "marker_resolved": Color(0.470588, 0.392157, 0.247059, 0.55),
        "inner_active": Color(0.396078, 0.286275, 0.14902, 0.95),
        "inner_resolved": Color(0.27451, 0.219608, 0.145098, 0.72),
        "accent": Color(0.878431, 0.729412, 0.486275, 0.98)
    },
    "lever": {
        "icon": "lever.png",
        "marker_active": Color(0.282353, 0.760784, 0.568627, 0.85),
        "marker_resolved": Color(0.156863, 0.505882, 0.396078, 0.65),
        "inner_active": Color(0.129412, 0.356863, 0.266667, 0.95),
        "inner_resolved": Color(0.101961, 0.25098, 0.184314, 0.72),
        "accent": Color(0.615686, 0.952941, 0.784314, 0.98)
    }
}
const DEFAULT_OBJECT_VISUAL_FAMILY := "altar"

signal interacted(actor: InteractiveObjectActor, by_unit: UnitActor)

@export var object_data: InteractiveObjectData

var grid_position: Vector2i = Vector2i.ZERO
var is_resolved: bool = false
var _highlighted: bool = false
var _beacon_pulse_tween: Tween
var _icon_cache: Dictionary = {}

@onready var shadow: ColorRect = $Shadow
@onready var halo: ColorRect = $Halo
@onready var beacon: ColorRect = $Beacon
@onready var beacon_ring: ColorRect = $BeaconRing
@onready var frame: ColorRect = $Frame
@onready var marker: ColorRect = $Marker
@onready var accent: ColorRect = $Accent
@onready var inner: ColorRect = $Inner
@onready var icon: TextureRect = $Icon
@onready var name_plate_back: ColorRect = $NamePlateBack
@onready var name_label: Label = $NameLabel

func _ready() -> void:
    if object_data != null:
        setup_from_data(object_data)
    else:
        _refresh_visuals()

func setup_from_data(data: InteractiveObjectData, cell_size: Vector2i = Vector2i(64, 64)) -> void:
    object_data = data
    grid_position = data.grid_position
    position = Vector2(grid_position.x * cell_size.x, grid_position.y * cell_size.y)
    is_resolved = false
    _refresh_visuals()

func can_interact(unit: UnitActor) -> bool:
    if object_data == null or unit == null or not is_instance_valid(unit):
        return false

    if is_resolved and object_data.one_time_use:
        return false

    var distance: int = abs(unit.grid_position.x - grid_position.x) + abs(unit.grid_position.y - grid_position.y)
    return distance <= object_data.interaction_range

func resolve_interaction(by_unit: UnitActor) -> Dictionary:
    if object_data == null:
        return {"resolved": false, "reason": "missing_object_data"}

    if is_resolved and object_data.one_time_use:
        return {
            "resolved": false,
            "reason": "already_resolved",
            "object_id": object_data.object_id,
            "object_type": object_data.object_type
        }

    if object_data.one_time_use:
        is_resolved = true

    _refresh_visuals()
    interacted.emit(self, by_unit)

    return {
        "resolved": true,
        "object_id": object_data.object_id,
        "object_type": object_data.object_type,
        "reward_text": object_data.reward_text,
        "interaction_text": object_data.interaction_text,
        "story_flag": _get_story_flag()
    }

func blocks_movement() -> bool:
    if object_data == null:
        return false

    return object_data.blocks_movement_when_resolved if is_resolved else object_data.blocks_movement_while_active

func set_highlighted(value: bool) -> void:
    var was_highlighted: bool = _highlighted
    _highlighted = value
    _refresh_visuals()
    if value and not was_highlighted:
        _play_beacon_pulse()

func _refresh_visuals() -> void:
    if name_label != null:
        name_label.text = object_data.display_name if object_data != null else "Object"
        name_label.visible = _highlighted or not is_resolved

    if shadow != null:
        shadow.color = Color(0, 0, 0, 0.18 if is_resolved else 0.24)
    if halo != null:
        halo.color = _get_halo_color()
    if beacon != null:
        beacon.visible = _highlighted and not is_resolved
        beacon.color = Color(1.0, 0.917647, 0.65098, 0.22)
    if beacon_ring != null:
        beacon_ring.visible = _highlighted and not is_resolved
        beacon_ring.color = Color(1.0, 0.92549, 0.701961, 0.12)
    if frame != null:
        frame.color = Color(0.121569, 0.101961, 0.0588235, 0.95)
    if marker != null:
        marker.color = _get_marker_color()
    if accent != null:
        accent.color = _get_accent_color()
    if inner != null:
        inner.color = _get_inner_color()
    if icon != null:
        icon.texture = _get_object_icon_texture()
        icon.modulate = _get_icon_modulate()
        icon.visible = icon.texture != null
    if name_plate_back != null:
        name_plate_back.color = Color(0.105882, 0.0901961, 0.0470588, 0.82)
        name_plate_back.visible = _highlighted or not is_resolved

func _get_halo_color() -> Color:
    if _highlighted and not is_resolved:
        return Color(1.0, 0.894118, 0.541176, 0.34)
    return Color(0.996078, 0.858824, 0.388235, 0.14 if is_resolved else 0.24)

func _get_marker_color() -> Color:
    var contract := _get_object_visual_contract()
    if contract.is_empty():
        return Color(0.6, 0.6, 0.6, 0.8)

    return Color(contract.get("marker_resolved")) if is_resolved else Color(contract.get("marker_active"))

func _get_inner_color() -> Color:
    var contract := _get_object_visual_contract()
    if contract.is_empty():
        return Color(0.35, 0.35, 0.35, 0.9)

    return Color(contract.get("inner_resolved")) if is_resolved else Color(contract.get("inner_active"))

func _get_accent_color() -> Color:
    var contract := _get_object_visual_contract()
    if contract.is_empty():
        return Color(1.0, 0.882353, 0.505882, 0.96)
    return Color(contract.get("accent", Color(1.0, 0.882353, 0.505882, 0.96)))

func _get_icon_modulate() -> Color:
    if is_resolved:
        return Color(1.0, 1.0, 1.0, 0.55)
    if _highlighted:
        return Color(1.0, 1.0, 1.0, 0.96)
    return Color(1.0, 1.0, 1.0, 0.82)

func _get_object_icon_texture() -> Texture2D:
    var contract := _get_object_visual_contract()
    if contract.is_empty():
        return null

    return _load_runtime_icon(String(contract.get("icon", "")))

func _load_runtime_icon(file_name: String) -> Texture2D:
    if file_name.is_empty():
        return null
    if _icon_cache.has(file_name):
        return _icon_cache[file_name]
    var texture: Texture2D = BattleArtCatalog.load_object_icon(file_name)
    if texture != null:
        _icon_cache[file_name] = texture
    return texture

func _get_object_visual_contract() -> Dictionary:
    if object_data == null:
        return {}

    var visual_family := _get_object_visual_family(object_data.object_type)
    return OBJECT_VISUAL_CONTRACTS.get(visual_family, OBJECT_VISUAL_CONTRACTS.get(DEFAULT_OBJECT_VISUAL_FAMILY, {}))

func _get_object_visual_family(object_type: String) -> String:
    match object_type:
        "door", "gate":
            return "gate"
        "lever":
            return "lever"
        "chest":
            return "chest"
        "shrine":
            return "shrine"
        "altar":
            return "altar"
        _:
            return DEFAULT_OBJECT_VISUAL_FAMILY

func _get_story_flag() -> StringName:
    if object_data == null:
        return &""
    if object_data.object_type == "shrine":
        return &"mira_shrine_investigated"
    return &""

func _play_beacon_pulse() -> void:
    if beacon_ring == null:
        return
    if _beacon_pulse_tween != null and _beacon_pulse_tween.is_running():
        _beacon_pulse_tween.kill()
    beacon_ring.scale = Vector2.ONE
    beacon_ring.modulate = Color(1.0, 1.0, 1.0, 1.0)
    _beacon_pulse_tween = create_tween()
    _beacon_pulse_tween.tween_property(beacon_ring, "scale", Vector2(1.16, 1.16), 0.18)
    _beacon_pulse_tween.parallel().tween_property(beacon_ring, "modulate:a", 0.4, 0.18)
    _beacon_pulse_tween.tween_property(beacon_ring, "scale", Vector2.ONE, 0.18)
    _beacon_pulse_tween.parallel().tween_property(beacon_ring, "modulate:a", 1.0, 0.18)
