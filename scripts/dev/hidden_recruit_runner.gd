extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

const CH07_05_STAGE: StageData = preload("res://data/stages/ch07_05_stage.tres")
const CH08_05_STAGE: StageData = preload("res://data/stages/ch08_05_stage.tres")
const CH09B_05_STAGE: StageData = preload("res://data/stages/ch09b_05_stage.tres")

const ALLY_TIA: UnitData = preload("res://data/units/ally_tia.tres")
const ALLY_RIAN: UnitData = preload("res://data/units/ally_rian.tres")
const ALLY_NOAH: UnitData = preload("res://data/units/ally_noah.tres")
const ENEMY_LETE: UnitData = preload("res://data/units/enemy_lete.tres")
const ENEMY_SARIA: UnitData = preload("res://data/units/enemy_saria.tres")
const ENEMY_MELKION: UnitData = preload("res://data/units/enemy_melkion.tres")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _run_lete_case()
	await _run_mira_case()
	await _run_melkion_case()
	if _failed:
		quit(1)
		return
	print("[PASS] hidden_recruit_runner validated Lete, Mira, and Melkion unlock paths.")
	quit(0)

func _run_lete_case() -> void:
	var main: Node = await _spawn_main()
	var stage: StageData = CH08_05_STAGE.duplicate(true)
	stage.ally_units = [_build_unit(&"ally_rian", "Rian", "ally", 18, 6, 2, 4, 1)]
	stage.enemy_units = [ENEMY_LETE.duplicate(true)]
	stage.ally_spawns = [Vector2i(1, 6)]
	stage.enemy_spawns = [Vector2i(5, 1)]

	await _load_stage(main, &"CH08", 4, stage)

	var battle = main.battle_controller
	var lete = _find_unit_actor(battle, &"enemy_lete")
	_assert(lete != null, "Lete case should spawn enemy_lete.")
	if _failed:
		return
	lete.current_hp = 4
	lete._refresh_visuals()
	battle._resolve_attack(battle.ally_units[0], lete)
	await process_frame
	battle._check_battle_end()
	await process_frame
	await process_frame

	var summary: Dictionary = battle.get_last_result_summary()
	var hidden_state: Dictionary = summary.get("hidden_recruit_state", {})
	var progression = battle.progression_service.get_data()
	_assert(bool(hidden_state.get("lete_retreated", false)), "Lete case should record the retreat flag.")
	_assert(progression.is_ally_unlocked(&"lete"), "Lete case should unlock ally_unlocked['lete'] in progression.")
	_assert(main.campaign_controller._is_recruit_unlocked(&"ally_lete"), "Lete should be recruitable once the retreat unlock resolves.")
	_assert(CampaignCatalog.is_hidden_recruit(&"ally_lete"), "ally_lete should be registered as a hidden recruit.")
	if not _failed:
		print("[PASS] Lete retreat unlock")
	main.queue_free()
	await process_frame

func _run_mira_case() -> void:
	var main: Node = await _spawn_main()
	var stage: StageData = CH07_05_STAGE.duplicate(true)
	var tia: UnitData = ALLY_TIA.duplicate(true)
	tia.attack = 8
	stage.ally_units = [tia]
	stage.enemy_units = [ENEMY_SARIA.duplicate(true)]
	stage.ally_spawns = [Vector2i(2, 8)]
	stage.enemy_spawns = [Vector2i(10, 1)]

	_assert(not stage.interactive_objects.is_empty(), "Mira case should author a shrine interactive object in CH07_05.")
	if _failed:
		return
	_assert(stage.interactive_objects[0].object_type == "shrine", "CH07_05 should expose a shrine object type for Mira.")
	if _failed:
		return

	await _load_stage(main, &"CH07", 4, stage)

	var battle = main.battle_controller
	var shrine = battle.interactive_objects[0]
	battle._resolve_interaction(battle.ally_units[0], shrine)
	await process_frame

	var boss = _find_boss_enemy(battle)
	_assert(boss != null, "Mira case should spawn the CH07_05 boss.")
	if _failed:
		return
	boss.current_hp = 4
	boss._refresh_visuals()
	battle._resolve_attack(battle.ally_units[0], boss)
	await process_frame
	battle._check_battle_end()
	await process_frame
	await process_frame

	var summary: Dictionary = battle.get_last_result_summary()
	var hidden_state: Dictionary = summary.get("hidden_recruit_state", {})
	var progression = battle.progression_service.get_data()
	_assert(bool(hidden_state.get("mira_shrine_investigated", false)), "Mira case should record the shrine investigation.")
	_assert(bool(hidden_state.get("mira_unlocked", false)), "Mira case should record Tia's shrine-backed boss kill unlock.")
	_assert(progression.mira_unlocked, "Mira case should set mira_unlocked in progression.")
	_assert(main.campaign_controller._is_recruit_unlocked(&"ally_mira"), "Mira should be recruitable after the shrine route resolves.")
	_assert(CampaignCatalog.is_hidden_recruit(&"ally_mira"), "ally_mira should be registered as a hidden recruit.")
	if not _failed:
		print("[PASS] Mira shrine unlock")
	main.queue_free()
	await process_frame

func _run_melkion_case() -> void:
	var main: Node = await _spawn_main()
	var stage: StageData = CH09B_05_STAGE.duplicate(true)
	stage.ally_units = [ALLY_RIAN.duplicate(true), ALLY_NOAH.duplicate(true)]
	stage.enemy_units = [ENEMY_MELKION.duplicate(true)]
	stage.ally_spawns = [Vector2i(1, 6), Vector2i(2, 6)]
	stage.enemy_spawns = [Vector2i(5, 1)]

	await _load_stage(main, &"CH09B", 4, stage)

	var battle = main.battle_controller
	battle.bond_service.reset()
	battle.bond_service.apply_bond_delta(&"ally_noah", 5, "hidden_recruit_runner")
	_assert(battle.bond_service.get_support_rank(&"rian", &"noah") == 4, "Melkion case should reach the Noah S-rank support gate.")
	if _failed:
		return

	var melkion = _find_unit_actor(battle, &"enemy_melkion")
	_assert(melkion != null, "Melkion case should spawn enemy_melkion.")
	if _failed:
		return
	melkion.current_hp = 7
	melkion._refresh_visuals()
	battle._check_boss_phase_transitions()
	await process_frame
	battle._check_battle_end()
	await process_frame
	await process_frame

	var summary: Dictionary = battle.get_last_result_summary()
	var hidden_state: Dictionary = summary.get("hidden_recruit_state", {})
	var progression = battle.progression_service.get_data()
	_assert(bool(hidden_state.get("melkion_flipped", false)), "Melkion case should record the truth-flip event.")
	_assert(progression.melkion_unlocked, "Melkion case should set the temporary recruit unlock in progression.")
	_assert(main.campaign_controller._is_recruit_unlocked(&"ally_melkion_ally"), "Melkion should be recruitable for the next battle window.")
	_assert(_find_unit_actor(battle, &"ally_melkion_ally") != null, "Melkion should flip into the ally roster during CH09B_05 phase 2.")
	_assert(CampaignCatalog.is_hidden_recruit(&"ally_melkion_ally"), "ally_melkion_ally should be registered as a hidden recruit.")
	if not _failed:
		print("[PASS] Melkion truth flip unlock")
	main.queue_free()
	await process_frame

func _spawn_main() -> Node:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	return main

func _load_stage(main: Node, chapter_id: StringName, stage_index: int, stage: StageData) -> void:
	main.title_screen.visible = false
	main.battle_controller.visible = true
	main.campaign_controller._active_chapter_id = chapter_id
	main.campaign_controller._active_stage_index = stage_index
	main.campaign_controller._current_stage = stage
	main.campaign_controller._active_mode = "battle"
	main.battle_controller.set_stage(stage)
	await process_frame
	await process_frame

func _find_unit_actor(battle, unit_id: StringName):
	for unit in battle.ally_units + battle.enemy_units:
		if is_instance_valid(unit) and unit.unit_data != null and unit.unit_data.unit_id == unit_id:
			return unit
	return null

func _find_boss_enemy(battle):
	for enemy in battle.enemy_units:
		if is_instance_valid(enemy) and enemy.unit_data != null and enemy.unit_data.is_boss:
			return enemy
	return null

func _build_unit(unit_id: StringName, display_name: String, faction: String, max_hp: int, attack: int, defense: int, movement: int, attack_range: int) -> UnitData:
	var unit_data := UnitData.new()
	unit_data.unit_id = unit_id
	unit_data.display_name = display_name
	unit_data.faction = faction
	unit_data.max_hp = max_hp
	unit_data.attack = attack
	unit_data.defense = defense
	unit_data.movement = movement
	unit_data.attack_range = attack_range
	return unit_data

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
