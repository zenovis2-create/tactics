class_name BondVisualizer
extends Node2D

## Bond 시스템의 시각적 효과: 연결선, 지원 공격 FX, 피해 분담 FX, 보너스 팝업

const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const BondService = preload("res://scripts/battle/bond_service.gd")

# Bond 레벨별 선 색상
const COLOR_BOND3: Color = Color(0.4, 0.8, 0.9, 0.6)   # 청록색
const COLOR_BOND4: Color = Color(0.9, 0.8, 0.3, 0.7)   # 금색
const COLOR_BOND5: Color = Color(1.0, 1.0, 1.0, 0.9)  # 흰색
const COLOR_SUPPORT: Color = Color(0.5, 0.9, 1.0, 0.9)  # 지원 공격 섬광 (밝은 청록)
const COLOR_SHARE: Color = Color(1.0, 0.5, 0.7, 0.9)    # 피해 분담 (분홍)
const COLOR_BONUS: Color = Color(0.3, 1.0, 0.6, 1.0)    # Bond 보너스 (초록)

# Bond 레벨별 선 두께
const WIDTH_BOND3: float = 2.0
const WIDTH_BOND4: float = 3.0
const WIDTH_BOND5: float = 4.0

# Bond 3+부터 연결선 표시
const MIN_BOND_FOR_CONNECTION: int = 3

@export var cell_size: Vector2i = Vector2i(64, 64)

var _bond_service: BondService = null
var _ally_units: Array = []
var _bond_lines: Array = []  # [{line: Line2D, unit1_id, unit2_id, bond_level}]
var _fx_nodes: Array = []    # 임시 FX 노드들

func _ready() -> void:
    pass

func configure(bond_service: BondService, ally_units: Array, cell_size: Vector2i) -> void:
    _bond_service = bond_service
    _ally_units = ally_units
    self.cell_size = cell_size

func _process(delta: float) -> void:
    _update_bond_connections()
    _cleanup_finished_fx(delta)

func _update_bond_connections() -> void:
    if _bond_service == null or _ally_units.is_empty():
        return

    # Bond 3+ 인접 유닛 쌍 사이의 선을 그림/업데이트
    var valid_pairs: Array = _get_bonded_pairs()

    # 기존 선들 중 유지할 것들, 제거할 것들 분류
    var existing_by_pair: Dictionary = {}
    for line_data in _bond_lines:
        var key: String = _make_pair_key(line_data["unit1_id"], line_data["unit2_id"])
        existing_by_pair[key] = line_data

    var current_pairs: Dictionary = {}
    for pair_data in valid_pairs:
        var key: String = _make_pair_key(pair_data["unit1_id"], pair_data["unit2_id"])
        current_pairs[key] = pair_data

    # 제거: 현재 페어에 없는 기존 선
    for line_data in _bond_lines.duplicate():
        var key: String = _make_pair_key(line_data["unit1_id"], line_data["unit2_id"])
        if not current_pairs.has(key):
            _remove_bond_line(line_data)

    # 추가/업데이트: 새로운 페어 또는 변경된 페어
    for pair_data in valid_pairs:
        var key: String = _make_pair_key(pair_data["unit1_id"], pair_data["unit2_id"])
        if not existing_by_pair.has(key):
            _add_bond_line(pair_data)
        else:
            # Existing line - update points if units moved
            _update_bond_line_points(existing_by_pair[key], pair_data)

func _get_bonded_pairs() -> Array:
    var pairs: Array = []
    var checked: Dictionary = {}

    for unit in _ally_units:
        if not is_instance_valid(unit) or unit.unit_data == null:
            continue
        var unit_id: StringName = unit.unit_data.unit_id
        var unit_bond: int = _bond_service.get_bond(unit_id) if _bond_service != null else 0
        if unit_bond < MIN_BOND_FOR_CONNECTION:
            continue

        for other in _ally_units:
            if not is_instance_valid(other) or other == unit or other.unit_data == null:
                continue
            var other_id: StringName = other.unit_data.unit_id
            var pair_key: String = _make_pair_key(unit_id, other_id)
            if checked.has(pair_key):
                continue
            checked[pair_key] = true

            var other_bond: int = _bond_service.get_bond(other_id) if _bond_service != null else 0
            if other_bond < MIN_BOND_FOR_CONNECTION:
                continue

            # Check adjacency
            var dist: int = abs(unit.grid_position.x - other.grid_position.x) + abs(unit.grid_position.y - other.grid_position.y)
            if dist <= 1:
                # Use the lower bond level for coloring
                var bond_for_line: int = mini(unit_bond, other_bond)
                pairs.append({
                    "unit1": unit,
                    "unit2": other,
                    "unit1_id": unit_id,
                    "unit2_id": other_id,
                    "bond_level": bond_for_line
                })

    return pairs

func _make_pair_key(id1: StringName, id2: StringName) -> String:
    var a: StringName = id1 if id1 < id2 else id2
    var b: StringName = id2 if id1 < id2 else id1
    return String(a) + "_" + String(b)

func _add_bond_line(pair_data: Dictionary) -> void:
    var line: Line2D = Line2D.new()
    line.width = _get_width_for_bond(pair_data["bond_level"])
    line.default_color = _get_color_for_bond(pair_data["bond_level"])
    line.joint_mode = Line2D.LINE_JOINT_ROUND
    line.begin_cap_mode = Line2D.LINE_CAP_ROUND
    line.end_cap_mode = Line2D.LINE_CAP_ROUND

    # Add glow effect for bond 5
    if pair_data["bond_level"] >= 5:
        line.shadow_color = Color(1.0, 1.0, 1.0, 0.5)
        line.shadow_size = 4

    add_child(line)

    var line_data: Dictionary = {
        "line": line,
        "unit1_id": pair_data["unit1_id"],
        "unit2_id": pair_data["unit2_id"],
        "bond_level": pair_data["bond_level"]
    }
    _bond_lines.append(line_data)
    _update_bond_line_points(line_data, pair_data)

func _update_bond_line_points(line_data: Dictionary, pair_data: Dictionary) -> void:
    var line: Line2D = line_data["line"]
    var unit1: UnitActor = pair_data["unit1"]
    var unit2: UnitActor = pair_data["unit2"]

    if not is_instance_valid(unit1) or not is_instance_valid(unit2):
        return

    var pos1: Vector2 = _grid_to_world(unit1.grid_position)
    var pos2: Vector2 = _grid_to_world(unit2.grid_position)

    line.clear_points()
    line.add_point(pos1)
    line.add_point(pos2)

func _remove_bond_line(line_data: Dictionary) -> void:
    var line: Line2D = line_data["line"]
    if is_instance_valid(line):
        line.queue_free()
    _bond_lines.erase(line_data)

func _get_color_for_bond(bond_level: int) -> Color:
    match bond_level:
        5:
            return COLOR_BOND5
        4:
            return COLOR_BOND4
        _:
            return COLOR_BOND3

func _get_width_for_bond(bond_level: float) -> float:
    match int(bond_level):
        5:
            return WIDTH_BOND5
        4:
            return WIDTH_BOND4
        _:
            return WIDTH_BOND3

func _grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        grid_pos.x * cell_size.x + cell_size.x * 0.5,
        grid_pos.y * cell_size.y + cell_size.y * 0.5
    )

# --- Support Attack FX ---

func _draw_support_fx(supporter: UnitActor, attacker: UnitActor, bond_level: int) -> void:
    if not is_instance_valid(supporter) or not is_instance_valid(attacker):
        return

    var from_pos: Vector2 = _grid_to_world(supporter.grid_position)
    var to_pos: Vector2 = _grid_to_world(attacker.grid_position)

    # Create a flash line from supporter to attacker
    var line: Line2D = Line2D.new()
    line.width = 3.0
    line.default_color = COLOR_SUPPORT
    line.joint_mode = Line2D.LINE_JOINT_ROUND
    line.begin_cap_mode = Line2D.LINE_CAP_ROUND
    line.end_cap_mode = Line2D.LINE_CAP_ROUND
    line.shadow_color = Color(0.5, 0.9, 1.0, 0.8)
    line.shadow_size = 6

    line.clear_points()
    line.add_point(from_pos)
    line.add_point(to_pos)

    add_child(line)

    var fx_data: Dictionary = {
        "node": line,
        "duration": 0.3,
        "elapsed": 0.0,
        "type": "support"
    }
    _fx_nodes.append(fx_data)

# --- Damage Share FX ---

func _draw_share_fx(target: UnitActor, sharers: Array) -> void:
    if not is_instance_valid(target):
        return

    var target_pos: Vector2 = _grid_to_world(target.grid_position)

    for sharer_data in sharers:
        var sharer: UnitActor = sharer_data.get("unit")
        if not is_instance_valid(sharer):
            continue

        var sharer_pos: Vector2 = _grid_to_world(sharer.grid_position)

        # Create pink line from target to sharer
        var line: Line2D = Line2D.new()
        line.width = 2.5
        line.default_color = COLOR_SHARE
        line.joint_mode = Line2D.LINE_JOINT_ROUND
        line.begin_cap_mode = Line2D.LINE_CAP_ROUND
        line.end_cap_mode = Line2D.LINE_CAP_ROUND
        line.shadow_color = Color(1.0, 0.5, 0.7, 0.7)
        line.shadow_size = 5

        line.clear_points()
        line.add_point(target_pos)
        line.add_point(sharer_pos)

        add_child(line)

        var fx_data: Dictionary = {
            "node": line,
            "duration": 0.5,
            "elapsed": 0.0,
            "type": "share"
        }
        _fx_nodes.append(fx_data)

# --- Bond Bonus Popup ---

func _show_bond_bonus_popup(unit: UnitActor, bonus: int) -> void:
    if not is_instance_valid(unit) or bonus <= 0:
        return

    # Create a simple floating +N label
    var label: Label = Label.new()
    label.text = "+%d" % bonus
    label.add_theme_font_size_override("font_size", 16)
    label.add_theme_color_override("font_color", COLOR_BONUS)
    label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
    label.add_theme_constant_override("outline_size", 2)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    var world_pos: Vector2 = _grid_to_world(unit.grid_position)
    label.position = world_pos + Vector2(-15, -30)

    add_child(label)

    # Animate: float up and fade out
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", world_pos.y - 60, 0.8)
    tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
    tween.tween_callback(label.queue_free)

# --- FX Cleanup ---

func draw_support_fx(supporter: UnitActor, attacker: UnitActor, bond_level: int) -> void:
    _draw_support_fx(supporter, attacker, bond_level)

func draw_share_fx(target: UnitActor, sharers: Array) -> void:
    _draw_share_fx(target, sharers)

func show_bond_bonus_popup(unit: UnitActor, bonus: int) -> void:
    _show_bond_bonus_popup(unit, bonus)

func _cleanup_finished_fx(delta: float) -> void:
    for fx_data in _fx_nodes.duplicate():
        fx_data["elapsed"] += delta
        if fx_data["elapsed"] >= fx_data["duration"]:
            var node: Node = fx_data["node"]
            if is_instance_valid(node):
                node.queue_free()
            _fx_nodes.erase(fx_data)

func clear_all_fx() -> void:
    for fx_data in _fx_nodes:
        var node: Node = fx_data["node"]
        if is_instance_valid(node):
            node.queue_free()
    _fx_nodes.clear()

    for line_data in _bond_lines:
        var line: Line2D = line_data["line"]
        if is_instance_valid(line):
            line.queue_free()
    _bond_lines.clear()
