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
const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const StatusService = preload("res://scripts/battle/status_service.gd")
const TelemetryService = preload("res://scripts/battle/telemetry_service.gd")
const RewardService = preload("res://scripts/battle/reward_service.gd")

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
var equipped_accessory_by_unit_id: Dictionary = {}
var equipped_weapon_by_unit_id: Dictionary = {}
var equipped_armor_by_unit_id: Dictionary = {}
var boss_marked_target_id: int = -1
var boss_charge_pending: bool = false
var enemy_attack_bonus_by_unit: Dictionary = {}
var boss_event_history: Array[String] = []

var current_phase: int = BattlePhase.BATTLE_INIT
var round_index: int = 1
var phase_transition_history: Array = []
var board_origin: Vector2 = Vector2.ZERO
var board_scale: float = 1.0
var _battle_flash_tween: Tween
var _fx_cache: Dictionary = {}

# M4/M5/M6 services — instantiated at runtime, not scene nodes.
var progression_service: ProgressionService
var status_service: StatusService
var telemetry_service: TelemetryService
var reward_service: RewardService

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

func bootstrap_battle() -> void:
    round_index = 1
    current_phase = BattlePhase.BATTLE_INIT
    phase_transition_history.clear()
    battle_reward_log.clear()
    boss_marked_target_id = -1
    boss_charge_pending = false
    enemy_attack_bonus_by_unit.clear()
    boss_event_history.clear()

    _clear_battle_state()
    _spawn_from_stage()
    path_service.configure_from_stage(stage_data)
    _layout_battlefield()

    if telemetry_service != null:
        telemetry_service.record_battle_start(stage_data.stage_id if stage_data != null else &"unknown")
    if status_service != null:
        status_service.reset()
    if reward_service != null and stage_data != null:
        reward_service.record_stage_entry(stage_data.stage_id)

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
    input_controller.board_origin = board_origin
    input_controller.cell_size = Vector2i(roundi(scaled_cell_size.x), roundi(scaled_cell_size.y))
    if hud != null:
        hud.set_battle_frame_metrics(board_origin, board_size)

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

    selected_unit.set_grid_position(destination, stage_data.cell_size)
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

func _end_player_phase(reason: String) -> void:
    _clear_selection()
    _transition_to(BattlePhase.PLAYER_PHASE_END, reason, {"round": round_index})
    _begin_enemy_phase("enemy_phase_open")

func _begin_enemy_phase(reason: String) -> void:
    _transition_to(BattlePhase.ENEMY_PHASE_START, reason, {"round": round_index})

    turn_manager.begin_phase("enemy", ally_units + enemy_units, reason)
    enemy_attack_bonus_by_unit.clear()
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

    _transition_to(BattlePhase.ROUND_END, "round_completed", {"round": round_index})
    if telemetry_service != null:
        telemetry_service.record_round_complete(round_index)
    round_index += 1

    _begin_player_phase("next_round_started")

func _apply_enemy_action(enemy: UnitActor, action: Dictionary) -> void:
    var action_type: String = String(action.get("type", ""))
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

    # Apply Burden band penalty to attacker if ally (Rian's coherence cost).
    if attacker.faction == "ally" and progression_service != null:
        var burden_fx := progression_service.get_burden_effect()
        var atk_bonus: int = int(attack_context.get("attack_bonus", 0))
        atk_bonus += int(burden_fx.get("damage_mod", 0))
        attack_context["attack_bonus"] = atk_bonus

    # Apply 망각 stack effects to attacker.
    if status_service != null:
        var status_fx: Dictionary = status_service.get_effects(attacker)
        attack_context["oblivion_accuracy_mod"] = int(status_fx.get("accuracy_mod", 0))
        attack_context["oblivion_evasion_mod"] = int(status_fx.get("evasion_mod", 0))
        attack_context["oblivion_skills_sealed"] = bool(status_fx.get("skills_sealed", false))

    var result: Dictionary = combat_service.resolve_attack(attacker, defender, attacker.get_default_skill(), {
        "defense_bonus": attack_context.get("defense_bonus", 0),
        "terrain_type": attack_context.get("terrain_type", "plain"),
        "allow_counterattack": attack_context.get("allow_counterattack", true),
        "attack_bonus": attack_context.get("attack_bonus", 0),
        "counter_context": attack_context.get("counter_context", {}),
        "oblivion_accuracy_mod": attack_context.get("oblivion_accuracy_mod", 0),
        "oblivion_skills_sealed": attack_context.get("oblivion_skills_sealed", false)
    })
    var reason: String = String(result.get("transition_reason", "attack_resolved"))
    _play_attack_feedback(reason)

    hud.set_transition_reason(reason, {
        "attacker": attacker.unit_data.unit_id,
        "defender": defender.unit_data.unit_id,
        "damage": result.get("damage", 0),
        "round": round_index,
        "terrain_type": String(stage_data.get_terrain_type(defender.grid_position))
    })

    if bool(result.get("defender_defeated", false)):
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

    _sync_hud_phase(reason, {
        "attacker": attacker.unit_data.unit_id,
        "defender": defender.unit_data.unit_id,
        "round": round_index
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

    match String(stage_data.win_condition):
        "resolve_all_interactions":
            if _are_all_interactive_objects_resolved():
                _transition_to(BattlePhase.VICTORY, "interaction_objectives_completed", {"round": round_index})
                hud.show_result("Victory!\nAll objective points were secured.")
                _on_battle_victory()
                battle_finished.emit(&"victory", stage_data.stage_id)
                return true
        "resolve_all_interactions_and_defeat_all_enemies":
            if _are_all_interactive_objects_resolved() and enemy_units.is_empty():
                _transition_to(BattlePhase.VICTORY, "interaction_and_enemy_objectives_completed", {"round": round_index})
                hud.show_result("Victory!\nObjective points were secured and all enemies were defeated.")
                _on_battle_victory()
                battle_finished.emit(&"victory", stage_data.stage_id)
                return true
        _:
            if enemy_units.is_empty():
                _transition_to(BattlePhase.VICTORY, "enemy_team_eliminated", {"round": round_index})
                hud.show_result("Victory!\nAll enemy units are defeated.")
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
    if telemetry_service != null:
        telemetry_service.record_battle_end(&"victory", round_index)
    if progression_service != null and stage_data != null:
        var fragment_id := StringName(String(stage_data.stage_id) + "_fragment")
        var unlock_result := progression_service.recover_fragment(fragment_id)
        if not bool(unlock_result.get("already_known", true)):
            var cmd = unlock_result.get("command_unlocked", null)
            if cmd != null:
                print("[BattleController] Fragment recovered: %s → command unlocked: %s" % [fragment_id, cmd])

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
    hud.set_selection_summary(
        selected_unit.unit_data.display_name,
        hp_text,
        selected_unit.get_movement(),
        selected_unit.get_attack_range(),
        reachable_cells.size(),
        attackable_count,
        interactable_count,
        terrain_text
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
    var resolved_object_ids: Array[StringName] = []
    for object_actor in interactive_objects:
        if not is_instance_valid(object_actor) or object_actor.object_data == null or not object_actor.is_resolved:
            continue
        resolved_object_ids.append(object_actor.object_data.object_id)

    var resolved_count: int = resolved_object_ids.size()
    var required_count: int = interactive_objects.size()

    return {
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

func _get_inventory_panel_title() -> String:
    if stage_data == null:
        return "Field Inventory"
    return "%s Inventory" % stage_data.get_display_title()

func _get_objective_text() -> String:
    if stage_data == null:
        return "Defeat all enemies."

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

func _pick_enemy_action(enemy: UnitActor) -> Dictionary:
    if enemy.unit_data != null and enemy.unit_data.is_boss and enemy.unit_data.boss_pattern == &"roderic_ch01_05":
        var boss_action: Dictionary = _pick_roderic_action(enemy)
        if not boss_action.is_empty():
            return boss_action

    return ai_service.pick_action(
        enemy,
        ally_units,
        path_service,
        range_service,
        _get_dynamic_blocked_cells(enemy)
    )

func _pick_roderic_action(enemy: UnitActor) -> Dictionary:
    var marked_target: UnitActor = _get_marked_target()
    if boss_charge_pending and marked_target != null and is_instance_valid(marked_target) and not marked_target.is_defeated():
        var dynamic_blocked: Dictionary = _get_dynamic_blocked_cells(enemy)
        var approach_plan: Dictionary = ai_service._find_best_approach_plan(enemy, marked_target, path_service, range_service, dynamic_blocked)
        if not approach_plan.is_empty():
            var move_to: Vector2i = ai_service._truncate_path_to_movement(approach_plan.get("path", []), enemy.get_movement(), path_service)
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
