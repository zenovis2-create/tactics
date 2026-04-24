extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const TIA_DATA = preload("res://data/units/ally_tia.tres")
const SERIN_DATA = preload("res://data/units/ally_serin.tres")
const VANGUARD_DATA = preload("res://data/units/ally_vanguard.tres")
const PIN_SHOT = preload("res://data/skills/pin_shot.tres")
const ARK_BREATH = preload("res://data/skills/ark_breath.tres")
const BASIC_ATTACK = preload("res://data/skills/basic_attack.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var attacker = battle._spawn_unit_actor(TIA_DATA, Vector2i(2, 6), "ally", battle.ally_units)
	var target = battle._spawn_unit_actor(VANGUARD_DATA, Vector2i(5, 6), "ally", battle.ally_units)
	var base_zoom: Vector2 = battle.battle_camera.zoom

	battle._play_attack_timing_signature(attacker, target, BASIC_ATTACK)
	await process_frame
	var melee_zoom: Vector2 = battle.battle_camera.zoom
	var melee_snapshot: Dictionary = battle.get_last_attack_timing_signature_snapshot()
	if melee_zoom == base_zoom:
		return _fail("Melee timing signature should modify camera zoom.")

	battle.battle_camera.zoom = base_zoom
	battle._play_attack_timing_signature(attacker, target, PIN_SHOT)
	await process_frame
	var ranged_zoom: Vector2 = battle.battle_camera.zoom
	var ranged_snapshot: Dictionary = battle.get_last_attack_timing_signature_snapshot()
	if ranged_zoom == base_zoom:
		return _fail("Ranged timing signature should modify camera zoom.")

	var supporter = battle._spawn_unit_actor(SERIN_DATA, Vector2i(1, 5), "ally", battle.ally_units)
	battle.battle_camera.zoom = base_zoom
	battle._play_attack_timing_signature(supporter, target, ARK_BREATH)
	await process_frame
	var support_zoom: Vector2 = battle.battle_camera.zoom
	var support_snapshot: Dictionary = battle.get_last_attack_timing_signature_snapshot()
	if support_zoom == base_zoom:
		return _fail("Support timing signature should modify camera zoom.")
	if melee_zoom == ranged_zoom and ranged_zoom == support_zoom:
		return _fail("Attack timing signatures should not collapse into one identical camera response.")
	if float(melee_snapshot.get("position_pull", 0.0)) <= float(ranged_snapshot.get("position_pull", 0.0)):
		return _fail("Melee signature should pull the camera more aggressively than ranged.")
	if float(support_snapshot.get("flash_duration", 0.0)) <= float(ranged_snapshot.get("flash_duration", 0.0)):
		return _fail("Support timing should hold flash longer than ranged timing.")
	if Vector2(melee_snapshot.get("target_zoom", Vector2.ONE)) == Vector2(ranged_snapshot.get("target_zoom", Vector2.ONE)):
		return _fail("Melee and ranged should not share the same target zoom.")
	if Vector2(ranged_snapshot.get("target_zoom", Vector2.ONE)) == Vector2(support_snapshot.get("target_zoom", Vector2.ONE)):
		return _fail("Ranged and support should not share the same target zoom.")

	print("[PASS] attack_camera_timing_runner validated melee, ranged, and support camera timing signatures.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
