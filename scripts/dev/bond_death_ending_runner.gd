extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH04_01_STAGE = preload("res://data/stages/ch04_01_stage.tres")
const ALLY_RIAN = preload("res://data/units/ally_rian.tres")
const ALLY_NOAH = preload("res://data/units/ally_noah.tres")
const ENEMY_RAIDER = preload("res://data/units/enemy_raider.tres")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

var _failed: bool = false
var _bond_signal_payload: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	if not _prepare_slot_zero(save_service):
		return

	var loaded := save_service.load_progression(0)
	battle.progression_service.load_data(loaded)
	battle.bond_service.setup_progression(loaded)
	battle.bond_death_triggered.connect(_on_bond_death_triggered)

	var stage: StageData = CH04_01_STAGE.duplicate(true) as StageData
	var rian_data: UnitData = ALLY_RIAN.duplicate(true) as UnitData
	var noah_data: UnitData = ALLY_NOAH.duplicate(true) as UnitData
	var raider_data: UnitData = ENEMY_RAIDER.duplicate(true) as UnitData
	stage.ally_units = [rian_data, noah_data]
	stage.enemy_units = [raider_data]
	stage.ally_spawns = [Vector2i(1, 6), Vector2i(2, 6)]
	stage.enemy_spawns = [Vector2i(5, 1)]
	battle.set_stage(stage)
	await process_frame
	await process_frame

	_assert(battle.stage_data != null and battle.stage_data.stage_id == &"CH04_01", "Runner should boot the CH04_01 battle.")
	_assert(battle.bond_service.get_support_rank(&"ally_rian", &"ally_noah") >= 2, "slot_0 should provide a bonded Rian/Noah support rank.")
	if _failed:
		return

	var registry = battle.get_bond_ending_registry()
	_assert(registry != null, "Battle controller should expose the bond ending registry.")
	if _failed:
		return

	var direct_ending = registry.get_pair_ending("rian+noah")
	var simultaneous_ending = registry.check_simultaneous_death([&"ally_rian", &"ally_noah"])
	_assert(direct_ending != null, "Registry should expose the authored Rian/Noah ending.")
	_assert(simultaneous_ending != null, "Registry should resolve Rian/Noah as a simultaneous death ending.")
	if _failed:
		return
	_assert(direct_ending.id == simultaneous_ending.id, "Registry lookups should agree on the authored ending id.")
	if _failed:
		return

	var rian = _find_unit_actor(battle, &"ally_rian")
	var noah = _find_unit_actor(battle, &"ally_noah")
	_assert(rian != null and noah != null, "CH04_01 should spawn both Rian and Noah for the contract test.")
	if _failed:
		return

	rian.current_hp = 1
	rian._refresh_visuals()
	noah.current_hp = 1
	noah._refresh_visuals()

	rian.apply_damage(1)
	noah.apply_damage(1)
	await process_frame
	battle._check_bond_death()
	await process_frame

	_assert(not _bond_signal_payload.is_empty(), "Bond death signal should fire when bonded allies fall on the same turn.")
	_assert(String(_bond_signal_payload.get("pair_id", "")) == "rian+noah", "Signal should identify the fallen pair.")
	_assert(String(_bond_signal_payload.get("ending_id", "")) == direct_ending.id, "Signal ending id should match the registry ending.")
	if _failed:
		return

	battle.queue_free()
	save_service.queue_free()
	await process_frame
	await process_frame
	print("[PASS] bond_death_ending_runner: all assertions passed.")
	quit(0)

func _prepare_slot_zero(save_service: SaveService) -> bool:
	var progression := ProgressionData.new()
	progression.support_progress_by_pair["ally_noah:ally_rian"] = {
		"pair": "ally_noah:ally_rian",
		"battles_together": 6,
		"milestone_rank": 4,
		"rank_bonus": 0,
		"rank": 4,
		"pending_support_bonus": 0
	}
	progression.snapshot_unlock_state()
	var err := save_service.save_progression(progression, 0)
	if err != OK:
		return _fail("save_progression(slot_0) should return OK, got %s" % error_string(err))
	return true

func _find_unit_actor(battle, unit_id: StringName):
	for unit in battle.ally_units + battle.enemy_units:
		if is_instance_valid(unit) and unit.unit_data != null and unit.unit_data.unit_id == unit_id:
			return unit
	return null

func _on_bond_death_triggered(pair_id: String, ending_id: String) -> void:
	_bond_signal_payload = {
		"pair_id": pair_id,
		"ending_id": ending_id
	}

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
	quit(1)

func _fail(message: String) -> bool:
	_assert(false, message)
	return false
