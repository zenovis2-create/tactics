class_name BattleController
extends Node2D

signal battle_finished(result: StringName, stage_id: StringName)

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const InteractiveObjectActor = preload("res://scripts/battle/interactive_object_actor.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const TurnManager = preload("res://scripts/battle/turn_manager.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const CombatService = preload("res://scripts/battle/combat_service.gd")
const AIService = preload("res://scripts/battle/ai_service.gd")
const InputController = preload("res://scripts/battle/input_controller.gd")
const GridCursor = preload("res://scripts/battle/grid_cursor.gd")
const BattleHUD = preload("res://scripts/battle/battle_hud.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const AccessoryData = preload("res://scripts/data/accessory_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const ArmorData = preload("res://scripts/data/armor_data.gd")
const BattleBoard = preload("res://scripts/battle/battle_board.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const StageRuleTemplateService = preload("res://scripts/battle/stage_rule_template_service.gd")
const StatusService = preload("res://scripts/battle/status_service.gd")
const TelemetryService = preload("res://scripts/battle/telemetry_service.gd")
const RewardService = preload("res://scripts/battle/reward_service.gd")
const CutscenePlayer = preload("res://scripts/cutscene/cutscene_player.gd")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const BondService = preload("res://scripts/battle/bond_service.gd")
const SupportConversations = preload("res://data/support_conversations.gd")
const CampaignContentRegistry = preload("res://scripts/campaign/campaign_content_registry.gd")
const ALLY_VANGUARD_DATA: UnitData = preload("res://data/units/ally_vanguard.tres")

enum BattlePhase {
    BATTLE_INIT,
    PLAYER_PHASE_START,
    PLAYER_SELECT,
    PLAYER_ACTION_PREVIEW,
    PLAYER_ACTION_COMMIT,
    PLAYER_ACTION_RESOLVE,
    PLAYER_PHASE_END,
    ENEMY_PHASE_START,
    ENEMY_DECIDE,
    ENEMY_ACTION_RESOLVE,
    ENEMY_PHASE_END,
    ROUND_END,
    VICTORY,
    DEFEAT
}

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const OBJECT_SCENE: PackedScene = preload("res://scenes/battle/InteractiveObject.tscn")
const DEFAULT_STAGE: StageData = preload("res://data/stages/tutorial_stage.tres")

const WEATHER_EFFECTS: Dictionary = {
    "clear": {"range_modifier": 0, "damage_modifier": 0.0, "status_chance_modifier": 0.0, "heal_modifier": 1.0},
    "rain": {"range_modifier": 0, "damage_modifier": -0.1, "status_chance_modifier": 0.0, "heal_modifier": 1.0, "fire_extinguished": true, "water_expansion": 1.5},
    "night": {"range_modifier": -1, "damage_modifier": 0.0, "status_chance_modifier": 0.0, "heal_modifier": 2.0, "ambush_defense_bonus": 0.3}
}

const TERRAIN_EFFECTS: Dictionary = {
    "high_ground": {"defense_bonus": 0.2, "range_bonus": 1},
    "water": {"speed_penalty": 1},
    "fire": {"damage_per_turn": 10, "spread_chance": 0.3},
    "sacred_ground": {"heal_per_turn": 5},
    "narrow_pass": {"max_occupancy": 1},
    "destructible": {"hp": 50, "destroyed": false}
}

const SYNERGY_REACTIONS: Array[Dictionary] = [
    {"trigger": ["fire", "rain"], "result": "steam", "duration": 3, "effect": "blocks_los"},
    {"trigger": ["fire", "night"], "result": "smoke", "duration": 2, "damage": 5, "spread": 2},
    {"trigger": ["high_ground", "night"], "result": "ambush", "defense_bonus": 0.3},
    {"trigger": ["sacred_ground", "rain"], "result": "purified", "heal_bonus": 2.0, "cleanse": true}
]

const PHASE_NAMES := {
    BattlePhase.BATTLE_INIT: "BATTLE_INIT",
    BattlePhase.PLAYER_PHASE_START: "PLAYER_PHASE_START",
    BattlePhase.PLAYER_SELECT: "PLAYER_SELECT",
    BattlePhase.PLAYER_ACTION_PREVIEW: "PLAYER_ACTION_PREVIEW",
    BattlePhase.PLAYER_ACTION_COMMIT: "PLAYER_ACTION_COMMIT",
    BattlePhase.PLAYER_ACTION_RESOLVE: "PLAYER_ACTION_RESOLVE",
    BattlePhase.PLAYER_PHASE_END: "PLAYER_PHASE_END",
    BattlePhase.ENEMY_PHASE_START: "ENEMY_PHASE_START",
    BattlePhase.ENEMY_DECIDE: "ENEMY_DECIDE",
    BattlePhase.ENEMY_ACTION_RESOLVE: "ENEMY_ACTION_RESOLVE",
    BattlePhase.ENEMY_PHASE_END: "ENEMY_PHASE_END",
    BattlePhase.ROUND_END: "ROUND_END",
    BattlePhase.VICTORY: "VICTORY",
    BattlePhase.DEFEAT: "DEFEAT"
}

const PHASE_TRANSITIONS := {
    BattlePhase.BATTLE_INIT: [BattlePhase.PLAYER_PHASE_START, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.PLAYER_PHASE_START: [BattlePhase.PLAYER_SELECT, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.PLAYER_SELECT: [BattlePhase.PLAYER_ACTION_PREVIEW, BattlePhase.PLAYER_PHASE_END, BattlePhase.ENEMY_PHASE_START, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.PLAYER_ACTION_PREVIEW: [BattlePhase.PLAYER_ACTION_COMMIT, BattlePhase.PLAYER_SELECT, BattlePhase.PLAYER_PHASE_END, BattlePhase.ENEMY_PHASE_START, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.PLAYER_ACTION_COMMIT: [BattlePhase.PLAYER_ACTION_PREVIEW, BattlePhase.PLAYER_ACTION_RESOLVE, BattlePhase.PLAYER_SELECT, BattlePhase.PLAYER_PHASE_END, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.PLAYER_ACTION_RESOLVE: [BattlePhase.PLAYER_SELECT, BattlePhase.PLAYER_PHASE_END, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.PLAYER_PHASE_END: [BattlePhase.ENEMY_PHASE_START, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.ENEMY_PHASE_START: [BattlePhase.ENEMY_DECIDE, BattlePhase.ENEMY_PHASE_END, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.ENEMY_DECIDE: [BattlePhase.ENEMY_ACTION_RESOLVE, BattlePhase.ENEMY_PHASE_END, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.ENEMY_ACTION_RESOLVE: [BattlePhase.ENEMY_DECIDE, BattlePhase.ENEMY_PHASE_END, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.ENEMY_PHASE_END: [BattlePhase.ROUND_END, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.ROUND_END: [BattlePhase.PLAYER_PHASE_START, BattlePhase.VICTORY, BattlePhase.DEFEAT],
    BattlePhase.VICTORY: [],
    BattlePhase.DEFEAT: []
}

@export var stage_data: StageData

@onready var units_root: Node2D = $Units
@onready var objects_root: Node2D = $Objects
@onready var effects_root: Node2D = $Effects
@onready var battle_camera: Camera2D = $BattleCamera
@onready var battle_flash: ColorRect = $BattleFlash
@onready var battle_board: BattleBoard = $BattleBoard
@onready var turn_manager: TurnManager = $TurnManager
@onready var path_service: PathService = $PathService
@onready var range_service: RangeService = $RangeService
@onready var combat_service: CombatService = $CombatService
@onready var ai_service: AIService = $AIService
@onready var input_controller: InputController = $InputController
@onready var grid_cursor: GridCursor = $GridCursor
@onready var hud: BattleHUD = $CanvasLayer/BattleHUD

var ally_units: Array = []
var enemy_units: Array = []
var interactive_objects: Array = []
var selected_unit: UnitActor
var reachable_cells: Array = []
var pending_move_origins: Dictionary = {}
var battle_reward_log: Array[String] = []
var last_result_summary: Dictionary = {}
var equipped_accessory_by_unit_id: Dictionary = {}
var equipped_weapon_by_unit_id: Dictionary = {}
var equipped_armor_by_unit_id: Dictionary = {}
var boss_marked_target_id: int = -1
var boss_charge_pending: bool = false
var enemy_attack_bonus_by_unit: Dictionary = {}
var enemy_movement_bonus_by_unit: Dictionary = {}  ## boss phase movement bonuses
var boss_event_history: Array[String] = []
var boss_phase_by_unit: Dictionary = {}  ## unit instance_id → current phase StringName
var boss_lock_state_by_unit: Dictionary = {}  ## unit instance_id → boss lock break runtime state
var last_support_attack_details: Dictionary = {}
var last_damage_share_details: Dictionary = {}
var last_charm_forced_details: Dictionary = {}
var enemy_damage_multiplier_by_unit: Dictionary = {}
var enemy_damage_reduction_turns_by_unit: Dictionary = {}
var enemy_skill_cooldowns_by_unit: Dictionary = {}
var player_skip_turns_by_unit: Dictionary = {}
var ignored_terrain_turns_by_unit: Dictionary = {}
var bond_suppression_turns_by_unit: Dictionary = {}
var boss_attacked_this_player_phase: Dictionary = {}
var boss_untouched_player_turns: Dictionary = {}
var spawned_once_flags_by_unit: Dictionary = {}
var last_player_skill_used: SkillData
var last_name_call_line: String = ""
var last_name_call_speaker_id: StringName = &""

var current_phase: int = BattlePhase.BATTLE_INIT
var round_index: int = 1
var phase_transition_history: Array = []
var board_origin: Vector2 = Vector2.ZERO
var board_scale: float = 1.0
var _battle_flash_tween: Tween
var _camera_emphasis_tween: Tween
var _fx_cache: Dictionary = {}
var _last_attack_timing_signature: Dictionary = {}
var weather_type: String = "clear"
var weather_defense_bonus_by_unit: Dictionary = {}
var _active_area_statuses: Array[Dictionary] = []
var _unit_visual_status_turns: Dictionary = {}
var _last_visible_ally_cells_by_unit_id: Dictionary = {}
var _active_synergy_results: Dictionary = {}
var _triggered_synergy_keys: Dictionary = {}
var _synergy_activation_log: Array[String] = []
var _rain_environment_applied: bool = false
var battle_test_flags: Dictionary = {}
var battle_objective_flags: Dictionary = {}
var battle_runtime_counters: Dictionary = {}
var _active_secret_hint_contract: Dictionary = {}
var _secret_hint_rules: Array[Dictionary] = []
var _secret_hint_revealed_lines: Array[String] = []
var _secret_hint_level: int = 0

# M4/M5/M6 services — instantiated at runtime, not scene nodes.
var progression_service: ProgressionService
var status_service: StatusService
var telemetry_service: TelemetryService
var reward_service: RewardService
var cutscene_player: CutscenePlayer
var bond_service: BondService

func _ready() -> void:
    _wire_signals()
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    if stage_data == null:
        stage_data = DEFAULT_STAGE

    _init_meta_services()
    _sync_hud_phase("controller_ready", {"stage_loaded": stage_data != null})
    bootstrap_battle()

func _init_meta_services() -> void:
    progression_service = ProgressionService.new()
    add_child(progression_service)
    status_service = StatusService.new()
    add_child(status_service)
    telemetry_service = TelemetryService.new()
    add_child(telemetry_service)
    reward_service = RewardService.new()
    add_child(reward_service)
    cutscene_player = CutscenePlayer.new()
    add_child(cutscene_player)
    bond_service = BondService.new()
    add_child(bond_service)

func bootstrap_battle() -> void:
    round_index = 1
    current_phase = BattlePhase.BATTLE_INIT
    phase_transition_history.clear()
    battle_reward_log.clear()
    last_result_summary.clear()
    boss_marked_target_id = -1
    boss_charge_pending = false
    enemy_attack_bonus_by_unit.clear()
    enemy_movement_bonus_by_unit.clear()
    boss_event_history.clear()
    boss_phase_by_unit.clear()
    boss_lock_state_by_unit.clear()
    last_support_attack_details.clear()
    last_damage_share_details.clear()
    enemy_damage_multiplier_by_unit.clear()
    enemy_damage_reduction_turns_by_unit.clear()
    enemy_skill_cooldowns_by_unit.clear()
    player_skip_turns_by_unit.clear()
    ignored_terrain_turns_by_unit.clear()
    bond_suppression_turns_by_unit.clear()
    boss_attacked_this_player_phase.clear()
    boss_untouched_player_turns.clear()
    spawned_once_flags_by_unit.clear()
    last_player_skill_used = null
    last_name_call_line = ""
    last_name_call_speaker_id = &""
    battle_objective_flags.clear()
    battle_runtime_counters.clear()
    _active_secret_hint_contract.clear()
    _secret_hint_rules.clear()
    _secret_hint_revealed_lines.clear()
    _secret_hint_level = 0
    _unit_visual_status_turns.clear()
    _last_visible_ally_cells_by_unit_id.clear()
    weather_type = _normalize_weather_type(stage_data.weather_type if stage_data != null else "")
    _reset_weather_runtime_state()

    _clear_battle_state()
    _spawn_from_stage()
    path_service.configure_from_stage(stage_data)
    _layout_battlefield()
    if combat_service != null:
        combat_service.set_weather_type(weather_type)

    if telemetry_service != null:
        telemetry_service.record_battle_start(stage_data.stage_id if stage_data != null else &"unknown")
    if status_service != null:
        status_service.reset()
    _initialize_stage_specific_runtime_flags()
    _initialize_boss_lock_definitions()
    _initialize_secret_hint_contract()
    if reward_service != null and stage_data != null:
        reward_service.record_stage_entry(stage_data.stage_id)

    # 전투 시작 전 컷씬 재생 (있는 경우)
    if cutscene_player != null and stage_data != null and stage_data.start_cutscene_id != &"":
        var start_data = CutsceneCatalog.get_cutscene(stage_data.start_cutscene_id)
        if start_data != null:
            cutscene_player.play(start_data)

    _begin_player_phase("battle_initialized")

func set_stage(new_stage_data: StageData) -> void:
    stage_data = new_stage_data
    if is_inside_tree():
        bootstrap_battle()

func set_equipped_accessory_map(accessory_map: Dictionary) -> void:
    equipped_accessory_by_unit_id = accessory_map.duplicate(true)
    if is_inside_tree():
        for unit in ally_units + enemy_units:
            if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
                continue
            var accessory: AccessoryData = equipped_accessory_by_unit_id.get(String(unit.unit_data.unit_id), null)
            unit.set_equipped_accessory(accessory)

func set_equipped_weapon_map(weapon_map: Dictionary) -> void:
    equipped_weapon_by_unit_id = weapon_map.duplicate(true)
    if is_inside_tree():
        for unit in ally_units + enemy_units:
            if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
                continue
            var weapon: WeaponData = equipped_weapon_by_unit_id.get(String(unit.unit_data.unit_id), null)
            unit.set_equipped_weapon(weapon)

func set_equipped_armor_map(armor_map: Dictionary) -> void:
    equipped_armor_by_unit_id = armor_map.duplicate(true)
    if is_inside_tree():
        for unit in ally_units + enemy_units:
            if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
                continue
            var armor: ArmorData = equipped_armor_by_unit_id.get(String(unit.unit_data.unit_id), null)
            unit.set_equipped_armor(armor)

func _wire_signals() -> void:
    input_controller.world_cell_pressed.connect(_on_world_cell_pressed)
    input_controller.ui_blocking_rects_provider = Callable(hud, "get_input_blocking_rects")
    hud.cancel_requested.connect(_on_cancel_requested)
    hud.wait_requested.connect(_on_wait_requested)
    hud.end_turn_requested.connect(_on_end_turn_requested)
    hud.menu_visibility_changed.connect(_on_hud_menu_visibility_changed)
    turn_manager.action_state_changed.connect(_on_action_state_changed)

func _clear_battle_state() -> void:
    for child in units_root.get_children():
        child.queue_free()

    for child in objects_root.get_children():
        child.queue_free()

    ally_units.clear()
    enemy_units.clear()
    interactive_objects.clear()
    selected_unit = null
    reachable_cells.clear()
    pending_move_origins.clear()
    grid_cursor.visible = false
    grid_cursor.clear_reachable_cells()
    units_root.position = Vector2.ZERO
    objects_root.position = Vector2.ZERO
    grid_cursor.position = Vector2.ZERO
    units_root.scale = Vector2.ONE
    objects_root.scale = Vector2.ONE
    grid_cursor.scale = Vector2.ONE
    if battle_board != null:
        battle_board.position = Vector2.ZERO
        battle_board.scale = Vector2.ONE
    if hud != null and hud.is_inside_tree():
        hud.close_inventory_panel()

func _spawn_from_stage() -> void:
    if stage_data == null:
        push_warning("BattleController has no StageData; stage spawn skipped.")
        return

    if battle_board != null:
        battle_board.set_stage(stage_data)
    _spawn_group(stage_data.ally_units, stage_data.ally_spawns, "ally", ally_units)
    _spawn_group(stage_data.enemy_units, stage_data.enemy_spawns, "enemy", enemy_units)
    _spawn_interactive_objects(stage_data.interactive_objects)

func _on_viewport_size_changed() -> void:
    if is_inside_tree() and stage_data != null:
        _layout_battlefield()

func _layout_battlefield() -> void:
    if stage_data == null:
        return

    var viewport_size: Vector2 = get_viewport_rect().size
    var base_board_size: Vector2 = Vector2(stage_data.grid_size.x * stage_data.cell_size.x, stage_data.grid_size.y * stage_data.cell_size.y)
    var top_reserved: float = 28.0
    var bottom_reserved: float = 28.0
    var left_reserved: float = 16.0
    var right_reserved: float = 16.0
    var fit_scale_x: float = (viewport_size.x - left_reserved - right_reserved) / base_board_size.x
    var fit_scale_y: float = (viewport_size.y - top_reserved - bottom_reserved) / base_board_size.y
    board_scale = clampf(minf(fit_scale_x, fit_scale_y), 0.86, 1.44)
    var scaled_cell_size: Vector2 = Vector2(stage_data.cell_size) * board_scale
    var board_size: Vector2 = base_board_size * board_scale

    var origin_x: float = maxf(left_reserved, floor((viewport_size.x - board_size.x) * 0.5))
    var origin_y: float = top_reserved + maxf(0.0, floor(((viewport_size.y - top_reserved - bottom_reserved) - board_size.y) * 0.04))

    board_origin = Vector2(origin_x, origin_y)
    units_root.position = board_origin
    objects_root.position = board_origin
    effects_root.position = board_origin
    grid_cursor.position = board_origin
    units_root.scale = Vector2.ONE * board_scale
    objects_root.scale = Vector2.ONE * board_scale
    effects_root.scale = Vector2.ONE * board_scale
    grid_cursor.scale = Vector2.ONE * board_scale
    if battle_board != null:
        battle_board.position = board_origin
        battle_board.scale = Vector2.ONE * board_scale
        battle_board.set_stage(stage_data)
    if battle_camera != null:
        battle_camera.position = viewport_size * 0.5
        battle_camera.limit_left = 0
        battle_camera.limit_top = 0
        battle_camera.limit_right = int(viewport_size.x)
        battle_camera.limit_bottom = int(viewport_size.y)
    input_controller.board_origin = board_origin
    input_controller.cell_size = Vector2i(roundi(scaled_cell_size.x), roundi(scaled_cell_size.y))
    if hud != null:
        hud.set_battle_frame_metrics(board_origin, board_size)

func _spawn_group(unit_defs: Array, spawn_cells: Array, faction: String, sink: Array) -> void:
    var count: int = min(unit_defs.size(), spawn_cells.size())
    for index in count:
        var unit_data: UnitData = unit_defs[index]
        var spawn_cell: Vector2i = spawn_cells[index]
        _spawn_unit_actor(unit_data, spawn_cell, faction, sink)

func _spawn_unit_actor(unit_data: UnitData, spawn_cell: Vector2i, faction: String, sink: Array) -> UnitActor:
    var unit: UnitActor = UNIT_SCENE.instantiate() as UnitActor
    if unit == null or unit_data == null:
        return null

    unit.setup_from_data(unit_data)
    unit.faction = faction
    var equipped_weapon: WeaponData = equipped_weapon_by_unit_id.get(String(unit_data.unit_id), null)
    var equipped_armor: ArmorData = equipped_armor_by_unit_id.get(String(unit_data.unit_id), null)
    var equipped_accessory: AccessoryData = equipped_accessory_by_unit_id.get(String(unit_data.unit_id), null)
    unit.set_equipped_weapon(equipped_weapon)
    unit.set_equipped_armor(equipped_armor)
    unit.set_equipped_accessory(equipped_accessory)
    unit.set_grid_position(spawn_cell, stage_data.cell_size)
    unit.defeated.connect(_on_unit_defeated)

    units_root.add_child(unit)
    sink.append(unit)
    return unit

func _spawn_runtime_enemy(unit_data: UnitData, origin: Vector2i, preferred_cells: Array = []) -> UnitActor:
    var spawn_cell: Vector2i = _find_open_spawn_cell(origin, preferred_cells)
    if spawn_cell == Vector2i(-1, -1):
        return null
    return _spawn_unit_actor(unit_data, spawn_cell, "enemy", enemy_units)

func _find_open_spawn_cell(origin: Vector2i, preferred_cells: Array = []) -> Vector2i:
    for cell_variant in preferred_cells:
        var preferred: Vector2i = cell_variant
        if _is_cell_in_bounds(preferred) and _is_spawn_cell_open(preferred):
            return preferred

    for radius in range(1, 4):
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                var candidate := origin + Vector2i(dx, dy)
                if not _is_cell_in_bounds(candidate):
                    continue
                if _is_spawn_cell_open(candidate):
                    return candidate
    return Vector2i(-1, -1)

func _is_spawn_cell_open(cell: Vector2i) -> bool:
    if not _is_cell_in_bounds(cell):
        return false
    if _find_unit_at(cell, ally_units + enemy_units) != null:
        return false
    return not _is_object_occupying_cell(cell)

func _initialize_stage_specific_runtime_flags() -> void:
    if stage_data == null:
        return
    match stage_data.stage_id:
        &"CH04_05":
            battle_objective_flags.erase("ark_survives_flooded_section")
        &"CH03_05":
            battle_objective_flags["no_structures_destroyed"] = true
        &"CH05_05":
            # Until the Noah-specific escort scene exists in runtime, use a no-casualty proxy.
            battle_objective_flags["defeat_boss_without_noah_dying"] = true
        &"CH08_05":
            battle_objective_flags["no_black_hound_casualties"] = true
        &"HUNT_SARIA":
            battle_objective_flags["hunt_saria_queue_preserved"] = true
        &"HUNT_LETE":
            battle_objective_flags["hunt_lete_black_hounds_preserved"] = true
        &"CH09B_05":
            # Until the Noah-specific party composition is guaranteed in runtime, use a no-casualty proxy.
            battle_objective_flags["noah_survives"] = true
        _:
            pass

func _initialize_boss_lock_definitions() -> void:
    if stage_data == null:
        return
    var boss_unit: UnitActor = _find_primary_stage_boss()
    if boss_unit == null:
        return
    match stage_data.stage_id:
        &"CH06_05":
            _start_boss_lock(boss_unit, &"valgar_iron_oath", "Iron Oath Break", 2, {"strike": 1, "object": 1}, "Valgar keeps the fort line locked.", "Valgar's fort line weakens.")
        &"CH07_05":
            _start_boss_lock(boss_unit, &"saria_forgetting_hymn", "Forgetting Hymn", 2, {"name": 1, "cleanse": 1}, "Saria's hymn keeps names blurred.", "The hymn loses its hold.")
        &"CH08_05":
            _start_boss_lock(boss_unit, &"lete_hound_pincer", "Hound Pincer", 2, {"object": 1, "skill": 1}, "Lete keeps the chase line closed.", "The pursuit line opens.")
        &"CH09B_05":
            _start_boss_lock(boss_unit, &"melkion_archive_rewrite", "Archive Rewrite", 2, {"object": 1, "name": 1}, "Melkion keeps rewriting the field.", "The archive rewrite stutters.")
        &"CH10_05":
            _start_boss_lock(boss_unit, &"karon_final_toll", "Final Toll", 3, {"object": 2, "name": 1}, "Every ally answers the bell.", "The bell line breaks.")
        _:
            pass

func _find_primary_stage_boss() -> UnitActor:
    for enemy in enemy_units:
        if is_instance_valid(enemy) and not enemy.is_defeated() and enemy.unit_data != null and enemy.unit_data.is_boss:
            return enemy
    return null

func _spawn_interactive_objects(objects: Array) -> void:
    for object_data in objects:
        var object_actor: InteractiveObjectActor = OBJECT_SCENE.instantiate() as InteractiveObjectActor
        if object_actor == null:
            continue

        object_actor.setup_from_data(object_data, stage_data.cell_size)
        objects_root.add_child(object_actor)
        interactive_objects.append(object_actor)

func _on_world_cell_pressed(cell: Vector2i) -> void:
    if hud.is_menu_open():
        return

    if not _is_player_input_phase() or not _is_cell_in_bounds(cell):
        return

    var enemy_at_cell: UnitActor = _find_unit_at(cell, enemy_units)
    if selected_unit != null and enemy_at_cell != null and _can_selected_unit_attack(enemy_at_cell):
        _transition_to(BattlePhase.PLAYER_ACTION_COMMIT, "player_attack_committed", {
            "attacker": selected_unit.unit_data.unit_id,
            "target": enemy_at_cell.unit_data.unit_id
        })
        _transition_to(BattlePhase.PLAYER_ACTION_RESOLVE, "player_attack_resolve", {"round": round_index})
        if _resolve_attack(selected_unit, enemy_at_cell):
            _complete_selected_unit_action("player_attack_completed")
        return

    var object_at_cell: InteractiveObjectActor = _find_object_at(cell)
    if selected_unit != null and object_at_cell != null and _can_selected_unit_interact(object_at_cell):
        _transition_to(BattlePhase.PLAYER_ACTION_COMMIT, "player_interact_committed", {
            "unit": selected_unit.unit_data.unit_id,
            "object": object_at_cell.object_data.object_id
        })
        _transition_to(BattlePhase.PLAYER_ACTION_RESOLVE, "player_interact_resolve", {"round": round_index})
        _resolve_interaction(selected_unit, object_at_cell)
        _complete_selected_unit_action("player_interact_completed")
        return
    elif selected_unit != null and object_at_cell != null:
        var interaction_destination: Vector2i = _get_selected_unit_interaction_destination(object_at_cell)
        if interaction_destination != Vector2i(-1, -1):
            _commit_player_move(interaction_destination)
            return

    var ally_at_cell: UnitActor = _find_unit_at(cell, ally_units)
    if ally_at_cell != null and turn_manager.can_unit_act(ally_at_cell):
        _select_unit(ally_at_cell)
        return

    if selected_unit == null:
        return

    if _can_selected_unit_move_to(cell):
        _commit_player_move(cell)
        return

    if cell == selected_unit.grid_position:
        grid_cursor.set_cell(cell)
        return

    _clear_selection()
    _transition_to(BattlePhase.PLAYER_SELECT, "player_selection_cleared", {"round": round_index})

func _select_unit(unit: UnitActor) -> void:
    if selected_unit != null and is_instance_valid(selected_unit):
        selected_unit.set_selected(false)

    selected_unit = unit
    selected_unit.set_selected(true)
    _evaluate_secret_hint_reveals("scout", selected_unit)
    _refresh_selected_action_options()

    _transition_to(BattlePhase.PLAYER_ACTION_PREVIEW, "player_unit_selected", {
        "unit": selected_unit.unit_data.unit_id,
        "reachable_count": reachable_cells.size(),
        "state": String(turn_manager.get_unit_state(selected_unit))
    })

func _refresh_selected_action_options() -> void:
    if selected_unit == null or not is_instance_valid(selected_unit):
        reachable_cells.clear()
        grid_cursor.visible = false
        grid_cursor.clear_reachable_cells()
        grid_cursor.clear_interactable_cells()
        _refresh_unit_visual_state()
        _sync_selection_hud()
        return

    var state: StringName = turn_manager.get_unit_state(selected_unit)
    if state == TurnManager.STATE_READY:
        reachable_cells = path_service.get_reachable_cells(
            selected_unit.grid_position,
            _get_effective_movement(selected_unit),
            _get_dynamic_blocked_cells(selected_unit)
        )
    else:
        reachable_cells.clear()

    grid_cursor.set_cell(selected_unit.grid_position)
    grid_cursor.set_reachable_cells(reachable_cells)
    grid_cursor.set_interactable_cells(_get_interactable_cells(selected_unit))
    grid_cursor.visible = true
    _refresh_unit_visual_state()
    _sync_selection_hud()

func _clear_selection() -> void:
    if selected_unit != null and is_instance_valid(selected_unit):
        selected_unit.set_selected(false)

    selected_unit = null
    reachable_cells.clear()
    grid_cursor.visible = false
    grid_cursor.clear_reachable_cells()
    grid_cursor.clear_interactable_cells()
    _refresh_unit_visual_state()
    _sync_selection_hud()

func _commit_player_move(destination: Vector2i) -> void:
    var unit_instance_id: int = selected_unit.get_instance_id()
    if not pending_move_origins.has(unit_instance_id):
        pending_move_origins[unit_instance_id] = selected_unit.grid_position
    var move_path: Array = path_service.find_path(
        selected_unit.grid_position,
        destination,
        _get_dynamic_blocked_cells(selected_unit)
    )

    _transition_to(BattlePhase.PLAYER_ACTION_COMMIT, "player_move_committed", {
        "unit": selected_unit.unit_data.unit_id,
        "to": destination
    })

    selected_unit.set_grid_position(destination, stage_data.cell_size, false, true)
    selected_unit.play_path_walk_visual(move_path, stage_data.cell_size)
    turn_manager.mark_moved(selected_unit, "player_move_committed", {"to": destination})
    _handle_stage_move_flags(selected_unit, destination)
    _evaluate_secret_hint_reveals("proximity", selected_unit)

    _refresh_selected_action_options()
    _transition_to(BattlePhase.PLAYER_ACTION_PREVIEW, "player_post_move_preview", {
        "unit": selected_unit.unit_data.unit_id,
        "attackable_targets": _get_attackable_enemy_count(selected_unit),
        "interactable_objects": _get_interactable_object_count(selected_unit)
    })
    _refresh_unit_visual_state()

func _complete_selected_unit_action(reason: String) -> void:
    if selected_unit == null:
        return

    var acting_unit: UnitActor = selected_unit

    if current_phase == BattlePhase.PLAYER_ACTION_COMMIT:
        _transition_to(BattlePhase.PLAYER_ACTION_RESOLVE, "player_action_resolve", {"round": round_index})

    if is_instance_valid(acting_unit):
        pending_move_origins.erase(acting_unit.get_instance_id())

    if is_instance_valid(acting_unit) and not acting_unit.is_defeated():
        turn_manager.mark_acted(acting_unit, reason, {"round": round_index})

    _clear_selection()
    _refresh_unit_visual_state()

    if _check_battle_end():
        return

    if turn_manager.is_phase_complete("ally", ally_units):
        _end_player_phase("all_player_units_exhausted")
    else:
        _transition_to(BattlePhase.PLAYER_SELECT, "player_next_selection", {
            "ready_units": turn_manager.get_ready_unit_count("ally", ally_units)
        })
        _focus_first_ready_unit_if_any()

func _begin_player_phase(reason: String) -> void:
    _transition_to(BattlePhase.PLAYER_PHASE_START, reason, {"round": round_index})

    turn_manager.begin_phase("ally", ally_units + enemy_units, reason)
    pending_move_origins.clear()
    _apply_player_skip_turns()
    _apply_terrain_effects()
    _tick_area_statuses()
    _tick_unit_visual_statuses()
    var charm_forced := _apply_charm_forced_actions()
    _clear_selection()
    _apply_synergy_reactions()
    _apply_weather_effects()
    _evaluate_secret_hint_reveals("turn_cadence")

    input_controller.cell_size = stage_data.cell_size
    input_controller.board_origin = board_origin
    grid_cursor.cell_size = stage_data.cell_size
    grid_cursor.position = board_origin

    _transition_to(BattlePhase.PLAYER_SELECT, "player_units_ready", {
        "ready_units": turn_manager.get_ready_unit_count("ally", ally_units)
    })
    _focus_first_ready_unit_if_any()
    if charm_forced and not last_charm_forced_details.is_empty():
        var charm_reason := "charm_restrained" if last_charm_forced_details.has("restrainer") else "charm_forced_attack"
        hud.set_transition_reason(charm_reason, last_charm_forced_details.duplicate(true))

func _end_player_phase(reason: String) -> void:
    _clear_selection()
    _handle_end_player_phase_boss_state()
    _transition_to(BattlePhase.PLAYER_PHASE_END, reason, {"round": round_index})
    _begin_enemy_phase("enemy_phase_open")

func _begin_enemy_phase(reason: String) -> void:
    _transition_to(BattlePhase.ENEMY_PHASE_START, reason, {"round": round_index})

    turn_manager.begin_phase("enemy", ally_units + enemy_units, reason)
    # Clear per-round bonuses; boss phase bonuses are re-applied in _check_boss_phase_transitions
    enemy_attack_bonus_by_unit.clear()
    enemy_movement_bonus_by_unit.clear()
    _tick_enemy_skill_cooldowns()
    _refresh_unit_visual_state()
    _clear_selection()

    call_deferred("_run_enemy_phase")

func _apply_player_skip_turns() -> void:
    var skipped_any: bool = false
    for unit in ally_units:
        if not is_instance_valid(unit) or unit.is_defeated():
            continue
        var unit_id: int = unit.get_instance_id()
        var skip_turns: int = int(player_skip_turns_by_unit.get(unit_id, 0))
        if skip_turns <= 0:
            continue
        skipped_any = true
        turn_manager.mark_acted(unit, "smoke_bomb_skip", {"round": round_index})
        player_skip_turns_by_unit[unit_id] = skip_turns - 1
        if int(player_skip_turns_by_unit.get(unit_id, 0)) <= 0:
            player_skip_turns_by_unit.erase(unit_id)
    if skipped_any:
        hud.set_transition_reason("lete_smoke_bomb", {"round": round_index})

func _handle_end_player_phase_boss_state() -> void:
    for enemy in enemy_units:
        if not is_instance_valid(enemy) or enemy.is_defeated() or enemy.unit_data == null:
            continue
        if enemy.unit_data.boss_pattern == &"karl_ch09a_05":
            var enemy_id: int = enemy.get_instance_id()
            if bool(boss_attacked_this_player_phase.get(enemy_id, false)):
                boss_untouched_player_turns[enemy_id] = 0
            else:
                boss_untouched_player_turns[enemy_id] = int(boss_untouched_player_turns.get(enemy_id, 0)) + 1

    boss_attacked_this_player_phase.clear()
    _tick_duration_map(enemy_damage_reduction_turns_by_unit, enemy_damage_multiplier_by_unit)
    _tick_duration_map(ignored_terrain_turns_by_unit)
    _tick_duration_map(bond_suppression_turns_by_unit)

func _tick_enemy_skill_cooldowns() -> void:
    for unit_id_variant in enemy_skill_cooldowns_by_unit.keys():
        var unit_id: int = int(unit_id_variant)
        var cooldowns: Dictionary = enemy_skill_cooldowns_by_unit.get(unit_id, {})
        for key in cooldowns.keys():
            cooldowns[key] = maxi(0, int(cooldowns.get(key, 0)) - 1)
            if int(cooldowns[key]) <= 0:
                cooldowns.erase(key)
        if cooldowns.is_empty():
            enemy_skill_cooldowns_by_unit.erase(unit_id)
        else:
            enemy_skill_cooldowns_by_unit[unit_id] = cooldowns

func _tick_duration_map(turns_map: Dictionary, payload_map: Dictionary = {}) -> void:
    for unit_id_variant in turns_map.keys():
        var unit_id: int = int(unit_id_variant)
        turns_map[unit_id] = maxi(0, int(turns_map.get(unit_id, 0)) - 1)
        if int(turns_map.get(unit_id, 0)) <= 0:
            turns_map.erase(unit_id)
            if not payload_map.is_empty():
                payload_map.erase(unit_id)

func _get_enemy_skill_cooldown(enemy: UnitActor, skill_key: StringName) -> int:
    if enemy == null or not is_instance_valid(enemy):
        return 0
    var cooldowns: Dictionary = enemy_skill_cooldowns_by_unit.get(enemy.get_instance_id(), {})
    return int(cooldowns.get(skill_key, 0))

func _set_enemy_skill_cooldown(enemy: UnitActor, skill_key: StringName, turns: int) -> void:
    if enemy == null or not is_instance_valid(enemy):
        return
    var enemy_id: int = enemy.get_instance_id()
    var cooldowns: Dictionary = enemy_skill_cooldowns_by_unit.get(enemy_id, {})
    cooldowns[skill_key] = turns
    enemy_skill_cooldowns_by_unit[enemy_id] = cooldowns

func _focus_first_ready_unit_if_any() -> void:
    if not _is_player_input_phase():
        return
    if selected_unit != null and is_instance_valid(selected_unit):
        return

    for unit in ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and turn_manager.can_unit_act(unit):
            _select_unit(unit)
            return

func _run_enemy_phase() -> void:
    var acted_count: int = 0

    # Check boss phase transitions at the start of enemy phase
    _check_boss_phase_transitions()

    for enemy in enemy_units.duplicate():
        if not is_instance_valid(enemy) or enemy.is_defeated() or not turn_manager.can_unit_act(enemy):
            continue

        _transition_to(BattlePhase.ENEMY_DECIDE, "enemy_decide", {
            "unit": enemy.unit_data.unit_id,
            "round": round_index
        })

        var action: Dictionary = _pick_enemy_action(enemy)

        _transition_to(BattlePhase.ENEMY_ACTION_RESOLVE, "enemy_action_resolve", {
            "unit": enemy.unit_data.unit_id,
            "action": action.get("type", "unknown")
        })

        _apply_enemy_action(enemy, action)
        if is_instance_valid(enemy) and not enemy.is_defeated():
            turn_manager.mark_acted(enemy, "enemy_action_complete", {"round": round_index})
        acted_count += 1

        _refresh_unit_visual_state()

        if _check_battle_end():
            return

    _transition_to(BattlePhase.ENEMY_PHASE_END, "enemy_phase_exhausted", {
        "acted_count": acted_count,
        "round": round_index
    })
    _update_stage_pressure_state()

    _transition_to(BattlePhase.ROUND_END, "round_completed", {"round": round_index})
    if telemetry_service != null:
        telemetry_service.record_round_complete(round_index)
    round_index += 1

    _begin_player_phase("next_round_started")

func _apply_enemy_action(enemy: UnitActor, action: Dictionary) -> void:
    var action_type: String = String(action.get("type", ""))
    if action_type == "apply_oblivion":
        var target: UnitActor = action.get("target", null)
        if target != null and is_instance_valid(target) and not target.is_defeated():
            var result: Dictionary = status_service.apply_stack(target, 1, "enemy_erosion")
            var new_stack: int = int(result.get("after", 0))
            telemetry_service.record_oblivion_applied(1)
            hud.set_transition_reason("oblivion_stack_applied", {
                "unit": enemy.unit_data.unit_id,
                "target": target.unit_data.unit_id,
                "stack_level": new_stack
            })
            _play_battle_flash(Color(0.4, 0.2, 0.6, 0.14), 0.16)
            _sync_hud_phase("oblivion_applied", {"target": target.unit_data.unit_id, "stack": new_stack})
        return
    if action_type == "boss_mark":
        var marked_target = action.get("target", null)
        if marked_target != null and is_instance_valid(marked_target) and not marked_target.is_defeated():
            boss_marked_target_id = marked_target.get_instance_id()
            boss_charge_pending = true
            _apply_boss_command_buff(enemy)
            _record_boss_event("boss_mark")
            _refresh_unit_visual_state()
            hud.set_transition_reason("boss_mark_telegraphed", {
                "unit": enemy.unit_data.unit_id,
                "target": marked_target.unit_data.unit_id,
                "effect": "charge_next_enemy_phase"
            })
            _play_battle_flash(Color(1.0, 0.552941, 0.776471, 0.16), 0.18)
            _play_world_fx("mark_ring.png", marked_target.grid_position, Color(1.0, 0.682353, 0.858824, 0.96), 0.34, 0.9)
        return
    if action_type == "smoke_bomb":
        _use_lete_smoke_bomb(enemy)
        return
    if action_type == "lete_scatter_cover":
        _use_lete_scatter_cover(enemy)
        return
    if action_type == "lete_shadow_feint":
        _use_lete_shadow_feint(enemy)
        return
    if action_type == "lete_black_hound_execute":
        _use_lete_black_hound_execute(enemy, action.get("target", null))
        return
    if action_type == "shield_wall":
        _use_karl_shield_wall(enemy)
        return
    if action_type == "hardren_trap_salvo":
        _use_hardren_trap_salvo(enemy)
        return
    if action_type == "resin_ignition":
        _use_resin_ignition(enemy)
        return
    if action_type == "archive_collapse":
        _use_archive_collapse(enemy)
        return
    if action_type == "valgar_fortify":
        _use_valgar_fortify(enemy)
        return
    if action_type == "formation_call":
        _use_karl_formation_call(enemy)
        return
    if action_type == "basil_altar_purge":
        _use_basil_altar_purge(enemy, action.get("skill", null))
        return
    if action_type == "hunt_basil_backwash_surge":
        _use_hunt_basil_backwash_surge(enemy)
        return
    if action_type == "saria_oblivion_field":
        _use_saria_oblivion_field(enemy)
        return
    if action_type == "hunt_saria_choir_break":
        _use_hunt_saria_choir_break(enemy)
        return
    if action_type == "memory_wipe":
        _use_melkion_memory_wipe(enemy)
        return
    if action_type == "melkion_revision_lock":
        _use_melkion_revision_lock(enemy)
        return
    if action_type == "melkion_revision_field":
        _use_melkion_revision_field(enemy)
        return
    if action_type == "melkion_revision_sentence":
        _use_melkion_revision_sentence(enemy)
        return
    if action_type == "karon_royal_edict":
        _use_karon_royal_edict(enemy)
        return
    if action_type == "karon_name_severance":
        _use_karon_name_severance(enemy)
        return
    if action_type == "karon_bell_of_erasure":
        _use_karon_bell_of_erasure(enemy)
        return
    if action_type == "karon_final_toll":
        _use_karon_final_toll(enemy)
        return
    if action_type == "all_out_attack":
        _use_karon_all_out_attack(enemy, action.get("skill", null))
        return

    var move_succeeded: bool = false
    if action.has("move_to"):
        var move_to: Vector2i = action["move_to"]
        if move_to == enemy.grid_position:
            move_succeeded = true
        elif _can_unit_legally_move_to(enemy, move_to):
            var enemy_move_path: Array = path_service.find_path(
                enemy.grid_position,
                move_to,
                _get_dynamic_blocked_cells(enemy)
            )
            enemy.set_grid_position(move_to, stage_data.cell_size, false, true)
            enemy.play_path_walk_visual(enemy_move_path, stage_data.cell_size)
            turn_manager.mark_moved(enemy, "enemy_move_committed", {"to": move_to})
            move_succeeded = true

    if action.has("target"):
        var target: UnitActor = action["target"]
        var skill_override: SkillData = action.get("skill", null)
        var can_attack: bool = target != null and is_instance_valid(target) and not target.is_defeated() and _is_skill_in_range(enemy, target, skill_override)
        if action_type == "move_attack" and action.has("move_to") and not move_succeeded:
            can_attack = false

        if can_attack:
            var extra_context: Dictionary = {}
            if enemy_attack_bonus_by_unit.has(enemy.get_instance_id()):
                extra_context["attack_bonus"] = int(enemy_attack_bonus_by_unit[enemy.get_instance_id()])
            if action_type == "boss_charge":
                extra_context["attack_bonus"] = int(extra_context.get("attack_bonus", 0)) + 1
                _record_boss_event("boss_charge")
                hud.set_transition_reason("boss_charge_resolve", {
                    "unit": enemy.unit_data.unit_id,
                    "target": target.unit_data.unit_id
                })
                _play_battle_flash(Color(1.0, 0.701961, 0.701961, 0.18), 0.16)
                _play_world_fx("hit_spark.png", target.grid_position, Color(1.0, 0.780392, 0.741176, 0.98), 0.28, 1.0)
                boss_charge_pending = false
                boss_marked_target_id = -1
            if not bool(action.get("allow_counterattack", true)):
                extra_context["allow_counterattack"] = false
            _resolve_attack(enemy, target, extra_context, skill_override)
            match action_type:
                "reckless_charge":
                    if target != null and is_instance_valid(target) and _get_unit_visual_status_turns(target, &"mark") > 0:
                        _set_unit_visual_status(target, &"mark", 0)
                        battle_objective_flags["lete_marked_pursuit"] = true
                    _record_boss_event("lete_reckless_charge")
                "truth_rewrite":
                    battle_objective_flags["melkion_truth_revealed"] = true
                    _set_enemy_skill_cooldown(enemy, &"truth_rewrite", 2)
                    hud.set_transition_reason("melkion_truth_rewrite", {
                        "unit": enemy.unit_data.unit_id,
                        "skill": String(action.get("copied_skill_id", &"basic_attack"))
                    })
                "shield_bash", "formation_break", "erase_truth", "truth_read", "imperial_edict", "last_bastion", "ranged_harass":
                    pass
                "shield_break":
                    _set_enemy_skill_cooldown(enemy, &"shield_break", 2)
                "basil_purge":
                    _set_enemy_skill_cooldown(enemy, &"basil_purge", 3)
                "banner_betrayal":
                    _set_enemy_skill_cooldown(enemy, &"banner_betrayal", 2)
                "saria_oblivion_zone":
                    _set_enemy_skill_cooldown(enemy, &"saria_oblivion_zone", 2)
                "charm_gaze":
                    battle_objective_flags["saria_mind_control_active"] = true
                    _set_enemy_skill_cooldown(enemy, &"charm_gaze", 2)
                    hud.set_transition_reason("mind_control_applied", {
                        "unit": enemy.unit_data.unit_id,
                        "target": target.unit_data.unit_id if target != null and target.unit_data != null else &"",
                        "skill": "charm_gaze"
                    })
                "memory_burn":
                    _set_enemy_skill_cooldown(enemy, &"memory_burn", 2)
        elif action.has("target"):
            hud.set_transition_reason("enemy_attack_cancelled", {
                "unit": enemy.unit_data.unit_id,
                "reason": "target_out_of_range_after_move"
            })

func _is_skill_in_range(attacker: UnitActor, defender: UnitActor, skill: SkillData = null) -> bool:
    if attacker == null or defender == null:
        return false
    var range_value: int = _get_effective_skill_range(attacker, skill)
    var attack_cells: Array = range_service.get_attack_cells(attacker.grid_position, range_value)
    return defender.grid_position in attack_cells

func _use_lete_smoke_bomb(enemy: UnitActor) -> void:
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        player_skip_turns_by_unit[ally.get_instance_id()] = 1
    _set_enemy_skill_cooldown(enemy, &"smoke_bomb", 3)
    _record_boss_event("lete_smoke_bomb")
    hud.set_transition_reason("lete_smoke_bomb", {"unit": enemy.unit_data.unit_id, "round": round_index})
    _play_battle_flash(Color(0.55, 0.55, 0.6, 0.2), 0.18)

func _use_lete_shadow_feint(enemy: UnitActor) -> void:
    var target: UnitActor = ai_service._find_nearest_target(enemy, ally_units)
    if target == null:
        return
    _set_unit_visual_status(target, &"mark", 2)
    _set_enemy_skill_cooldown(enemy, &"pin_shot", 2)
    _record_boss_event("lete_shadow_feint")
    battle_objective_flags["lete_shadow_feint"] = true
    hud.set_transition_reason("assassin_mark_applied", {"unit": enemy.unit_data.unit_id, "target": target.unit_data.unit_id})
    _play_world_fx("mark_ring.png", target.grid_position, Color(0.98, 0.72, 0.58, 0.94), 0.28, 0.96)
    _play_battle_flash(Color(0.42, 0.42, 0.48, 0.16), 0.14)

func _use_lete_scatter_cover(enemy: UnitActor) -> void:
    for enemy_unit in enemy_units:
        if not is_instance_valid(enemy_unit) or enemy_unit.is_defeated():
            continue
        ignored_terrain_turns_by_unit[enemy_unit.get_instance_id()] = maxi(int(ignored_terrain_turns_by_unit.get(enemy_unit.get_instance_id(), 0)), 2)
        enemy_movement_bonus_by_unit[enemy_unit.get_instance_id()] = int(enemy_movement_bonus_by_unit.get(enemy_unit.get_instance_id(), 0)) + 1
    _set_enemy_skill_cooldown(enemy, &"scatter_cover", 3)
    _record_boss_event("lete_scatter_cover")
    battle_objective_flags["black_hound_scattered"] = true
    hud.set_transition_reason("lete_scatter_cover", {"unit": enemy.unit_data.unit_id, "turns": 2})
    _play_battle_flash(Color(0.64, 0.64, 0.72, 0.18), 0.18)

func _use_lete_black_hound_execute(enemy: UnitActor, target: UnitActor) -> void:
    if target == null or not is_instance_valid(target) or target.is_defeated():
        target = _get_marked_ally_target(enemy)
    if target == null:
        return
    _set_unit_visual_status(target, &"fear", 1)
    _set_unit_visual_status(target, &"mark", maxi(_get_unit_visual_status_turns(target, &"mark"), 1))
    battle_objective_flags["lete_black_hound_execute"] = true
    _record_boss_event("lete_black_hound_execute")
    hud.set_transition_reason("lete_black_hound_execute", {"unit": enemy.unit_data.unit_id, "target": target.unit_data.unit_id})
    _play_battle_flash(Color(0.92, 0.34, 0.28, 0.2), 0.16)
    _play_world_fx("hit_spark.png", target.grid_position, Color(1.0, 0.54, 0.44, 0.94), 0.32, 1.04)

func _use_karl_shield_wall(enemy: UnitActor) -> void:
    var enemy_id: int = enemy.get_instance_id()
    enemy_damage_multiplier_by_unit[enemy_id] = 0.5
    enemy_damage_reduction_turns_by_unit[enemy_id] = 2
    _set_enemy_skill_cooldown(enemy, &"shield_wall", 3)
    _record_boss_event("karl_shield_wall")
    hud.set_transition_reason("karl_shield_wall", {"unit": enemy.unit_data.unit_id, "turns": 2})
    _play_battle_flash(Color(0.65, 0.72, 0.92, 0.18), 0.18)

func _use_hardren_trap_salvo(enemy: UnitActor) -> void:
    _set_enemy_skill_cooldown(enemy, &"hardren_trap_salvo", 3)
    _record_boss_event("hardren_trap_salvo")
    _deal_area_damage(2, 1, ["destructible"])
    var trap_count: int = _increment_runtime_counter("ch02_trap_salvo_count")
    battle_objective_flags["hardren_trap_salvo"] = true
    if trap_count >= 3:
        battle_objective_flags["activate_3_traps"] = true
    hud.set_transition_reason("hardren_trap_salvo", {"unit": enemy.unit_data.unit_id, "effect": "barricade_traps", "trap_count": trap_count})
    _play_battle_flash(Color(0.86, 0.62, 0.42, 0.18), 0.18)

func _use_resin_ignition(enemy: UnitActor) -> void:
    _set_enemy_skill_cooldown(enemy, &"resin_ignition", 3)
    _record_boss_event("resin_ignition")
    var ignition_sources: Array[String] = ["fire"]
    if get_boss_phase_for_unit(enemy) == &"shrine_burn":
        ignition_sources.append("sacred_ground")
        battle_objective_flags.erase("no_structures_destroyed")
        battle_objective_flags["resin_shrine_scorched"] = true
    _spread_terrain_feature("fire", 1, ignition_sources)
    _deal_area_damage(2, 1, ["fire"])
    battle_objective_flags["resin_ignition"] = true
    hud.set_transition_reason("resin_ignition", {"unit": enemy.unit_data.unit_id, "effect": "wildfire_spread"})
    _play_battle_flash(Color(0.95, 0.45, 0.22, 0.22), 0.2)

func _use_archive_collapse(enemy: UnitActor) -> void:
    _set_enemy_skill_cooldown(enemy, &"archive_collapse", 3)
    _record_boss_event("archive_collapse")
    _spread_fire()
    _spread_terrain_feature("fire", 1, ["fire", "destructible"])
    _deal_area_damage(3, 1, ["fire"])
    var ledger_count: int = _increment_runtime_counter("ch05_ledger_collapse_count")
    battle_objective_flags["archive_collapse"] = true
    if ledger_count >= 3:
        battle_objective_flags["collect_3_ledger_entries"] = true
    hud.set_transition_reason("archive_collapse", {"unit": enemy.unit_data.unit_id, "effect": "ashfire_spread", "ledger_count": ledger_count})
    _play_battle_flash(Color(0.88, 0.46, 0.18, 0.2), 0.2)

func _use_valgar_fortify(enemy: UnitActor) -> void:
    for enemy_unit in enemy_units:
        if not is_instance_valid(enemy_unit) or enemy_unit.is_defeated():
            continue
        var distance: int = abs(enemy_unit.grid_position.x - enemy.grid_position.x) + abs(enemy_unit.grid_position.y - enemy.grid_position.y)
        if enemy_unit == enemy or distance <= 2:
            enemy_damage_multiplier_by_unit[enemy_unit.get_instance_id()] = 0.75
            enemy_damage_reduction_turns_by_unit[enemy_unit.get_instance_id()] = 2
    _set_enemy_skill_cooldown(enemy, &"valgar_fortify", 3)
    _record_boss_event("valgar_fortify")
    battle_objective_flags["valgar_fortified"] = true
    hud.set_transition_reason("valgar_fortify", {"unit": enemy.unit_data.unit_id, "radius": 2, "effect": "incoming_damage_down"})
    _play_battle_flash(Color(0.62, 0.72, 0.82, 0.18), 0.18)
    _play_world_fx("mark_ring.png", enemy.grid_position, Color(0.74, 0.82, 0.9, 0.96), 0.34, 1.0)

func _use_karl_formation_call(enemy: UnitActor) -> void:
    var reinforcement: UnitActor = _spawn_runtime_enemy(
        _create_reinforcement_vanguard_data(),
        enemy.grid_position,
        [
            enemy.grid_position + Vector2i(-1, 0),
            enemy.grid_position + Vector2i(1, 0),
            enemy.grid_position + Vector2i(0, 1),
            enemy.grid_position + Vector2i(0, -1)
        ]
    )
    boss_untouched_player_turns[enemy.get_instance_id()] = 0
    if reinforcement != null:
        _record_boss_event("karl_formation_call")
        battle_objective_flags["karl_testifies"] = true
        hud.set_transition_reason("karl_formation_call", {"unit": enemy.unit_data.unit_id, "reinforcement": reinforcement.unit_data.unit_id})
        _play_battle_flash(Color(0.82, 0.86, 1.0, 0.16), 0.18)

func _use_melkion_memory_wipe(enemy: UnitActor) -> void:
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        if stage_data.get_defense_bonus(ally.grid_position) > 0:
            ignored_terrain_turns_by_unit[ally.get_instance_id()] = 1
        else:
            bond_suppression_turns_by_unit[ally.get_instance_id()] = 1
    _set_enemy_skill_cooldown(enemy, &"memory_wipe", 3)
    _record_boss_event("melkion_memory_wipe")
    hud.set_transition_reason("melkion_memory_wipe", {"unit": enemy.unit_data.unit_id, "round": round_index})
    _play_battle_flash(Color(0.56, 0.34, 0.7, 0.18), 0.2)

func _use_melkion_revision_field(enemy: UnitActor) -> void:
    var marked_count: int = 0
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        _set_unit_visual_status(ally, &"mark", 2)
        ignored_terrain_turns_by_unit[ally.get_instance_id()] = maxi(int(ignored_terrain_turns_by_unit.get(ally.get_instance_id(), 0)), 1)
        marked_count += 1
    _set_enemy_skill_cooldown(enemy, &"true_read", 3)
    _record_boss_event("melkion_revision_field")
    battle_objective_flags["melkion_revision_field"] = true
    hud.set_transition_reason("melkion_truth_rewrite", {"unit": enemy.unit_data.unit_id, "targets": marked_count, "skill": "revision_field"})
    _play_battle_flash(Color(0.56, 0.38, 0.76, 0.2), 0.2)
    _play_world_fx("mark_ring.png", enemy.grid_position, Color(0.82, 0.72, 1.0, 0.92), 0.34, 1.08)

func _use_melkion_revision_lock(enemy: UnitActor) -> void:
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        _set_unit_visual_status(ally, &"mark", 2)
        bond_suppression_turns_by_unit[ally.get_instance_id()] = maxi(int(bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)), 1)
    _set_enemy_skill_cooldown(enemy, &"true_read", 3)
    _record_boss_event("melkion_revision_lock")
    battle_objective_flags["melkion_revision_lock"] = true
    hud.set_transition_reason("melkion_revision_lock", {"unit": enemy.unit_data.unit_id, "turns": 2})
    _play_battle_flash(Color(0.66, 0.5, 0.88, 0.18), 0.2)

func _use_melkion_revision_sentence(enemy: UnitActor) -> void:
    var marked_count: int = 0
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        if _get_unit_visual_status_turns(ally, &"mark") <= 0:
            continue
        _set_unit_visual_status(ally, &"mark", maxi(_get_unit_visual_status_turns(ally, &"mark"), 2))
        bond_suppression_turns_by_unit[ally.get_instance_id()] = maxi(int(bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)), 2)
        ignored_terrain_turns_by_unit[ally.get_instance_id()] = maxi(int(ignored_terrain_turns_by_unit.get(ally.get_instance_id(), 0)), 2)
        marked_count += 1
    if marked_count <= 0:
        return
    battle_objective_flags["melkion_revision_sentence"] = true
    _record_boss_event("melkion_revision_sentence")
    hud.set_transition_reason("melkion_revision_sentence", {"unit": enemy.unit_data.unit_id, "targets": marked_count})
    _play_battle_flash(Color(0.7, 0.52, 0.92, 0.2), 0.18)
    _play_world_fx("mark_ring.png", enemy.grid_position, Color(0.86, 0.76, 1.0, 0.94), 0.38, 1.12)

func _use_basil_altar_purge(enemy: UnitActor, skill: SkillData) -> void:
    if skill == null:
        return
    _set_enemy_skill_cooldown(enemy, &"basil_purge", 3)
    _record_boss_event("basil_altar_purge")
    battle_objective_flags["basil_altar_purged"] = true
    for ally in ally_units.duplicate():
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        if _distance_between_cells(enemy.grid_position, ally.grid_position) <= 2:
            _resolve_attack(enemy, ally, {"allow_counterattack": false}, skill)
    hud.set_transition_reason("basil_altar_purge", {"unit": enemy.unit_data.unit_id, "radius": 2})
    _play_battle_flash(Color(0.95, 0.82, 0.58, 0.2), 0.22)
    _play_world_fx("objective_burst.png", enemy.grid_position, Color(1.0, 0.88, 0.62, 0.98), 0.4, 1.0)

func _use_hunt_basil_backwash_surge(enemy: UnitActor) -> void:
    for candidate in [Vector2i(4, 2), Vector2i(5, 2)]:
        if not _is_cell_in_bounds(candidate):
            continue
        stage_data.terrain_types[candidate] = &"flooded"
        stage_data.terrain_move_costs[candidate] = 2
        stage_data.terrain_defense_bonuses[candidate] = 1
    battle_objective_flags["hunt_basil_backwash_surge"] = true
    _record_boss_event("hunt_basil_backwash_surge")
    hud.set_transition_reason("hunt_basil_backwash_surge", {"unit": enemy.unit_data.unit_id, "lane": "central"})
    _play_battle_flash(Color(0.36, 0.58, 0.82, 0.2), 0.18)
    if battle_board != null:
        battle_board.queue_redraw()

func _use_saria_oblivion_field(enemy: UnitActor) -> void:
    if status_service == null:
        return
    _set_enemy_skill_cooldown(enemy, &"saria_oblivion_zone", 3)
    _record_boss_event("saria_oblivion_field")
    battle_objective_flags["saria_oblivion_field_active"] = true
    _active_area_statuses.append({
        "status": "oblivion_field",
        "effect": "oblivion_zone",
        "center": enemy.grid_position,
        "radius": 2,
        "remaining_turns": 2
    })
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        if _distance_between_cells(enemy.grid_position, ally.grid_position) <= 2:
            status_service.apply_stack(ally, 1, "saria_oblivion_zone")
    hud.set_transition_reason("saria_oblivion_field", {"unit": enemy.unit_data.unit_id, "radius": 2})
    _play_battle_flash(Color(0.56, 0.34, 0.7, 0.18), 0.22)
    _play_world_fx("mark_ring.png", enemy.grid_position, Color(0.72, 0.54, 0.88, 0.98), 0.42, 1.0)

func _use_hunt_saria_choir_break(enemy: UnitActor) -> void:
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        _set_unit_visual_status(ally, &"fear", 1)
        _set_unit_visual_status(ally, &"mark", maxi(_get_unit_visual_status_turns(ally, &"mark"), 1))
        bond_suppression_turns_by_unit[ally.get_instance_id()] = maxi(int(bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)), 1)
    battle_objective_flags["hunt_saria_choir_break"] = true
    _record_boss_event("hunt_saria_choir_break")
    hud.set_transition_reason("hunt_saria_choir_break", {"unit": enemy.unit_data.unit_id, "targets": ally_units.size()})
    _play_battle_flash(Color(0.7, 0.44, 0.84, 0.22), 0.18)

func _use_karon_all_out_attack(enemy: UnitActor, skill: SkillData) -> void:
    if skill == null:
        return
    _set_enemy_skill_cooldown(enemy, &"all_out_attack", 3)
    _record_boss_event("karon_all_out_attack")
    hud.set_transition_reason("karon_phase_two", {"unit": enemy.unit_data.unit_id, "round": round_index})
    for ally in ally_units.duplicate():
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        _resolve_attack(enemy, ally, {"allow_counterattack": false}, skill)

func _use_karon_royal_edict(enemy: UnitActor) -> void:
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        bond_suppression_turns_by_unit[ally.get_instance_id()] = maxi(int(bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)), 1)
    _set_enemy_skill_cooldown(enemy, &"royal_edict", 3)
    _record_boss_event("karon_royal_edict")
    battle_objective_flags["karon_royal_edict"] = true
    hud.set_transition_reason("karon_royal_edict", {"unit": enemy.unit_data.unit_id, "effect": "bond_suppression"})
    _play_battle_flash(Color(0.9, 0.74, 0.52, 0.2), 0.2)

func _use_karon_name_severance(enemy: UnitActor) -> void:
    if status_service == null:
        return
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        status_service.apply_stack(ally, 1, "karon_name_severance")
    _set_enemy_skill_cooldown(enemy, &"name_severance", 3)
    _record_boss_event("karon_name_severance")
    battle_objective_flags["karon_name_severance"] = true
    hud.set_transition_reason("karon_name_severance", {"unit": enemy.unit_data.unit_id, "effect": "party_oblivion"})
    _play_battle_flash(Color(0.96, 0.72, 0.54, 0.24), 0.24)
    _play_world_fx("hit_spark.png", enemy.grid_position, Color(1.0, 0.82, 0.64, 0.96), 0.44, 1.1)

func _use_karon_final_toll(enemy: UnitActor) -> void:
    if status_service == null:
        return
    if _is_boss_lock_broken(enemy):
        _set_enemy_skill_cooldown(enemy, &"all_out_attack", 1)
        _record_boss_event("karon_final_toll_broken")
        battle_objective_flags["karon_final_toll_broken"] = true
        battle_objective_flags.erase("karon_final_toll")
        _refresh_objective_surfaces()
        hud.set_transition_reason("boss_lock_broken", {
            "unit": enemy.unit_data.unit_id if enemy != null and enemy.unit_data != null else &"",
            "action": "Final Toll",
            "outcome": "downgraded",
            "break_text": String(_get_boss_lock_state(enemy).get("break_text", "The charged action weakens."))
        })
        _play_battle_flash(Color(0.58, 0.86, 1.0, 0.18), 0.18)
        return
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        status_service.apply_stack(ally, 1, "karon_final_toll")
        _set_unit_visual_status(ally, &"mark", 1)
        bond_suppression_turns_by_unit[ally.get_instance_id()] = maxi(int(bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)), 2)
    _set_enemy_skill_cooldown(enemy, &"all_out_attack", 2)
    _record_boss_event("karon_final_toll")
    battle_objective_flags["karon_final_toll"] = true
    battle_objective_flags.erase("karon_final_toll_broken")
    _refresh_objective_surfaces()
    hud.set_transition_reason("boss_lock_unbroken", {
        "unit": enemy.unit_data.unit_id if enemy != null and enemy.unit_data != null else &"",
        "action": "Final Toll",
        "outcome": "pressure_applied",
        "failure_text": String(_get_boss_lock_state(enemy).get("failure_text", "The charged action lands."))
    })
    _play_battle_flash(Color(1.0, 0.78, 0.62, 0.26), 0.26)
    _play_world_fx("hit_spark.png", enemy.grid_position, Color(1.0, 0.88, 0.72, 0.98), 0.48, 1.18)

func _create_reinforcement_vanguard_data() -> UnitData:
    var reinforcement: UnitData = ALLY_VANGUARD_DATA.duplicate(true)
    reinforcement.unit_id = &"reinforcement_vanguard"
    reinforcement.display_name = "Reinforcement Vanguard"
    reinforcement.faction = "enemy"
    reinforcement.max_hp = 1
    reinforcement.attack = 3
    reinforcement.defense = 0
    reinforcement.movement = 3
    reinforcement.attack_range = 1
    return reinforcement

func _create_name_call_anchor_data() -> UnitData:
    var anchor: UnitData = ALLY_VANGUARD_DATA.duplicate(true)
    anchor.unit_id = &"enemy_name_call_anchor"
    anchor.display_name = "Name-Call Anchor"
    anchor.faction = "enemy"
    anchor.max_hp = 1
    anchor.attack = 2
    anchor.defense = 0
    anchor.movement = 2
    anchor.attack_range = 1
    return anchor

func _has_living_enemy_with_unit_id(target_unit_id: StringName) -> bool:
    for enemy in enemy_units:
        if is_instance_valid(enemy) and not enemy.is_defeated() and enemy.unit_data != null and enemy.unit_data.unit_id == target_unit_id:
            return true
    return false

func _resolve_attack(attacker: UnitActor, defender: UnitActor, extra_context: Dictionary = {}, skill_override: SkillData = null) -> bool:
    var attack_context: Dictionary = _build_attack_context(attacker, defender, extra_context)
    var resolved_skill: SkillData = skill_override if skill_override != null else attacker.get_default_skill()
    if attacker != null and is_instance_valid(attacker) and attacker.faction == "ally" and resolved_skill != null and resolved_skill.has_resource_cost():
        if not attacker.can_afford_skill_cost(resolved_skill):
            hud.set_transition_reason("skill_insufficient_resource", {
                "unit": attacker.unit_data.unit_id if attacker.unit_data != null else &"",
                "skill": resolved_skill.skill_id,
                "cost": resolved_skill.get_resource_cost_text()
            })
            _sync_selection_hud()
            return false
        attacker.spend_skill_cost(resolved_skill)
        _sync_selection_hud()

    var result: Dictionary = combat_service.resolve_attack(attacker, defender, resolved_skill, {
        "defense_bonus": attack_context.get("defense_bonus", 0),
        "terrain_type": attack_context.get("terrain_type", "plain"),
        "allow_counterattack": attack_context.get("allow_counterattack", true),
        "attack_bonus": attack_context.get("attack_bonus", 0),
        "damage_multiplier": attack_context.get("damage_multiplier", 1.0),
        "counter_context": attack_context.get("counter_context", {}),
        "oblivion_accuracy_mod": attack_context.get("oblivion_accuracy_mod", 0),
        "oblivion_skills_sealed": attack_context.get("oblivion_skills_sealed", false)
    })
    _apply_visual_status_from_skill(defender, resolved_skill, result)
    _progress_boss_lock_from_player_attack(attacker, defender, resolved_skill, result, skill_override)
    var reason: String = String(result.get("transition_reason", "attack_resolved"))
    _play_attack_feedback(reason)

    # 데미지 타입에 따른 팝업 표시 (MISS/GUARD는 apply_damage에서 자동 표시되지 않으므로)
    if reason == "attack_missed" or reason == "attack_missed_counter_resolved":
        defender.show_damage(0, &"miss")
    elif bool(result.get("guard", false)):
        defender.show_damage(int(result.get("damage", 0)), &"guard")
    elif reason == "attack_resolved_deterministic" or reason == "attack_resolved":
        var dmg: int = int(result.get("damage", 0))
        var hp_before: int = int(result.get("defender_hp_before", defender.current_hp + dmg))
        if dmg >= hp_before * 2 and dmg > 0:
            defender.show_damage(dmg, &"critical")
        # 일반 데미지 팝업은 apply_damage()에서 자동 표시됨

    # 공격 애니메이션: 공격자가 타겟 방향으로 전진 후 복귀
    if attacker != null and is_instance_valid(attacker) and not attacker.is_defeated():
        _play_attack_timing_signature(attacker, defender, resolved_skill)
        _play_attack_sequence_fx(attacker, defender, resolved_skill)
        attacker.play_attack_animation(defender.grid_position, stage_data.cell_size.x)

    var damage_share_triggered := false
    if defender.faction == "ally" and bond_service != null and int(result.get("damage", 0)) > 0 and not bool(extra_context.get("suppress_support_logic", false)):
        damage_share_triggered = _try_resolve_damage_share(defender, int(result.get("damage", 0)))

    hud.set_transition_reason(reason, {
        "attacker": attacker.unit_data.unit_id,
        "defender": defender.unit_data.unit_id,
        "damage": result.get("damage", 0),
        "round": round_index,
        "terrain_type": String(stage_data.get_terrain_type(defender.grid_position))
    })

    if damage_share_triggered and not last_damage_share_details.is_empty():
        hud.set_transition_reason("bond_damage_share", last_damage_share_details.duplicate(true))

    if bool(result.get("defender_defeated", false)):
        if attacker != null and attacker.unit_data != null and defender != null and defender.unit_data != null and defender.unit_data.is_boss:
            battle_objective_flags["boss_defeated_by:%s" % String(attacker.unit_data.unit_id)] = true
            if stage_data != null and stage_data.stage_id == &"CH03_05" and attacker.unit_data.unit_id == &"ally_scout":
                battle_objective_flags["tia_defeats_enemy_boss"] = true
        _remove_unit_from_roster(defender)

    if attacker.faction == "ally":
        last_player_skill_used = resolved_skill
        if defender.faction == "enemy" and defender.unit_data != null and defender.unit_data.is_boss:
            boss_attacked_this_player_phase[defender.get_instance_id()] = true

    var counterattack: Dictionary = result.get("counterattack", {})
    if bool(counterattack.get("triggered", false)):
        _apply_visual_status_from_skill(attacker, defender.get_default_skill(), counterattack)
    if bool(counterattack.get("triggered", false)):
        hud.set_transition_reason("counterattack_resolved", {
            "attacker": defender.unit_data.unit_id,
            "defender": attacker.unit_data.unit_id,
            "damage": counterattack.get("damage", 0),
            "round": round_index
        })
        if bool(counterattack.get("target_defeated", false)):
            _remove_unit_from_roster(attacker)

    # 지원 공격: 공격자가 아군이고 인접 동료 중 bond 3+ 있으면 발동
    var support_attack_triggered := false
    if attacker.faction == "ally" and bond_service != null and is_instance_valid(attacker) and not attacker.is_defeated() and not bool(result.get("defender_defeated", false)) and not bool(extra_context.get("suppress_support_logic", false)):
        support_attack_triggered = _try_resolve_support_attack(attacker, defender)

    var follow_up_payload := {
        "attacker": attacker.unit_data.unit_id,
        "defender": defender.unit_data.unit_id,
        "round": round_index
    }
    if support_attack_triggered and not last_support_attack_details.is_empty():
        follow_up_payload = last_support_attack_details.duplicate(true)
    elif damage_share_triggered and not last_damage_share_details.is_empty():
        follow_up_payload = last_damage_share_details.duplicate(true)

    if support_attack_triggered:
        _sync_hud_phase("support_attack_resolved", follow_up_payload)
    elif damage_share_triggered:
        _sync_hud_phase("bond_damage_share", follow_up_payload)
    else:
        _sync_hud_phase(reason, follow_up_payload)
    return true

func _try_resolve_support_attack(attacker: UnitActor, defender: UnitActor) -> bool:
    for unit: UnitActor in ally_units:
        if unit == attacker or not is_instance_valid(unit) or unit.is_defeated():
            continue
        if bond_service.can_support_attack(attacker, unit):
            _resolve_support_attack(unit, defender)
            return true  # 첫 번째 지원자만
    return false

func _try_resolve_damage_share(defender: UnitActor, original_damage: int) -> bool:
    if defender == null or not is_instance_valid(defender) or defender.is_defeated() and original_damage <= 0:
        return false
    var share_candidates: Array[UnitActor] = []
    for unit: UnitActor in ally_units:
        if unit == defender or not is_instance_valid(unit) or unit.is_defeated():
            continue
        if bond_service.get_bond(unit.unit_data.unit_id) < BondService.MAX_BOND:
            continue
        var dist: int = abs(defender.grid_position.x - unit.grid_position.x) + abs(defender.grid_position.y - unit.grid_position.y)
        if dist <= 1:
            share_candidates.append(unit)
    if share_candidates.is_empty():
        return false

    var sharer: UnitActor = share_candidates[0]
    var share_ratio: float = 0.5
    var passive_card_id: StringName = &""
    if _has_unlocked_passive_card(&"guard_share_plus"):
        share_ratio = float(progression_service.get_passive_card_definition(&"guard_share_plus").get("shared_ratio", 0.65))
        passive_card_id = &"guard_share_plus"
    var shared_damage: int = maxi(1, int(ceil(float(original_damage) * share_ratio)))
    _play_world_fx("mark_ring.png", sharer.grid_position, Color(0.64, 1.0, 0.82, 0.9), 0.22, 0.86)
    _play_world_fx("objective_burst.png", defender.grid_position, Color(0.72, 0.96, 1.0, 0.92), 0.22, 0.9)
    defender.apply_heal(shared_damage)
    sharer.apply_damage(shared_damage)
    last_damage_share_details = {
        "target": defender.unit_data.unit_id,
        "sharer": sharer.unit_data.unit_id,
        "bond": bond_service.get_bond(sharer.unit_data.unit_id),
        "shared_damage": shared_damage,
        "shared_ratio": share_ratio,
        "passive_card_id": passive_card_id,
        "round": round_index
    }
    if sharer.is_defeated():
        _remove_unit_from_roster(sharer)
    return true

func _resolve_support_attack(supporter: UnitActor, defender: UnitActor) -> void:
    var support_context := _build_attack_context(supporter, defender, {
        "attack_bonus": -2,
        "allow_counterattack": false
    }, false)
    var support_result: Dictionary = combat_service.resolve_attack(supporter, defender, supporter.get_default_skill(), {
        "defense_bonus": support_context.get("defense_bonus", 0),
        "terrain_type": support_context.get("terrain_type", "plain"),
        "allow_counterattack": false,
        "attack_bonus": support_context.get("attack_bonus", 0),
        "damage_multiplier": support_context.get("damage_multiplier", 1.0),
        "counter_context": support_context.get("counter_context", {}),
        "oblivion_accuracy_mod": support_context.get("oblivion_accuracy_mod", 0),
        "oblivion_skills_sealed": support_context.get("oblivion_skills_sealed", false)
    })
    _apply_visual_status_from_skill(defender, supporter.get_default_skill(), support_result)
    if telemetry_service != null:
        telemetry_service.record_command_use(&"support_attack")
    _play_world_fx("objective_burst.png", supporter.grid_position, Color(0.54, 0.88, 1.0, 0.9), 0.2, 0.84)
    _play_world_fx("mark_ring.png", defender.grid_position, Color(0.74, 0.9, 1.0, 0.94), 0.22, 0.88)
    # 지원 공격 데미지 팝업
    var support_dmg: int = int(support_result.get("damage", 0))
    var support_bond: int = bond_service.get_bond(supporter.unit_data.unit_id) if bond_service != null else 0
    if support_dmg > 0:
        defender.show_damage(support_dmg, &"damage")
    else:
        defender.show_damage(0, &"miss")
    last_support_attack_details = {
        "supporter": supporter.unit_data.unit_id,
        "defender": defender.unit_data.unit_id,
        "bond": support_bond,
        "damage": support_result.get("damage", 0),
        "round": round_index
    }
    hud.set_transition_reason("support_attack_resolved", last_support_attack_details)
    if bool(support_result.get("defender_defeated", false)):
        _remove_unit_from_roster(defender)

func _resolve_interaction(unit: UnitActor, object_actor: InteractiveObjectActor) -> void:
    var result: Dictionary = object_actor.resolve_interaction(unit)
    if not bool(result.get("resolved", false)):
        hud.set_transition_reason("interaction_rejected", {
            "unit": unit.unit_data.unit_id,
            "object": result.get("object_id", &"interactive_object"),
            "reason": result.get("reason", "unavailable")
        })
        _sync_hud_phase("interaction_rejected", {
            "unit": unit.unit_data.unit_id,
            "object": result.get("object_id", &"interactive_object"),
            "reason": result.get("reason", "unavailable")
        })
        return

    _handle_stage_interaction_flags(result.get("object_id", &"interactive_object"))
    _progress_boss_lock_for_event(&"object")
    var reward_detail: String = _format_interaction_detail(result)
    var objective_state: Dictionary = get_objective_state_snapshot()
    _record_reward_entry(reward_detail)
    _play_battle_flash(Color(1.0, 0.913725, 0.627451, 0.16), 0.16)
    _play_world_fx("objective_burst.png", object_actor.grid_position, Color(1.0, 0.905882, 0.627451, 0.98), 0.34, 0.92)
    hud.set_transition_reason("interaction_resolved", {
        "unit": unit.unit_data.unit_id,
        "object": result.get("object_id", &"interactive_object"),
        "detail": reward_detail,
        "objective_state": objective_state.get("state_id", &"battle_objective_default"),
        "resolved_interactions": objective_state.get("resolved_interactions", 0),
        "required_interactions": objective_state.get("required_interactions", 0)
    })
    _sync_hud_phase("interaction_resolved", {
        "unit": unit.unit_data.unit_id,
        "object": result.get("object_id", &"interactive_object"),
        "objective_state": objective_state.get("state_id", &"battle_objective_default"),
        "resolved_interactions": objective_state.get("resolved_interactions", 0),
        "required_interactions": objective_state.get("required_interactions", 0)
    })
    var stage_transition: Dictionary = _get_stage_interaction_transition(String(result.get("object_id", "")))
    if not stage_transition.is_empty():
        hud.set_transition_reason(String(stage_transition.get("reason", "")), Dictionary(stage_transition.get("payload", {})))

func _handle_stage_interaction_flags(object_id_variant: Variant) -> void:
    if stage_data == null:
        return
    var object_id: String = String(object_id_variant)
    if object_id.is_empty():
        return

    battle_objective_flags[object_id] = true
    if StageRuleTemplateService.apply_interaction_rule(self, object_id):
        return

    match String(stage_data.stage_id):
        "CH04_05":
            if bool(battle_objective_flags.get("ch04_05_north_research_log", false)) and bool(battle_objective_flags.get("ch04_05_south_research_log", false)):
                battle_objective_flags["collect_2_research_logs"] = true
        "CH06_05":
            if bool(battle_objective_flags.get("ch06_05_keep_dais", false)) and bool(battle_objective_flags.get("ch06_05_barricade_latch", false)):
                battle_objective_flags["fort_resistance_zero"] = true
        "CH07_05":
            if object_id == "ch07_05_city_seal":
                battle_objective_flags["collect_city_seal"] = true
            if object_id == "ch07_05_prayer_dais":
                battle_objective_flags["prayer_dais_secured"] = true
            if not bool(battle_objective_flags.get("mira_queue_lost", false)) and bool(battle_objective_flags.get("collect_city_seal", false)) and bool(battle_objective_flags.get("prayer_dais_secured", false)):
                battle_objective_flags["recruit_mira"] = true
        "CH10_04":
            if object_id == "ch10_04_edict_throne":
                battle_objective_flags["stairs_to_bell_open"] = true
        "HUNT_BASIL":
            if object_id == "hunt_basil_sluice_wheel":
                battle_objective_flags["hunt_basil_sluice_open"] = true
        "HUNT_SARIA":
            if object_id == "hunt_saria_choir_lectern":
                battle_objective_flags["hunt_saria_choir_lectern"] = true
        "HUNT_LETE":
            if object_id == "hunt_lete_gate_latch":
                battle_objective_flags["hunt_lete_gate_latch"] = true
                stage_data.blocked_cells.erase(Vector2i(7, 4))
                if battle_board != null:
                    battle_board.queue_redraw()

func _get_stage_interaction_transition(object_id: String) -> Dictionary:
    match object_id:
        "ch08_05_transfer_gate_latch":
            return {
                "reason": "lete_route_cut",
                "payload": {"object": object_id, "effect": "pursuit_line_open"}
            }
        "ch09b_05_archive_lectern":
            return {
                "reason": "melkion_archive_stabilized",
                "payload": {"object": object_id, "effect": "central_tile_stable"}
            }
        "ch10_05_anchor_chain":
            return {
                "reason": "karon_bell_line_broken",
                "payload": {"object": object_id, "effect": "bell_line_open"}
            }
        _:
            return {}

func _handle_stage_move_flags(unit: UnitActor, destination: Vector2i) -> void:
    if stage_data == null or unit == null or not is_instance_valid(unit) or unit.unit_data == null:
        return
    match stage_data.stage_id:
        &"CH04_05":
            if unit.unit_data.unit_id == &"ally_vanguard" and stage_data.get_terrain_type(destination) == &"flooded":
                battle_objective_flags["ark_survives_flooded_section"] = true

func _update_stage_pressure_state() -> void:
    if stage_data == null:
        return
    match stage_data.stage_id:
        &"CH04_05":
            _update_ch04_flood_pressure()
        &"CH07_05":
            _update_ch07_civilian_pressure()
        &"HUNT_BASIL":
            _update_hunt_basil_pressure()
        &"HUNT_SARIA":
            _update_hunt_saria_pressure()

func _update_ch04_flood_pressure() -> void:
    if not bool(battle_objective_flags.get("basil_altar_purged", false)):
        return
    var spread_count: int = int(battle_runtime_counters.get("ch04_flood_spread_count", 0))
    if spread_count >= 2:
        _resolve_flooded_research_logs(true)
        return
    var source_cells: Array[Vector2i] = [Vector2i(1, 1), Vector2i(6, 6)]
    var candidate_cells: Array[Vector2i] = []
    for source in source_cells:
        for offset in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
            var candidate: Vector2i = source + offset * (spread_count + 1)
            if not _is_cell_in_bounds(candidate):
                continue
            if stage_data.get_terrain_type(candidate) == &"flooded":
                continue
            if candidate_cells.has(candidate):
                continue
            candidate_cells.append(candidate)
    if spread_count == 0:
        for log_cell in [Vector2i(5, 2), Vector2i(6, 2)]:
            if _is_cell_in_bounds(log_cell) and not candidate_cells.has(log_cell):
                candidate_cells.append(log_cell)
    if candidate_cells.is_empty():
        return
    for candidate in candidate_cells:
        stage_data.terrain_types[candidate] = &"flooded"
        stage_data.terrain_move_costs[candidate] = 2
        stage_data.terrain_defense_bonuses[candidate] = 1
    battle_runtime_counters["ch04_flood_spread_count"] = spread_count + 1
    battle_objective_flags["basil_flood_risen"] = true
    _resolve_flooded_research_logs(spread_count + 1 >= 2)
    hud.set_transition_reason("basil_flood_rise", {"round": round_index, "spread": spread_count + 1})
    _play_battle_flash(Color(0.403922, 0.631373, 0.847059, 0.18), 0.22)
    if battle_board != null:
        battle_board.queue_redraw()

func _update_ch07_civilian_pressure() -> void:
    if bool(battle_objective_flags.get("recruit_mira", false)) or bool(battle_objective_flags.get("mira_queue_lost", false)):
        return
    var delay_pressure: bool = bool(battle_objective_flags.get("collect_city_seal", false)) or bool(battle_objective_flags.get("prayer_dais_secured", false))
    var pressure_ticks: int = int(battle_runtime_counters.get("ch07_civilian_pressure_ticks", 0)) + 1
    battle_runtime_counters["ch07_civilian_pressure_ticks"] = pressure_ticks
    if delay_pressure and pressure_ticks % 2 == 1:
        hud.set_transition_reason("saria_civilian_pressure_delayed", {"round": round_index, "ticks": pressure_ticks})
        return
    var pressure_turns: int = int(battle_runtime_counters.get("ch07_civilian_pressure_turns", 0)) + 1
    battle_runtime_counters["ch07_civilian_pressure_turns"] = pressure_turns
    if pressure_turns >= 2:
        battle_objective_flags["mira_queue_at_risk"] = true
        hud.set_transition_reason("saria_civilian_pressure", {"round": round_index, "pressure": pressure_turns})
    if pressure_turns >= 4:
        battle_objective_flags["mira_queue_lost"] = true
        battle_objective_flags.erase("recruit_mira")
        hud.set_transition_reason("saria_civilian_loss", {"round": round_index})

func _resolve_flooded_research_logs(force_loss: bool) -> void:
    if stage_data == null or String(stage_data.stage_id) != "CH04_05":
        return
    var unresolved_flooded_logs: int = 0
    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor) or object_actor.object_data == null or object_actor.is_resolved:
            continue
        var object_id: StringName = object_actor.object_data.object_id
        if object_id != &"ch04_05_north_research_log" and object_id != &"ch04_05_south_research_log":
            continue
        if stage_data.get_terrain_type(object_actor.grid_position) != &"flooded":
            continue
        unresolved_flooded_logs += 1
        if force_loss:
            object_actor.is_resolved = true
            object_actor.set_highlighted(false)
            object_actor._refresh_visuals()
    if unresolved_flooded_logs <= 0:
        return
    battle_objective_flags["basil_logs_at_risk"] = true
    hud.set_transition_reason("basil_logs_at_risk", {"count": unresolved_flooded_logs, "lost": force_loss})
    if force_loss:
        battle_objective_flags["basil_logs_lost"] = true

func _apply_lete_berserk_battlefield_rewrite() -> void:
    if stage_data == null or stage_data.stage_id != &"CH08_05":
        return
    var rewrite_cells: Array[Vector2i] = [Vector2i(4, 4), Vector2i(5, 5)]
    var dampened_rewrite: bool = bool(battle_objective_flags.get("lete_escape_route_cut", false))
    if dampened_rewrite:
        rewrite_cells = [Vector2i(4, 4)]
    for cell in rewrite_cells:
        stage_data.terrain_types[cell] = &"shadow"
        stage_data.terrain_move_costs[cell] = 1 if dampened_rewrite else 2
        stage_data.terrain_defense_bonuses[cell] = 1
    if dampened_rewrite:
        stage_data.terrain_types.erase(Vector2i(5, 5))
        stage_data.terrain_move_costs.erase(Vector2i(5, 5))
        stage_data.terrain_defense_bonuses.erase(Vector2i(5, 5))
    stage_data.blocked_cells.erase(Vector2i(3, 3))
    if battle_board != null:
        battle_board.queue_redraw()

func _apply_melkion_archive_battlefield_rewrite() -> void:
    if stage_data == null or stage_data.stage_id != &"CH09B_05":
        return
    var rewrite_cells: Array[Vector2i] = [Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2)]
    var dampened_rewrite: bool = bool(battle_objective_flags.get("melkion_archive_destabilized", false))
    if dampened_rewrite:
        rewrite_cells = [Vector2i(3, 2), Vector2i(5, 2)]
    for cell in rewrite_cells:
        stage_data.terrain_types[cell] = &"revision"
        stage_data.terrain_move_costs[cell] = 1 if dampened_rewrite else 2
        stage_data.terrain_defense_bonuses[cell] = 1
    if dampened_rewrite:
        stage_data.terrain_types[Vector2i(4, 2)] = &"plain"
        stage_data.terrain_move_costs.erase(Vector2i(4, 2))
        stage_data.terrain_defense_bonuses.erase(Vector2i(4, 2))
    if battle_board != null:
        battle_board.queue_redraw()

func _apply_karon_name_severance_battlefield_rewrite() -> void:
    if stage_data == null or stage_data.stage_id != &"CH10_05":
        return
    var dampened_rewrite: bool = bool(battle_objective_flags.get("karon_bell_line_broken", false))
    stage_data.terrain_types[Vector2i(6, 6)] = &"bell"
    stage_data.terrain_move_costs[Vector2i(6, 6)] = 1 if dampened_rewrite else 2
    stage_data.terrain_defense_bonuses[Vector2i(6, 6)] = 1
    if not dampened_rewrite and not stage_data.blocked_cells.has(Vector2i(10, 6)):
        stage_data.blocked_cells.append(Vector2i(10, 6))
    elif dampened_rewrite:
        stage_data.blocked_cells.erase(Vector2i(10, 6))
    if battle_board != null:
        battle_board.queue_redraw()

func _update_hunt_basil_pressure() -> void:
    if bool(battle_objective_flags.get("hunt_basil_sluice_open", false)):
        return
    var spread_count: int = int(battle_runtime_counters.get("hunt_basil_flood_spread_count", 0))
    if spread_count >= 2:
        battle_objective_flags["hunt_basil_flood_rise_survived"] = true
        return
    var source: Vector2i = Vector2i(2, 2)
    var candidate: Vector2i = source + Vector2i(spread_count + 1, 0)
    if _is_cell_in_bounds(candidate):
        stage_data.terrain_types[candidate] = &"flooded"
        stage_data.terrain_move_costs[candidate] = 2
        stage_data.terrain_defense_bonuses[candidate] = 1
    battle_runtime_counters["hunt_basil_flood_spread_count"] = spread_count + 1
    hud.set_transition_reason("basil_flood_rise", {"round": round_index, "hunt": true, "spread": spread_count + 1})
    if battle_board != null:
        battle_board.queue_redraw()

func _update_hunt_saria_pressure() -> void:
    if not bool(battle_objective_flags.get("hunt_saria_queue_preserved", false)):
        return
    var threshold: int = 3
    if bool(battle_objective_flags.get("hunt_saria_choir_lectern", false)):
        threshold = 5
    var pressure_turns: int = int(battle_runtime_counters.get("hunt_saria_queue_turns", 0)) + 1
    battle_runtime_counters["hunt_saria_queue_turns"] = pressure_turns
    if pressure_turns >= threshold:
        battle_objective_flags.erase("hunt_saria_queue_preserved")
        hud.set_transition_reason("saria_civilian_loss", {"round": round_index, "hunt": true})

func _play_attack_feedback(reason: String) -> void:
    match reason:
        "attack_resolved_deterministic":
            _play_battle_flash(Color(1.0, 0.929412, 0.839216, 0.14), 0.12)
        "counterattack_resolved", "attack_missed_counter_resolved":
            _play_battle_flash(Color(1.0, 0.780392, 0.698039, 0.14), 0.14)
        "attack_missed":
            _play_battle_flash(Color(0.847059, 0.905882, 1.0, 0.1), 0.1)
        _:
            pass

func _play_battle_flash(color: Color, duration: float) -> void:
    if battle_flash == null:
        return
    if _battle_flash_tween != null and _battle_flash_tween.is_running():
        _battle_flash_tween.kill()
    battle_flash.color = color
    _battle_flash_tween = create_tween()
    _battle_flash_tween.tween_property(battle_flash, "color:a", 0.0, duration)

func _play_world_fx(file_name: String, cell: Vector2i, tint: Color, duration: float, scale_amount: float) -> void:
    if effects_root == null:
        return
    var texture: Texture2D = _load_fx_texture(file_name)
    if texture == null:
        return

    var sprite := Sprite2D.new()
    sprite.texture = texture
    sprite.centered = true
    sprite.position = Vector2(
        cell.x * stage_data.cell_size.x + stage_data.cell_size.x * 0.5,
        cell.y * stage_data.cell_size.y + stage_data.cell_size.y * 0.5
    )
    sprite.modulate = tint
    sprite.scale = Vector2(0.7, 0.7)
    effects_root.add_child(sprite)

    var tween := create_tween()
    tween.tween_property(sprite, "scale", Vector2(scale_amount, scale_amount), duration * 0.45)
    tween.parallel().tween_property(sprite, "modulate:a", 0.92, duration * 0.25)
    tween.tween_property(sprite, "scale", Vector2(scale_amount + 0.12, scale_amount + 0.12), duration * 0.55)
    tween.parallel().tween_property(sprite, "modulate:a", 0.0, duration * 0.55)
    tween.finished.connect(sprite.queue_free)

func _play_attack_sequence_fx(attacker: UnitActor, defender: UnitActor, skill: SkillData = null) -> void:
    if attacker == null or defender == null or not is_instance_valid(attacker) or not is_instance_valid(defender):
        return
    var resolved_skill: SkillData = skill if skill != null else attacker.get_default_skill()
    var skill_range: int = resolved_skill.range if resolved_skill != null else attacker.get_attack_range()
    var attacker_class_name: String = ""
    if attacker.unit_data != null and attacker.unit_data.get_class_data() != null:
        attacker_class_name = String(attacker.unit_data.get_class_data().display_name).to_lower()

    var cast_tint := Color(0.76, 0.9, 1.0, 0.96)
    var trail_tint := Color(0.94, 0.86, 0.7, 0.96)
    var impact_tint := Color(1.0, 0.82, 0.64, 0.98)

    if attacker_class_name == "mystic":
        cast_tint = Color(0.78, 0.72, 1.0, 0.96)
        trail_tint = Color(0.84, 0.78, 1.0, 0.96)
        impact_tint = Color(0.92, 0.84, 1.0, 0.98)
    elif attacker_class_name == "ranger":
        cast_tint = Color(0.72, 0.96, 0.82, 0.9)
        trail_tint = Color(0.86, 0.98, 0.74, 0.92)
        impact_tint = Color(1.0, 0.86, 0.64, 0.96)

    if resolved_skill != null and (resolved_skill.mp_cost > 0 or attacker_class_name == "mystic"):
        _play_world_fx("mark_ring.png", attacker.grid_position, cast_tint, 0.22, 0.82)

    if skill_range > 1:
        _play_travel_fx(attacker.grid_position, defender.grid_position, trail_tint, 0.22)

    _play_world_fx("hit_spark.png", defender.grid_position, impact_tint, 0.24, 0.96)

func _play_attack_timing_signature(attacker: UnitActor, defender: UnitActor, skill: SkillData = null) -> void:
    if battle_camera == null:
        return
    var resolved_skill: SkillData = skill if skill != null else (attacker.get_default_skill() if attacker != null else null)
    var skill_range: int = resolved_skill.range if resolved_skill != null else (attacker.get_attack_range() if attacker != null else 1)
    var attacker_class_name: String = ""
    if attacker != null and attacker.unit_data != null and attacker.unit_data.get_class_data() != null:
        attacker_class_name = String(attacker.unit_data.get_class_data().display_name).to_lower()

    var target_zoom := Vector2.ONE
    var flash_color := Color(1.0, 0.92, 0.84, 0.1)
    var flash_duration := 0.10
    var position_pull := 10.0
    if attacker_class_name == "mystic" or (resolved_skill != null and resolved_skill.mp_cost > 0):
        target_zoom = Vector2(0.96, 0.96)
        flash_color = Color(0.84, 0.78, 1.0, 0.12)
        flash_duration = 0.16
        position_pull = 8.0
    elif skill_range > 1:
        target_zoom = Vector2(0.98, 0.98)
        flash_color = Color(0.86, 0.96, 0.78, 0.1)
        flash_duration = 0.12
        position_pull = 18.0
    else:
        target_zoom = Vector2(0.94, 0.94)
        flash_color = Color(1.0, 0.84, 0.72, 0.14)
        flash_duration = 0.1
        position_pull = 26.0

    var focus_point := battle_camera.position
    if attacker != null and defender != null:
        var attacker_pos := attacker.global_position
        var defender_pos := defender.global_position
        var midpoint := attacker_pos.lerp(defender_pos, 0.5)
        var direction := (midpoint - battle_camera.position).normalized()
        if direction.length() > 0.0:
            focus_point = battle_camera.position + direction * position_pull
        else:
            focus_point = midpoint

    _play_battle_flash(flash_color, flash_duration)
    _last_attack_timing_signature = {
        "class_name": attacker_class_name,
        "skill_range": skill_range,
        "flash_duration": flash_duration,
        "target_zoom": target_zoom,
        "focus_point": focus_point,
        "position_pull": position_pull,
    }
    _play_camera_emphasis(target_zoom, focus_point, flash_duration + 0.08)

func _play_camera_emphasis(target_zoom: Vector2, focus_point: Vector2, duration: float) -> void:
    if battle_camera == null:
        return
    var base_zoom := Vector2.ONE
    var base_position := get_viewport_rect().size * 0.5
    if _camera_emphasis_tween != null and _camera_emphasis_tween.is_running():
        _camera_emphasis_tween.kill()
    _camera_emphasis_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _camera_emphasis_tween.parallel().tween_property(battle_camera, "zoom", target_zoom, duration * 0.45)
    _camera_emphasis_tween.parallel().tween_property(battle_camera, "position", focus_point, duration * 0.45)
    _camera_emphasis_tween.tween_property(battle_camera, "zoom", base_zoom, duration * 0.55)
    _camera_emphasis_tween.parallel().tween_property(battle_camera, "position", base_position, duration * 0.55)

func get_last_attack_timing_signature_snapshot() -> Dictionary:
    return _last_attack_timing_signature.duplicate(true)

func _play_travel_fx(from_cell: Vector2i, to_cell: Vector2i, tint: Color, duration: float) -> void:
    if effects_root == null:
        return
    var texture: Texture2D = _load_fx_texture("objective_burst.png")
    if texture == null:
        return
    var start := Vector2(
        from_cell.x * stage_data.cell_size.x + stage_data.cell_size.x * 0.5,
        from_cell.y * stage_data.cell_size.y + stage_data.cell_size.y * 0.5
    )
    var finish := Vector2(
        to_cell.x * stage_data.cell_size.x + stage_data.cell_size.x * 0.5,
        to_cell.y * stage_data.cell_size.y + stage_data.cell_size.y * 0.5
    )
    var sprite := Sprite2D.new()
    sprite.texture = texture
    sprite.centered = true
    sprite.position = start
    sprite.modulate = tint
    sprite.scale = Vector2(0.32, 0.32)
    effects_root.add_child(sprite)

    var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_property(sprite, "position", finish, duration)
    tween.parallel().tween_property(sprite, "scale", Vector2(0.52, 0.52), duration)
    tween.parallel().tween_property(sprite, "modulate:a", 0.0, duration)
    tween.finished.connect(sprite.queue_free)

func _load_fx_texture(file_name: String) -> Texture2D:
    if _fx_cache.has(file_name):
        return _fx_cache[file_name]
    var texture: Texture2D = BattleArtCatalog.load_fx(file_name)
    if texture == null:
        return null
    _fx_cache[file_name] = texture
    return texture

func _format_interaction_detail(result: Dictionary) -> String:
    var reward_text := String(result.get("reward_text", ""))
    if not reward_text.is_empty():
        return reward_text

    var interaction_text := String(result.get("interaction_text", ""))
    if not interaction_text.is_empty():
        return interaction_text

    return "interaction_completed"

func _check_battle_end() -> bool:
    _prune_invalid_units()

    match String(stage_data.win_condition):
        "resolve_all_interactions":
            if _are_all_interactive_objects_resolved():
                _transition_to(BattlePhase.VICTORY, "interaction_objectives_completed", {"round": round_index})
                hud.cache_result_text("Victory\nAll objective points were secured.")
                _on_battle_victory()
                battle_finished.emit(&"victory", stage_data.stage_id)
                return true
        "resolve_all_interactions_and_defeat_all_enemies":
            if _are_all_interactive_objects_resolved() and enemy_units.is_empty():
                _transition_to(BattlePhase.VICTORY, "interaction_and_enemy_objectives_completed", {"round": round_index})
                hud.cache_result_text("Victory\nObjective points were secured and all enemies were defeated.")
                _on_battle_victory()
                battle_finished.emit(&"victory", stage_data.stage_id)
                return true
        _:
            if enemy_units.is_empty():
                _transition_to(BattlePhase.VICTORY, "enemy_team_eliminated", {"round": round_index})
                hud.cache_result_text("Victory\nAll enemy units are defeated.")
                _on_battle_victory()
                battle_finished.emit(&"victory", stage_data.stage_id)
                return true

    if ally_units.is_empty():
        _transition_to(BattlePhase.DEFEAT, "ally_team_eliminated", {"round": round_index})
        hud.show_result("Defeat...\nAll ally units are defeated.")
        _on_battle_defeat()
        battle_finished.emit(&"defeat", stage_data.stage_id)
        return true

    return false

func _on_battle_victory() -> void:
    var objective_result: Dictionary = _check_optional_objectives()
    var completed_objectives: Array = objective_result.get("completed", [])
    var all_optional_objectives_met: bool = stage_data != null and not stage_data.optional_objectives.is_empty() and completed_objectives.size() == stage_data.optional_objectives.size()
    var final_stars: int = 1
    if stage_data != null and not stage_data.optional_objectives.is_empty() and bool(objective_result.get("turn_limit_met", false)):
        final_stars = 2
        if all_optional_objectives_met:
            final_stars = 3
    if telemetry_service != null:
        telemetry_service.record_objective_summary(completed_objectives.size(), stage_data.optional_objectives.size() if stage_data != null else 0)
    var result_summary := {
        "outcome": "victory",
        "title": "Victory",
        "stage_id": String(stage_data.stage_id) if stage_data != null else "",
        "objective": _get_objective_text(),
        "stars_earned": final_stars,
        "turn_limit_met": bool(objective_result.get("turn_limit_met", false)),
        "optional_objectives_completed": completed_objectives.duplicate(),
        "optional_objectives_failed": objective_result.get("failed", []).duplicate(),
        "control_relief_entries": _get_control_relief_result_entries(),
        "reward_entries": battle_reward_log.duplicate(),
        "unit_exp_results": [],
        "bonus_exp_pool": 0,
        "bonus_exp_results": [],
        "memory_entries": _get_stage_memory_entries(),
        "evidence_entries": _get_stage_evidence_entries(),
        "letter_entries": _get_stage_letter_entries(),
        "fragment_id": "",
        "command_unlocked": "",
        "recovered_fragment_ids": [],
        "unlocked_command_ids": [],
        "support_attack_count": 0,
        "supporter_bond_level": 0,
        "support_conversations": [],
        "name_call_line": last_name_call_line,
        "name_call_speaker": String(last_name_call_speaker_id),
        "telemetry": {},
        "telemetry_summary": [],
        "burden_delta": 0,
        "trust_delta": 0,
    }
    var burden_before := 0
    var trust_before := 0
    if progression_service != null:
        var before_data = progression_service.get_data()
        if before_data != null:
            burden_before = before_data.burden
            trust_before = before_data.trust
    if telemetry_service != null:
        telemetry_service.record_battle_end(&"victory", round_index)
    if progression_service != null and stage_data != null:
        var fragment_id := progression_service.get_fragment_id_for_stage(stage_data.stage_id)
        var unlock_result := progression_service.recover_stage_fragment(stage_data.stage_id)
        result_summary["fragment_id"] = String(fragment_id)
        if not bool(unlock_result.get("already_known", true)):
            var cmd = unlock_result.get("command_unlocked", null)
            if cmd != null:
                result_summary["command_unlocked"] = String(cmd)
                print("[BattleController] Fragment recovered: %s → command unlocked: %s" % [fragment_id, cmd])
            # 기억 조각 획득 연출 트리거
            if cutscene_player != null:
                var flash_id := progression_service.get_fragment_flash_cutscene_id_for_stage(stage_data.stage_id)
                var flash_data = CutsceneCatalog.get_cutscene(flash_id)
                if flash_data != null:
                    cutscene_player.play(flash_data)
        var participant_ids: Array[StringName] = []
        for unit in ally_units:
            if is_instance_valid(unit) and unit.unit_data != null:
                participant_ids.append(unit.unit_data.unit_id)
        var unit_exp_results: Array[Dictionary] = progression_service.grant_victory_exp(participant_ids)
        for index in range(unit_exp_results.size()):
            var entry: Dictionary = unit_exp_results[index]
            var unit_id: StringName = StringName(entry.get("unit_id", ""))
            entry["display_name"] = _get_ally_display_name(unit_id)
            unit_exp_results[index] = entry
        result_summary["unit_exp_results"] = unit_exp_results

        var bonus_exp_result: Dictionary = progression_service.grant_bonus_exp_pool(
            participant_ids,
            _build_bonus_exp_contribution_snapshot(),
            stage_data.stage_id
        )
        result_summary["bonus_exp_pool"] = int(bonus_exp_result.get("pool", 0))
        var bonus_exp_results: Array[Dictionary] = bonus_exp_result.get("results", [])
        for index in range(bonus_exp_results.size()):
            var entry: Dictionary = bonus_exp_results[index]
            var unit_id: StringName = StringName(entry.get("unit_id", ""))
            entry["display_name"] = _get_ally_display_name(unit_id)
            bonus_exp_results[index] = entry
        result_summary["bonus_exp_results"] = bonus_exp_results
    # 클리어 컷씬 재생
    if cutscene_player != null and stage_data != null and stage_data.clear_cutscene_id != &"":
        var clear_data = CutsceneCatalog.get_cutscene(stage_data.clear_cutscene_id)
        if clear_data == null:
            var fallback_clear_id := progression_service.get_clear_cutscene_id_for_stage(stage_data.stage_id)
            clear_data = CutsceneCatalog.get_cutscene(fallback_clear_id)
        if clear_data != null:
            cutscene_player.play(clear_data)
    # bond → trust 연동: 팀 평균 bond 기반 소량 trust 상승
    if bond_service != null and progression_service != null:
        var avg: float = bond_service.get_squad_trust_average()
        if avg >= 1.0:
            progression_service.apply_trust_delta(1, "bond_victory_trust")
    if progression_service != null:
        var after_data = progression_service.get_data()
        if after_data != null:
            result_summary["burden_delta"] = after_data.burden - burden_before
            result_summary["trust_delta"] = after_data.trust - trust_before
            result_summary["recovered_fragment_ids"] = after_data.get_recovered_fragment_ids()
            result_summary["unlocked_command_ids"] = after_data.get_unlocked_command_ids()
    if telemetry_service != null:
        var session_snapshot: Dictionary = telemetry_service.get_session_snapshot()
        var command_usage: Dictionary = session_snapshot.get(TelemetryService.KEY_COMMAND_USAGE, {})
        result_summary["support_attack_count"] = int(command_usage.get("support_attack", 0))
        if not last_support_attack_details.is_empty():
            result_summary["supporter_bond_level"] = int(last_support_attack_details.get("bond", 0))
        result_summary["telemetry"] = session_snapshot.duplicate(true)
        result_summary["telemetry_summary"] = _build_telemetry_summary_lines(session_snapshot)
    last_result_summary = result_summary
    if int(last_result_summary.get("support_attack_count", 0)) > 0:
        var victory_support_payload := {
            "count": int(last_result_summary.get("support_attack_count", 0)),
            "round": round_index
        }
        if not last_support_attack_details.is_empty():
            victory_support_payload["bond"] = int(last_support_attack_details.get("bond", 0))
        hud.set_transition_reason("support_attack_resolved", victory_support_payload)
    var result_text := _build_result_summary_text(last_result_summary)
    hud.cache_result_text(result_text)
    # 전투 결과 전용 화면도 함께 표시
    hud.show_result_screen(last_result_summary)

func _on_battle_defeat() -> void:
    if telemetry_service != null:
        telemetry_service.record_battle_end(&"defeat", round_index)
    if progression_service != null:
        progression_service.apply_burden_delta(1, "battle_defeat")

func _on_wait_requested() -> void:
    if selected_unit == null or not _is_player_input_phase() or not turn_manager.can_unit_act(selected_unit):
        return

    _transition_to(BattlePhase.PLAYER_ACTION_COMMIT, "player_wait_committed", {
        "unit": selected_unit.unit_data.unit_id,
        "round": round_index
    })
    _complete_selected_unit_action("player_wait_completed")

func _on_cancel_requested() -> void:
    if selected_unit == null or not _is_player_input_phase():
        return

    var unit_state: StringName = turn_manager.get_unit_state(selected_unit)
    if unit_state == TurnManager.STATE_MOVED:
        var unit_instance_id: int = selected_unit.get_instance_id()
        if pending_move_origins.has(unit_instance_id):
            var origin: Vector2i = pending_move_origins[unit_instance_id]
            if _find_unit_at(origin, ally_units + enemy_units) == null and not _is_object_occupying_cell(origin):
                selected_unit.set_grid_position(origin, stage_data.cell_size)
                turn_manager.reset_to_ready(selected_unit, "player_move_cancelled", {"to": origin})
                pending_move_origins.erase(unit_instance_id)
                _refresh_selected_action_options()
                _transition_to(BattlePhase.PLAYER_ACTION_PREVIEW, "player_move_cancelled", {
                    "unit": selected_unit.unit_data.unit_id,
                    "to": origin
                })
                return

    _clear_selection()
    _transition_to(BattlePhase.PLAYER_SELECT, "player_selection_cleared", {"round": round_index})

func _on_end_turn_requested() -> void:
    if not _is_player_input_phase():
        return

    _end_player_phase("manual_end_turn")

func _on_hud_menu_visibility_changed(is_open: bool) -> void:
    input_controller.world_input_enabled = not is_open

func _on_unit_defeated(unit: UnitActor) -> void:
    pending_move_origins.erase(unit.get_instance_id())
    _unit_visual_status_turns.erase(unit.get_instance_id())
    if stage_data != null and stage_data.stage_id == &"CH04_05" and unit.faction == "ally" and unit.unit_data != null and unit.unit_data.unit_id == &"ally_vanguard":
        battle_objective_flags.erase("ark_survives_flooded_section")
    if stage_data != null and stage_data.stage_id == &"CH05_05" and unit.faction == "ally":
        battle_objective_flags.erase("defeat_boss_without_noah_dying")
    if stage_data != null and stage_data.stage_id == &"CH08_05" and unit.faction == "enemy" and unit.unit_data != null and not unit.unit_data.is_boss:
        battle_objective_flags.erase("no_black_hound_casualties")
    if stage_data != null and stage_data.stage_id == &"HUNT_LETE" and unit.faction == "enemy" and unit.unit_data != null and not unit.unit_data.is_boss:
        battle_objective_flags.erase("hunt_lete_black_hounds_preserved")
    if stage_data != null and stage_data.stage_id == &"CH09B_05" and unit.faction == "ally":
        battle_objective_flags.erase("noah_survives")
    if stage_data != null and stage_data.stage_id == &"CH10_05" and unit.faction == "ally":
        battle_objective_flags.erase("all_allies_name_called")
    turn_manager.mark_downed(unit, "unit_defeated", {"round": round_index})
    if status_service != null:
        status_service.remove_unit(unit)
    if telemetry_service != null:
        if unit.faction == "ally":
            telemetry_service.record_ally_death("unit_hp_zero")
        else:
            telemetry_service.record_enemy_death()
    _remove_unit_from_roster(unit)
    _sync_hud_phase("unit_defeated", {"round": round_index})

func _on_action_state_changed(unit: UnitActor, from_state: StringName, to_state: StringName, reason: String, payload: Dictionary) -> void:
    var transition_payload: Dictionary = payload.duplicate(true)
    if unit != null and unit.unit_data != null:
        transition_payload["unit"] = unit.unit_data.unit_id

    transition_payload["from"] = from_state
    transition_payload["to"] = to_state
    hud.set_transition_reason(reason, transition_payload)
    _sync_hud_phase(reason, transition_payload)

func _remove_unit_from_roster(unit: UnitActor) -> void:
    ally_units.erase(unit)
    enemy_units.erase(unit)

func _prune_invalid_units() -> void:
    ally_units = _filter_live_units(ally_units)
    enemy_units = _filter_live_units(enemy_units)

func _filter_live_units(units: Array) -> Array:
    var live_units: Array = []
    for unit in units:
        if is_instance_valid(unit) and not unit.is_defeated():
            live_units.append(unit)
    return live_units

func _find_unit_at(cell: Vector2i, units: Array) -> UnitActor:
    for unit in units:
        if is_instance_valid(unit) and not unit.is_defeated() and unit.grid_position == cell:
            return unit
    return null

func _find_object_at(cell: Vector2i) -> InteractiveObjectActor:
    for object_actor in interactive_objects:
        if is_instance_valid(object_actor) and object_actor.grid_position == cell:
            return object_actor
    return null

func _find_boss_enemy() -> UnitActor:
    for enemy in enemy_units:
        if is_instance_valid(enemy) and enemy.unit_data != null and enemy.unit_data.is_boss:
            return enemy
    return null

func _can_selected_unit_move_to(cell: Vector2i) -> bool:
    if selected_unit == null:
        return false

    if turn_manager.get_unit_state(selected_unit) != TurnManager.STATE_READY:
        return false

    if not (cell in reachable_cells):
        return false

    return _find_unit_at(cell, ally_units + enemy_units) == null and _is_object_occupying_cell(cell) == false

func _can_unit_legally_move_to(unit: UnitActor, cell: Vector2i) -> bool:
    if unit == null or not is_instance_valid(unit) or unit.is_defeated():
        return false

    if cell == unit.grid_position:
        return true

    var dynamic_blocked: Dictionary = _get_dynamic_blocked_cells(unit)
    var occupied: UnitActor = _find_unit_at(cell, ally_units + enemy_units)
    if not path_service.is_walkable(cell, dynamic_blocked):
        return false
    if occupied != null and occupied != unit:
        return false
    if _is_object_occupying_cell(cell):
        return false

    var path: Array = path_service.find_path(unit.grid_position, cell, dynamic_blocked)
    if path.is_empty():
        return false

    return path_service.get_path_cost(path) <= _get_effective_movement(unit)

func _can_selected_unit_attack(defender: UnitActor) -> bool:
    if selected_unit == null or defender == null or not turn_manager.can_unit_act(selected_unit):
        return false

    return _is_in_attack_range(selected_unit, defender)

func _can_selected_unit_interact(object_actor: InteractiveObjectActor) -> bool:
    if selected_unit == null or object_actor == null or not turn_manager.can_unit_act(selected_unit):
        return false

    return object_actor.can_interact(selected_unit)

func _get_attackable_enemy_count(unit: UnitActor) -> int:
    var count: int = 0
    for enemy in enemy_units:
        if is_instance_valid(enemy) and not enemy.is_defeated() and _is_in_attack_range(unit, enemy):
            count += 1
    return count

func _get_interactable_object_count(unit: UnitActor) -> int:
    var count: int = 0
    for object_actor in interactive_objects:
        if is_instance_valid(object_actor) and object_actor.can_interact(unit):
            count += 1
    return count

func _get_interactable_cells(unit: UnitActor) -> Array:
    var cells: Array = []
    for object_actor in interactive_objects:
        if is_instance_valid(object_actor) and object_actor.can_interact(unit):
            cells.append(object_actor.grid_position)
    return cells

func _get_selected_unit_interaction_destination(object_actor: InteractiveObjectActor) -> Vector2i:
    if selected_unit == null or object_actor == null or not is_instance_valid(object_actor):
        return Vector2i(-1, -1)

    if turn_manager.get_unit_state(selected_unit) != TurnManager.STATE_READY:
        return Vector2i(-1, -1)

    if object_actor.object_data == null:
        return Vector2i(-1, -1)

    if object_actor.is_resolved and object_actor.object_data.one_time_use:
        return Vector2i(-1, -1)

    var candidate_cells: Array = range_service.get_attack_cells(
        object_actor.grid_position,
        object_actor.object_data.interaction_range
    )
    var best_cell := Vector2i(-1, -1)
    var best_cost := INF
    var dynamic_blocked: Dictionary = _get_dynamic_blocked_cells(selected_unit)

    for candidate in candidate_cells:
        if not _is_cell_in_bounds(candidate):
            continue
        if candidate == selected_unit.grid_position:
            continue
        if _is_object_occupying_cell(candidate):
            continue

        var occupying_unit: UnitActor = _find_unit_at(candidate, ally_units + enemy_units)
        if occupying_unit != null and occupying_unit != selected_unit:
            continue

        if not path_service.is_walkable(candidate, dynamic_blocked):
            continue

        var path: Array = path_service.find_path(selected_unit.grid_position, candidate, dynamic_blocked)
        if path.is_empty():
            continue

        var path_cost: int = path_service.get_path_cost(path)
        if path_cost > _get_effective_movement(selected_unit):
            continue

        if path_cost < best_cost or (path_cost == best_cost and _distance_between_cells(candidate, object_actor.grid_position) < _distance_between_cells(best_cell, object_actor.grid_position)):
            best_cost = path_cost
            best_cell = candidate

    return best_cell

func _is_in_attack_range(attacker: UnitActor, defender: UnitActor) -> bool:
    var attack_cells: Array = range_service.get_attack_cells(attacker.grid_position, _get_effective_attack_range(attacker))
    return defender.grid_position in attack_cells

func _distance_between_cells(from_cell: Vector2i, to_cell: Vector2i) -> int:
    return abs(to_cell.x - from_cell.x) + abs(to_cell.y - from_cell.y)

func _get_dynamic_blocked_cells(excluded_unit: UnitActor = null) -> Dictionary:
    var blocked: Dictionary = {}

    for unit in ally_units + enemy_units:
        if not is_instance_valid(unit) or unit.is_defeated() or unit == excluded_unit:
            continue
        blocked[unit.grid_position] = true

    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor):
            continue
        if object_actor.blocks_movement():
            blocked[object_actor.grid_position] = true

    return blocked

func _is_object_occupying_cell(cell: Vector2i) -> bool:
    var object_actor: InteractiveObjectActor = _find_object_at(cell)
    return object_actor != null and object_actor.blocks_movement()

func _is_cell_in_bounds(cell: Vector2i) -> bool:
    if stage_data == null:
        return false

    return cell.x >= 0 and cell.y >= 0 and cell.x < stage_data.grid_size.x and cell.y < stage_data.grid_size.y

func _is_player_input_phase() -> bool:
    return current_phase == BattlePhase.PLAYER_SELECT or current_phase == BattlePhase.PLAYER_ACTION_PREVIEW

func _refresh_unit_visual_state() -> void:
    for unit in ally_units + enemy_units:
        if is_instance_valid(unit):
            unit.has_acted = turn_manager.is_unit_exhausted(unit)
            unit.set_attackable(_is_unit_attackable_by_selection(unit))
            unit.set_selected(selected_unit == unit)
            unit.set_boss_marked(_is_unit_boss_marked(unit))
            unit.set_status_visual_state(_build_unit_status_visual_state(unit))
            unit.set_bond_visual_state(_build_unit_bond_visual_state(unit))
            unit.set_tile_context(stage_data.get_terrain_type(unit.grid_position), stage_data.get_defense_bonus(unit.grid_position))
    _update_last_visible_ally_cells()
    for object_actor in interactive_objects:
        if is_instance_valid(object_actor):
            object_actor.set_highlighted(_is_object_interactable_by_selection(object_actor))
    _sync_battle_board_visuals()

func _update_last_visible_ally_cells() -> void:
    var next_visible_cells: Dictionary = _last_visible_ally_cells_by_unit_id.duplicate(true)
    for unit in ally_units:
        if not is_instance_valid(unit) or unit.is_defeated():
            continue
        var unit_key := str(unit.get_instance_id())
        if _get_unit_visual_status_turns(unit, &"stealth") > 0:
            continue
        next_visible_cells[unit_key] = unit.grid_position
    for stored_key in next_visible_cells.keys():
        var resolved_unit := instance_from_id(int(stored_key))
        if resolved_unit == null or not is_instance_valid(resolved_unit) or resolved_unit.is_defeated():
            next_visible_cells.erase(stored_key)
    _last_visible_ally_cells_by_unit_id = next_visible_cells

func _sync_battle_board_visuals() -> void:
    if battle_board == null or not is_instance_valid(battle_board):
        return
    battle_board.set_bond_links(_build_bond_link_visuals())

func _build_bond_link_visuals() -> Array[Dictionary]:
    var links: Array[Dictionary] = []
    if selected_unit == null or not is_instance_valid(selected_unit) or selected_unit.faction != "ally" or bond_service == null:
        return links

    var selected_unit_id: StringName = selected_unit.unit_data.unit_id if selected_unit.unit_data != null else &""
    for unit in ally_units:
        if unit == null or not is_instance_valid(unit) or unit == selected_unit or unit.is_defeated():
            continue
        var unit_id: StringName = unit.unit_data.unit_id if unit.unit_data != null else &""
        var distance: int = _distance_between_cells(selected_unit.grid_position, unit.grid_position)
        var bond_level: int = bond_service.get_bond(unit_id)
        var kind: String = ""
        if distance <= 1 and bond_level >= BondService.MAX_BOND:
            kind = "guard"
        elif distance <= BondService.SUPPORT_ATTACK_RANGE and bond_level >= BondService.SUPPORT_ATTACK_MIN_BOND:
            kind = "support"
        if kind.is_empty():
            continue
        links.append({
            "from_unit_id": selected_unit_id,
            "to_unit_id": unit_id,
            "from_cell": selected_unit.grid_position,
            "to_cell": unit.grid_position,
            "bond_level": bond_level,
            "kind": kind
        })
    return links

func _is_unit_attackable_by_selection(unit: UnitActor) -> bool:
    if selected_unit == null or not is_instance_valid(selected_unit):
        return false

    if unit == null or not is_instance_valid(unit) or unit.is_defeated():
        return false

    if not _is_player_input_phase():
        return false

    if unit.faction == selected_unit.faction:
        return false

    return _is_in_attack_range(selected_unit, unit)

func _is_unit_boss_marked(unit: UnitActor) -> bool:
    if unit == null or not is_instance_valid(unit):
        return false
    return boss_marked_target_id != -1 and unit.get_instance_id() == boss_marked_target_id

func _build_unit_status_visual_state(unit: UnitActor) -> Dictionary:
    return {
        "oblivion_stack": status_service.get_oblivion_stack(unit) if status_service != null else 0,
        "fear_turns": _get_unit_visual_status_turns(unit, &"fear"),
        "charm_turns": _get_unit_visual_status_turns(unit, &"charm"),
        "dot_turns": _get_unit_visual_status_turns(unit, &"dot"),
        "mark_turns": _get_unit_visual_status_turns(unit, &"mark"),
        "silence_turns": _get_unit_visual_status_turns(unit, &"silence"),
        "seal_turns": _get_unit_visual_status_turns(unit, &"seal"),
        "sleep_turns": _get_unit_visual_status_turns(unit, &"sleep"),
        "wake_caution_turns": _get_unit_visual_status_turns(unit, &"wake_caution"),
        "stealth_turns": _get_unit_visual_status_turns(unit, &"stealth")
    }

func _build_unit_bond_visual_state(unit: UnitActor) -> Dictionary:
    if unit == null or not is_instance_valid(unit) or unit.faction != "ally" or bond_service == null:
        return {"support_ready": false, "guard_ready": false}
    if selected_unit == null or not is_instance_valid(selected_unit) or selected_unit == unit or selected_unit.faction != "ally":
        return {"support_ready": false, "guard_ready": false}
    var distance: int = _distance_between_cells(selected_unit.grid_position, unit.grid_position)
    var bond_level: int = bond_service.get_bond(unit.unit_data.unit_id if unit.unit_data != null else &"")
    return {
        "support_ready": distance <= BondService.SUPPORT_ATTACK_RANGE and bond_level >= BondService.SUPPORT_ATTACK_MIN_BOND,
        "guard_ready": distance <= 1 and bond_level >= BondService.MAX_BOND
    }

func _get_unit_visual_status_turns(unit: UnitActor, status_type: StringName) -> int:
    if unit == null or not is_instance_valid(unit) or status_type == &"":
        return 0
    var status_map: Dictionary = _unit_visual_status_turns.get(unit.get_instance_id(), {})
    return maxi(int(status_map.get(status_type, 0)), 0)

func _set_unit_visual_status(unit: UnitActor, status_type: StringName, turns: int) -> void:
    if unit == null or not is_instance_valid(unit) or status_type == &"":
        return
    var unit_id: int = unit.get_instance_id()
    var status_map: Dictionary = _unit_visual_status_turns.get(unit_id, {})
    if turns <= 0:
        status_map.erase(status_type)
        if status_map.is_empty():
            _unit_visual_status_turns.erase(unit_id)
        else:
            _unit_visual_status_turns[unit_id] = status_map
        return
    status_map[status_type] = maxi(int(status_map.get(status_type, 0)), turns)
    _unit_visual_status_turns[unit_id] = status_map

func _increment_runtime_counter(counter_id: String, amount: int = 1) -> int:
    var next_value: int = int(battle_runtime_counters.get(counter_id, 0)) + amount
    battle_runtime_counters[counter_id] = next_value
    return next_value

func _tick_unit_visual_statuses() -> void:
    if _unit_visual_status_turns.is_empty():
        return
    var remaining: Dictionary = {}
    for unit_id_variant in _unit_visual_status_turns.keys():
        var unit_id: int = int(unit_id_variant)
        var status_map: Dictionary = _unit_visual_status_turns.get(unit_id, {})
        var reduced: Dictionary = {}
        for status_variant in status_map.keys():
            var status_key: StringName = status_variant
            var turns_left: int = maxi(int(status_map.get(status_key, 0)) - 1, 0)
            if turns_left > 0:
                reduced[status_key] = turns_left
        if not reduced.is_empty():
            remaining[unit_id] = reduced
    _unit_visual_status_turns = remaining

func _apply_charm_forced_actions() -> bool:
    last_charm_forced_details = {}
    var triggered: bool = false
    for unit in ally_units:
        if not is_instance_valid(unit) or unit.is_defeated() or not turn_manager.can_unit_act(unit):
            continue
        if _get_unit_visual_status_turns(unit, &"charm") <= 0:
            continue
        var restrainer: UnitActor = _find_charm_restrainer(unit)
        if restrainer != null:
            last_charm_forced_details = {
                "unit": unit.unit_data.unit_id if unit.unit_data != null else &"",
                "restrainer": restrainer.unit_data.unit_id if restrainer.unit_data != null else &"",
                "round": round_index
            }
            triggered = true
            turn_manager.mark_acted(unit, "charm_restrained", {"round": round_index})
            continue
        var target: UnitActor = _find_nearest_charm_target(unit)
        if target != null:
            _resolve_attack(unit, target, {"allow_counterattack": false, "suppress_support_logic": true})
            last_charm_forced_details = {
                "unit": unit.unit_data.unit_id if unit.unit_data != null else &"",
                "target": target.unit_data.unit_id if target.unit_data != null else &"",
                "round": round_index
            }
        else:
            last_charm_forced_details = {
                "unit": unit.unit_data.unit_id if unit.unit_data != null else &"",
                "round": round_index
            }
        triggered = true
        turn_manager.mark_acted(unit, "charm_forced_action", {"round": round_index})
    return triggered

func _find_charm_restrainer(unit: UnitActor) -> UnitActor:
    if unit == null or not is_instance_valid(unit) or bond_service == null:
        return null
    for candidate in ally_units:
        if candidate == unit or not is_instance_valid(candidate) or candidate.is_defeated() or candidate.unit_data == null:
            continue
        if _distance_between_cells(unit.grid_position, candidate.grid_position) > 1:
            continue
        if bond_service.get_bond(candidate.unit_data.unit_id) >= BondService.MAX_BOND:
            return candidate
    return null

func _find_nearest_charm_target(unit: UnitActor) -> UnitActor:
    var best: UnitActor = null
    var best_distance: int = 999999
    for candidate in ally_units:
        if candidate == unit or not is_instance_valid(candidate) or candidate.is_defeated():
            continue
        var distance: int = _distance_between_cells(unit.grid_position, candidate.grid_position)
        if distance < best_distance and distance <= _get_effective_attack_range(unit):
            best = candidate
            best_distance = distance
    return best

func try_apply_charm_counterplay(caster: UnitActor, target: UnitActor, skill: SkillData) -> bool:
    if caster == null or target == null or skill == null:
        return false
    if not is_instance_valid(caster) or not is_instance_valid(target):
        return false
    if caster.faction != "ally" or target.faction != "ally":
        return false
    if _get_unit_visual_status_turns(target, &"charm") <= 0:
        return false
    if caster.has_method("can_afford_skill_cost") and not caster.can_afford_skill_cost(skill):
        hud.set_transition_reason("skill_insufficient_resource", {
            "unit": caster.unit_data.unit_id if caster.unit_data != null else &"",
            "skill": skill.skill_id,
            "cost": skill.get_resource_cost_text()
        })
        return false
    if caster.has_method("spend_skill_cost"):
        caster.spend_skill_cost(skill)

    var skill_id: StringName = skill.skill_id
    match skill_id:
        &"never_forget", &"name_restore", &"name_return":
            _clear_unit_visual_status(target, &"charm")
            _clear_unit_visual_status(target, &"fear")
            _progress_boss_lock_for_event(&"name")
            if status_service != null:
                var oblivion_stack: int = status_service.get_oblivion_stack(target)
                if oblivion_stack > 0:
                    status_service.cleanse_stack(target, oblivion_stack, "charm_counterplay")
                    _progress_boss_lock_for_event(&"cleanse", null, oblivion_stack)
                    if telemetry_service != null:
                        telemetry_service.record_oblivion_cleansed(oblivion_stack)
            hud.set_transition_reason("charm_cleansed", {
                "unit": caster.unit_data.unit_id if caster.unit_data != null else &"",
                "target": target.unit_data.unit_id if target.unit_data != null else &"",
                "skill": skill_id
            })
            _sync_selection_hud()
            return true
        &"rescue":
            _clear_unit_visual_status(target, &"charm")
            var rescue_cell: Vector2i = _find_charm_rescue_cell(target)
            if rescue_cell != Vector2i(-1, -1):
                target.set_grid_position(rescue_cell, stage_data.cell_size)
            if telemetry_service != null:
                telemetry_service.record_rescue()
            hud.set_transition_reason("charm_rescued", {
                "unit": caster.unit_data.unit_id if caster.unit_data != null else &"",
                "target": target.unit_data.unit_id if target.unit_data != null else &"",
                "to": rescue_cell
            })
            _sync_selection_hud()
            return true
    return false

func _clear_unit_visual_status(unit: UnitActor, status_type: StringName) -> void:
    if unit == null or not is_instance_valid(unit) or status_type == &"":
        return
    var unit_id: int = unit.get_instance_id()
    var status_map: Dictionary = _unit_visual_status_turns.get(unit_id, {})
    if status_map.has(status_type):
        status_map.erase(status_type)
    if status_map.is_empty():
        _unit_visual_status_turns.erase(unit_id)
    else:
        _unit_visual_status_turns[unit_id] = status_map
    _refresh_unit_visual_state()

func _find_charm_rescue_cell(target: UnitActor) -> Vector2i:
    if stage_data == null or target == null or not is_instance_valid(target):
        return Vector2i(-1, -1)
    for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
        var candidate: Vector2i = target.grid_position + offset
        if not _is_cell_in_bounds(candidate):
            continue
        if _find_unit_at(candidate, ally_units + enemy_units) != null:
            continue
        if _is_object_occupying_cell(candidate):
            continue
        return candidate
    return Vector2i(-1, -1)

func _apply_visual_status_from_skill(target: UnitActor, skill: SkillData, result: Dictionary) -> void:
    if target == null or not is_instance_valid(target) or skill == null:
        return
    if String(result.get("transition_reason", "")) == "attack_missed":
        return
    var status_type: StringName = skill.get_status_type()
    if status_type == &"":
        return
    if status_type not in [&"fear", &"charm", &"dot", &"mark"]:
        return
    _set_unit_visual_status(target, status_type, skill.get_status_duration())

func _is_object_interactable_by_selection(object_actor: InteractiveObjectActor) -> bool:
    if selected_unit == null or not is_instance_valid(selected_unit):
        return false
    if object_actor == null or not is_instance_valid(object_actor):
        return false
    if not _is_player_input_phase():
        return false
    return object_actor.can_interact(selected_unit)

func _sync_selection_hud() -> void:
    if selected_unit == null or not is_instance_valid(selected_unit):
        hud.clear_selection()
        if _is_player_input_phase():
            hud.set_action_hint("Tap a ready ally to act.")
            hud.set_buttons_state(false, false, true)
        else:
            hud.set_action_hint("Waiting for the active phase to resolve.")
            hud.set_buttons_state(false, false, false)
        return

    var unit_state: StringName = turn_manager.get_unit_state(selected_unit)
    var attackable_count: int = _get_attackable_enemy_count(selected_unit)
    var interactable_count: int = _get_interactable_object_count(selected_unit)
    var hp_text: String = "%d/%d" % [selected_unit.current_hp, selected_unit.unit_data.max_hp]
    var terrain_text: String = _get_tile_summary_text(selected_unit.grid_position)
    var oblivion_stack: int = status_service.get_oblivion_stack(selected_unit) if status_service != null else 0
    var skill_cost_lines: Array[String] = _build_selected_unit_skill_cost_lines(selected_unit)
    var resource_pool_text: String = _build_selected_unit_resource_pool_text(selected_unit)
    hud.set_selection_summary(
        selected_unit.unit_data.display_name,
        hp_text,
        _get_effective_movement(selected_unit),
        _get_effective_attack_range(selected_unit),
        reachable_cells.size(),
        attackable_count,
        interactable_count,
        terrain_text,
        oblivion_stack,
        skill_cost_lines,
        resource_pool_text,
        _build_selection_preview_labels(selected_unit)
    )

    var can_wait: bool = turn_manager.can_unit_act(selected_unit)
    var can_cancel: bool = unit_state == TurnManager.STATE_READY or unit_state == TurnManager.STATE_MOVED
    hud.set_buttons_state(can_wait, can_cancel, _is_player_input_phase())

    if unit_state == TurnManager.STATE_MOVED:
        if attackable_count > 0:
            hud.set_action_hint("Tap a highlighted enemy to attack, Wait, or Cancel to undo the move.")
        elif interactable_count > 0:
            hud.set_action_hint("Interact, Wait, or Cancel to undo the move.")
        else:
            hud.set_action_hint("Wait to finish this unit or Cancel to undo the move.")
        return

    if attackable_count > 0:
        hud.set_action_hint("Move to a highlighted tile, attack a highlighted enemy, or Wait.")
    elif interactable_count > 0:
        hud.set_action_hint("Move, interact with a nearby object, or Wait.")
    else:
        hud.set_action_hint("Move to a highlighted tile or Wait.")

func _build_selected_unit_skill_cost_lines(unit: UnitActor) -> Array[String]:
    var lines: Array[String] = []
    if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
        return lines
    for skill in unit.unit_data.get_all_skills():
        if skill == null or skill.skill_id == &"basic_attack" or not skill.has_resource_cost():
            continue
        lines.append("%s %s" % [skill.display_name, skill.get_resource_cost_text()])
    if lines.size() > 3:
        var remaining: int = lines.size() - 3
        lines = lines.slice(0, 3)
        lines.append("+%d more" % remaining)
    return lines

func _build_selected_unit_resource_pool_text(unit: UnitActor) -> String:
    if unit == null or not is_instance_valid(unit):
        return ""
    var parts: Array[String] = []
    if unit.max_mp > 0:
        parts.append("MP %d/%d" % [unit.current_mp, unit.max_mp])
    if unit.max_sp > 0:
        parts.append("SP %d/%d" % [unit.current_sp, unit.max_sp])
    return "  ".join(parts)

func _get_tile_summary_text(cell: Vector2i) -> String:
    if stage_data == null:
        return ""

    var terrain_type: String = String(stage_data.get_terrain_type(cell)).capitalize()
    if terrain_type.is_empty() or terrain_type == "Plain":
        terrain_type = "Plain"
    var defense_bonus: int = stage_data.get_defense_bonus(cell)
    if defense_bonus > 0:
        return "%s +%dDEF" % [terrain_type, defense_bonus]
    var move_cost: int = stage_data.get_move_cost(cell)
    if move_cost > 1:
        return "%s %dMV" % [terrain_type, move_cost]
    return terrain_type

func _normalize_weather_type(raw_weather: String) -> String:
    var normalized := raw_weather.strip_edges().to_lower()
    if normalized.is_empty():
        return "clear"
    if WEATHER_EFFECTS.has(normalized):
        return normalized
    return "clear"

func _normalize_terrain_key(raw_value: String) -> String:
    var normalized := raw_value.strip_edges().to_lower().replace("-", "_").replace(" ", "_")
    match normalized:
        "highground":
            return "high_ground"
        "sacredground":
            return "sacred_ground"
        _:
            return normalized

func _reset_weather_runtime_state() -> void:
    weather_defense_bonus_by_unit.clear()
    _active_area_statuses.clear()
    _active_synergy_results.clear()
    _triggered_synergy_keys.clear()
    _synergy_activation_log.clear()
    _rain_environment_applied = false

func _get_effective_attack_range(unit: UnitActor) -> int:
    if unit == null:
        return 1
    return _get_effective_range_value(unit, unit.get_attack_range())

func _get_effective_skill_range(unit: UnitActor, skill: SkillData = null) -> int:
    var base_range: int = skill.range if skill != null else (unit.get_attack_range() if unit != null else 1)
    return _get_effective_range_value(unit, base_range)

func _get_effective_range_value(unit: UnitActor, base_range: int) -> int:
    var range_value: int = base_range
    if unit != null:
        var feature_effects: Dictionary = _get_feature_effects_for_unit(unit)
        range_value += int(feature_effects.get("range_bonus", 0))
    if combat_service != null:
        return combat_service._apply_weather_range_modifier(range_value, weather_type)
    return range_value

func _get_feature_effects_for_unit(unit: UnitActor) -> Dictionary:
    var effects := {
        "defense_bonus": 0,
        "range_bonus": 0,
        "speed_penalty": 0,
        "damage_per_turn": 0,
        "heal_per_turn": 0,
        "fire_spread_chance": 0.0,
    }
    if unit == null or not is_instance_valid(unit) or stage_data == null:
        return effects

    for feature_variant in stage_data.terrain_features:
        var feature: Dictionary = feature_variant
        if not _is_in_radius(unit.grid_position, _get_feature_position(feature), _get_feature_radius(feature)):
            continue
        var feature_type := _normalize_terrain_key(String(feature.get("type", "")))
        match feature_type:
            "high_ground":
                var defense_bonus := int(ceil(float(unit.get_defense()) * float(TERRAIN_EFFECTS["high_ground"].get("defense_bonus", 0.0))))
                effects["defense_bonus"] = max(int(effects.get("defense_bonus", 0)), defense_bonus)
                effects["range_bonus"] = max(int(effects.get("range_bonus", 0)), int(TERRAIN_EFFECTS["high_ground"].get("range_bonus", 0)))
            "water":
                effects["speed_penalty"] = max(int(effects.get("speed_penalty", 0)), int(TERRAIN_EFFECTS["water"].get("speed_penalty", 0)))
            "fire":
                effects["damage_per_turn"] = max(int(effects.get("damage_per_turn", 0)), int(feature.get("damage_per_turn", TERRAIN_EFFECTS["fire"].get("damage_per_turn", 0))))
                effects["fire_spread_chance"] = max(float(effects.get("fire_spread_chance", 0.0)), float(feature.get("spread_chance", TERRAIN_EFFECTS["fire"].get("spread_chance", 0.0))))
            "sacred_ground":
                effects["heal_per_turn"] = max(int(effects.get("heal_per_turn", 0)), int(feature.get("heal_per_turn", TERRAIN_EFFECTS["sacred_ground"].get("heal_per_turn", 0))))
            _:
                pass
    return effects

func _get_all_units() -> Array:
    var units: Array = []
    for unit in ally_units + enemy_units:
        if is_instance_valid(unit) and not unit.is_defeated():
            units.append(unit)
    return units

func _apply_terrain_effects() -> void:
    if stage_data == null or stage_data.terrain_features.is_empty():
        return

    var pending_fire_spread_count: int = 0
    for unit in _get_all_units():
        var feature_effects: Dictionary = _get_feature_effects_for_unit(unit)
        var fire_damage: int = int(feature_effects.get("damage_per_turn", 0))
        if fire_damage > 0:
            _apply_fire_damage(unit, fire_damage)
            if randf() < float(feature_effects.get("fire_spread_chance", 0.0)):
                pending_fire_spread_count += 1

        if unit.faction == "ally":
            var heal_per_turn: int = int(feature_effects.get("heal_per_turn", 0))
            if heal_per_turn > 0:
                unit.apply_heal(heal_per_turn)

    for _index in range(pending_fire_spread_count):
        _spread_fire()

func _apply_fire_damage(unit: UnitActor, damage_per_turn: int) -> void:
    if unit == null or not is_instance_valid(unit) or unit.is_defeated() or damage_per_turn <= 0:
        return
    unit.apply_damage(damage_per_turn)

func _spread_fire() -> void:
    if stage_data == null:
        return
    for center_variant in _get_positions_for_types(["fire"]):
        var center: Vector2i = center_variant
        for offset in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
            var candidate: Vector2i = center + offset
            if not _is_cell_in_bounds(candidate) or _has_feature_at(candidate, "fire"):
                continue
            stage_data.terrain_features.append({"type": "fire", "position": candidate, "radius": 0})
            return

func _apply_weather_effects() -> void:
    weather_defense_bonus_by_unit.clear()
    if stage_data == null:
        return

    weather_type = _normalize_weather_type(stage_data.weather_type)
    if combat_service != null:
        combat_service.set_weather_type(weather_type)

    if weather_type == "clear":
        return

    var weather: Dictionary = WEATHER_EFFECTS.get(weather_type, WEATHER_EFFECTS["clear"])
    if weather_type == "rain" and not _rain_environment_applied:
        if bool(weather.get("fire_extinguished", false)):
            _extinguish_fire()
        if float(weather.get("water_expansion", 1.0)) > 1.0:
            _expand_water_tiles(float(weather.get("water_expansion", 1.0)))
        _rain_environment_applied = true

    for unit in _get_all_units():
        if weather_type == "night" and _is_on_high_ground(unit.grid_position):
            var defense_bonus := int(ceil(float(unit.get_defense()) * float(weather.get("ambush_defense_bonus", 0.0))))
            if defense_bonus > 0:
                weather_defense_bonus_by_unit[unit.get_instance_id()] = defense_bonus

        if weather_type == "night":
            _apply_sacred_ground_weather_bonus(unit, float(weather.get("heal_modifier", 1.0)), false)

    if weather_type == "rain" and _active_synergy_results.has("purified"):
        var purified: Dictionary = _active_synergy_results.get("purified", {})
        for unit in _get_all_units():
            _apply_sacred_ground_weather_bonus(unit, float(purified.get("heal_bonus", 1.0)), bool(purified.get("cleanse", false)))

func _apply_sacred_ground_weather_bonus(unit: UnitActor, heal_multiplier: float, should_cleanse: bool) -> void:
    if unit == null or not is_instance_valid(unit) or stage_data == null:
        return

    for feature_variant in stage_data.terrain_features:
        var feature: Dictionary = feature_variant
        if _normalize_terrain_key(String(feature.get("type", ""))) != "sacred_ground":
            continue
        if not _is_in_radius(unit.grid_position, _get_feature_position(feature), _get_feature_radius(feature)):
            continue
        var heal_amount := int(round(float(feature.get("heal_amount", 5)) * heal_multiplier))
        if heal_amount > 0:
            unit.apply_heal(heal_amount)
        if should_cleanse:
            _cleanse_unit(unit)

func _apply_synergy_reactions() -> void:
    if stage_data == null or not stage_data.terrain_synergies_enabled:
        return

    _active_synergy_results.clear()
    var active_terrain_types: Array[String] = []
    _append_unique_string(active_terrain_types, weather_type)
    for terrain_value in stage_data.terrain_types.values():
        _append_unique_string(active_terrain_types, _normalize_terrain_key(String(terrain_value)))
    for feature_variant in stage_data.terrain_features:
        var feature: Dictionary = feature_variant
        _append_unique_string(active_terrain_types, _normalize_terrain_key(String(feature.get("type", ""))))

    for synergy in SYNERGY_REACTIONS:
        var triggers: Array = synergy.get("trigger", [])
        var has_all: bool = true
        for trigger_value in triggers:
            if _normalize_terrain_key(String(trigger_value)) not in active_terrain_types:
                has_all = false
                break
        if has_all:
            _trigger_synergy_effect(synergy)

func _trigger_synergy_effect(synergy: Dictionary) -> void:
    var result_key := _normalize_terrain_key(String(synergy.get("result", "")))
    if result_key.is_empty():
        return

    _active_synergy_results[result_key] = synergy.duplicate(true)
    if result_key in ["steam", "smoke"] and bool(_triggered_synergy_keys.get(result_key, false)):
        return

    _triggered_synergy_keys[result_key] = true
    if result_key not in _synergy_activation_log:
        _synergy_activation_log.append(result_key)

    match result_key:
        "steam":
            _apply_status_to_area(int(synergy.get("duration", 0)), "steam_blocked", String(synergy.get("effect", "")), ["fire", "water"])
        "smoke":
            _deal_area_damage(int(synergy.get("damage", 0)), int(synergy.get("spread", 0)), ["fire"])
            _spread_terrain_feature("smoke", int(synergy.get("spread", 0)), ["fire"])
        "ambush":
            pass
        "purified":
            pass

func _append_unique_string(target: Array[String], value: String) -> void:
    if value.is_empty() or value in target:
        return
    target.append(value)

func _get_feature_position(feature: Dictionary) -> Vector2i:
    return feature.get("position", Vector2i.ZERO)

func _get_feature_radius(feature: Dictionary) -> int:
    return int(feature.get("radius", 0))

func _is_on_high_ground(cell: Vector2i) -> bool:
    if stage_data == null:
        return false
    if _normalize_terrain_key(String(stage_data.get_terrain_type(cell))) == "high_ground":
        return true
    for feature_variant in stage_data.terrain_features:
        var feature: Dictionary = feature_variant
        if _normalize_terrain_key(String(feature.get("type", ""))) != "high_ground":
            continue
        if _is_in_radius(cell, _get_feature_position(feature), _get_feature_radius(feature)):
            return true
    return false

func _is_in_radius(cell: Vector2i, center: Vector2i, radius: int) -> bool:
    return _distance_between_cells(cell, center) <= maxi(radius, 0)

func _cleanse_unit(unit: UnitActor) -> void:
    if status_service == null or unit == null or not is_instance_valid(unit):
        return
    var stack_count: int = status_service.get_oblivion_stack(unit)
    if stack_count > 0:
        status_service.cleanse_stack(unit, stack_count, "weather_purified")

func _extinguish_fire() -> void:
    if stage_data == null or stage_data.terrain_features.is_empty():
        return
    var remaining_features: Array[Dictionary] = []
    for feature_variant in stage_data.terrain_features:
        var feature: Dictionary = feature_variant
        if _normalize_terrain_key(String(feature.get("type", ""))) == "fire":
            continue
        remaining_features.append(feature)
    stage_data.terrain_features = remaining_features

func _expand_water_tiles(multiplier: float) -> void:
    if stage_data == null or stage_data.terrain_features.is_empty():
        return
    var spread_radius := maxi(1, int(ceil(multiplier - 1.0)))
    var additions: Array[Dictionary] = []
    for source_position_variant in _get_positions_for_types(["water"]):
        var source_position: Vector2i = source_position_variant
        for dx in range(-spread_radius, spread_radius + 1):
            for dy in range(-spread_radius, spread_radius + 1):
                var candidate: Vector2i = source_position + Vector2i(dx, dy)
                if candidate == source_position or not _is_cell_in_bounds(candidate) or _has_feature_at(candidate, "water"):
                    continue
                additions.append({"type": "water", "position": candidate, "radius": 0})
    if not additions.is_empty():
        stage_data.terrain_features.append_array(additions)

func _apply_status_to_area(duration: int, status_id: String, effect: String, source_types: Array[String] = ["fire"]) -> void:
    for center_variant in _get_positions_for_types(source_types):
        var center: Vector2i = center_variant
        _active_area_statuses.append({
            "status": status_id,
            "effect": effect,
            "center": center,
            "radius": 0,
            "remaining_turns": duration
        })

func _deal_area_damage(amount: int, radius: int = 0, source_types: Array[String] = ["fire"]) -> void:
    if amount <= 0:
        return
    var centers: Array[Vector2i] = _get_positions_for_types(source_types)
    if centers.is_empty():
        return
    for unit in _get_all_units():
        for center in centers:
            if _is_in_radius(unit.grid_position, center, radius):
                unit.apply_damage(amount)
                break

func _spread_terrain_feature(feature_type: String, spread: int, source_types: Array[String] = ["fire"]) -> void:
    if spread <= 0 or stage_data == null:
        return
    var additions: Array[Dictionary] = []
    for center_variant in _get_positions_for_types(source_types):
        var center: Vector2i = center_variant
        for dx in range(-spread, spread + 1):
            for dy in range(-spread, spread + 1):
                var candidate: Vector2i = center + Vector2i(dx, dy)
                if not _is_cell_in_bounds(candidate) or _has_feature_at(candidate, feature_type):
                    continue
                additions.append({"type": feature_type, "position": candidate, "radius": 0})
    if not additions.is_empty():
        stage_data.terrain_features.append_array(additions)

func _tick_area_statuses() -> void:
    if _active_area_statuses.is_empty():
        return
    var remaining_statuses: Array[Dictionary] = []
    for status_entry in _active_area_statuses:
        var turns_left := int(status_entry.get("remaining_turns", 0)) - 1
        if turns_left > 0:
            status_entry["remaining_turns"] = turns_left
            remaining_statuses.append(status_entry)
    _active_area_statuses = remaining_statuses

func _get_positions_for_types(source_types: Array[String]) -> Array[Vector2i]:
    var positions: Array[Vector2i] = []
    var normalized_types: Array[String] = []
    for source_type in source_types:
        normalized_types.append(_normalize_terrain_key(String(source_type)))

    for feature_variant in stage_data.terrain_features:
        var feature: Dictionary = feature_variant
        if _normalize_terrain_key(String(feature.get("type", ""))) in normalized_types:
            positions.append(_get_feature_position(feature))

    for cell_variant in stage_data.terrain_types.keys():
        var cell: Vector2i = cell_variant
        if _normalize_terrain_key(String(stage_data.terrain_types.get(cell, &"plain"))) in normalized_types and cell not in positions:
            positions.append(cell)
    return positions

func _has_feature_at(cell: Vector2i, feature_type: String) -> bool:
    for feature_variant in stage_data.terrain_features:
        var feature: Dictionary = feature_variant
        if _normalize_terrain_key(String(feature.get("type", ""))) == _normalize_terrain_key(feature_type) and _get_feature_position(feature) == cell:
            return true
    return false

func _transition_to(next_phase: int, reason: String, payload: Dictionary = {}) -> bool:
    if current_phase == next_phase:
        _record_phase_transition(current_phase, next_phase, reason, payload)
        _sync_hud_phase(reason, payload)
        return true

    var allowed: Array = PHASE_TRANSITIONS.get(current_phase, [])
    if not (next_phase in allowed):
        push_error("Invalid battle phase transition %s -> %s" % [_phase_name(current_phase), _phase_name(next_phase)])
        return false

    var previous_phase: int = current_phase
    current_phase = next_phase

    _record_phase_transition(previous_phase, next_phase, reason, payload)
    _sync_hud_phase(reason, payload)
    return true

func _record_phase_transition(from_phase: int, to_phase: int, reason: String, payload: Dictionary) -> void:
    var entry := {
        "from": _phase_name(from_phase),
        "to": _phase_name(to_phase),
        "reason": reason,
        "payload": payload,
        "round": round_index
    }

    phase_transition_history.append(entry)
    if phase_transition_history.size() > 40:
        phase_transition_history.pop_front()

func _sync_hud_phase(reason: String, payload: Dictionary) -> void:
    hud.set_round(round_index)
    hud.set_phase(_phase_name(current_phase).replace("_", " "))
    hud.set_weather_type(weather_type)
    _refresh_objective_surfaces()
    hud.set_stage_title(stage_data.get_display_title() if stage_data != null else "")
    hud.set_landmarks(stage_data.landmark_labels if stage_data != null else PackedStringArray())
    hud.set_transition_reason(reason, payload)
    _sync_selection_hud()

func _refresh_objective_surfaces() -> void:
    if hud == null:
        return
    hud.set_objective(_get_objective_text())
    hud.set_objective_hint(_get_objective_hint())
    hud.set_risk_forecast_cards(_build_risk_forecast_cards())
    hud.set_inventory_snapshot(
        _get_inventory_panel_title(),
        _get_objective_text(),
        get_party_summary_lines(),
        get_inventory_entries()
    )

func get_secret_hint_snapshot() -> Dictionary:
    return {
        "contract": _active_secret_hint_contract.duplicate(true),
        "level": _secret_hint_level,
        "revealed_lines": _secret_hint_revealed_lines.duplicate(),
    }

func _phase_name(phase_value: int) -> String:
    return PHASE_NAMES.get(phase_value, "UNKNOWN")

func get_party_summary_lines() -> Array[String]:
    var lines: Array[String] = []
    for unit in ally_units:
        if not is_instance_valid(unit) or unit.unit_data == null:
            continue

        var state_label := String(turn_manager.get_unit_state(unit)).to_lower()
        lines.append("%s  HP %d/%d  ATK %d  DEF %d  %s" % [
            unit.unit_data.display_name,
            unit.current_hp,
            unit.unit_data.max_hp,
            unit.get_attack(),
            unit.get_defense(),
            state_label
        ])

    if lines.is_empty():
        lines.append("No allied roster available.")
    return lines

func get_inventory_entries() -> Array[String]:
    if battle_reward_log.is_empty():
        return ["No recovered supplies yet."]
    return battle_reward_log.duplicate()

func get_player_interface_snapshot() -> Dictionary:
    return {
        "stage_title": _get_inventory_panel_title(),
        "objective": _get_objective_text(),
        "objective_state": get_objective_state_snapshot(),
        "transition_surface": hud.get_transition_surface_snapshot() if hud != null and hud.has_method("get_transition_surface_snapshot") else {},
        "party_entries": get_party_summary_lines(),
        "party_details": get_party_detail_entries(),
        "inventory_entries": get_inventory_entries(),
        "phase": _phase_name(current_phase),
        "round": round_index
    }

func get_party_detail_entries() -> Array[Dictionary]:
    var details: Array[Dictionary] = []
    for unit in ally_units:
        if not is_instance_valid(unit) or unit.unit_data == null:
            continue

        var default_skill_name := "No skill"
        var skill = unit.get_default_skill()
        if skill != null:
            default_skill_name = skill.display_name
        var skill_entries: Array[Dictionary] = _build_skill_detail_entries(unit.unit_data.get_all_skills())
        var accessory_name: String = "None"
        var weapon_name: String = "Standard Issue"
        var armor_name: String = "Field Garb"
        var equipped_weapon: WeaponData = unit.get_equipped_weapon()
        var equipped_armor: ArmorData = unit.get_equipped_armor()
        var equipped_accessory: AccessoryData = unit.get_equipped_accessory()
        if equipped_weapon != null:
            weapon_name = equipped_weapon.display_name
        if equipped_armor != null:
            armor_name = equipped_armor.display_name
        if equipped_accessory != null:
            accessory_name = equipped_accessory.display_name

        details.append({
            "name": unit.unit_data.display_name,
            "unit_id": String(unit.unit_data.unit_id),
            "hp_text": "%d/%d" % [unit.current_hp, unit.unit_data.max_hp],
            "status": String(turn_manager.get_unit_state(unit)).capitalize(),
            "attack": unit.get_attack(),
            "defense": unit.get_defense(),
            "move": _get_effective_movement(unit),
            "range": _get_effective_attack_range(unit),
            "skill": default_skill_name,
            "skill_entries": skill_entries,
            "weapon_slot": weapon_name,
            "armor_slot": armor_name,
            "accessory_slot": accessory_name
        })

    return details

func _build_skill_detail_entries(skills: Array) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for skill in skills:
        if skill == null:
            continue
        var cost_text: String = skill.get_resource_cost_text() if skill.has_method("get_resource_cost_text") else ""
        var current_level: int = int(skill.skill_level)
        var current_exp: int = int(skill.skill_exp)
        var exp_to_next: int = skill.exp_to_next_level(current_level) if skill.has_method("exp_to_next_level") else 0
        var exp_remaining: int = skill.exp_remaining() if skill.has_method("exp_remaining") else maxi(exp_to_next - current_exp, 0)
        var is_max_level: bool = skill.is_max_level() if skill.has_method("is_max_level") else exp_to_next <= 0
        entries.append({
            "skill_id": String(skill.skill_id),
            "name": String(skill.display_name),
            "description": String(skill.description),
            "cost_text": cost_text,
            "level": current_level,
            "exp": current_exp,
            "exp_to_next": exp_to_next,
            "exp_remaining": exp_remaining,
            "is_max": is_max_level,
        })
    return entries

func get_objective_state_snapshot() -> Dictionary:
    var resolved_object_ids: Array[StringName] = []
    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor) or object_actor.object_data == null or not object_actor.is_resolved:
            continue
        resolved_object_ids.append(object_actor.object_data.object_id)

    var resolved_count: int = resolved_object_ids.size()
    var required_count: int = interactive_objects.size()
    var state_id: StringName = _get_relief_objective_state_id()
    if state_id == &"":
        state_id = _get_objective_state_id(resolved_count, required_count)

    return {
        "state_id": state_id,
        "resolved_interactions": resolved_count,
        "required_interactions": required_count,
        "resolved_object_ids": resolved_object_ids
    }

func _record_reward_entry(entry_text: String) -> void:
    var normalized_entry := entry_text.strip_edges()
    if normalized_entry.is_empty():
        return

    if not battle_reward_log.has(normalized_entry):
        battle_reward_log.append(normalized_entry)

func get_last_result_summary() -> Dictionary:
    return last_result_summary.duplicate(true)

func get_last_name_call_snapshot() -> Dictionary:
    return {
        "line": last_name_call_line,
        "speaker_id": String(last_name_call_speaker_id)
    }

func _get_stage_memory_entries() -> Array[String]:
    return _get_stage_record_entries("memory")

func _get_stage_evidence_entries() -> Array[String]:
    return _get_stage_record_entries("evidence")

func _get_stage_letter_entries() -> Array[String]:
    return _get_stage_record_entries("letter")

func _get_stage_record_entries(record_kind: String) -> Array[String]:
    if stage_data == null:
        return []
    var registry_entries: Variant = []
    match record_kind:
        "memory":
            registry_entries = _lookup_stage_record_registry_entry([
                CampaignContentRegistry.CH01_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH02_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH03_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH04_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH05_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH06_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH07_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH08_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH09A_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH09B_STAGE_MEMORY_LOG,
                CampaignContentRegistry.CH10_STAGE_MEMORY_LOG,
            ])
        "evidence":
            registry_entries = _lookup_stage_record_registry_entry([
                CampaignContentRegistry.CH01_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH02_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH03_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH04_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH05_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH06_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH07_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH08_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH09A_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH09B_STAGE_EVIDENCE_LOG,
                CampaignContentRegistry.CH10_STAGE_EVIDENCE_LOG,
            ])
        "letter":
            registry_entries = _lookup_stage_record_registry_entry([
                CampaignContentRegistry.CH01_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH02_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH03_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH04_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH05_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH06_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH07_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH08_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH09A_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH09B_STAGE_LETTER_LOG,
                CampaignContentRegistry.CH10_STAGE_LETTER_LOG,
            ])
        _:
            registry_entries = []
    return _format_stage_record_entries(registry_entries)

func _lookup_stage_record_registry_entry(registries: Array) -> Variant:
    for registry in registries:
        if typeof(registry) != TYPE_DICTIONARY:
            continue
        if registry.has(stage_data.stage_id):
            return registry.get(stage_data.stage_id, [])
    return []

func _format_stage_record_entries(entries: Variant) -> Array[String]:
    var lines: Array[String] = []
    if typeof(entries) != TYPE_ARRAY:
        return lines
    for entry in entries:
        if typeof(entry) == TYPE_DICTIONARY:
            lines.append("%s — %s" % [
                String(entry.get("title", "Record")),
                String(entry.get("summary", ""))
            ])
        else:
            var text := String(entry).strip_edges()
            if not text.is_empty():
                lines.append(text)
    return lines

func _build_bonus_exp_contribution_snapshot() -> Dictionary:
    var contribution_by_unit: Dictionary = {}
    for unit in ally_units:
        if not is_instance_valid(unit) or unit.unit_data == null:
            continue
        var contribution_score: int = 0
        var unit_state: StringName = turn_manager.get_unit_state(unit) if turn_manager != null else &""
        if unit_state == TurnManager.STATE_MOVED:
            contribution_score += 1
        elif unit_state == TurnManager.STATE_ACTED or unit_state == TurnManager.STATE_EXHAUSTED:
            contribution_score += 2
        if unit.current_hp < unit.unit_data.max_hp:
            contribution_score += 1
        contribution_by_unit[String(unit.unit_data.unit_id)] = contribution_score
    return contribution_by_unit

func _build_result_summary_text(summary: Dictionary) -> String:
    var lines: Array[String] = []
    lines.append("Victory")
    lines.append("Objective: %s" % String(summary.get("objective", "")))
    lines.append("Stars Earned: %d" % int(summary.get("stars_earned", 1)))
    if bool(summary.get("turn_limit_met", false)):
        lines.append("Turn Limit: Met")
    var completed_objectives := _variant_to_string_array(summary.get("optional_objectives_completed", []))
    if not completed_objectives.is_empty():
        _append_result_section(lines, "Optional Objectives Completed", completed_objectives)
    var control_relief_entries := _variant_to_string_array(summary.get("control_relief_entries", []))
    if not control_relief_entries.is_empty():
        _append_result_section(lines, "Control Relief", control_relief_entries)
    var fragment_id := String(summary.get("fragment_id", ""))
    if not fragment_id.is_empty():
        lines.append("Memory Fragment: %s" % fragment_id)
    var unit_exp_results: Array = summary.get("unit_exp_results", [])
    if not unit_exp_results.is_empty():
        lines.append("Unit EXP:")
        for entry in unit_exp_results:
            var display_name := String(entry.get("display_name", entry.get("unit_id", "Unit")))
            lines.append("- %s Lv %d -> %d (+%d EXP)%s" % [
                display_name,
                int(entry.get("level_before", 1)),
                int(entry.get("level_after", 1)),
                int(entry.get("exp_gain", 0)),
                " LEVEL UP!" if bool(entry.get("leveled_up", false)) else ""
            ])
    var bonus_exp_pool := int(summary.get("bonus_exp_pool", 0))
    var bonus_exp_results: Array = summary.get("bonus_exp_results", [])
    if bonus_exp_pool > 0 and not bonus_exp_results.is_empty():
        lines.append("Bonus EXP: %d" % bonus_exp_pool)
        for entry in bonus_exp_results:
            var display_name := String(entry.get("display_name", entry.get("unit_id", "Unit")))
            lines.append("- %s bonus +%d EXP" % [display_name, int(entry.get("exp_gain", 0))])
    var fragment_ids := _variant_to_string_array(summary.get("recovered_fragment_ids", []))
    if not fragment_ids.is_empty():
        lines.append("Recovered Fragments: %s" % ", ".join(fragment_ids))
    var command_unlocked := String(summary.get("command_unlocked", ""))
    if not command_unlocked.is_empty():
        lines.append("Command Unlocked: %s" % command_unlocked)
    var command_ids := _variant_to_string_array(summary.get("unlocked_command_ids", []))
    if not command_ids.is_empty():
        lines.append("Unlocked Commands: %s" % ", ".join(command_ids))
    var support_attack_count := int(summary.get("support_attack_count", 0))
    if support_attack_count > 0:
        lines.append("Support Attacks: %d" % support_attack_count)
        var support_bond := int(summary.get("supporter_bond_level", 0))
        if support_bond > 0:
            lines.append("Support Bond: %d" % support_bond)
    var support_conversations: Array = summary.get("support_conversations", [])
    if not support_conversations.is_empty():
        lines.append("Support Rank Up!")
        for entry_variant in support_conversations:
            if typeof(entry_variant) != TYPE_DICTIONARY:
                continue
            var entry: Dictionary = entry_variant
            var pair_label: String = String(entry.get("pair_label", "Support"))
            var rank_label: String = String(entry.get("rank_label", ""))
            var pair_line: String = "- %s" % pair_label
            if not rank_label.is_empty():
                pair_line += " (%s)" % rank_label
            lines.append(pair_line)
            var support_text: String = String(entry.get("text", "")).strip_edges()
            if not support_text.is_empty():
                lines.append("  %s" % support_text)
    var name_call_line: String = String(summary.get("name_call_line", "")).strip_edges()
    if not name_call_line.is_empty():
        lines.append("Name Call: %s" % name_call_line)
    for entry in _variant_to_string_array(summary.get("telemetry_summary", [])):
        lines.append(entry)
    lines.append("Burden Delta: %+d" % int(summary.get("burden_delta", 0)))
    lines.append("Trust Delta: %+d" % int(summary.get("trust_delta", 0)))
    _append_result_section(lines, "Rewards", _variant_to_string_array(summary.get("reward_entries", [])))
    _append_result_section(lines, "Memory", _variant_to_string_array(summary.get("memory_entries", [])))
    _append_result_section(lines, "Evidence", _variant_to_string_array(summary.get("evidence_entries", [])))
    _append_result_section(lines, "Letters", _variant_to_string_array(summary.get("letter_entries", [])))
    return "\n".join(lines)

func _append_result_section(lines: Array[String], heading: String, entries: Array[String]) -> void:
    lines.append("%s:" % heading)
    if entries.is_empty():
        lines.append("- None")
        return
    for entry in entries:
        lines.append("- %s" % entry)

func _build_telemetry_summary_lines(session_snapshot: Dictionary) -> Array[String]:
    var lines: Array[String] = []
    if session_snapshot.is_empty():
        return lines
    lines.append("Telemetry: rounds %d / objective %.2f" % [
        int(session_snapshot.get(TelemetryService.KEY_ROUNDS, 0)),
        float(session_snapshot.get(TelemetryService.KEY_OBJECTIVE_COMPLETION_RATE, 0.0))
    ])
    var status_counts: Dictionary = Dictionary(session_snapshot.get(TelemetryService.KEY_STATUS_COUNTS, {}))
    lines.append("Status Counts: oblivion %d / cleansed %d / rescues %d" % [
        int(status_counts.get("oblivion_applied", 0)),
        int(status_counts.get("oblivion_cleansed", 0)),
        int(status_counts.get("rescues", 0))
    ])
    var boss_phase_timings: Dictionary = Dictionary(session_snapshot.get(TelemetryService.KEY_BOSS_PHASE_TIMINGS, {}))
    if not boss_phase_timings.is_empty():
        var boss_phase_lines: Array[String] = []
        var phase_names: Array[String] = []
        for phase_name in boss_phase_timings.keys():
            phase_names.append(String(phase_name))
        phase_names.sort()
        for phase_name in phase_names:
            boss_phase_lines.append("%s@R%d" % [phase_name, int(boss_phase_timings.get(phase_name, 0))])
        lines.append("Boss Phases: %s" % ", ".join(boss_phase_lines))
    var failure_causes: Array[String] = _variant_to_string_array(session_snapshot.get(TelemetryService.KEY_FAILURE_CAUSES, []))
    if not failure_causes.is_empty():
        lines.append("Failure Causes: %s" % ", ".join(failure_causes))
    return lines

func _get_control_relief_result_entries() -> Array[String]:
    var entries: Array[String] = []
    if bool(battle_objective_flags.get("lete_escape_route_cut", false)):
        entries.append("레테 추격선 약화 / 깊은 shadow lane 재형성 차단")
    if bool(battle_objective_flags.get("melkion_archive_stabilized", false)):
        entries.append("기록보관소 안정화 / 중앙 archive tile 고정")
    if bool(battle_objective_flags.get("karon_bell_line_broken", false)):
        entries.append("종선 개방 / central bell choke 해제")
    return entries

func _check_optional_objectives() -> Dictionary:
    var completed_objectives: Array[String] = []
    var failed_objectives: Array[String] = []
    if stage_data == null:
        return {
            "stars": 1,
            "completed": completed_objectives,
            "failed": failed_objectives,
            "turn_limit_met": false,
        }

    for objective_variant in stage_data.optional_objectives:
        var objective: Dictionary = objective_variant
        var objective_id: String = String(objective.get("id", "objective"))
        var condition: String = String(objective.get("condition", ""))
        if _evaluate_objective(condition):
            completed_objectives.append(objective_id)
        else:
            failed_objectives.append(objective_id)

    return {
        "stars": 1,
        "completed": completed_objectives,
        "failed": failed_objectives,
        "turn_limit_met": round_index <= max(1, stage_data.turn_limit),
    }

func _evaluate_objective(condition: String) -> bool:
    var normalized := condition.strip_edges()
    if normalized.is_empty():
        return false
    if normalized == "no_ally_casualties":
        var session_snapshot: Dictionary = telemetry_service.get_session_snapshot() if telemetry_service != null else {}
        return int(session_snapshot.get(TelemetryService.KEY_ALLY_DEATHS, 0)) <= 0
    if normalized.begins_with("flag:"):
        return _get_objective_flag(normalized.trim_prefix("flag:"))
    if normalized.begins_with("survive_unit:"):
        return _has_living_unit_with_id(StringName(normalized.trim_prefix("survive_unit:")))
    return _get_objective_flag(normalized)

func _get_objective_flag(flag_id: String) -> bool:
    return bool(battle_test_flags.get(flag_id, false)) or bool(battle_objective_flags.get(flag_id, false))

func _has_living_unit_with_id(unit_id: StringName) -> bool:
    for unit in ally_units:
        if not is_instance_valid(unit) or unit.is_defeated() or unit.unit_data == null:
            continue
        if unit.unit_data.unit_id == unit_id:
            return true
    return false

func _build_attack_context(attacker: UnitActor, defender: UnitActor, extra_context: Dictionary = {}, include_bond_bonus: bool = true) -> Dictionary:
    var defender_terrain_bonus: int = stage_data.get_defense_bonus(defender.grid_position)
    if int(ignored_terrain_turns_by_unit.get(defender.get_instance_id(), 0)) > 0:
        defender_terrain_bonus = 0
    defender_terrain_bonus += int(weather_defense_bonus_by_unit.get(defender.get_instance_id(), 0))
    defender_terrain_bonus += int(_get_feature_effects_for_unit(defender).get("defense_bonus", 0))

    var counter_terrain_bonus: int = stage_data.get_defense_bonus(attacker.grid_position)
    if int(ignored_terrain_turns_by_unit.get(attacker.get_instance_id(), 0)) > 0:
        counter_terrain_bonus = 0
    counter_terrain_bonus += int(weather_defense_bonus_by_unit.get(attacker.get_instance_id(), 0))
    counter_terrain_bonus += int(_get_feature_effects_for_unit(attacker).get("defense_bonus", 0))

    var attack_context: Dictionary = {
        "defense_bonus": defender_terrain_bonus,
        "terrain_type": String(stage_data.get_terrain_type(defender.grid_position)),
        "allow_counterattack": true,
        "counter_context": {
            "defense_bonus": counter_terrain_bonus,
            "terrain_type": String(stage_data.get_terrain_type(attacker.grid_position))
        }
    }
    for key in extra_context.keys():
        attack_context[key] = extra_context[key]

    if attacker.faction == "ally" and progression_service != null:
        var burden_fx := progression_service.get_burden_effect()
        var atk_bonus: int = int(attack_context.get("attack_bonus", 0))
        atk_bonus += int(burden_fx.get("damage_mod", 0))
        attack_context["attack_bonus"] = atk_bonus

    if attacker.unit_data != null and attacker.unit_data.boss_pattern == &"karon_final_ch10_05" and _has_living_enemy_with_unit_id(&"enemy_name_call_anchor"):
        attack_context["attack_bonus"] = int(attack_context.get("attack_bonus", 0)) + 2

    if include_bond_bonus and attacker.faction == "ally" and bond_service != null and int(bond_suppression_turns_by_unit.get(attacker.get_instance_id(), 0)) <= 0:
        var bond_atk_bonus: int = 0
        for unit: UnitActor in ally_units:
            if unit == attacker or not is_instance_valid(unit) or unit.is_defeated():
                continue
            if bond_service.get_bond(unit.unit_data.unit_id) >= 2:
                var dist: int = abs(attacker.grid_position.x - unit.grid_position.x) + abs(attacker.grid_position.y - unit.grid_position.y)
                if dist <= 1:
                    bond_atk_bonus += 1
                    break
        if bond_atk_bonus > 0:
            attack_context["bond_attack_bonus"] = bond_atk_bonus

    var defender_id: int = defender.get_instance_id()
    if enemy_damage_multiplier_by_unit.has(defender_id):
        attack_context["damage_multiplier"] = float(enemy_damage_multiplier_by_unit.get(defender_id, 1.0))

    if defender.unit_data != null and defender.unit_data.boss_pattern == &"melkion_ch09b_05" and get_boss_phase_for_unit(defender) == &"archive_mode":
        attack_context["defense_bonus"] = int(attack_context.get("defense_bonus", 0)) + (defender.get_defense() * 2)

    if status_service != null:
        var status_fx: Dictionary = status_service.get_effects(attacker)
        attack_context["oblivion_accuracy_mod"] = int(status_fx.get("accuracy_mod", 0))
        attack_context["oblivion_evasion_mod"] = int(status_fx.get("evasion_mod", 0))
        attack_context["oblivion_skills_sealed"] = bool(status_fx.get("skills_sealed", false))

    return attack_context

func _variant_to_string_array(value: Variant) -> Array[String]:
    if value is Array[String]:
        return (value as Array[String]).duplicate()
    if value is Array:
        var result: Array[String] = []
        for item in value:
            result.append(String(item))
        return result
    return []

func _has_unlocked_passive_card(card_id: StringName) -> bool:
    if card_id == &"" or progression_service == null:
        return false
    var data: ProgressionData = progression_service.get_data()
    return data != null and data.has_passive_card(card_id)

func _get_ally_display_name(unit_id: StringName) -> String:
    for unit in ally_units:
        if is_instance_valid(unit) and unit.unit_data != null and unit.unit_data.unit_id == unit_id:
            return unit.unit_data.display_name
    return String(unit_id)

func _get_inventory_panel_title() -> String:
    if stage_data == null:
        return "Field Inventory"
    return "%s Inventory" % stage_data.get_display_title()

func _get_objective_text() -> String:
    if stage_data == null:
        return "Defeat all enemies."

    var template_objective: String = StageRuleTemplateService.get_objective_override(stage_data, battle_objective_flags)
    if not template_objective.is_empty():
        return template_objective

    match String(stage_data.stage_id):
        "CH08_05":
            if bool(battle_objective_flags.get("lete_escape_route_cut", false)):
                return "표식 재설정 차단선을 유지하며 전면 추격만 관리한다."
        "CH09B_05":
            if bool(battle_objective_flags.get("melkion_archive_stabilized", false)):
                return "archive center 유지를 우선하고 flank revision만 정리한다."
        "CH10_05":
            if bool(battle_objective_flags.get("karon_final_toll", false)):
                return "bell line을 버티며 all allies marked pressure를 견딘다. final toll 동안 bond suppression을 감안해 중앙을 잃지 않는다."
            if bool(battle_objective_flags.get("karon_bell_line_broken", false)):
                return "bell line 유지를 우선하고 열린 중앙 진입을 끝까지 붙든다."

    var resolved_count: int = _get_resolved_interaction_count()
    var progress_text: String = _get_interaction_objective_text(resolved_count)
    if not progress_text.is_empty():
        return progress_text

    if not stage_data.objective_text.strip_edges().is_empty():
        return stage_data.objective_text.strip_edges()

    match String(stage_data.win_condition):
        "defeat_all_enemies":
            return "Defeat all enemies."
        "resolve_all_interactions":
            return "Secure all marked objective points."
        "resolve_all_interactions_and_defeat_all_enemies":
            return "Secure all objective points and defeat all enemies."
        _:
            return String(stage_data.win_condition).replace("_", " ")

func _build_risk_forecast_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if stage_data == null:
        return cards

    for raw_card in stage_data.risk_forecast_cards:
        var title := String(raw_card.get("title", "")).strip_edges()
        var detail := String(raw_card.get("detail", "")).strip_edges()
        if title.is_empty() and detail.is_empty():
            continue
        cards.append({"title": title, "detail": detail})
        if cards.size() >= 3:
            return cards

    var objective_line := _get_objective_text().strip_edges()
    if objective_line.is_empty():
        objective_line = _get_interaction_objective_text(_get_resolved_interaction_count()).strip_edges()
    if not objective_line.is_empty():
        cards.append({
            "title": "Primary Risk",
            "detail": objective_line
        })

    var weather_line := ""
    match _normalize_weather_type(stage_data.weather_type):
        "rain":
            weather_line = "Rain pressure widens slippery lanes and punishes late interaction routes."
        "night":
            weather_line = "Night pressure shortens vision and makes lane reads arrive later."
        _:
            weather_line = "Field pressure is active; keep the lane plan readable before committing."
    cards.append({
        "title": "Field Pressure",
        "detail": weather_line
    })

    var object_names: Array[String] = []
    for object_data in stage_data.interactive_objects:
        if object_data == null:
            continue
        var object_name := String(object_data.display_name).strip_edges()
        if object_name.is_empty():
            object_name = String(object_data.object_id)
        object_names.append(object_name)
        if object_names.size() >= 2:
            break
    var mitigation_detail := "Use nearby interactions to buy back tempo before the line collapses."
    if not object_names.is_empty():
        mitigation_detail = "Stabilize %s to reduce the route pressure before overextending." % ", ".join(object_names)
    cards.append({
        "title": "Mitigation",
        "detail": mitigation_detail
    })

    return cards.slice(0, 3)

func _build_selection_preview_labels(unit: UnitActor) -> Array[String]:
    var labels: Array[String] = []
    if unit == null or not is_instance_valid(unit) or stage_data == null:
        return labels

    var secret_hint_lines: Array[String] = _get_secret_hint_preview_lines(unit)
    if not secret_hint_lines.is_empty():
        labels.append_array(secret_hint_lines)
        return labels

    var interactable_objects_nearby: Array[InteractiveObjectActor] = []
    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor) or object_actor.object_data == null or object_actor.is_resolved:
            continue
        if unit.grid_position.distance_to(object_actor.grid_position) > float(max(1, object_actor.object_data.interaction_range)):
            continue
        interactable_objects_nearby.append(object_actor)

    if not interactable_objects_nearby.is_empty():
        var target_object := interactable_objects_nearby[0]
        var target_name := String(target_object.object_data.display_name).strip_edges()
        if target_name.is_empty():
            target_name = String(target_object.object_data.object_id)
        labels.append("Objective +1")
        labels.append(target_name)
        var next_state_text := _get_interaction_objective_text(mini(_get_resolved_interaction_count() + 1, interactive_objects.size())).strip_edges()
        if not next_state_text.is_empty():
            labels.append(next_state_text)
        return labels

    if _get_attackable_enemy_count(unit) > 0:
        labels.append("Pressure -1")
    return labels

func _get_objective_hint() -> String:
    if stage_data == null:
        return ""
    var template_hint: String = StageRuleTemplateService.get_objective_hint_override(stage_data, battle_objective_flags)
    if not template_hint.is_empty():
        return _merge_secret_hint_into_text(template_hint)
    match String(stage_data.stage_id):
        "CH08_05":
            if bool(battle_objective_flags.get("lete_escape_route_cut", false)):
                return _merge_secret_hint_into_text("깊은 추격선은 약화되었다. 전면 shadow lane만 경계하며 표식 재설정을 끊는다.")
        "CH09B_05":
            if bool(battle_objective_flags.get("melkion_archive_stabilized", false)):
                return _merge_secret_hint_into_text("중앙 archive tile은 안정화되었다. flank revision lane만 경계하며 rewrite를 늦춘다.")
        "CH10_05":
            if bool(battle_objective_flags.get("karon_final_toll", false)):
                return _merge_secret_hint_into_text("all allies가 bell pressure 범위에 들어갔다. bond bonus 없이 버틸 수 있게 formation을 재정렬하고 marked lane를 끊는다.")
            if bool(battle_objective_flags.get("karon_bell_line_broken", false)):
                return _merge_secret_hint_into_text("bell choke는 열렸다. 중앙 진입을 유지하며 남은 bell lane pressure만 관리한다.")
    return _merge_secret_hint_into_text(stage_data.stage_objective_hint.strip_edges())

func _are_all_interactive_objects_resolved() -> bool:
    if interactive_objects.is_empty():
        return false

    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor):
            continue
        if not object_actor.is_resolved:
            return false
    return true

func _get_resolved_interaction_count() -> int:
    var resolved_count: int = 0
    for object_actor in interactive_objects:
        if is_instance_valid(object_actor) and object_actor.is_resolved:
            resolved_count += 1
    return resolved_count

func _get_interaction_objective_text(resolved_count: int) -> String:
    if stage_data == null or stage_data.interaction_objective_texts.is_empty():
        return ""

    var clamped_index: int = clampi(resolved_count, 0, stage_data.interaction_objective_texts.size() - 1)
    return String(stage_data.interaction_objective_texts[clamped_index]).strip_edges()

func _initialize_secret_hint_contract() -> void:
    if stage_data == null:
        return
    _active_secret_hint_contract = Dictionary(stage_data.secret_hint_contract).duplicate(true)
    _secret_hint_rules.clear()
    _secret_hint_revealed_lines.clear()
    _secret_hint_level = 0
    if _active_secret_hint_contract.is_empty():
        return
    for raw_rule in _active_secret_hint_contract.get("reveal_rules", []):
        if typeof(raw_rule) != TYPE_DICTIONARY:
            continue
        _secret_hint_rules.append(Dictionary(raw_rule).duplicate(true))
    var hint_id := StringName(String(_active_secret_hint_contract.get("hint_id", "")).strip_edges())
    if progression_service == null or hint_id == &"":
        return
    var data: ProgressionData = progression_service.get_data()
    if data == null:
        return
    _secret_hint_level = data.get_hint_reveal_level(stage_data.stage_id, hint_id)
    for rule in _secret_hint_rules:
        if int(rule.get("level", 0)) > _secret_hint_level:
            continue
        var line := String(rule.get("text", "")).strip_edges()
        if not line.is_empty() and line not in _secret_hint_revealed_lines:
            _secret_hint_revealed_lines.append(line)

func _evaluate_secret_hint_reveals(trigger: String, unit: UnitActor = null) -> void:
    if _secret_hint_rules.is_empty() or stage_data == null:
        return
    var revealed_any: bool = false
    for rule in _secret_hint_rules:
        if String(rule.get("trigger", "")).strip_edges() != trigger:
            continue
        if not _secret_hint_rule_matches(rule, unit):
            continue
        if _reveal_secret_hint_rule(rule):
            revealed_any = true
    if revealed_any:
        _refresh_objective_surfaces()

func _secret_hint_rule_matches(rule: Dictionary, unit: UnitActor) -> bool:
    var level: int = int(rule.get("level", 0))
    if level <= _secret_hint_level:
        return false
    match String(rule.get("trigger", "")).strip_edges():
        "scout":
            if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
                return false
            var allowed_units: Array[String] = _variant_to_string_array(rule.get("unit_ids", []))
            return allowed_units.is_empty() or allowed_units.has(String(unit.unit_data.unit_id))
        "proximity":
            if unit == null or not is_instance_valid(unit):
                return false
            var radius: int = max(0, int(rule.get("radius", 1)))
            for cell_variant in rule.get("cells", []):
                var cell: Vector2i = cell_variant
                if unit.grid_position.distance_to(cell) <= float(radius):
                    return true
            return false
        "turn_cadence":
            return round_index >= max(1, int(rule.get("round", 1)))
        _:
            return false

func _reveal_secret_hint_rule(rule: Dictionary) -> bool:
    var next_level: int = max(0, int(rule.get("level", 0)))
    if next_level <= _secret_hint_level:
        return false
    _secret_hint_level = next_level
    var line := String(rule.get("text", "")).strip_edges()
    if not line.is_empty() and line not in _secret_hint_revealed_lines:
        _secret_hint_revealed_lines.append(line)
    var hint_id := StringName(String(_active_secret_hint_contract.get("hint_id", "")).strip_edges())
    if progression_service != null and hint_id != &"":
        var data: ProgressionData = progression_service.get_data()
        if data != null:
            data.set_hint_reveal_level(stage_data.stage_id, hint_id, _secret_hint_level)
    return true

func _merge_secret_hint_into_text(base_hint: String) -> String:
    var lines: Array[String] = []
    var normalized_base := base_hint.strip_edges()
    if not normalized_base.is_empty():
        lines.append(normalized_base)
    for line in _secret_hint_revealed_lines:
        if line not in lines:
            lines.append(line)
    return "\n".join(lines)

func _get_secret_hint_preview_lines(unit: UnitActor) -> Array[String]:
    var lines: Array[String] = []
    if _secret_hint_rules.is_empty() or unit == null or not is_instance_valid(unit):
        return lines
    for rule in _secret_hint_rules:
        var trigger := String(rule.get("trigger", "")).strip_edges()
        if trigger != "scout" and trigger != "proximity":
            continue
        if not _secret_hint_rule_matches(rule, unit):
            continue
        var preview_label := String(rule.get("preview", "")).strip_edges()
        if preview_label.is_empty():
            preview_label = "Hidden Route"
        lines.append(preview_label)
        var line := String(rule.get("text", "")).strip_edges()
        if not line.is_empty():
            lines.append(line)
        break
    return lines

func _get_objective_state_id(resolved_count: int, required_count: int) -> StringName:
    if stage_data != null and not stage_data.interaction_objective_state_ids.is_empty():
        var clamped_index: int = clampi(resolved_count, 0, stage_data.interaction_objective_state_ids.size() - 1)
        return stage_data.interaction_objective_state_ids[clamped_index]

    var win_condition: String = String(stage_data.win_condition) if stage_data != null else ""
    if win_condition == "resolve_all_interactions" or win_condition == "resolve_all_interactions_and_defeat_all_enemies":
        if required_count <= 0:
            return &"interaction_objectives_missing"
        if resolved_count >= required_count:
            return &"interaction_objectives_completed"
        if resolved_count > 0:
            return &"interaction_objectives_in_progress"
        return &"interaction_objectives_pending"

    return &"battle_objective_default"

func _get_relief_objective_state_id() -> StringName:
    if stage_data == null:
        return &""
    var template_state: StringName = StageRuleTemplateService.get_relief_objective_state_id(stage_data, battle_objective_flags)
    if template_state != &"":
        return template_state
    match String(stage_data.stage_id):
        "CH08_05":
            if bool(battle_objective_flags.get("lete_escape_route_cut", false)):
                return &"lete_route_cut_relief"
        "CH09B_05":
            if bool(battle_objective_flags.get("melkion_archive_stabilized", false)):
                return &"archive_stable_relief"
        "CH10_05":
            if bool(battle_objective_flags.get("karon_bell_line_broken", false)):
                return &"bell_line_relief"
    return &""

func _pick_enemy_action(enemy: UnitActor) -> Dictionary:
    var custom_boss_action: Dictionary = _pick_custom_boss_action(enemy)
    if not custom_boss_action.is_empty():
        return custom_boss_action

    if enemy.unit_data != null and enemy.unit_data.is_boss and enemy.unit_data.boss_pattern == &"roderic_ch01_05":
        var boss_action: Dictionary = _pick_roderic_action(enemy)
        if not boss_action.is_empty():
            return boss_action

    # Eroder-type enemies apply 망각 instead of attacking when valid target is in range
    # and the target has not yet reached max stack.
    if enemy.unit_data != null and enemy.unit_data.applies_oblivion and status_service != null:
        var oblivion_target: UnitActor = _find_oblivion_target(enemy)
        if oblivion_target != null:
            return {"type": "apply_oblivion", "target": oblivion_target}

    return ai_service.pick_action(
        enemy,
        ally_units,
        path_service,
        range_service,
        _get_dynamic_blocked_cells(enemy),
        _build_enemy_ai_runtime_context(enemy)
    )

func _build_enemy_ai_runtime_context(enemy: UnitActor) -> Dictionary:
    if enemy == null or not is_instance_valid(enemy):
        return {}
    var runtime_context := {
        "last_seen_cells": _last_visible_ally_cells_by_unit_id.duplicate(true)
    }
    var objective_cell: Variant = _get_enemy_objective_cell(enemy)
    if typeof(objective_cell) == TYPE_VECTOR2I:
        runtime_context["objective_cell"] = objective_cell
    return runtime_context

func _get_enemy_objective_cell(enemy: UnitActor) -> Variant:
    if enemy == null or not is_instance_valid(enemy) or stage_data == null:
        return null
    var win_condition: String = String(stage_data.win_condition)
    if win_condition != "resolve_all_interactions" and win_condition != "resolve_all_interactions_and_defeat_all_enemies":
        return null
    var best_cell: Vector2i = Vector2i.ZERO
    var best_distance: int = 2147483647
    var found := false
    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor) or object_actor.is_resolved:
            continue
        var distance: int = _distance_between_cells(enemy.grid_position, object_actor.grid_position)
        if not found or distance < best_distance:
            found = true
            best_distance = distance
            best_cell = object_actor.grid_position
    return best_cell if found else null

func _pick_custom_boss_action(enemy: UnitActor) -> Dictionary:
    if enemy == null or not is_instance_valid(enemy) or enemy.unit_data == null:
        return {}

    match enemy.unit_data.boss_pattern:
        &"hardren_banner_ch02_05":
            return _ai_action_hardren_banner(enemy)
        &"resin_shrine_ch03_05":
            return _ai_action_resin_shrine(enemy)
        &"ash_escape_ch05_05":
            return _ai_action_ash_escape(enemy)
        &"valgar_ch06_05", &"valgar_ch06_01":
            return _ai_action_valgar(enemy)
        &"basil_ch04_05":
            return _ai_action_basil(enemy)
        &"saria_ch07_05", &"saria_ch07_01":
            return _ai_action_saria(enemy)
        &"lete_ch08_05":
            return _ai_action_lete(enemy)
        &"karl_ch09a_05":
            return _ai_action_karl(enemy)
        &"melkion_ch09b_05":
            return _ai_action_melkion(enemy)
        &"karon_ch10_04", &"karon_ch05_01":
            return _ai_action_karon_early(enemy)
        &"karon_final_ch10_05":
            return _ai_action_karon(enemy)
        _:
            return {}

func _ai_action_valgar(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var fortify_ready: bool = _get_enemy_skill_cooldown(enemy, &"valgar_fortify") <= 0
    if fortify_ready and phase == &"fortification":
        return {"type": "valgar_fortify"}
    var shield_break_ready: bool = _get_enemy_skill_cooldown(enemy, &"shield_break") <= 0
    if shield_break_ready and (phase == &"wall_breaker" or phase == &"final_stand" or round_index % 2 == 0):
        var shield_break: SkillData = enemy.unit_data.get_skill_by_id(&"shield_break")
        var break_action: Dictionary = _build_skill_attack_action(enemy, shield_break, ally_units, "shield_break")
        if not break_action.is_empty():
            return break_action
    return {}

func _ai_action_hardren_banner(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var trap_ready: bool = _get_enemy_skill_cooldown(enemy, &"hardren_trap_salvo") <= 0
    var trap_count: int = int(battle_runtime_counters.get("ch02_trap_salvo_count", 0))
    if trap_ready and ((phase == &"trap_pressure" and trap_count < 2) or (phase == &"collapse_order" and trap_count < 3)):
        return {"type": "hardren_trap_salvo"}
    var shield_break: SkillData = enemy.unit_data.get_skill_by_id(&"shield_break")
    return _build_skill_attack_action(enemy, shield_break, ally_units, "shield_break")

func _ai_action_resin_shrine(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var ignition_ready: bool = _get_enemy_skill_cooldown(enemy, &"resin_ignition") <= 0
    var shrine_intact: bool = bool(battle_objective_flags.get("no_structures_destroyed", false))
    if ignition_ready and (phase == &"wildfire_echo" or (phase == &"shrine_burn" and shrine_intact)):
        return {"type": "resin_ignition"}
    var banner_betrayal: SkillData = enemy.unit_data.get_skill_by_id(&"banner_betrayal")
    var betray_action: Dictionary = _build_skill_attack_action(enemy, banner_betrayal, ally_units, "banner_betrayal")
    if not betray_action.is_empty():
        return betray_action
    var trap_lure: SkillData = enemy.unit_data.get_skill_by_id(&"trap_lure")
    return _build_skill_attack_action(enemy, trap_lure, ally_units, "trap_lure")

func _ai_action_ash_escape(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var collapse_ready: bool = _get_enemy_skill_cooldown(enemy, &"archive_collapse") <= 0
    var ledger_count: int = int(battle_runtime_counters.get("ch05_ledger_collapse_count", 0))
    if collapse_ready and ((phase == &"stack_collapse" and ledger_count < 2) or (phase == &"record_burn" and ledger_count < 3)):
        return {"type": "archive_collapse"}
    var seal_script: SkillData = enemy.unit_data.get_skill_by_id(&"seal_script")
    if phase == &"ash_screen":
        var seal_action: Dictionary = _build_skill_attack_action(enemy, seal_script, ally_units, "seal_script")
        if not seal_action.is_empty():
            return seal_action
    var memory_burn: SkillData = enemy.unit_data.get_skill_by_id(&"memory_burn")
    var burn_action: Dictionary = _build_skill_attack_action(enemy, memory_burn, ally_units, "memory_burn")
    if not burn_action.is_empty():
        return burn_action
    return _build_skill_attack_action(enemy, seal_script, ally_units, "seal_script")

func _ai_action_basil(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var purge_ready: bool = _get_enemy_skill_cooldown(enemy, &"basil_purge") <= 0
    var banner_ready: bool = _get_enemy_skill_cooldown(enemy, &"banner_betrayal") <= 0
    if stage_data != null and stage_data.stage_id == &"HUNT_BASIL" and bool(battle_objective_flags.get("hunt_basil_flood_rise_survived", false)):
        return {"type": "hunt_basil_backwash_surge"}
    if stage_data != null and stage_data.stage_id == &"HUNT_BASIL" and bool(battle_objective_flags.get("hunt_basil_flood_rise_survived", false)) and banner_ready:
        var hunt_banner: SkillData = enemy.unit_data.get_skill_by_id(&"banner_betrayal")
        var hunt_banner_action: Dictionary = _build_skill_attack_action(enemy, hunt_banner, ally_units, "banner_betrayal")
        if not hunt_banner_action.is_empty():
            return hunt_banner_action
    if stage_data != null and stage_data.stage_id == &"HUNT_BASIL" and purge_ready and (phase == &"flood_rise" or phase == &"altar_exposed" or phase == &"purge_judgment"):
        var hunt_basil_purge: SkillData = enemy.unit_data.get_skill_by_id(&"basil_purge")
        if hunt_basil_purge != null:
            return {"type": "basil_altar_purge", "skill": hunt_basil_purge}
    if purge_ready and (phase == &"altar_exposed" or phase == &"purge_judgment"):
        var basil_purge: SkillData = enemy.unit_data.get_skill_by_id(&"basil_purge")
        if basil_purge != null:
            return {"type": "basil_altar_purge", "skill": basil_purge}

    if banner_ready and round_index % 2 == 1:
        var banner_betrayal: SkillData = enemy.unit_data.get_skill_by_id(&"banner_betrayal")
        var banner_action: Dictionary = _build_skill_attack_action(enemy, banner_betrayal, ally_units, "banner_betrayal")
        if not banner_action.is_empty():
            return banner_action

    return {}

func _ai_action_saria(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var zone_ready: bool = _get_enemy_skill_cooldown(enemy, &"saria_oblivion_zone") <= 0
    var memory_burn_ready: bool = _get_enemy_skill_cooldown(enemy, &"memory_burn") <= 0
    if stage_data != null and stage_data.stage_id == &"HUNT_SARIA":
        var queue_turns: int = int(battle_runtime_counters.get("hunt_saria_queue_turns", 0))
        if not bool(battle_objective_flags.get("hunt_saria_queue_preserved", false)):
            return {"type": "hunt_saria_choir_break"}
        if not bool(battle_objective_flags.get("hunt_saria_queue_preserved", false)) and memory_burn_ready:
            var hunt_burn: SkillData = enemy.unit_data.get_skill_by_id(&"memory_burn")
            var hunt_burn_action: Dictionary = _build_skill_attack_action(enemy, hunt_burn, ally_units, "memory_burn")
            if not hunt_burn_action.is_empty():
                return hunt_burn_action
        if zone_ready and queue_turns >= 2 and (phase == &"civilian_unrest" or phase == &"mind_control" or phase == &"final_purge"):
            return {"type": "saria_oblivion_field"}
    var charm_ready: bool = _get_enemy_skill_cooldown(enemy, &"charm_gaze") <= 0
    if stage_data != null and stage_data.stage_id == &"HUNT_SARIA" and charm_ready and (phase == &"civilian_unrest" or phase == &"mind_control"):
        var hunt_charm: SkillData = enemy.unit_data.get_skill_by_id(&"charm_gaze")
        var hunt_charm_action: Dictionary = _build_skill_attack_action(enemy, hunt_charm, ally_units, "charm_gaze")
        if not hunt_charm_action.is_empty():
            return hunt_charm_action
    if charm_ready and phase == &"mind_control":
        var charm_gaze: SkillData = enemy.unit_data.get_skill_by_id(&"charm_gaze")
        var charm_action: Dictionary = _build_skill_attack_action(enemy, charm_gaze, ally_units, "charm_gaze")
        if not charm_action.is_empty():
            return charm_action
    if zone_ready and (phase == &"civilian_unrest" or phase == &"final_purge"):
        return {"type": "saria_oblivion_field"}

    if memory_burn_ready and phase != &"":
        var memory_burn: SkillData = enemy.unit_data.get_skill_by_id(&"memory_burn")
        var burn_action: Dictionary = _build_skill_attack_action(enemy, memory_burn, ally_units, "memory_burn")
        if not burn_action.is_empty():
            return burn_action

    return {}

func _ai_action_lete(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var smoke_ready: bool = _get_enemy_skill_cooldown(enemy, &"smoke_bomb") <= 0
    var pin_ready: bool = _get_enemy_skill_cooldown(enemy, &"pin_shot") <= 0
    if stage_data != null and stage_data.stage_id == &"HUNT_LETE":
        var scatter_ready: bool = _get_enemy_skill_cooldown(enemy, &"scatter_cover") <= 0
        if scatter_ready and bool(battle_objective_flags.get("hunt_lete_black_hounds_preserved", false)):
            return {"type": "lete_scatter_cover"}
        if not bool(battle_objective_flags.get("hunt_lete_black_hounds_preserved", false)) and phase == &"berserk_rush":
            var marked_hunt_target: UnitActor = _get_marked_ally_target(enemy)
            if marked_hunt_target != null:
                return {"type": "lete_black_hound_execute", "target": marked_hunt_target}
        if not bool(battle_objective_flags.get("hunt_lete_black_hounds_preserved", false)) and pin_ready:
            return {"type": "lete_shadow_feint"}
    if smoke_ready and round_index >= 2 and player_skip_turns_by_unit.is_empty():
        return {"type": "smoke_bomb"}
    if pin_ready and phase == &"" and round_index % 2 == 1:
        return {"type": "lete_shadow_feint"}

    if phase == &"berserk_rush":
        if bool(battle_objective_flags.get("lete_escape_route_cut", false)) and pin_ready:
            return {"type": "lete_shadow_feint"}
        var marked_target: UnitActor = _get_marked_ally_target(enemy)
        if marked_target != null:
            return {"type": "lete_black_hound_execute", "target": marked_target}
        var reckless_charge: SkillData = enemy.unit_data.get_skill_by_id(&"comet_charge")
        return _build_skill_attack_action(enemy, reckless_charge, ally_units, "reckless_charge")

    var ranged_harass: SkillData = enemy.unit_data.get_skill_by_id(&"pin_shot")
    return _build_skill_attack_action(enemy, ranged_harass, ally_units, "ranged_harass")

func _get_marked_ally_target(enemy: UnitActor) -> UnitActor:
    var best_target: UnitActor = null
    var best_distance: int = 2147483647
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        if _get_unit_visual_status_turns(ally, &"mark") <= 0:
            continue
        var distance: int = _distance_between_cells(enemy.grid_position, ally.grid_position)
        if distance < best_distance:
            best_distance = distance
            best_target = ally
    return best_target

func _get_marked_ally_targets() -> Array[UnitActor]:
    var targets: Array[UnitActor] = []
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        if _get_unit_visual_status_turns(ally, &"mark") <= 0:
            continue
        targets.append(ally)
    return targets

func _ai_action_karl(enemy: UnitActor) -> Dictionary:
    var enemy_id: int = enemy.get_instance_id()
    if int(boss_untouched_player_turns.get(enemy_id, 0)) >= 2:
        return {"type": "formation_call"}

    var shield_wall_ready: bool = _get_enemy_skill_cooldown(enemy, &"shield_wall") <= 0
    var wall_active: bool = int(enemy_damage_reduction_turns_by_unit.get(enemy_id, 0)) > 0
    if shield_wall_ready and not wall_active and enemy.current_hp <= enemy.unit_data.max_hp - 2:
        return {"type": "shield_wall"}

    var shield_bash: SkillData = enemy.unit_data.get_skill_by_id(&"shield_bash")
    var bash_action: Dictionary = _build_skill_attack_action(enemy, shield_bash, ally_units, "shield_bash")
    if not bash_action.is_empty():
        return bash_action

    var formation_break: SkillData = enemy.unit_data.get_skill_by_id(&"formation_break")
    return _build_skill_attack_action(enemy, formation_break, ally_units, "formation_break")

func _ai_action_melkion(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var marked_targets: Array[UnitActor] = _get_marked_ally_targets()
    if phase == &"archive_mode" and bool(battle_objective_flags.get("melkion_archive_destabilized", false)):
        var erase_truth: SkillData = enemy.unit_data.get_skill_by_id(&"erase_truth")
        var destabilized_action: Dictionary = _build_skill_attack_action(enemy, erase_truth, ally_units, "erase_truth")
        if not destabilized_action.is_empty():
            return destabilized_action
    if phase == &"archive_mode" and not marked_targets.is_empty():
        return {"type": "melkion_revision_sentence"}
    var rewrite_ready: bool = _get_enemy_skill_cooldown(enemy, &"truth_rewrite") <= 0
    if rewrite_ready and last_player_skill_used != null:
        var rewrite_action: Dictionary = _build_skill_attack_action(enemy, last_player_skill_used, ally_units, "truth_rewrite", {"copied_skill_id": last_player_skill_used.skill_id})
        if not rewrite_action.is_empty():
            return rewrite_action

    var memory_wipe_ready: bool = _get_enemy_skill_cooldown(enemy, &"memory_wipe") <= 0
    if memory_wipe_ready and round_index >= 2:
        return {"type": "memory_wipe"}

    var erase_truth: SkillData = enemy.unit_data.get_skill_by_id(&"erase_truth")
    if not marked_targets.is_empty():
        var marked_erase_action: Dictionary = _build_skill_attack_action(enemy, erase_truth, marked_targets, "erase_truth")
        if not marked_erase_action.is_empty():
            return marked_erase_action
    var erase_action: Dictionary = _build_skill_attack_action(enemy, erase_truth, ally_units, "erase_truth")
    if not erase_action.is_empty():
        return erase_action

    var true_read: SkillData = enemy.unit_data.get_skill_by_id(&"true_read")
    var read_action: Dictionary = _build_skill_attack_action(enemy, true_read, ally_units, "truth_read")
    if not read_action.is_empty():
        return read_action

    if phase == &"archive_mode":
        var revision_ready: bool = _get_enemy_skill_cooldown(enemy, &"true_read") <= 0
        if revision_ready:
            return {"type": "melkion_revision_field"}
        return {"type": "wait"}

    return {}

func _ai_action_karon(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    var marked_targets: Array[UnitActor] = _get_marked_ally_targets()
    if phase == &"name_severance" and not marked_targets.is_empty() and not bool(battle_objective_flags.get("ch10_05_anchor_chain", false)):
        return {"type": "karon_bell_of_erasure"}
    if phase == &"final_toll" and bool(battle_objective_flags.get("karon_bell_line_broken", false)):
        var imperial_edict: SkillData = enemy.unit_data.get_skill_by_id(&"imperial_edict")
        var weakened_action: Dictionary = _build_skill_attack_action(enemy, imperial_edict, ally_units, "imperial_edict")
        if not weakened_action.is_empty():
            return weakened_action
    if phase == &"royal_edict" and _get_enemy_skill_cooldown(enemy, &"royal_edict") <= 0:
        return {"type": "karon_royal_edict"}
    if phase == &"name_severance" and _get_enemy_skill_cooldown(enemy, &"name_severance") <= 0:
        return {"type": "karon_name_severance"}
    if phase == &"final_toll" and _get_enemy_skill_cooldown(enemy, &"all_out_attack") <= 0:
        return {"type": "karon_final_toll"}

    var phase_targets: Array = ally_units
    if phase == &"name_severance" or phase == &"final_toll":
        if not marked_targets.is_empty():
            phase_targets = marked_targets

    var imperial_edict: SkillData = enemy.unit_data.get_skill_by_id(&"imperial_edict")
    var edict_action: Dictionary = _build_skill_attack_action(enemy, imperial_edict, phase_targets, "imperial_edict")
    if not edict_action.is_empty():
        return edict_action

    var last_bastion: SkillData = enemy.unit_data.get_skill_by_id(&"last_bastion")
    var bastion_action: Dictionary = _build_skill_attack_action(enemy, last_bastion, phase_targets, "last_bastion")
    if not bastion_action.is_empty():
        return bastion_action

    return {}

func _use_karon_bell_of_erasure(enemy: UnitActor) -> void:
    var pressured_count: int = 0
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.is_defeated():
            continue
        bond_suppression_turns_by_unit[ally.get_instance_id()] = maxi(int(bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)), 2)
        if _get_unit_visual_status_turns(ally, &"mark") > 0:
            _set_unit_visual_status(ally, &"mark", maxi(_get_unit_visual_status_turns(ally, &"mark"), 2))
            pressured_count += 1
    battle_objective_flags["karon_bell_of_erasure"] = true
    _record_boss_event("karon_bell_of_erasure")
    hud.set_transition_reason("karon_bell_of_erasure", {"unit": enemy.unit_data.unit_id, "targets": pressured_count})
    _play_battle_flash(Color(0.96, 0.78, 0.58, 0.22), 0.2)
    _play_world_fx("mark_ring.png", enemy.grid_position, Color(1.0, 0.88, 0.7, 0.96), 0.4, 1.18)

func _ai_action_karon_early(enemy: UnitActor) -> Dictionary:
    var phase: StringName = get_boss_phase_for_unit(enemy)
    if phase == &"royal_edict" and _get_enemy_skill_cooldown(enemy, &"royal_edict") <= 0:
        return {"type": "karon_royal_edict"}
    if phase == &"name_severance" and _get_enemy_skill_cooldown(enemy, &"name_severance") <= 0:
        return {"type": "karon_name_severance"}
    var imperial_edict: SkillData = enemy.unit_data.get_skill_by_id(&"imperial_edict")
    if phase == &"" or phase == &"royal_edict":
        var edict_action: Dictionary = _build_skill_attack_action(enemy, imperial_edict, ally_units, "imperial_edict")
        if not edict_action.is_empty():
            return edict_action

    var last_bastion: SkillData = enemy.unit_data.get_skill_by_id(&"last_bastion")
    var bastion_action: Dictionary = _build_skill_attack_action(enemy, last_bastion, ally_units, "last_bastion")
    if not bastion_action.is_empty():
        return bastion_action

    if imperial_edict != null:
        var fallback_edict_action: Dictionary = _build_skill_attack_action(enemy, imperial_edict, ally_units, "imperial_edict")
        if not fallback_edict_action.is_empty():
            return fallback_edict_action

    return {}

func _build_skill_attack_action(attacker: UnitActor, skill: SkillData, candidates: Array, action_type: String, extra_payload: Dictionary = {}) -> Dictionary:
    if attacker == null or not is_instance_valid(attacker) or skill == null:
        return {}

    var immediate_target: UnitActor = _find_skill_target_in_range(attacker, skill, candidates)
    if immediate_target != null:
        var action := {"type": action_type, "skill": skill, "target": immediate_target}
        for key in extra_payload.keys():
            action[key] = extra_payload[key]
        return action

    var best_plan: Dictionary = _find_best_attack_plan_for_skill(attacker, skill, candidates)
    if best_plan.is_empty():
        return {}

    var movement: int = _get_effective_movement(attacker)
    if int(best_plan.get("path_cost", 0)) <= movement:
        var action := {
            "type": action_type,
            "skill": skill,
            "move_to": best_plan.get("move_to", attacker.grid_position),
            "target": best_plan.get("target", null)
        }
        for key in extra_payload.keys():
            action[key] = extra_payload[key]
        return action

    return {
        "type": "move_wait",
        "move_to": ai_service._truncate_path_to_movement(best_plan.get("path", []), movement, path_service)
    }

func _find_skill_target_in_range(actor: UnitActor, skill: SkillData, candidates: Array) -> UnitActor:
    var attack_cells: Array = range_service.get_attack_cells(actor.grid_position, _get_effective_skill_range(actor, skill))
    var best_target: UnitActor = null
    var best_score: int = -2147483648
    var best_distance: int = 2147483647

    for unit in candidates:
        if not is_instance_valid(unit) or unit.is_defeated() or not (unit.grid_position in attack_cells):
            continue
        var score: int = ai_service._score_attack_target(actor, unit)
        var distance: int = _distance_between_cells(actor.grid_position, unit.grid_position)
        if score > best_score or (score == best_score and distance < best_distance):
            best_score = score
            best_distance = distance
            best_target = unit
    return best_target

func _find_best_attack_plan_for_skill(actor: UnitActor, skill: SkillData, candidates: Array) -> Dictionary:
    var best_plan: Dictionary = {}
    var best_score: int = -2147483648
    var best_cost: int = 2147483647
    var dynamic_blocked: Dictionary = _get_dynamic_blocked_cells(actor)

    for target in candidates:
        if not is_instance_valid(target) or target.is_defeated():
            continue
        var candidate_cells: Array = range_service.get_attack_cells(target.grid_position, _get_effective_skill_range(actor, skill))
        for cell in candidate_cells:
            if not path_service.is_walkable(cell, dynamic_blocked):
                continue
            var path: Array = path_service.find_path(actor.grid_position, cell, dynamic_blocked)
            if path.is_empty():
                continue
            var path_cost: int = path_service.get_path_cost(path)
            var score: int = ai_service._score_attack_target(actor, target)
            if score > best_score or (score == best_score and path_cost < best_cost):
                best_score = score
                best_cost = path_cost
                best_plan = {
                    "target": target,
                    "move_to": cell,
                    "path": path,
                    "path_cost": path_cost
                }
    return best_plan

func _find_oblivion_target(enemy: UnitActor) -> UnitActor:
    ## Returns the nearest ally in attack range whose 망각 stack is below max.
    var attack_cells: Array = range_service.get_attack_cells(enemy.grid_position, _get_effective_attack_range(enemy))
    var best: UnitActor = null
    var best_stack: int = StatusService.MAX_STACK  # Only pick targets below max

    for unit in ally_units:
        if not is_instance_valid(unit) or unit.is_defeated():
            continue
        if not (unit.grid_position in attack_cells):
            continue
        var stack: int = status_service.get_oblivion_stack(unit)
        if stack < best_stack:
            best_stack = stack
            best = unit

    return best

func _pick_roderic_action(enemy: UnitActor) -> Dictionary:
    var marked_target: UnitActor = _get_marked_target()
    var boss_movement: int = _get_effective_movement(enemy)
    if boss_charge_pending and marked_target != null and is_instance_valid(marked_target) and not marked_target.is_defeated():
        var dynamic_blocked: Dictionary = _get_dynamic_blocked_cells(enemy)
        var approach_plan: Dictionary = ai_service._find_best_approach_plan(enemy, marked_target, path_service, range_service, dynamic_blocked)
        if not approach_plan.is_empty():
            var move_to: Vector2i = ai_service._truncate_path_to_movement(approach_plan.get("path", []), boss_movement, path_service)
            return {
                "type": "boss_charge",
                "move_to": move_to,
                "target": marked_target
            }
        if _is_in_attack_range(enemy, marked_target):
            return {
                "type": "boss_charge",
                "target": marked_target
            }
        boss_charge_pending = false
        boss_marked_target_id = -1

    var target: UnitActor = ai_service._find_nearest_target(enemy, ally_units)
    if target == null:
        return {"type": "wait"}

    return {
        "type": "boss_mark",
        "target": target
    }

func _get_marked_target() -> UnitActor:
    if boss_marked_target_id == -1:
        return null

    for unit in ally_units:
        if is_instance_valid(unit) and unit.get_instance_id() == boss_marked_target_id:
            return unit
    return null

func _apply_boss_command_buff(boss_unit: UnitActor) -> void:
    _record_boss_event("boss_command_buff")
    for enemy in enemy_units:
        if not is_instance_valid(enemy) or enemy == boss_unit or enemy.is_defeated():
            continue
        var distance: int = abs(enemy.grid_position.x - boss_unit.grid_position.x) + abs(enemy.grid_position.y - boss_unit.grid_position.y)
        if distance <= 2:
            enemy_attack_bonus_by_unit[enemy.get_instance_id()] = 1

    hud.set_transition_reason("boss_command_buff", {
        "unit": boss_unit.unit_data.unit_id,
        "radius": 2,
        "bonus": "+1 ATK"
    })

func _record_boss_event(event_name: String) -> void:
    boss_event_history.append(event_name)

func _start_boss_lock(boss_unit: UnitActor, action_id: StringName, display_name: String, countdown: int, locks_required: Dictionary, failure_text: String = "", break_text: String = "") -> Dictionary:
    if boss_unit == null or not is_instance_valid(boss_unit):
        return {}
    var unit_instance_id: int = boss_unit.get_instance_id()
    var progress: Dictionary = {}
    for lock_type in locks_required.keys():
        progress[String(lock_type)] = 0
    var state: Dictionary = {
        "unit_instance_id": unit_instance_id,
        "unit_id": boss_unit.unit_data.unit_id if boss_unit.unit_data != null else &"",
        "action_id": action_id,
        "display_name": display_name,
        "countdown": max(0, countdown),
        "locks_required": locks_required.duplicate(true),
        "locks_progress": progress,
        "failure_text": failure_text,
        "break_text": break_text,
        "broken": false
    }
    boss_lock_state_by_unit[unit_instance_id] = state
    _record_boss_event("boss_lock_started_%s" % String(action_id))
    return state.duplicate(true)

func _clear_boss_lock(boss_unit: UnitActor) -> void:
    if boss_unit == null or not is_instance_valid(boss_unit):
        return
    boss_lock_state_by_unit.erase(boss_unit.get_instance_id())

func _clear_all_boss_locks() -> void:
    boss_lock_state_by_unit.clear()

func get_boss_lock_state_snapshot() -> Dictionary:
    var snapshot: Dictionary = {}
    for unit_instance_id in boss_lock_state_by_unit.keys():
        var state: Dictionary = boss_lock_state_by_unit.get(unit_instance_id, {})
        snapshot[unit_instance_id] = state.duplicate(true)
    return snapshot

func _get_boss_lock_state(boss_unit: UnitActor) -> Dictionary:
    if boss_unit == null or not is_instance_valid(boss_unit):
        return {}
    return boss_lock_state_by_unit.get(boss_unit.get_instance_id(), {}).duplicate(true)

func _is_boss_lock_broken(boss_unit: UnitActor) -> bool:
    var state: Dictionary = _get_boss_lock_state(boss_unit)
    return bool(state.get("broken", false))

func _progress_boss_lock(boss_unit: UnitActor, lock_type: StringName, amount: int = 1) -> Dictionary:
    if boss_unit == null or not is_instance_valid(boss_unit):
        return {}
    var unit_instance_id: int = boss_unit.get_instance_id()
    if not boss_lock_state_by_unit.has(unit_instance_id):
        return {}
    var state: Dictionary = boss_lock_state_by_unit.get(unit_instance_id, {})
    var type_key: String = String(lock_type)
    var locks_required: Dictionary = state.get("locks_required", {})
    if not locks_required.has(type_key):
        return state.duplicate(true)
    var locks_progress: Dictionary = state.get("locks_progress", {})
    var required_amount: int = max(0, int(locks_required.get(type_key, 0)))
    var current_amount: int = max(0, int(locks_progress.get(type_key, 0)))
    var was_broken: bool = bool(state.get("broken", false))
    locks_progress[type_key] = min(required_amount, current_amount + max(0, amount))
    state["locks_progress"] = locks_progress
    state["broken"] = _is_boss_lock_complete(state)
    boss_lock_state_by_unit[unit_instance_id] = state
    if bool(state.get("broken", false)) and not was_broken:
        _record_boss_event("boss_lock_broken_%s" % String(state.get("action_id", &"")))
    return state.duplicate(true)

func _progress_boss_lock_for_event(lock_type: StringName, boss_unit: UnitActor = null, amount: int = 1) -> Dictionary:
    if boss_unit != null and is_instance_valid(boss_unit):
        return _progress_boss_lock(boss_unit, lock_type, amount)
    for unit_instance_id in boss_lock_state_by_unit.keys():
        var candidate: UnitActor = instance_from_id(int(unit_instance_id)) as UnitActor
        if candidate == null or not is_instance_valid(candidate) or candidate.is_defeated():
            continue
        var progressed: Dictionary = _progress_boss_lock(candidate, lock_type, amount)
        if not progressed.is_empty():
            return progressed
    return {}

func _progress_boss_lock_from_player_attack(attacker: UnitActor, defender: UnitActor, resolved_skill: SkillData, result: Dictionary, skill_override: SkillData = null) -> void:
    if attacker == null or defender == null or not is_instance_valid(attacker) or not is_instance_valid(defender):
        return
    if attacker.faction != "ally" or defender.faction != "enemy" or defender.unit_data == null or not defender.unit_data.is_boss:
        return
    if String(result.get("transition_reason", "")) == "attack_missed":
        return
    var is_skill_use: bool = skill_override != null or (resolved_skill != null and resolved_skill.has_resource_cost())
    _progress_boss_lock(defender, &"skill" if is_skill_use else &"strike")

func _is_boss_lock_complete(state: Dictionary) -> bool:
    var locks_required: Dictionary = state.get("locks_required", {})
    var locks_progress: Dictionary = state.get("locks_progress", {})
    if locks_required.is_empty():
        return false
    for lock_type in locks_required.keys():
        var type_key: String = String(lock_type)
        if int(locks_progress.get(type_key, 0)) < int(locks_required.get(type_key, 0)):
            return false
    return true

func _check_boss_phase_transitions() -> void:
    ## Check all boss units for HP-threshold phase transitions.
    ## Applies phase bonuses for the current phase (re-applied each enemy phase start).
    for enemy in enemy_units:
        if not is_instance_valid(enemy) or enemy.is_defeated() or enemy.unit_data == null:
            continue
        if not enemy.unit_data.is_boss:
            continue

        var hp_percent: float = (float(enemy.current_hp) / float(enemy.unit_data.max_hp)) * 100.0
        _check_boss_special_events(enemy, hp_percent)
        if enemy.unit_data.boss_phase_thresholds.is_empty():
            _refresh_unit_visual_state()
            continue
        var new_phase: StringName = enemy.unit_data.get_boss_phase_for_hp(hp_percent)
        var unit_id: int = enemy.get_instance_id()
        var old_phase: StringName = boss_phase_by_unit.get(unit_id, &"")

        # Detect phase transition (change or first entry into a phase)
        if new_phase != old_phase:
            if new_phase != &"":
                boss_phase_by_unit[unit_id] = new_phase
                _record_boss_event("boss_phase_%s" % String(new_phase))
                if telemetry_service != null:
                    telemetry_service.record_boss_phase(new_phase, round_index)
                hud.set_transition_reason("boss_phase_transition", {
                    "unit": enemy.unit_data.unit_id,
                    "phase": String(new_phase),
                    "hp_percent": hp_percent,
                    "round": round_index
                })
                # Phase transition visual feedback
                _apply_boss_phase_effects(enemy, new_phase, old_phase)
            elif old_phase != &"":
                # HP recovered above all thresholds — reset to normal
                boss_phase_by_unit.erase(unit_id)
                hud.set_transition_reason("boss_phase_ended", {
                    "unit": enemy.unit_data.unit_id,
                    "previous_phase": String(old_phase),
                    "round": round_index
                })
        elif new_phase != &"":
            # Same phase as before — re-apply bonuses for this phase
            _apply_boss_phase_bonuses(enemy, new_phase)

        _refresh_unit_visual_state()

func _check_boss_special_events(enemy: UnitActor, hp_percent: float) -> void:
    if enemy.unit_data == null:
        return

    if enemy.unit_data.boss_pattern == &"karon_final_ch10_05" and hp_percent <= 75.0:
        var flag_key := "karon_anchor_%d" % enemy.get_instance_id()
        if not bool(spawned_once_flags_by_unit.get(flag_key, false)):
            var anchor: UnitActor = _spawn_runtime_enemy(
                _create_name_call_anchor_data(),
                enemy.grid_position,
                [
                    enemy.grid_position + Vector2i(-1, 1),
                    enemy.grid_position + Vector2i(1, 1),
                    enemy.grid_position + Vector2i(0, 1),
                    enemy.grid_position + Vector2i(-1, 0),
                    enemy.grid_position + Vector2i(1, 0)
                ]
            )
            if anchor != null:
                spawned_once_flags_by_unit[flag_key] = true
                _record_boss_event("karon_name_call_anchor")
                if not ally_units.is_empty():
                    var all_present: bool = true
                    for ally in ally_units:
                        if not is_instance_valid(ally) or ally.is_defeated():
                            all_present = false
                            break
                    if all_present:
                        battle_objective_flags["all_allies_name_called"] = true
                var name_call_payload: Dictionary = _build_name_call_payload()
                last_name_call_line = String(name_call_payload.get("line", "")).strip_edges()
                last_name_call_speaker_id = StringName(name_call_payload.get("speaker_id", &""))
                var hud_payload := {"unit": enemy.unit_data.unit_id, "anchor": anchor.unit_data.unit_id}
                if not last_name_call_line.is_empty():
                    hud_payload["speaker"] = last_name_call_speaker_id
                    hud_payload["line"] = last_name_call_line
                    hud_payload["support_rank"] = int(name_call_payload.get("support_rank", 0))
                hud.set_transition_reason("karon_name_call_anchor", hud_payload)
                _play_battle_flash(Color(0.93, 0.79, 0.56, 0.18), 0.2)
                _play_world_fx("mark_ring.png", anchor.grid_position, Color(1.0, 0.866667, 0.635294, 0.92), 0.32, 1.0)

func _build_name_call_payload() -> Dictionary:
    if stage_data == null or stage_data.stage_id != &"CH10_05":
        return {}
    var generic_payload: Dictionary = {}
    for ally in ally_units:
        if not is_instance_valid(ally) or ally.unit_data == null or ally.is_defeated():
            continue
        if ally.unit_data.unit_id == &"ally_rian":
            continue
        var support_rank: int = bond_service.get_support_rank(&"ally_rian", ally.unit_data.unit_id) if bond_service != null else 0
        var pair_id := SupportConversations.get_pair_id(String(&"ally_rian"), String(ally.unit_data.unit_id))
        if support_rank == 4:
            var support_line := SupportConversations.get_conversation(pair_id, 4)
            if not support_line.is_empty():
                return {
                    "speaker_id": ally.unit_data.unit_id,
                    "support_rank": 4,
                    "line": support_line
                }
        if generic_payload.is_empty():
            generic_payload = {
                "speaker_id": ally.unit_data.unit_id,
                "support_rank": support_rank,
                "line": "%s: Rian!" % ally.unit_data.display_name
            }
    return generic_payload

func _apply_boss_phase_effects(boss: UnitActor, new_phase: StringName, old_phase: StringName) -> void:
    ## Visual and game-feel feedback for a boss phase transition.
    var phase_name: String = String(new_phase)
    if phase_name == "berserk_rush":
        battle_objective_flags["lete_defects_alive"] = true
        _apply_lete_berserk_battlefield_rewrite()
        _play_battle_flash(Color(0.95, 0.29, 0.25, 0.24), 0.24)
        _play_world_fx("hit_spark.png", boss.grid_position, Color(1.0, 0.45, 0.32, 0.96), 0.42, 1.26)
        hud.set_transition_reason("lete_phase_two", {"unit": boss.unit_data.unit_id, "line": "No more shadows. Run them down."})
    elif phase_name == "archive_mode":
        battle_objective_flags["melkion_truth_revealed"] = true
        _apply_melkion_archive_battlefield_rewrite()
        _play_battle_flash(Color(0.58, 0.35, 0.74, 0.22), 0.26)
        _play_world_fx("mark_ring.png", boss.grid_position, Color(0.78, 0.68, 1.0, 0.94), 0.38, 1.18)
        hud.set_transition_reason("melkion_archive_mode", {"unit": boss.unit_data.unit_id, "line": "The archive closes. Only the rewritten survives."})
    elif phase_name == "royal_edict":
        _play_battle_flash(Color(0.9, 0.74, 0.52, 0.2), 0.24)
        _play_world_fx("mark_ring.png", boss.grid_position, Color(0.96, 0.84, 0.62, 0.92), 0.32, 1.04)
        hud.set_transition_reason("karon_royal_edict", {"unit": boss.unit_data.unit_id, "line": "Kneel. The bell will decide what remains."})
    elif phase_name == "name_severance":
        _apply_karon_name_severance_battlefield_rewrite()
        _play_battle_flash(Color(0.98, 0.8, 0.62, 0.22), 0.26)
        _play_world_fx("hit_spark.png", boss.grid_position, Color(1.0, 0.9, 0.7, 0.94), 0.36, 1.08)
        hud.set_transition_reason("karon_name_severance", {"unit": boss.unit_data.unit_id, "line": "Then lose the name before you lose the body."})
    elif phase_name == "final_toll":
        battle_objective_flags["karon_final_toll"] = true
        _refresh_objective_surfaces()
        _play_battle_flash(Color(1.0, 0.82, 0.66, 0.26), 0.3)
        _play_world_fx("mark_ring.png", boss.grid_position, Color(1.0, 0.88, 0.72, 0.98), 0.44, 1.22)
        hud.set_transition_reason("karon_phase_two", _build_karon_phase_three_payload(boss, "The bell tolls once more. Every name answers now."))
    elif phase_name == "oblivion_resonance":
        _play_battle_flash(Color(0.92, 0.72, 0.54, 0.24), 0.28)
        _play_world_fx("hit_spark.png", boss.grid_position, Color(1.0, 0.84, 0.62, 0.98), 0.46, 1.3)
        hud.set_transition_reason("karon_phase_two", {"unit": boss.unit_data.unit_id, "line": "Say the name, or be folded into the bell."})
    elif phase_name == "enrage":
        _play_battle_flash(Color(1.0, 0.4, 0.2, 0.22), 0.24)
        _play_world_fx("hit_spark.png", boss.grid_position, Color(1.0, 0.55, 0.3, 0.96), 0.38, 1.2)
    elif phase_name == "despair":
        _play_battle_flash(Color(0.8, 0.1, 0.2, 0.28), 0.30)
        _play_world_fx("hit_spark.png", boss.grid_position, Color(1.0, 0.2, 0.15, 0.98), 0.45, 1.5)
    # Apply stat bonuses for this phase
    _apply_boss_phase_bonuses(boss, new_phase)

func _build_karon_phase_three_payload(boss: UnitActor, line: String) -> Dictionary:
    return {
        "unit": boss.unit_data.unit_id if boss != null and boss.unit_data != null else &"enemy_karuon",
        "phase_callout": "Phase 3",
        "subtitle": "Final Toll",
        "line": line,
        "stakes": "All allies are inside the bell pressure. Bond bonuses are suppressed while the toll holds.",
        "telegraph_title": "Phase 3 / Final Toll",
        "telegraph_detail": "Karuon drags all allies into the bell line, keeps them marked, and suppresses bond responses until the formation survives the toll."
    }

func _apply_boss_phase_bonuses(boss: UnitActor, phase: StringName) -> void:
    ## Re-apply stat bonuses for the current boss phase (called each enemy phase start).
    var phase_name: String = String(phase)
    if phase_name == "berserk_rush":
        enemy_attack_bonus_by_unit[boss.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(boss.get_instance_id(), 0)) + 1
        enemy_movement_bonus_by_unit[boss.get_instance_id()] = int(enemy_movement_bonus_by_unit.get(boss.get_instance_id(), 0)) + 1
    elif phase_name == "final_toll":
        enemy_attack_bonus_by_unit[boss.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(boss.get_instance_id(), 0)) + 2
        enemy_movement_bonus_by_unit[boss.get_instance_id()] = int(enemy_movement_bonus_by_unit.get(boss.get_instance_id(), 0)) + 1
    elif phase_name == "oblivion_resonance":
        enemy_attack_bonus_by_unit[boss.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(boss.get_instance_id(), 0)) + 2
        enemy_movement_bonus_by_unit[boss.get_instance_id()] = int(enemy_movement_bonus_by_unit.get(boss.get_instance_id(), 0)) + 1
    elif phase_name == "enrage":
        # Enrage: boss +1 ATK, nearby enemies +1 ATK
        enemy_attack_bonus_by_unit[boss.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(boss.get_instance_id(), 0)) + 1
        for enemy in enemy_units:
            if not is_instance_valid(enemy) or enemy.is_defeated() or enemy == boss:
                continue
            var dist: int = abs(enemy.grid_position.x - boss.grid_position.x) + abs(enemy.grid_position.y - boss.grid_position.y)
            if dist <= 2:
                enemy_attack_bonus_by_unit[enemy.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(enemy.get_instance_id(), 0)) + 1
    elif phase_name == "despair":
        # Despair: boss +2 ATK +1 MOV, nearby enemies +2 ATK (within 3 tiles)
        enemy_attack_bonus_by_unit[boss.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(boss.get_instance_id(), 0)) + 2
        enemy_movement_bonus_by_unit[boss.get_instance_id()] = int(enemy_movement_bonus_by_unit.get(boss.get_instance_id(), 0)) + 1
        for enemy in enemy_units:
            if not is_instance_valid(enemy) or enemy.is_defeated() or enemy == boss:
                continue
            var dist: int = abs(enemy.grid_position.x - boss.grid_position.x) + abs(enemy.grid_position.y - boss.grid_position.y)
            if dist <= 3:
                enemy_attack_bonus_by_unit[enemy.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(enemy.get_instance_id(), 0)) + 2

func get_boss_phase_for_unit(unit: UnitActor) -> StringName:
    ## Public accessor for runner tests — returns the current boss phase for a unit.
    if unit == null or not is_instance_valid(unit):
        return &""
    return boss_phase_by_unit.get(unit.get_instance_id(), &"")

func _get_effective_movement(unit: UnitActor) -> int:
    ## Returns movement stat plus any boss phase movement bonus.
    if unit == null:
        return 1
    var base_movement: int = unit.get_movement()
    if unit.unit_data != null and unit.unit_data.is_boss:
        base_movement += int(enemy_movement_bonus_by_unit.get(unit.get_instance_id(), 0))
    base_movement -= int(_get_feature_effects_for_unit(unit).get("speed_penalty", 0))
    return max(1, base_movement)
