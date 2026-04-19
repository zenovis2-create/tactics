extends SceneTree

const SpotlightManager = preload("res://scripts/battle/spotlight_manager.gd")
const BattleController = preload("res://scripts/battle/battle_controller.gd")
const Ch04BattleController = preload("res://scripts/dev/ch04_01_representative_battle_controller.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

const CH04_01_STAGE: StageData = preload("res://data/stages/ch04_01_stage.tres")
const CH01_02_STAGE: StageData = preload("res://data/stages/ch01_02_stage.tres")

var _spotlight: SpotlightManager
var _trigger_log: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_spotlight = _resolve_spotlight_manager()
	_spotlight.reset_all()
	if not _spotlight.spotlight_triggered.is_connected(_on_spotlight_triggered):
		_spotlight.spotlight_triggered.connect(_on_spotlight_triggered)

	if not _assert_triple_kill():
		return
	if not _assert_last_stand():
		return
	if not _assert_weather_master():
		return
	if not _assert_sacrifice_play():
		return

	print("[PASS] tactical_spotlight_runner: all four spotlight types triggered correctly.")
	quit(0)

func _assert_triple_kill() -> bool:
	var battle: BattleController = Ch04BattleController.new()
	battle.stage_data = CH04_01_STAGE
	var attacker := _make_unit(&"ally_rian", "ally", "steady", 24, 11, 5, Vector2i(2, 5))
	var enemy_a := _make_unit(&"enemy_raider_a", "enemy", "adapted", 10, 6, 2, Vector2i(5, 1))
	var enemy_b := _make_unit(&"enemy_raider_b", "enemy", "adapted", 10, 6, 2, Vector2i(6, 1))
	var enemy_c := _make_unit(&"enemy_raider_c", "enemy", "adapted", 10, 6, 2, Vector2i(7, 1))
	enemy_a.current_hp = 1
	enemy_b.current_hp = 1
	enemy_c.current_hp = 1
	battle.ally_units = [attacker]
	battle.enemy_units = [enemy_a, enemy_b, enemy_c]
	_bind_turn_signal(battle)
	_clear_trigger_log()
	battle.battle_turn_ended.emit("ally", [
		{
			"type": "attack",
			"actor_id": attacker.unit_data.unit_id,
			"actor_hp_before": attacker.current_hp,
			"actor_max_hp": attacker.unit_data.max_hp,
			"target_id": enemy_a.unit_data.unit_id,
			"killed_unit_ids": [enemy_a.unit_data.unit_id]
		},
		{
			"type": "attack",
			"actor_id": attacker.unit_data.unit_id,
			"actor_hp_before": attacker.current_hp,
			"actor_max_hp": attacker.unit_data.max_hp,
			"target_id": enemy_b.unit_data.unit_id,
			"killed_unit_ids": [enemy_b.unit_data.unit_id]
		},
		{
			"type": "attack",
			"actor_id": attacker.unit_data.unit_id,
			"actor_hp_before": attacker.current_hp,
			"actor_max_hp": attacker.unit_data.max_hp,
			"target_id": enemy_c.unit_data.unit_id,
			"killed_unit_ids": [enemy_c.unit_data.unit_id]
		}
	])
	var ok := _assert_triggered(SpotlightManager.TRIPLE_KILL, "CH04_01 should trigger TRIPLE_KILL after three one-HP enemies fall in the same turn.")
	_cleanup_battle(battle, [attacker, enemy_a, enemy_b, enemy_c])
	return ok

func _assert_last_stand() -> bool:
	var battle := BattleController.new()
	battle.stage_data = CH01_02_STAGE
	var attacker := _make_unit(&"ally_bran", "ally", "steady", 100, 9, 4, Vector2i(1, 2))
	var enemy := _make_unit(&"enemy_scout", "enemy", "adapted", 12, 6, 2, Vector2i(2, 2))
	attacker.current_hp = 5
	enemy.current_hp = 1
	battle.ally_units = [attacker]
	battle.enemy_units = [enemy]
	_bind_turn_signal(battle)
	_clear_trigger_log()
	battle.battle_turn_ended.emit("ally", [{
		"type": "attack",
		"actor_id": attacker.unit_data.unit_id,
		"actor_hp_before": attacker.current_hp,
		"actor_max_hp": attacker.unit_data.max_hp,
		"target_id": enemy.unit_data.unit_id,
		"killed_unit_ids": [enemy.unit_data.unit_id]
	}])
	var ok := _assert_triggered(SpotlightManager.LAST_STAND, "CH01_02 should trigger LAST_STAND when a unit at 5% HP secures a kill.")
	_cleanup_battle(battle, [attacker, enemy])
	return ok

func _assert_weather_master() -> bool:
	var battle := BattleController.new()
	battle.stage_data = StageData.new()
	battle.stage_data.stage_id = &"WEATHER_MASTER_TEST"
	var caster := _make_unit(&"ally_tia", "ally", "steady", 18, 8, 3, Vector2i(3, 3))
	battle.ally_units = [caster]
	_bind_turn_signal(battle)
	_clear_trigger_log()
	battle.battle_turn_ended.emit("ally", [
		{
			"type": "weather",
			"actor_id": caster.unit_data.unit_id,
			"weather_effect_id": &"rain_comfort",
			"affected_unit_ids": [caster.unit_data.unit_id]
		},
		{
			"type": "weather",
			"actor_id": caster.unit_data.unit_id,
			"weather_effect_id": &"steam_confusion",
			"affected_unit_ids": [caster.unit_data.unit_id]
		},
		{
			"type": "weather",
			"actor_id": caster.unit_data.unit_id,
			"weather_effect_id": &"thunder_fear",
			"affected_unit_ids": [caster.unit_data.unit_id]
		}
	])
	var ok := _assert_triggered(SpotlightManager.WEATHER_MASTER, "Weather master should trigger after three distinct weather effects resolve in one turn.")
	_cleanup_battle(battle, [caster])
	return ok

func _assert_sacrifice_play() -> bool:
	var battle := BattleController.new()
	battle.stage_data = StageData.new()
	battle.stage_data.stage_id = &"SACRIFICE_PLAY_TEST"
	var saved_ally := _make_unit(&"ally_serin", "ally", "steady", 20, 7, 4, Vector2i(4, 4))
	var sacrifice_ally := _make_unit(&"ally_guard", "ally", "steady", 12, 6, 5, Vector2i(4, 5))
	battle.ally_units = [saved_ally, sacrifice_ally]
	_bind_turn_signal(battle)
	_clear_trigger_log()
	battle.battle_turn_ended.emit("enemy", [{
		"type": "sacrifice_play",
		"actor_id": sacrifice_ally.unit_data.unit_id,
		"saved_unit_id": saved_ally.unit_data.unit_id,
		"protected_unit_id": saved_ally.unit_data.unit_id,
		"actor_died": true
	}])
	var ok := _assert_triggered(SpotlightManager.SACRIFICE_PLAY, "Sacrifice play should trigger when one ally dies protecting another in the same action.")
	_cleanup_battle(battle, [saved_ally, sacrifice_ally])
	return ok

func _bind_turn_signal(battle: BattleController) -> void:
	battle.battle_turn_ended.connect(func(_turn_owner: String, turn_actions: Array) -> void:
		_spotlight.begin_battle(battle.stage_data.stage_id if battle.stage_data != null else &"runner_battle")
		_spotlight.check_spotlight_conditions(turn_actions)
	)

func _resolve_spotlight_manager() -> SpotlightManager:
	var spotlight := root.get_node_or_null("Spotlight") as SpotlightManager
	if spotlight != null:
		return spotlight
	spotlight = SpotlightManager.new()
	spotlight.name = "Spotlight"
	root.add_child(spotlight)
	return spotlight

func _make_unit(unit_id: StringName, faction: String, personality: String, hp: int, attack: int, defense: int, grid_position: Vector2i) -> UnitActor:
	var unit := UnitActor.new()
	var data := UnitData.new()
	data.unit_id = unit_id
	data.display_name = String(unit_id)
	data.faction = faction
	data.max_hp = hp
	data.attack = attack
	data.defense = defense
	data.movement = 4
	data.attack_range = 1
	data.personality = personality
	unit.unit_data = data
	unit.faction = faction
	unit.current_hp = hp
	unit.grid_position = grid_position
	return unit

func _clear_trigger_log() -> void:
	_trigger_log.clear()

func _assert_triggered(expected_type: StringName, message: String) -> bool:
	for entry in _trigger_log:
		if entry.get("spotlight_type", &"") == expected_type:
			return true
	return _fail(message)

func _cleanup_battle(battle: BattleController, units: Array) -> void:
	for unit_variant in units:
		var unit: UnitActor = unit_variant
		if unit != null and is_instance_valid(unit):
			unit.free()
	if battle != null and is_instance_valid(battle):
		battle.free()

func _on_spotlight_triggered(spotlight_type: StringName, unit_ids: Array) -> void:
	_trigger_log.append({
		"spotlight_type": spotlight_type,
		"unit_ids": unit_ids.duplicate()
	})

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
