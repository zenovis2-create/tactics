class_name UnitActor
extends Node2D

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const SkillData = preload("res://scripts/data/skill_data.gd")
const AccessoryData = preload("res://scripts/data/accessory_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const ArmorData = preload("res://scripts/data/armor_data.gd")
const TelegraphTextureLibrary = preload("res://scripts/battle/telegraph_texture_library.gd")
signal defeated(unit: UnitActor)
signal attack_anim_hit  ## 공격 애니메이션 타격 시점 방출

@export var unit_data: UnitData
@export var faction: String = "ally"

var current_hp: int = 1
var grid_position: Vector2i = Vector2i.ZERO
var has_acted: bool = false

var _selected: bool = false
var _attackable: bool = false
var _boss_marked: bool = false
var _stealth_hidden: bool = false
var _tile_terrain_type: StringName = &"plain"
var _tile_defense_bonus: int = 0
var _equipped_accessory: AccessoryData
var _equipped_weapon: WeaponData
var _equipped_armor: ArmorData
var _move_tween: Tween
var _mark_pulse_tween: Tween
var _damage_flash_tween: Tween
var _animating_attack: bool = false

const DamageLabel = preload("res://scripts/battle/damage_label.gd")

@onready var marker: ColorRect = $Marker
@onready var shadow: ColorRect = $Shadow
@onready var halo: ColorRect = $Halo
@onready var terrain_ring: ColorRect = $TerrainRing
@onready var mark_aura: ColorRect = $MarkAura
@onready var frame: ColorRect = $Frame
@onready var damage_flash: ColorRect = $DamageFlash
@onready var accent: ColorRect = $Accent
@onready var faction_pip: ColorRect = $FactionPip
@onready var glyph_back: ColorRect = $GlyphBack
@onready var role_icon: TextureRect = $RoleIcon
@onready var glyph_label: Label = $GlyphLabel
@onready var inner: ColorRect = $Inner
@onready var token_art: TextureRect = $TokenArt
@onready var name_plate_back: ColorRect = $NamePlateBack
@onready var name_label: Label = $NameLabel
@onready var telegraph_label: Label = $TelegraphLabel
@onready var telegraph_icon: TextureRect = $TelegraphIcon
@onready var mark_crosshair_h: ColorRect = $MarkCrosshairH
@onready var mark_crosshair_v: ColorRect = $MarkCrosshairV
@onready var hp_label: Label = $HPLabel
@onready var hp_bar_back: ColorRect = $HPBarBack
@onready var hp_bar_fill: ColorRect = $HPBarFill
@onready var terrain_badge_back: ColorRect = $TerrainBadgeBack
@onready var terrain_badge_label: Label = $TerrainBadgeLabel
@onready var terrain_chevron_left: ColorRect = $TerrainChevronLeft
@onready var terrain_chevron_right: ColorRect = $TerrainChevronRight

func _ready() -> void:
    if unit_data != null:
        setup_from_data(unit_data)
    else:
        _refresh_visuals()

func setup_from_data(data: UnitData) -> void:
    unit_data = data
    faction = data.faction
    current_hp = data.max_hp
    _refresh_visuals()

func set_grid_position(cell: Vector2i, cell_size: Vector2i = Vector2i(64, 64)) -> void:
    grid_position = cell
    position = Vector2(cell.x * cell_size.x, cell.y * cell_size.y)

func move_to_grid(cell: Vector2i, cell_size: Vector2i = Vector2i(64, 64), duration: float = 0.2) -> void:
    grid_position = cell
    var target_position := Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
    if _move_tween != null and _move_tween.is_running():
        _move_tween.kill()
    if position.distance_to(target_position) <= 0.1:
        position = target_position
        _move_tween = null
        return
    _move_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _move_tween.tween_property(self, "position", target_position, duration)
    _move_tween.tween_callback(func():
        position = target_position
        _move_tween = null
    )

func set_selected(value: bool) -> void:
    _selected = value
    _refresh_visuals()

func set_attackable(value: bool) -> void:
    _attackable = value
    _refresh_visuals()

func set_boss_marked(value: bool) -> void:
    var was_marked: bool = _boss_marked
    _boss_marked = value
    _refresh_visuals()
    if value and not was_marked:
        _play_mark_pulse()

func set_stealth_hidden(value: bool) -> void:
    if _stealth_hidden == value:
        return
    _stealth_hidden = value
    _refresh_visuals()

func is_stealth_hidden() -> bool:
    return _stealth_hidden

func set_tile_context(terrain_type: StringName, defense_bonus: int) -> void:
    _tile_terrain_type = terrain_type
    _tile_defense_bonus = defense_bonus
    _refresh_visuals()

func set_equipped_accessory(accessory: AccessoryData) -> void:
    _equipped_accessory = accessory
    _refresh_visuals()

func set_equipped_weapon(weapon: WeaponData) -> void:
    _equipped_weapon = weapon
    _refresh_visuals()

func set_equipped_armor(armor: ArmorData) -> void:
    _equipped_armor = armor
    _refresh_visuals()

func apply_damage(amount: int) -> void:
    current_hp = max(0, current_hp - amount)
    _refresh_visuals()
    _play_damage_flash()
    show_damage(amount, &"damage")

    if current_hp <= 0:
        defeated.emit(self)
        queue_free()


func apply_heal(amount: int) -> void:
    current_hp = mini(unit_data.max_hp, current_hp + amount)
    _refresh_visuals()
    show_damage(amount, &"heal")


func show_damage(amount: int, type: StringName = &"damage") -> void:
    ## 유닛 위에 데미지/MISS/GUARD/CRITICAL 팝업 표시.
    var label: DamageLabel = DamageLabel.new()
    add_child(label)
    label.global_position = global_position
    label.setup(amount, type)


func play_attack_animation(target_pos: Vector2i, cell_size: float) -> void:
    ## 전진(0.12s) → 타격 콜백 → 복귀(0.10s) 애니메이션.
    if _animating_attack:
        return
    _animating_attack = true
    var original_pos: Vector2 = position
    var direction: Vector2 = (Vector2(target_pos) * cell_size - original_pos).normalized()
    var lunge_distance: float = cell_size * 0.4
    var target_offset: Vector2 = direction * lunge_distance

    var tw := create_tween().set_trans(Tween.TRANS_SINE)
    tw.tween_property(self, "position", original_pos + target_offset, 0.12)
    tw.tween_callback(attack_anim_hit.emit)
    tw.tween_property(self, "position", original_pos, 0.10)
    tw.tween_callback(func(): _animating_attack = false)


func is_animating_attack() -> bool:
    return _animating_attack

func is_defeated() -> bool:
    return current_hp <= 0

func get_attack() -> int:
    var base_value: int = unit_data.attack if unit_data != null else 1
    if _equipped_weapon != null:
        base_value += _equipped_weapon.attack_bonus
    if _equipped_armor != null:
        base_value += _equipped_armor.attack_bonus
    if _equipped_accessory != null:
        base_value += _equipped_accessory.attack_bonus
    return base_value

func get_defense() -> int:
    var base_value: int = unit_data.defense if unit_data != null else 0
    if _equipped_weapon != null:
        base_value += _equipped_weapon.defense_bonus
    if _equipped_armor != null:
        base_value += _equipped_armor.defense_bonus
    if _equipped_accessory != null:
        base_value += _equipped_accessory.defense_bonus
    return base_value

func get_movement() -> int:
    var base_value: int = unit_data.movement if unit_data != null else 3
    if _equipped_weapon != null:
        base_value += _equipped_weapon.movement_bonus
    if _equipped_armor != null:
        base_value += _equipped_armor.movement_bonus
    if _equipped_accessory != null:
        base_value += _equipped_accessory.movement_bonus
    return base_value

func get_attack_range() -> int:
    return unit_data.attack_range if unit_data != null else 1

func get_default_skill() -> SkillData:
    return unit_data.default_skill if unit_data != null else null

func get_equipped_accessory() -> AccessoryData:
    return _equipped_accessory

func get_equipped_weapon() -> WeaponData:
    return _equipped_weapon

func get_equipped_armor() -> ArmorData:
    return _equipped_armor

func _refresh_visuals() -> void:
    var base_color: Color = _get_base_color()
    if shadow != null:
        shadow.color = Color(0.0, 0.0, 0.0, 0.34 if _stealth_hidden else 0.18 if has_acted else 0.28)
    if halo != null:
        halo.color = _get_halo_color()
    if terrain_ring != null:
        terrain_ring.visible = _tile_defense_bonus > 0 and not _stealth_hidden
        terrain_ring.color = _get_terrain_ring_color()
    if mark_aura != null:
        mark_aura.visible = _boss_marked and not _stealth_hidden
        mark_aura.color = _get_mark_aura_color()
    if frame != null:
        frame.color = Color(0.090196, 0.098039, 0.121569, 0.94) if _stealth_hidden else _get_frame_color()
    if damage_flash != null:
        damage_flash.color = Color(1.0, 1.0, 1.0, 0.0)
    if marker != null:
        marker.color = Color(0.180392, 0.180392, 0.2, 0.88) if _stealth_hidden else base_color
    if accent != null:
        accent.color = Color(0.290196, 0.290196, 0.32549, 0.76) if _stealth_hidden else _get_accent_color()
    if faction_pip != null:
        faction_pip.visible = not _stealth_hidden
        faction_pip.color = _get_pip_color()
    if glyph_back != null:
        glyph_back.visible = not _stealth_hidden
        glyph_back.color = _get_glyph_back_color()
    if role_icon != null:
        role_icon.texture = _get_role_icon_texture()
        role_icon.modulate = _get_glyph_color()
        role_icon.visible = role_icon.texture != null and not _stealth_hidden
    if glyph_label != null:
        glyph_label.text = _get_role_glyph()
        glyph_label.add_theme_color_override("font_color", _get_glyph_color())
        glyph_label.visible = (role_icon == null or role_icon.texture == null) and not _stealth_hidden
    if inner != null:
        inner.color = Color(0.121569, 0.121569, 0.137255, 0.9) if _stealth_hidden else _get_inner_color()
    if token_art != null:
        token_art.texture = _get_token_art_texture()
        token_art.modulate = _get_token_art_color()
        token_art.visible = token_art.texture != null and not _stealth_hidden
    if name_plate_back != null:
        name_plate_back.color = _get_nameplate_color()
        name_plate_back.visible = _should_show_nameplate()

    if name_label != null:
        var unit_name: String = unit_data.display_name if unit_data != null else "Unit"
        name_label.text = unit_name
        name_label.visible = _should_show_nameplate()

    if telegraph_label != null:
        if _stealth_hidden:
            telegraph_label.text = "HIDDEN"
            telegraph_label.modulate = Color(0.792157, 0.835294, 0.960784, 0.78)
            telegraph_label.visible = true
        else:
            telegraph_label.text = "MARK" if _boss_marked else ""
            telegraph_label.modulate = Color(1.0, 0.529412, 0.764706, 0.95)
            telegraph_label.visible = _boss_marked

    if telegraph_icon != null:
        telegraph_icon.texture = TelegraphTextureLibrary.get_texture("mark") if _boss_marked else null
        telegraph_icon.visible = _boss_marked and not _stealth_hidden
    if mark_crosshair_h != null:
        mark_crosshair_h.visible = _boss_marked and not _stealth_hidden
        mark_crosshair_h.color = _get_mark_crosshair_color()
    if mark_crosshair_v != null:
        mark_crosshair_v.visible = _boss_marked and not _stealth_hidden
        mark_crosshair_v.color = _get_mark_crosshair_color()

    if hp_label != null:
        var max_hp: int = unit_data.max_hp if unit_data != null else current_hp
        hp_label.text = "%d/%d" % [current_hp, max_hp]
        hp_label.visible = not _stealth_hidden
        var hp_ratio: float = 1.0 if max_hp <= 0 else clampf(float(current_hp) / float(max_hp), 0.0, 1.0)
        if hp_bar_fill != null:
            hp_bar_fill.size.x = 48.0 * hp_ratio
            hp_bar_fill.color = _get_hp_bar_color(hp_ratio)
            hp_bar_fill.visible = not _stealth_hidden
    if hp_bar_back != null:
        hp_bar_back.visible = not _stealth_hidden
    if terrain_badge_back != null:
        terrain_badge_back.visible = _tile_defense_bonus > 0 and not _stealth_hidden
        terrain_badge_back.color = _get_terrain_badge_back_color()
    if terrain_badge_label != null:
        terrain_badge_label.visible = _tile_defense_bonus > 0 and not _stealth_hidden
        terrain_badge_label.text = "+%d" % _tile_defense_bonus if _tile_defense_bonus > 0 else ""
        terrain_badge_label.add_theme_color_override("font_color", _get_terrain_emphasis_color())
    if terrain_chevron_left != null:
        terrain_chevron_left.visible = _tile_defense_bonus > 0 and not _stealth_hidden
        terrain_chevron_left.color = _get_terrain_emphasis_color()
    if terrain_chevron_right != null:
        terrain_chevron_right.visible = _tile_defense_bonus > 0 and not _stealth_hidden
        terrain_chevron_right.color = _get_terrain_emphasis_color()

func _get_inner_color() -> Color:
    if _selected:
        return Color(0.231373, 0.160784, 0.054902, 0.94)
    if _attackable:
        return Color(0.34902, 0.101961, 0.0862745, 0.94)
    if faction == "ally":
        return Color(0.211765, 0.388235, 0.682353, 0.98)
    return Color(0.556863, 0.164706, 0.14902, 0.98)

func _get_frame_color() -> Color:
    if _selected:
        return Color(0.960784, 0.784314, 0.298039, 0.98)
    if _attackable:
        return Color(0.937255, 0.396078, 0.329412, 0.98)
    return Color(0.082353, 0.113725, 0.156863, 0.98)

func _get_accent_color() -> Color:
    if _selected:
        return Color(0.992157, 0.905882, 0.458824, 0.98)
    if _attackable:
        return Color(0.984314, 0.533333, 0.431373, 0.98)
    if faction == "ally":
        return Color(0.584314, 0.788235, 1.0, 0.98)
    return Color(0.952941, 0.521569, 0.494118, 0.98)

func _get_nameplate_color() -> Color:
    if _selected:
        return Color(0.145098, 0.117647, 0.0588235, 0.82)
    if _attackable:
        return Color(0.172549, 0.0705882, 0.0588235, 0.84)
    if faction == "ally":
        return Color(0.0745098, 0.121569, 0.211765, 0.84)
    return Color(0.211765, 0.0823529, 0.0784314, 0.84)

func _should_show_nameplate() -> bool:
    return not _stealth_hidden and (_selected or _attackable or _boss_marked)

func _get_pip_color() -> Color:
    if _selected:
        return Color(0.992157, 0.905882, 0.458824, 1.0)
    if _attackable:
        return Color(1.0, 0.623529, 0.533333, 1.0)
    if faction == "ally":
        return Color(0.686275, 0.847059, 1.0, 1.0)
    return Color(0.984314, 0.611765, 0.564706, 1.0)

func _get_glyph_back_color() -> Color:
    if _selected:
        return Color(0.243137, 0.180392, 0.0666667, 0.96)
    if _attackable:
        return Color(0.27451, 0.0901961, 0.0745098, 0.96)
    if faction == "ally":
        return Color(0.0588235, 0.101961, 0.180392, 0.94)
    return Color(0.180392, 0.0588235, 0.0588235, 0.94)

func _get_glyph_color() -> Color:
    if _selected:
        return Color(0.992157, 0.917647, 0.564706, 1.0)
    if _attackable:
        return Color(1.0, 0.709804, 0.611765, 1.0)
    if faction == "ally":
        return Color(0.862745, 0.92549, 1.0, 1.0)
    return Color(1.0, 0.835294, 0.8, 1.0)

func _get_role_glyph() -> String:
    if unit_data == null:
        return "--"

    var job_name: String = ""
    if unit_data.job_data != null:
        job_name = unit_data.job_data.display_name.to_lower()
    var resolved_class_name: String = ""
    var resolved_class_data = unit_data.get_class_data()
    if resolved_class_data != null:
        resolved_class_name = resolved_class_data.display_name.to_lower()
    var weapon_types: PackedStringArray = unit_data.get_allowed_weapon_types()
    var primary_weapon: String = ""
    if not weapon_types.is_empty():
        primary_weapon = String(weapon_types[0]).to_lower()

    if unit_data.is_boss:
        return "BX"
    if job_name.contains("medic"):
        return "MD"
    if resolved_class_name.contains("ranger") or primary_weapon == "bow":
        return "AR"
    if resolved_class_name.contains("mystic") or primary_weapon == "staff" or primary_weapon == "tome":
        return "MY"
    if resolved_class_name.contains("knight"):
        return "KN"
    if resolved_class_name.contains("vanguard"):
        return "VG"
    if primary_weapon == "sword":
        return "SW"
    if primary_weapon == "lance":
        return "LN"
    return "UN"

func _get_role_icon_texture() -> Texture2D:
    var file_name := ""
    var glyph := _get_role_glyph()
    match glyph:
        "BX":
            file_name = "boss.png"
        "MD":
            file_name = "medic.png"
        "AR":
            file_name = "ranger.png"
        "MY":
            file_name = "mystic.png"
        "VG":
            file_name = "vanguard.png"
        "KN", "SW", "LN":
            file_name = "knight.png"
        _:
            file_name = ""

    if file_name.is_empty():
        return null
    return _load_runtime_role_icon(file_name)

func _get_token_art_texture() -> Texture2D:
    var file_name := ""
    var glyph := _get_role_glyph()
    match glyph:
        "BX":
            file_name = "boss.png"
        "MD":
            file_name = "medic.png"
        "AR":
            file_name = "ranger.png"
        "MY":
            file_name = "mystic.png"
        "VG":
            file_name = "vanguard.png"
        "KN", "SW", "LN":
            file_name = "knight.png"
        _:
            file_name = ""
    if file_name.is_empty():
        return null
    return _load_runtime_token_art(file_name)

func _load_runtime_role_icon(file_name: String) -> Texture2D:
    return BattleArtCatalog.load_role_icon(file_name)

func _load_runtime_token_art(file_name: String) -> Texture2D:
    return BattleArtCatalog.load_token_art(file_name)

func _get_token_art_color() -> Color:
    if _selected:
        return Color(1.0, 0.952941, 0.772549, 0.92)
    if _attackable:
        return Color(1.0, 0.819608, 0.760784, 0.88)
    if faction == "ally":
        return Color(0.862745, 0.941176, 1.0, 0.82)
    return Color(1.0, 0.854902, 0.823529, 0.8)

func _get_halo_color() -> Color:
    if _stealth_hidden:
        return Color(0.141176, 0.141176, 0.160784, 0.22)
    if _boss_marked:
        return Color(0.960784, 0.435294, 0.701961, 0.34)
    if _selected:
        return Color(0.976471, 0.858824, 0.396078, 0.34)
    if _attackable:
        return Color(0.964706, 0.470588, 0.415686, 0.28)
    if faction == "ally":
        return Color(0.341176, 0.611765, 1.0, 0.2 if has_acted else 0.28)
    return Color(0.901961, 0.294118, 0.278431, 0.16 if has_acted else 0.24)

func _get_hp_bar_color(hp_ratio: float) -> Color:
    if hp_ratio <= 0.34:
        return Color(0.905882, 0.301961, 0.266667, 0.98)
    if hp_ratio <= 0.67:
        return Color(0.92549, 0.764706, 0.278431, 0.98)
    return Color(0.278431, 0.878431, 0.529412, 0.98)

func _get_terrain_ring_color() -> Color:
    match _tile_terrain_type:
        &"forest":
            return Color(0.513726, 0.901961, 0.67451, 0.2)
        &"cathedral", &"hymn":
            return Color(0.92549, 0.764706, 0.984314, 0.18)
        &"bell":
            return Color(0.756863, 0.878431, 1.0, 0.18)
        &"battery", &"floodgate", &"gate_control":
            return Color(1.0, 0.827451, 0.564706, 0.18)
        &"highground":
            return Color(1.0, 0.878431, 0.615686, 0.24)
        _:
            return Color(0.658824, 0.854902, 1.0, 0.16)

func _get_terrain_badge_back_color() -> Color:
    match _tile_terrain_type:
        &"forest":
            return Color(0.0705882, 0.14902, 0.109804, 0.86)
        &"cathedral", &"hymn":
            return Color(0.137255, 0.0823529, 0.164706, 0.84)
        &"bell":
            return Color(0.0745098, 0.113725, 0.184314, 0.84)
        &"battery", &"floodgate", &"gate_control":
            return Color(0.168627, 0.12549, 0.054902, 0.84)
        &"highground":
            return Color(0.196078, 0.14902, 0.0627451, 0.9)
        _:
            return Color(0.0862745, 0.12549, 0.168627, 0.82)

func _get_terrain_emphasis_color() -> Color:
    match _tile_terrain_type:
        &"forest", &"thicket":
            return Color(0.737255, 0.972549, 0.772549, 0.9)
        &"cathedral", &"hymn":
            return Color(0.945098, 0.811765, 1.0, 0.92)
        &"bell", &"corridor", &"keeper":
            return Color(0.823529, 0.901961, 1.0, 0.9)
        &"battery", &"floodgate", &"gate_control", &"bridge", &"keep":
            return Color(1.0, 0.882353, 0.647059, 0.92)
        &"highground":
            return Color(1.0, 0.921569, 0.709804, 0.98)
        _:
            return Color(0.921569, 0.960784, 1.0, 0.88)

func _play_mark_pulse() -> void:
    if mark_aura == null:
        return
    if _mark_pulse_tween != null and _mark_pulse_tween.is_running():
        _mark_pulse_tween.kill()
    mark_aura.scale = Vector2.ONE
    mark_aura.modulate = Color(1.0, 1.0, 1.0, 1.0)
    _mark_pulse_tween = create_tween()
    _mark_pulse_tween.tween_property(mark_aura, "scale", Vector2(1.14, 1.14), 0.16)
    _mark_pulse_tween.parallel().tween_property(mark_aura, "modulate:a", 0.52, 0.16)
    _mark_pulse_tween.tween_property(mark_aura, "scale", Vector2.ONE, 0.16)
    _mark_pulse_tween.parallel().tween_property(mark_aura, "modulate:a", 1.0, 0.16)

func _play_damage_flash() -> void:
    if damage_flash == null:
        return
    if _damage_flash_tween != null and _damage_flash_tween.is_running():
        _damage_flash_tween.kill()
    damage_flash.color = Color(1.0, 0.921569, 0.8, 0.78)
    _damage_flash_tween = create_tween()
    _damage_flash_tween.tween_property(damage_flash, "color:a", 0.0, 0.22)

func _get_mark_aura_color() -> Color:
    if _selected:
        return Color(1.0, 0.6, 0.792157, 0.2)
    return Color(0.988235, 0.494118, 0.741176, 0.14)

func _get_mark_crosshair_color() -> Color:
    return Color(1.0, 0.760784, 0.898039, 0.9)

func _get_base_color() -> Color:
    if _stealth_hidden:
        return Color(0.180392, 0.180392, 0.2, 0.9)
    if _selected:
        return Color(0.964706, 0.776471, 0.27451, 0.95)

    if _attackable:
        return Color(1.0, 0.52549, 0.301961, 0.9)

    var color: Color = Color(0.239216, 0.537255, 0.972549, 0.92) if faction == "ally" else Color(0.807843, 0.266667, 0.258824, 0.92)
    if has_acted:
        color = color.darkened(0.48)

    return color
