extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const TIA_DATA = preload("res://data/units/ally_tia.tres")
const SERIN_DATA = preload("res://data/units/ally_serin.tres")
const VANGUARD_DATA = preload("res://data/units/ally_vanguard.tres")
const PIN_SHOT = preload("res://data/skills/pin_shot.tres")
const ARK_BREATH = preload("res://data/skills/ark_breath.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var initial_children: int = battle.effects_root.get_child_count()

	var tia = battle._spawn_unit_actor(TIA_DATA, Vector2i(2, 6), "ally", battle.ally_units)
	var target = battle._spawn_unit_actor(VANGUARD_DATA, Vector2i(5, 6), "ally", battle.ally_units)
	battle._play_attack_sequence_fx(tia, target, PIN_SHOT)
	await process_frame
	if battle.effects_root.get_child_count() < initial_children + 2:
		return _fail("Ranged attack FX should spawn at least trail + impact surfaces.")

	var after_ranged: int = battle.effects_root.get_child_count()
	var serin = battle._spawn_unit_actor(SERIN_DATA, Vector2i(2, 5), "ally", battle.ally_units)
	battle._play_attack_sequence_fx(serin, target, ARK_BREATH)
	await process_frame
	if battle.effects_root.get_child_count() < after_ranged + 2:
		return _fail("Mystic/support FX should spawn at least cast + trail surfaces.")

	print("[PASS] attack_fx_runner validated ranged and mystic attack FX layering.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
