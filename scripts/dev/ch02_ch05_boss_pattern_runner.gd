extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH02_05_STAGE = preload("res://data/stages/ch02_05_stage.tres")
const CH03_05_STAGE = preload("res://data/stages/ch03_05_stage.tres")
const CH04_05_STAGE = preload("res://data/stages/ch04_05_stage.tres")
const CH05_05_STAGE = preload("res://data/stages/ch05_05_stage.tres")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_ch02_trap_objective():
		return
	if not await _assert_ch03_shrine_and_tia_flags():
		return
	if not await _assert_ch04_basil_purge_surface():
		return
	if not await _assert_ch05_ledger_objective():
		return
	print("[PASS] ch02_ch05_boss_pattern_runner: chapter boss pattern deepening checks passed.")
	quit(0)

func _spawn_battle(stage) -> Node:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(stage)
	await process_frame
	await process_frame
	return battle

func _assert_ch02_trap_objective() -> bool:
	var battle = await _spawn_battle(CH02_05_STAGE)
	var boss = battle.enemy_units[0]
	for _i in range(3):
		battle._use_hardren_trap_salvo(boss)
	if not bool(battle.battle_objective_flags.get("activate_3_traps", false)):
		return _fail("CH02_05 should complete activate_3_traps after three trap salvos.")
	if int(battle.battle_runtime_counters.get("ch02_trap_salvo_count", 0)) != 3:
		return _fail("CH02_05 trap salvo counter should reach 3.")
	battle.queue_free()
	await process_frame
	return true

func _assert_ch03_shrine_and_tia_flags() -> bool:
	var battle = await _spawn_battle(CH03_05_STAGE)
	var boss = battle.enemy_units[0]
	var scout = battle.ally_units[1]
	if not bool(battle.battle_objective_flags.get("no_structures_destroyed", false)):
		return _fail("CH03_05 should start with no_structures_destroyed enabled.")
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"shrine_burn"
	battle._use_resin_ignition(boss)
	if bool(battle.battle_objective_flags.get("no_structures_destroyed", false)):
		return _fail("CH03_05 shrine burn should revoke no_structures_destroyed.")
	if not bool(battle.battle_objective_flags.get("resin_shrine_scorched", false)):
		return _fail("CH03_05 shrine burn should surface resin_shrine_scorched.")
	boss.current_hp = 1
	battle._resolve_attack(scout, boss)
	if not bool(battle.battle_objective_flags.get("tia_defeats_enemy_boss", false)):
		return _fail("CH03_05 should reward ally_scout boss last-hit as tia_defeats_enemy_boss.")
	battle.queue_free()
	await process_frame
	return true

func _assert_ch04_basil_purge_surface() -> bool:
	var battle = await _spawn_battle(CH04_05_STAGE)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"altar_exposed"
	var action: Dictionary = battle._ai_action_basil(boss)
	if String(action.get("type", "")) != "basil_altar_purge":
		return _fail("CH04_05 altar_exposed phase should prioritize basil_altar_purge.")
	battle._apply_enemy_action(boss, action)
	await process_frame
	if not bool(battle.battle_objective_flags.get("basil_altar_purged", false)):
		return _fail("CH04_05 basil purge should expose basil_altar_purged.")
	if battle.hud.transition_reason_label.text.find("Altar Purge") == -1:
		return _fail("CH04_05 basil purge should surface a dedicated HUD reason.")
	battle.queue_free()
	await process_frame
	return true

func _assert_ch05_ledger_objective() -> bool:
	var battle = await _spawn_battle(CH05_05_STAGE)
	var boss = battle.enemy_units[0]
	for _i in range(3):
		battle._use_archive_collapse(boss)
	if not bool(battle.battle_objective_flags.get("collect_3_ledger_entries", false)):
		return _fail("CH05_05 should complete collect_3_ledger_entries after three archive collapses.")
	if int(battle.battle_runtime_counters.get("ch05_ledger_collapse_count", 0)) != 3:
		return _fail("CH05_05 ledger collapse counter should reach 3.")
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
