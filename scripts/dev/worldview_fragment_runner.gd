extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const EncyclopediaPanelScene: PackedScene = preload("res://scenes/ui/encyclopedia_panel.tscn")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
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

const LETE_FRAGMENT := "복수의_순수함"
const MIRA_FRAGMENT := "믿음과_의심"
const MELKION_FRAGMENT := "진실의_대가"

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = await _spawn_main()
	await _run_lete_case(main)
	await _run_mira_case(main)
	await _run_melkion_case(main)
	await _assert_worldview_completion(main)
	main.queue_free()
	await process_frame
	if _failed:
		quit(1)
		return
	print("[PASS] worldview_fragment_runner validated worldview fragment collection, Museum of Truth unlock, and Codex progress rendering.")
	quit(0)

func _run_lete_case(main: Node) -> void:
	var stage: StageData = CH08_05_STAGE.duplicate(true)
	stage.ally_units = [_build_unit(&"ally_rian", "Rian", "ally", 18, 6, 2, 4, 1)]
	stage.enemy_units = [ENEMY_LETE.duplicate(true)]
	stage.ally_spawns = [Vector2i(1, 6)]
	stage.enemy_spawns = [Vector2i(5, 1)]
	await _load_stage(main, &"CH08", 4, stage)
	var battle = main.battle_controller
	var lete = _find_unit_actor(battle, &"enemy_lete")
	_assert(lete != null, "Worldview runner should spawn enemy_lete for the Lete case.")
	if _failed:
		return
	lete.current_hp = 4
	lete._refresh_visuals()
	battle._resolve_attack(battle.ally_units[0], lete)
	await process_frame
	battle._check_battle_end()
	await process_frame
	await process_frame
	var progression = battle.progression_service.get_data()
	_assert(progression.has_worldview_fragment(LETE_FRAGMENT), "Lete recruitment should add the 복수의_순수함 worldview fragment.")

func _run_mira_case(main: Node) -> void:
	var stage: StageData = CH07_05_STAGE.duplicate(true)
	var tia: UnitData = ALLY_TIA.duplicate(true)
	tia.attack = 8
	stage.ally_units = [tia]
	stage.enemy_units = [ENEMY_SARIA.duplicate(true)]
	stage.ally_spawns = [Vector2i(2, 8)]
	stage.enemy_spawns = [Vector2i(10, 1)]
	await _load_stage(main, &"CH07", 4, stage)
	var battle = main.battle_controller
	var shrine = battle.interactive_objects[0]
	battle._resolve_interaction(battle.ally_units[0], shrine)
	await process_frame
	var boss = _find_boss_enemy(battle)
	_assert(boss != null, "Worldview runner should spawn the CH07_05 boss for the Mira case.")
	if _failed:
		return
	boss.current_hp = 4
	boss._refresh_visuals()
	battle._resolve_attack(battle.ally_units[0], boss)
	await process_frame
	battle._check_battle_end()
	await process_frame
	await process_frame
	var progression = battle.progression_service.get_data()
	_assert(progression.has_worldview_fragment(MIRA_FRAGMENT), "Mira recruitment should add the 믿음과_의심 worldview fragment.")

func _run_melkion_case(main: Node) -> void:
	var stage: StageData = CH09B_05_STAGE.duplicate(true)
	stage.ally_units = [ALLY_RIAN.duplicate(true), ALLY_NOAH.duplicate(true)]
	stage.enemy_units = [ENEMY_MELKION.duplicate(true)]
	stage.ally_spawns = [Vector2i(1, 6), Vector2i(2, 6)]
	stage.enemy_spawns = [Vector2i(5, 1)]
	await _load_stage(main, &"CH09B", 4, stage)
	var battle = main.battle_controller
	battle.bond_service.reset()
	battle.bond_service.apply_bond_delta(&"ally_noah", 5, "worldview_fragment_runner")
	var melkion = _find_unit_actor(battle, &"enemy_melkion")
	_assert(melkion != null, "Worldview runner should spawn enemy_melkion for the Melkion case.")
	if _failed:
		return
	melkion.current_hp = 7
	melkion._refresh_visuals()
	battle._check_boss_phase_transitions()
	await process_frame
	battle._check_battle_end()
	await process_frame
	await process_frame
	var progression = battle.progression_service.get_data()
	_assert(progression.has_worldview_fragment(MELKION_FRAGMENT), "Melkion truth flip should add the 진실의_대가 worldview fragment.")

func _assert_worldview_completion(main: Node) -> void:
	var progression = main.battle_controller.progression_service.get_data()
	_assert(progression.worldview_fragments.size() == 3, "All three worldview fragments should be recorded after the hidden recruit sequence.")
	_assert(progression.worldview_complete, "Collecting all three worldview fragments should unlock worldview_complete.")
	if _failed:
		return
	main.campaign_controller._active_chapter_id = &"CH09B"
	main.campaign_controller._active_mode = CampaignState.MODE_CAMP
	main.campaign_controller._set_panel_state(
		CampaignState.MODE_CAMP,
		"CH09B Record Abyss Interlude",
		main.campaign_controller._build_ch09b_camp_summary(),
		"Next Battle"
	)
	await process_frame
	await process_frame
	var panel_snapshot: Dictionary = main.campaign_controller._campaign_panel.get_snapshot()
	_assert(bool(panel_snapshot.get("museum_visible", false)), "Museum of Truth should be visible in the camp summary once all worldview fragments are collected.")
	_assert(int(panel_snapshot.get("museum_card_count", 0)) == 3, "Museum of Truth should render three worldview fragment cards.")
	_assert(String(panel_snapshot.get("museum_badge", "")).find("Hidden Chapter") != -1, "Museum of Truth should show the hidden-chapter completion badge.")
	var encyclopedia = EncyclopediaPanelScene.instantiate()
	root.add_child(encyclopedia)
	await process_frame
	encyclopedia.show_encyclopedia(progression, &"CH09B")
	await process_frame
	var encyclopedia_snapshot: Dictionary = encyclopedia.get_snapshot()
	_assert(String(encyclopedia_snapshot.get("worldview_detail", "")).find("3/3 collected") != -1, "Codex should show worldview fragment progress as 3/3 collected.")
	_assert(String(encyclopedia_snapshot.get("worldview_detail", "")).find("Museum of Truth") != -1, "Codex should mention the Museum of Truth unlock once worldview_complete is true.")
	encyclopedia.queue_free()
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
	main.campaign_controller._active_mode = CampaignState.MODE_BATTLE
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
