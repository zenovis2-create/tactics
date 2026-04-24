extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const SkillData = preload("res://scripts/data/skill_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not _assert_skill_cost_contract():
		return
	if not await _assert_battle_hud_cost_surface():
		return
	print("[PASS] skill_cost_surface_runner: all assertions passed.")
	quit(0)

func _assert_skill_cost_contract() -> bool:
	var tactical_shift: SkillData = load("res://data/skills/tactical_shift.tres")
	var ark_breath: SkillData = load("res://data/skills/ark_breath.tres")
	var comet_charge: SkillData = load("res://data/skills/comet_charge.tres")
	if tactical_shift == null or ark_breath == null or comet_charge == null:
		return _fail("Representative skill resources should load.")
	if tactical_shift.get_resource_cost_text() != "MP 1 / SP 1":
		return _fail("tactical_shift should expose MP 1 / SP 1.")
	if ark_breath.get_resource_cost_text() != "MP 2":
		return _fail("ark_breath should expose MP-only cost text.")
	if comet_charge.get_resource_cost_text() != "SP 3":
		return _fail("comet_charge should expose SP-only cost text.")
	return true

func _assert_battle_hud_cost_surface() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage := StageData.new()
	stage.stage_id = &"skill_cost_surface_stage"
	stage.stage_title = "Skill Cost Surface"
	stage.grid_size = Vector2i(4, 4)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.ally_units = [load("res://data/units/ally_rian.tres")]
	stage.enemy_units = [_make_enemy()]
	stage.ally_spawns = [Vector2i(1, 1)]
	stage.enemy_spawns = [Vector2i(2, 1)]

	battle.set_stage(stage)
	await process_frame
	await process_frame
	battle._on_world_cell_pressed(Vector2i(1, 1))
	await process_frame

	var snapshot: Dictionary = battle.hud.get_layout_snapshot()
	if not bool(snapshot.get("resource_cost_visible", false)):
		return _fail("Selecting a unit with non-zero skill costs should expose the HUD skill cost line.")
	if battle.hud.resource_cost_label.text.find("전술 전환 MP 1 / SP 1") == -1:
		return _fail("HUD skill cost line should list representative skill costs for the selected unit.")

	battle.queue_free()
	await process_frame
	return true

func _make_enemy() -> UnitData:
	var unit := UnitData.new()
	unit.unit_id = &"enemy_dummy"
	unit.display_name = "Dummy"
	unit.faction = "enemy"
	unit.max_hp = 6
	unit.attack = 1
	unit.defense = 0
	unit.movement = 3
	unit.attack_range = 1
	unit.default_skill = load("res://data/skills/basic_attack.tres")
	return unit

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
