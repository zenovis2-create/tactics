class_name GridCursor
extends Node2D

@export var cell_size: Vector2i = Vector2i(64, 64)
@export var selected_color: Color = Color(0.992, 0.862, 0.364, 0.26)
@export var reachable_color: Color = Color(0.314, 0.745, 1.0, 0.18)
@export var selected_inset: float = 2.0
@export var reachable_inset: float = 7.0
@export var selected_border_color: Color = Color(1.0, 0.921569, 0.572549, 0.92)
@export var reachable_border_color: Color = Color(0.529412, 0.854902, 1.0, 0.82)
@export var selected_border_thickness: float = 3.0
@export var reachable_border_thickness: float = 2.0
@export var interactable_color: Color = Color(0.996, 0.824, 0.38, 0.16)
@export var interactable_inset: float = 10.0
@export var interactable_border_color: Color = Color(1.0, 0.901961, 0.596078, 0.88)
@export var interactable_border_thickness: float = 2.0

var _reachable_rects: Array[ColorRect] = []
var _interactable_rects: Array[ColorRect] = []
var _interactable_guides: Array = []
var _selected_cell: Vector2i = Vector2i.ZERO

@onready var highlight: ColorRect = $Highlight

func _ready() -> void:
    _configure_rect(highlight, Vector2i.ZERO, selected_color, selected_inset)
    _apply_border_style(highlight, selected_border_color, selected_border_thickness)

func set_cell(cell: Vector2i) -> void:
    _selected_cell = cell
    _configure_rect(highlight, cell, selected_color, selected_inset)
    _apply_border_style(highlight, selected_border_color, selected_border_thickness)
    _refresh_interactable_guides()

func set_reachable_cells(cells: Array) -> void:
    clear_reachable_cells()

    for cell in cells:
        var rect := ColorRect.new()
        rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(rect)
        move_child(rect, 0)
        _configure_rect(rect, cell, reachable_color, reachable_inset)
        _apply_border_style(rect, reachable_border_color, reachable_border_thickness)
        _reachable_rects.append(rect)

func set_interactable_cells(cells: Array) -> void:
    clear_interactable_cells()

    for cell in cells:
        var rect := ColorRect.new()
        rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(rect)
        move_child(rect, 0)
        _configure_rect(rect, cell, interactable_color, interactable_inset)
        _apply_border_style(rect, interactable_border_color, interactable_border_thickness)
        _apply_corner_notches(rect, interactable_border_color, interactable_border_thickness)
        _interactable_rects.append(rect)

    _refresh_interactable_guides()

func clear_reachable_cells() -> void:
    for rect in _reachable_rects:
        if is_instance_valid(rect):
            rect.queue_free()
    _reachable_rects.clear()

func clear_interactable_cells() -> void:
    for rect in _interactable_rects:
        if is_instance_valid(rect):
            rect.queue_free()
    _interactable_rects.clear()

    for guide in _interactable_guides:
        if is_instance_valid(guide):
            guide.queue_free()
    _interactable_guides.clear()

func _configure_rect(rect: ColorRect, cell: Vector2i, color: Color, inset: float = 0.0) -> void:
    rect.position = Vector2(cell.x * cell_size.x + inset, cell.y * cell_size.y + inset)
    rect.size = Vector2(cell_size.x - inset * 2.0, cell_size.y - inset * 2.0)
    rect.color = color
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _apply_border_style(rect: ColorRect, border_color: Color, thickness: float) -> void:
    var border_names := ["BorderTop", "BorderBottom", "BorderLeft", "BorderRight"]
    for border_name in border_names:
        if rect.get_node_or_null(border_name) == null:
            var border := ColorRect.new()
            border.name = border_name
            border.mouse_filter = Control.MOUSE_FILTER_IGNORE
            rect.add_child(border)

    var border_top: ColorRect = rect.get_node("BorderTop")
    var border_bottom: ColorRect = rect.get_node("BorderBottom")
    var border_left: ColorRect = rect.get_node("BorderLeft")
    var border_right: ColorRect = rect.get_node("BorderRight")

    border_top.position = Vector2.ZERO
    border_top.size = Vector2(rect.size.x, thickness)
    border_bottom.position = Vector2(0.0, rect.size.y - thickness)
    border_bottom.size = Vector2(rect.size.x, thickness)
    border_left.position = Vector2.ZERO
    border_left.size = Vector2(thickness, rect.size.y)
    border_right.position = Vector2(rect.size.x - thickness, 0.0)
    border_right.size = Vector2(thickness, rect.size.y)

    for border in [border_top, border_bottom, border_left, border_right]:
        border.color = border_color

func _apply_corner_notches(rect: ColorRect, border_color: Color, thickness: float) -> void:
    var notch_names := ["NotchTLH", "NotchTLV", "NotchTRH", "NotchTRV", "NotchBLH", "NotchBLV", "NotchBRH", "NotchBRV"]
    for notch_name in notch_names:
        if rect.get_node_or_null(notch_name) == null:
            var notch := ColorRect.new()
            notch.name = notch_name
            notch.mouse_filter = Control.MOUSE_FILTER_IGNORE
            rect.add_child(notch)

    var arm: float = 9.0
    var tl_h: ColorRect = rect.get_node("NotchTLH")
    var tl_v: ColorRect = rect.get_node("NotchTLV")
    var tr_h: ColorRect = rect.get_node("NotchTRH")
    var tr_v: ColorRect = rect.get_node("NotchTRV")
    var bl_h: ColorRect = rect.get_node("NotchBLH")
    var bl_v: ColorRect = rect.get_node("NotchBLV")
    var br_h: ColorRect = rect.get_node("NotchBRH")
    var br_v: ColorRect = rect.get_node("NotchBRV")

    tl_h.position = Vector2.ZERO
    tl_h.size = Vector2(arm, thickness)
    tl_v.position = Vector2.ZERO
    tl_v.size = Vector2(thickness, arm)

    tr_h.position = Vector2(rect.size.x - arm, 0.0)
    tr_h.size = Vector2(arm, thickness)
    tr_v.position = Vector2(rect.size.x - thickness, 0.0)
    tr_v.size = Vector2(thickness, arm)

    bl_h.position = Vector2(0.0, rect.size.y - thickness)
    bl_h.size = Vector2(arm, thickness)
    bl_v.position = Vector2(0.0, rect.size.y - arm)
    bl_v.size = Vector2(thickness, arm)

    br_h.position = Vector2(rect.size.x - arm, rect.size.y - thickness)
    br_h.size = Vector2(arm, thickness)
    br_v.position = Vector2(rect.size.x - thickness, rect.size.y - arm)
    br_v.size = Vector2(thickness, arm)

    for notch in [tl_h, tl_v, tr_h, tr_v, bl_h, bl_v, br_h, br_v]:
        notch.color = border_color

func _refresh_interactable_guides() -> void:
    for guide in _interactable_guides:
        if is_instance_valid(guide):
            guide.queue_free()
    _interactable_guides.clear()

    if _interactable_rects.is_empty():
        return

    var origin := Vector2(
        _selected_cell.x * cell_size.x + cell_size.x * 0.5,
        _selected_cell.y * cell_size.y + cell_size.y * 0.5
    )

    for rect in _interactable_rects:
        if not is_instance_valid(rect):
            continue

        var target := rect.position + rect.size * 0.5
        var direction := (target - origin).normalized()
        var start := origin + direction * 18.0
        var end := target - direction * 18.0

        var guide := Line2D.new()
        guide.width = 4.0
        guide.default_color = Color(1.0, 0.905882, 0.611765, 0.72)
        guide.begin_cap_mode = Line2D.LINE_CAP_ROUND
        guide.end_cap_mode = Line2D.LINE_CAP_ROUND
        guide.joint_mode = Line2D.LINE_JOINT_ROUND
        guide.points = PackedVector2Array([start, end])
        guide.z_index = 18
        add_child(guide)
        _interactable_guides.append(guide)

        var glow := Line2D.new()
        glow.width = 8.0
        glow.default_color = Color(1.0, 0.952941, 0.780392, 0.12)
        glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
        glow.end_cap_mode = Line2D.LINE_CAP_ROUND
        glow.joint_mode = Line2D.LINE_JOINT_ROUND
        glow.points = PackedVector2Array([start, end])
        glow.z_index = 17
        add_child(glow)
        _interactable_guides.append(glow)

        var arrow := Polygon2D.new()
        var normal := Vector2(-direction.y, direction.x)
        arrow.polygon = PackedVector2Array([
            end + direction * 10.0,
            end - direction * 6.0 + normal * 7.0,
            end - direction * 6.0 - normal * 7.0
        ])
        arrow.color = Color(1.0, 0.921569, 0.666667, 0.86)
        arrow.z_index = 19
        add_child(arrow)
        _interactable_guides.append(arrow)
