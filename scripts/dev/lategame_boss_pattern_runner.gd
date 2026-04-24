extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH08_05_STAGE = preload("res://data/stages/ch08_05_stage.tres")
const CH09A_05_STAGE = preload("res://data/stages/ch09a_05_stage.tres")
const CH09B_05_STAGE = preload("res://data/stages/ch09b_05_stage.tres")
const CH10_05_STAGE = preload("res://data/stages/ch10_05_stage.tres")

const EXPECTED_RULE_TEMPLATES := {
	&"CH08_05": &"lete_route_cut",
	&"CH09B_05": &"melkion_archive_relief",
	&"CH10_05": &"karon_bell_pressure",
}

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_lete_phase_proxy():
		return
	if not await _assert_lete_battlefield_rewrite():
		return
	if not await _assert_lete_gate_latch_relief():
		return
	if not await _assert_lete_gate_latch_ai_shift():
		return
	if not await _assert_lete_gate_latch_boss_debuff():
		return
	if not await _assert_lete_gate_latch_objective_surface():
		return
	if not await _assert_lete_gate_latch_transition_surface():
		return
	if not await _assert_lete_gate_latch_objective_hint_shift():
		return
	if not await _assert_lete_gate_latch_objective_text_shift():
		return
	if not await _assert_lete_gate_latch_inventory_objective_shift():
		return
	if not await _assert_lete_gate_latch_result_relief_entry():
		return
	if not await _assert_lete_gate_latch_objective_state_relief():
		return
	if not await _assert_lete_gate_latch_rewrite_dampen():
		return
	if not await _assert_lete_execute_pressure():
		return
	if not await _assert_kyle_testimony_flag():
		return
	if not await _assert_melkion_truth_flag():
		return
	if not await _assert_melkion_battlefield_rewrite():
		return
	if not await _assert_melkion_lectern_relief():
		return
	if not await _assert_melkion_lectern_ai_shift():
		return
	if not await _assert_melkion_lectern_cooldown_lock():
		return
	if not await _assert_melkion_lectern_objective_surface():
		return
	if not await _assert_melkion_lectern_transition_surface():
		return
	if not await _assert_melkion_lectern_objective_hint_shift():
		return
	if not await _assert_melkion_lectern_objective_text_shift():
		return
	if not await _assert_melkion_lectern_inventory_objective_shift():
		return
	if not await _assert_melkion_lectern_result_relief_entry():
		return
	if not await _assert_melkion_lectern_objective_state_relief():
		return
	if not await _assert_melkion_lectern_rewrite_dampen():
		return
	if not await _assert_melkion_revision_sentence():
		return
	if not await _assert_karuon_name_call_flag():
		return
	if not await _assert_karuon_battlefield_pressure():
		return
	if not await _assert_karuon_anchor_chain_relief():
		return
	if not await _assert_karuon_anchor_chain_ai_shift():
		return
	if not await _assert_karuon_anchor_chain_cooldown_lock():
		return
	if not await _assert_karuon_anchor_chain_objective_surface():
		return
	if not await _assert_karuon_anchor_chain_transition_surface():
		return
	if not await _assert_karuon_anchor_chain_objective_hint_shift():
		return
	if not await _assert_karuon_anchor_chain_objective_text_shift():
		return
	if not await _assert_karuon_anchor_chain_inventory_objective_shift():
		return
	if not await _assert_karuon_anchor_chain_result_relief_entry():
		return
	if not await _assert_karuon_anchor_chain_objective_state_relief():
		return
	if not await _assert_karuon_anchor_chain_rewrite_dampen():
		return
	if not await _assert_karuon_final_toll_flag():
		return
	if not await _assert_karuon_bell_pressure():
		return
	print("[PASS] lategame_boss_pattern_runner: late-game boss pattern checks passed.")
	quit(0)

func _spawn_battle(stage) -> Node:
	var expected_template: StringName = StringName(EXPECTED_RULE_TEMPLATES.get(StringName(stage.stage_id), &""))
	if expected_template != &"" and StringName(stage.rule_template_id) != expected_template:
		_fail("%s should declare rule template %s." % [String(stage.stage_id), String(expected_template)])
		return null
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(stage)
	await process_frame
	await process_frame
	return battle

func _assert_lete_phase_proxy() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var boss = battle.enemy_units[0]
	battle._apply_boss_phase_effects(boss, &"berserk_rush", &"")
	if not bool(battle.battle_objective_flags.get("lete_defects_alive", false)):
		return _fail("CH08_05 should surface lete_defects_alive when berserk_rush proxy triggers.")
	battle._use_lete_scatter_cover(boss)
	if not bool(battle.battle_objective_flags.get("black_hound_scattered", false)):
		return _fail("CH08_05 should surface black_hound_scattered when Lete scatters the hound line.")
	battle._use_lete_shadow_feint(boss)
	if not bool(battle.battle_objective_flags.get("lete_shadow_feint", false)):
		return _fail("CH08_05 should surface lete_shadow_feint when Lete marks a target.")
	var marked_any: bool = false
	var marked_target = null
	for ally in battle.ally_units:
		if ally != null and is_instance_valid(ally):
			if int(battle._get_unit_visual_status_turns(ally, &"mark")) > 0:
				marked_any = true
				marked_target = ally
				break
	if not marked_any:
		return _fail("CH08_05 shadow feint should leave at least one ally in a marked visual state.")
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"berserk_rush"
	var lete_action: Dictionary = battle._ai_action_lete(boss)
	if lete_action.is_empty() or lete_action.get("target", null) != marked_target:
		return _fail("CH08_05 berserk rush should prioritize the marked ally target.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_battlefield_rewrite() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var boss = battle.enemy_units[0]
	battle._apply_boss_phase_effects(boss, &"berserk_rush", &"")
	if String(battle.stage_data.get_terrain_type(Vector2i(4, 4))) != "shadow":
		return _fail("CH08_05 berserk_rush should rewrite the central pursuit lane into shadow terrain.")
	if battle.stage_data.blocked_cells.has(Vector2i(3, 3)):
		return _fail("CH08_05 berserk_rush should open at least one blocked pursuit cell.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_relief() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	battle._set_unit_visual_status(ally, &"mark", 2)
	battle._set_unit_visual_status(ally, &"fear", 1)
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if not bool(battle.battle_objective_flags.get("ch08_05_transfer_gate_latch", false)):
		return _fail("CH08_05 gate latch should set its control flag when resolved.")
	if battle.stage_data.blocked_cells.has(Vector2i(4, 3)):
		return _fail("CH08_05 gate latch should open part of the pursuit choke.")
	if not bool(battle.battle_objective_flags.get("lete_escape_route_cut", false)):
		return _fail("CH08_05 gate latch should surface the escape route cut flag.")
	if int(battle._get_unit_visual_status_turns(ally, &"mark")) > 0 or int(battle._get_unit_visual_status_turns(ally, &"fear")) > 0:
		return _fail("CH08_05 gate latch should clear current pursuit mark/fear pressure from the interacting ally.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_ai_shift() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"berserk_rush"
	var action: Dictionary = battle._ai_action_lete(boss)
	if String(action.get("type", "")) != "lete_shadow_feint":
		return _fail("CH08_05 gate latch relief should force Lete to rebuild pressure with shadow_feint instead of immediate execution.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_boss_debuff() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	battle.enemy_movement_bonus_by_unit[boss.get_instance_id()] = 2
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if int(battle.enemy_movement_bonus_by_unit.get(boss.get_instance_id(), 0)) > 0:
		return _fail("CH08_05 gate latch should strip Lete's temporary movement pressure bonuses.")
	if battle._get_enemy_skill_cooldown(boss, &"smoke_bomb") <= 0:
		return _fail("CH08_05 gate latch should delay Lete's smoke_bomb reset window.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_objective_surface() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if not bool(battle.battle_objective_flags.get("lete_hunt_collapsing", false)):
		return _fail("CH08_05 gate latch should surface lete_hunt_collapsing as an explicit objective-state flag.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_transition_surface() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.transition_reason_label.text).find("Lete Route Cut") == -1:
		return _fail("CH08_05 gate latch should surface a dedicated route-cut transition reason.")
	if String(battle.hud.telegraph_label.text).find("Route Cut") == -1:
		return _fail("CH08_05 gate latch should surface a dedicated route-cut telegraph label.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_objective_hint_shift() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.objective_hint_label.text).find("깊은 추격선") == -1:
		return _fail("CH08_05 gate latch should rewrite the objective hint toward the weakened pursuit state.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_objective_text_shift() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.objective_label.text).find("표식 재설정 차단") == -1:
		return _fail("CH08_05 gate latch should rewrite the objective text toward the weakened pursuit objective.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_inventory_objective_shift() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.inventory_objective_label.text).find("표식 재설정 차단") == -1:
		return _fail("CH08_05 gate latch should rewrite the inventory objective line toward the weakened pursuit objective.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_result_relief_entry() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	battle.enemy_units.clear()
	if not battle._check_battle_end():
		return _fail("CH08_05 gate latch result relief test expected forced victory to resolve.")
	var summary: Dictionary = battle.get_last_result_summary()
	if not _array_contains(summary.get("control_relief_entries", []), "레테 추격선 약화"):
		return _fail("CH08_05 result summary should surface the Lete route-cut relief entry.")
	if String(battle.hud.result_popup.dialog_text).find("Control Relief") == -1 or String(battle.hud.result_popup.dialog_text).find("레테 추격선 약화") == -1:
		return _fail("CH08_05 result popup should render the Lete control relief section.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_objective_state_relief() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	var objective_state: Dictionary = battle.get_objective_state_snapshot()
	if String(objective_state.get("state_id", "")).find("lete_route_cut_relief") == -1:
		return _fail("CH08_05 gate latch should rewrite objective_state toward a dedicated relief state id.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_gate_latch_rewrite_dampen() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	battle._apply_boss_phase_effects(boss, &"berserk_rush", &"")
	if String(battle.stage_data.get_terrain_type(Vector2i(4, 4))) != "shadow":
		return _fail("CH08_05 gate latch should still leave a weakened shadow lane at the front pursuit cell.")
	if String(battle.stage_data.get_terrain_type(Vector2i(5, 5))) == "shadow":
		return _fail("CH08_05 gate latch should keep the deeper pursuit cell from being rewritten once the route is cut.")
	battle.queue_free()
	await process_frame
	return true

func _assert_lete_execute_pressure() -> bool:
	var battle = await _spawn_battle(CH08_05_STAGE)
	var boss = battle.enemy_units[0]
	var marked_target = battle.ally_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"berserk_rush"
	battle._set_unit_visual_status(marked_target, &"mark", 2)
	var action: Dictionary = battle._ai_action_lete(boss)
	if String(action.get("type", "")) != "lete_black_hound_execute":
		return _fail("CH08_05 berserk rush should choose lete_black_hound_execute when a marked ally is exposed.")
	battle._use_lete_black_hound_execute(boss, marked_target)
	if not bool(battle.battle_objective_flags.get("lete_black_hound_execute", false)):
		return _fail("CH08_05 should surface lete_black_hound_execute when Lete commits the execute pressure.")
	if int(battle._get_unit_visual_status_turns(marked_target, &"fear")) <= 0:
		return _fail("CH08_05 execute pressure should leave the marked ally in a fear state.")
	battle.queue_free()
	await process_frame
	return true

func _assert_kyle_testimony_flag() -> bool:
	var battle = await _spawn_battle(CH09A_05_STAGE)
	var boss = battle.enemy_units[0]
	battle._use_karl_formation_call(boss)
	if not bool(battle.battle_objective_flags.get("karl_testifies", false)):
		return _fail("CH09A_05 should surface karl_testifies when Kyle enters formation call testimony state.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_truth_flag() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var boss = battle.enemy_units[0]
	battle._apply_boss_phase_effects(boss, &"archive_mode", &"")
	if not bool(battle.battle_objective_flags.get("melkion_truth_revealed", false)):
		return _fail("CH09B_05 should surface melkion_truth_revealed when archive_mode triggers.")
	if not bool(battle.battle_objective_flags.get("noah_survives", false)):
		return _fail("CH09B_05 should start with the noah_survives proxy enabled.")
	battle._use_melkion_revision_field(boss)
	if not bool(battle.battle_objective_flags.get("melkion_revision_field", false)):
		return _fail("CH09B_05 should surface melkion_revision_field when Melkion marks the party.")
	for ally in battle.ally_units:
		if ally == null or not is_instance_valid(ally):
			continue
		if int(battle.ignored_terrain_turns_by_unit.get(ally.get_instance_id(), 0)) <= 0:
			return _fail("CH09B_05 revision field should temporarily strip ally terrain reliance.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_battlefield_rewrite() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var boss = battle.enemy_units[0]
	battle._apply_boss_phase_effects(boss, &"archive_mode", &"")
	if String(battle.stage_data.get_terrain_type(Vector2i(3, 2))) != "revision":
		return _fail("CH09B_05 archive_mode should rewrite archive tiles into revision terrain.")
	if int(battle.stage_data.terrain_move_costs.get(Vector2i(3, 2), 0)) < 2:
		return _fail("CH09B_05 archive_mode should raise movement cost on rewritten revision terrain.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_relief() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	battle._use_melkion_revision_field(boss)
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if not bool(battle.battle_objective_flags.get("ch09b_05_archive_lectern", false)):
		return _fail("CH09B_05 archive lectern should set its control flag when resolved.")
	if String(battle.stage_data.get_terrain_type(Vector2i(4, 2))) != "plain":
		return _fail("CH09B_05 archive lectern should clear one rewritten revision tile back to plain.")
	if not bool(battle.battle_objective_flags.get("melkion_archive_destabilized", false)):
		return _fail("CH09B_05 archive lectern should surface the archive destabilized flag.")
	if int(battle._get_unit_visual_status_turns(ally, &"mark")) > 0:
		return _fail("CH09B_05 archive lectern should clear current revision mark pressure from the interacting ally.")
	if int(battle.ignored_terrain_turns_by_unit.get(ally.get_instance_id(), 0)) > 0:
		return _fail("CH09B_05 archive lectern should restore terrain reliance for the interacting ally.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_ai_shift() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"archive_mode"
	var action: Dictionary = battle._ai_action_melkion(boss)
	if String(action.get("type", "")) == "melkion_revision_sentence" or String(action.get("type", "")) == "melkion_revision_field":
		return _fail("CH09B_05 archive lectern relief should prevent Melkion from immediately returning to the revision loop.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_cooldown_lock() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if battle._get_enemy_skill_cooldown(boss, &"truth_rewrite") <= 0:
		return _fail("CH09B_05 archive lectern should lock out truth_rewrite for a few turns.")
	if battle._get_enemy_skill_cooldown(boss, &"true_read") <= 0:
		return _fail("CH09B_05 archive lectern should lock out true_read/revision setup for a few turns.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_objective_surface() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if not bool(battle.battle_objective_flags.get("melkion_archive_stabilized", false)):
		return _fail("CH09B_05 archive lectern should surface melkion_archive_stabilized as an explicit objective-state flag.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_transition_surface() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.transition_reason_label.text).find("Archive Stabilized") == -1:
		return _fail("CH09B_05 archive lectern should surface a dedicated archive-stabilized transition reason.")
	if String(battle.hud.telegraph_label.text).find("Archive Stable") == -1:
		return _fail("CH09B_05 archive lectern should surface a dedicated archive-stable telegraph label.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_objective_hint_shift() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.objective_hint_label.text).find("중앙 archive tile") == -1:
		return _fail("CH09B_05 archive lectern should rewrite the objective hint toward the stabilized archive center.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_objective_text_shift() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.objective_label.text).find("archive center 유지") == -1:
		return _fail("CH09B_05 archive lectern should rewrite the objective text toward the stabilized archive objective.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_inventory_objective_shift() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if String(battle.hud.inventory_objective_label.text).find("archive center 유지") == -1:
		return _fail("CH09B_05 archive lectern should rewrite the inventory objective line toward the stabilized archive objective.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_result_relief_entry() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	battle.enemy_units.clear()
	if not battle._check_battle_end():
		return _fail("CH09B_05 lectern result relief test expected forced victory to resolve.")
	var summary: Dictionary = battle.get_last_result_summary()
	if not _array_contains(summary.get("control_relief_entries", []), "기록보관소 안정화"):
		return _fail("CH09B_05 result summary should surface the archive stabilization relief entry.")
	if String(battle.hud.result_popup.dialog_text).find("Control Relief") == -1 or String(battle.hud.result_popup.dialog_text).find("기록보관소 안정화") == -1:
		return _fail("CH09B_05 result popup should render the archive stabilization relief section.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_objective_state_relief() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	var objective_state: Dictionary = battle.get_objective_state_snapshot()
	if String(objective_state.get("state_id", "")).find("archive_stable_relief") == -1:
		return _fail("CH09B_05 archive lectern should rewrite objective_state toward a dedicated archive relief state id.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_lectern_rewrite_dampen() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var object_actor = battle.interactive_objects[0]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	battle._apply_boss_phase_effects(boss, &"archive_mode", &"")
	if String(battle.stage_data.get_terrain_type(Vector2i(3, 2))) != "revision":
		return _fail("CH09B_05 archive lectern should still leave a weakened revision lane on one archive flank.")
	if String(battle.stage_data.get_terrain_type(Vector2i(4, 2))) == "revision":
		return _fail("CH09B_05 archive lectern should keep the central archive tile stable after the rewrite is dampened.")
	battle.queue_free()
	await process_frame
	return true

func _assert_melkion_revision_sentence() -> bool:
	var battle = await _spawn_battle(CH09B_05_STAGE)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"archive_mode"
	battle._use_melkion_revision_field(boss)
	var action: Dictionary = battle._ai_action_melkion(boss)
	if String(action.get("type", "")) != "melkion_revision_sentence":
		return _fail("CH09B_05 archive mode should choose melkion_revision_sentence after the field rewrite marks the party.")
	battle._use_melkion_revision_sentence(boss)
	if not bool(battle.battle_objective_flags.get("melkion_revision_sentence", false)):
		return _fail("CH09B_05 should surface melkion_revision_sentence when Melkion seals the rewritten field.")
	for ally in battle.ally_units:
		if ally == null or not is_instance_valid(ally):
			continue
		if int(battle.bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)) <= 0:
			return _fail("CH09B_05 revision sentence should suppress ally bond surfaces for at least one turn.")
		if int(battle._get_unit_visual_status_turns(ally, &"mark")) <= 0:
			return _fail("CH09B_05 revision sentence should preserve rewritten target marking.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_name_call_flag() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var boss = battle.enemy_units[0]
	battle._check_boss_special_events(boss, 75.0)
	if not bool(battle.battle_objective_flags.get("all_allies_name_called", false)):
		return _fail("CH10_05 should surface all_allies_name_called when the name-call anchor spawns with the party alive.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_battlefield_pressure() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var boss = battle.enemy_units[0]
	battle._apply_boss_phase_effects(boss, &"name_severance", &"royal_edict")
	if String(battle.stage_data.get_terrain_type(Vector2i(6, 6))) != "bell":
		return _fail("CH10_05 name_severance should stamp a bell pressure lane across the central approach.")
	if not battle.stage_data.blocked_cells.has(Vector2i(10, 6)):
		return _fail("CH10_05 name_severance should add a choke cell to compress the central push.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_relief() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var object_actor = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"name_severance"
	battle._set_unit_visual_status(ally, &"mark", 2)
	battle.bond_suppression_turns_by_unit[ally.get_instance_id()] = 2
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	if not bool(battle.battle_objective_flags.get("ch10_05_anchor_chain", false)):
		return _fail("CH10_05 anchor chain should set its control flag when resolved.")
	if battle.stage_data.blocked_cells.has(Vector2i(10, 6)):
		return _fail("CH10_05 anchor chain should release the added bell choke.")
	if not bool(battle.battle_objective_flags.get("karon_bell_line_broken", false)):
		return _fail("CH10_05 anchor chain should surface the bell line broken flag.")
	if int(battle._get_unit_visual_status_turns(ally, &"mark")) > 0:
		return _fail("CH10_05 anchor chain should clear current bell mark pressure from the interacting ally.")
	if int(battle.bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)) > 0:
		return _fail("CH10_05 anchor chain should clear current bond suppression from the interacting ally.")
	battle._set_unit_visual_status(ally, &"mark", 2)
	var action: Dictionary = battle._ai_action_karon(boss)
	if String(action.get("type", "")) == "karon_bell_of_erasure":
		return _fail("CH10_05 anchor chain relief should stop Karuon from preferring bell_of_erasure while the chain remains broken.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_ai_shift() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var object_actor = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, object_actor)
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"final_toll"
	var action: Dictionary = battle._ai_action_karon(boss)
	if String(action.get("type", "")) == "karon_final_toll":
		return _fail("CH10_05 anchor chain relief should stop Karuon from preferring final_toll while the bell line is broken.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_cooldown_lock() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var bell_dais = battle.interactive_objects[0]
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(bell_dais.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, bell_dais)
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	if battle._get_enemy_skill_cooldown(boss, &"name_severance") <= 0:
		return _fail("CH10_05 anchor chain should delay name_severance once the bell line is broken.")
	if battle._get_enemy_skill_cooldown(boss, &"all_out_attack") <= 0:
		return _fail("CH10_05 anchor chain should delay final_toll once the bell line is broken.")
	if not bool(battle.battle_objective_flags.get("karon_cut_off", false)):
		return _fail("CH10_05 should surface karon_cut_off when both final control points are secured.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_objective_surface() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var bell_dais = battle.interactive_objects[0]
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	ally.set_grid_position(bell_dais.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, bell_dais)
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	if not bool(battle.battle_objective_flags.get("karon_cut_off", false)):
		return _fail("CH10_05 should surface karon_cut_off once both final control objects are secured.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_transition_surface() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	if String(battle.hud.transition_reason_label.text).find("Bell Line Broken") == -1:
		return _fail("CH10_05 anchor chain should surface a dedicated bell-line-broken transition reason.")
	if String(battle.hud.telegraph_label.text).find("Bell Line") == -1:
		return _fail("CH10_05 anchor chain should surface a dedicated bell-line telegraph label.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_objective_hint_shift() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	if String(battle.hud.objective_hint_label.text).find("bell choke") == -1:
		return _fail("CH10_05 anchor chain should rewrite the objective hint toward the opened bell line.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_objective_text_shift() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	if String(battle.hud.objective_label.text).find("bell line 유지") == -1:
		return _fail("CH10_05 anchor chain should rewrite the objective text toward the opened central push objective.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_inventory_objective_shift() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	if String(battle.hud.inventory_objective_label.text).find("bell line 유지") == -1:
		return _fail("CH10_05 anchor chain should rewrite the inventory objective line toward the opened central push objective.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_result_relief_entry() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var bell_dais = battle.interactive_objects[0]
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	ally.set_grid_position(bell_dais.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, bell_dais)
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	battle.enemy_units.clear()
	if not battle._check_battle_end():
		return _fail("CH10_05 anchor chain result relief test expected forced victory to resolve.")
	var summary: Dictionary = battle.get_last_result_summary()
	if not _array_contains(summary.get("control_relief_entries", []), "종선 개방"):
		return _fail("CH10_05 result summary should surface the bell-line relief entry.")
	if String(battle.hud.result_popup.dialog_text).find("Control Relief") == -1 or String(battle.hud.result_popup.dialog_text).find("종선 개방") == -1:
		return _fail("CH10_05 result popup should render the bell-line relief section.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_objective_state_relief() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	var objective_state: Dictionary = battle.get_objective_state_snapshot()
	if String(objective_state.get("state_id", "")).find("bell_line_relief") == -1:
		return _fail("CH10_05 anchor chain should rewrite objective_state toward a dedicated bell-line relief state id.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_anchor_chain_rewrite_dampen() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var anchor_chain = battle.interactive_objects[1]
	var ally = battle.ally_units[0]
	var boss = battle.enemy_units[0]
	ally.set_grid_position(anchor_chain.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, anchor_chain)
	battle._apply_boss_phase_effects(boss, &"name_severance", &"royal_edict")
	if battle.stage_data.blocked_cells.has(Vector2i(10, 6)):
		return _fail("CH10_05 anchor chain should keep the bell choke open even if name_severance is re-applied.")
	if int(battle.stage_data.terrain_move_costs.get(Vector2i(6, 6), 0)) > 1:
		return _fail("CH10_05 anchor chain should dampen the bell lane move cost after the chain is broken.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_final_toll_flag() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var boss = battle.enemy_units[0]
	if boss.unit_data.get_boss_phase_for_hp(70.0) != &"royal_edict":
		return _fail("CH10_05 final Karuon should enter royal_edict around 70% HP.")
	if boss.unit_data.get_boss_phase_for_hp(45.0) != &"name_severance":
		return _fail("CH10_05 final Karuon should enter name_severance around 45% HP.")
	if boss.unit_data.get_boss_phase_for_hp(20.0) != &"final_toll":
		return _fail("CH10_05 final Karuon should enter final_toll around 20% HP.")
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"name_severance"
	var marked_ally = battle.ally_units[0]
	battle._set_unit_visual_status(marked_ally, &"mark", 2)
	var phase_action: Dictionary = battle._ai_action_karon(boss)
	if phase_action.is_empty():
		return _fail("CH10_05 name_severance should choose a concrete action.")
	var action_type: String = String(phase_action.get("type", ""))
	if action_type != "karon_name_severance" and action_type != "karon_bell_of_erasure" and phase_action.get("target", null) != marked_ally:
		return _fail("CH10_05 name_severance should either fire its special or prioritize marked allies when choosing attacks.")
	battle._apply_boss_phase_effects(boss, &"final_toll", &"oblivion_resonance")
	battle._use_karon_final_toll(boss)
	if not bool(battle.battle_objective_flags.get("karon_final_toll", false)):
		return _fail("CH10_05 should surface karon_final_toll when the final toll resolves.")
	for ally in battle.ally_units:
		if ally == null or not is_instance_valid(ally):
			continue
		if int(battle.bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)) <= 0:
			return _fail("CH10_05 final toll should suppress ally bond bonuses for at least one turn.")
	battle.queue_free()
	await process_frame
	return true

func _assert_karuon_bell_pressure() -> bool:
	var battle = await _spawn_battle(CH10_05_STAGE)
	var boss = battle.enemy_units[0]
	var marked_ally = battle.ally_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"name_severance"
	battle._set_unit_visual_status(marked_ally, &"mark", 2)
	var action: Dictionary = battle._ai_action_karon(boss)
	if String(action.get("type", "")) != "karon_bell_of_erasure":
		return _fail("CH10_05 should choose karon_bell_of_erasure when name_severance has a marked ally.")
	battle._use_karon_bell_of_erasure(boss)
	if not bool(battle.battle_objective_flags.get("karon_bell_of_erasure", false)):
		return _fail("CH10_05 should surface karon_bell_of_erasure when Karuon escalates name pressure.")
	for ally in battle.ally_units:
		if ally == null or not is_instance_valid(ally):
			continue
		if int(battle.bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)) <= 0:
			return _fail("CH10_05 bell pressure should suppress ally bond surfaces for at least one turn.")
	if int(battle._get_unit_visual_status_turns(marked_ally, &"mark")) <= 0:
		return _fail("CH10_05 bell pressure should keep the exposed ally marked.")
	battle.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false

func _array_contains(values: Variant, needle: String) -> bool:
	if not (values is Array):
		return false
	for value in values:
		if String(value).find(needle) != -1:
			return true
	return false
