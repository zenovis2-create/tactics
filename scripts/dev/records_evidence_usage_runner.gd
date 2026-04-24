extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH05_03_STAGE = preload("res://data/stages/ch05_03_stage.tres")
const CH07_01_STAGE = preload("res://data/stages/ch07_01_stage.tres")

const CASES := [
	{
		"chapter_id": &"CH05",
		"stage": CH05_03_STAGE,
		"expected_fragment": "stack_seal_noted"
	},
	{
		"chapter_id": &"CH07",
		"stage": CH07_01_STAGE,
		"expected_fragment": "queue_bell_logged"
	}
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)

	await process_frame
	await process_frame

	main.start_game_direct()
	await process_frame
	await process_frame

	var campaign = main.campaign_controller
	if campaign == null:
		push_error("Records evidence usage runner could not resolve campaign controller.")
		quit(1)
		return

	for case_data in CASES:
		var stage = case_data.get("stage", null)
		if stage == null:
			push_error("Missing stage resource in records evidence usage runner.")
			quit(1)
			return

		campaign._active_chapter_id = case_data.get("chapter_id", StringName())
		campaign._current_stage = stage.duplicate(true)
		campaign._commit_stage_rewards(campaign._current_stage)

		var payload: Dictionary = campaign._build_panel_payload("camp")
		var evidence_entries: Array = payload.get("evidence_entries", [])
		if evidence_entries.is_empty():
			push_error("Expected evidence entries after committing %s." % StringName(campaign._current_stage.stage_id))
			quit(1)
			return

		var expected_fragment: String = String(case_data.get("expected_fragment", ""))
		var found := false
		for entry in evidence_entries:
			if String(entry).find(expected_fragment) != -1:
				found = true
				break
		if not found:
			push_error("Expected evidence fragment %s in records payload for %s." % [expected_fragment, StringName(campaign._current_stage.stage_id)])
			quit(1)
			return

	print("[PASS] records_evidence_usage_runner validated CH05_03 and CH07_01 evidence entries through the records payload.")
	quit(0)
