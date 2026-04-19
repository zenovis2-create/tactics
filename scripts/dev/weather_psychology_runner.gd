extends SceneTree

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const CombatService = preload("res://scripts/battle/combat_service.gd")
const StatusService = preload("res://scripts/battle/status_service.gd")
const TurnManager = preload("res://scripts/battle/turn_manager.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not _assert_steam_and_smoke_apply_weather_psychology():
		return
	if not _assert_rain_applies_comfort_and_fire_drain():
		return
	if not _assert_thunder_applies_fear_and_skips_turn():
		return
	if not _assert_combat_context_uses_weather_status_modifiers():
		return
	print("[PASS] weather_psychology_runner: all assertions passed.")
	quit(0)

func _assert_steam_and_smoke_apply_weather_psychology() -> bool:
	var battle := _make_battle_controller(["night", "storm"])
	battle.stage_data.steam_cloud_cells = [Vector2i(1, 1)]
	battle.stage_data.smoke_cells = [Vector2i(1, 1)]
	var ally := _make_unit(&"ally_watch", "ally", "steady", 16, 10, 4, Vector2i(1, 1))
	var enemy := _make_unit(&"enemy_hound", "enemy", "adapted", 16, 10, 4, Vector2i(1, 1))
	battle.ally_units = [ally]
	battle.enemy_units = [enemy]

	battle._apply_synergy_reactions()

	if not battle.status_service.has_status(ally, &"混乱"):
		return _fail("Steam cloud should apply 混乱 to allies inside the area.")
	if not battle.status_service.has_status(enemy, &"混乱"):
		return _fail("Steam cloud should apply 混乱 to enemies inside the area.")
	if not battle.status_service.has_status(ally, &"눈不适应"):
		return _fail("Night + Smoke should apply 눈不适应 to allied units inside smoke.")
	if battle.status_service.has_status(enemy, &"눈不适应"):
		return _fail("Night + Smoke should not penalize enemies inside smoke.")

	var ally_fx: Dictionary = battle.status_service.get_effects(ally)
	if int(ally_fx.get("defense_percent_mod", 0)) != 20:
		return _fail("混乱 should grant defense_percent_mod = 20.")
	if int(ally_fx.get("accuracy_mod", 0)) != -15:
		return _fail("混乱 should apply accuracy_mod = -15.")
	if int(ally_fx.get("attack_percent_mod", 0)) != -10:
		return _fail("눈不适应 should apply attack_percent_mod = -10.")
	_cleanup_battle(battle, [ally, enemy])
	return true

func _assert_rain_applies_comfort_and_fire_drain() -> bool:
	var battle := _make_battle_controller(["rain"])
	var comfort_ally := _make_unit(&"ally_serin", "ally", "steady", 18, 7, 3, Vector2i(0, 0))
	var fire_ally := _make_unit(&"ally_ember", "ally", "fire", 12, 7, 2, Vector2i(0, 1))
	battle.ally_units = [comfort_ally, fire_ally]
	battle.enemy_units = []

	battle._apply_weather_effects()

	if not battle.status_service.has_status(comfort_ally, &"비옷의慰め"):
		return _fail("Rain should apply 비옷의慰め to non-Fire allies.")
	if battle.status_service.has_status(fire_ally, &"비옷의慰め"):
		return _fail("Rain should not apply 비옷의慰め to Fire allies.")
	if fire_ally.current_hp != 11:
		return _fail("Rain should drain 1 HP from Fire allies.")
	var comfort_fx: Dictionary = battle.status_service.get_effects(comfort_ally)
	if int(comfort_fx.get("crit_rate_bonus", 0)) != 10:
		return _fail("비옷의慰め should grant crit_rate_bonus = 10.")
	_cleanup_battle(battle, [comfort_ally, fire_ally])
	return true

func _assert_thunder_applies_fear_and_skips_turn() -> bool:
	var battle := _make_battle_controller(["storm"])
	var target := _make_unit(&"ally_bran", "ally", "steady", 20, 8, 5, Vector2i(2, 2))
	battle.ally_units = [target]
	battle.enemy_units = []
	battle.turn_manager.begin_phase("ally", [target], "runner_setup")

	battle._apply_weather_effects({
		"thunder_targets": [target],
		"thunder_paralytic_success": true
	})

	if not battle.status_service.has_status(target, &"fear"):
		return _fail("Thunder paralytic success should apply fear.")
	var fear_fx: Dictionary = battle.status_service.get_effects(target)
	if not bool(fear_fx.get("ability_locked", false)):
		return _fail("Fear should lock the next ability use.")

	battle._apply_phase_start_statuses("ally")
	if not battle.turn_manager.is_unit_exhausted(target):
		return _fail("Fear should skip the next turn by exhausting the unit.")
	if battle.status_service.has_status(target, &"fear"):
		return _fail("Fear should be consumed after skipping the turn.")
	_cleanup_battle(battle, [target])
	return true

func _assert_combat_context_uses_weather_status_modifiers() -> bool:
	var battle := _make_battle_controller(["night", "storm"])
	battle.stage_data.steam_cloud_cells = [Vector2i(1, 1)]
	battle.stage_data.smoke_cells = [Vector2i(1, 1)]
	var attacker := _make_unit(&"ally_tia", "ally", "steady", 18, 10, 3, Vector2i(1, 1))
	var defender := _make_unit(&"enemy_guard", "enemy", "adapted", 18, 7, 5, Vector2i(1, 1))
	battle.ally_units = [attacker]
	battle.enemy_units = [defender]
	battle._apply_synergy_reactions()

	var attack_context: Dictionary = battle._build_attack_context(attacker, defender)
	var combat := CombatService.new()
	var result: Dictionary = combat.resolve_attack(attacker, defender, null, {
		"defense_bonus": attack_context.get("defense_bonus", 0),
		"terrain_type": attack_context.get("terrain_type", "plain"),
		"allow_counterattack": false,
		"attack_bonus": attack_context.get("attack_bonus", 0),
		"counter_context": attack_context.get("counter_context", {}),
		"oblivion_accuracy_mod": attack_context.get("oblivion_accuracy_mod", 0),
		"accuracy_mod": attack_context.get("accuracy_mod", 0),
		"attack_percent_mod": attack_context.get("attack_percent_mod", 0),
		"defense_percent_mod": attack_context.get("defense_percent_mod", 0),
		"crit_rate_bonus": attack_context.get("crit_rate_bonus", 0)
	})
	var hit_event: Dictionary = result.get("pipeline_trace", [])[0]
	if int(hit_event.get("hit_chance", 0)) != 85:
		return _fail("Steam cloud should reduce effective hit chance to 85.")
	if int(result.get("damage", -1)) != 3:
		return _fail("Weather psychology combat modifiers should reduce damage from 5 to 3.")
	combat.free()
	_cleanup_battle(battle, [attacker, defender])
	return true

func _make_battle_controller(weather_tags: Array[String]) -> BattleController:
	var battle := BattleController.new()
	battle.stage_data = StageData.new()
	battle.stage_data.weather_tags = PackedStringArray(weather_tags)
	battle.status_service = StatusService.new()
	battle.turn_manager = TurnManager.new()
	root.add_child(battle.status_service)
	root.add_child(battle.turn_manager)
	return battle

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

func _cleanup_battle(battle: BattleController, units: Array) -> void:
	for unit_variant in units:
		var unit: UnitActor = unit_variant
		if is_instance_valid(unit):
			unit.free()
	if battle != null:
		if battle.status_service != null and is_instance_valid(battle.status_service):
			battle.status_service.free()
		if battle.turn_manager != null and is_instance_valid(battle.turn_manager):
			battle.turn_manager.free()
		battle.free()

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
