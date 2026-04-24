extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_skill_resource_spend_and_block():
		return
	print("[PASS] skill_resource_spend_runner: all assertions passed.")
	quit(0)

func _assert_skill_resource_spend_and_block() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage := StageData.new()
	stage.stage_id = &"skill_resource_spend_stage"
	stage.stage_title = "Skill Resource Spend"
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

	var attacker = battle.ally_units[0]
	var defender = battle.enemy_units[0]
	var skill = attacker.unit_data.get_skill_by_id(&"collapse_line")
	if skill == null:
		return _fail("Rian should expose collapse_line for skill spend test.")

	var mp_before: int = attacker.current_mp
	var sp_before: int = attacker.current_sp
	if not battle._resolve_attack(attacker, defender, {}, skill):
		return _fail("Affordable skill use should resolve successfully.")
	if attacker.current_mp != mp_before - skill.mp_cost:
		return _fail("Skill use should spend MP.")
	if attacker.current_sp != sp_before - skill.sp_cost:
		return _fail("Skill use should spend SP.")

	attacker.set_resource_values(0, 0)
	var defender_hp_before: int = defender.current_hp
	if battle._resolve_attack(attacker, defender, {}, skill):
		return _fail("Unaffordable skill use should be rejected.")
	if defender.current_hp != defender_hp_before:
		return _fail("Rejected skill use should not apply damage.")
	if battle.hud.transition_reason_label.text.find("Skill Insufficient Resource") == -1:
		return _fail("Rejected skill use should expose an insufficient-resource HUD reason.")

	battle.queue_free()
	await process_frame
	return true

func _make_enemy() -> UnitData:
	var unit := UnitData.new()
	unit.unit_id = &"enemy_dummy"
	unit.display_name = "Dummy"
	unit.faction = "enemy"
	unit.max_hp = 12
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
