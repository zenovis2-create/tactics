class_name BattleController
extends Node2D

signal battle_finished(result: StringName, stage_id: StringName)
signal battle_defeat(stage_id: StringName, payload: Dictionary)
signal battle_turn_ended(turn_owner: String, turn_actions: Array)
signal bond_death_triggered(pair_id: String, ending_id: String)

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const SpotlightManager = preload("res://scripts/battle/spotlight_manager.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const InteractiveObjectActor = preload("res://scripts/battle/interactive_object_actor.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const TurnManager = preload("res://scripts/battle/turn_manager.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const CombatService = preload("res://scripts/battle/combat_service.gd")
const AIService = preload("res://scripts/battle/ai_service.gd")
const EnemyCommander = preload("res://scripts/battle/enemy_commander.gd")
const InputController = preload("res://scripts/battle/input_controller.gd")
const GridCursor = preload("res://scripts/battle/grid_cursor.gd")
const BattleHUD = preload("res://scripts/battle/battle_hud.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const AccessoryData = preload("res://scripts/data/accessory_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const ArmorData = preload("res://scripts/data/armor_data.gd")
const BattleBoard = preload("res://scripts/battle/battle_board.gd")
const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const STATUS_SERVICE_PATH := "res://scripts/battle/status_service.gd"
const TelemetryService = preload("res://scripts/battle/telemetry_service.gd")
const RewardService = preload("res://scripts/battle/reward_service.gd")
const CutscenePlayer = preload("res://scripts/cutscene/cutscene_player.gd")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const BOND_SERVICE_PATH := "res://scripts/battle/bond_service.gd"
const BattleControllerBondDeath = preload("res://scripts/battle/battle_controller_bond_death.gd")
const BattleResultScreenScript = preload("res://scripts/battle/battle_result_screen.gd")
const ChronicleGenerator = preload("res://scripts/battle/chronicle_generator.gd")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")
const DOWNPOUR_WEATHER_IDS := {
    &"downpour": true,
    &"storm": true,
    &"heavy_rain": true,
    &"暴雨": true
}
const WET_TERRAIN_TYPES := {
    &"water": true,
    &"flooded": true,
    &"flood": true
}
const FLOOD_IMPASSABLE_TERRAIN_TYPES := {
    &"mountain": true,
    &"cave": true
}
const FIRE_TERRAIN_TYPES := {
    &"fire": true,
    &"burning": true,
    &"flame": true,
    &"ember": true,
    &"wildfire": true
}
const FIRE_SKILL_IDS := {
    &"memory_burn": true
}
const FLOOD_TERRAIN_TYPE: StringName = &"flood"
const FLOOD_MOVE_COST: int = 2
const FLOOD_DEFENSE_BONUS: int = 1
const FLOOD_EXPANSION_LIMIT: int = 3
const DROWNING_DAMAGE: int = 5
const SUPPORT_BOND_RANK_B: int = 4
const MAX_BOND_LEVEL: int = 5
const MAX_OBLIVION_STACK: int = 3
const CARDINAL_DIRECTIONS := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
const MIRROR_LEONIKA_UNIT_ID: StringName = &"enemy_saria"
const MIRROR_LEONIKA_DIALOGUE := "당신이 나였다면 어떻게 했을까?"

const CH01_STAGE_MEMORY_LOG: Dictionary = {
    &"CH01_05": [
        "mem_frag_ch01_first_order — First Order: a cut command echoes over the burning field, but the speaker and intent stay unclear."
    ]
}

const CH07_05_STAGE_ID: StringName = &"CH07_05"
const CH08_05_STAGE_ID: StringName = &"CH08_05"
const CH09B_05_STAGE_ID: StringName = &"CH09B_05"
const LETE_CH08_05_BOSS_PATTERN: StringName = &"lete_ch08_05"
const MELKION_FLIP_PHASE: StringName = &"enrage"
const CH10_FINALE_NAME_CALL_IDS: Array[StringName] = [
    &"ally_serin",
    &"ally_bran",
    &"ally_tia",
    &"ally_enoch",
    &"ally_karl",
    &"ally_noah"
]
const CH01_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH01_05": [
        "flag_evidence_hardren_seal_obtained — Hardren seal recovered; the ash-field command chain can be traced north toward the border evidence trail."
    ]
}

const CH01_STAGE_LETTER_LOG: Dictionary = {
    &"CH01_05": [
        "Letter from Serin — \"The name on your scabbard is enough for now. We move north together and keep the survivors behind us safe.\""
    ]
}

const STATUS_FEAR: StringName = &"fear"
const STATUS_CONFUSION: StringName = &"混乱"
const STATUS_NIGHT_SMOKE: StringName = &"눈不适应"
const STATUS_RAIN_COMFORT: StringName = &"비옷의慰め"

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
@onready var flood_effect_root: Node2D = $Effects/FloodCombinedFX
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
var last_result: String = ""
var equipped_accessory_by_unit_id: Dictionary = {}
var equipped_weapon_by_unit_id: Dictionary = {}
var equipped_armor_by_unit_id: Dictionary = {}
var boss_marked_target_id: int = -1
var boss_charge_pending: bool = false
var enemy_attack_bonus_by_unit: Dictionary = {}
var enemy_movement_bonus_by_unit: Dictionary = {}  ## boss phase movement bonuses
var boss_event_history: Array[String] = []
var boss_phase_by_unit: Dictionary = {}  ## unit instance_id → current phase StringName
var last_support_attack_details: Dictionary = {}
var hidden_recruit_state: Dictionary = {}
var hold_objective_armed: bool = false
var hold_objective_completed: bool = false
var hold_objective_round_started: int = -1
var finale_name_anchor_state: Dictionary = {}
var finale_name_call_state: Dictionary = {}
var finale_name_call_lines: Dictionary = {}
var namecall_pending: bool = false
var _pending_namecall_companion_id: StringName = &""
var _pending_namecall_unit: UnitActor
var _pending_namecall_reason: String = ""
var desperate_wave_context: Dictionary = {}
var _last_defeated_ally_id: StringName = &""
var falling_units_this_turn: Array[StringName] = []

var current_phase: int = BattlePhase.BATTLE_INIT
var round_index: int = 1
var phase_transition_history: Array = []
var board_origin: Vector2 = Vector2.ZERO
var board_scale: float = 1.0
var _battle_flash_tween: Tween
var _fx_cache: Dictionary = {}
var _current_turn_actions: Array[Dictionary] = []
var _spotlight_slow_mo_token: int = 0
var flood_zone_positions: Array[Vector2i] = []
var flood_margin_positions: Array[Vector2i] = []
var _flood_expansion_turns: int = 0
var last_spotlight_effect: Dictionary = {}
var _chronicle_enemy_opening_count: int = 0
var _chronicle_ally_opening_count: int = 0
var _chronicle_enemy_defeats: Array[String] = []
var _chronicle_allies_lost: Array[Dictionary] = []
var _chronicle_weather_events: Array[String] = []
var _chronicle_turn_history: Array[Dictionary] = []
var mirror_enemy_commander = EnemyCommander.new()

# M4/M5/M6 services — instantiated at runtime, not scene nodes.
var progression_service: ProgressionService
var status_service: Node
var telemetry_service: TelemetryService
var reward_service: RewardService
var cutscene_player: CutscenePlayer
var bond_service: Node
var bond_death_patch = BattleControllerBondDeath.new()

func _ready() -> void:
    _wire_signals()
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    if stage_data == null:
        stage_data = _clone_stage_data(DEFAULT_STAGE)
    else:
        stage_data = _clone_stage_data(stage_data)

    _init_meta_services()
    _sync_hud_phase("controller_ready", {"stage_loaded": stage_data != null})
    bootstrap_battle()

func _init_meta_services() -> void:
    progression_service = ProgressionService.new()
    add_child(progression_service)
    var ashes = get_node_or_null("/root/Ashes")
    if ashes != null and ashes.has_method("bind_progression"):
        ashes.bind_progression(progression_service.get_data())
    status_service = null
    telemetry_service = TelemetryService.new()
    add_child(telemetry_service)
    reward_service = RewardService.new()
    add_child(reward_service)
    cutscene_player = CutscenePlayer.new()
    add_child(cutscene_player)
    var bond_service_script = load(BOND_SERVICE_PATH)
    if bond_service_script is GDScript and bond_service_script.can_instantiate():
        bond_service = bond_service_script.new()
        add_child(bond_service)

func bootstrap_battle() -> void:
    round_index = 1
    current_phase = BattlePhase.BATTLE_INIT
    phase_transition_history.clear()
    battle_reward_log.clear()
    last_result_summary.clear()
    last_result = ""
    boss_marked_target_id = -1
    boss_charge_pending = false
    enemy_attack_bonus_by_unit.clear()
    enemy_movement_bonus_by_unit.clear()
    boss_event_history.clear()
    boss_phase_by_unit.clear()
    last_support_attack_details.clear()
    hidden_recruit_state.clear()
    hold_objective_armed = false
    hold_objective_completed = false
    hold_objective_round_started = -1
    namecall_pending = false
    _pending_namecall_companion_id = &""
    _pending_namecall_unit = null
    _pending_namecall_reason = ""
    _last_defeated_ally_id = &""
    _current_turn_actions.clear()
    last_spotlight_effect.clear()
    _chronicle_enemy_defeats.clear()
    _chronicle_allies_lost.clear()
    _chronicle_weather_events.clear()
    _chronicle_turn_history.clear()
    _chronicle_enemy_opening_count = 0
    _chronicle_ally_opening_count = 0
    _spotlight_slow_mo_token += 1
    Engine.time_scale = 1.0
    falling_units_this_turn.clear()
    if mirror_enemy_commander != null:
        mirror_enemy_commander.reset()
    _reset_flood_state()
    _reset_finale_contract_state()
    if bond_service != null and progression_service != null:
        bond_service.setup_progression(progression_service.get_data())

    _clear_battle_state()
    _apply_mirror_stage_configuration()
    _spawn_from_stage()
    _chronicle_ally_opening_count = ally_units.size()
    _chronicle_enemy_opening_count = enemy_units.size()
    path_service.configure_from_stage(stage_data)
    _layout_battlefield()
    _initialize_flood_zones()

    if telemetry_service != null:
        telemetry_service.record_battle_start(stage_data.stage_id if stage_data != null else &"unknown")
    if status_service != null:
        status_service.reset()
    if reward_service != null and stage_data != null:
        reward_service.record_stage_entry(stage_data.stage_id)
    var spotlight := _get_spotlight_manager()
    if spotlight != null:
        spotlight.begin_battle(_get_spotlight_battle_id())

    # 전투 시작 전 컷씬 재생 (있는 경우)
    if cutscene_player != null and stage_data != null and stage_data.start_cutscene_id != &"":
        var start_data = CutsceneCatalog.get_cutscene(stage_data.start_cutscene_id)
        if start_data != null:
            cutscene_player.play(start_data)

    _begin_player_phase("battle_initialized")
    _show_mirror_mode_intro()

func set_stage(new_stage_data: StageData) -> void:
    stage_data = _clone_stage_data(new_stage_data)
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
    hud.namecall_choice_selected.connect(_on_namecall_choice_selected)
    turn_manager.action_state_changed.connect(_on_action_state_changed)
    if not battle_turn_ended.is_connected(_on_battle_turn_ended):
        battle_turn_ended.connect(_on_battle_turn_ended)
    _wire_spotlight_signal()

func _clear_battle_state() -> void:
    _current_turn_actions.clear()
    last_spotlight_effect.clear()
    for child in units_root.get_children():
        child.queue_free()

    for child in objects_root.get_children():
        child.queue_free()

    for child in effects_root.get_children():
        if child == flood_effect_root:
            for flood_child in flood_effect_root.get_children():
                flood_child.queue_free()
            continue
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
    effects_root.position = Vector2.ZERO
    grid_cursor.position = Vector2.ZERO
    units_root.scale = Vector2.ONE
    objects_root.scale = Vector2.ONE
    effects_root.scale = Vector2.ONE
    grid_cursor.scale = Vector2.ONE
    if battle_board != null:
        battle_board.position = Vector2.ZERO
        battle_board.scale = Vector2.ONE
        battle_board.set_flood_state([], [])
    if hud != null and hud.is_inside_tree():
        hud.set_flood_margin_positions([])
        hud.set_stage_memorial({}, Vector2i(-1, -1))
        hud.close_inventory_panel()

func _spawn_from_stage() -> void:
    if stage_data == null:
        push_warning("BattleController has no StageData; stage spawn skipped.")
        return

    if battle_board != null:
        battle_board.set_stage(stage_data)
    _refresh_stage_memorial_visual()
    _spawn_group(stage_data.ally_units, stage_data.ally_spawns, "ally", ally_units)
    _spawn_group(stage_data.enemy_units, stage_data.enemy_spawns, "enemy", enemy_units)
    _spawn_interactive_objects(stage_data.interactive_objects)
    _apply_opening_boss_stealth_state()

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
    input_controller.board_origin = board_origin
    input_controller.cell_size = Vector2i(roundi(scaled_cell_size.x), roundi(scaled_cell_size.y))
    if hud != null:
        hud.set_battle_frame_metrics(board_origin, board_size, scaled_cell_size)
    _refresh_flood_visuals()

func _refresh_stage_memorial_visual() -> void:
    if hud == null:
        return
    if stage_data == null or progression_service == null:
        hud.set_stage_memorial({}, Vector2i(-1, -1))
        return
    var progression_data := progression_service.get_data()
    if progression_data == null or not stage_data.has_memorial_slot():
        hud.set_stage_memorial({}, Vector2i(-1, -1))
        return
    var memorial := progression_data.get_stage_memorial(String(stage_data.stage_id))
    hud.set_stage_memorial(memorial, stage_data.memorial_slot)

func _spawn_group(unit_defs: Array, spawn_cells: Array, faction: String, sink: Array) -> void:
    var count: int = min(unit_defs.size(), spawn_cells.size())
    for index in count:
        var unit: UnitActor = UNIT_SCENE.instantiate() as UnitActor
        if unit == null:
            continue

        var unit_data: UnitData = unit_defs[index]
        var spawn_cell: Vector2i = spawn_cells[index]

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

func _apply_opening_boss_stealth_state() -> void:
    if stage_data == null or stage_data.stage_id != CH08_05_STAGE_ID:
        return

    for enemy in enemy_units:
        if not is_instance_valid(enemy) or enemy.unit_data == null:
            continue
        if StringName(enemy.unit_data.boss_pattern) != LETE_CH08_05_BOSS_PATTERN:
            continue
        enemy.set_stealth_hidden(true)

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
        _resolve_attack(selected_unit, enemy_at_cell)
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
            selected_unit.get_movement(),
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

    _transition_to(BattlePhase.PLAYER_ACTION_COMMIT, "player_move_committed", {
        "unit": selected_unit.unit_data.unit_id,
        "to": destination
    })

    selected_unit.move_to_grid(destination, stage_data.cell_size, 0.2)
    turn_manager.mark_moved(selected_unit, "player_move_committed", {"to": destination})

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

    if is_instance_valid(acting_unit) and not acting_unit.is_defeated() and _begin_namecall_choice_if_needed(acting_unit, reason):
        return

    _finalize_selected_unit_action(acting_unit, reason)

func _finalize_selected_unit_action(acting_unit: UnitActor, reason: String, skip_namecall_record: bool = false) -> void:
    if is_instance_valid(acting_unit) and not acting_unit.is_defeated():
        if not skip_namecall_record:
            _try_record_live_finale_name_call(acting_unit)
        turn_manager.mark_acted(acting_unit, reason, {"round": round_index})

    _clear_selection()
    _refresh_unit_visual_state()

    _check_bond_death()

    if _check_battle_end():
        return

    if turn_manager.is_phase_complete("ally", ally_units):
        _end_player_phase("all_player_units_exhausted")
    else:
        _transition_to(BattlePhase.PLAYER_SELECT, "player_next_selection", {
            "ready_units": turn_manager.get_ready_unit_count("ally", ally_units)
        })
        _focus_first_ready_unit_if_any()

func _begin_namecall_choice_if_needed(acting_unit: UnitActor, reason: String) -> bool:
    var companion_id := _resolve_namecall_choice_companion_id(acting_unit)
    if companion_id == &"" or hud == null:
        return false
    _pending_namecall_unit = acting_unit
    _pending_namecall_reason = reason
    _show_namecall_choice(companion_id)
    return true

func _resolve_namecall_choice_companion_id(acting_unit: UnitActor) -> StringName:
    if not _is_ch10_finale_stage() or acting_unit == null or not is_instance_valid(acting_unit) or acting_unit.unit_data == null:
        return &""
    if namecall_pending and _pending_namecall_companion_id != &"":
        return _pending_namecall_companion_id
    var required_name_call_ids: Array[StringName] = _get_required_finale_name_call_ids()
    for companion_id: StringName in required_name_call_ids:
        if not bool(finale_name_call_state.get(companion_id, false)):
            return companion_id
    return &""

func _show_namecall_choice(_companion_id: StringName = &"") -> void:
    if hud == null:
        return
    hud.show_namecall_choice("그 이름... 불러도 될까요?", 3.0)

func _on_namecall_choice_selected(choice_id: String) -> void:
    var acting_unit: UnitActor = _pending_namecall_unit
    var pending_reason: String = _pending_namecall_reason
    var companion_id := _resolve_namecall_choice_companion_id(acting_unit)
    _pending_namecall_unit = null
    _pending_namecall_reason = ""
    if companion_id != &"":
        if choice_id == "defer":
            _defer_namecall_choice(companion_id)
        else:
            _accept_namecall_choice(companion_id)
    _finalize_selected_unit_action(acting_unit, pending_reason, true)

func _accept_namecall_choice(companion_id: StringName) -> void:
    namecall_pending = false
    _pending_namecall_companion_id = &""
    var support_rank: int = 0
    if bond_service != null:
        bond_service.promote_name_call_support(&"ally_rian", companion_id)
        support_rank = bond_service.get_support_rank(&"ally_rian", companion_id)
    var line := SupportConversations.get_name_call_choice_line(String(companion_id), support_rank, true)
    record_finale_name_call_fired(companion_id, line)

func _defer_namecall_choice(companion_id: StringName) -> void:
    namecall_pending = true
    _pending_namecall_companion_id = companion_id
    finale_name_call_lines[String(companion_id)] = SupportConversations.get_name_call_choice_line(String(companion_id), SUPPORT_BOND_RANK_B, false)
    if progression_service == null:
        return
    var progression_data = progression_service.get_data()
    if progression_data != null:
        progression_data.namecall_rejected_count += 1

func _begin_player_phase(reason: String) -> void:
    _transition_to(BattlePhase.PLAYER_PHASE_START, reason, {"round": round_index})

    _update_hold_objective_progress(reason)

    turn_manager.begin_phase("ally", ally_units + enemy_units, reason)
    var synergy_summary := _apply_synergy_reactions()
    var weather_summary := _apply_weather_effects()
    _record_environment_turn_actions(synergy_summary, weather_summary)
    _apply_phase_start_statuses("ally")
    pending_move_origins.clear()
    falling_units_this_turn.clear()
    _refresh_unit_visual_state()
    _clear_selection()

    input_controller.cell_size = stage_data.cell_size
    input_controller.board_origin = board_origin
    grid_cursor.cell_size = stage_data.cell_size
    grid_cursor.position = board_origin

    _transition_to(BattlePhase.PLAYER_SELECT, "player_units_ready", {
        "ready_units": turn_manager.get_ready_unit_count("ally", ally_units)
    })
    _focus_first_ready_unit_if_any()
    if _check_battle_end():
        return

func _end_player_phase(reason: String) -> void:
    _check_bond_death()
    falling_units_this_turn.clear()
    _clear_selection()
    _transition_to(BattlePhase.PLAYER_PHASE_END, reason, {"round": round_index})
    _emit_turn_ended_signal("ally")
    _begin_enemy_phase("enemy_phase_open")

func _begin_enemy_phase(reason: String) -> void:
    _transition_to(BattlePhase.ENEMY_PHASE_START, reason, {"round": round_index})

    turn_manager.begin_phase("enemy", ally_units + enemy_units, reason)
    var synergy_summary := _apply_synergy_reactions()
    var weather_summary := _apply_weather_effects({"apply_rain_tick": false})
    _record_environment_turn_actions(synergy_summary, weather_summary)
    _apply_phase_start_statuses("enemy")
    # Clear per-round bonuses; boss phase bonuses are re-applied in _check_boss_phase_transitions
    enemy_attack_bonus_by_unit.clear()
    enemy_movement_bonus_by_unit.clear()
    falling_units_this_turn.clear()
    _refresh_unit_visual_state()
    _clear_selection()

    call_deferred("_run_enemy_phase")

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

        _check_bond_death()

        if _check_battle_end():
            return

    _transition_to(BattlePhase.ENEMY_PHASE_END, "enemy_phase_exhausted", {
        "acted_count": acted_count,
        "round": round_index
    })
    _emit_turn_ended_signal("enemy")

    _check_bond_death()
    falling_units_this_turn.clear()

    _update_flood_zones()
    if _check_battle_end():
        return

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

    if action_type == "valgar_fortify":
        var pressured_target = action.get("target", null)
        if pressured_target != null and is_instance_valid(pressured_target) and not pressured_target.is_defeated():
            boss_marked_target_id = pressured_target.get_instance_id()
            boss_charge_pending = true
            _apply_valgar_fortification(enemy)
            _record_boss_event("valgar_fortify")
            _refresh_unit_visual_state()
            hud.set_transition_reason("valgar_fortify_telegraphed", {
                "unit": enemy.unit_data.unit_id,
                "target": pressured_target.unit_data.unit_id,
                "effect": "pressure_then_charge"
            })
            _play_battle_flash(Color(0.85098, 0.670588, 0.352941, 0.18), 0.18)
            _play_world_fx("mark_ring.png", enemy.grid_position, Color(0.94902, 0.807843, 0.454902, 0.96), 0.38, 1.05)
            _play_world_fx("mark_ring.png", pressured_target.grid_position, Color(1.0, 0.768627, 0.423529, 0.92), 0.30, 0.88)
        return

    var move_succeeded: bool = false
    if action.has("move_to"):
        var move_to: Vector2i = action["move_to"]
        if move_to == enemy.grid_position:
            move_succeeded = true
        elif _can_unit_legally_move_to(enemy, move_to):
            enemy.set_grid_position(move_to, stage_data.cell_size)
            turn_manager.mark_moved(enemy, "enemy_move_committed", {"to": move_to})
            move_succeeded = true

    if action.has("target"):
        var target: UnitActor = action["target"]
        var can_attack: bool = target != null and is_instance_valid(target) and not target.is_defeated() and _is_in_attack_range(enemy, target)
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
            _resolve_attack(enemy, target, extra_context)
        elif action.has("target"):
            hud.set_transition_reason("enemy_attack_cancelled", {
                "unit": enemy.unit_data.unit_id,
                "reason": "target_out_of_range_after_move"
            })

func _resolve_attack(attacker: UnitActor, defender: UnitActor, extra_context: Dictionary = {}) -> void:
    var attacker_hp_before: int = attacker.current_hp
    var attacker_max_hp: int = attacker.unit_data.max_hp if attacker.unit_data != null else attacker.current_hp
    var attack_context: Dictionary = _build_attack_context(attacker, defender, extra_context)
    if _should_apply_lete_story_retreat(defender):
        attack_context["story_retreat_min_hp"] = 1
        attack_context["allow_counterattack"] = false

    var result: Dictionary = combat_service.resolve_attack(attacker, defender, attacker.get_default_skill(), {
        "defense_bonus": attack_context.get("defense_bonus", 0),
        "terrain_type": attack_context.get("terrain_type", "plain"),
        "allow_counterattack": attack_context.get("allow_counterattack", true),
        "attack_bonus": attack_context.get("attack_bonus", 0),
        "counter_context": attack_context.get("counter_context", {}),
        "oblivion_accuracy_mod": attack_context.get("oblivion_accuracy_mod", 0),
        "oblivion_skills_sealed": attack_context.get("oblivion_skills_sealed", false),
        "accuracy_mod": attack_context.get("accuracy_mod", 0),
        "attack_percent_mod": attack_context.get("attack_percent_mod", 0),
        "defense_percent_mod": attack_context.get("defense_percent_mod", 0),
        "crit_rate_bonus": attack_context.get("crit_rate_bonus", 0)
    })
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
        attacker.play_attack_animation(defender.grid_position, stage_data.cell_size.x)

    hud.set_transition_reason(reason, {
        "attacker": attacker.unit_data.unit_id,
        "defender": defender.unit_data.unit_id,
        "damage": result.get("damage", 0),
        "round": round_index,
        "terrain_type": String(stage_data.get_terrain_type(defender.grid_position))
    })

    var damage_share_payload: Dictionary = {}
    if attacker.faction == "enemy" and defender.faction == "ally" and bond_service != null:
        damage_share_payload = _apply_damage_share(defender, int(result.get("damage", 0)))

    var lete_retreated: bool = _try_trigger_lete_story_retreat(defender)
    _try_record_mira_unlock(attacker, defender, result)

    if defender.is_defeated():
        _remove_unit_from_roster(defender)

    var counterattack: Dictionary = result.get("counterattack", {})
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
    if attacker.faction == "ally" and bond_service != null and is_instance_valid(attacker) and not attacker.is_defeated() and not lete_retreated and not bool(result.get("defender_defeated", false)):
        support_attack_triggered = _try_resolve_support_attack(attacker, defender)

    var follow_up_payload := {
        "attacker": attacker.unit_data.unit_id,
        "defender": defender.unit_data.unit_id,
        "round": round_index
    }
    if support_attack_triggered and not last_support_attack_details.is_empty():
        follow_up_payload = last_support_attack_details.duplicate(true)
    elif not damage_share_payload.is_empty():
        follow_up_payload = damage_share_payload.duplicate(true)

    var phase_reason := reason
    if support_attack_triggered:
        phase_reason = "support_attack_resolved"
    elif not damage_share_payload.is_empty():
        phase_reason = "damage_shared"
    _sync_hud_phase(phase_reason, follow_up_payload)
    _record_turn_action({
        "type": "attack",
        "actor_id": attacker.unit_data.unit_id if attacker.unit_data != null else &"",
        "actor_hp_before": attacker_hp_before,
        "actor_max_hp": attacker_max_hp,
        "target_id": defender.unit_data.unit_id if defender.unit_data != null else &"",
        "killed_unit_ids": [defender.unit_data.unit_id] if bool(result.get("defender_defeated", false)) and defender.unit_data != null else [],
        "source": "primary_attack"
    })

func _apply_damage_share(defender: UnitActor, total_damage: int) -> Dictionary:
    if total_damage <= 0:
        return {}
    var share_result: Dictionary = bond_service.resolve_damage_share(defender, total_damage, ally_units)
    if bool(share_result.get("target_takes_all", true)):
        return {}

    var redirected_total: int = 0
    var sacrificed_unit_ids: Array[StringName] = []
    for share in share_result.get("shared_amounts", []):
        var unit: UnitActor = share.get("unit", null)
        var shared_damage: int = int(share.get("shared_damage", 0))
        if unit == null or not is_instance_valid(unit) or shared_damage <= 0:
            continue
        unit.apply_damage(shared_damage)
        redirected_total += shared_damage
        if unit.is_defeated():
            _remove_unit_from_roster(unit)
            if unit.unit_data != null:
                sacrificed_unit_ids.append(unit.unit_data.unit_id)

    if redirected_total > 0:
        defender.current_hp = mini(defender.unit_data.max_hp, defender.current_hp + redirected_total)
        defender._refresh_visuals()
        if not defender.is_defeated() and defender.unit_data != null:
            for sacrificed_unit_id in sacrificed_unit_ids:
                _record_turn_action({
                    "type": "sacrifice_play",
                    "actor_id": sacrificed_unit_id,
                    "saved_unit_id": defender.unit_data.unit_id,
                    "protected_unit_id": defender.unit_data.unit_id,
                    "actor_died": true,
                    "source": "damage_share"
                })

    var payload := {
        "target": defender.unit_data.unit_id,
        "bond": MAX_BOND_LEVEL,
        "share": int(share_result.get("share_per_ally", 0)),
        "shared_units": int((share_result.get("shared_amounts", []) as Array).size())
    }
    hud.set_transition_reason("damage_shared", payload)
    return payload

func _try_resolve_support_attack(attacker: UnitActor, defender: UnitActor) -> bool:
    for unit: UnitActor in ally_units:
        if unit == attacker or not is_instance_valid(unit) or unit.is_defeated():
            continue
        if bond_service.can_support_attack(attacker, unit):
            _resolve_support_attack(unit, defender)
            return true  # 첫 번째 지원자만
    return false

func _resolve_support_attack(supporter: UnitActor, defender: UnitActor) -> void:
    var supporter_hp_before: int = supporter.current_hp
    var supporter_max_hp: int = supporter.unit_data.max_hp if supporter.unit_data != null else supporter.current_hp
    var support_context := _build_attack_context(supporter, defender, {
        "attack_bonus": -2,
        "allow_counterattack": false
    }, false)
    var support_result: Dictionary = combat_service.resolve_attack(supporter, defender, supporter.get_default_skill(), {
        "defense_bonus": support_context.get("defense_bonus", 0),
        "terrain_type": support_context.get("terrain_type", "plain"),
        "allow_counterattack": false,
        "attack_bonus": support_context.get("attack_bonus", 0),
        "counter_context": support_context.get("counter_context", {}),
        "oblivion_accuracy_mod": support_context.get("oblivion_accuracy_mod", 0),
        "oblivion_skills_sealed": support_context.get("oblivion_skills_sealed", false),
        "accuracy_mod": support_context.get("accuracy_mod", 0),
        "attack_percent_mod": support_context.get("attack_percent_mod", 0),
        "defense_percent_mod": support_context.get("defense_percent_mod", 0),
        "crit_rate_bonus": support_context.get("crit_rate_bonus", 0)
    })
    if telemetry_service != null:
        telemetry_service.record_command_use(&"support_attack")
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
    _record_turn_action({
        "type": "attack",
        "actor_id": supporter.unit_data.unit_id if supporter.unit_data != null else &"",
        "actor_hp_before": supporter_hp_before,
        "actor_max_hp": supporter_max_hp,
        "target_id": defender.unit_data.unit_id if defender.unit_data != null else &"",
        "killed_unit_ids": [defender.unit_data.unit_id] if bool(support_result.get("defender_defeated", false)) and defender.unit_data != null else [],
        "source": "support_attack"
    })

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

    var reward_detail: String = _format_interaction_detail(result)
    _handle_story_interaction_result(result, unit, object_actor)
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

func _queue_spotlight_slow_mo(duration: float, scale: float = 0.35) -> void:
    if duration <= 0.0 or not is_inside_tree() or DisplayServer.get_name() == "headless":
        return
    _spotlight_slow_mo_token += 1
    var token: int = _spotlight_slow_mo_token
    Engine.time_scale = clampf(scale, 0.05, 1.0)
    var timer := get_tree().create_timer(duration, true, false, true)
    timer.timeout.connect(func() -> void:
        if token == _spotlight_slow_mo_token:
            Engine.time_scale = 1.0
    , CONNECT_ONE_SHOT)

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
    var objective_state := _get_active_objective_progress()

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
        "rescue_quota":
            if int(objective_state.get("required_count", 0)) > 0 and bool(objective_state.get("completed", false)):
                _transition_to(BattlePhase.VICTORY, "rescue_objectives_completed", {"round": round_index})
                hud.cache_result_text("Victory\nThe required objective anchors were secured.")
                _on_battle_victory()
                battle_finished.emit(&"victory", stage_data.stage_id)
                return true
        _:
            if enemy_units.is_empty():
                last_result = "victory"
                _transition_to(BattlePhase.VICTORY, "enemy_team_eliminated", {"round": round_index})
                hud.cache_result_text("Victory\nAll enemy units are defeated.")
                _on_battle_victory()
                battle_finished.emit(&"victory", stage_data.stage_id)
                return true

    if ally_units.is_empty():
        last_result = "defeat"
        _transition_to(BattlePhase.DEFEAT, "ally_team_eliminated", {"round": round_index})
        hud.show_result("Defeat...\nAll ally units are defeated.")
        _on_battle_defeat()
        battle_defeat.emit(stage_data.stage_id if stage_data != null else &"", _build_battle_defeat_payload())
        battle_finished.emit(&"defeat", stage_data.stage_id)
        return true

    return false

func _on_battle_victory() -> void:
    last_result = "victory"
    if _is_mirror_battle_active():
        hidden_recruit_state["mirror_mode"] = true
        hidden_recruit_state["mirror_leonika_survived"] = _has_live_mirror_leonika()
        hidden_recruit_state["mirror_perspective_decision_count"] = mirror_enemy_commander.perspective_decisions.size() if mirror_enemy_commander != null else 0
        var enemy_view := _get_enemy_view()
        if enemy_view != null and enemy_view.has_method("record_mirror_victory"):
            enemy_view.record_mirror_victory(stage_data.stage_id if stage_data != null else &"")
    var result_summary := {
        "outcome": "victory",
        "title": "Victory",
        "stage_id": String(stage_data.stage_id) if stage_data != null else "",
        "objective": _get_objective_text(),
        "reward_entries": battle_reward_log.duplicate(),
        "unit_exp_results": [],
        "memory_entries": _get_stage_memory_entries(),
        "evidence_entries": _get_stage_evidence_entries(),
        "letter_entries": _get_stage_letter_entries(),
        "fragment_id": "",
        "command_unlocked": "",
        "recovered_fragment_ids": [],
        "unlocked_command_ids": [],
        "support_attack_count": 0,
        "supporter_bond_level": 0,
        "burden_delta": 0,
        "trust_delta": 0,
        "badge_narrative": "",
        "hidden_recruit_state": {},
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
            result_summary["world_timeline_id"] = _normalize_world_timeline_id(after_data.world_timeline_id)
            result_summary["world_timeline_text"] = _build_world_timeline_result_line(after_data.world_timeline_id, stage_data.stage_id if stage_data != null else StringName())
            result_summary["badge_narrative"] = String(BattleResultScreenScript.build_badge_narrative_payload(after_data).get("narrative", ""))
            result_summary["progression_data"] = after_data
    if telemetry_service != null:
        var session_snapshot: Dictionary = telemetry_service.get_session_snapshot()
        var command_usage: Dictionary = session_snapshot.get(TelemetryService.KEY_COMMAND_USAGE, {})
        result_summary["support_attack_count"] = int(command_usage.get("support_attack", 0))
    if not last_support_attack_details.is_empty():
        result_summary["supporter_bond_level"] = int(last_support_attack_details.get("bond", 0))
    var completed_objectives: Array[String] = []
    if stage_data != null:
        var objective_text := stage_data.objective_text.strip_edges()
        if objective_text.is_empty():
            objective_text = stage_data.get_display_title()
        completed_objectives.append(objective_text)
        result_summary["stage_id"] = String(stage_data.stage_id)
    result_summary["turn_count"] = round_index
    result_summary["star_rating"] = _calculate_result_star_rating()
    result_summary["objective_state"] = get_objective_state_snapshot()
    result_summary["objectives_completed"] = completed_objectives
    result_summary["notes"] = "Victory archived in the field record."
    result_summary["hidden_recruit_state"] = get_hidden_recruit_state_snapshot()
    _archive_chronicle_entry(result_summary)
    var finale_result: Dictionary = _build_finale_result_summary()
    if not finale_result.is_empty():
        result_summary["finale_result"] = finale_result
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
    last_result = "defeat"
    if telemetry_service != null:
        telemetry_service.record_battle_end(&"defeat", round_index)
    if progression_service != null:
        progression_service.apply_burden_delta(1, "battle_defeat")

func _archive_chronicle_entry(result_summary: Dictionary) -> void:
    if stage_data == null or progression_service == null:
        return
    var chronicle := get_node_or_null("/root/Chronicle") as ChronicleGenerator
    if chronicle == null:
        return
    var progression = progression_service.get_data()
    if progression == null:
        return
    var entry := chronicle.generate_entry(String(stage_data.stage_id), _build_chronicle_battle_log(), progression.choices_made)
    if entry == null:
        return
    progression.add_chronicle_entry(entry)
    result_summary["chronicle_entry"] = entry.to_summary_dict()

func _build_chronicle_battle_log() -> Array:
    var key_moments: Array[Dictionary] = []
    for raw_turn in _chronicle_turn_history:
        if typeof(raw_turn) != TYPE_DICTIONARY:
            continue
        var turn_data := raw_turn as Dictionary
        var turn_number := int(turn_data.get("turn", round_index))
        var turn_owner := String(turn_data.get("turn_owner", "")).strip_edges()
        for raw_action in turn_data.get("actions", []):
            if typeof(raw_action) != TYPE_DICTIONARY:
                continue
            var action := (raw_action as Dictionary).duplicate(true)
            action["turn"] = int(action.get("turn", turn_number))
            action["turn_owner"] = turn_owner
            key_moments.append(action)
    return [{
        "turn_count": round_index,
        "ally_count": _chronicle_ally_opening_count,
        "enemy_count": _chronicle_enemy_opening_count,
        "enemies_defeated": _chronicle_enemy_defeats.duplicate(),
        "allies_lost": _chronicle_allies_lost.duplicate(true),
        "weather_events": _chronicle_weather_events.duplicate(),
        "key_moments": key_moments,
    }]

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
    if unit != null and is_instance_valid(unit) and unit.unit_data != null and not falling_units_this_turn.has(unit.unit_data.unit_id):
        falling_units_this_turn.append(unit.unit_data.unit_id)
    if unit != null and is_instance_valid(unit) and unit.unit_data != null:
        if unit.faction == "enemy":
            var defeated_enemy_id := String(unit.unit_data.unit_id).strip_edges()
            if not defeated_enemy_id.is_empty() and not _chronicle_enemy_defeats.has(defeated_enemy_id):
                _chronicle_enemy_defeats.append(defeated_enemy_id)
        elif unit.faction == "ally":
            var defeated_ally_id := String(unit.unit_data.unit_id).strip_edges()
            if not defeated_ally_id.is_empty():
                _chronicle_allies_lost.append({
                    "unit_id": defeated_ally_id,
                    "turn": round_index
                })
    turn_manager.mark_downed(unit, "unit_defeated", {"round": round_index})
    if status_service != null:
        status_service.remove_unit(unit)
    if telemetry_service != null:
        if unit.faction == "ally":
            telemetry_service.record_ally_death("unit_hp_zero")
            _last_defeated_ally_id = unit.unit_data.unit_id if unit.unit_data != null else &""
            if bond_service != null and unit.unit_data != null:
                bond_service.notify_unit_died(unit.unit_data.unit_id, unit.unit_data.display_name)
        else:
            telemetry_service.record_enemy_death()
            var ashes = get_node_or_null("/root/Ashes")
            if ashes != null and unit.unit_data != null and ashes.has_method("set_current_stage") and ashes.has_method("collect_ashes"):
                ashes.set_current_stage(String(stage_data.stage_id) if stage_data != null else "")
                ashes.collect_ashes(String(unit.unit_data.unit_id))
    _remove_unit_from_roster(unit)
    _sync_hud_phase("unit_defeated", {"round": round_index})

func _check_bond_death():
    if bond_death_patch == null or bond_service == null:
        return null
    var resolution: Dictionary = bond_death_patch.resolve_bond_death(falling_units_this_turn, bond_service)
    if resolution.is_empty():
        return null
    var pair_id := String(resolution.get("pair_id", ""))
    var ending = resolution.get("ending", null)
    if pair_id.is_empty() or ending == null:
        return null
    bond_death_triggered.emit(pair_id, String(ending.id))
    falling_units_this_turn.clear()
    return ending

func get_bond_ending_registry():
    if bond_death_patch == null:
        return null
    return bond_death_patch.get_registry()

func _on_action_state_changed(unit: UnitActor, from_state: StringName, to_state: StringName, reason: String, payload: Dictionary) -> void:
    var transition_payload: Dictionary = payload.duplicate(true)
    if unit != null and unit.unit_data != null:
        transition_payload["unit"] = unit.unit_data.unit_id

    transition_payload["from"] = from_state
    transition_payload["to"] = to_state
    hud.set_transition_reason(reason, transition_payload)
    _sync_hud_phase(reason, transition_payload)

func _on_battle_turn_ended(_turn_owner: String, turn_actions: Array) -> void:
    _chronicle_turn_history.append({
        "turn": round_index,
        "turn_owner": _turn_owner,
        "actions": turn_actions.duplicate(true)
    })
    var spotlight := _get_spotlight_manager()
    if spotlight == null:
        return
    spotlight.check_spotlight_conditions(turn_actions)

func _on_spotlight_triggered(spotlight_type: StringName, unit_ids: Array) -> void:
    var spotlight := _get_spotlight_manager()
    if spotlight == null or spotlight.get_active_battle_id() != _get_spotlight_battle_id():
        return
    last_spotlight_effect = spotlight.apply_spotlight_effects(self, spotlight_type, _variant_to_string_name_array(unit_ids))

func _wire_spotlight_signal() -> void:
    var spotlight := _get_spotlight_manager()
    if spotlight == null:
        return
    if not spotlight.spotlight_triggered.is_connected(_on_spotlight_triggered):
        spotlight.spotlight_triggered.connect(_on_spotlight_triggered)

func _get_spotlight_manager() -> SpotlightManager:
    return get_node_or_null("/root/Spotlight") as SpotlightManager

func _get_spotlight_battle_id() -> StringName:
    return stage_data.stage_id if stage_data != null else &"unknown"

func _emit_turn_ended_signal(turn_owner: String) -> void:
    var turn_snapshot: Array = _current_turn_actions.duplicate(true)
    battle_turn_ended.emit(turn_owner, turn_snapshot)
    _current_turn_actions.clear()

func _record_turn_action(action: Dictionary) -> void:
    if action.is_empty():
        return
    _current_turn_actions.append(action.duplicate(true))

func _record_environment_turn_actions(synergy_summary: Dictionary, weather_summary: Dictionary) -> void:
    _record_weather_effect_action(&"steam_confusion", synergy_summary.get("steam_confusion_units", []))
    _record_weather_effect_action(&"night_smoke", synergy_summary.get("night_smoke_penalty_units", []))
    _record_weather_effect_action(&"rain_comfort", weather_summary.get("rain_comfort_units", []))
    _record_weather_effect_action(&"rain_drain", weather_summary.get("rain_drained_units", []))
    _record_weather_effect_action(&"thunder_fear", weather_summary.get("fear_targets", []))

func _record_weather_effect_action(effect_id: StringName, affected_unit_ids: Variant) -> void:
    var unit_ids: Array[StringName] = _variant_to_string_name_array(affected_unit_ids)
    if unit_ids.is_empty():
        return
    var normalized_effect_id := String(effect_id).strip_edges()
    if not normalized_effect_id.is_empty() and not _chronicle_weather_events.has(normalized_effect_id):
        _chronicle_weather_events.append(normalized_effect_id)
    _record_turn_action({
        "type": "weather",
        "weather_effect_id": effect_id,
        "affected_unit_ids": unit_ids
    })

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

func _is_hidden_enemy_from_player(unit: UnitActor) -> bool:
    return unit != null and is_instance_valid(unit) and unit.faction == "enemy" and unit.is_stealth_hidden()

func _find_object_at(cell: Vector2i) -> InteractiveObjectActor:
    for object_actor in interactive_objects:
        if is_instance_valid(object_actor) and object_actor.grid_position == cell:
            return object_actor
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

    return path_service.get_path_cost(path) <= unit.get_movement()

func _can_selected_unit_attack(defender: UnitActor) -> bool:
    if selected_unit == null or defender == null or not turn_manager.can_unit_act(selected_unit):
        return false

    if _is_hidden_enemy_from_player(defender):
        return false

    return _is_in_attack_range(selected_unit, defender)

func _can_selected_unit_interact(object_actor: InteractiveObjectActor) -> bool:
    if selected_unit == null or object_actor == null or not turn_manager.can_unit_act(selected_unit):
        return false

    return object_actor.can_interact(selected_unit)

func _get_attackable_enemy_count(unit: UnitActor) -> int:
    var count: int = 0
    for enemy in enemy_units:
        if is_instance_valid(enemy) and not enemy.is_defeated() and not _is_hidden_enemy_from_player(enemy) and _is_in_attack_range(unit, enemy):
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
        if path_cost > selected_unit.get_movement():
            continue

        if path_cost < best_cost or (path_cost == best_cost and _distance_between_cells(candidate, object_actor.grid_position) < _distance_between_cells(best_cell, object_actor.grid_position)):
            best_cost = path_cost
            best_cell = candidate

    return best_cell

func _is_in_attack_range(attacker: UnitActor, defender: UnitActor) -> bool:
    var attack_cells: Array = range_service.get_attack_cells(attacker.grid_position, attacker.get_attack_range())
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
            unit.set_tile_context(stage_data.get_terrain_type(unit.grid_position), stage_data.get_defense_bonus(unit.grid_position))
    for object_actor in interactive_objects:
        if is_instance_valid(object_actor):
            object_actor.set_highlighted(_is_object_interactable_by_selection(object_actor))

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
    var combat_quote := _get_selected_unit_combat_quote()
    var active_statuses: Array[StringName]
    if status_service != null:
        active_statuses = status_service.get_statuses(selected_unit)
    hud.set_selection_summary(
        selected_unit.unit_data.display_name,
        hp_text,
        selected_unit.get_movement(),
        selected_unit.get_attack_range(),
        reachable_cells.size(),
        attackable_count,
        interactable_count,
        terrain_text,
        oblivion_stack,
        combat_quote,
        active_statuses
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

func _get_selected_unit_combat_quote() -> String:
    if selected_unit == null or selected_unit.unit_data == null or progression_service == null:
        return ""
    var data := progression_service.get_data()
    if data == null:
        return ""
    return data.get_unit_quote(String(selected_unit.unit_data.unit_id))

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
    hud.set_objective(_get_objective_text())
    hud.set_stage_title(stage_data.get_display_title() if stage_data != null else "")
    hud.set_inventory_snapshot(
        _get_inventory_panel_title(),
        _get_objective_text(),
        get_party_summary_lines(),
        get_inventory_entries()
    )
    hud.set_transition_reason(reason, payload)
    _sync_selection_hud()

func _get_enemy_view() -> Node:
    return get_node_or_null("/root/EnemyView")

func _is_mirror_battle_active() -> bool:
    var enemy_view := _get_enemy_view()
    return enemy_view != null and stage_data != null and bool(enemy_view.get("mirror_mode_active")) and stage_data.stage_id == CH07_05_STAGE_ID

func _apply_mirror_stage_configuration() -> void:
    if not _is_mirror_battle_active():
        return
    var enemy_view := _get_enemy_view()
    if enemy_view != null and enemy_view.has_method("prepare_stage_for_mirror_mode"):
        enemy_view.prepare_stage_for_mirror_mode(stage_data)
    hidden_recruit_state["mirror_mode"] = true
    hidden_recruit_state["mirror_chapter_title"] = _get_mirror_chapter_title()

func _show_mirror_mode_intro() -> void:
    if not _is_mirror_battle_active():
        return
    _record_reward_entry("Leonika — \"%s\"" % MIRROR_LEONIKA_DIALOGUE)
    hidden_recruit_state["mirror_dialogue"] = MIRROR_LEONIKA_DIALOGUE
    _sync_hud_phase("leonika_perspective", {
        "speaker": "Leonika",
        "line": MIRROR_LEONIKA_DIALOGUE
    })

func _get_mirror_chapter_title() -> String:
    var enemy_view := _get_enemy_view()
    if enemy_view != null and enemy_view.has_method("get_mirror_chapter_title"):
        return String(enemy_view.get_mirror_chapter_title())
    return "적의 눈으로 보기"

func _has_live_mirror_leonika() -> bool:
    for unit in ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and unit.unit_data != null and unit.unit_data.unit_id == MIRROR_LEONIKA_UNIT_ID:
            return true
    return false

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
            "move": unit.get_movement(),
            "range": unit.get_attack_range(),
            "skill": default_skill_name,
            "weapon_slot": weapon_name,
            "armor_slot": armor_name,
            "accessory_slot": accessory_name
        })

    return details

func get_objective_state_snapshot() -> Dictionary:
    var objective_state := _get_active_objective_progress()
    var resolved_object_ids: Array[StringName] = objective_state.get("resolved_object_ids", [])
    var resolved_count: int = int(objective_state.get("resolved_count", 0))
    var required_count: int = int(objective_state.get("required_count", 0))

    return {
        "objective_type": objective_state.get("objective_type", &""),
        "objective_id": objective_state.get("objective_id", &""),
        "state_id": _get_objective_state_id(resolved_count, required_count),
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

func _calculate_result_star_rating() -> int:
    if round_index <= 4:
        return 3
    if round_index <= 7:
        return 2
    return 1

func configure_desperate_wave_battle(context: Dictionary) -> void:
    desperate_wave_context = context.duplicate(true)

func clear_special_battle_context() -> void:
    desperate_wave_context.clear()

func get_special_battle_snapshot() -> Dictionary:
    return {
        "last_result": last_result,
        "stage_id": String(stage_data.stage_id) if stage_data != null else "",
        "desperate_wave_battle_triggered": not desperate_wave_context.is_empty(),
        "desperate_wave_context": desperate_wave_context.duplicate(true)
    }

func get_hidden_recruit_state_snapshot() -> Dictionary:
    return hidden_recruit_state.duplicate(true)

func _build_battle_defeat_payload() -> Dictionary:
    return {
        "stage_id": String(stage_data.stage_id) if stage_data != null else "",
        "round": round_index,
        "deployed_ally_ids": _get_stage_ally_unit_ids(),
        "final_ally_unit_id": String(_last_defeated_ally_id),
        "desperate_wave_context": desperate_wave_context.duplicate(true)
    }

func _get_stage_ally_unit_ids() -> Array[String]:
    var unit_ids: Array[String] = []
    if stage_data == null:
        return unit_ids
    for unit_variant in stage_data.ally_units:
        var unit_data := unit_variant as UnitData
        if unit_data == null:
            continue
        unit_ids.append(String(unit_data.unit_id))
    return unit_ids

func record_finale_name_anchor_destroyed(anchor_id: StringName) -> void:
    if not finale_name_anchor_state.has(anchor_id):
        return
    finale_name_anchor_state[anchor_id] = false

func record_finale_name_call_fired(companion_id: StringName, line_override: String = "") -> void:
    if not _get_required_finale_name_call_ids().has(companion_id):
        return
    finale_name_call_state[companion_id] = true
    finale_name_call_lines[String(companion_id)] = line_override if not line_override.strip_edges().is_empty() else _get_finale_name_call_line(companion_id)

func get_finale_result_snapshot() -> Dictionary:
    return _build_finale_result_summary().duplicate(true)

func _reset_finale_contract_state() -> void:
    finale_name_anchor_state.clear()
    finale_name_call_state.clear()
    finale_name_call_lines.clear()
    if stage_data == null:
        return
    for anchor_id: StringName in stage_data.finale_name_anchor_ids:
        finale_name_anchor_state[anchor_id] = true
    if not _is_ch10_finale_stage() or progression_service == null:
        return
    var progression_data = progression_service.get_data()
    if progression_data == null or not progression_data.free_name_call or CH10_FINALE_NAME_CALL_IDS.is_empty():
        return
    finale_name_call_state[CH10_FINALE_NAME_CALL_IDS[0]] = true

func _build_finale_result_summary() -> Dictionary:
    if stage_data == null or stage_data.finale_name_anchor_ids.is_empty():
        return {}

    var remaining_anchor_ids: Array[String] = []
    for anchor_id: StringName in stage_data.finale_name_anchor_ids:
        if bool(finale_name_anchor_state.get(anchor_id, true)):
            remaining_anchor_ids.append(String(anchor_id))

    var required_name_call_ids: Array[StringName] = _get_required_finale_name_call_ids()
    var fired_name_call_ids: Array[String] = []
    for companion_id: StringName in required_name_call_ids:
        if bool(finale_name_call_state.get(companion_id, false)):
            fired_name_call_ids.append(String(companion_id))

    var minimum_anchor_count: int = max(stage_data.finale_minimum_name_anchors, 0)
    return {
        "name_anchor_total": stage_data.finale_name_anchor_ids.size(),
        "name_anchors_remaining": remaining_anchor_ids.size(),
        "name_call_moments_fired": fired_name_call_ids.size(),
        "required_name_call_count": required_name_call_ids.size(),
        "minimum_anchor_condition_met": remaining_anchor_ids.size() >= minimum_anchor_count,
        "minimum_name_anchors_required": minimum_anchor_count,
        "remaining_name_anchor_ids": remaining_anchor_ids,
        "fired_name_call_ids": fired_name_call_ids,
        "fired_name_call_lines": finale_name_call_lines.duplicate(true)
    }

func _get_required_finale_name_call_ids() -> Array[StringName]:
    if _is_ch10_finale_stage():
        return CH10_FINALE_NAME_CALL_IDS.duplicate()
    return _get_current_finale_name_call_ids()

func _get_current_finale_name_call_ids() -> Array[StringName]:
    var companion_ids: Array[StringName] = []
    if stage_data == null:
        return companion_ids
    for unit_data in stage_data.ally_units:
        if unit_data == null:
            continue
        companion_ids.append(unit_data.unit_id)
    return companion_ids

func _is_ch10_finale_stage() -> bool:
    return stage_data != null and stage_data.stage_id == &"CH10_05"

func _try_record_live_finale_name_call(unit: UnitActor) -> void:
    if not _is_ch10_finale_stage() or unit == null or not is_instance_valid(unit) or unit.unit_data == null:
        return
    if bond_service != null:
        bond_service.promote_name_call_support(&"ally_rian", unit.unit_data.unit_id)
    record_finale_name_call_fired(unit.unit_data.unit_id)

func _get_finale_name_call_line(companion_id: StringName) -> String:
    var support_rank: int = 0
    if bond_service != null:
        support_rank = bond_service.get_support_rank(&"ally_rian", companion_id)
    return SupportConversations.get_name_call_line(String(companion_id), support_rank)

func _break_next_finale_name_anchor() -> void:
    if not _is_ch10_finale_stage() or stage_data == null:
        return
    for anchor_id: StringName in stage_data.finale_name_anchor_ids:
        if bool(finale_name_anchor_state.get(anchor_id, true)):
            record_finale_name_anchor_destroyed(anchor_id)
            hud.set_transition_reason("finale_anchor_broken", {
                "anchor": anchor_id,
                "round": round_index
            })
            _sync_hud_phase("finale_anchor_broken", {
                "anchor": anchor_id,
                "round": round_index
            })
            return

func _get_stage_memory_entries() -> Array[String]:
    if stage_data == null:
        return []
    return _variant_to_string_array(CH01_STAGE_MEMORY_LOG.get(stage_data.stage_id, []))

func _get_stage_evidence_entries() -> Array[String]:
    if stage_data == null:
        return []
    return _variant_to_string_array(CH01_STAGE_EVIDENCE_LOG.get(stage_data.stage_id, []))

func _get_stage_letter_entries() -> Array[String]:
    if stage_data == null:
        return []
    return _variant_to_string_array(CH01_STAGE_LETTER_LOG.get(stage_data.stage_id, []))

func _build_result_summary_text(summary: Dictionary) -> String:
    var lines: Array[String] = []
    lines.append("Victory")
    lines.append("Objective: %s" % String(summary.get("objective", "")))
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
    var world_timeline_id := _normalize_world_timeline_id(String(summary.get("world_timeline_id", "A")))
    var world_timeline_text := String(summary.get("world_timeline_text", "")).strip_edges()
    lines.append("World Timeline: %s" % world_timeline_id)
    if not world_timeline_text.is_empty():
        lines.append(world_timeline_text)
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

func _normalize_world_timeline_id(world_timeline_id: String) -> String:
    var normalized := world_timeline_id.strip_edges().to_upper()
    return "B" if normalized == "B" else "A"

func _build_world_timeline_result_line(world_timeline_id: String, stage_id: StringName) -> String:
    var normalized_timeline_id := _normalize_world_timeline_id(world_timeline_id)
    var normalized_stage_id := String(stage_id)
    if normalized_stage_id.begins_with("CH10"):
        return "당신의 진실이 세계를 바꿨습니다." if normalized_timeline_id == "A" else "진실 없는 세계의 영웅입니다."
    if normalized_stage_id.begins_with("CH07"):
        return "세계를 구원하기 위한 선택입니다." if normalized_timeline_id == "A" else "개인적인 생존을 위한 선택입니다."
    if normalized_stage_id.begins_with("CH06"):
        return "진실을 알게 된 전투는 더욱 깊어집니다." if normalized_timeline_id == "A" else "진실을 모르기에 평화롭습니다."
    return "희망 있는 세계관이 이어집니다." if normalized_timeline_id == "A" else "진실을 외면한 세계관이 이어집니다."

func _build_attack_context(attacker: UnitActor, defender: UnitActor, extra_context: Dictionary = {}, include_bond_bonus: bool = true) -> Dictionary:
    var attack_context: Dictionary = {
        "defense_bonus": stage_data.get_defense_bonus(defender.grid_position),
        "terrain_type": String(stage_data.get_terrain_type(defender.grid_position)),
        "allow_counterattack": true,
        "counter_context": {
            "defense_bonus": stage_data.get_defense_bonus(attacker.grid_position),
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

    if include_bond_bonus and attacker.faction == "ally" and bond_service != null:
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

    if status_service != null:
        var attacker_oblivion_fx: Dictionary = status_service.get_oblivion_effects(attacker)
        var attacker_status_fx: Dictionary = status_service.get_status_effects(attacker)
        var defender_status_fx: Dictionary = status_service.get_status_effects(defender)
        attack_context["oblivion_accuracy_mod"] = int(attacker_oblivion_fx.get("accuracy_mod", 0))
        attack_context["oblivion_evasion_mod"] = int(attacker_oblivion_fx.get("evasion_mod", 0))
        attack_context["oblivion_skills_sealed"] = bool(attacker_oblivion_fx.get("skills_sealed", false))
        attack_context["accuracy_mod"] = int(attacker_status_fx.get("accuracy_mod", 0))
        attack_context["attack_percent_mod"] = int(attacker_status_fx.get("attack_percent_mod", 0))
        attack_context["crit_rate_bonus"] = int(attacker_status_fx.get("crit_rate_bonus", 0))
        attack_context["ability_locked"] = bool(attacker_status_fx.get("ability_locked", false))
        attack_context["defense_percent_mod"] = int(defender_status_fx.get("defense_percent_mod", 0))

    var heirloom = get_node_or_null("/root/Heirloom")
    if heirloom != null and heirloom.has_method("get_attack_context_bonus"):
        var heirloom_context: Dictionary = heirloom.get_attack_context_bonus(attacker, defender)
        for key_variant in heirloom_context.keys():
            var key := String(key_variant)
            var value = heirloom_context.get(key_variant)
            if typeof(value) in [TYPE_INT, TYPE_FLOAT] and attack_context.has(key):
                attack_context[key] = int(attack_context.get(key, 0)) + int(value)
            else:
                attack_context[key] = value

    return attack_context

func _apply_synergy_reactions(context: Dictionary = {}) -> Dictionary:
    if status_service == null:
        return {}
    var all_units: Array = _variant_to_unit_array(context.get("units", ally_units + enemy_units))
    var steam_fallback: Array[Vector2i] = stage_data.steam_cloud_cells if stage_data != null else []
    var smoke_fallback: Array[Vector2i] = stage_data.smoke_cells if stage_data != null else []
    var steam_units: Array = _variant_to_unit_array(context.get("steam_units", _get_units_in_cells(_resolve_weather_cells(context, "steam_cloud_cells", steam_fallback), all_units)))
    var smoke_units: Array = _variant_to_unit_array(context.get("smoke_units", _get_units_in_cells(_resolve_weather_cells(context, "smoke_cells", smoke_fallback), all_units)))
    var steam_lookup: Dictionary = _build_unit_lookup(steam_units)
    var smoke_lookup: Dictionary = _build_unit_lookup(smoke_units)
    var night_active: bool = bool(context.get("night", _is_weather_active("night")))
    var summary := {
        "steam_confusion_units": [],
        "night_smoke_penalty_units": []
    }

    for unit_variant in all_units:
        var unit: UnitActor = unit_variant
        if not is_instance_valid(unit) or unit.is_defeated():
            continue
        if steam_lookup.has(unit.get_instance_id()):
            _apply_status(unit, STATUS_CONFUSION, "steam_cloud")
            var confused_units: Array = summary["steam_confusion_units"]
            confused_units.append(unit.unit_data.unit_id)
            summary["steam_confusion_units"] = confused_units
        else:
            status_service.clear_status(unit, STATUS_CONFUSION, "steam_cloud_left")

        var should_apply_night_smoke: bool = night_active and smoke_lookup.has(unit.get_instance_id()) and unit.faction == "ally"
        if should_apply_night_smoke:
            _apply_status(unit, STATUS_NIGHT_SMOKE, "night_smoke")
            var night_smoke_units: Array = summary["night_smoke_penalty_units"]
            night_smoke_units.append(unit.unit_data.unit_id)
            summary["night_smoke_penalty_units"] = night_smoke_units
        else:
            status_service.clear_status(unit, STATUS_NIGHT_SMOKE, "night_smoke_cleared")

    return summary

func _apply_weather_effects(context: Dictionary = {}) -> Dictionary:
    if status_service == null:
        return {}
    var all_units: Array = _variant_to_unit_array(context.get("units", ally_units + enemy_units))
    var rain_active: bool = bool(context.get("rain", _is_weather_active("rain")))
    var apply_rain_tick: bool = bool(context.get("apply_rain_tick", true))
    var thunder_targets: Array = _variant_to_unit_array(context.get("thunder_targets", []))
    var thunder_paralytic_success: bool = bool(context.get("thunder_paralytic_success", false))
    var summary := {
        "rain_comfort_units": [],
        "rain_drained_units": [],
        "fear_targets": []
    }

    for unit_variant in all_units:
        var unit: UnitActor = unit_variant
        if not is_instance_valid(unit) or unit.is_defeated():
            continue
        var is_fire_unit: bool = _is_fire_unit(unit)
        if rain_active and unit.faction == "ally" and not is_fire_unit:
            _apply_status(unit, STATUS_RAIN_COMFORT, "rain_comfort")
            var comfort_units: Array = summary["rain_comfort_units"]
            comfort_units.append(unit.unit_data.unit_id)
            summary["rain_comfort_units"] = comfort_units
        else:
            status_service.clear_status(unit, STATUS_RAIN_COMFORT, "rain_comfort_cleared")

        if rain_active and apply_rain_tick and is_fire_unit:
            unit.current_hp = max(0, unit.current_hp - 1)
            unit._refresh_visuals()
            var drained_units: Array = summary["rain_drained_units"]
            drained_units.append(unit.unit_data.unit_id)
            summary["rain_drained_units"] = drained_units

    if thunder_paralytic_success:
        for target_variant in thunder_targets:
            var target: UnitActor = target_variant
            if not is_instance_valid(target) or target.is_defeated():
                continue
            _apply_status(target, STATUS_FEAR, "thunder_fear", 1, {"source": "thunder"})
            var fear_targets: Array = summary["fear_targets"]
            fear_targets.append(target.unit_data.unit_id)
            summary["fear_targets"] = fear_targets

    return summary

func _apply_phase_start_statuses(faction: String) -> Array[StringName]:
    var skipped_units: Array[StringName] = []
    if status_service == null or turn_manager == null:
        return skipped_units
    var roster: Array = ally_units if faction == "ally" else enemy_units
    for unit_variant in roster:
        var unit: UnitActor = unit_variant
        if not is_instance_valid(unit) or unit.is_defeated() or unit.faction != faction:
            continue
        var status_result: Dictionary = status_service.consume_turn_start_statuses(unit)
        if bool(status_result.get("skip_turn", false)):
            turn_manager.mark_acted(unit, "fear_skip_turn", {"round": round_index, "status": String(STATUS_FEAR)})
            skipped_units.append(unit.unit_data.unit_id)
    return skipped_units

func _variant_to_string_array(value: Variant) -> Array[String]:
    if value is Array[String]:
        return (value as Array[String]).duplicate()
    if value is Array:
        var result: Array[String] = []
        for item in value:
            result.append(String(item))
        return result
    return []

func _variant_to_string_name_array(value: Variant) -> Array[StringName]:
    var result: Array[StringName] = []
    if value is Array:
        for item in value:
            var unit_id: StringName = StringName(item)
            if unit_id != &"":
                result.append(unit_id)
    else:
        var single_unit_id: StringName = StringName(value)
        if single_unit_id != &"":
            result.append(single_unit_id)
    return result

func _variant_to_unit_array(value: Variant) -> Array:
    if value is Array:
        return (value as Array).duplicate()
    return []

func _resolve_weather_cells(context: Dictionary, key: String, fallback: Array[Vector2i]) -> Array[Vector2i]:
    var resolved: Variant = context.get(key, fallback)
    if resolved is Array[Vector2i]:
        return (resolved as Array[Vector2i]).duplicate()
    var cells: Array[Vector2i] = []
    if resolved is Array:
        for entry in resolved:
            if entry is Vector2i:
                cells.append(entry)
    return cells

func _get_units_in_cells(cells: Array[Vector2i], units: Array) -> Array:
    if cells.is_empty():
        return []
    var cell_lookup: Dictionary = {}
    for cell in cells:
        cell_lookup[cell] = true
    var result: Array = []
    for unit_variant in units:
        var unit: UnitActor = unit_variant
        if is_instance_valid(unit) and cell_lookup.has(unit.grid_position):
            result.append(unit)
    return result

func _build_unit_lookup(units: Array) -> Dictionary:
    var lookup: Dictionary = {}
    for unit_variant in units:
        var unit: UnitActor = unit_variant
        if is_instance_valid(unit):
            lookup[unit.get_instance_id()] = true
    return lookup

func _is_weather_active(tag: String) -> bool:
    if stage_data == null:
        return false
    return stage_data.weather_tags.has(tag)

func _is_fire_unit(unit: UnitActor) -> bool:
    if unit == null or unit.unit_data == null:
        return false
    var personality: String = String(unit.unit_data.personality).to_lower()
    if personality == "fire" or personality == "flame" or personality == "ember":
        return true
    return unit.unit_data.default_skill != null and FIRE_SKILL_IDS.has(unit.unit_data.default_skill.skill_id)

func _apply_status(unit: UnitActor, status_name: StringName, reason: String, remaining_turns: int = -1, payload: Dictionary = {}) -> Dictionary:
    if status_service == null:
        return {}
    return status_service.apply_status(unit, status_name, reason, remaining_turns, payload)

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

    var objective_state := _get_active_objective_progress()
    var resolved_count: int = int(objective_state.get("resolved_count", 0))
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
        "rescue_quota":
            return "Rescue the required officers."
        _:
            return String(stage_data.win_condition).replace("_", " ")

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

func _get_active_objective_progress() -> Dictionary:
    var win_condition: String = String(stage_data.win_condition) if stage_data != null else ""
    if win_condition == "rescue_quota":
        var rescue_object_ids: Array[StringName] = _get_rescue_quota_resolved_object_ids()
        var required_count: int = max(stage_data.rescue_objective_required_count, 0)
        var hold_required_turns: int = _get_hold_objective_required_turns()
        var completed: bool = required_count > 0 and rescue_object_ids.size() >= required_count
        var display_count: int = rescue_object_ids.size()
        var display_required: int = required_count
        if hold_required_turns > 0 and rescue_object_ids.size() >= required_count:
            display_required = required_count + hold_required_turns
            display_count = required_count + (hold_required_turns if hold_objective_completed else 0)
            completed = hold_objective_completed
        return {
            "objective_type": &"rescue_quota",
            "objective_id": stage_data.rescue_objective_id,
            "resolved_object_ids": rescue_object_ids,
            "resolved_count": display_count,
            "required_count": display_required,
            "completed": completed,
            "hold_armed": hold_objective_armed,
            "hold_completed": hold_objective_completed
        }

    var resolved_object_ids: Array[StringName] = []
    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor) or object_actor.object_data == null or not object_actor.is_resolved:
            continue
        resolved_object_ids.append(object_actor.object_data.object_id)

    return {
        "objective_type": StringName(win_condition),
        "objective_id": &"",
        "resolved_object_ids": resolved_object_ids,
        "resolved_count": resolved_object_ids.size(),
        "required_count": interactive_objects.size()
    }

func _get_rescue_quota_resolved_object_ids() -> Array[StringName]:
    var resolved_object_ids: Array[StringName] = []
    if stage_data == null or stage_data.rescue_objective_object_ids.is_empty():
        return resolved_object_ids

    for target_object_id in stage_data.rescue_objective_object_ids:
        var object_actor := _find_interactive_object_by_id(target_object_id)
        if object_actor == null or not object_actor.is_resolved:
            continue
        resolved_object_ids.append(target_object_id)
    return resolved_object_ids

func _get_hold_objective_required_turns() -> int:
    if stage_data == null:
        return 0
    return max(stage_data.hold_objective_required_turns, 0)

func _update_hold_objective_progress(reason: String) -> void:
    if stage_data == null or String(stage_data.win_condition) != "rescue_quota":
        return

    var hold_required_turns: int = _get_hold_objective_required_turns()
    if hold_required_turns <= 0:
        return

    var required_count: int = max(stage_data.rescue_objective_required_count, 0)
    var rescue_count: int = _get_rescue_quota_resolved_object_ids().size()
    if rescue_count < required_count:
        return

    if not hold_objective_armed:
        hold_objective_armed = true
        hold_objective_round_started = round_index
        return

    if hold_objective_completed:
        return

    if round_index >= hold_objective_round_started + hold_required_turns:
        hold_objective_completed = true
        _sync_hud_phase("hold_objective_secured", {
            "objective": stage_data.hold_objective_id,
            "round": round_index,
            "hold_turns": hold_required_turns
        })

func _find_interactive_object_by_id(object_id: StringName) -> InteractiveObjectActor:
    for object_actor in interactive_objects:
        if object_actor != null and is_instance_valid(object_actor) and object_actor.object_data != null and StringName(object_actor.object_data.object_id) == object_id:
            return object_actor
    return null

func _get_interaction_objective_text(resolved_count: int) -> String:
    if stage_data == null or stage_data.interaction_objective_texts.is_empty():
        return ""

    var clamped_index: int = clampi(resolved_count, 0, stage_data.interaction_objective_texts.size() - 1)
    return String(stage_data.interaction_objective_texts[clamped_index]).strip_edges()

func _get_objective_state_id(resolved_count: int, required_count: int) -> StringName:
    if stage_data != null and not stage_data.interaction_objective_state_ids.is_empty():
        var clamped_index: int = clampi(resolved_count, 0, stage_data.interaction_objective_state_ids.size() - 1)
        return stage_data.interaction_objective_state_ids[clamped_index]

    var win_condition: String = String(stage_data.win_condition) if stage_data != null else ""
    if win_condition == "resolve_all_interactions" or win_condition == "resolve_all_interactions_and_defeat_all_enemies" or win_condition == "rescue_quota":
        if required_count <= 0:
            return &"interaction_objectives_missing"
        if resolved_count >= required_count:
            return &"interaction_objectives_completed"
        if resolved_count > 0:
            return &"interaction_objectives_in_progress"
        return &"interaction_objectives_pending"

    return &"battle_objective_default"

func _pick_enemy_action(enemy: UnitActor) -> Dictionary:
    if _is_mirror_battle_active():
        return _pick_mirror_enemy_action(enemy)
    if enemy.unit_data != null and enemy.unit_data.is_boss and enemy.unit_data.boss_pattern == LETE_CH08_05_BOSS_PATTERN:
        var lete_action: Dictionary = _pick_lete_action(enemy)
        if not lete_action.is_empty():
            return lete_action
    if enemy.unit_data != null and enemy.unit_data.is_boss and enemy.unit_data.boss_pattern == &"roderic_ch01_05":
        var boss_action: Dictionary = _pick_roderic_action(enemy)
        if not boss_action.is_empty():
            return boss_action
    if enemy.unit_data != null and enemy.unit_data.is_boss and enemy.unit_data.boss_pattern == &"valgar_ch06_05":
        var valgar_action: Dictionary = _pick_valgar_action(enemy)
        if not valgar_action.is_empty():
            return valgar_action

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
        _get_dynamic_blocked_cells(enemy)
    )

func _pick_mirror_enemy_action(enemy: UnitActor) -> Dictionary:
    if mirror_enemy_commander == null:
        return {"type": "wait"}

    var action_data = mirror_enemy_commander.make_mirror_decision(
        ally_units,
        enemy_units,
        {
            "active_unit": enemy,
            "path_service": path_service,
            "range_service": range_service,
            "dynamic_blocked": _get_dynamic_blocked_cells(enemy),
            "stage_data": stage_data
        }
    )
    var enemy_view := _get_enemy_view()
    if enemy_view != null and enemy_view.has_method("record_perspective_decisions"):
        enemy_view.record_perspective_decisions(mirror_enemy_commander.perspective_decisions)
    if action_data == null or not action_data.has_method("to_dictionary"):
        return {"type": "wait"}
    return action_data.to_dictionary()

func _pick_lete_action(enemy: UnitActor) -> Dictionary:
    if enemy.is_stealth_hidden():
        enemy.set_stealth_hidden(false)

    return ai_service.pick_action(
        enemy,
        ally_units,
        path_service,
        range_service,
        _get_dynamic_blocked_cells(enemy)
    )

func _find_oblivion_target(enemy: UnitActor) -> UnitActor:
    ## Returns the nearest ally in attack range whose 망각 stack is below max.
    var attack_cells: Array = range_service.get_attack_cells(enemy.grid_position, enemy.get_attack_range())
    var best: UnitActor = null
    var best_stack: int = MAX_OBLIVION_STACK  # Only pick targets below max

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

func _pick_valgar_action(enemy: UnitActor) -> Dictionary:
    var pressured_target: UnitActor = _get_marked_target()
    var boss_movement: int = _get_effective_movement(enemy)
    if boss_charge_pending:
        if pressured_target != null and is_instance_valid(pressured_target) and not pressured_target.is_defeated():
            var dynamic_blocked: Dictionary = _get_dynamic_blocked_cells(enemy)
            var approach_plan: Dictionary = ai_service._find_best_approach_plan(enemy, pressured_target, path_service, range_service, dynamic_blocked)
            if not approach_plan.is_empty():
                var move_to: Vector2i = ai_service._truncate_path_to_movement(approach_plan.get("path", []), boss_movement, path_service)
                return {
                    "type": "boss_charge",
                    "move_to": move_to,
                    "target": pressured_target
                }
            if _is_in_attack_range(enemy, pressured_target):
                return {
                    "type": "boss_charge",
                    "target": pressured_target
                }
        boss_charge_pending = false
        boss_marked_target_id = -1

    var target: UnitActor = ai_service._find_nearest_target(enemy, ally_units)
    if target == null:
        return {"type": "wait"}

    return {
        "type": "valgar_fortify",
        "target": target
    }

func _get_marked_target() -> UnitActor:
    if boss_marked_target_id == -1:
        return null

    for unit in ally_units:
        if is_instance_valid(unit) and unit.get_instance_id() == boss_marked_target_id:
            return unit
    return null

func _clone_stage_data(source_stage: StageData) -> StageData:
    if source_stage == null:
        return null
    var duplicated := source_stage.duplicate(true)
    if duplicated is StageData:
        return duplicated
    return source_stage

func _reset_flood_state() -> void:
    flood_zone_positions.clear()
    flood_margin_positions.clear()
    _flood_expansion_turns = 0

func _initialize_flood_zones() -> void:
    _reset_flood_state()
    if not _is_downpour_active() or stage_data == null:
        _refresh_flood_visuals()
        return

    var seeded_cells: Dictionary = {}
    for cell_variant in stage_data.terrain_types.keys():
        var cell: Vector2i = cell_variant
        if _is_wet_terrain(stage_data.get_terrain_type(cell)):
            seeded_cells[cell] = true

    flood_zone_positions = _sort_cells(seeded_cells.keys())
    _recompute_flood_margin_positions()
    _record_flooded_stage()
    _refresh_flood_visuals()

func _update_flood_zones() -> void:
    if not _is_downpour_active() or stage_data == null:
        return
    if flood_zone_positions.is_empty():
        _initialize_flood_zones()
    if flood_zone_positions.is_empty():
        return

    var expanded_cells: Array[Vector2i] = []
    if _flood_expansion_turns < FLOOD_EXPANSION_LIMIT:
        var next_cells: Dictionary = {}
        for source_cell in flood_zone_positions:
            for offset in CARDINAL_DIRECTIONS:
                var candidate: Vector2i = source_cell + offset
                if not _is_cell_in_bounds(candidate):
                    continue
                var terrain_type := stage_data.get_terrain_type(candidate)
                if _is_wet_terrain(terrain_type):
                    continue
                if FLOOD_IMPASSABLE_TERRAIN_TYPES.has(terrain_type):
                    continue
                next_cells[candidate] = true
        for candidate in next_cells.keys():
            _set_flood_terrain(candidate)
            expanded_cells.append(candidate)
        if not expanded_cells.is_empty():
            _flood_expansion_turns += 1
            _extinguish_adjacent_fire_terrain(expanded_cells)

    var drowned_units: Array[String] = _apply_flood_drowning_damage()
    _recompute_flood_margin_positions()
    _refresh_flood_visuals()
    if not expanded_cells.is_empty() or not drowned_units.is_empty():
        _sync_hud_phase("flood_zone_updated", {
            "expanded": expanded_cells.size(),
            "drowning": drowned_units.size(),
            "round": round_index
        })

func _set_flood_terrain(cell: Vector2i) -> void:
    if stage_data == null or not _is_cell_in_bounds(cell):
        return
    stage_data.terrain_types[cell] = FLOOD_TERRAIN_TYPE
    stage_data.terrain_move_costs[cell] = FLOOD_MOVE_COST
    stage_data.terrain_defense_bonuses[cell] = FLOOD_DEFENSE_BONUS
    if not flood_zone_positions.has(cell):
        flood_zone_positions.append(cell)

func _clear_terrain_to_plain(cell: Vector2i) -> void:
    if stage_data == null:
        return
    stage_data.terrain_types.erase(cell)
    stage_data.terrain_move_costs.erase(cell)
    stage_data.terrain_defense_bonuses.erase(cell)

func _extinguish_adjacent_fire_terrain(source_cells: Array[Vector2i]) -> void:
    if stage_data == null:
        return
    var cleared_cells: Dictionary = {}
    for source_cell in source_cells:
        for offset in CARDINAL_DIRECTIONS:
            var candidate: Vector2i = source_cell + offset
            if not _is_cell_in_bounds(candidate):
                continue
            var terrain_type := stage_data.get_terrain_type(candidate)
            if not FIRE_TERRAIN_TYPES.has(terrain_type):
                continue
            cleared_cells[candidate] = true
    for cell in cleared_cells.keys():
        _clear_terrain_to_plain(cell)

func _apply_flood_drowning_damage() -> Array[String]:
    var drowned_units: Array[String] = []
    if stage_data == null:
        return drowned_units
    for unit in ally_units + enemy_units:
        if unit == null or not is_instance_valid(unit) or unit.is_defeated() or not _is_fire_unit(unit):
            continue
        if not _is_wet_terrain(stage_data.get_terrain_type(unit.grid_position)):
            continue
        unit.apply_damage(DROWNING_DAMAGE, &"drowning")
        if unit.unit_data != null:
            drowned_units.append(String(unit.unit_data.unit_id))
    return drowned_units

func _recompute_flood_margin_positions() -> void:
    flood_margin_positions.clear()
    if stage_data == null:
        return
    for cell in flood_zone_positions:
        for offset in CARDINAL_DIRECTIONS:
            var candidate: Vector2i = cell + offset
            if not _is_cell_in_bounds(candidate):
                flood_margin_positions.append(cell)
                break
            if not _is_wet_terrain(stage_data.get_terrain_type(candidate)):
                flood_margin_positions.append(cell)
                break
    flood_margin_positions = _sort_cells(flood_margin_positions)

func _refresh_flood_visuals() -> void:
    if battle_board != null:
        battle_board.set_stage(stage_data)
        battle_board.set_flood_state(flood_zone_positions, flood_margin_positions)
    if path_service != null and stage_data != null:
        path_service.configure_from_stage(stage_data)
    if hud != null:
        hud.set_flood_margin_positions(flood_margin_positions)
    _refresh_flood_effect_layer()
    if is_inside_tree():
        _refresh_unit_visual_state()

func _refresh_flood_effect_layer() -> void:
    if flood_effect_root == null:
        return
    for child in flood_effect_root.get_children():
        child.queue_free()
    if stage_data == null:
        return
    for cell in flood_zone_positions:
        var fill := Polygon2D.new()
        fill.polygon = PackedVector2Array([
            Vector2.ZERO,
            Vector2(stage_data.cell_size.x, 0.0),
            Vector2(stage_data.cell_size.x, stage_data.cell_size.y),
            Vector2(0.0, stage_data.cell_size.y)
        ])
        fill.position = Vector2(cell.x * stage_data.cell_size.x, cell.y * stage_data.cell_size.y)
        fill.color = Color(0.247059, 0.568627, 0.901961, 0.12)
        flood_effect_root.add_child(fill)
        if flood_margin_positions.has(cell):
            var crest := Polygon2D.new()
            crest.polygon = PackedVector2Array([
                Vector2(10.0, 8.0),
                Vector2(stage_data.cell_size.x - 10.0, 8.0),
                Vector2(stage_data.cell_size.x - 16.0, 14.0),
                Vector2(16.0, 14.0)
            ])
            crest.position = fill.position
            crest.color = Color(1.0, 0.380392, 0.380392, 0.22)
            flood_effect_root.add_child(crest)

func _record_flooded_stage() -> void:
    if progression_service == null or stage_data == null:
        return
    var progression_data := progression_service.get_data()
    if progression_data == null:
        return
    var stage_id_text := String(stage_data.stage_id)
    if stage_id_text.is_empty() or progression_data.flooded_stages.has(stage_id_text):
        return
    progression_data.flooded_stages.append(stage_id_text)

func _is_downpour_active() -> bool:
    return stage_data != null and DOWNPOUR_WEATHER_IDS.has(stage_data.weather_id)

func _is_wet_terrain(terrain_type: StringName) -> bool:
    return WET_TERRAIN_TYPES.has(terrain_type)

func _sort_cells(cells: Array) -> Array[Vector2i]:
    var sorted_cells: Array[Vector2i] = []
    for cell in cells:
        sorted_cells.append(cell)
    sorted_cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
        if a.y == b.y:
            return a.x < b.x
        return a.y < b.y
    )
    return sorted_cells

func get_flood_state_snapshot() -> Dictionary:
    return {
        "weather_id": stage_data.weather_id if stage_data != null else &"",
        "flood_zone_positions": flood_zone_positions.duplicate(),
        "flood_margin_positions": flood_margin_positions.duplicate(),
        "expansion_turns": _flood_expansion_turns
    }

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

func _apply_valgar_fortification(boss_unit: UnitActor) -> void:
    enemy_attack_bonus_by_unit[boss_unit.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(boss_unit.get_instance_id(), 0)) + 1
    for enemy in enemy_units:
        if not is_instance_valid(enemy) or enemy == boss_unit or enemy.is_defeated():
            continue
        var distance: int = abs(enemy.grid_position.x - boss_unit.grid_position.x) + abs(enemy.grid_position.y - boss_unit.grid_position.y)
        if distance <= 3:
            enemy_attack_bonus_by_unit[enemy.get_instance_id()] = int(enemy_attack_bonus_by_unit.get(enemy.get_instance_id(), 0)) + 1

func _record_boss_event(event_name: String) -> void:
    boss_event_history.append(event_name)

func _check_boss_phase_transitions() -> void:
    ## Check all boss units for HP-threshold phase transitions.
    ## Applies phase bonuses for the current phase (re-applied each enemy phase start).
    for enemy in enemy_units:
        if not is_instance_valid(enemy) or enemy.is_defeated() or enemy.unit_data == null:
            continue
        if not enemy.unit_data.is_boss:
            continue
        if enemy.unit_data.boss_phase_thresholds.is_empty():
            continue

        var hp_percent: float = (float(enemy.current_hp) / float(enemy.unit_data.max_hp)) * 100.0
        var new_phase: StringName = enemy.unit_data.get_boss_phase_for_hp(hp_percent)
        var unit_id: int = enemy.get_instance_id()
        var old_phase: StringName = boss_phase_by_unit.get(unit_id, &"")

        # Detect phase transition (change or first entry into a phase)
        if new_phase != old_phase:
            if new_phase != &"":
                if _try_trigger_melkion_truth_flip(enemy, new_phase):
                    continue
                boss_phase_by_unit[unit_id] = new_phase
                _record_boss_event("boss_phase_%s" % String(new_phase))
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

func _apply_boss_phase_effects(boss: UnitActor, new_phase: StringName, old_phase: StringName) -> void:
    ## Visual and game-feel feedback for a boss phase transition.
    var phase_name: String = String(new_phase)
    if phase_name == "enrage":
        _play_battle_flash(Color(1.0, 0.4, 0.2, 0.22), 0.24)
        _play_world_fx("hit_spark.png", boss.grid_position, Color(1.0, 0.55, 0.3, 0.96), 0.38, 1.2)
    elif phase_name == "despair":
        _play_battle_flash(Color(0.8, 0.1, 0.2, 0.28), 0.30)
        _play_world_fx("hit_spark.png", boss.grid_position, Color(1.0, 0.2, 0.15, 0.98), 0.45, 1.5)
    if _is_ch10_finale_stage() and boss.unit_data != null and boss.unit_data.unit_id == &"enemy_karon":
        _break_next_finale_name_anchor()
    # Apply stat bonuses for this phase
    _apply_boss_phase_bonuses(boss, new_phase)

func _apply_boss_phase_bonuses(boss: UnitActor, phase: StringName) -> void:
    ## Re-apply stat bonuses for the current boss phase (called each enemy phase start).
    var phase_name: String = String(phase)
    if phase_name == "enrage":
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
    var base_movement: int = unit.get_movement()
    if unit.unit_data != null and unit.unit_data.is_boss:
        base_movement += int(enemy_movement_bonus_by_unit.get(unit.get_instance_id(), 0))
    return base_movement

func _should_apply_lete_story_retreat(defender: UnitActor) -> bool:
    return stage_data != null \
        and stage_data.stage_id == CH08_05_STAGE_ID \
        and defender != null \
        and is_instance_valid(defender) \
        and defender.faction == "enemy" \
        and defender.unit_data != null \
        and defender.unit_data.boss_pattern == LETE_CH08_05_BOSS_PATTERN \
        and not bool(hidden_recruit_state.get("lete_retreated", false))

func _try_trigger_lete_story_retreat(defender: UnitActor) -> bool:
    if not _should_apply_lete_story_retreat(defender):
        return false
    if defender.current_hp > 3:
        return false
    hidden_recruit_state["lete_retreated"] = true
    hidden_recruit_state["lete_remaining_hp"] = defender.current_hp
    _record_reward_entry("Lete retreats at the edge of defeat. Her black-hound oath is broken, but not her life.")
    hud.set_transition_reason("lete_retreat_triggered", {
        "unit": defender.unit_data.unit_id,
        "hp": defender.current_hp,
        "round": round_index
    })
    _sync_hud_phase("lete_retreat_triggered", {
        "unit": defender.unit_data.unit_id,
        "hp": defender.current_hp,
        "round": round_index
    })
    if turn_manager != null:
        turn_manager.mark_downed(defender, "lete_retreat", {"round": round_index})
    if status_service != null:
        status_service.remove_unit(defender)
    _remove_unit_from_roster(defender)
    defender.queue_free()
    return true

func _handle_story_interaction_result(result: Dictionary, unit: UnitActor, object_actor: InteractiveObjectActor) -> void:
    var story_flag: StringName = StringName(result.get("story_flag", &""))
    if story_flag == &"mira_shrine_investigated" and stage_data != null and stage_data.stage_id == CH07_05_STAGE_ID:
        hidden_recruit_state["mira_shrine_investigated"] = true
        hidden_recruit_state["mira_shrine_object_id"] = String(result.get("object_id", object_actor.object_data.object_id if object_actor != null and object_actor.object_data != null else &""))
        hidden_recruit_state["mira_shrine_user"] = String(unit.unit_data.unit_id) if unit != null and unit.unit_data != null else ""

func _try_record_mira_unlock(attacker: UnitActor, defender: UnitActor, result: Dictionary) -> bool:
    if stage_data == null or stage_data.stage_id != CH07_05_STAGE_ID:
        return false
    if not bool(hidden_recruit_state.get("mira_shrine_investigated", false)):
        return false
    if attacker == null or defender == null or attacker.unit_data == null or defender.unit_data == null:
        return false
    if attacker.unit_data.unit_id != &"ally_tia":
        return false
    if not defender.unit_data.is_boss:
        return false
    if not bool(result.get("defender_defeated", false)):
        return false
    hidden_recruit_state["mira_boss_defeated_by_tia"] = true
    hidden_recruit_state["mira_unlocked"] = true
    _record_reward_entry("Mira answers the shrine's record and joins after Tia shatters Saria's line.")
    return true

func _try_trigger_melkion_truth_flip(enemy: UnitActor, new_phase: StringName) -> bool:
    if stage_data == null or stage_data.stage_id != CH09B_05_STAGE_ID:
        return false
    if enemy == null or not is_instance_valid(enemy) or enemy.unit_data == null:
        return false
    if enemy.unit_data.unit_id != &"enemy_melkion" or new_phase != MELKION_FLIP_PHASE:
        return false
    if bool(hidden_recruit_state.get("melkion_flipped", false)):
        return false
    if not _has_live_ally(&"ally_noah"):
        return false
    if bond_service == null or bond_service.get_support_rank(&"rian", &"noah") != 4:
        return false
    var ally_data: UnitData = CampaignCatalog.get_unit_data(&"ally_melkion_ally")
    if ally_data == null:
        return false
    var destination: Vector2i = enemy.grid_position
    boss_phase_by_unit.erase(enemy.get_instance_id())
    enemy_attack_bonus_by_unit.erase(enemy.get_instance_id())
    enemy_movement_bonus_by_unit.erase(enemy.get_instance_id())
    enemy_units.erase(enemy)
    enemy.setup_from_data(ally_data)
    enemy.faction = "ally"
    enemy.set_grid_position(destination, stage_data.cell_size)
    if not ally_units.has(enemy):
        ally_units.append(enemy)
    hidden_recruit_state["melkion_flipped"] = true
    hidden_recruit_state["melkion_support_rank"] = bond_service.get_support_rank(&"rian", &"noah")
    hidden_recruit_state["melkion_flip_phase"] = String(new_phase)
    _record_reward_entry("Melkion rewrites his own record, turns on the archive, and stands with the party for one battle.")
    hud.set_transition_reason("melkion_truth_flip", {
        "unit": ally_data.unit_id,
        "phase": String(new_phase),
        "round": round_index
    })
    _sync_hud_phase("melkion_truth_flip", {
        "unit": ally_data.unit_id,
        "phase": String(new_phase),
        "round": round_index
    })
    _refresh_unit_visual_state()
    return true

func _has_live_ally(unit_id: StringName) -> bool:
    for unit in ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and unit.unit_data != null and unit.unit_data.unit_id == unit_id:
            return true
    return false
