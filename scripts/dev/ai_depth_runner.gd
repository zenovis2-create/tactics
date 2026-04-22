extends SceneTree

const AIService = preload("res://scripts/battle/ai_service.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const ClassData = preload("res://scripts/data/class_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ai := AIService.new()
	root.add_child(ai)
	var path_service := PathService.new()
	root.add_child(path_service)
	var range_service := RangeService.new()
	root.add_child(range_service)
	await process_frame

	if not _assert_in_range_ai_prefers_lethal_target(ai, path_service, range_service):
		return
	if not _assert_move_attack_ai_prefers_better_damage_target(ai, path_service, range_service):
		return
	if not _assert_threat_aware_ai_prefers_finishing_exposed_attacker(ai, path_service, range_service):
		return
	if not _assert_archer_control_prefers_support_core(ai, path_service, range_service):
		return
	if not _assert_lancer_officer_prefers_ranged_target(ai, path_service, range_service):
		return
	if not _assert_assassin_black_hound_prefers_isolated_target(ai, path_service, range_service):
		return
	if not _assert_shield_guard_prefers_melee_threat(ai, path_service, range_service):
		return
	if not _assert_healer_chanter_prefers_backline_pressure(ai, path_service, range_service):
		return
	if not _assert_commander_support_prefers_threat_control(ai, path_service, range_service):
		return
	if not _assert_fear_reduces_forward_aggression(ai, path_service, range_service):
		return
	if not _assert_silence_forces_healer_chanter_safety(ai, path_service, range_service):
		return
	if not _assert_seal_reduces_commander_support_commitment(ai, path_service, range_service):
		return
	if not _assert_archer_control_prefers_marked_target(ai, path_service, range_service):
		return
	if not _assert_black_hound_prefers_marked_target(ai, path_service, range_service):
		return
	if not _assert_sleep_forces_wait(ai, path_service, range_service):
		return
	if not _assert_wake_caution_reduces_commitment(ai, path_service, range_service):
		return
	if not _assert_non_sensor_ignores_stealthed_target(ai, path_service, range_service):
		return
	if not _assert_black_hound_detects_stealthed_target(ai, path_service, range_service):
		return
	if not _assert_commander_support_holds_objective(ai, path_service, range_service):
		return
	if not _assert_commander_support_approaches_objective(ai, path_service, range_service):
		return
	if not _assert_shield_guard_holds_objective(ai, path_service, range_service):
		return
	if not _assert_shield_guard_approaches_objective(ai, path_service, range_service):
		return
	if not _assert_non_sensor_guards_last_seen_cell(ai, path_service, range_service):
		return

	print("[PASS] ai_depth_runner: AI scoring prefers stronger attack targets without breaking legality.")
	quit(0)

func _assert_in_range_ai_prefers_lethal_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_raider", "enemy", 10, 4, 0, 3, 1, Vector2i(1, 1))
	var tank := _make_actor(&"ally_tank", "ally", 10, 1, 2, 3, 1, Vector2i(1, 2))
	var fragile := _make_actor(&"ally_fragile", "ally", 2, 1, 0, 3, 1, Vector2i(2, 1))
	var action := ai.pick_action(enemy, [tank, fragile], path_service, range_service)
	enemy.queue_free()
	tank.queue_free()
	fragile.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("AI should choose an immediate attack when targets are already in range.")
	var target = action.get("target", null)
	if target != fragile:
		return _fail("AI should prefer the in-range lethal target over the merely nearest durable target.")
	return true

func _assert_move_attack_ai_prefers_better_damage_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_striker", "enemy", 10, 5, 0, 3, 1, Vector2i(0, 2))
	var armored := _make_actor(&"ally_armored", "ally", 10, 1, 4, 3, 1, Vector2i(3, 2))
	var exposed := _make_actor(&"ally_exposed", "ally", 5, 1, 0, 3, 1, Vector2i(3, 3))
	var action := ai.pick_action(enemy, [armored, exposed], path_service, range_service)
	enemy.queue_free()
	armored.queue_free()
	exposed.queue_free()
	if String(action.get("type", "")) != "move_attack":
		return _fail("AI should choose a move-attack plan when an attack tile is reachable this turn.")
	var target = action.get("target", null)
	if target != exposed:
		return _fail("AI should prefer the reachable higher-damage target when choosing a move-attack plan.")
	return true

func _assert_threat_aware_ai_prefers_finishing_exposed_attacker(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_guard", "enemy", 12, 4, 0, 3, 1, Vector2i(2, 2))
	var bruiser := _make_actor(&"ally_bruiser", "ally", 8, 4, 0, 3, 1, Vector2i(2, 3))
	var support := _make_actor(&"ally_support", "ally", 6, 1, 0, 3, 1, Vector2i(3, 2))
	var action := ai.pick_action(enemy, [bruiser, support], path_service, range_service)
	enemy.queue_free()
	bruiser.queue_free()
	support.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Threat-aware AI should still take the immediate legal attack in range.")
	var target = action.get("target", null)
	if target != bruiser:
		return _fail("AI should prefer the exposed higher-threat attacker over the lower-threat nonlethal support unit.")
	return true

func _assert_archer_control_prefers_support_core(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_skirmisher", "enemy", 10, 4, 0, 4, 1, Vector2i(2, 2), &"cls_ranger", "Ranger")
	var bruiser := _make_actor(&"ally_bruiser", "ally", 5, 4, 0, 3, 1, Vector2i(2, 3), &"cls_vanguard", "Vanguard")
	var support_core := _make_actor(&"ally_support_core", "ally", 6, 1, 0, 3, 1, Vector2i(3, 2), &"cls_mystic", "Mystic")
	var action := ai.pick_action(enemy, [bruiser, support_core], path_service, range_service)
	enemy.queue_free()
	bruiser.queue_free()
	support_core.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Archer-control AI should still attack immediately when both targets are already in range.")
	var target = action.get("target", null)
	if target != support_core:
		return _fail("Archer-control AI should prefer support_core targets over front-line bruisers when both are in range.")
	return true

func _assert_lancer_officer_prefers_ranged_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_raider", "enemy", 12, 4, 0, 4, 1, Vector2i(2, 2), &"cls_vanguard", "Vanguard")
	var bruiser := _make_actor(&"ally_bruiser", "ally", 8, 4, 1, 3, 1, Vector2i(2, 3), &"cls_vanguard", "Vanguard")
	var ranged := _make_actor(&"ally_ranged", "ally", 8, 2, 0, 3, 2, Vector2i(3, 2), &"cls_ranger", "Ranger")
	var action := ai.pick_action(enemy, [bruiser, ranged], path_service, range_service)
	enemy.queue_free()
	bruiser.queue_free()
	ranged.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Lancer-officer AI should still attack immediately when both targets are already in range.")
	var target = action.get("target", null)
	if target != ranged:
		return _fail("Lancer-officer AI should pressure ranged backliners over sturdier melee bruisers when both are in range.")
	return true

func _assert_assassin_black_hound_prefers_isolated_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_black_hound", "enemy", 11, 4, 0, 4, 1, Vector2i(2, 2), &"cls_ranger", "Ranger")
	var anchored_bruiser := _make_actor(&"ally_bruiser", "ally", 8, 4, 0, 3, 1, Vector2i(2, 3), &"cls_vanguard", "Vanguard")
	var support_anchor := _make_actor(&"ally_support_anchor", "ally", 7, 1, 0, 3, 1, Vector2i(2, 4), &"cls_mystic", "Mystic")
	var isolated_target := _make_actor(&"ally_isolated", "ally", 8, 3, 0, 3, 1, Vector2i(3, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [anchored_bruiser, support_anchor, isolated_target], path_service, range_service)
	enemy.queue_free()
	anchored_bruiser.queue_free()
	support_anchor.queue_free()
	isolated_target.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Assassin-black-hound AI should still attack immediately when multiple targets are already in range.")
	var target = action.get("target", null)
	if target != isolated_target:
		return _fail("Assassin-black-hound AI should prefer isolated targets over clustered ones when both are in range.")
	return true

func _assert_shield_guard_prefers_melee_threat(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_guardian", "enemy", 13, 4, 1, 3, 1, Vector2i(2, 2), &"cls_knight", "Knight")
	var melee_threat := _make_actor(&"ally_melee_threat", "ally", 8, 3, 1, 3, 1, Vector2i(2, 3), &"cls_vanguard", "Vanguard")
	var ranged_harasser := _make_actor(&"ally_ranged_harasser", "ally", 8, 3, 0, 3, 2, Vector2i(3, 2), &"cls_ranger", "Ranger")
	var action := ai.pick_action(enemy, [melee_threat, ranged_harasser], path_service, range_service)
	enemy.queue_free()
	melee_threat.queue_free()
	ranged_harasser.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Shield-guard AI should still attack immediately when both targets are already in range.")
	var target = action.get("target", null)
	if target != melee_threat:
		return _fail("Shield-guard AI should pin the adjacent melee threat before chasing ranged chip damage.")
	return true

func _assert_healer_chanter_prefers_backline_pressure(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_chanter", "enemy", 10, 4, 0, 3, 1, Vector2i(2, 2), &"cls_mystic", "Mystic")
	var melee_threat := _make_actor(&"ally_melee_threat", "ally", 8, 4, 0, 3, 1, Vector2i(2, 3), &"cls_vanguard", "Vanguard")
	var backline_target := _make_actor(&"ally_backline", "ally", 7, 2, 0, 3, 2, Vector2i(3, 2), &"cls_ranger", "Ranger")
	var action := ai.pick_action(enemy, [melee_threat, backline_target], path_service, range_service)
	enemy.queue_free()
	melee_threat.queue_free()
	backline_target.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Healer-chanter AI should still attack immediately when both targets are already in range.")
	var target = action.get("target", null)
	if target != backline_target:
		return _fail("Healer-chanter AI should pressure the backline target instead of trading into the front-line melee threat.")
	return true

func _assert_commander_support_prefers_threat_control(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_commander", "enemy", 12, 4, 0, 3, 1, Vector2i(2, 2), &"cls_knight", "Knight")
	var high_threat := _make_actor(&"ally_high_threat", "ally", 8, 5, 0, 3, 1, Vector2i(2, 3), &"cls_vanguard", "Vanguard")
	var easy_pick := _make_actor(&"ally_easy_pick", "ally", 2, 1, 0, 3, 1, Vector2i(3, 2), &"cls_mystic", "Mystic")
	var action := ai.pick_action(enemy, [high_threat, easy_pick], path_service, range_service)
	enemy.queue_free()
	high_threat.queue_free()
	easy_pick.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Commander-support AI should still attack immediately when both targets are already in range.")
	var target = action.get("target", null)
	if target != high_threat:
		return _fail("Commander-support AI should control the highest-threat attacker before taking an easy low-impact cleanup.")
	return true

func _assert_fear_reduces_forward_aggression(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_raider", "enemy", 12, 4, 0, 4, 1, Vector2i(0, 2), &"cls_vanguard", "Vanguard")
	enemy.set_status_visual_state({"fear_turns": 1})
	var target := _make_actor(&"ally_front", "ally", 8, 4, 0, 3, 1, Vector2i(3, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [target], path_service, range_service)
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "move_wait":
		return _fail("Feared forward profiles should reduce aggression and avoid immediate move-attack commitments.")
	var move_to: Vector2i = action.get("move_to", Vector2i(-1, -1))
	if move_to == Vector2i(2, 2) or move_to == target.grid_position:
		return _fail("Feared AI should still advance cautiously instead of committing to the attack tile.")
	return true

func _assert_silence_forces_healer_chanter_safety(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_chanter", "enemy", 10, 4, 0, 3, 1, Vector2i(0, 2), &"cls_mystic", "Mystic")
	enemy.set_status_visual_state({"silence_turns": 1})
	var melee_threat := _make_actor(&"ally_melee_threat", "ally", 8, 4, 0, 3, 1, Vector2i(2, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [melee_threat], path_service, range_service)
	enemy.queue_free()
	melee_threat.queue_free()
	if String(action.get("type", "")) != "move_wait":
		return _fail("Silenced healer-chanter should prioritize safety instead of immediate move-attack commitments.")
	return true

func _assert_seal_reduces_commander_support_commitment(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_commander", "enemy", 12, 4, 0, 3, 1, Vector2i(0, 2), &"cls_knight", "Knight")
	enemy.set_status_visual_state({"seal_turns": 1})
	var target := _make_actor(&"ally_front", "ally", 8, 5, 0, 3, 1, Vector2i(2, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [target], path_service, range_service)
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "move_wait":
		return _fail("Sealed commander-support should reduce immediate offensive commitment.")
	return true

func _assert_archer_control_prefers_marked_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_skirmisher", "enemy", 10, 4, 0, 4, 1, Vector2i(2, 2), &"cls_ranger", "Ranger")
	var support_core := _make_actor(&"ally_support_core", "ally", 6, 1, 0, 3, 1, Vector2i(2, 3), &"cls_mystic", "Mystic")
	var marked_bruiser := _make_actor(&"ally_marked_bruiser", "ally", 8, 4, 0, 3, 1, Vector2i(3, 2), &"cls_vanguard", "Vanguard")
	marked_bruiser.set_status_visual_state({"mark_turns": 2})
	var action := ai.pick_action(enemy, [support_core, marked_bruiser], path_service, range_service)
	enemy.queue_free()
	support_core.queue_free()
	marked_bruiser.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Archer-control AI should still attack immediately when marked targets are already in range.")
	var target = action.get("target", null)
	if target != marked_bruiser:
		return _fail("Archer-control AI should prioritize an already marked target over a normal support-core target.")
	return true

func _assert_black_hound_prefers_marked_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_black_hound", "enemy", 11, 4, 0, 4, 1, Vector2i(2, 2), &"cls_ranger", "Ranger")
	var isolated_target := _make_actor(&"ally_isolated", "ally", 8, 3, 0, 3, 1, Vector2i(2, 3), &"cls_vanguard", "Vanguard")
	var marked_target := _make_actor(&"ally_marked", "ally", 8, 2, 0, 3, 1, Vector2i(3, 2), &"cls_ranger", "Ranger")
	marked_target.set_status_visual_state({"mark_turns": 2})
	var action := ai.pick_action(enemy, [isolated_target, marked_target], path_service, range_service)
	enemy.queue_free()
	isolated_target.queue_free()
	marked_target.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Black-hound AI should still attack immediately when marked targets are already in range.")
	var target = action.get("target", null)
	if target != marked_target:
		return _fail("Black-hound AI should prioritize an already marked target over a normal in-range target.")
	return true

func _assert_sleep_forces_wait(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_raider", "enemy", 12, 4, 0, 4, 1, Vector2i(1, 2), &"cls_vanguard", "Vanguard")
	enemy.set_status_visual_state({"sleep_turns": 1})
	var target := _make_actor(&"ally_front", "ally", 8, 4, 0, 3, 1, Vector2i(2, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [target], path_service, range_service)
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "wait":
		return _fail("Sleeping AI should take no action.")
	return true

func _assert_wake_caution_reduces_commitment(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_raider", "enemy", 12, 4, 0, 4, 1, Vector2i(0, 2), &"cls_vanguard", "Vanguard")
	enemy.set_status_visual_state({"wake_caution_turns": 1})
	var target := _make_actor(&"ally_front", "ally", 8, 4, 0, 3, 1, Vector2i(2, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [target], path_service, range_service)
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "move_wait":
		return _fail("Recently awakened AI should favor safety over immediate move-attack commitments.")
	return true

func _assert_non_sensor_ignores_stealthed_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_raider", "enemy", 12, 4, 0, 4, 1, Vector2i(2, 2), &"cls_vanguard", "Vanguard")
	var stealthed := _make_actor(&"ally_stealthed", "ally", 6, 4, 0, 3, 1, Vector2i(2, 3), &"cls_ranger", "Ranger")
	stealthed.set_status_visual_state({"stealth_turns": 2})
	var visible := _make_actor(&"ally_visible", "ally", 7, 2, 0, 3, 1, Vector2i(3, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [stealthed, visible], path_service, range_service)
	enemy.queue_free()
	stealthed.queue_free()
	visible.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Non-sensor AI should still attack a visible in-range target.")
	var target = action.get("target", null)
	if target != visible:
		return _fail("Non-sensor AI should ignore stealthed targets when a visible target exists.")
	return true

func _assert_black_hound_detects_stealthed_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_black_hound", "enemy", 11, 4, 0, 4, 1, Vector2i(2, 2), &"cls_ranger", "Ranger")
	var stealthed := _make_actor(&"ally_stealthed", "ally", 6, 4, 0, 3, 1, Vector2i(2, 3), &"cls_ranger", "Ranger")
	stealthed.set_status_visual_state({"stealth_turns": 2})
	var visible := _make_actor(&"ally_visible", "ally", 7, 2, 0, 3, 1, Vector2i(3, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [stealthed, visible], path_service, range_service)
	enemy.queue_free()
	stealthed.queue_free()
	visible.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("Black-hound AI should still attack immediately when a stealthed target is detectable.")
	var target = action.get("target", null)
	if target != stealthed:
		return _fail("Black-hound AI should detect and prioritize stealthed targets.")
	return true

func _assert_commander_support_holds_objective(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_commander", "enemy", 12, 4, 0, 3, 1, Vector2i(2, 2), &"cls_knight", "Knight")
	var target := _make_actor(&"ally_front", "ally", 8, 4, 0, 3, 1, Vector2i(4, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [target], path_service, range_service, {}, {"objective_cell": Vector2i(2, 2)})
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "wait":
		return _fail("Commander-support should hold a claimed objective instead of vacating it for a chase.")
	return true

func _assert_commander_support_approaches_objective(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(8, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_commander", "enemy", 12, 4, 0, 3, 1, Vector2i(0, 2), &"cls_knight", "Knight")
	var target := _make_actor(&"ally_backline", "ally", 8, 2, 0, 3, 2, Vector2i(7, 2), &"cls_ranger", "Ranger")
	var action := ai.pick_action(enemy, [target], path_service, range_service, {}, {"objective_cell": Vector2i(3, 2)})
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "move_wait":
		return _fail("Commander-support should advance toward an unclaimed objective.")
	var move_to: Vector2i = action.get("move_to", Vector2i(-1, -1))
	if move_to != Vector2i(3, 2):
		return _fail("Commander-support should bias movement toward the objective cell before chasing distant targets.")
	return true

func _assert_shield_guard_holds_objective(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_guardian", "enemy", 13, 4, 1, 3, 1, Vector2i(2, 2), &"cls_knight", "Knight")
	var target := _make_actor(&"ally_front", "ally", 8, 4, 0, 3, 1, Vector2i(4, 2), &"cls_vanguard", "Vanguard")
	var action := ai.pick_action(enemy, [target], path_service, range_service, {}, {"objective_cell": Vector2i(2, 2)})
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "wait":
		return _fail("Shield-guard should hold a frontline objective instead of vacating it for a chase.")
	return true

func _assert_shield_guard_approaches_objective(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(8, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_guardian", "enemy", 13, 4, 1, 3, 1, Vector2i(0, 2), &"cls_knight", "Knight")
	var target := _make_actor(&"ally_backline", "ally", 8, 2, 0, 3, 2, Vector2i(7, 2), &"cls_ranger", "Ranger")
	var action := ai.pick_action(enemy, [target], path_service, range_service, {}, {"objective_cell": Vector2i(3, 2)})
	enemy.queue_free()
	target.queue_free()
	if String(action.get("type", "")) != "move_wait":
		return _fail("Shield-guard should advance toward an unclaimed frontline objective.")
	var move_to: Vector2i = action.get("move_to", Vector2i(-1, -1))
	if move_to != Vector2i(3, 2):
		return _fail("Shield-guard should bias movement toward the objective cell before chasing distant targets.")
	return true

func _assert_non_sensor_guards_last_seen_cell(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_raider", "enemy", 12, 4, 0, 4, 1, Vector2i(0, 2), &"cls_vanguard", "Vanguard")
	var stealthed := _make_actor(&"ally_stealthed", "ally", 8, 3, 0, 3, 1, Vector2i(5, 2), &"cls_ranger", "Ranger")
	stealthed.set_status_visual_state({"stealth_turns": 2})
	var action := ai.pick_action(enemy, [stealthed], path_service, range_service, {}, {"last_seen_cells": {str(stealthed.get_instance_id()): Vector2i(4, 2)}})
	enemy.queue_free()
	stealthed.queue_free()
	if String(action.get("type", "")) != "move_wait":
		return _fail("Non-sensor AI should guard the last seen stealth position instead of idling.")
	var move_to: Vector2i = action.get("move_to", Vector2i(-1, -1))
	if move_to != Vector2i(3, 2):
		return _fail("Non-sensor AI should advance toward the last seen stealth guard cell.")
	return true

func _make_actor(unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int, grid_position: Vector2i, class_id: StringName = &"", class_label: String = "") -> UnitActor:
	var actor := UnitActor.new()
	actor.unit_data = _make_unit_data(unit_id, faction, hp, attack, defense, movement, attack_range, class_id, class_label)
	actor.faction = faction
	actor.current_hp = hp
	actor.grid_position = grid_position
	return actor

func _make_unit_data(unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int, class_id: StringName = &"", class_label: String = "") -> UnitData:
	var unit_data := UnitData.new()
	unit_data.unit_id = unit_id
	unit_data.display_name = String(unit_id)
	unit_data.faction = faction
	unit_data.max_hp = hp
	unit_data.attack = attack
	unit_data.defense = defense
	unit_data.movement = movement
	unit_data.attack_range = attack_range
	if class_id != &"" or not class_label.is_empty():
		var class_data := ClassData.new()
		class_data.class_id = class_id if class_id != &"" else &"class"
		class_data.display_name = class_label if not class_label.is_empty() else String(class_data.class_id)
		unit_data.class_data = class_data
	return unit_data

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
