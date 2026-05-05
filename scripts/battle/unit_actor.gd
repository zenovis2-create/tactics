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
var current_mp: int = 0
var current_sp: int = 0
var max_mp: int = 0
var max_sp: int = 0
var grid_position: Vector2i = Vector2i.ZERO
var has_acted: bool = false

var _selected: bool = false
var _attackable: bool = false
var _boss_marked: bool = false
var _oblivion_stack_visual: int = 0
var _fear_turns: int = 0
var _charm_turns: int = 0
var _dot_turns: int = 0
var _mark_turns: int = 0
var _silence_turns: int = 0
var _seal_turns: int = 0
var _sleep_turns: int = 0
var _wake_caution_turns: int = 0
var _stealth_turns: int = 0
var _bond_support_ready: bool = false
var _bond_guard_ready: bool = false
var _tile_terrain_type: StringName = &"plain"
var _tile_defense_bonus: int = 0
var _equipped_accessory: AccessoryData
var _equipped_weapon: WeaponData
var _equipped_armor: ArmorData
var _mark_pulse_tween: Tween
var _damage_flash_tween: Tween
var _fear_shake_tween: Tween
var _status_pulse_tween: Tween
var _active_status_pulse_profile: String = ""
var _status_idle_tween: Tween
var _active_status_idle_profile: String = ""
var _status_accent_tween: Tween
var _active_status_accent_profile: String = ""
var _status_release_tween: Tween
var _active_status_release_profile: String = ""
var _status_text_tween: Tween
var _active_status_text_profile: String = ""
var _status_nameplate_tween: Tween
var _active_status_nameplate_profile: String = ""
var _status_icon_tween: Tween
var _active_status_icon_profile: String = ""
var _status_badge_text_tween: Tween
var _active_status_badge_text_profile: String = ""
var _status_afterglow_tween: Tween
var _active_status_afterglow_profile: String = ""
var _animating_attack: bool = false
var _defeat_cleanup_started: bool = false
var _character_sprite_frames: Dictionary = {}
var _character_sprite_state: String = ""
var _character_sprite_frame_index: int = 0
var _character_sprite_frame_elapsed: float = 0.0
var _movement_tween: Tween
var _character_pose_tween: Tween
var _character_fade_tween: Tween

const CHARACTER_FRAME_STEP_SECONDS := 0.09
const DEFAULT_CHARACTER_SPRITE_SCALE := Vector2(0.42, 0.42)
const DEFAULT_CHARACTER_SPRITE_POSITION := Vector2(2.0, 2.0)

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
@onready var character_visual_root: Node2D = $CharacterVisualRoot
@onready var character_sprite: Sprite2D = $CharacterVisualRoot/CharacterSprite
@onready var character_animation_player: AnimationPlayer = $CharacterVisualRoot/CharacterAnimationPlayer
@onready var token_art: TextureRect = $TokenArt
@onready var name_plate_back: ColorRect = $NamePlateBack
@onready var name_label: Label = $NameLabel
@onready var telegraph_label: Label = $TelegraphLabel
@onready var telegraph_icon: TextureRect = $TelegraphIcon
@onready var status_badge_back: ColorRect = $StatusBadgeBack
@onready var status_badge_icon: TextureRect = $StatusBadgeIcon
@onready var status_badge_label: Label = $StatusBadgeLabel
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

func _process(delta: float) -> void:
    _advance_character_sprite_frames(delta)

func setup_from_data(data: UnitData) -> void:
    unit_data = data
    faction = data.faction
    current_hp = data.max_hp
    _initialize_skill_resources()
    _defeat_cleanup_started = false
    _setup_character_visuals()
    _refresh_visuals()

func set_grid_position(cell: Vector2i, cell_size: Vector2i = Vector2i(64, 64), animate: bool = false, preserve_visual_position: bool = false) -> void:
    var previous_cell := grid_position
    grid_position = cell
    var destination_position := Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
    if _movement_tween != null and _movement_tween.is_running():
        _movement_tween.kill()
    _movement_tween = null
    if preserve_visual_position:
        pass
    elif animate and previous_cell != cell and position != destination_position:
        _movement_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        _movement_tween.tween_property(self, "position", destination_position, 0.22)
    else:
        position = destination_position
    if previous_cell != cell:
        _play_move_visual()

func set_selected(value: bool) -> void:
    _selected = value
    _refresh_visuals()

func set_attackable(value: bool) -> void:
    _attackable = value
    _refresh_visuals()

func set_boss_marked(value: bool) -> void:
    var was_marked: bool = _boss_marked
    var previous_primary_status: StringName = _get_primary_status_key()
    _boss_marked = value
    _refresh_visuals()
    _refresh_status_idle_animation()
    _refresh_status_accent_animation()
    _refresh_status_text_animation()
    _refresh_status_nameplate_animation()
    _refresh_status_icon_animation()
    _refresh_status_badge_text_animation()
    var next_primary_status: StringName = _get_primary_status_key()
    if value and not was_marked:
        _play_mark_pulse()
        _play_status_pulse()
    elif not value and was_marked and previous_primary_status != &"" and next_primary_status == &"":
        _play_status_release(String(previous_primary_status))
        _play_status_afterglow(String(previous_primary_status))

func set_status_visual_state(state: Dictionary) -> void:
    var previous_primary_status: StringName = _get_primary_status_key()
    var fear_was_active: bool = _fear_turns > 0
    var mark_was_active: bool = _mark_turns > 0
    _oblivion_stack_visual = maxi(int(state.get("oblivion_stack", 0)), 0)
    _fear_turns = maxi(int(state.get("fear_turns", 0)), 0)
    _charm_turns = maxi(int(state.get("charm_turns", 0)), 0)
    _dot_turns = maxi(int(state.get("dot_turns", 0)), 0)
    _mark_turns = maxi(int(state.get("mark_turns", 0)), 0)
    _silence_turns = maxi(int(state.get("silence_turns", 0)), 0)
    _seal_turns = maxi(int(state.get("seal_turns", 0)), 0)
    _sleep_turns = maxi(int(state.get("sleep_turns", 0)), 0)
    _wake_caution_turns = maxi(int(state.get("wake_caution_turns", 0)), 0)
    _stealth_turns = maxi(int(state.get("stealth_turns", 0)), 0)
    _refresh_visuals()
    _refresh_status_idle_animation()
    _refresh_status_accent_animation()
    _refresh_status_text_animation()
    _refresh_status_nameplate_animation()
    _refresh_status_icon_animation()
    _refresh_status_badge_text_animation()
    var next_primary_status: StringName = _get_primary_status_key()
    if _fear_turns > 0 and not fear_was_active:
        _start_fear_shake()
    elif _fear_turns <= 0 and fear_was_active:
        _stop_fear_shake()
    if _mark_turns > 0 and not mark_was_active:
        _play_mark_pulse()
    if next_primary_status != &"" and next_primary_status != previous_primary_status:
        _play_status_pulse()
    elif previous_primary_status != &"" and next_primary_status == &"":
        _play_status_release(String(previous_primary_status))
        _play_status_afterglow(String(previous_primary_status))

func set_bond_visual_state(state: Dictionary) -> void:
    _bond_support_ready = bool(state.get("support_ready", false))
    _bond_guard_ready = bool(state.get("guard_ready", false))
    _refresh_visuals()

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
        _play_character_animation("defeat")
        _play_defeat_pose_feedback()
        if not _defeat_cleanup_started:
            _defeat_cleanup_started = true
            _queue_cleanup_after_delay(0.35)
    else:
        _play_character_animation("hit")
        _play_hit_pose_feedback()
        _queue_return_to_idle_after_delay(0.28)


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
    _play_character_animation("attack")
    var original_pos: Vector2 = position
    var direction: Vector2 = (Vector2(target_pos) * cell_size - original_pos).normalized()
    var lunge_distance: float = cell_size * 0.4
    var target_offset: Vector2 = direction * lunge_distance

    var tw := create_tween().set_trans(Tween.TRANS_SINE)
    tw.tween_property(self, "position", original_pos + target_offset, 0.12)
    tw.tween_callback(attack_anim_hit.emit)
    tw.tween_property(self, "position", original_pos, 0.10)
    tw.tween_callback(func():
        _animating_attack = false
        _play_character_animation("idle")
    )


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

func can_afford_skill_cost(skill: SkillData) -> bool:
    if skill == null or not skill.has_resource_cost():
        return true
    return current_mp >= skill.mp_cost and current_sp >= skill.sp_cost

func spend_skill_cost(skill: SkillData) -> bool:
    if not can_afford_skill_cost(skill):
        return false
    current_mp = maxi(current_mp - skill.mp_cost, 0)
    current_sp = maxi(current_sp - skill.sp_cost, 0)
    return true

func set_resource_values(next_mp: int, next_sp: int) -> void:
    current_mp = clampi(next_mp, 0, max_mp)
    current_sp = clampi(next_sp, 0, max_sp)

func get_resource_snapshot() -> Dictionary:
    return {
        "current_mp": current_mp,
        "max_mp": max_mp,
        "current_sp": current_sp,
        "max_sp": max_sp
    }

func get_equipped_accessory() -> AccessoryData:
    return _equipped_accessory

func get_equipped_weapon() -> WeaponData:
    return _equipped_weapon

func get_equipped_armor() -> ArmorData:
    return _equipped_armor

func get_status_visual_snapshot() -> Dictionary:
    var primary_status: String = String(_get_primary_status_key())
    var telegraph_texture: Texture2D = _get_status_telegraph_texture()
    var status_badge_icon_texture: Texture2D = _get_status_badge_icon_texture()
    return {
        "primary_status": primary_status,
        "oblivion_stack": _oblivion_stack_visual,
        "fear_turns": _fear_turns,
        "charm_turns": _charm_turns,
        "dot_turns": _dot_turns,
        "mark_turns": _mark_turns,
        "silence_turns": _silence_turns,
        "seal_turns": _seal_turns,
        "sleep_turns": _sleep_turns,
        "wake_caution_turns": _wake_caution_turns,
        "stealth_turns": _stealth_turns,
        "bond_support_ready": _bond_support_ready,
        "bond_guard_ready": _bond_guard_ready,
        "current_mp": current_mp,
        "max_mp": max_mp,
        "current_sp": current_sp,
        "max_sp": max_sp,
        "telegraph_text": _get_status_telegraph_text(),
        "telegraph_icon_visible": telegraph_texture != null,
        "status_badge_visible": _should_show_status_badge(),
        "status_badge_text": _get_status_badge_text(),
        "status_badge_icon_visible": status_badge_icon_texture != null,
        "status_badge_icon_kind": _get_status_badge_icon_kind(),
        "nameplate_visible": _should_show_nameplate(),
        "crosshair_visible": _should_show_mark_crosshair(),
        "fear_shake_active": _fear_shake_tween != null and _fear_shake_tween.is_running(),
        "status_pulse_active": _status_pulse_tween != null and _status_pulse_tween.is_running(),
        "status_pulse_profile": _active_status_pulse_profile,
        "status_idle_active": _status_idle_tween != null and _status_idle_tween.is_running(),
        "status_idle_profile": _active_status_idle_profile,
        "status_accent_active": _status_accent_tween != null and _status_accent_tween.is_running(),
        "status_accent_profile": _active_status_accent_profile,
        "status_release_active": _status_release_tween != null and _status_release_tween.is_running(),
        "status_release_profile": _active_status_release_profile,
        "status_afterglow_active": _status_afterglow_tween != null and _status_afterglow_tween.is_running(),
        "status_afterglow_profile": _active_status_afterglow_profile,
        "status_text_active": _status_text_tween != null and _status_text_tween.is_running(),
        "status_text_profile": _active_status_text_profile,
        "status_nameplate_active": _status_nameplate_tween != null and _status_nameplate_tween.is_running(),
        "status_nameplate_profile": _active_status_nameplate_profile,
        "status_icon_active": _status_icon_tween != null and _status_icon_tween.is_running(),
        "status_icon_profile": _active_status_icon_profile,
        "status_badge_text_active": _status_badge_text_tween != null and _status_badge_text_tween.is_running(),
        "status_badge_text_profile": _active_status_badge_text_profile,
        "status_motion_stack": _build_status_motion_stack(),
        "status_motion_signature": _build_status_motion_signature()
    }

func _build_status_motion_stack() -> Array[String]:
    var entries: Array[String] = []
    _append_motion_stack_entry(entries, "pulse", _status_pulse_tween, _active_status_pulse_profile)
    _append_motion_stack_entry(entries, "idle", _status_idle_tween, _active_status_idle_profile)
    _append_motion_stack_entry(entries, "accent", _status_accent_tween, _active_status_accent_profile)
    _append_motion_stack_entry(entries, "release", _status_release_tween, _active_status_release_profile)
    _append_motion_stack_entry(entries, "afterglow", _status_afterglow_tween, _active_status_afterglow_profile)
    _append_motion_stack_entry(entries, "text", _status_text_tween, _active_status_text_profile)
    _append_motion_stack_entry(entries, "nameplate", _status_nameplate_tween, _active_status_nameplate_profile)
    _append_motion_stack_entry(entries, "icon", _status_icon_tween, _active_status_icon_profile)
    _append_motion_stack_entry(entries, "badge_text", _status_badge_text_tween, _active_status_badge_text_profile)
    return entries

func _append_motion_stack_entry(entries: Array[String], label: String, tween: Tween, profile: String) -> void:
    if profile.is_empty() or tween == null or not tween.is_running():
        return
    entries.append("%s:%s" % [label, profile])

func _build_status_motion_signature() -> String:
    var primary_status: String = String(_get_primary_status_key())
    var entries: Array[String] = []
    if not primary_status.is_empty():
        entries.append(primary_status)
    for entry in _build_status_motion_stack():
        entries.append(String(entry))
    return "|".join(entries)

func _initialize_skill_resources() -> void:
    var highest_mp: int = 0
    var highest_sp: int = 0
    if unit_data != null:
        for skill in unit_data.get_all_skills():
            if skill == null:
                continue
            highest_mp = maxi(highest_mp, skill.mp_cost)
            highest_sp = maxi(highest_sp, skill.sp_cost)
    max_mp = highest_mp + 4 if highest_mp > 0 else 0
    max_sp = highest_sp + 3 if highest_sp > 0 else 0
    current_mp = max_mp
    current_sp = max_sp

func _refresh_visuals() -> void:
    var base_color: Color = _get_base_color()
    if shadow != null:
        shadow.color = Color(0.0, 0.0, 0.0, 0.18 if has_acted else 0.28)
    if halo != null:
        halo.color = _get_halo_color()
    if terrain_ring != null:
        terrain_ring.visible = _tile_defense_bonus > 0
        terrain_ring.color = _get_terrain_ring_color()
    if mark_aura != null:
        mark_aura.visible = _boss_marked or _mark_turns > 0
        mark_aura.color = _get_mark_aura_color()
    if frame != null:
        frame.color = _get_frame_color()
    if damage_flash != null:
        damage_flash.color = Color(1.0, 1.0, 1.0, 0.0)
    if marker != null:
        marker.color = base_color
    if accent != null:
        accent.color = _get_accent_color()
    if faction_pip != null:
        faction_pip.color = _get_pip_color()
    if glyph_back != null:
        glyph_back.color = _get_glyph_back_color()
    if role_icon != null:
        role_icon.texture = _get_role_icon_texture()
        role_icon.modulate = _get_glyph_color()
        role_icon.visible = role_icon.texture != null
    if glyph_label != null:
        glyph_label.text = _get_role_glyph()
        glyph_label.add_theme_color_override("font_color", _get_glyph_color())
        glyph_label.visible = role_icon == null or role_icon.texture == null
    if inner != null:
        inner.color = _get_inner_color()
    if token_art != null:
        token_art.texture = _get_token_art_texture()
        token_art.modulate = _get_visual_character_modulate()
        token_art.visible = token_art.texture != null and not _has_character_visuals()
    if character_sprite != null:
        character_sprite.modulate = _get_visual_character_modulate()
    if name_plate_back != null:
        name_plate_back.color = _get_nameplate_color()
        name_plate_back.visible = _should_show_nameplate()

    if name_label != null:
        var unit_name: String = unit_data.display_name if unit_data != null else "Unit"
        name_label.text = unit_name
        name_label.visible = _should_show_nameplate()

    if telegraph_label != null:
        telegraph_label.text = _get_status_telegraph_text()
        telegraph_label.modulate = _get_status_telegraph_color()

    if telegraph_icon != null:
        telegraph_icon.texture = _get_status_telegraph_texture()
        telegraph_icon.visible = telegraph_icon.texture != null
    if status_badge_back != null:
        status_badge_back.visible = _should_show_status_badge()
        status_badge_back.color = _get_status_badge_back_color()
    if status_badge_icon != null:
        status_badge_icon.texture = _get_status_badge_icon_texture()
        status_badge_icon.visible = _should_show_status_badge() and status_badge_icon.texture != null
    if status_badge_label != null:
        status_badge_label.visible = _should_show_status_badge()
        status_badge_label.text = _get_status_badge_text()
        status_badge_label.add_theme_color_override("font_color", _get_status_badge_text_color())
    if mark_crosshair_h != null:
        mark_crosshair_h.visible = _should_show_mark_crosshair()
        mark_crosshair_h.color = _get_mark_crosshair_color()
    if mark_crosshair_v != null:
        mark_crosshair_v.visible = _should_show_mark_crosshair()
        mark_crosshair_v.color = _get_mark_crosshair_color()

    if hp_label != null:
        var max_hp: int = unit_data.max_hp if unit_data != null else current_hp
        hp_label.text = "%d/%d" % [current_hp, max_hp]
        var hp_ratio: float = 1.0 if max_hp <= 0 else clampf(float(current_hp) / float(max_hp), 0.0, 1.0)
        if hp_bar_fill != null:
            hp_bar_fill.size.x = 48.0 * hp_ratio
            hp_bar_fill.color = _get_hp_bar_color(hp_ratio)
    if terrain_badge_back != null:
        terrain_badge_back.visible = _tile_defense_bonus > 0
        terrain_badge_back.color = _get_terrain_badge_back_color()
    if terrain_badge_label != null:
        terrain_badge_label.visible = _tile_defense_bonus > 0
        terrain_badge_label.text = "+%d" % _tile_defense_bonus if _tile_defense_bonus > 0 else ""
        terrain_badge_label.add_theme_color_override("font_color", _get_terrain_emphasis_color())
    if terrain_chevron_left != null:
        terrain_chevron_left.visible = _tile_defense_bonus > 0
        terrain_chevron_left.color = _get_terrain_emphasis_color()
    if terrain_chevron_right != null:
        terrain_chevron_right.visible = _tile_defense_bonus > 0
        terrain_chevron_right.color = _get_terrain_emphasis_color()

func _get_inner_color() -> Color:
    if _selected:
        return Color(0.231373, 0.160784, 0.054902, 0.94)
    if _attackable:
        return Color(0.34902, 0.101961, 0.0862745, 0.94)
    match _get_primary_status_key():
        &"charm":
            return Color(0.356863, 0.101961, 0.14902, 0.94)
        &"fear":
            return Color(0.270588, 0.129412, 0.0941176, 0.94)
        &"dot":
            return Color(0.321569, 0.219608, 0.0705882, 0.94)
        &"oblivion":
            return Color(0.227451, 0.176471, 0.329412, 0.94)
    if faction == "ally":
        return Color(0.211765, 0.388235, 0.682353, 0.98)
    return Color(0.556863, 0.164706, 0.14902, 0.98)

func _get_frame_color() -> Color:
    if _selected:
        return Color(0.960784, 0.784314, 0.298039, 0.98)
    if _attackable:
        return Color(0.937255, 0.396078, 0.329412, 0.98)
    if _bond_guard_ready:
        return Color(0.52549, 0.941176, 0.709804, 0.98)
    if _bond_support_ready:
        return Color(0.4, 0.847059, 1.0, 0.98)
    match _get_primary_status_key():
        &"charm":
            return Color(0.941176, 0.266667, 0.364706, 0.98)
        &"fear":
            return Color(0.823529, 0.435294, 0.25098, 0.98)
        &"dot":
            return Color(0.941176, 0.760784, 0.278431, 0.98)
        &"mark":
            return Color(0.968627, 0.756863, 0.505882, 0.98)
        &"oblivion":
            return Color(0.615686, 0.470588, 0.894118, 0.98)
    return Color(0.082353, 0.113725, 0.156863, 0.98)

func _get_accent_color() -> Color:
    if _selected:
        return Color(0.992157, 0.905882, 0.458824, 0.98)
    if _attackable:
        return Color(0.984314, 0.533333, 0.431373, 0.98)
    if _bond_guard_ready:
        return Color(0.682353, 1.0, 0.815686, 0.98)
    if _bond_support_ready:
        return Color(0.643137, 0.92549, 1.0, 0.98)
    match _get_primary_status_key():
        &"charm":
            return Color(1.0, 0.580392, 0.662745, 0.98)
        &"fear":
            return Color(0.964706, 0.67451, 0.458824, 0.98)
        &"dot":
            return Color(1.0, 0.870588, 0.423529, 0.98)
        &"mark":
            return Color(1.0, 0.847059, 0.592157, 0.98)
        &"oblivion":
            return Color(0.764706, 0.678431, 1.0, 0.98)
    if faction == "ally":
        return Color(0.584314, 0.788235, 1.0, 0.98)
    return Color(0.952941, 0.521569, 0.494118, 0.98)

func _get_nameplate_color() -> Color:
    if _selected:
        return Color(0.145098, 0.117647, 0.0588235, 0.82)
    if _attackable:
        return Color(0.172549, 0.0705882, 0.0588235, 0.84)
    if _bond_guard_ready:
        return Color(0.0705882, 0.176471, 0.117647, 0.88)
    if _bond_support_ready:
        return Color(0.0627451, 0.14902, 0.211765, 0.88)
    match _get_primary_status_key():
        &"charm":
            return Color(0.266667, 0.0862745, 0.109804, 0.88)
        &"fear":
            return Color(0.211765, 0.105882, 0.0627451, 0.88)
        &"dot":
            return Color(0.247059, 0.164706, 0.054902, 0.88)
        &"mark":
            return Color(0.25098, 0.160784, 0.0666667, 0.88)
        &"oblivion":
            return Color(0.129412, 0.0941176, 0.2, 0.88)
    if faction == "ally":
        return Color(0.0745098, 0.121569, 0.211765, 0.84)
    return Color(0.211765, 0.0823529, 0.0784314, 0.84)

func _should_show_nameplate() -> bool:
    return _selected or _attackable or _boss_marked or _has_visual_status() or _bond_support_ready or _bond_guard_ready

func _get_pip_color() -> Color:
    if _selected:
        return Color(0.992157, 0.905882, 0.458824, 1.0)
    if _attackable:
        return Color(1.0, 0.623529, 0.533333, 1.0)
    if _bond_guard_ready:
        return Color(0.737255, 1.0, 0.854902, 1.0)
    if _bond_support_ready:
        return Color(0.760784, 0.929412, 1.0, 1.0)
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

func _has_character_visuals() -> bool:
    return character_visual_root != null and character_visual_root.visible and character_sprite != null and character_sprite.texture != null

func _setup_character_visuals() -> void:
    if character_visual_root == null or character_sprite == null or character_animation_player == null or unit_data == null:
        return
    _character_sprite_frames = {
        "idle": _load_character_sprite_frames("idle"),
        "move": _load_character_sprite_frames("move"),
        "attack": _load_character_sprite_frames("attack"),
    }
    var idle_frames: Array[Texture2D] = _character_sprite_frames.get("idle", [])
    if not idle_frames.is_empty():
        character_sprite.texture = idle_frames[0]
        character_visual_root.visible = true
        _reset_character_sprite_pose()
        _character_sprite_state = "idle"
        _character_sprite_frame_index = 0
        _character_sprite_frame_elapsed = 0.0
        _ensure_character_animation_library()
        _play_character_animation("idle")
        return

    var character_file_name := "%s.png" % String(unit_data.display_name).to_lower()
    var texture := BattleArtCatalog.load_character_token_art(character_file_name)
    if texture == null:
        character_visual_root.visible = false
        character_sprite.texture = null
        return
    character_sprite.texture = texture
    character_visual_root.visible = true
    _reset_character_sprite_pose()
    _character_sprite_state = ""
    _character_sprite_frame_index = 0
    _character_sprite_frame_elapsed = 0.0
    _ensure_character_animation_library()
    _play_character_animation("idle")

func _load_character_sprite_frames(state: String) -> Array[Texture2D]:
    var lookup_names := [
        String(unit_data.unit_id),
        String(unit_data.display_name),
    ]
    for lookup_name in lookup_names:
        if lookup_name.is_empty():
            continue
        var frames := BattleArtCatalog.load_character_sprite_frames(lookup_name, state)
        if not frames.is_empty():
            return frames
    return []

func _ensure_character_animation_library() -> void:
    if character_animation_player == null:
        return
    var library: AnimationLibrary = null
    if character_animation_player.has_animation_library(""):
        library = character_animation_player.get_animation_library("")
    if library == null:
        library = AnimationLibrary.new()
        character_animation_player.add_animation_library("", library)
    for animation_name in ["idle", "move", "attack", "hit", "defeat"]:
        if library.has_animation(animation_name):
            continue
        var animation := Animation.new()
        animation.length = 0.2 if animation_name in ["attack", "hit"] else 0.4
        if animation_name == "idle":
            animation.length = 1.0
            animation.loop_mode = Animation.LOOP_LINEAR
        elif animation_name == "move":
            animation.length = 0.6
            animation.loop_mode = Animation.LOOP_LINEAR
        library.add_animation(animation_name, animation)

func _play_character_animation(animation_name: String) -> void:
    if character_animation_player == null or not _has_character_visuals():
        return
    if not character_animation_player.has_animation(animation_name):
        return
    character_animation_player.play(animation_name)
    _set_character_sprite_state(animation_name)

func _queue_return_to_idle_after_delay(delay_seconds: float) -> void:
    if not _has_character_visuals():
        return
    var tree := get_tree()
    if tree == null:
        return
    tree.create_timer(delay_seconds).timeout.connect(func():
        if is_inside_tree() and not is_defeated():
            _play_character_animation("idle")
    )

func _queue_cleanup_after_delay(delay_seconds: float) -> void:
    var tree := get_tree()
    if tree == null:
        queue_free()
        return
    tree.create_timer(delay_seconds).timeout.connect(func():
        if is_inside_tree():
            queue_free()
    )

func _play_hit_pose_feedback() -> void:
    if character_sprite == null or not _has_character_visuals():
        return
    if _character_pose_tween != null and _character_pose_tween.is_running():
        _character_pose_tween.kill()
    _reset_character_sprite_pose()
    var rotation_sign := -1.0 if faction == "ally" else 1.0
    _character_pose_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _character_pose_tween.parallel().tween_property(character_sprite, "scale", Vector2(0.48, 0.34), 0.06)
    _character_pose_tween.parallel().tween_property(character_sprite, "rotation_degrees", 8.0 * rotation_sign, 0.06)
    _character_pose_tween.parallel().tween_property(character_sprite, "position", DEFAULT_CHARACTER_SPRITE_POSITION + Vector2(-4.0 * rotation_sign, 2.0), 0.06)
    _character_pose_tween.tween_interval(0.03)
    _character_pose_tween.parallel().tween_property(character_sprite, "scale", DEFAULT_CHARACTER_SPRITE_SCALE, 0.16)
    _character_pose_tween.parallel().tween_property(character_sprite, "rotation_degrees", 0.0, 0.16)
    _character_pose_tween.parallel().tween_property(character_sprite, "position", DEFAULT_CHARACTER_SPRITE_POSITION, 0.16)

func _play_defeat_pose_feedback() -> void:
    if character_sprite == null or not _has_character_visuals():
        return
    if _character_pose_tween != null and _character_pose_tween.is_running():
        _character_pose_tween.kill()
    if _character_fade_tween != null and _character_fade_tween.is_running():
        _character_fade_tween.kill()
    _reset_character_sprite_pose()
    var rotation_sign := -1.0 if faction == "ally" else 1.0
    _character_pose_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _character_pose_tween.parallel().tween_property(character_sprite, "rotation_degrees", 88.0 * rotation_sign, 0.22)
    _character_pose_tween.parallel().tween_property(character_sprite, "scale", Vector2(0.32, 0.32), 0.22)
    _character_pose_tween.parallel().tween_property(character_sprite, "position", DEFAULT_CHARACTER_SPRITE_POSITION + Vector2(0.0, 10.0), 0.22)
    _character_fade_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _character_fade_tween.tween_property(character_sprite, "modulate:a", 0.45, 0.22)

func _reset_character_sprite_pose() -> void:
    if character_sprite == null:
        return
    character_sprite.scale = DEFAULT_CHARACTER_SPRITE_SCALE
    character_sprite.position = DEFAULT_CHARACTER_SPRITE_POSITION
    character_sprite.rotation_degrees = 0.0
    character_sprite.modulate.a = 1.0

func _play_move_visual() -> void:
    if not _has_character_visuals():
        return
    var move_frames: Array[Texture2D] = _character_sprite_frames.get("move", [])
    if move_frames.is_empty():
        return
    _play_character_animation("move")
    var tree := get_tree()
    if tree == null:
        return
    tree.create_timer(0.18).timeout.connect(func():
        if is_inside_tree() and not is_defeated() and not _animating_attack:
            _play_character_animation("idle")
    )

func play_path_walk_visual(path: Array, cell_size: Vector2i) -> void:
    if path.size() <= 1:
        return
    if _movement_tween != null and _movement_tween.is_running():
        _movement_tween.kill()
    _movement_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    for index in range(1, path.size()):
        var cell: Vector2i = path[index]
        var step_position := Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
        _movement_tween.tween_property(self, "position", step_position, 0.10)

func _set_character_sprite_state(animation_name: String) -> void:
    if _character_sprite_frames.is_empty():
        return
    var resolved_state := animation_name
    if not _character_sprite_frames.has(resolved_state) or (_character_sprite_frames.get(resolved_state, []) as Array).is_empty():
        resolved_state = "idle"
    var frames: Array[Texture2D] = _character_sprite_frames.get(resolved_state, [])
    if frames.is_empty():
        return
    _character_sprite_state = resolved_state
    _character_sprite_frame_index = 0
    _character_sprite_frame_elapsed = 0.0
    if character_sprite != null:
        character_sprite.texture = frames[0]

func _advance_character_sprite_frames(delta: float) -> void:
    if not _has_character_visuals():
        return
    if _character_sprite_state.is_empty():
        return
    var frames: Array[Texture2D] = _character_sprite_frames.get(_character_sprite_state, [])
    if frames.size() <= 1:
        return
    _character_sprite_frame_elapsed += delta
    if _character_sprite_frame_elapsed < CHARACTER_FRAME_STEP_SECONDS:
        return
    _character_sprite_frame_elapsed = 0.0
    var next_index := _character_sprite_frame_index + 1
    var loop_state := _character_sprite_state == "idle" or _character_sprite_state == "move"
    if next_index >= frames.size():
        next_index = 0 if loop_state else frames.size() - 1
    _character_sprite_frame_index = next_index
    if character_sprite != null:
        character_sprite.texture = frames[_character_sprite_frame_index]

func _get_token_art_color() -> Color:
    if _selected:
        return Color(1.0, 0.952941, 0.772549, 0.92)
    if _attackable:
        return Color(1.0, 0.819608, 0.760784, 0.88)
    if faction == "ally":
        return Color(0.862745, 0.941176, 1.0, 0.82)
    return Color(1.0, 0.854902, 0.823529, 0.8)

func _get_halo_color() -> Color:
    if _boss_marked:
        return Color(0.960784, 0.435294, 0.701961, 0.34)
    if _bond_guard_ready:
        return Color(0.384314, 0.937255, 0.682353, 0.26)
    if _bond_support_ready:
        return Color(0.376471, 0.760784, 1.0, 0.26)
    match _get_primary_status_key():
        &"charm":
            return Color(0.988235, 0.333333, 0.458824, 0.28)
        &"fear":
            return Color(0.87451, 0.509804, 0.27451, 0.24)
        &"dot":
            return Color(1.0, 0.741176, 0.266667, 0.24)
        &"mark":
            return Color(1.0, 0.772549, 0.490196, 0.22)
        &"oblivion":
            return Color(0.670588, 0.478431, 0.92549, 0.26)
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

func _play_status_pulse() -> void:
    if _status_pulse_tween != null and _status_pulse_tween.is_running():
        _status_pulse_tween.kill()
    _active_status_pulse_profile = _get_status_pulse_profile()
    if status_badge_back != null:
        status_badge_back.modulate = Color(1.0, 1.0, 1.0, 1.0)
        status_badge_back.scale = Vector2.ONE
    if status_badge_icon != null:
        status_badge_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
        status_badge_icon.scale = Vector2.ONE
    if telegraph_icon != null:
        telegraph_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
        telegraph_icon.scale = Vector2.ONE
    var badge_peak := Vector2(1.08, 1.08)
    var icon_peak := Vector2(1.16, 1.16)
    var telegraph_peak := Vector2(1.08, 1.08)
    var intro_duration := 0.12
    var settle_duration := 0.16
    match _active_status_pulse_profile:
        "fear":
            badge_peak = Vector2(1.12, 1.02)
            icon_peak = Vector2(1.2, 0.98)
            telegraph_peak = Vector2(1.12, 1.02)
            intro_duration = 0.08
            settle_duration = 0.12
        "charm":
            badge_peak = Vector2(1.06, 1.12)
            icon_peak = Vector2(1.1, 1.18)
            telegraph_peak = Vector2(1.06, 1.12)
            intro_duration = 0.14
            settle_duration = 0.18
        "dot":
            badge_peak = Vector2(1.04, 1.04)
            icon_peak = Vector2(1.22, 1.22)
            telegraph_peak = Vector2(1.04, 1.04)
            intro_duration = 0.07
            settle_duration = 0.1
        "oblivion":
            badge_peak = Vector2(1.1, 1.1)
            icon_peak = Vector2(1.14, 1.14)
            telegraph_peak = Vector2(1.12, 1.12)
            intro_duration = 0.16
            settle_duration = 0.2
        "mark", "boss_mark":
            badge_peak = Vector2(1.08, 1.08)
            icon_peak = Vector2(1.18, 1.18)
            telegraph_peak = Vector2(1.1, 1.1)
    _status_pulse_tween = create_tween()
    if status_badge_back != null:
        _status_pulse_tween.parallel().tween_property(status_badge_back, "scale", badge_peak, intro_duration)
        _status_pulse_tween.parallel().tween_property(status_badge_back, "modulate:a", 0.78, intro_duration)
    if status_badge_icon != null:
        _status_pulse_tween.parallel().tween_property(status_badge_icon, "scale", icon_peak, intro_duration)
    if telegraph_icon != null and telegraph_icon.visible:
        _status_pulse_tween.parallel().tween_property(telegraph_icon, "scale", telegraph_peak, intro_duration)
    _status_pulse_tween.tween_interval(0.02)
    if status_badge_back != null:
        _status_pulse_tween.parallel().tween_property(status_badge_back, "scale", Vector2.ONE, settle_duration)
        _status_pulse_tween.parallel().tween_property(status_badge_back, "modulate:a", 1.0, settle_duration)
    if status_badge_icon != null:
        _status_pulse_tween.parallel().tween_property(status_badge_icon, "scale", Vector2.ONE, settle_duration)
    if telegraph_icon != null and telegraph_icon.visible:
        _status_pulse_tween.parallel().tween_property(telegraph_icon, "scale", Vector2.ONE, settle_duration)

func _get_status_pulse_profile() -> String:
    match _get_primary_status_key():
        &"fear":
            return "fear"
        &"charm":
            return "charm"
        &"dot":
            return "dot"
        &"mark":
            return "mark"
        &"boss_mark":
            return "boss_mark"
        &"oblivion":
            return "oblivion"
        _:
            return ""

func _refresh_status_idle_animation() -> void:
    var next_profile := _get_status_idle_profile()
    if next_profile == _active_status_idle_profile and _status_idle_tween != null and _status_idle_tween.is_running():
        return
    _stop_status_idle_animation()
    _active_status_idle_profile = next_profile
    if next_profile.is_empty():
        return
    _start_status_idle_animation(next_profile)

func _get_status_idle_profile() -> String:
    match _get_primary_status_key():
        &"charm":
            return "charm"
        &"dot":
            return "dot"
        &"oblivion":
            return "oblivion"
        &"mark":
            return "mark"
        &"boss_mark":
            return "boss_mark"
        _:
            return ""

func _refresh_status_accent_animation() -> void:
    var next_profile := _get_status_accent_profile()
    if next_profile == _active_status_accent_profile and _status_accent_tween != null and _status_accent_tween.is_running():
        return
    _stop_status_accent_animation()
    _active_status_accent_profile = next_profile
    if next_profile.is_empty():
        return
    _start_status_accent_animation(next_profile)

func _get_status_accent_profile() -> String:
    match _get_primary_status_key():
        &"charm":
            return "charm"
        &"dot":
            return "dot"
        &"oblivion":
            return "oblivion"
        &"mark":
            return "mark"
        &"boss_mark":
            return "boss_mark"
        _:
            return ""

func _refresh_status_text_animation() -> void:
    var next_profile := _get_status_text_profile()
    if next_profile == _active_status_text_profile and _status_text_tween != null and _status_text_tween.is_running():
        return
    _stop_status_text_animation()
    _active_status_text_profile = next_profile
    if next_profile.is_empty():
        return
    _start_status_text_animation(next_profile)

func _get_status_text_profile() -> String:
    match _get_primary_status_key():
        &"charm":
            return "charm"
        &"dot":
            return "dot"
        &"oblivion":
            return "oblivion"
        &"mark":
            return "mark"
        &"boss_mark":
            return "boss_mark"
        _:
            return ""

func _refresh_status_nameplate_animation() -> void:
    var next_profile := _get_status_nameplate_profile()
    if next_profile == _active_status_nameplate_profile and _status_nameplate_tween != null and _status_nameplate_tween.is_running():
        return
    _stop_status_nameplate_animation()
    _active_status_nameplate_profile = next_profile
    if next_profile.is_empty():
        return
    _start_status_nameplate_animation(next_profile)

func _get_status_nameplate_profile() -> String:
    match _get_primary_status_key():
        &"charm":
            return "charm"
        &"oblivion":
            return "oblivion"
        &"mark":
            return "mark"
        &"boss_mark":
            return "boss_mark"
        _:
            return ""

func _refresh_status_icon_animation() -> void:
    var next_profile := _get_status_icon_profile()
    if next_profile == _active_status_icon_profile and _status_icon_tween != null and _status_icon_tween.is_running():
        return
    _stop_status_icon_animation()
    _active_status_icon_profile = next_profile
    if next_profile.is_empty():
        return
    _start_status_icon_animation(next_profile)

func _get_status_icon_profile() -> String:
    match _get_primary_status_key():
        &"charm":
            return "charm"
        &"oblivion":
            return "oblivion"
        &"mark":
            return "mark"
        &"boss_mark":
            return "boss_mark"
        _:
            return ""

func _refresh_status_badge_text_animation() -> void:
    var next_profile := _get_status_badge_text_profile()
    if next_profile == _active_status_badge_text_profile and _status_badge_text_tween != null and _status_badge_text_tween.is_running():
        return
    _stop_status_badge_text_animation()
    _active_status_badge_text_profile = next_profile
    if next_profile.is_empty():
        return
    _start_status_badge_text_animation(next_profile)

func _get_status_badge_text_profile() -> String:
    match _get_primary_status_key():
        &"charm":
            return "charm"
        &"oblivion":
            return "oblivion"
        &"mark":
            return "mark"
        &"boss_mark":
            return "boss_mark"
        _:
            return ""

func _play_status_release(profile: String) -> void:
    if profile.is_empty():
        return
    if _status_release_tween != null and _status_release_tween.is_running():
        _status_release_tween.kill()
    _active_status_release_profile = profile
    if status_badge_back != null:
        status_badge_back.modulate = Color(1.0, 1.0, 1.0, 0.84)
        status_badge_back.scale = Vector2.ONE
    if status_badge_icon != null:
        status_badge_icon.modulate = Color(1.0, 1.0, 1.0, 0.92)
        status_badge_icon.scale = Vector2.ONE
    if telegraph_icon != null:
        telegraph_icon.modulate = Color(1.0, 1.0, 1.0, 0.92)
        telegraph_icon.scale = Vector2.ONE
    if mark_aura != null:
        mark_aura.modulate = Color(1.0, 1.0, 1.0, 0.9)
        mark_aura.scale = Vector2.ONE
    var fade_duration := 0.18
    var settle_duration := 0.1
    var badge_drop := 0.24
    var icon_drop := 0.18
    var telegraph_drop := 0.18
    var mark_drop := 0.18
    match profile:
        "charm":
            fade_duration = 0.22
            badge_drop = 0.28
            telegraph_drop = 0.22
        "dot":
            fade_duration = 0.12
            icon_drop = 0.3
            telegraph_drop = 0.3
        "oblivion":
            fade_duration = 0.24
            badge_drop = 0.34
            telegraph_drop = 0.26
        "mark", "boss_mark":
            fade_duration = 0.16
            mark_drop = 0.34 if profile == "boss_mark" else 0.26
    _status_release_tween = create_tween()
    if status_badge_back != null:
        _status_release_tween.parallel().tween_property(status_badge_back, "modulate:a", badge_drop, fade_duration)
    if status_badge_icon != null:
        _status_release_tween.parallel().tween_property(status_badge_icon, "modulate:a", icon_drop, fade_duration)
    if telegraph_icon != null:
        _status_release_tween.parallel().tween_property(telegraph_icon, "modulate:a", telegraph_drop, fade_duration)
    if mark_aura != null and (profile == "mark" or profile == "boss_mark"):
        _status_release_tween.parallel().tween_property(mark_aura, "modulate:a", mark_drop, fade_duration)
        _status_release_tween.parallel().tween_property(mark_aura, "scale", Vector2(0.94, 0.94), fade_duration)
    _status_release_tween.tween_interval(0.02)
    if status_badge_back != null:
        _status_release_tween.parallel().tween_property(status_badge_back, "modulate:a", 1.0, settle_duration)
    if status_badge_icon != null:
        _status_release_tween.parallel().tween_property(status_badge_icon, "modulate:a", 1.0, settle_duration)
    if telegraph_icon != null:
        _status_release_tween.parallel().tween_property(telegraph_icon, "modulate:a", 1.0, settle_duration)
        _status_release_tween.parallel().tween_property(telegraph_icon, "scale", Vector2.ONE, settle_duration)
    if mark_aura != null and (profile == "mark" or profile == "boss_mark"):
        _status_release_tween.parallel().tween_property(mark_aura, "modulate:a", 1.0, settle_duration)
        _status_release_tween.parallel().tween_property(mark_aura, "scale", Vector2.ONE, settle_duration)

func _play_status_afterglow(profile: String) -> void:
    if profile.is_empty():
        return
    if _status_afterglow_tween != null and _status_afterglow_tween.is_running():
        _status_afterglow_tween.kill()
    _active_status_afterglow_profile = profile
    var glow_target: CanvasItem = telegraph_icon if telegraph_icon != null else self
    var peak_color := Color(1.0, 1.0, 1.0, 0.24)
    match profile:
        "charm":
            peak_color = Color(1.0, 0.86, 0.94, 0.28)
        "oblivion":
            peak_color = Color(0.88, 0.92, 1.0, 0.26)
        "mark":
            peak_color = Color(1.0, 0.9, 0.72, 0.24)
        "boss_mark":
            peak_color = Color(1.0, 0.82, 0.72, 0.30)
    glow_target.modulate = Color(1.0, 1.0, 1.0, 0.0)
    _status_afterglow_tween = create_tween()
    _status_afterglow_tween.tween_property(glow_target, "modulate", peak_color, 0.12)
    _status_afterglow_tween.tween_property(glow_target, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

func _start_status_idle_animation(profile: String) -> void:
    _status_idle_tween = create_tween().set_loops()
    match profile:
        "charm":
            if status_badge_icon != null:
                _status_idle_tween.tween_property(status_badge_icon, "rotation", 0.14, 0.28)
                _status_idle_tween.tween_property(status_badge_icon, "rotation", -0.14, 0.32)
                _status_idle_tween.tween_property(status_badge_icon, "rotation", 0.0, 0.22)
        "dot":
            if status_badge_back != null:
                _status_idle_tween.tween_property(status_badge_back, "modulate:a", 0.72, 0.18)
                _status_idle_tween.tween_property(status_badge_back, "modulate:a", 1.0, 0.18)
            if telegraph_icon != null and telegraph_icon.visible:
                _status_idle_tween.parallel().tween_property(telegraph_icon, "modulate:a", 0.74, 0.18)
                _status_idle_tween.parallel().tween_property(telegraph_icon, "modulate:a", 1.0, 0.18)
        "oblivion":
            if telegraph_icon != null and telegraph_icon.visible:
                _status_idle_tween.tween_property(telegraph_icon, "scale", Vector2(1.12, 1.12), 0.32)
                _status_idle_tween.tween_property(telegraph_icon, "scale", Vector2(0.96, 0.96), 0.32)
                _status_idle_tween.tween_property(telegraph_icon, "scale", Vector2.ONE, 0.2)
            if status_badge_back != null:
                _status_idle_tween.parallel().tween_property(status_badge_back, "modulate:a", 0.82, 0.32)
                _status_idle_tween.parallel().tween_property(status_badge_back, "modulate:a", 1.0, 0.32)
        "mark", "boss_mark":
            if mark_crosshair_h != null:
                _status_idle_tween.tween_property(mark_crosshair_h, "scale:x", 1.14, 0.18)
                _status_idle_tween.tween_property(mark_crosshair_h, "scale:x", 1.0, 0.18)
            if mark_crosshair_v != null:
                _status_idle_tween.parallel().tween_property(mark_crosshair_v, "scale:y", 1.14, 0.18)
                _status_idle_tween.parallel().tween_property(mark_crosshair_v, "scale:y", 1.0, 0.18)

func _start_status_accent_animation(profile: String) -> void:
    _status_accent_tween = create_tween().set_loops()
    match profile:
        "charm":
            if status_badge_back != null:
                _status_accent_tween.tween_property(status_badge_back, "modulate:a", 0.76, 0.42)
                _status_accent_tween.tween_property(status_badge_back, "modulate:a", 1.0, 0.42)
            if telegraph_icon != null and telegraph_icon.visible:
                _status_accent_tween.parallel().tween_property(telegraph_icon, "scale", Vector2(1.04, 1.04), 0.42)
                _status_accent_tween.parallel().tween_property(telegraph_icon, "scale", Vector2.ONE, 0.42)
        "dot":
            if status_badge_icon != null:
                _status_accent_tween.tween_property(status_badge_icon, "modulate:a", 0.7, 0.22)
                _status_accent_tween.tween_property(status_badge_icon, "modulate:a", 1.0, 0.22)
            if telegraph_icon != null and telegraph_icon.visible:
                _status_accent_tween.parallel().tween_property(telegraph_icon, "modulate:a", 0.66, 0.22)
                _status_accent_tween.parallel().tween_property(telegraph_icon, "modulate:a", 1.0, 0.22)
        "oblivion":
            if status_badge_back != null:
                _status_accent_tween.tween_property(status_badge_back, "scale", Vector2(1.05, 1.05), 0.38)
                _status_accent_tween.tween_property(status_badge_back, "scale", Vector2.ONE, 0.38)
            if telegraph_icon != null and telegraph_icon.visible:
                _status_accent_tween.parallel().tween_property(telegraph_icon, "modulate:a", 0.78, 0.38)
                _status_accent_tween.parallel().tween_property(telegraph_icon, "modulate:a", 1.0, 0.38)
        "mark", "boss_mark":
            if mark_aura != null:
                var aura_peak := Vector2(1.08, 1.08) if profile == "mark" else Vector2(1.14, 1.14)
                var aura_alpha := 0.72 if profile == "mark" else 0.84
                _status_accent_tween.tween_property(mark_aura, "scale", aura_peak, 0.2)
                _status_accent_tween.parallel().tween_property(mark_aura, "modulate:a", aura_alpha, 0.2)
                _status_accent_tween.tween_property(mark_aura, "scale", Vector2.ONE, 0.2)
                _status_accent_tween.parallel().tween_property(mark_aura, "modulate:a", 1.0, 0.2)

func _start_status_text_animation(profile: String) -> void:
    var text_target: CanvasItem = telegraph_label if telegraph_label != null else self
    _status_text_tween = create_tween().set_loops()
    match profile:
        "charm":
            _status_text_tween.tween_property(text_target, "modulate:a", 0.78, 0.34)
            _status_text_tween.tween_property(text_target, "modulate:a", 1.0, 0.34)
        "dot":
            _status_text_tween.tween_property(text_target, "scale", Vector2(1.03, 1.03), 0.18)
            _status_text_tween.tween_property(text_target, "scale", Vector2.ONE, 0.18)
        "oblivion":
            _status_text_tween.tween_property(text_target, "modulate:a", 0.74, 0.3)
            _status_text_tween.parallel().tween_property(text_target, "scale", Vector2(1.04, 1.04), 0.3)
            _status_text_tween.tween_property(text_target, "modulate:a", 1.0, 0.3)
            _status_text_tween.parallel().tween_property(text_target, "scale", Vector2.ONE, 0.3)
        "mark", "boss_mark":
            var peak := Vector2(1.04, 1.04) if profile == "mark" else Vector2(1.08, 1.08)
            _status_text_tween.tween_property(text_target, "scale", peak, 0.16)
            _status_text_tween.tween_property(text_target, "scale", Vector2.ONE, 0.16)

func _start_status_nameplate_animation(profile: String) -> void:
    var plate_target: CanvasItem = name_plate_back if name_plate_back != null else self
    _status_nameplate_tween = create_tween().set_loops()
    match profile:
        "charm":
            _status_nameplate_tween.tween_property(plate_target, "modulate:a", 0.76, 0.42)
            _status_nameplate_tween.tween_property(plate_target, "modulate:a", 1.0, 0.42)
        "oblivion":
            _status_nameplate_tween.tween_property(plate_target, "scale", Vector2(1.03, 1.03), 0.34)
            _status_nameplate_tween.tween_property(plate_target, "scale", Vector2.ONE, 0.34)
        "mark", "boss_mark":
            var drift_peak := Vector2(1.02, 1.02) if profile == "mark" else Vector2(1.05, 1.05)
            _status_nameplate_tween.tween_property(plate_target, "scale", drift_peak, 0.18)
            _status_nameplate_tween.tween_property(plate_target, "scale", Vector2.ONE, 0.18)

func _start_status_icon_animation(profile: String) -> void:
    var icon_target: CanvasItem = telegraph_icon if telegraph_icon != null else self
    _status_icon_tween = create_tween().set_loops()
    match profile:
        "charm":
            _status_icon_tween.tween_property(icon_target, "modulate", Color(1.0, 0.86, 0.94, 0.84), 0.34)
            _status_icon_tween.tween_property(icon_target, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.34)
        "oblivion":
            _status_icon_tween.tween_property(icon_target, "modulate", Color(0.88, 0.92, 1.0, 0.82), 0.3)
            _status_icon_tween.tween_property(icon_target, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
        "mark", "boss_mark":
            var marked_color := Color(1.0, 0.9, 0.72, 0.86) if profile == "mark" else Color(1.0, 0.82, 0.72, 0.92)
            _status_icon_tween.tween_property(icon_target, "modulate", marked_color, 0.18)
            _status_icon_tween.tween_property(icon_target, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

func _start_status_badge_text_animation(profile: String) -> void:
    var badge_text_target: CanvasItem = status_badge_label if status_badge_label != null else self
    _status_badge_text_tween = create_tween().set_loops()
    match profile:
        "charm":
            _status_badge_text_tween.tween_property(badge_text_target, "modulate:a", 0.78, 0.34)
            _status_badge_text_tween.tween_property(badge_text_target, "modulate:a", 1.0, 0.34)
        "oblivion":
            _status_badge_text_tween.tween_property(badge_text_target, "scale", Vector2(1.06, 1.06), 0.28)
            _status_badge_text_tween.tween_property(badge_text_target, "scale", Vector2.ONE, 0.28)
        "mark", "boss_mark":
            var peak := Vector2(1.05, 1.05) if profile == "mark" else Vector2(1.08, 1.08)
            _status_badge_text_tween.tween_property(badge_text_target, "scale", peak, 0.16)
            _status_badge_text_tween.tween_property(badge_text_target, "scale", Vector2.ONE, 0.16)

func _stop_status_idle_animation() -> void:
    if _status_idle_tween != null and _status_idle_tween.is_running():
        _status_idle_tween.kill()
    _status_idle_tween = null
    _active_status_idle_profile = ""
    if status_badge_back != null:
        status_badge_back.modulate = Color(1.0, 1.0, 1.0, 1.0)
    if status_badge_icon != null:
        status_badge_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
        status_badge_icon.rotation = 0.0
    if telegraph_icon != null:
        telegraph_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
        telegraph_icon.scale = Vector2.ONE
    if mark_crosshair_h != null:
        mark_crosshair_h.scale = Vector2.ONE
    if mark_crosshair_v != null:
        mark_crosshair_v.scale = Vector2.ONE

func _stop_status_accent_animation() -> void:
    if _status_accent_tween != null and _status_accent_tween.is_running():
        _status_accent_tween.kill()
    _status_accent_tween = null
    _active_status_accent_profile = ""
    if status_badge_back != null:
        status_badge_back.modulate = Color(1.0, 1.0, 1.0, 1.0)
        status_badge_back.scale = Vector2.ONE
    if status_badge_icon != null:
        status_badge_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
    if telegraph_icon != null:
        telegraph_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
        telegraph_icon.scale = Vector2.ONE
    if mark_aura != null:
        mark_aura.modulate = Color(1.0, 1.0, 1.0, 1.0)
        mark_aura.scale = Vector2.ONE

func _stop_status_text_animation() -> void:
    if _status_text_tween != null and _status_text_tween.is_running():
        _status_text_tween.kill()
    _status_text_tween = null
    _active_status_text_profile = ""
    if telegraph_label != null:
        telegraph_label.modulate = _get_status_telegraph_color()
        telegraph_label.scale = Vector2.ONE
    else:
        modulate = Color(1.0, 1.0, 1.0, 1.0)
        scale = Vector2.ONE

func _stop_status_nameplate_animation() -> void:
    if _status_nameplate_tween != null and _status_nameplate_tween.is_running():
        _status_nameplate_tween.kill()
    _status_nameplate_tween = null
    _active_status_nameplate_profile = ""
    if name_plate_back != null:
        name_plate_back.modulate = Color(1.0, 1.0, 1.0, 1.0)
        name_plate_back.scale = Vector2.ONE

func _stop_status_icon_animation() -> void:
    if _status_icon_tween != null and _status_icon_tween.is_running():
        _status_icon_tween.kill()
    _status_icon_tween = null
    _active_status_icon_profile = ""
    if telegraph_icon != null:
        telegraph_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _stop_status_badge_text_animation() -> void:
    if _status_badge_text_tween != null and _status_badge_text_tween.is_running():
        _status_badge_text_tween.kill()
    _status_badge_text_tween = null
    _active_status_badge_text_profile = ""
    if status_badge_label != null:
        status_badge_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
        status_badge_label.scale = Vector2.ONE

func _stop_status_afterglow_animation() -> void:
    if _status_afterglow_tween != null and _status_afterglow_tween.is_running():
        _status_afterglow_tween.kill()
    _status_afterglow_tween = null
    _active_status_afterglow_profile = ""
    if telegraph_icon != null:
        telegraph_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _get_mark_aura_color() -> Color:
    if _selected:
        return Color(1.0, 0.6, 0.792157, 0.2)
    if _mark_turns > 0 and not _boss_marked:
        return Color(0.968627, 0.772549, 0.529412, 0.16)
    return Color(0.988235, 0.494118, 0.741176, 0.14)

func _get_mark_crosshair_color() -> Color:
    if _mark_turns > 0 and not _boss_marked:
        return Color(1.0, 0.862745, 0.588235, 0.9)
    return Color(1.0, 0.760784, 0.898039, 0.9)

func _get_base_color() -> Color:
    if _selected:
        return Color(0.964706, 0.776471, 0.27451, 0.95)

    if _attackable:
        return Color(1.0, 0.52549, 0.301961, 0.9)

    var color: Color = Color(0.239216, 0.537255, 0.972549, 0.92) if faction == "ally" else Color(0.807843, 0.266667, 0.258824, 0.92)
    if has_acted:
        color = color.darkened(0.48)

    match _get_primary_status_key():
        &"charm":
            return color.lerp(Color(0.94902, 0.356863, 0.45098, 0.92), 0.48)
        &"fear":
            return color.lerp(Color(0.772549, 0.45098, 0.286275, 0.92), 0.42)
        &"dot":
            return color.lerp(Color(0.913726, 0.721569, 0.25098, 0.92), 0.44)
        &"mark":
            return color.lerp(Color(0.952941, 0.764706, 0.498039, 0.92), 0.32)
        &"oblivion":
            return color.lerp(Color(0.564706, 0.431373, 0.858824, 0.92), 0.52)

    return color

func _has_visual_status() -> bool:
    return _oblivion_stack_visual > 0 or _fear_turns > 0 or _charm_turns > 0 or _dot_turns > 0 or _mark_turns > 0

func _should_show_mark_crosshair() -> bool:
    return _boss_marked or _mark_turns > 0

func _should_show_status_badge() -> bool:
    return _get_primary_status_key() != &""

func _get_primary_status_key() -> StringName:
    if _boss_marked:
        return &"boss_mark"
    if _charm_turns > 0:
        return &"charm"
    if _fear_turns > 0:
        return &"fear"
    if _dot_turns > 0:
        return &"dot"
    if _mark_turns > 0:
        return &"mark"
    if _oblivion_stack_visual > 0:
        return &"oblivion"
    return &""

func _get_primary_status_turn_count(status_key: StringName = &"") -> int:
    var resolved_status: StringName = status_key if status_key != &"" else _get_primary_status_key()
    match resolved_status:
        &"charm":
            return _charm_turns
        &"fear":
            return _fear_turns
        &"dot":
            return _dot_turns
        &"mark":
            return _mark_turns
        _:
            return 0

func _get_status_duration_suffix(status_key: StringName = &"") -> String:
    var turn_count := _get_primary_status_turn_count(status_key)
    return "%dT" % turn_count if turn_count > 0 else ""

func _get_status_badge_count_suffix(status_key: StringName = &"") -> String:
    var turn_count := _get_primary_status_turn_count(status_key)
    return "%d" % turn_count if turn_count > 0 else ""

func _get_status_telegraph_text() -> String:
    if _bond_guard_ready:
        return "GUARD"
    if _bond_support_ready:
        return "BOND"
    var primary_status: StringName = _get_primary_status_key()
    var base_text := ""
    match primary_status:
        &"boss_mark":
            base_text = "MARK"
        &"charm":
            base_text = "유혹"
        &"fear":
            base_text = "공포"
        &"dot":
            base_text = "지속"
        &"mark":
            base_text = "표식"
        &"oblivion":
            base_text = "망각 %d" % _oblivion_stack_visual
        _:
            base_text = ""
    var turn_count: int = _get_primary_status_turn_count(primary_status)
    var duration_suffix: String = "%dT" % turn_count if turn_count > 0 else ""
    return "%s %s" % [base_text, duration_suffix] if not duration_suffix.is_empty() else base_text

func _get_status_telegraph_texture() -> Texture2D:
    if _bond_guard_ready:
        return TelegraphTextureLibrary.get_texture("protect")
    if _bond_support_ready:
        return TelegraphTextureLibrary.get_texture("heal")
    match _get_primary_status_key():
        &"boss_mark", &"mark":
            return TelegraphTextureLibrary.get_texture("mark")
        &"charm":
            return TelegraphTextureLibrary.get_texture("command")
        &"fear", &"dot", &"oblivion":
            return TelegraphTextureLibrary.get_texture("danger")
        _:
            return null

func _get_status_badge_text() -> String:
    var primary_status: StringName = _get_primary_status_key()
    var base_text := ""
    match primary_status:
        &"boss_mark":
            base_text = "MK"
        &"charm":
            base_text = "유"
        &"fear":
            base_text = "공"
        &"dot":
            base_text = "지"
        &"mark":
            base_text = "표"
        &"oblivion":
            base_text = "망"
        _:
            base_text = ""
    var badge_count_suffix := _get_status_badge_count_suffix(primary_status)
    return "%s%s" % [base_text, badge_count_suffix]

func _get_status_badge_icon_kind() -> String:
    match _get_primary_status_key():
        &"boss_mark":
            return "status_boss_mark"
        &"charm":
            return "status_charm"
        &"fear":
            return "status_fear"
        &"dot":
            return "status_dot"
        &"mark":
            return "status_mark"
        &"oblivion":
            return "status_oblivion"
        _:
            return ""

func _get_status_badge_icon_texture() -> Texture2D:
    var kind := _get_status_badge_icon_kind()
    if kind.is_empty():
        return null
    return TelegraphTextureLibrary.get_texture(kind)

func _get_status_badge_back_color() -> Color:
    match _get_primary_status_key():
        &"boss_mark":
            return Color(0.309804, 0.121569, 0.188235, 0.94)
        &"charm":
            return Color(0.345098, 0.101961, 0.137255, 0.94)
        &"fear":
            return Color(0.309804, 0.152941, 0.0823529, 0.94)
        &"dot":
            return Color(0.321569, 0.227451, 0.0784314, 0.94)
        &"mark":
            return Color(0.321569, 0.215686, 0.0823529, 0.94)
        &"oblivion":
            return Color(0.176471, 0.12549, 0.278431, 0.94)
        _:
            return Color(0.121569, 0.141176, 0.184314, 0.0)

func _get_status_badge_text_color() -> Color:
    match _get_primary_status_key():
        &"boss_mark":
            return Color(1.0, 0.760784, 0.898039, 0.98)
        &"charm":
            return Color(1.0, 0.705882, 0.792157, 0.98)
        &"fear":
            return Color(1.0, 0.780392, 0.592157, 0.98)
        &"dot":
            return Color(1.0, 0.882353, 0.529412, 0.98)
        &"mark":
            return Color(1.0, 0.854902, 0.603922, 0.98)
        &"oblivion":
            return Color(0.85098, 0.760784, 1.0, 0.98)
        _:
            return Color(0.968627, 0.972549, 0.992157, 1.0)

func _get_status_telegraph_color() -> Color:
    if _bond_guard_ready:
        return Color(0.733333, 1.0, 0.843137, 0.95)
    if _bond_support_ready:
        return Color(0.694118, 0.92549, 1.0, 0.95)
    match _get_primary_status_key():
        &"boss_mark":
            return Color(1.0, 0.529412, 0.764706, 0.95)
        &"charm":
            return Color(1.0, 0.478431, 0.556863, 0.95)
        &"fear":
            return Color(0.988235, 0.705882, 0.47451, 0.95)
        &"dot":
            return Color(1.0, 0.85098, 0.447059, 0.95)
        &"mark":
            return Color(1.0, 0.835294, 0.564706, 0.95)
        &"oblivion":
            return Color(0.823529, 0.705882, 1.0, 0.95)
        _:
            return Color(1.0, 1.0, 1.0, 0.0)

func _get_visual_character_modulate() -> Color:
    match _get_primary_status_key():
        &"charm":
            return Color(1.0, 0.752941, 0.803922, 0.94)
        &"fear":
            return Color(0.913726, 0.823529, 0.756863, 0.92)
        &"dot":
            return Color(1.0, 0.894118, 0.576471, 0.94)
        &"mark":
            return Color(1.0, 0.894118, 0.772549, 0.92)
        &"oblivion":
            return Color(0.764706, 0.709804, 0.929412, 0.82)
        _:
            return _get_token_art_color()

func _start_fear_shake() -> void:
    if character_visual_root == null:
        return
    if _fear_shake_tween != null and _fear_shake_tween.is_running():
        return
    character_visual_root.position = Vector2.ZERO
    _fear_shake_tween = create_tween().set_loops()
    _fear_shake_tween.tween_property(character_visual_root, "position:x", -1.5, 0.06)
    _fear_shake_tween.tween_property(character_visual_root, "position:x", 1.5, 0.08)
    _fear_shake_tween.tween_property(character_visual_root, "position:x", 0.0, 0.06)

func _stop_fear_shake() -> void:
    if _fear_shake_tween != null and _fear_shake_tween.is_running():
        _fear_shake_tween.kill()
    _fear_shake_tween = null
    if character_visual_root != null:
        character_visual_root.position = Vector2.ZERO
