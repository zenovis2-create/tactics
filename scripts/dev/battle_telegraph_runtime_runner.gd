extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH01_BOSS_STAGE = preload("res://data/stages/ch01_05_stage.tres")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(CH01_BOSS_STAGE)

	await process_frame
	await process_frame

	var boss = battle.enemy_units[0]
	var ally = battle.ally_units[0]
	battle._apply_enemy_action(boss, {"type": "boss_mark", "target": ally})
	await process_frame

	if battle.hud.telegraph_card == null or not battle.hud.telegraph_card.visible:
		_fail("BattleHUD should show the telegraph card after boss_mark_telegraphed.")
		return

	if battle.hud.telegraph_preview.texture == null:
		_fail("BattleHUD telegraph preview should render a runtime texture.")
		return

	if battle.hud.telegraph_label.text.find("Mark") == -1:
		_fail("BattleHUD telegraph label should identify the mark state.")
		return

	if ally.telegraph_icon == null or ally.telegraph_icon.texture == null:
		_fail("Marked unit should render a runtime telegraph icon.")
		return

	battle.hud.set_transition_reason("enemy_phase_open")
	await process_frame
	if battle.hud.telegraph_label.text.find("Danger") == -1:
		_fail("BattleHUD should switch to the danger telegraph during enemy phase.")
		return

	battle.hud.set_transition_reason("interaction_resolved")
	await process_frame
	if battle.hud.telegraph_label.text.find("Support") == -1:
		_fail("BattleHUD should surface the support telegraph on interaction progress.")
		return

	print("[PASS] Battle telegraph runtime runner validated hostile and support telegraph surfaces.")
	quit(0)

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
