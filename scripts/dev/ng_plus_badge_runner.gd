extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var progression = main.battle_controller.progression_service.get_data()
	_assert(progression != null, "Main scene should expose progression data for NG+ tests.")
	if _failed:
		quit(1)
		return

	for stage_id in [
		"CH01_05",
		"CH02_05",
		"CH03_05",
		"CH04_05",
		"CH05_05",
		"CH06_05",
		"CH07_05",
		"CH08_05",
		"CH09A_05",
		"CH09B_05",
		"CH10_05"
	]:
		progression.earn_badge("stage_clear:%s:three_star" % stage_id, 3)

	for hidden_badge in [
		"hidden_objective:CH07_05:shrine",
		"hidden_objective:CH08_05:mercy",
		"hidden_objective:CH09A_04:hold",
		"hidden_objective:CH09B_05:truth",
		"hidden_objective:CH10_05:anchors"
	]:
		progression.earn_badge(hidden_badge, 2)

	progression.unlock_ally(&"lete")
	progression.unlock_ally(&"mira")
	progression.unlock_ally(&"melkion")
	progression.earn_badge("secret_recruit:lete", 5)
	progression.earn_badge("secret_recruit:mira", 5)
	progression.earn_badge("secret_recruit:melkion", 5)
	progression.earn_badge("ending:true_resolution", 10)

	_assert(progression.badges_of_heroism == 68, "Badge total should seed to 68 before purchases, got %d." % progression.badges_of_heroism)
	_assert(main.purchase_ng_plus_item("bond_anchor"), "Bond Anchor purchase should succeed at 68 badges.")
	_assert(main.purchase_ng_plus_item("veteran_squad"), "Veteran Squad purchase should succeed after Bond Anchor.")
	_assert(progression.badges_of_heroism == 43, "Badge total should drop to 43 after two purchases, got %d." % progression.badges_of_heroism)
	_assert(progression.ng_plus_purchases.has("bond_anchor"), "Bond Anchor should persist in ng_plus_purchases.")
	_assert(progression.ng_plus_purchases.has("veteran_squad"), "Veteran Squad should persist in ng_plus_purchases.")

	if _failed:
		quit(1)
		return
	print("[PASS] ng_plus_badge_runner validated badge totals and NG+ shop purchases.")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
