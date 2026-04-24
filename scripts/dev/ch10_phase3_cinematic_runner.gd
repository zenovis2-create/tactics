extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH10_05_STAGE = preload("res://data/stages/ch10_05_stage.tres")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = await _spawn_battle(CH10_05_STAGE)
	if battle == null:
		return
	await _finish_active_cutscene(battle)
	if _failed:
		return
	var boss = battle.enemy_units[0] if battle.enemy_units.size() > 0 else null
	if boss == null:
		_fail("CH10_05 phase-3 cinematic runner could not find Karuon.")
		return
	battle._apply_boss_phase_effects(boss, &"final_toll", &"name_severance")
	await process_frame
	if String(battle.hud.transition_reason_label.text).find("Phase 3") == -1:
		_fail("CH10_05 phase-3 transition should surface an explicit Phase 3 callout in the HUD transition reason.")
		return
	if String(battle.hud.transition_reason_label.text).find("Final Toll") == -1:
		_fail("CH10_05 phase-3 transition should surface Final Toll in the HUD transition reason.")
		return
	if String(battle.hud.telegraph_label.text).find("Phase 3") == -1:
		_fail("CH10_05 phase-3 transition should upgrade the telegraph card title into an explicit phase-3 surface.")
		return
	var telegraph_detail := String(battle.hud.telegraph_detail_label.text)
	if telegraph_detail.find("all allies") == -1 or telegraph_detail.find("bond") == -1:
		_fail("CH10_05 phase-3 transition should explain the all-allies pressure and bond suppression stakes on the telegraph card.")
		return
	if String(battle.hud.objective_hint_label.text).find("all allies") == -1:
		_fail("CH10_05 phase-3 transition should redirect the objective hint toward the whole-party bell pressure.")
		return
	var interface_snapshot: Dictionary = battle.get_player_interface_snapshot()
	var transition_surface: Dictionary = interface_snapshot.get("transition_surface", {})
	if String(transition_surface.get("telegraph_label", "")).find("Phase 3") == -1:
		_fail("CH10_05 player interface snapshot should expose the deepened phase-3 telegraph surface.")
		return
	if String(transition_surface.get("telegraph_detail", "")).find("suppresses bond responses") == -1:
		_fail("CH10_05 player interface snapshot should carry the cinematic bond-suppression stakes detail.")
		return
	var objective_text := String(interface_snapshot.get("objective", ""))
	if objective_text.find("bell") == -1 or objective_text.find("all allies") == -1:
		_fail("CH10_05 player interface snapshot should expose the phase-3 bell pressure objective surface.")
		return
	print("[PASS] ch10_phase3_cinematic_runner: CH10 phase-3 transition surface validated.")
	battle.queue_free()
	await process_frame
	quit(0)

func _spawn_battle(stage) -> Node:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(stage)
	await process_frame
	await process_frame
	return battle

func _finish_active_cutscene(battle) -> void:
	var safety := 0
	while is_instance_valid(battle) and battle.cutscene_player != null and battle.cutscene_player.is_playing():
		battle.cutscene_player.advance_beat_immediate()
		await process_frame
		safety += 1
		if safety > 32:
			_fail("Timed out fast-forwarding CH10_05 intro cutscene.")
			return

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
