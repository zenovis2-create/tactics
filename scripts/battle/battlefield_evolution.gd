class_name BattlefieldEvolution
extends Node

const EvolutionEvent = preload("res://scripts/battle/evolution_event.gd")

signal evolution_occurred(event_id, affected_tiles)

var active_events: Array[EvolutionEvent] = []
var turn_count: int = 1
var boss_enraged: bool = false

var _stage_data = null
var _battle_board: Node = null
var _path_service: Node = null
var _battle_controller: Node = null

func prepare_for_battle(stage_data, battle_board: Node = null, path_service: Node = null, battle_controller: Node = null) -> void:
	_stage_data = stage_data
	_battle_board = battle_board
	_path_service = path_service
	_battle_controller = battle_controller
	reset()
	for event in build_predefined_events_for_stage(stage_data.stage_id if stage_data != null else &""):
		register_event(event)

func reset() -> void:
	active_events.clear()
	turn_count = 1
	boss_enraged = false
	if _battle_controller != null:
		_battle_controller.set("boss_enraged", false)

func clear_battlefield() -> void:
	reset()
	_stage_data = null
	_battle_board = null
	_path_service = null
	_battle_controller = null

func register_event(event: EvolutionEvent) -> void:
	if event == null:
		return
	var remaining_events: Array[EvolutionEvent] = []
	for active_event in active_events:
		if active_event == null or active_event.event_id == event.event_id:
			continue
		remaining_events.append(active_event)
	active_events = remaining_events
	active_events.append(event)

func build_predefined_events_for_stage(stage_id: StringName) -> Array[EvolutionEvent]:
	var events: Array[EvolutionEvent] = []
	match String(stage_id):
		"CH06_01":
			events.append(EvolutionEvent.create_ch06_castle_siege_event())
		"CH08_01":
			var available_tree_tiles: Array[Vector2i] = EvolutionEvent.CH08_TREE_CANDIDATES.duplicate()
			for trigger_turn_value in [3, 6, 9]:
				var tree_tile := _pick_deterministic_tree_tile(String(stage_id), trigger_turn_value, available_tree_tiles)
				events.append(EvolutionEvent.create_ch08_dark_forest_block_event(trigger_turn_value, tree_tile))
		"CH10_05":
			events.append(EvolutionEvent.create_ch10_final_corruption_event())
	return events

func get_warning_event(current_turn: int) -> EvolutionEvent:
	var warning_event: EvolutionEvent = null
	for event in active_events:
		if event == null:
			continue
		if event.trigger_turn - current_turn != 2:
			continue
		if warning_event == null or event.trigger_turn < warning_event.trigger_turn:
			warning_event = event
	return warning_event

func check_evolutions(current_turn: int) -> Array[EvolutionEvent]:
	turn_count = current_turn
	var triggered_events: Array[EvolutionEvent] = []
	var remaining_events: Array[EvolutionEvent] = []
	for event in active_events:
		if event == null:
			continue
		if event.trigger_turn <= current_turn:
			_apply_event(event)
			triggered_events.append(event)
			continue
		remaining_events.append(event)
	active_events = remaining_events
	return triggered_events

func apply_tile_change(position: Vector2i, new_terrain: String) -> void:
	if _stage_data == null or not _is_cell_in_bounds(position):
		return
	var normalized_terrain := new_terrain.strip_edges()
	if normalized_terrain.is_empty() or normalized_terrain == "plain":
		_stage_data.terrain_types.erase(position)
		_stage_data.terrain_move_costs.erase(position)
		_stage_data.terrain_defense_bonuses.erase(position)
		return
	_stage_data.terrain_types[position] = StringName(normalized_terrain)
	var profile := _terrain_profile_for(normalized_terrain)
	_stage_data.terrain_move_costs[position] = int(profile.get("move_cost", 1))
	_stage_data.terrain_defense_bonuses[position] = int(profile.get("defense_bonus", 0))

func _apply_event(event: EvolutionEvent) -> void:
	if _stage_data == null:
		return
	var affected_tiles: Array[Vector2i] = []
	for position in event.tile_positions:
		if not _is_cell_in_bounds(position):
			continue
		match event.effect_type:
			EvolutionEvent.EffectType.DESTROY:
				_stage_data.blocked_cells.erase(position)
				apply_tile_change(position, event.new_terrain_type)
			EvolutionEvent.EffectType.BLOCK:
				if not _stage_data.blocked_cells.has(position):
					_stage_data.blocked_cells.append(position)
				apply_tile_change(position, event.new_terrain_type)
			EvolutionEvent.EffectType.TRANSFORM:
				_stage_data.blocked_cells.erase(position)
				apply_tile_change(position, event.new_terrain_type)
			EvolutionEvent.EffectType.SPAWN:
				apply_tile_change(position, event.new_terrain_type)
		affected_tiles.append(position)
	if event.event_id == "ch10_final_central_platform_corruption":
		boss_enraged = true
		if _battle_controller != null:
			_battle_controller.set("boss_enraged", true)
	_refresh_battlefield()
	evolution_occurred.emit(event.event_id, affected_tiles)

func _refresh_battlefield() -> void:
	if _battle_board != null and _stage_data != null and _battle_board.has_method("set_stage"):
		_battle_board.set_stage(_stage_data)
	if _path_service != null and _stage_data != null and _path_service.has_method("configure_from_stage"):
		_path_service.configure_from_stage(_stage_data)
	if _battle_controller != null and _battle_controller.has_method("_refresh_unit_visual_state"):
		_battle_controller.call("_refresh_unit_visual_state")

func _pick_deterministic_tree_tile(stage_id: String, trigger_turn_value: int, available_tiles: Array[Vector2i]) -> Vector2i:
	if available_tiles.is_empty():
		return Vector2i.ZERO
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%s_%d" % [stage_id, trigger_turn_value])
	var selected_index := rng.randi_range(0, available_tiles.size() - 1)
	var selected_tile: Vector2i = available_tiles[selected_index]
	available_tiles.remove_at(selected_index)
	return selected_tile

func _terrain_profile_for(terrain_type: String) -> Dictionary:
	match terrain_type:
		"crumbling_debris":
			return {"move_cost": 2, "defense_bonus": 0}
		"fallen_tree":
			return {"move_cost": 2, "defense_bonus": 1}
		"corrupted_ground":
			return {"move_cost": 2, "defense_bonus": 0}
		_:
			return {"move_cost": 1, "defense_bonus": 0}

func _is_cell_in_bounds(cell: Vector2i) -> bool:
	if _stage_data == null:
		return false
	return cell.x >= 0 and cell.y >= 0 and cell.x < _stage_data.grid_size.x and cell.y < _stage_data.grid_size.y
