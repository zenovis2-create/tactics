extends SceneTree

const PATH_SERVICE_SCRIPT = preload("res://scripts/battle/path_service.gd")
const STAGE_DATA_SCRIPT = preload("res://scripts/data/stage_data.gd")
const INTERACTIVE_OBJECT_DATA_SCRIPT = preload("res://scripts/data/interactive_object_data.gd")
const UNIT_DATA_SCRIPT = preload("res://scripts/data/unit_data.gd")
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const OBJECT_SCENE: PackedScene = preload("res://scenes/battle/InteractiveObject.tscn")
const ALLY_VANGUARD = preload("res://data/units/ally_vanguard.tres")
const ALLY_SCOUT = preload("res://data/units/ally_scout.tres")
const ENEMY_RAIDER = preload("res://data/units/enemy_raider.tres")
const BASIC_ATTACK = preload("res://data/skills/basic_attack.tres")
const CLASS_DATA_SCRIPT = preload("res://scripts/data/class_data.gd")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert_weighted_path_prefers_lower_total_cost()
	if _failed:
		return
	await _assert_battle_boots_into_player_phase()
	if _failed:
		return
	_assert_repeated_one_time_interaction_is_rejected()
	if _failed:
		return
	await _assert_one_time_interaction_consumes_turn()
	if _failed:
		return
	await _assert_clicking_resolved_one_time_object_tile_allows_movement()
	if _failed:
		return
	await _assert_duplicate_interaction_resolution_is_inert()
	if _failed:
		return
	await _assert_interaction_blocking_updates_immediately()
	if _failed:
		return
	await _assert_manual_end_turn_forfeits_remaining_allies()
	if _failed:
		return
	await _assert_one_action_package_per_round()
	if _failed:
		return
	await _assert_enemy_illegal_move_targets_are_rejected()
	if _failed:
		return
	await _assert_enemy_out_of_range_move_targets_are_rejected()
	if _failed:
		return
	await _assert_ai_waits_when_no_legal_move_exists()
	if _failed:
		return
	await _assert_ai_move_attack_targets_remain_in_range()
	if _failed:
		return
	await _assert_commander_support_holds_interaction_objective()
	if _failed:
		return
	await _assert_commander_support_approaches_interaction_objective()
	if _failed:
		return
	await _assert_shield_guard_holds_interaction_objective()
	if _failed:
		return
	await _assert_shield_guard_approaches_interaction_objective()
	if _failed:
		return
	await _assert_commander_support_retargets_next_objective_after_resolution()
	if _failed:
		return
	await _assert_shield_guard_retargets_next_objective_after_resolution()
	if _failed:
		return
	await _assert_runtime_context_exposes_last_seen_cells_for_stealth_targets()
	if _failed:
		return
	await _assert_enemy_uses_runtime_context_last_seen_cell_in_battle()
	if _failed:
		return
	await _assert_sleeping_enemy_waits_in_live_battle()
	if _failed:
		return
	await _assert_sealed_commander_reduces_commitment_in_live_battle()
	if _failed:
		return
	await _assert_feared_enemy_advances_cautiously_in_live_battle()
	if _failed:
		return
	await _assert_wake_caution_enemy_advances_cautiously_in_live_battle()
	if _failed:
		return
	await _assert_silenced_healer_holds_position_in_live_battle()
	if _failed:
		return
	await _assert_black_hound_detects_stealth_in_live_battle()
	if _failed:
		return
	await _assert_final_attack_triggers_victory_immediately()
	if _failed:
		return
	await _assert_final_interaction_triggers_victory_immediately()
	if _failed:
		return
	await _assert_final_counterattack_triggers_defeat_immediately()
	if _failed:
		return

	await _cleanup_root_children()
	print("[PASS] Core loop contract runner validated movement, interactions, turn flow, and AI legality.")
	quit(0)

func _assert_weighted_path_prefers_lower_total_cost() -> void:
	var stage = STAGE_DATA_SCRIPT.new()
	stage.grid_size = Vector2i(4, 3)
	stage.cell_size = Vector2i(64, 64)
	stage.terrain_move_costs = {
		Vector2i(1, 1): 5
	}

	var path_service = PATH_SERVICE_SCRIPT.new()
	root.add_child(path_service)
	path_service.configure_from_stage(stage)

	var path: Array = path_service.find_path(Vector2i(0, 1), Vector2i(3, 1))
	var expected_detour := [
		Vector2i(0, 1),
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(3, 0),
		Vector2i(3, 1)
	]

	if path != expected_detour:
		_fail("Weighted pathfinding should prefer the lower-total-cost detour. Got %s" % [str(path)])
		return

	path_service.queue_free()
	await process_frame

func _assert_battle_boots_into_player_phase() -> void:
	var battle = await _spawn_battle()
	if battle == null:
		return

	if int(battle.current_phase) != int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
		_fail("Battle should boot into the focused player-action preview state. Got %s." % battle._phase_name(battle.current_phase))
		return

	if battle.round_index != 1:
		_fail("Battle should start on round 1.")
		return

	if battle.selected_unit == null or battle.selected_unit != battle.ally_units[0]:
		_fail("Battle should auto-focus the first ready ally when the player phase begins.")
		return

	if battle.turn_manager.get_ready_unit_count("ally", battle.ally_units) <= 0:
		_fail("At least one ally should be ready when battle boots into player phase.")
		return

	await _despawn_node(battle)

func _assert_repeated_one_time_interaction_is_rejected() -> void:
	var object_data = INTERACTIVE_OBJECT_DATA_SCRIPT.new()
	object_data.object_id = &"single_use_switch"
	object_data.display_name = "Single Use Switch"
	object_data.one_time_use = true

	var object_actor = OBJECT_SCENE.instantiate()
	root.add_child(object_actor)
	object_actor.setup_from_data(object_data)

	var first_result: Dictionary = object_actor.resolve_interaction(null)
	var second_result: Dictionary = object_actor.resolve_interaction(null)

	if not bool(first_result.get("resolved", false)):
		_fail("Expected the first one-time interaction to resolve successfully.")
		return

	if bool(second_result.get("resolved", false)):
		_fail("One-time objects should reject a second direct resolution attempt.")
		return

	object_actor.queue_free()
	await process_frame

func _assert_one_time_interaction_consumes_turn() -> void:
	var battle = await _spawn_battle(_make_interaction_approach_stage())
	if battle == null:
		return

	var ally = battle.ally_units[0]
	var chest = battle.interactive_objects[0]

	battle._on_world_cell_pressed(ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(chest.grid_position)
	await process_frame

	if ally.grid_position == Vector2i(1, 2):
		_fail("Clicking an out-of-range object should auto-approach a legal interaction tile when one is reachable.")
		return

	battle._on_world_cell_pressed(chest.grid_position)
	await process_frame

	if not chest.is_resolved:
		_fail("Expected one-time object interaction to resolve the chest.")
		return

	if battle.turn_manager.can_unit_act(ally):
		_fail("Interaction should consume the acting unit's action package.")
		return

	battle._on_world_cell_pressed(ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(chest.grid_position)
	await process_frame

	if battle.turn_manager.can_unit_act(ally):
		_fail("Resolved one-time object should not restore or preserve action access.")
		return

	await _despawn_node(battle)

func _assert_clicking_resolved_one_time_object_tile_allows_movement() -> void:
	var battle = await _spawn_battle(_make_interaction_approach_stage())
	if battle == null:
		return

	var acting_ally = battle.ally_units[0]
	var observer_ally = battle.ally_units[1]
	var chest = battle.interactive_objects[0]

	battle._on_world_cell_pressed(acting_ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(chest.grid_position)
	await process_frame
	battle._on_world_cell_pressed(chest.grid_position)
	await process_frame

	var origin: Vector2i = observer_ally.grid_position
	battle._on_world_cell_pressed(observer_ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(chest.grid_position)
	await process_frame

	if observer_ally.grid_position == origin:
		_fail("Clicking a resolved one-time object tile should still allow normal movement onto that tile.")
		return

	if observer_ally.grid_position != chest.grid_position:
		_fail("Expected movement onto the resolved object tile, but the unit ended on %s." % [str(observer_ally.grid_position)])
		return

	if battle.turn_manager.get_unit_state(observer_ally) != battle.turn_manager.STATE_MOVED:
		_fail("Moving onto a resolved object tile should consume movement normally.")
		return

	await _despawn_node(battle)

func _assert_duplicate_interaction_resolution_is_inert() -> void:
	var battle = await _spawn_battle()
	if battle == null:
		return

	var ally = battle.ally_units[1]
	var chest = battle.interactive_objects[0]

	battle._resolve_interaction(ally, chest)
	var reward_count_after_first: int = battle.battle_reward_log.size()
	battle._resolve_interaction(ally, chest)
	await process_frame

	if battle.battle_reward_log.size() != reward_count_after_first:
		_fail("Duplicate one-time interaction resolution should not add reward or interaction log entries.")
		return

	await _despawn_node(battle)

func _assert_interaction_blocking_updates_immediately() -> void:
	var stage = _make_object_blocking_stage()
	var battle = await _spawn_battle(stage)
	if battle == null:
		return

	var acting_ally = battle.ally_units[0]
	var waiting_ally = battle.ally_units[1]
	var lever = battle.interactive_objects[0]

	battle._on_world_cell_pressed(acting_ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(lever.grid_position)
	await process_frame

	if not battle._is_object_occupying_cell(lever.grid_position):
		_fail("Resolved blocking object should occupy its tile immediately after interaction.")
		return

	battle._on_world_cell_pressed(waiting_ally.grid_position)
	await process_frame
	if battle._can_selected_unit_move_to(lever.grid_position):
		_fail("Resolved blocking object should be included in movement legality on the same turn.")
		return

	await _despawn_node(battle)

func _assert_manual_end_turn_forfeits_remaining_allies() -> void:
	var battle = await _spawn_battle()
	if battle == null:
		return

	var acting_ally = battle.ally_units[0]
	var waiting_ally = battle.ally_units[1]

	battle._on_world_cell_pressed(acting_ally.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame

	if not battle.turn_manager.can_unit_act(waiting_ally):
		_fail("Expected the second ally to remain ready before manual end turn.")
		return

	battle._on_end_turn_requested()
	await _wait_until_player_phase_returns(battle)

	if battle.round_index != 2:
		_fail("Manual end turn should advance to the next round after enemy phase.")
		return

	if not battle.turn_manager.can_unit_act(acting_ally):
		_fail("Acting ally should refresh on the next player phase.")
		return

	if not battle.turn_manager.can_unit_act(waiting_ally):
		_fail("Unacted ally should refresh for the next round after forfeiting the previous one.")
		return

	await _despawn_node(battle)

func _assert_one_action_package_per_round() -> void:
	var battle = await _spawn_battle(_make_one_action_package_stage())
	if battle == null:
		return

	var ally = battle.ally_units[0]
	var enemy = battle.enemy_units[0]

	battle._on_world_cell_pressed(ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(enemy.grid_position)
	await process_frame

	if battle.turn_manager.can_unit_act(ally):
		_fail("A unit should be exhausted after spending its action package for the round.")
		return

	battle._on_world_cell_pressed(ally.grid_position)
	await process_frame
	if battle.selected_unit == ally:
		_fail("An exhausted unit should not become re-selectable during the same round.")
		return

	battle._on_end_turn_requested()
	await _wait_until_player_phase_returns(battle)

	if not battle.turn_manager.can_unit_act(ally):
		_fail("A living unit should refresh at the start of the next player round.")
		return

	await _despawn_node(battle)

func _assert_enemy_illegal_move_targets_are_rejected() -> void:
	var battle = await _spawn_battle()
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var start_cell: Vector2i = enemy.grid_position
	var blocked_cell := Vector2i(3, 3)

	battle._apply_enemy_action(enemy, {
		"type": "move_wait",
		"move_to": blocked_cell
	})
	await process_frame

	if enemy.grid_position == blocked_cell:
		_fail("Enemy action resolution should reject illegal move targets on blocked terrain.")
		return

	if enemy.grid_position != start_cell:
		_fail("Enemy should remain on its original tile after an illegal move target is rejected.")
		return

	await _despawn_node(battle)

func _assert_enemy_out_of_range_move_targets_are_rejected() -> void:
	var battle = await _spawn_battle()
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var start_cell: Vector2i = enemy.grid_position
	var illegal_far_cell := Vector2i(7, 7)

	battle._apply_enemy_action(enemy, {
		"type": "move_wait",
		"move_to": illegal_far_cell
	})
	await process_frame

	if enemy.grid_position == illegal_far_cell:
		_fail("Enemy action resolution should reject move targets beyond the unit movement budget.")
		return

	if enemy.grid_position != start_cell:
		_fail("Enemy should remain on its original tile after an out-of-range move target is rejected.")
		return

	await _despawn_node(battle)

func _assert_ai_waits_when_no_legal_move_exists() -> void:
	var battle = await _spawn_battle(_make_sealed_enemy_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "wait":
		_fail("Enemy AI should explicitly wait when no legal move or attack exists.")
		return

	await _despawn_node(battle)

func _assert_ai_move_attack_targets_remain_in_range() -> void:
	var battle = await _spawn_battle(_make_move_attack_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_attack":
		_fail("Expected enemy AI to choose a move-attack action when a legal attack tile exists.")
		return

	var target = action.get("target", null)
	var move_to: Vector2i = action.get("move_to", enemy.grid_position)
	enemy.set_grid_position(move_to, battle.stage_data.cell_size)
	await process_frame

	if target == null or not is_instance_valid(target) or not battle._is_in_attack_range(enemy, target):
		_fail("Enemy move-attack plans must keep the chosen target in range after movement resolution.")
		return

	await _despawn_node(battle)

func _assert_commander_support_holds_interaction_objective() -> void:
	var battle = await _spawn_battle(_make_commander_objective_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var runtime_context: Dictionary = battle._build_enemy_ai_runtime_context(enemy)
	if runtime_context.get("objective_cell", Vector2i(-1, -1)) != Vector2i(3, 2):
		_fail("Commander-support runtime context should bind the nearest unresolved interaction objective cell.")
		return

	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "wait":
		_fail("Commander-support should hold a claimed interaction objective instead of leaving it.")
		return

	await _despawn_node(battle)

func _assert_commander_support_approaches_interaction_objective() -> void:
	var battle = await _spawn_battle(_make_commander_objective_approach_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var runtime_context: Dictionary = battle._build_enemy_ai_runtime_context(enemy)
	if runtime_context.get("objective_cell", Vector2i(-1, -1)) != Vector2i(3, 2):
		_fail("Commander-support approach stage should still bind the nearest unresolved interaction objective cell.")
		return

	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_wait":
		_fail("Commander-support should approach an unclaimed interaction objective before chasing distant targets.")
		return
	if action.get("move_to", Vector2i(-1, -1)) != Vector2i(3, 2):
		_fail("Commander-support should bias movement toward the interaction objective cell.")
		return

	await _despawn_node(battle)

func _assert_shield_guard_holds_interaction_objective() -> void:
	var battle = await _spawn_battle(_make_guard_objective_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var runtime_context: Dictionary = battle._build_enemy_ai_runtime_context(enemy)
	if runtime_context.get("objective_cell", Vector2i(-1, -1)) != Vector2i(3, 2):
		_fail("Shield-guard runtime context should bind the nearest unresolved interaction objective cell.")
		return

	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "wait":
		_fail("Shield-guard should hold a claimed interaction objective instead of leaving it.")
		return

	await _despawn_node(battle)

func _assert_shield_guard_approaches_interaction_objective() -> void:
	var battle = await _spawn_battle(_make_guard_objective_approach_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var runtime_context: Dictionary = battle._build_enemy_ai_runtime_context(enemy)
	if runtime_context.get("objective_cell", Vector2i(-1, -1)) != Vector2i(3, 2):
		_fail("Shield-guard approach stage should still bind the nearest unresolved interaction objective cell.")
		return

	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_wait":
		_fail("Shield-guard should approach an unclaimed interaction objective before chasing distant targets.")
		return
	if action.get("move_to", Vector2i(-1, -1)) != Vector2i(3, 2):
		_fail("Shield-guard should bias movement toward the interaction objective cell.")
		return

	await _despawn_node(battle)

func _assert_commander_support_retargets_next_objective_after_resolution() -> void:
	var battle = await _spawn_battle(_make_commander_objective_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var ally = battle.ally_units[0]
	battle._resolve_interaction(ally, battle.interactive_objects[0])
	await process_frame

	var runtime_context: Dictionary = battle._build_enemy_ai_runtime_context(enemy)
	if runtime_context.get("objective_cell", Vector2i(-1, -1)) != Vector2i(5, 2):
		_fail("Commander-support should retarget the next unresolved interaction objective after the first resolves.")
		return

	await _despawn_node(battle)

func _assert_shield_guard_retargets_next_objective_after_resolution() -> void:
	var battle = await _spawn_battle(_make_guard_objective_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var ally = battle.ally_units[0]
	battle._resolve_interaction(ally, battle.interactive_objects[0])
	await process_frame

	var runtime_context: Dictionary = battle._build_enemy_ai_runtime_context(enemy)
	if runtime_context.get("objective_cell", Vector2i(-1, -1)) != Vector2i(5, 2):
		_fail("Shield-guard should retarget the next unresolved interaction objective after the first resolves.")
		return

	await _despawn_node(battle)

func _assert_runtime_context_exposes_last_seen_cells_for_stealth_targets() -> void:
	var battle = await _spawn_battle(_make_last_seen_stealth_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var ally = battle.ally_units[0]
	ally.set_status_visual_state({"stealth_turns": 2})
	battle._last_visible_ally_cells_by_unit_id[String(ally.unit_data.unit_id)] = Vector2i(4, 2)

	var runtime_context: Dictionary = battle._build_enemy_ai_runtime_context(enemy)
	var last_seen_cells: Dictionary = runtime_context.get("last_seen_cells", {})
	if last_seen_cells.get(String(ally.unit_data.unit_id), Vector2i(-1, -1)) != Vector2i(4, 2):
		_fail("Battle runtime context should expose the cached last-seen ally cell for stealth-aware AI.")
		return

	await _despawn_node(battle)

func _assert_enemy_uses_runtime_context_last_seen_cell_in_battle() -> void:
	var battle = await _spawn_battle(_make_last_seen_stealth_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var ally = battle.ally_units[0]
	ally.set_status_visual_state({"stealth_turns": 2})
	battle._last_visible_ally_cells_by_unit_id[String(ally.unit_data.unit_id)] = Vector2i(4, 2)

	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_wait":
		_fail("Enemy AI should fall back to a guarded move when only the cached last-seen stealth cell is available.")
		return
	if action.get("move_to", Vector2i(-1, -1)) != Vector2i(4, 2):
		_fail("Enemy AI should advance to the cached last-seen stealth attack tile in live battle context.")
		return

	await _despawn_node(battle)

func _assert_sleeping_enemy_waits_in_live_battle() -> void:
	var battle = await _spawn_battle(_make_status_response_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	enemy.set_status_visual_state({"sleep_turns": 1})
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "wait":
		_fail("Sleeping enemy should always wait in live battle context.")
		return

	await _despawn_node(battle)

func _assert_sealed_commander_reduces_commitment_in_live_battle() -> void:
	var battle = await _spawn_battle(_make_status_response_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	enemy.unit_data.unit_id = &"enemy_commander_contract"
	enemy.set_status_visual_state({"seal_turns": 1})
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_wait":
		_fail("Sealed commander-support should reduce offensive commitment in live battle context.")
		return
	if action.get("move_to", Vector2i(-1, -1)) != enemy.grid_position:
		_fail("Sealed commander-support should hold position instead of committing to an attack tile.")
		return

	await _despawn_node(battle)

func _assert_feared_enemy_advances_cautiously_in_live_battle() -> void:
	var battle = await _spawn_battle(_make_status_response_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	enemy.set_status_visual_state({"fear_turns": 1})
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_wait":
		_fail("Feared enemy should switch to cautious movement in live battle context.")
		return
	if action.get("move_to", Vector2i(-1, -1)) != Vector2i(1, 2):
		_fail("Feared enemy should stop one tile short of the attack commitment in live battle context.")
		return

	await _despawn_node(battle)

func _assert_wake_caution_enemy_advances_cautiously_in_live_battle() -> void:
	var battle = await _spawn_battle(_make_status_response_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	enemy.set_status_visual_state({"wake_caution_turns": 1})
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_wait":
		_fail("Recently awakened enemy should switch to cautious movement in live battle context.")
		return
	if action.get("move_to", Vector2i(-1, -1)) != Vector2i(1, 2):
		_fail("Recently awakened enemy should stop one tile short of the attack commitment in live battle context.")
		return

	await _despawn_node(battle)

func _assert_silenced_healer_holds_position_in_live_battle() -> void:
	var battle = await _spawn_battle(_make_status_response_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	enemy.unit_data.unit_id = &"enemy_chanter_contract"
	if enemy.unit_data.class_data == null:
		var class_data = CLASS_DATA_SCRIPT.new()
		class_data.class_id = &"cls_mystic"
		class_data.display_name = "Mystic"
		enemy.unit_data.class_data = class_data
	enemy.set_status_visual_state({"silence_turns": 1})
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_wait":
		_fail("Silenced healer should reduce offensive commitment in live battle context.")
		return
	if action.get("move_to", Vector2i(-1, -1)) != enemy.grid_position:
		_fail("Silenced healer should hold position instead of committing to an attack tile.")
		return

	await _despawn_node(battle)

func _assert_black_hound_detects_stealth_in_live_battle() -> void:
	var battle = await _spawn_battle(_make_status_response_stage())
	if battle == null:
		return

	var enemy = battle.enemy_units[0]
	var ally = battle.ally_units[0]
	enemy.unit_data.unit_id = &"enemy_black_hound_contract"
	ally.set_status_visual_state({"stealth_turns": 2})
	var action: Dictionary = battle._pick_enemy_action(enemy)
	if String(action.get("type", "")) != "move_attack" and String(action.get("type", "")) != "attack":
		_fail("Black-hound should keep an offensive action when a stealthed target is detectable in live battle context.")
		return
	if action.get("target", null) != ally:
		_fail("Black-hound should detect and target the stealthed ally in live battle context.")
		return

	await _despawn_node(battle)

func _assert_final_attack_triggers_victory_immediately() -> void:
	var battle = await _spawn_battle(_make_final_attack_victory_stage())
	if battle == null:
		return

	var ally = battle.ally_units[0]
	var enemy = battle.enemy_units[0]

	battle._on_world_cell_pressed(ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(enemy.grid_position)
	await process_frame

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("Final enemy defeat should transition to victory immediately after the attack resolves.")
		return

	await _despawn_node(battle)

func _assert_final_interaction_triggers_victory_immediately() -> void:
	var battle = await _spawn_battle(_make_final_interaction_victory_stage())
	if battle == null:
		return

	var ally = battle.ally_units[0]
	var object_actor = battle.interactive_objects[0]

	battle._on_world_cell_pressed(ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(object_actor.grid_position)
	await process_frame

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("Final objective interaction should transition to victory immediately after resolution.")
		return

	await _despawn_node(battle)

func _assert_final_counterattack_triggers_defeat_immediately() -> void:
	var battle = await _spawn_battle(_make_final_counterattack_defeat_stage())
	if battle == null:
		return

	var ally = battle.ally_units[0]
	var enemy = battle.enemy_units[0]

	battle._on_world_cell_pressed(ally.grid_position)
	await process_frame
	battle._on_world_cell_pressed(enemy.grid_position)
	await process_frame

	if int(battle.current_phase) != int(battle.BattlePhase.DEFEAT):
		_fail("Final ally death on counterattack should transition to defeat immediately after resolution.")
		return

	await _despawn_node(battle)

func _spawn_battle(stage = null):
	var battle = BATTLE_SCENE.instantiate()
	if stage != null:
		battle.stage_data = stage
	root.add_child(battle)
	await process_frame
	await process_frame
	return battle

func _make_object_blocking_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"blocking_object_stage"
	stage.stage_title = "Blocking Object Contract"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(ALLY_VANGUARD)
	stage.ally_units.append(ALLY_SCOUT)
	stage.enemy_units.append(ENEMY_RAIDER)
	stage.ally_spawns.append(Vector2i(1, 2))
	stage.ally_spawns.append(Vector2i(1, 4))
	stage.enemy_spawns.append(Vector2i(4, 4))
	stage.win_condition = &"defeat_all_enemies"

	var lever = INTERACTIVE_OBJECT_DATA_SCRIPT.new()
	lever.object_id = &"contract_lever"
	lever.display_name = "Contract Lever"
	lever.object_type = "lever"
	lever.grid_position = Vector2i(2, 2)
	lever.interaction_range = 1
	lever.blocks_movement_while_active = false
	lever.blocks_movement_when_resolved = true
	lever.one_time_use = true
	lever.interaction_text = "Lever engaged."
	stage.interactive_objects.append(lever)

	return stage

func _make_interaction_approach_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"interaction_approach_stage"
	stage.stage_title = "Interaction Approach Contract"
	stage.grid_size = Vector2i(6, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(ALLY_SCOUT)
	stage.ally_units.append(ALLY_VANGUARD)
	stage.enemy_units.append(ENEMY_RAIDER)
	stage.ally_spawns.append(Vector2i(1, 2))
	stage.ally_spawns.append(Vector2i(4, 3))
	stage.enemy_spawns.append(Vector2i(5, 4))
	stage.win_condition = &"defeat_all_enemies"

	var chest = INTERACTIVE_OBJECT_DATA_SCRIPT.new()
	chest.object_id = &"contract_supply_chest"
	chest.display_name = "Contract Supply Chest"
	chest.object_type = "chest"
	chest.grid_position = Vector2i(4, 2)
	chest.interaction_range = 1
	chest.one_time_use = true
	chest.reward_text = "Contract chest opened."
	stage.interactive_objects.append(chest)

	return stage

func _make_sealed_enemy_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"sealed_enemy_stage"
	stage.stage_title = "Sealed Enemy Contract"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(ALLY_VANGUARD)
	stage.enemy_units.append(ENEMY_RAIDER)
	stage.ally_spawns.append(Vector2i(4, 4))
	stage.enemy_spawns.append(Vector2i(0, 0))
	stage.blocked_cells.append(Vector2i(1, 0))
	stage.blocked_cells.append(Vector2i(0, 1))
	stage.win_condition = &"defeat_all_enemies"
	return stage

func _make_move_attack_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"move_attack_stage"
	stage.stage_title = "Move Attack Contract"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(ALLY_VANGUARD)
	stage.enemy_units.append(ENEMY_RAIDER)
	stage.ally_spawns.append(Vector2i(3, 2))
	stage.enemy_spawns.append(Vector2i(0, 2))
	stage.win_condition = &"defeat_all_enemies"
	return stage

func _make_commander_objective_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"commander_objective_stage"
	stage.stage_title = "Commander Objective Contract"
	stage.grid_size = Vector2i(7, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(_make_unit_data(&"contract_ally_objective", "Contract Ally", "ally", 10, 3, 1, 3, 1))
	stage.enemy_units.append(_make_unit_data(&"enemy_commander_contract", "Enemy Commander", "enemy", 12, 4, 1, 3, 1))
	stage.ally_spawns.append(Vector2i(1, 2))
	stage.enemy_spawns.append(Vector2i(3, 2))
	stage.win_condition = &"resolve_all_interactions"
	stage.interaction_objective_texts = PackedStringArray([
		"Hold both objective points. (0/2)",
		"One objective point is lost. (1/2)",
		"All objective points are resolved. (2/2)"
	])

	var first_objective = INTERACTIVE_OBJECT_DATA_SCRIPT.new()
	first_objective.object_id = &"contract_objective_a"
	first_objective.display_name = "Objective A"
	first_objective.object_type = "lever"
	first_objective.grid_position = Vector2i(3, 2)
	first_objective.interaction_range = 1
	first_objective.one_time_use = true
	stage.interactive_objects.append(first_objective)

	var second_objective = INTERACTIVE_OBJECT_DATA_SCRIPT.new()
	second_objective.object_id = &"contract_objective_b"
	second_objective.display_name = "Objective B"
	second_objective.object_type = "lever"
	second_objective.grid_position = Vector2i(5, 2)
	second_objective.interaction_range = 1
	second_objective.one_time_use = true
	stage.interactive_objects.append(second_objective)
	return stage

func _make_commander_objective_approach_stage():
	var stage = _make_commander_objective_stage()
	stage.stage_id = &"commander_objective_approach_stage"
	stage.stage_title = "Commander Objective Approach Contract"
	stage.enemy_spawns.clear()
	stage.enemy_spawns.append(Vector2i(0, 2))
	stage.ally_units.clear()
	stage.ally_units.append(_make_unit_data(&"contract_far_ally", "Far Ally", "ally", 8, 2, 0, 3, 2))
	stage.ally_spawns.clear()
	stage.ally_spawns.append(Vector2i(6, 2))
	return stage

func _make_guard_objective_stage():
	var stage = _make_commander_objective_stage()
	stage.stage_id = &"guard_objective_stage"
	stage.stage_title = "Guard Objective Contract"
	stage.enemy_units.clear()
	stage.enemy_units.append(_make_unit_data(&"enemy_guard_contract", "Enemy Guard", "enemy", 13, 4, 1, 3, 1))
	return stage

func _make_guard_objective_approach_stage():
	var stage = _make_guard_objective_stage()
	stage.stage_id = &"guard_objective_approach_stage"
	stage.stage_title = "Guard Objective Approach Contract"
	stage.enemy_spawns.clear()
	stage.enemy_spawns.append(Vector2i(0, 2))
	stage.ally_units.clear()
	stage.ally_units.append(_make_unit_data(&"contract_far_ally", "Far Ally", "ally", 8, 2, 0, 3, 2))
	stage.ally_spawns.clear()
	stage.ally_spawns.append(Vector2i(6, 2))
	return stage

func _make_last_seen_stealth_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"last_seen_stealth_stage"
	stage.stage_title = "Last Seen Stealth Contract"
	stage.grid_size = Vector2i(7, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(_make_unit_data(&"contract_stealth_ally", "Stealth Ally", "ally", 8, 3, 0, 3, 1))
	stage.enemy_units.append(_make_unit_data(&"enemy_raider_contract", "Enemy Raider", "enemy", 12, 4, 0, 4, 1))
	stage.ally_spawns.append(Vector2i(5, 2))
	stage.enemy_spawns.append(Vector2i(0, 2))
	stage.win_condition = &"defeat_all_enemies"
	return stage

func _make_status_response_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"status_response_stage"
	stage.stage_title = "Status Response Contract"
	stage.grid_size = Vector2i(6, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(_make_unit_data(&"contract_status_ally", "Status Ally", "ally", 8, 3, 0, 3, 1))
	stage.enemy_units.append(_make_unit_data(&"enemy_raider_contract", "Enemy Raider", "enemy", 12, 4, 0, 4, 1))
	stage.ally_spawns.append(Vector2i(2, 2))
	stage.enemy_spawns.append(Vector2i(0, 2))
	stage.win_condition = &"defeat_all_enemies"
	return stage

func _make_final_attack_victory_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"final_attack_victory_stage"
	stage.stage_title = "Final Attack Victory Contract"
	stage.grid_size = Vector2i(4, 4)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(_make_unit_data(&"contract_ally", "Contract Ally", "ally", 10, 5, 1, 3, 1))
	stage.enemy_units.append(_make_unit_data(&"contract_enemy", "Contract Enemy", "enemy", 1, 1, 0, 3, 1))
	stage.ally_spawns.append(Vector2i(1, 1))
	stage.enemy_spawns.append(Vector2i(2, 1))
	stage.win_condition = &"defeat_all_enemies"
	return stage

func _make_final_interaction_victory_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"final_interaction_victory_stage"
	stage.stage_title = "Final Interaction Victory Contract"
	stage.grid_size = Vector2i(4, 4)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(_make_unit_data(&"contract_ally_interact", "Contract Ally", "ally", 10, 4, 1, 3, 1))
	stage.ally_spawns.append(Vector2i(1, 1))
	stage.win_condition = &"resolve_all_interactions"

	var lever = INTERACTIVE_OBJECT_DATA_SCRIPT.new()
	lever.object_id = &"contract_final_objective"
	lever.display_name = "Final Objective"
	lever.object_type = "lever"
	lever.grid_position = Vector2i(2, 1)
	lever.interaction_range = 1
	lever.one_time_use = true
	stage.interactive_objects.append(lever)
	return stage

func _make_final_counterattack_defeat_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"final_counterattack_defeat_stage"
	stage.stage_title = "Final Counterattack Defeat Contract"
	stage.grid_size = Vector2i(4, 4)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(_make_unit_data(&"contract_fragile_ally", "Fragile Ally", "ally", 1, 1, 0, 3, 1))
	stage.enemy_units.append(_make_unit_data(&"contract_counter_enemy", "Counter Enemy", "enemy", 10, 3, 3, 3, 1))
	stage.ally_spawns.append(Vector2i(1, 1))
	stage.enemy_spawns.append(Vector2i(2, 1))
	stage.win_condition = &"defeat_all_enemies"
	return stage

func _make_one_action_package_stage():
	var stage = STAGE_DATA_SCRIPT.new()
	stage.stage_id = &"one_action_package_stage"
	stage.stage_title = "One Action Package Contract"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units.append(_make_unit_data(&"contract_round_ally", "Round Ally", "ally", 10, 2, 0, 3, 1))
	stage.ally_units.append(_make_unit_data(&"contract_round_support", "Round Support", "ally", 10, 1, 0, 3, 1))
	stage.enemy_units.append(_make_unit_data(&"contract_round_enemy", "Round Enemy", "enemy", 10, 1, 0, 3, 1))
	stage.ally_spawns.append(Vector2i(1, 1))
	stage.ally_spawns.append(Vector2i(0, 4))
	stage.enemy_spawns.append(Vector2i(2, 1))
	stage.win_condition = &"defeat_all_enemies"
	return stage

func _make_unit_data(unit_id: StringName, display_name: String, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int) -> Resource:
	var unit = UNIT_DATA_SCRIPT.new()
	unit.unit_id = unit_id
	unit.display_name = display_name
	unit.faction = faction
	unit.max_hp = hp
	unit.attack = attack
	unit.defense = defense
	unit.movement = movement
	unit.attack_range = attack_range
	unit.default_skill = BASIC_ATTACK
	if String(unit_id).find("commander") != -1 or String(unit_id).find("guard") != -1:
		var class_data = CLASS_DATA_SCRIPT.new()
		class_data.class_id = &"cls_knight"
		class_data.display_name = "Knight"
		unit.class_data = class_data
	return unit

func _despawn_node(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return

	node.queue_free()
	await process_frame
	await process_frame

func _cleanup_root_children() -> void:
	for child in root.get_children():
		if child == null or not is_instance_valid(child):
			continue
		if child == current_scene:
			continue
		child.queue_free()
	await process_frame
	await process_frame

func _wait_until_player_phase_returns(battle) -> void:
	var safety := 0
	while safety < 180:
		var phase: int = int(battle.current_phase)
		if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
			return
		await process_frame
		safety += 1

	_fail("Timed out waiting for player phase to return after manual end turn.")

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
