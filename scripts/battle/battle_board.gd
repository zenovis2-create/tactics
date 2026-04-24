class_name BattleBoard
extends Node2D

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const TILE_ICON_DIR := "assets/ui/tile_icons_generated/"
const TILE_CARD_DIR := "assets/ui/tile_cards_generated/"
const TILE_CARD_INSET := 2.0
const TILE_ICON_SIZE := 18.0
const TERRAIN_OVERLAY_CONTRACTS := {
    &"plain": {"family": "plain", "card": "plain.png", "card_alpha": 0.16, "icon": ""},
    &"forest": {"family": "forest", "card": "forest.png", "card_alpha": 0.28, "icon": "forest.png"},
    &"wall": {"family": "wall", "card": "wall.png", "card_alpha": 0.22, "icon": "wall.png"},
    &"battery": {"family": "battery", "card": "battery.png", "card_alpha": 0.2, "icon": "battery.png"},
    &"cathedral": {"family": "cathedral", "card": "bell.png", "card_alpha": 0.18, "icon": "cathedral.png"},
    &"bell": {"family": "bell", "card": "bell.png", "card_alpha": 0.18, "icon": "bell.png"},
    &"bridge": {"family": "bridge", "card": "bridge.png", "card_alpha": 0.2, "icon": "bridge.png"},
    &"corridor": {"family": "bell", "card": "bell.png", "card_alpha": 0.16, "icon": "bell.png"},
    &"highground": {"family": "highground", "card": "highground.png", "card_alpha": 0.24, "icon": "highground.png"},
    &"keep": {"family": "wall", "card": "wall.png", "card_alpha": 0.2, "icon": "wall.png"}
}

var stage_data: StageData
var _tile_icon_cache: Dictionary = {}
var _tile_card_cache: Dictionary = {}
var _bond_links: Array[Dictionary] = []

func set_stage(data: StageData) -> void:
    stage_data = data
    queue_redraw()

func set_bond_links(links: Array[Dictionary]) -> void:
    _bond_links = []
    for entry in links:
        if entry is Dictionary:
            _bond_links.append((entry as Dictionary).duplicate(true))
    queue_redraw()

func get_debug_snapshot() -> Dictionary:
    return {
        "bond_links": _bond_links.duplicate(true)
    }

func get_surface_contract_snapshot() -> Dictionary:
    return {
        "surface_family": _get_stage_surface_family(),
        "backdrop_family": _get_backdrop_family(),
        "backdrop_density": _get_backdrop_density(),
        "tile_card_inset": TILE_CARD_INSET,
        "tile_icon_size": TILE_ICON_SIZE,
        "card_alphas": {
            "plain": float(TERRAIN_OVERLAY_CONTRACTS[&"plain"].get("card_alpha", 0.0)),
            "forest": float(TERRAIN_OVERLAY_CONTRACTS[&"forest"].get("card_alpha", 0.0)),
            "wall": float(TERRAIN_OVERLAY_CONTRACTS[&"wall"].get("card_alpha", 0.0)),
        }
    }

func _draw() -> void:
    if stage_data == null:
        return

    var backdrop_rect := Rect2(-global_position, get_viewport_rect().size)
    var cell_size := Vector2(stage_data.cell_size)
    var board_size := Vector2(stage_data.grid_size.x * stage_data.cell_size.x, stage_data.grid_size.y * stage_data.cell_size.y)
    var board_rect := Rect2(Vector2.ZERO, board_size)
    var palette := _get_palette()

    draw_rect(backdrop_rect, palette.backdrop_base, true)
    draw_rect(Rect2(backdrop_rect.position, Vector2(backdrop_rect.size.x, backdrop_rect.size.y * 0.42)), palette.backdrop_top, true)
    draw_rect(Rect2(Vector2(backdrop_rect.position.x, backdrop_rect.position.y + backdrop_rect.size.y * 0.6), Vector2(backdrop_rect.size.x, backdrop_rect.size.y * 0.4)), palette.backdrop_bottom, true)
    draw_circle(Vector2(-120.0, board_size.y * 0.8), 240.0, palette.backdrop_glow_left)
    draw_circle(Vector2(board_size.x + 140.0, -40.0), 220.0, palette.backdrop_glow_right)
    _draw_backdrop_family_overlay(backdrop_rect, board_rect, palette)
    _draw_stage_backdrop_signature(backdrop_rect, board_rect, palette)

    draw_rect(board_rect.grow(30.0), palette.frame_outer, true)
    draw_rect(board_rect.grow(18.0), palette.frame_inner, true)
    draw_rect(board_rect.grow(8.0), palette.board_shadow, true)
    var enemy_zone_rect := Rect2(Vector2(0, 0), Vector2(board_size.x, board_size.y * 0.32))
    var ally_zone_rect := Rect2(Vector2(0, board_size.y * 0.55), Vector2(board_size.x, board_size.y * 0.45))
    draw_rect(ally_zone_rect, palette.ally_zone, true)
    draw_rect(enemy_zone_rect, palette.enemy_zone, true)
    _draw_zone_pattern(enemy_zone_rect, palette.enemy_zone_line)
    _draw_zone_pattern(ally_zone_rect, palette.ally_zone_line)
    draw_circle(board_rect.get_center() + Vector2(-40.0, 24.0), board_size.x * 0.24, palette.board_glow_center)
    draw_circle(board_rect.get_center() + Vector2(board_size.x * 0.18, -board_size.y * 0.22), board_size.x * 0.14, palette.board_glow_edge)
    _draw_corner_ornaments(board_rect, palette.frame_highlight)
    _draw_stage_signature(board_rect, palette)
    _draw_surface_family_overlay(board_rect, palette)
    _draw_ambient_scene_accents(board_rect)

    for y in range(stage_data.grid_size.y):
        for x in range(stage_data.grid_size.x):
            var cell := Vector2i(x, y)
            var rect := Rect2(Vector2(x * stage_data.cell_size.x, y * stage_data.cell_size.y), cell_size)
            draw_rect(rect, _get_tile_color(cell, x + y), true)
            _draw_tile_detail(cell, rect)
            _draw_terrain_advantage_marker(cell, rect)

            if stage_data.ally_spawns.has(cell):
                draw_rect(rect.grow(-6.0), Color(0.239, 0.608, 0.976, 0.16), true)
                draw_arc(rect.get_center(), 18.0, 0.0, TAU, 18, palette.ally_zone_line, 2.0)
                draw_circle(rect.get_center(), 6.0, Color(0.529, 0.804, 1.0, 0.28))
                _draw_spawn_chevrons(rect, Color(0.713725, 0.901961, 1.0, 0.72), false)
            if stage_data.enemy_spawns.has(cell):
                draw_rect(rect.grow(-6.0), Color(0.925, 0.365, 0.341, 0.18), true)
                _draw_enemy_corner_brackets(rect, palette.enemy_zone_line)
                draw_circle(rect.get_center(), 6.0, Color(0.984, 0.522, 0.459, 0.22))
                _draw_spawn_chevrons(rect, Color(1.0, 0.729412, 0.666667, 0.68), true)
            if _has_interactive_object_at(cell):
                draw_rect(rect.grow(-8.0), Color(0.992, 0.765, 0.286, 0.18), true)
                draw_arc(rect.get_center(), 14.0, 0.0, TAU, 18, Color(0.992, 0.824, 0.424, 0.5), 2.0)
                _draw_objective_marker(rect)

    for x in range(stage_data.grid_size.x + 1):
        var x_pos := float(x * stage_data.cell_size.x)
        draw_line(Vector2(x_pos, 0.0), Vector2(x_pos, board_size.y), Color(1, 1, 1, 0.08), 1.0)
    for y in range(stage_data.grid_size.y + 1):
        var y_pos := float(y * stage_data.cell_size.y)
        draw_line(Vector2(0.0, y_pos), Vector2(board_size.x, y_pos), Color(1, 1, 1, 0.08), 1.0)

    _draw_bond_links()
    draw_rect(board_rect, palette.frame_highlight, false, 3.0)

func _draw_bond_links() -> void:
    if stage_data == null or _bond_links.is_empty():
        return

    for entry in _bond_links:
        var from_cell: Vector2i = entry.get("from_cell", Vector2i.ZERO)
        var to_cell: Vector2i = entry.get("to_cell", Vector2i.ZERO)
        var bond_level: int = int(entry.get("bond_level", 0))
        var kind: String = String(entry.get("kind", "support"))
        var from_center := _get_cell_center(from_cell)
        var to_center := _get_cell_center(to_cell)
        var line_color := Color(0.576, 0.835, 1.0, 0.78)
        var glow_color := Color(0.353, 0.675, 1.0, 0.18)
        var width := 4.0

        if kind == "guard":
            line_color = Color(1.0, 0.835, 0.545, 0.86)
            glow_color = Color(1.0, 0.667, 0.486, 0.22)
            width = 5.0
        elif bond_level >= 4:
            line_color = Color(0.702, 0.906, 1.0, 0.84)
            glow_color = Color(0.459, 0.78, 1.0, 0.2)

        draw_line(from_center, to_center, glow_color, width + 6.0)
        draw_line(from_center, to_center, line_color, width)
        draw_circle(to_center, 11.0 if kind == "guard" else 9.0, glow_color)
        draw_circle(to_center, 5.0 if kind == "guard" else 4.0, line_color)
        draw_circle(from_center, 6.0, Color(line_color.r, line_color.g, line_color.b, 0.5))

func _get_cell_center(cell: Vector2i) -> Vector2:
    return Vector2(
        (float(cell.x) + 0.5) * stage_data.cell_size.x,
        (float(cell.y) + 0.5) * stage_data.cell_size.y
    )

func _get_tile_color(cell: Vector2i, parity: int) -> Color:
    var palette := _get_palette()
    var terrain_type: StringName = stage_data.get_terrain_type(cell)
    match terrain_type:
        &"forest":
            return palette.forest_a if parity % 2 == 0 else palette.forest_b
        &"wall":
            return palette.wall_a if parity % 2 == 0 else palette.wall_b
        &"tunnel":
            return Color(0.305882, 0.286275, 0.247059, 1.0) if parity % 2 == 0 else Color(0.270588, 0.25098, 0.215686, 1.0)
        &"gate_control":
            return Color(0.329412, 0.309804, 0.211765, 1.0) if parity % 2 == 0 else Color(0.294118, 0.270588, 0.180392, 1.0)
        &"floodgate":
            return Color(0.203922, 0.286275, 0.333333, 1.0) if parity % 2 == 0 else Color(0.176471, 0.247059, 0.298039, 1.0)
        &"battery":
            return Color(0.309804, 0.266667, 0.203922, 1.0) if parity % 2 == 0 else Color(0.27451, 0.231373, 0.172549, 1.0)
        &"cathedral":
            return Color(0.282353, 0.25098, 0.313726, 1.0) if parity % 2 == 0 else Color(0.25098, 0.219608, 0.282353, 1.0)
        &"bell":
            return Color(0.227451, 0.262745, 0.356863, 1.0) if parity % 2 == 0 else Color(0.2, 0.231373, 0.321569, 1.0)
        &"hymn":
            return Color(0.27451, 0.239216, 0.317647, 1.0) if parity % 2 == 0 else Color(0.243137, 0.207843, 0.286275, 1.0)
        &"shrine":
            return Color(0.239216, 0.313726, 0.231373, 1.0) if parity % 2 == 0 else Color(0.211765, 0.278431, 0.203922, 1.0)
        &"market":
            return Color(0.32549, 0.270588, 0.227451, 1.0) if parity % 2 == 0 else Color(0.290196, 0.239216, 0.2, 1.0)
        &"marked":
            return Color(0.333333, 0.180392, 0.219608, 1.0) if parity % 2 == 0 else Color(0.290196, 0.152941, 0.188235, 1.0)
        &"thicket":
            return Color(0.180392, 0.25098, 0.172549, 1.0) if parity % 2 == 0 else Color(0.152941, 0.215686, 0.145098, 1.0)
        &"archives":
            return Color(0.286275, 0.247059, 0.192157, 1.0) if parity % 2 == 0 else Color(0.254902, 0.219608, 0.168627, 1.0)
        &"keeper":
            return Color(0.215686, 0.254902, 0.290196, 1.0) if parity % 2 == 0 else Color(0.184314, 0.223529, 0.258824, 1.0)
        &"bridge":
            return Color(0.345098, 0.298039, 0.219608, 1.0) if parity % 2 == 0 else Color(0.313726, 0.270588, 0.2, 1.0)
        &"keep":
            return Color(0.286275, 0.286275, 0.333333, 1.0) if parity % 2 == 0 else Color(0.25098, 0.25098, 0.298039, 1.0)
        &"corridor":
            return Color(0.215686, 0.235294, 0.305882, 1.0) if parity % 2 == 0 else Color(0.188235, 0.207843, 0.27451, 1.0)
        &"highground":
            return Color(0.364706, 0.333333, 0.227451, 1.0) if parity % 2 == 0 else Color(0.32549, 0.294118, 0.203922, 1.0)
        _:
            return palette.plain_a if parity % 2 == 0 else palette.plain_b

func _has_interactive_object_at(cell: Vector2i) -> bool:
    for object_data in stage_data.interactive_objects:
        if object_data != null and object_data.grid_position == cell:
            return true
    return false

func _draw_zone_pattern(zone_rect: Rect2, color: Color) -> void:
    var spacing: float = 56.0
    var offset: float = -zone_rect.size.y
    while offset < zone_rect.size.x:
        var start := Vector2(zone_rect.position.x + offset, zone_rect.position.y)
        var end := Vector2(zone_rect.position.x + offset + zone_rect.size.y, zone_rect.position.y + zone_rect.size.y)
        draw_line(start, end, color, 2.0)
        offset += spacing

func _draw_ambient_scene_accents(board_rect: Rect2) -> void:
    var stage_key: String = String(stage_data.stage_id)

    if stage_key == "tutorial_stage":
        for center in [
            board_rect.position + Vector2(board_rect.size.x * 0.2, board_rect.size.y * 0.76),
            board_rect.position + Vector2(board_rect.size.x * 0.32, board_rect.size.y * 0.68),
            board_rect.position + Vector2(board_rect.size.x * 0.82, board_rect.size.y * 0.28)
        ]:
            draw_circle(center, 10.0, Color(0.980392, 0.764706, 0.396078, 0.06))
            draw_circle(center + Vector2(8.0, -6.0), 4.0, Color(1.0, 0.847059, 0.615686, 0.08))
        return

    if stage_key.begins_with("CH03"):
        for center in [
            board_rect.position + Vector2(board_rect.size.x * 0.18, board_rect.size.y * 0.2),
            board_rect.position + Vector2(board_rect.size.x * 0.62, board_rect.size.y * 0.34),
            board_rect.position + Vector2(board_rect.size.x * 0.78, board_rect.size.y * 0.72)
        ]:
            draw_circle(center, 6.0, Color(0.713726, 0.956863, 0.776471, 0.06))
            draw_circle(center + Vector2(16.0, 10.0), 3.0, Color(0.858824, 1.0, 0.839216, 0.08))
            draw_line(center + Vector2(-10.0, 8.0), center + Vector2(10.0, -8.0), Color(0.792157, 1.0, 0.839216, 0.06), 1.0)
        return

    if stage_key.begins_with("CH07"):
        for center in [
            board_rect.position + Vector2(board_rect.size.x * 0.16, board_rect.size.y * 0.26),
            board_rect.position + Vector2(board_rect.size.x * 0.46, board_rect.size.y * 0.52),
            board_rect.position + Vector2(board_rect.size.x * 0.82, board_rect.size.y * 0.24)
        ]:
            draw_circle(center, 7.0, Color(0.956863, 0.815686, 1.0, 0.06))
            draw_arc(center, 14.0, PI * 1.1, PI * 1.9, 16, Color(0.901961, 0.713726, 0.984314, 0.08), 1.0)
        return

    if stage_key.begins_with("CH10"):
        for center in [
            board_rect.position + Vector2(board_rect.size.x * 0.2, board_rect.size.y * 0.2),
            board_rect.position + Vector2(board_rect.size.x * 0.56, board_rect.size.y * 0.46),
            board_rect.position + Vector2(board_rect.size.x * 0.84, board_rect.size.y * 0.72)
        ]:
            draw_circle(center, 6.0, Color(0.835294, 0.921569, 1.0, 0.06))
            draw_line(center + Vector2(-10.0, 0.0), center + Vector2(10.0, 0.0), Color(1.0, 0.827451, 0.945098, 0.06), 1.0)
            draw_line(center + Vector2(0.0, -10.0), center + Vector2(0.0, 10.0), Color(0.827451, 0.921569, 1.0, 0.06), 1.0)
        return

func _draw_stage_backdrop_signature(backdrop_rect: Rect2, board_rect: Rect2, palette: Dictionary) -> void:
    var stage_key: String = String(stage_data.stage_id)

    if stage_key.begins_with("CH03"):
        for x_pos in [backdrop_rect.position.x + 72.0, backdrop_rect.position.x + 124.0, backdrop_rect.end.x - 132.0]:
            draw_rect(Rect2(Vector2(x_pos, backdrop_rect.position.y + backdrop_rect.size.y * 0.18), Vector2(22.0, backdrop_rect.size.y * 0.76)), Color(0.024, 0.071, 0.047, 0.7), true)
            draw_circle(Vector2(x_pos + 10.0, backdrop_rect.position.y + backdrop_rect.size.y * 0.26), 88.0, Color(0.094, 0.271, 0.18, 0.28))
            draw_circle(Vector2(x_pos + 32.0, backdrop_rect.position.y + backdrop_rect.size.y * 0.24), 64.0, Color(0.129, 0.349, 0.231, 0.18))
        return

    if stage_key.begins_with("CH07"):
        var base_y: float = backdrop_rect.position.y + backdrop_rect.size.y * 0.72
        for x_pos in [backdrop_rect.position.x + 110.0, backdrop_rect.position.x + 194.0, backdrop_rect.end.x - 210.0]:
            draw_rect(Rect2(Vector2(x_pos, base_y - 132.0), Vector2(18.0, 132.0)), Color(0.161, 0.102, 0.22, 0.56), true)
            draw_arc(Vector2(x_pos + 9.0, base_y - 132.0), 42.0, PI, TAU, 28, Color(0.525, 0.341, 0.627, 0.24), 4.0)
            draw_arc(Vector2(x_pos + 9.0, base_y - 132.0), 24.0, PI, TAU, 20, Color(0.851, 0.722, 0.965, 0.12), 2.0)
        draw_arc(Vector2(backdrop_rect.position.x + backdrop_rect.size.x * 0.5, backdrop_rect.position.y + backdrop_rect.size.y * 0.22), 180.0, PI * 0.1, PI * 0.9, 44, Color(0.776471, 0.6, 0.901961, 0.12), 4.0)
        draw_arc(Vector2(backdrop_rect.position.x + backdrop_rect.size.x * 0.5, backdrop_rect.position.y + backdrop_rect.size.y * 0.22), 230.0, PI * 0.16, PI * 0.84, 44, Color(0.960784, 0.835294, 0.988235, 0.08), 3.0)
        return

    if stage_key.begins_with("CH10"):
        var center := Vector2(backdrop_rect.end.x - 186.0, backdrop_rect.position.y + 138.0)
        draw_arc(center, 112.0, 0.0, TAU, 40, Color(0.667, 0.816, 1.0, 0.16), 4.0)
        draw_arc(center, 154.0, PI * 0.08, PI * 1.92, 40, Color(1.0, 0.725, 0.894, 0.14), 3.0)
        draw_arc(Vector2(backdrop_rect.position.x + backdrop_rect.size.x * 0.28, backdrop_rect.position.y + backdrop_rect.size.y * 0.24), 132.0, PI * 0.82, PI * 1.78, 34, Color(0.827451, 0.901961, 1.0, 0.08), 3.0)
        draw_arc(Vector2(backdrop_rect.position.x + backdrop_rect.size.x * 0.28, backdrop_rect.position.y + backdrop_rect.size.y * 0.24), 176.0, PI * 0.86, PI * 1.74, 34, Color(1.0, 0.8, 0.941176, 0.06), 2.0)
        for offset_x in [-34.0, 0.0, 38.0]:
            draw_rect(Rect2(Vector2(center.x + offset_x, backdrop_rect.position.y + 54.0), Vector2(16.0, backdrop_rect.size.y * 0.62)), Color(0.118, 0.102, 0.224, 0.56), true)
        draw_circle(center, 26.0, Color(0.824, 0.918, 1.0, 0.08))
        return

func _draw_backdrop_family_overlay(backdrop_rect: Rect2, board_rect: Rect2, palette: Dictionary) -> void:
    var backdrop_family := _get_backdrop_family()
    if backdrop_family == "forest":
        var horizon_y: float = backdrop_rect.position.y + backdrop_rect.size.y * 0.42
        var trunk_color := Color(0.0196078, 0.054902, 0.0392157, 0.78)
        var canopy_color := Color(0.0705882, 0.211765, 0.141176, 0.36)
        var mist_band := Color(0.803922, 0.980392, 0.866667, 0.055)
        for x_pos in [backdrop_rect.position.x + 48.0, backdrop_rect.position.x + 118.0, backdrop_rect.position.x + 188.0, backdrop_rect.end.x - 216.0, backdrop_rect.end.x - 128.0]:
            draw_rect(Rect2(Vector2(x_pos, horizon_y - 18.0), Vector2(20.0, backdrop_rect.size.y * 0.64)), trunk_color, true)
            draw_circle(Vector2(x_pos + 10.0, horizon_y - 34.0), 78.0, canopy_color)
            draw_circle(Vector2(x_pos + 40.0, horizon_y - 20.0), 62.0, Color(canopy_color.r, canopy_color.g, canopy_color.b, 0.24))
        draw_rect(Rect2(Vector2(backdrop_rect.position.x, horizon_y + 22.0), Vector2(backdrop_rect.size.x, 46.0)), Color(0.0392157, 0.109804, 0.0745098, 0.24), true)
        draw_line(Vector2(backdrop_rect.position.x + 24.0, horizon_y + 8.0), Vector2(backdrop_rect.end.x - 24.0, horizon_y + 8.0), mist_band, 10.0)
        draw_line(Vector2(backdrop_rect.position.x + 52.0, horizon_y + 34.0), Vector2(backdrop_rect.end.x - 62.0, horizon_y + 34.0), Color(0.886275, 1.0, 0.92549, 0.035), 6.0)
        return

    if backdrop_family == "fortress":
        var horizon_y: float = backdrop_rect.position.y + backdrop_rect.size.y * 0.28
        var wall_color := Color(0.0823529, 0.0901961, 0.117647, 0.72)
        var tower_color := Color(0.105882, 0.113725, 0.145098, 0.82)
        var slit_color := Color(0.756863, 0.803922, 0.890196, 0.09)
        draw_rect(Rect2(Vector2(backdrop_rect.position.x, horizon_y + 26.0), Vector2(backdrop_rect.size.x, 84.0)), wall_color, true)
        for x_pos in [backdrop_rect.position.x + 42.0, backdrop_rect.position.x + 180.0, backdrop_rect.position.x + 352.0, backdrop_rect.end.x - 392.0, backdrop_rect.end.x - 212.0, backdrop_rect.end.x - 74.0]:
            draw_rect(Rect2(Vector2(x_pos, horizon_y - 42.0), Vector2(48.0, 152.0)), tower_color, true)
            draw_rect(Rect2(Vector2(x_pos + 20.0, horizon_y - 8.0), Vector2(8.0, 20.0)), slit_color, true)
            draw_rect(Rect2(Vector2(x_pos + 20.0, horizon_y + 42.0), Vector2(8.0, 20.0)), slit_color, true)
        draw_line(Vector2(backdrop_rect.position.x, horizon_y + 24.0), Vector2(backdrop_rect.end.x, horizon_y + 24.0), Color(0.85098, 0.878431, 0.92549, 0.06), 3.0)
        draw_line(Vector2(backdrop_rect.position.x, horizon_y + 110.0), Vector2(backdrop_rect.end.x, horizon_y + 110.0), Color(0.184314, 0.219608, 0.286275, 0.18), 4.0)
        return

    if backdrop_family == "city":
        var skyline_y: float = backdrop_rect.position.y + backdrop_rect.size.y * 0.34
        var tower_color := Color(0.101961, 0.0705882, 0.141176, 0.78)
        var roof_color := Color(0.356863, 0.215686, 0.462745, 0.28)
        for x_pos in [backdrop_rect.position.x + 36.0, backdrop_rect.position.x + 128.0, backdrop_rect.position.x + 236.0, backdrop_rect.end.x - 312.0, backdrop_rect.end.x - 188.0, backdrop_rect.end.x - 84.0]:
            draw_rect(Rect2(Vector2(x_pos, skyline_y - 28.0), Vector2(34.0, 136.0)), tower_color, true)
            draw_arc(Vector2(x_pos + 17.0, skyline_y - 26.0), 22.0, PI, TAU, 20, roof_color, 3.0)
        draw_line(Vector2(backdrop_rect.position.x, skyline_y + 92.0), Vector2(backdrop_rect.end.x, skyline_y + 92.0), Color(0.917647, 0.780392, 0.968627, 0.05), 4.0)
        draw_line(Vector2(backdrop_rect.position.x + 18.0, skyline_y + 54.0), Vector2(backdrop_rect.end.x - 18.0, skyline_y + 54.0), Color(0.533333, 0.337255, 0.662745, 0.09), 2.0)
        return

    if backdrop_family == "archive":
        var shelf_y: float = backdrop_rect.position.y + backdrop_rect.size.y * 0.30
        var shelf_color := Color(0.129412, 0.0941176, 0.0784314, 0.72)
        var spine_color := Color(0.65098, 0.564706, 0.403922, 0.08)
        for row in [0.0, 86.0]:
            draw_rect(Rect2(Vector2(backdrop_rect.position.x, shelf_y + row), Vector2(backdrop_rect.size.x, 16.0)), shelf_color, true)
            for x_pos in range(0, int(backdrop_rect.size.x), 44):
                draw_rect(Rect2(Vector2(backdrop_rect.position.x + x_pos + 10.0, shelf_y + row - 58.0), Vector2(22.0, 58.0)), Color(0.180392, 0.137255, 0.109804, 0.62), true)
                draw_line(Vector2(backdrop_rect.position.x + x_pos + 14.0, shelf_y + row - 46.0), Vector2(backdrop_rect.position.x + x_pos + 28.0, shelf_y + row - 46.0), spine_color, 2.0)
        draw_line(Vector2(backdrop_rect.position.x + 32.0, shelf_y + 164.0), Vector2(backdrop_rect.end.x - 32.0, shelf_y + 164.0), Color(0.839216, 0.756863, 0.627451, 0.05), 4.0)
        return

    if backdrop_family == "final_bell":
        var center := Vector2(backdrop_rect.position.x + backdrop_rect.size.x * 0.72, backdrop_rect.position.y + backdrop_rect.size.y * 0.28)
        draw_arc(center, 120.0, 0.0, TAU, 44, Color(0.72549, 0.858824, 1.0, 0.18), 4.0)
        draw_arc(center, 168.0, PI * 0.08, PI * 1.92, 44, Color(1.0, 0.741176, 0.917647, 0.16), 3.0)
        for x_pos in [center.x - 56.0, center.x, center.x + 62.0]:
            draw_rect(Rect2(Vector2(x_pos, backdrop_rect.position.y + 42.0), Vector2(18.0, backdrop_rect.size.y * 0.7)), Color(0.101961, 0.0862745, 0.176471, 0.64), true)
        draw_line(Vector2(backdrop_rect.position.x + 24.0, backdrop_rect.position.y + backdrop_rect.size.y * 0.76), Vector2(backdrop_rect.end.x - 24.0, backdrop_rect.position.y + backdrop_rect.size.y * 0.48), Color(0.85098, 0.917647, 1.0, 0.045), 6.0)
        return

func _draw_tile_detail(cell: Vector2i, rect: Rect2) -> void:
    var terrain_type: StringName = stage_data.get_terrain_type(cell)
    var stage_key: String = String(stage_data.stage_id)
    if terrain_type == &"forest":
        _draw_contract_tile_card(rect, terrain_type)
        draw_rect(rect.grow(-11.0), Color(0.145098, 0.270588, 0.219608, 0.42), true)
        draw_circle(rect.position + Vector2(18.0, 18.0), 6.0, Color(0.486275, 0.811765, 0.658824, 0.16))
        draw_circle(rect.position + Vector2(rect.size.x - 18.0, rect.size.y - 16.0), 5.0, Color(0.486275, 0.811765, 0.658824, 0.12))
        draw_line(rect.position + Vector2(14.0, rect.size.y - 16.0), rect.position + Vector2(rect.size.x * 0.52, 16.0), Color(0.596078, 0.866667, 0.709804, 0.24), 2.0)
        draw_line(rect.position + Vector2(rect.size.x - 16.0, rect.size.y - 12.0), rect.position + Vector2(rect.size.x * 0.6, 14.0), Color(0.596078, 0.866667, 0.709804, 0.18), 2.0)
        _draw_contract_tile_icon(rect, terrain_type)
        return

    if terrain_type == &"wall" or stage_data.blocked_cells.has(cell):
        _draw_contract_tile_card(rect, &"wall")
        var inner_rect := rect.grow(-8.0)
        draw_rect(inner_rect, Color(0.176471, 0.188235, 0.215686, 0.96), true)
        draw_rect(Rect2(inner_rect.position, Vector2(inner_rect.size.x, 7.0)), Color(0.360784, 0.384314, 0.439216, 0.9), true)
        draw_line(inner_rect.position + Vector2(10.0, inner_rect.size.y * 0.48), inner_rect.position + Vector2(inner_rect.size.x - 10.0, inner_rect.size.y * 0.48), Color(0.513725, 0.537255, 0.6, 0.16), 2.0)
        draw_circle(inner_rect.position + Vector2(12.0, 12.0), 2.0, Color(0.643137, 0.670588, 0.733333, 0.22))
        draw_circle(inner_rect.position + Vector2(inner_rect.size.x - 12.0, inner_rect.size.y - 12.0), 2.0, Color(0.643137, 0.670588, 0.733333, 0.18))
        draw_rect(inner_rect, Color(0.521569, 0.545098, 0.611765, 0.22), false, 2.0)
        _draw_contract_tile_icon(rect, &"wall")
        return

    if terrain_type == &"tunnel":
        draw_line(rect.position + Vector2(12.0, rect.size.y * 0.5), rect.position + Vector2(rect.size.x - 12.0, rect.size.y * 0.5), Color(0.827451, 0.752941, 0.588235, 0.22), 3.0)
        draw_line(rect.position + Vector2(16.0, rect.size.y * 0.34), rect.position + Vector2(rect.size.x - 16.0, rect.size.y * 0.34), Color(0.54902, 0.470588, 0.341176, 0.2), 1.0)
        draw_line(rect.position + Vector2(16.0, rect.size.y * 0.66), rect.position + Vector2(rect.size.x - 16.0, rect.size.y * 0.66), Color(0.54902, 0.470588, 0.341176, 0.2), 1.0)
        return

    if terrain_type == &"gate_control":
        draw_rect(rect.grow(-12.0), Color(0.615686, 0.529412, 0.243137, 0.2), false, 2.0)
        draw_arc(rect.get_center(), 12.0, 0.0, TAU, 18, Color(0.945098, 0.858824, 0.505882, 0.28), 2.0)
        draw_line(rect.get_center() + Vector2(-8.0, 0.0), rect.get_center() + Vector2(8.0, 0.0), Color(1.0, 0.917647, 0.611765, 0.22), 2.0)
        draw_line(rect.get_center() + Vector2(0.0, -8.0), rect.get_center() + Vector2(0.0, 8.0), Color(1.0, 0.917647, 0.611765, 0.22), 2.0)
        return

    if terrain_type == &"floodgate":
        draw_line(rect.position + Vector2(12.0, 16.0), rect.position + Vector2(rect.size.x - 12.0, 16.0), Color(0.729412, 0.87451, 0.984314, 0.18), 2.0)
        draw_line(rect.position + Vector2(12.0, rect.size.y - 16.0), rect.position + Vector2(rect.size.x - 12.0, rect.size.y - 16.0), Color(0.729412, 0.87451, 0.984314, 0.18), 2.0)
        draw_arc(rect.get_center(), 12.0, PI * 0.1, PI * 0.9, 16, Color(0.564706, 0.811765, 0.952941, 0.2), 2.0)
        return

    if terrain_type == &"battery":
        _draw_contract_tile_card(rect, terrain_type)
        draw_rect(rect.grow(-11.0), Color(0.14902, 0.117647, 0.0823529, 0.36), true)
        draw_line(rect.get_center() + Vector2(-10.0, 10.0), rect.get_center() + Vector2(10.0, -10.0), Color(1.0, 0.843137, 0.541176, 0.18), 2.0)
        draw_circle(rect.get_center() + Vector2(6.0, -6.0), 4.0, Color(0.952941, 0.690196, 0.356863, 0.18))
        _draw_contract_tile_icon(rect, terrain_type)
        return

    if terrain_type == &"cathedral":
        _draw_contract_tile_card(rect, terrain_type)
        draw_arc(rect.get_center() + Vector2(0.0, 4.0), 14.0, PI, TAU, 18, Color(0.929412, 0.807843, 1.0, 0.14), 2.0)
        draw_line(rect.get_center() + Vector2(-10.0, 10.0), rect.get_center() + Vector2(-10.0, -2.0), Color(0.858824, 0.741176, 0.964706, 0.14), 1.0)
        draw_line(rect.get_center() + Vector2(10.0, 10.0), rect.get_center() + Vector2(10.0, -2.0), Color(0.858824, 0.741176, 0.964706, 0.14), 1.0)
        _draw_contract_tile_icon(rect, terrain_type)
        return

    if terrain_type == &"bell":
        _draw_contract_tile_card(rect, terrain_type)
        draw_arc(rect.get_center(), 12.0, PI, TAU, 18, Color(0.796078, 0.898039, 1.0, 0.18), 2.0)
        draw_line(rect.get_center() + Vector2(0.0, -12.0), rect.get_center() + Vector2(0.0, 6.0), Color(0.972549, 0.847059, 0.972549, 0.16), 1.0)
        _draw_contract_tile_icon(rect, terrain_type)
        return

    if terrain_type == &"hymn":
        draw_arc(rect.get_center(), 10.0, PI * 1.05, PI * 1.95, 16, Color(0.929412, 0.772549, 0.984314, 0.16), 2.0)
        draw_arc(rect.get_center(), 16.0, PI * 1.05, PI * 1.95, 16, Color(0.929412, 0.772549, 0.984314, 0.08), 1.0)
        return

    if terrain_type == &"shrine":
        draw_circle(rect.get_center(), 8.0, Color(0.792157, 0.952941, 0.760784, 0.12))
        draw_arc(rect.get_center(), 16.0, 0.0, TAU, 18, Color(0.854902, 1.0, 0.823529, 0.1), 1.0)
        return

    if terrain_type == &"market":
        draw_rect(Rect2(rect.position + Vector2(12.0, 12.0), Vector2(rect.size.x - 24.0, 10.0)), Color(0.843137, 0.670588, 0.427451, 0.14), true)
        draw_line(rect.position + Vector2(14.0, 22.0), rect.position + Vector2(rect.size.x - 14.0, 22.0), Color(0.945098, 0.807843, 0.576471, 0.12), 1.0)
        return

    if terrain_type == &"marked":
        draw_arc(rect.get_center(), 12.0, 0.0, TAU, 16, Color(1.0, 0.54902, 0.643137, 0.2), 2.0)
        draw_line(rect.get_center() + Vector2(-8.0, -8.0), rect.get_center() + Vector2(8.0, 8.0), Color(1.0, 0.631373, 0.694118, 0.18), 2.0)
        draw_line(rect.get_center() + Vector2(-8.0, 8.0), rect.get_center() + Vector2(8.0, -8.0), Color(1.0, 0.631373, 0.694118, 0.18), 2.0)
        return

    if terrain_type == &"thicket":
        draw_circle(rect.position + Vector2(18.0, 18.0), 5.0, Color(0.623529, 0.870588, 0.607843, 0.16))
        draw_circle(rect.position + Vector2(rect.size.x - 18.0, rect.size.y - 16.0), 4.0, Color(0.623529, 0.870588, 0.607843, 0.12))
        draw_line(rect.position + Vector2(14.0, rect.size.y - 14.0), rect.position + Vector2(rect.size.x * 0.46, 18.0), Color(0.698039, 0.921569, 0.686275, 0.16), 2.0)
        return

    if terrain_type == &"archives":
        draw_rect(rect.grow(-12.0), Color(0.623529, 0.529412, 0.337255, 0.14), false, 2.0)
        draw_line(rect.position + Vector2(14.0, 18.0), rect.position + Vector2(rect.size.x - 14.0, 18.0), Color(0.929412, 0.811765, 0.611765, 0.12), 1.0)
        draw_line(rect.position + Vector2(14.0, rect.size.y - 18.0), rect.position + Vector2(rect.size.x - 14.0, rect.size.y - 18.0), Color(0.929412, 0.811765, 0.611765, 0.12), 1.0)
        return

    if terrain_type == &"keeper":
        draw_arc(rect.get_center(), 10.0, PI * 0.15, PI * 1.85, 16, Color(0.772549, 0.882353, 1.0, 0.14), 2.0)
        draw_line(rect.get_center() + Vector2(-8.0, 0.0), rect.get_center() + Vector2(8.0, 0.0), Color(0.862745, 0.929412, 1.0, 0.12), 1.0)
        return

    if terrain_type == &"bridge":
        _draw_contract_tile_card(rect, terrain_type)
        draw_line(rect.position + Vector2(10.0, 14.0), rect.position + Vector2(rect.size.x - 10.0, 14.0), Color(0.878431, 0.745098, 0.505882, 0.18), 2.0)
        draw_line(rect.position + Vector2(10.0, rect.size.y - 14.0), rect.position + Vector2(rect.size.x - 10.0, rect.size.y - 14.0), Color(0.878431, 0.745098, 0.505882, 0.18), 2.0)
        for offset_x in [18.0, 30.0, 42.0]:
            draw_line(rect.position + Vector2(offset_x, 12.0), rect.position + Vector2(offset_x, rect.size.y - 12.0), Color(0.623529, 0.505882, 0.341176, 0.16), 1.0)
        _draw_contract_tile_icon(rect, terrain_type)
        return

    if terrain_type == &"keep":
        _draw_contract_tile_card(rect, terrain_type)
        draw_rect(rect.grow(-10.0), Color(0.172549, 0.184314, 0.219608, 0.34), true)
        draw_line(rect.position + Vector2(14.0, 18.0), rect.position + Vector2(rect.size.x - 14.0, 18.0), Color(0.847059, 0.905882, 0.984314, 0.12), 1.0)
        draw_line(rect.position + Vector2(14.0, rect.size.y - 18.0), rect.position + Vector2(rect.size.x - 14.0, rect.size.y - 18.0), Color(0.847059, 0.905882, 0.984314, 0.12), 1.0)
        _draw_contract_tile_icon(rect, terrain_type)
        return

    if terrain_type == &"corridor":
        _draw_contract_tile_card(rect, terrain_type)
        draw_line(rect.position + Vector2(rect.size.x * 0.5, 12.0), rect.position + Vector2(rect.size.x * 0.5, rect.size.y - 12.0), Color(0.811765, 0.87451, 1.0, 0.16), 2.0)
        draw_line(rect.position + Vector2(rect.size.x * 0.32, 14.0), rect.position + Vector2(rect.size.x * 0.32, rect.size.y - 14.0), Color(0.611765, 0.694118, 0.870588, 0.08), 1.0)
        draw_line(rect.position + Vector2(rect.size.x * 0.68, 14.0), rect.position + Vector2(rect.size.x * 0.68, rect.size.y - 14.0), Color(0.611765, 0.694118, 0.870588, 0.08), 1.0)
        _draw_contract_tile_icon(rect, terrain_type)
        return

    if terrain_type == &"highground":
        _draw_contract_tile_card(rect, terrain_type)
        draw_polygon(
            PackedVector2Array([
                rect.position + Vector2(rect.size.x * 0.5, 10.0),
                rect.position + Vector2(rect.size.x - 12.0, rect.size.y * 0.45),
                rect.position + Vector2(rect.size.x * 0.5, rect.size.y - 10.0),
                rect.position + Vector2(12.0, rect.size.y * 0.45)
            ]),
            PackedColorArray([Color(0.976471, 0.878431, 0.6, 0.14)])
        )
        draw_line(rect.position + Vector2(16.0, rect.size.y - 18.0), rect.position + Vector2(rect.size.x - 16.0, rect.size.y - 18.0), Color(0.647059, 0.552941, 0.337255, 0.24), 2.0)
        draw_line(rect.position + Vector2(20.0, rect.size.y - 24.0), rect.position + Vector2(rect.size.x - 20.0, rect.size.y - 24.0), Color(0.905882, 0.807843, 0.592157, 0.18), 1.0)
        _draw_contract_tile_icon(rect, terrain_type)
        return

    _draw_contract_tile_card(rect, &"plain")
    var inner_plain := rect.grow(-16.0)
    draw_rect(inner_plain, Color(1, 1, 1, 0.028), true)
    draw_line(rect.position + Vector2(0.0, 1.0), rect.position + Vector2(rect.size.x, 1.0), Color(1, 1, 1, 0.045), 1.0)
    draw_line(rect.position + Vector2(1.0, rect.size.y - 1.0), rect.position + Vector2(rect.size.x - 1.0, rect.size.y - 1.0), Color(0, 0, 0, 0.08), 1.0)
    if (cell.x + cell.y) % 2 == 0:
        draw_line(rect.position + Vector2(16.0, rect.size.y - 16.0), rect.position + Vector2(rect.size.x - 16.0, 16.0), Color(1, 1, 1, 0.035), 1.0)
    _draw_stage_cell_motif(stage_key, cell, rect)

func _get_terrain_overlay_contract(terrain_type: StringName) -> Dictionary:
    return TERRAIN_OVERLAY_CONTRACTS.get(terrain_type, TERRAIN_OVERLAY_CONTRACTS.get(&"plain", {}))

func _draw_contract_tile_icon(rect: Rect2, terrain_type: StringName) -> void:
    var contract := _get_terrain_overlay_contract(terrain_type)
    var file_name := String(contract.get("icon", ""))
    if file_name.is_empty():
        return
    _draw_tile_icon(rect, file_name)

func _draw_contract_tile_card(rect: Rect2, terrain_type: StringName) -> void:
    var contract := _get_terrain_overlay_contract(terrain_type)
    var file_name := String(contract.get("card", ""))
    if file_name.is_empty():
        return
    _draw_tile_card(rect, file_name, float(contract.get("card_alpha", 0.0)))

func _draw_tile_icon(rect: Rect2, file_name: String) -> void:
    var texture: Texture2D = _load_tile_icon(file_name)
    if texture == null:
        return
    draw_texture_rect(
        texture,
        Rect2(rect.position + Vector2(6.0, 6.0), Vector2(TILE_ICON_SIZE, TILE_ICON_SIZE)),
        false,
        Color(1.0, 1.0, 1.0, 0.72)
    )

func _load_tile_icon(file_name: String) -> Texture2D:
    if _tile_icon_cache.has(file_name):
        return _tile_icon_cache[file_name]
    var texture: Texture2D = BattleArtCatalog.load_tile_icon(file_name)
    if texture == null:
        return null
    _tile_icon_cache[file_name] = texture
    return texture

func _draw_tile_card(rect: Rect2, file_name: String, alpha: float) -> void:
    var texture: Texture2D = _load_tile_card(file_name)
    if texture == null:
        return
    draw_texture_rect(
        texture,
        Rect2(rect.position + Vector2(TILE_CARD_INSET, TILE_CARD_INSET), rect.size - Vector2(TILE_CARD_INSET * 2.0, TILE_CARD_INSET * 2.0)),
        false,
        Color(1.0, 1.0, 1.0, alpha)
    )

func _load_tile_card(file_name: String) -> Texture2D:
    if _tile_card_cache.has(file_name):
        return _tile_card_cache[file_name]
    var texture: Texture2D = BattleArtCatalog.load_tile_card(file_name)
    if texture == null:
        return null
    _tile_card_cache[file_name] = texture
    return texture

func _draw_spawn_chevrons(rect: Rect2, color: Color, enemy: bool) -> void:
    var center := rect.get_center()
    var y_dir: float = 1.0 if enemy else -1.0
    draw_line(center + Vector2(-8.0, -6.0 * y_dir), center + Vector2(0.0, -14.0 * y_dir), color, 2.0)
    draw_line(center + Vector2(8.0, -6.0 * y_dir), center + Vector2(0.0, -14.0 * y_dir), color, 2.0)
    draw_line(center + Vector2(-8.0, 2.0 * y_dir), center + Vector2(0.0, -6.0 * y_dir), color, 2.0)
    draw_line(center + Vector2(8.0, 2.0 * y_dir), center + Vector2(0.0, -6.0 * y_dir), color, 2.0)

func _draw_stage_cell_motif(stage_key: String, cell: Vector2i, rect: Rect2) -> void:
    if stage_key.begins_with("CH02") or stage_key.begins_with("CH06"):
        if cell.y % 2 == 0:
            draw_line(rect.position + Vector2(10.0, rect.size.y * 0.32), rect.position + Vector2(rect.size.x - 10.0, rect.size.y * 0.32), Color(0.815686, 0.843137, 0.905882, 0.05), 1.0)
            draw_line(rect.position + Vector2(10.0, rect.size.y * 0.68), rect.position + Vector2(rect.size.x - 10.0, rect.size.y * 0.68), Color(0.431373, 0.462745, 0.537255, 0.06), 1.0)
        if cell.x % 3 == 0:
            draw_line(rect.position + Vector2(rect.size.x * 0.48, 10.0), rect.position + Vector2(rect.size.x * 0.48, rect.size.y - 10.0), Color(0.756863, 0.780392, 0.839216, 0.04), 1.0)
        return

    if stage_key.begins_with("CH03"):
        if (cell.x + cell.y) % 3 == 0:
            draw_circle(rect.get_center() + Vector2(-8.0, 6.0), 3.0, Color(0.615686, 0.905882, 0.713725, 0.08))
            draw_line(rect.get_center() + Vector2(-4.0, 10.0), rect.get_center() + Vector2(6.0, -8.0), Color(0.721569, 0.952941, 0.792157, 0.08), 1.0)
        return

    if stage_key.begins_with("CH07"):
        if cell.y % 2 == 0:
            draw_arc(rect.get_center(), 9.0, PI * 1.05, PI * 1.95, 14, Color(0.909804, 0.733333, 0.984314, 0.08), 1.0)
            draw_arc(rect.get_center(), 14.0, PI * 1.05, PI * 1.95, 14, Color(0.909804, 0.733333, 0.984314, 0.05), 1.0)
        return

    if stage_key.begins_with("CH10"):
        if (cell.x + cell.y) % 2 == 0:
            draw_line(rect.get_center() + Vector2(-8.0, 0.0), rect.get_center() + Vector2(8.0, 0.0), Color(0.764706, 0.866667, 1.0, 0.08), 1.0)
            draw_line(rect.get_center() + Vector2(0.0, -8.0), rect.get_center() + Vector2(0.0, 8.0), Color(1.0, 0.764706, 0.92549, 0.07), 1.0)
            draw_arc(rect.get_center(), 10.0, PI * 0.12, PI * 1.88, 16, Color(0.862745, 0.921569, 1.0, 0.06), 1.0)
        return

func _draw_objective_marker(rect: Rect2) -> void:
    var center := rect.get_center()
    draw_line(center + Vector2(0.0, -24.0), center + Vector2(0.0, -10.0), Color(1.0, 0.937255, 0.709804, 0.2), 2.0)
    draw_line(center + Vector2(-10.0, 0.0), center + Vector2(10.0, 0.0), Color(0.996078, 0.886275, 0.556863, 0.44), 2.0)
    draw_line(center + Vector2(0.0, -10.0), center + Vector2(0.0, 10.0), Color(0.996078, 0.886275, 0.556863, 0.44), 2.0)
    draw_arc(center, 18.0, 0.0, TAU, 24, Color(1.0, 0.913725, 0.584314, 0.28), 2.0)
    draw_arc(center, 24.0, PI * 0.18, PI * 0.82, 18, Color(1.0, 0.945098, 0.721569, 0.2), 2.0)
    draw_arc(center, 24.0, PI * 1.18, PI * 1.82, 18, Color(1.0, 0.945098, 0.721569, 0.2), 2.0)
    draw_polygon(
        PackedVector2Array([
            center + Vector2(0.0, -22.0),
            center + Vector2(4.0, -16.0),
            center + Vector2(0.0, -10.0),
            center + Vector2(-4.0, -16.0)
        ]),
        PackedColorArray([Color(1.0, 0.94902, 0.713725, 0.5)])
    )
    draw_circle(center, 4.0, Color(1.0, 0.92549, 0.635294, 0.36))

func _draw_terrain_advantage_marker(cell: Vector2i, rect: Rect2) -> void:
    var defense_bonus: int = stage_data.get_defense_bonus(cell)
    if defense_bonus <= 0:
        return

    var anchor := rect.position + Vector2(rect.size.x - 16.0, 16.0)
    draw_circle(anchor, 8.0, Color(0.105882, 0.14902, 0.203922, 0.76))
    draw_circle(anchor, 7.0, Color(0.658824, 0.854902, 1.0, 0.14))
    draw_line(anchor + Vector2(0.0, -4.0), anchor + Vector2(0.0, 4.0), Color(0.878431, 0.960784, 1.0, 0.78), 2.0)
    draw_line(anchor + Vector2(-4.0, 0.0), anchor + Vector2(4.0, 0.0), Color(0.878431, 0.960784, 1.0, 0.78), 2.0)

func _draw_enemy_corner_brackets(rect: Rect2, color: Color) -> void:
    var inset: float = 6.0
    var arm: float = 10.0
    var tl := rect.position + Vector2(inset, inset)
    var tr := rect.position + Vector2(rect.size.x - inset, inset)
    var bl := rect.position + Vector2(inset, rect.size.y - inset)
    var br := rect.position + Vector2(rect.size.x - inset, rect.size.y - inset)
    draw_line(tl, tl + Vector2(arm, 0), color, 2.0)
    draw_line(tl, tl + Vector2(0, arm), color, 2.0)
    draw_line(tr, tr + Vector2(-arm, 0), color, 2.0)
    draw_line(tr, tr + Vector2(0, arm), color, 2.0)
    draw_line(bl, bl + Vector2(arm, 0), color, 2.0)
    draw_line(bl, bl + Vector2(0, -arm), color, 2.0)
    draw_line(br, br + Vector2(-arm, 0), color, 2.0)
    draw_line(br, br + Vector2(0, -arm), color, 2.0)

func _draw_corner_ornaments(board_rect: Rect2, color: Color) -> void:
    var notch: float = 18.0
    draw_line(board_rect.position, board_rect.position + Vector2(notch, 0), color, 3.0)
    draw_line(board_rect.position, board_rect.position + Vector2(0, notch), color, 3.0)
    draw_line(board_rect.position + Vector2(board_rect.size.x, 0), board_rect.position + Vector2(board_rect.size.x - notch, 0), color, 3.0)
    draw_line(board_rect.position + Vector2(board_rect.size.x, 0), board_rect.position + Vector2(board_rect.size.x, notch), color, 3.0)
    draw_line(board_rect.position + Vector2(0, board_rect.size.y), board_rect.position + Vector2(notch, board_rect.size.y), color, 3.0)
    draw_line(board_rect.position + Vector2(0, board_rect.size.y), board_rect.position + Vector2(0, board_rect.size.y - notch), color, 3.0)
    draw_line(board_rect.position + board_rect.size, board_rect.position + board_rect.size + Vector2(-notch, 0), color, 3.0)
    draw_line(board_rect.position + board_rect.size, board_rect.position + board_rect.size + Vector2(0, -notch), color, 3.0)

func _draw_stage_signature(board_rect: Rect2, palette: Dictionary) -> void:
    var stage_key: String = String(stage_data.stage_id)
    var primary: Color = Color(palette.get("signature_primary", Color(0.631373, 0.803922, 1.0, 0.08)))
    var secondary: Color = Color(palette.get("signature_secondary", Color(1.0, 0.764706, 0.556863, 0.07)))

    if stage_key == "tutorial_stage":
        draw_circle(board_rect.get_center(), 44.0, primary)
        draw_arc(board_rect.get_center(), 74.0, PI * 0.14, PI * 0.86, 28, secondary, 2.0)
        return

    if stage_key.begins_with("CH02") or stage_key.begins_with("CH06"):
        for offset_y in [board_rect.size.y * 0.18, board_rect.size.y * 0.5, board_rect.size.y * 0.82]:
            draw_line(Vector2(board_rect.position.x + 24.0, board_rect.position.y + offset_y), Vector2(board_rect.end.x - 24.0, board_rect.position.y + offset_y), primary, 2.0)
        return

    if stage_key.begins_with("CH03"):
        for offset_x in [board_rect.size.x * 0.22, board_rect.size.x * 0.54, board_rect.size.x * 0.8]:
            draw_arc(Vector2(board_rect.position.x + offset_x, board_rect.position.y + board_rect.size.y * 0.42), 28.0, 0.0, TAU, 20, primary, 3.0)
            draw_circle(Vector2(board_rect.position.x + offset_x, board_rect.position.y + board_rect.size.y * 0.42), 10.0, secondary)
        draw_line(board_rect.position + Vector2(36.0, board_rect.size.y * 0.76), board_rect.position + Vector2(board_rect.size.x - 36.0, board_rect.size.y * 0.18), secondary, 3.0)
        draw_line(board_rect.position + Vector2(44.0, board_rect.size.y * 0.82), board_rect.position + Vector2(board_rect.size.x - 60.0, board_rect.size.y * 0.26), primary, 2.0)
        return

    if stage_key.begins_with("CH04"):
        for offset_x in [board_rect.size.x * 0.28, board_rect.size.x * 0.62]:
            draw_line(Vector2(board_rect.position.x + offset_x, board_rect.position.y + 24.0), Vector2(board_rect.position.x + offset_x, board_rect.end.y - 24.0), primary, 2.0)
        draw_arc(board_rect.position + Vector2(board_rect.size.x * 0.52, board_rect.size.y * 0.26), 36.0, PI, TAU, 18, secondary, 2.0)
        return

    if stage_key.begins_with("CH05"):
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.18, 28.0), board_rect.position + Vector2(board_rect.size.x * 0.74, board_rect.end.y - 34.0), primary, 3.0)
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.34, 24.0), board_rect.position + Vector2(board_rect.size.x * 0.88, board_rect.end.y - 42.0), secondary, 2.0)
        return

    if stage_key.begins_with("CH07"):
        draw_arc(board_rect.position + Vector2(board_rect.size.x * 0.5, board_rect.size.y * 0.18), 54.0, PI, TAU, 24, primary, 3.0)
        draw_arc(board_rect.position + Vector2(board_rect.size.x * 0.5, board_rect.size.y * 0.18), 76.0, PI, TAU, 24, secondary, 3.0)
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.34, board_rect.size.y * 0.12), board_rect.position + Vector2(board_rect.size.x * 0.34, board_rect.size.y * 0.28), secondary, 2.0)
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.66, board_rect.size.y * 0.12), board_rect.position + Vector2(board_rect.size.x * 0.66, board_rect.size.y * 0.28), secondary, 2.0)
        draw_arc(board_rect.position + Vector2(board_rect.size.x * 0.5, board_rect.size.y * 0.56), 118.0, PI * 1.08, PI * 1.92, 28, Color(0.960784, 0.835294, 0.988235, 0.08), 2.0)
        draw_arc(board_rect.position + Vector2(board_rect.size.x * 0.5, board_rect.size.y * 0.56), 154.0, PI * 1.12, PI * 1.88, 28, Color(0.678431, 0.47451, 0.776471, 0.07), 2.0)
        return

    if stage_key.begins_with("CH08"):
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.16, board_rect.size.y * 0.76), board_rect.position + Vector2(board_rect.size.x * 0.82, board_rect.size.y * 0.28), primary, 2.0)
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.18, board_rect.size.y * 0.66), board_rect.position + Vector2(board_rect.size.x * 0.84, board_rect.size.y * 0.18), secondary, 2.0)
        return

    if stage_key.begins_with("CH09A") or stage_key.begins_with("CH09B"):
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.24, 26.0), board_rect.position + Vector2(board_rect.size.x * 0.76, board_rect.end.y - 26.0), primary, 2.0)
        draw_line(board_rect.position + Vector2(board_rect.size.x * 0.76, 26.0), board_rect.position + Vector2(board_rect.size.x * 0.24, board_rect.end.y - 26.0), primary, 2.0)
        draw_rect(Rect2(board_rect.position + Vector2(board_rect.size.x * 0.43, board_rect.size.y * 0.38), Vector2(44.0, 44.0)), secondary, false, 2.0)
        return

    if stage_key.begins_with("CH10"):
        draw_arc(board_rect.get_center(), 56.0, 0.0, TAU, 30, primary, 3.0)
        draw_arc(board_rect.get_center(), 92.0, 0.0, TAU, 30, secondary, 3.0)
        draw_arc(board_rect.get_center(), 128.0, PI * 0.12, PI * 1.88, 34, primary, 2.0)
        draw_arc(board_rect.get_center(), 170.0, PI * 0.16, PI * 1.84, 36, Color(0.839216, 0.917647, 1.0, 0.06), 2.0)
        draw_line(board_rect.get_center() + Vector2(-140.0, 0.0), board_rect.get_center() + Vector2(140.0, 0.0), Color(0.847059, 0.905882, 1.0, 0.05), 1.0)
        draw_line(board_rect.get_center() + Vector2(0.0, -140.0), board_rect.get_center() + Vector2(0.0, 140.0), Color(1.0, 0.823529, 0.945098, 0.05), 1.0)
        draw_circle(board_rect.get_center(), 18.0, secondary)
        return

func _draw_surface_family_overlay(board_rect: Rect2, palette: Dictionary) -> void:
    var surface_family := _get_stage_surface_family()
    if surface_family == "fortress":
        var pillar_color := Color(0.090196, 0.0980392, 0.129412, 0.34)
        var slit_color := Color(0.756863, 0.807843, 0.901961, 0.08)
        for x_ratio in [0.12, 0.34, 0.66, 0.88]:
            var x_pos: float = board_rect.position.x + board_rect.size.x * x_ratio
            draw_rect(Rect2(Vector2(x_pos - 12.0, board_rect.position.y - 18.0), Vector2(24.0, board_rect.size.y + 36.0)), pillar_color, true)
            draw_rect(Rect2(Vector2(x_pos - 2.0, board_rect.position.y + board_rect.size.y * 0.16), Vector2(4.0, board_rect.size.y * 0.14)), slit_color, true)
            draw_rect(Rect2(Vector2(x_pos - 2.0, board_rect.position.y + board_rect.size.y * 0.58), Vector2(4.0, board_rect.size.y * 0.14)), slit_color, true)
        draw_line(board_rect.position + Vector2(24.0, board_rect.size.y * 0.2), board_rect.position + Vector2(board_rect.size.x - 24.0, board_rect.size.y * 0.2), Color(0.847059, 0.878431, 0.941176, 0.06), 2.0)
        draw_line(board_rect.position + Vector2(24.0, board_rect.size.y * 0.8), board_rect.position + Vector2(board_rect.size.x - 24.0, board_rect.size.y * 0.8), Color(0.341176, 0.380392, 0.458824, 0.08), 2.0)
        return

    if surface_family == "forest":
        var canopy_color := Color(0.0588235, 0.14902, 0.101961, 0.18)
        var mist_color := Color(0.733333, 0.956863, 0.831373, 0.05)
        draw_circle(board_rect.position + Vector2(board_rect.size.x * 0.18, board_rect.size.y * 0.18), 74.0, canopy_color)
        draw_circle(board_rect.position + Vector2(board_rect.size.x * 0.76, board_rect.size.y * 0.22), 92.0, canopy_color)
        draw_circle(board_rect.position + Vector2(board_rect.size.x * 0.34, board_rect.size.y * 0.72), 84.0, canopy_color)
        draw_line(board_rect.position + Vector2(28.0, board_rect.size.y * 0.64), board_rect.position + Vector2(board_rect.size.x - 44.0, board_rect.size.y * 0.28), mist_color, 6.0)
        draw_line(board_rect.position + Vector2(44.0, board_rect.size.y * 0.78), board_rect.position + Vector2(board_rect.size.x - 28.0, board_rect.size.y * 0.44), Color(0.862745, 1.0, 0.901961, 0.035), 4.0)
        return

    if surface_family == "city":
        var lane_color := Color(0.823529, 0.701961, 0.905882, 0.05)
        for y_ratio in [0.26, 0.5, 0.74]:
            draw_line(
                board_rect.position + Vector2(24.0, board_rect.size.y * y_ratio),
                board_rect.position + Vector2(board_rect.size.x - 24.0, board_rect.size.y * y_ratio),
                lane_color,
                2.0
            )
        for x_ratio in [0.22, 0.5, 0.78]:
            draw_line(
                board_rect.position + Vector2(board_rect.size.x * x_ratio, 22.0),
                board_rect.position + Vector2(board_rect.size.x * x_ratio, board_rect.size.y - 22.0),
                Color(0.509804, 0.34902, 0.635294, 0.06),
                1.0
            )
        return

    if surface_family == "archive":
        for x_ratio in [0.18, 0.5, 0.82]:
            var x_pos: float = board_rect.position.x + board_rect.size.x * x_ratio
            draw_rect(Rect2(Vector2(x_pos - 10.0, board_rect.position.y + 18.0), Vector2(20.0, board_rect.size.y - 36.0)), Color(0.14902, 0.113725, 0.0901961, 0.18), true)
        for y_ratio in [0.32, 0.66]:
            draw_line(
                board_rect.position + Vector2(18.0, board_rect.size.y * y_ratio),
                board_rect.position + Vector2(board_rect.size.x - 18.0, board_rect.size.y * y_ratio),
                Color(0.760784, 0.678431, 0.541176, 0.06),
                2.0
            )
        return

    if surface_family == "final_bell":
        var center := board_rect.get_center()
        draw_arc(center, 96.0, 0.0, TAU, 28, Color(0.72549, 0.843137, 1.0, 0.08), 2.0)
        draw_arc(center, 142.0, PI * 0.1, PI * 1.9, 34, Color(1.0, 0.756863, 0.917647, 0.07), 2.0)
        draw_line(center + Vector2(-board_rect.size.x * 0.34, 0.0), center + Vector2(board_rect.size.x * 0.34, 0.0), Color(0.807843, 0.905882, 1.0, 0.04), 1.0)
        draw_line(center + Vector2(0.0, -board_rect.size.y * 0.32), center + Vector2(0.0, board_rect.size.y * 0.32), Color(1.0, 0.811765, 0.952941, 0.04), 1.0)
        return

func _get_stage_surface_family() -> String:
    if stage_data == null:
        return "default"
    var stage_key: String = String(stage_data.stage_id)
    if stage_key.begins_with("CH02") or stage_key.begins_with("CH06"):
        return "fortress"
    if stage_key.begins_with("CH03") or stage_key.begins_with("CH08"):
        return "forest"
    if stage_key.begins_with("CH07"):
        return "city"
    if stage_key.begins_with("CH09A") or stage_key.begins_with("CH09B"):
        return "archive"
    if stage_key.begins_with("CH10"):
        return "final_bell"
    return "default"

func _get_backdrop_family() -> String:
    if stage_data == null:
        return "default"
    var stage_key: String = String(stage_data.stage_id)
    if stage_key.begins_with("CH02") or stage_key.begins_with("CH06"):
        return "fortress"
    if stage_key.begins_with("CH03") or stage_key.begins_with("CH08"):
        return "forest"
    if stage_key.begins_with("CH07"):
        return "city"
    if stage_key.begins_with("CH09A") or stage_key.begins_with("CH09B"):
        return "archive"
    if stage_key.begins_with("CH10"):
        return "final_bell"
    return "default"

func _get_backdrop_density() -> float:
    match _get_backdrop_family():
        "forest", "fortress", "city", "archive", "final_bell":
            return 0.68
        _:
            return 0.34

func _get_palette() -> Dictionary:
    var stage_key: String = String(stage_data.stage_id)
    if stage_key == "tutorial_stage":
        return {
            "backdrop_base": Color(0.071, 0.082, 0.125, 1.0),
            "backdrop_top": Color(0.125, 0.153, 0.231, 0.98),
            "backdrop_bottom": Color(0.055, 0.067, 0.106, 0.98),
            "backdrop_glow_left": Color(0.204, 0.384, 0.678, 0.26),
            "backdrop_glow_right": Color(0.608, 0.294, 0.247, 0.2),
            "board_glow_center": Color(0.388, 0.475, 0.706, 0.14),
            "board_glow_edge": Color(0.671, 0.388, 0.286, 0.12),
            "signature_primary": Color(0.658824, 0.843137, 1.0, 0.1),
            "signature_secondary": Color(1.0, 0.858824, 0.466667, 0.08),
            "frame_outer": Color(0.027, 0.039, 0.059, 0.96),
            "frame_inner": Color(0.071, 0.09, 0.129, 0.98),
            "board_shadow": Color(0.02, 0.027, 0.043, 0.94),
            "ally_zone": Color(0.18, 0.384, 0.655, 0.16),
            "enemy_zone": Color(0.545, 0.184, 0.169, 0.15),
            "ally_zone_line": Color(0.557, 0.82, 1.0, 0.14),
            "enemy_zone_line": Color(0.961, 0.514, 0.451, 0.14),
            "frame_highlight": Color(1.0, 0.866667, 0.482353, 0.8),
            "plain_a": Color(0.313, 0.321, 0.357, 1.0),
            "plain_b": Color(0.271, 0.278, 0.317, 1.0),
            "forest_a": Color(0.176, 0.266667, 0.231373, 1.0),
            "forest_b": Color(0.145098, 0.223529, 0.192157, 1.0),
            "wall_a": Color(0.247059, 0.254902, 0.286275, 1.0),
            "wall_b": Color(0.211765, 0.219608, 0.25098, 1.0)
        }
    if stage_key.begins_with("CH02") or stage_key.begins_with("CH06"):
        return {
            "backdrop_base": Color(0.094, 0.094, 0.106, 1.0),
            "backdrop_top": Color(0.145, 0.141, 0.161, 0.97),
            "backdrop_bottom": Color(0.075, 0.078, 0.09, 0.97),
            "backdrop_glow_left": Color(0.235, 0.337, 0.525, 0.2),
            "backdrop_glow_right": Color(0.471, 0.239, 0.216, 0.18),
            "board_glow_center": Color(0.353, 0.38, 0.463, 0.09),
            "board_glow_edge": Color(0.6, 0.302, 0.251, 0.08),
            "frame_outer": Color(0.035, 0.039, 0.051, 0.95),
            "frame_inner": Color(0.09, 0.094, 0.114, 0.98),
            "board_shadow": Color(0.024, 0.027, 0.035, 0.94),
            "ally_zone": Color(0.157, 0.259, 0.416, 0.12),
            "enemy_zone": Color(0.431, 0.176, 0.157, 0.12),
            "ally_zone_line": Color(0.459, 0.678, 0.961, 0.1),
            "enemy_zone_line": Color(0.918, 0.471, 0.416, 0.1),
            "frame_highlight": Color(0.925, 0.765, 0.424, 0.74),
            "plain_a": Color(0.278, 0.282, 0.302, 1.0),
            "plain_b": Color(0.243, 0.247, 0.267, 1.0),
            "forest_a": Color(0.173, 0.212, 0.188, 1.0),
            "forest_b": Color(0.141, 0.176, 0.157, 1.0),
            "wall_a": Color(0.247, 0.247, 0.267, 1.0),
            "wall_b": Color(0.208, 0.208, 0.227, 1.0)
        }
    if stage_key.begins_with("CH03"):
        return {
            "backdrop_base": Color(0.047, 0.075, 0.059, 1.0),
            "backdrop_top": Color(0.078, 0.153, 0.114, 0.98),
            "backdrop_bottom": Color(0.035, 0.059, 0.047, 0.98),
            "backdrop_glow_left": Color(0.204, 0.486, 0.31, 0.26),
            "backdrop_glow_right": Color(0.42, 0.698, 0.376, 0.2),
            "board_glow_center": Color(0.255, 0.514, 0.341, 0.14),
            "board_glow_edge": Color(0.545, 0.804, 0.447, 0.1),
            "signature_primary": Color(0.541, 0.922, 0.651, 0.12),
            "signature_secondary": Color(0.855, 1.0, 0.718, 0.09),
            "frame_outer": Color(0.027, 0.043, 0.035, 0.96),
            "frame_inner": Color(0.075, 0.106, 0.094, 0.98),
            "board_shadow": Color(0.02, 0.031, 0.024, 0.94),
            "ally_zone": Color(0.173, 0.388, 0.294, 0.14),
            "enemy_zone": Color(0.376, 0.2, 0.149, 0.12),
            "ally_zone_line": Color(0.616, 0.961, 0.741, 0.12),
            "enemy_zone_line": Color(0.933, 0.635, 0.486, 0.09),
            "frame_highlight": Color(0.871, 0.796, 0.447, 0.74),
            "plain_a": Color(0.227, 0.247, 0.239, 1.0),
            "plain_b": Color(0.192, 0.212, 0.204, 1.0),
            "forest_a": Color(0.141, 0.231, 0.18, 1.0),
            "forest_b": Color(0.114, 0.188, 0.145, 1.0),
            "wall_a": Color(0.2, 0.216, 0.212, 1.0),
            "wall_b": Color(0.165, 0.18, 0.176, 1.0)
        }
    if stage_key.begins_with("CH04") or stage_key.begins_with("CH05"):
        return {
            "backdrop_base": Color(0.082, 0.086, 0.11, 1.0),
            "backdrop_top": Color(0.106, 0.125, 0.161, 0.97),
            "backdrop_bottom": Color(0.063, 0.067, 0.09, 0.97),
            "backdrop_glow_left": Color(0.176, 0.349, 0.455, 0.18),
            "backdrop_glow_right": Color(0.541, 0.345, 0.22, 0.16),
            "board_glow_center": Color(0.286, 0.392, 0.494, 0.09),
            "board_glow_edge": Color(0.631, 0.424, 0.255, 0.08),
            "frame_outer": Color(0.031, 0.039, 0.055, 0.95),
            "frame_inner": Color(0.082, 0.098, 0.129, 0.98),
            "board_shadow": Color(0.024, 0.027, 0.039, 0.94),
            "ally_zone": Color(0.133, 0.282, 0.42, 0.12),
            "enemy_zone": Color(0.431, 0.216, 0.161, 0.12),
            "ally_zone_line": Color(0.431, 0.706, 0.91, 0.1),
            "enemy_zone_line": Color(0.906, 0.584, 0.396, 0.1),
            "frame_highlight": Color(0.91, 0.804, 0.514, 0.74),
            "plain_a": Color(0.259, 0.267, 0.294, 1.0),
            "plain_b": Color(0.227, 0.235, 0.267, 1.0),
            "forest_a": Color(0.153, 0.204, 0.19, 1.0),
            "forest_b": Color(0.122, 0.173, 0.157, 1.0),
            "wall_a": Color(0.224, 0.231, 0.251, 1.0),
            "wall_b": Color(0.188, 0.196, 0.22, 1.0)
        }
    if stage_key.begins_with("CH07"):
        return {
            "backdrop_base": Color(0.071, 0.063, 0.094, 1.0),
            "backdrop_top": Color(0.125, 0.094, 0.173, 0.97),
            "backdrop_bottom": Color(0.055, 0.047, 0.082, 0.97),
            "backdrop_glow_left": Color(0.392, 0.243, 0.608, 0.26),
            "backdrop_glow_right": Color(0.651, 0.325, 0.424, 0.22),
            "board_glow_center": Color(0.447, 0.31, 0.608, 0.12),
            "board_glow_edge": Color(0.769, 0.455, 0.557, 0.1),
            "signature_primary": Color(0.945, 0.733, 0.984, 0.12),
            "signature_secondary": Color(1.0, 0.858824, 0.952941, 0.09),
            "frame_outer": Color(0.043, 0.051, 0.074, 0.95),
            "frame_inner": Color(0.086, 0.094, 0.129, 0.98),
            "board_shadow": Color(0.024, 0.031, 0.047, 0.9),
            "ally_zone": Color(0.173, 0.255, 0.431, 0.12),
            "enemy_zone": Color(0.471, 0.165, 0.243, 0.13),
            "ally_zone_line": Color(0.404, 0.616, 0.863, 0.1),
            "enemy_zone_line": Color(0.847, 0.471, 0.565, 0.1),
            "frame_highlight": Color(0.733, 0.604, 0.376, 0.7),
            "plain_a": Color(0.255, 0.247, 0.286, 1.0),
            "plain_b": Color(0.227, 0.22, 0.259, 1.0),
            "forest_a": Color(0.165, 0.235, 0.212, 1.0),
            "forest_b": Color(0.133, 0.2, 0.18, 1.0),
            "wall_a": Color(0.22, 0.22, 0.239, 1.0),
            "wall_b": Color(0.184, 0.184, 0.204, 1.0)
        }
    if stage_key.begins_with("CH08"):
        return {
            "backdrop_base": Color(0.055, 0.082, 0.071, 1.0),
            "backdrop_top": Color(0.082, 0.125, 0.114, 0.96),
            "backdrop_bottom": Color(0.055, 0.071, 0.063, 0.96),
            "backdrop_glow_left": Color(0.153, 0.349, 0.247, 0.2),
            "backdrop_glow_right": Color(0.255, 0.529, 0.341, 0.16),
            "board_glow_center": Color(0.184, 0.353, 0.267, 0.09),
            "board_glow_edge": Color(0.275, 0.518, 0.365, 0.08),
            "signature_primary": Color(0.694118, 0.886275, 0.756863, 0.09),
            "signature_secondary": Color(0.882353, 1.0, 0.784314, 0.07),
            "frame_outer": Color(0.031, 0.047, 0.043, 0.95),
            "frame_inner": Color(0.075, 0.102, 0.094, 0.98),
            "board_shadow": Color(0.02, 0.031, 0.027, 0.9),
            "ally_zone": Color(0.125, 0.259, 0.235, 0.1),
            "enemy_zone": Color(0.271, 0.153, 0.153, 0.1),
            "ally_zone_line": Color(0.286, 0.612, 0.529, 0.09),
            "enemy_zone_line": Color(0.604, 0.337, 0.314, 0.08),
            "frame_highlight": Color(0.69, 0.655, 0.4, 0.72),
            "plain_a": Color(0.216, 0.239, 0.227, 1.0),
            "plain_b": Color(0.184, 0.208, 0.196, 1.0),
            "forest_a": Color(0.137, 0.216, 0.184, 1.0),
            "forest_b": Color(0.11, 0.176, 0.149, 1.0),
            "wall_a": Color(0.169, 0.184, 0.18, 1.0),
            "wall_b": Color(0.145, 0.157, 0.153, 1.0)
        }
    if stage_key.begins_with("CH09A") or stage_key.begins_with("CH09B"):
        return {
            "backdrop_base": Color(0.094, 0.074, 0.086, 1.0),
            "backdrop_top": Color(0.141, 0.098, 0.122, 0.97),
            "backdrop_bottom": Color(0.071, 0.055, 0.071, 0.97),
            "backdrop_glow_left": Color(0.243, 0.325, 0.541, 0.18),
            "backdrop_glow_right": Color(0.573, 0.231, 0.271, 0.18),
            "board_glow_center": Color(0.38, 0.275, 0.392, 0.1),
            "board_glow_edge": Color(0.694, 0.286, 0.333, 0.08),
            "frame_outer": Color(0.039, 0.031, 0.047, 0.95),
            "frame_inner": Color(0.098, 0.078, 0.11, 0.98),
            "board_shadow": Color(0.027, 0.02, 0.031, 0.94),
            "ally_zone": Color(0.165, 0.235, 0.404, 0.12),
            "enemy_zone": Color(0.49, 0.157, 0.216, 0.12),
            "ally_zone_line": Color(0.443, 0.651, 0.961, 0.1),
            "enemy_zone_line": Color(0.953, 0.416, 0.514, 0.1),
            "frame_highlight": Color(0.925, 0.71, 0.514, 0.74),
            "plain_a": Color(0.286, 0.267, 0.286, 1.0),
            "plain_b": Color(0.251, 0.231, 0.255, 1.0),
            "forest_a": Color(0.173, 0.2, 0.188, 1.0),
            "forest_b": Color(0.141, 0.169, 0.157, 1.0),
            "wall_a": Color(0.239, 0.224, 0.243, 1.0),
            "wall_b": Color(0.2, 0.188, 0.208, 1.0)
        }
    if stage_key.begins_with("CH10"):
        return {
            "backdrop_base": Color(0.055, 0.055, 0.086, 1.0),
            "backdrop_top": Color(0.102, 0.086, 0.153, 0.98),
            "backdrop_bottom": Color(0.039, 0.043, 0.071, 0.98),
            "backdrop_glow_left": Color(0.286, 0.408, 0.776, 0.22),
            "backdrop_glow_right": Color(0.82, 0.376, 0.533, 0.22),
            "board_glow_center": Color(0.416, 0.365, 0.698, 0.14),
            "board_glow_edge": Color(0.78, 0.506, 0.71, 0.1),
            "signature_primary": Color(0.733, 0.867, 1.0, 0.12),
            "signature_secondary": Color(1.0, 0.815686, 0.952941, 0.1),
            "frame_outer": Color(0.031, 0.031, 0.051, 0.96),
            "frame_inner": Color(0.082, 0.078, 0.129, 0.98),
            "board_shadow": Color(0.024, 0.024, 0.043, 0.95),
            "ally_zone": Color(0.212, 0.325, 0.561, 0.13),
            "enemy_zone": Color(0.604, 0.188, 0.341, 0.13),
            "ally_zone_line": Color(0.588, 0.82, 1.0, 0.12),
            "enemy_zone_line": Color(1.0, 0.565, 0.741, 0.12),
            "frame_highlight": Color(0.984, 0.859, 0.565, 0.76),
            "plain_a": Color(0.271, 0.271, 0.31, 1.0),
            "plain_b": Color(0.235, 0.235, 0.275, 1.0),
            "forest_a": Color(0.157, 0.204, 0.192, 1.0),
            "forest_b": Color(0.125, 0.169, 0.157, 1.0),
            "wall_a": Color(0.227, 0.227, 0.251, 1.0),
            "wall_b": Color(0.192, 0.192, 0.22, 1.0)
        }
    return {
        "backdrop_base": Color(0.094, 0.102, 0.141, 1.0),
        "backdrop_top": Color(0.133, 0.141, 0.188, 0.97),
        "backdrop_bottom": Color(0.071, 0.082, 0.114, 0.97),
        "backdrop_glow_left": Color(0.149, 0.275, 0.455, 0.2),
        "backdrop_glow_right": Color(0.431, 0.239, 0.216, 0.18),
        "board_glow_center": Color(0.275, 0.369, 0.541, 0.1),
        "board_glow_edge": Color(0.541, 0.31, 0.255, 0.08),
        "signature_primary": Color(0.631373, 0.803922, 1.0, 0.08),
        "signature_secondary": Color(1.0, 0.764706, 0.556863, 0.07),
        "frame_outer": Color(0.031, 0.043, 0.063, 0.94),
        "frame_inner": Color(0.078, 0.094, 0.129, 0.96),
        "board_shadow": Color(0.024, 0.031, 0.043, 0.92),
        "ally_zone": Color(0.118, 0.29, 0.49, 0.12),
        "enemy_zone": Color(0.431, 0.153, 0.153, 0.12),
        "ally_zone_line": Color(0.384, 0.651, 0.949, 0.1),
        "enemy_zone_line": Color(0.855, 0.392, 0.353, 0.1),
        "frame_highlight": Color(0.972, 0.831, 0.424, 0.72),
        "plain_a": Color(0.274, 0.282, 0.314, 1.0),
        "plain_b": Color(0.239, 0.247, 0.282, 1.0),
        "forest_a": Color(0.157, 0.231, 0.208, 1.0),
        "forest_b": Color(0.122, 0.192, 0.173, 1.0),
        "wall_a": Color(0.212, 0.212, 0.231, 1.0),
        "wall_b": Color(0.176, 0.176, 0.196, 1.0)
    }
