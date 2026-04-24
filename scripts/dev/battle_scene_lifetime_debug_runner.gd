extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH07_MARKET = preload("res://data/stages/ch07_01_stage.tres")
const CH08_VANISHED_TRAIL = preload("res://data/stages/ch08_01_stage.tres")

const CASES := [
	{"label": "CH07_01", "stage": CH07_MARKET},
	{"label": "CH08_01", "stage": CH08_VANISHED_TRAIL},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var baseline_children := root.get_child_count()
	print("[DEBUG] root child count before cases: %d" % baseline_children)

	for case_data in CASES:
		await _run_case(case_data)

	var after_children := root.get_child_count()
	print("[DEBUG] root child count after cases: %d" % after_children)

	var lingering_battles: Array[String] = []
	for child in root.get_children():
		if child == null or not is_instance_valid(child):
			continue
		if String(child.name).find("Battle") != -1:
			lingering_battles.append("%s:%s" % [child.name, child.get_class()])

	if not lingering_battles.is_empty():
		push_error("Battle lifetime debug runner found lingering battle-like nodes: %s" % ", ".join(lingering_battles))
		quit(1)
		return

	print("[PASS] battle_scene_lifetime_debug_runner found no lingering battle-like root nodes after cleanup.")
	quit(0)

func _run_case(case_data: Dictionary) -> void:
	var before_case_children := root.get_child_count()
	print("[DEBUG] %s before instantiate root children: %d" % [String(case_data["label"]), before_case_children])

	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(case_data["stage"])

	await process_frame
	await process_frame

	print("[DEBUG] %s after instantiate root children: %d" % [String(case_data["label"]), root.get_child_count()])

	battle.queue_free()
	await process_frame
	await process_frame

	print("[DEBUG] %s after cleanup root children: %d" % [String(case_data["label"]), root.get_child_count()])
