extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH04_03_STAGE = preload("res://data/stages/ch04_03_stage.tres")
const CH06_02_STAGE = preload("res://data/stages/ch06_02_stage.tres")
const CH10_05_STAGE = preload("res://data/stages/ch10_05_stage.tres")

const CASES := [
	{"chapter_id": &"CH04", "stage_index": 2, "stage_id": &"CH04_03", "stage": CH04_03_STAGE},
	{"chapter_id": &"CH06", "stage_index": 1, "stage_id": &"CH06_02", "stage": CH06_02_STAGE},
	{"chapter_id": &"CH10", "stage_index": 4, "stage_id": &"CH10_05", "stage": CH10_05_STAGE},
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
		push_error("Briefing usage expansion runner could not resolve campaign controller.")
		quit(1)
		return

	for case_data in CASES:
		var stage_id: StringName = case_data.get("stage_id", StringName())
		var stage = case_data.get("stage", null)
		if stage == null:
			push_error("Missing stage resource for %s." % String(stage_id))
			quit(1)
			return

		campaign._active_chapter_id = case_data.get("chapter_id", StringName())
		campaign._active_stage_index = int(case_data.get("stage_index", 0))
		campaign._current_stage = stage.duplicate(true)
		campaign._briefing_abort_active = false

		if not campaign._should_show_briefing(stage_id):
			push_error("Expected expanded briefing trigger for %s." % String(stage_id))
			quit(1)
			return

		var briefing: Dictionary = campaign._get_briefing_data(stage_id)
		if briefing.is_empty():
			push_error("Expected authored briefing data for %s." % String(stage_id))
			quit(1)
			return

		campaign._enter_briefing_state(stage_id)
		await process_frame
		await process_frame

		var snapshot: Dictionary = main.get_campaign_state_snapshot()
		if String(snapshot.get("mode", "")) != "briefing":
			push_error("Expected briefing mode for %s, got %s." % [String(stage_id), snapshot.get("mode", "")])
			quit(1)
			return

		var body: String = String(snapshot.get("panel_body", ""))
		if body.find("적 정보") == -1:
			push_error("Expected enemy intel section for %s." % String(stage_id))
			quit(1)
			return
		if body.find("지형 요약") == -1:
			push_error("Expected terrain summary section for %s." % String(stage_id))
			quit(1)
			return
		if body.find("선택 목표") == -1:
			push_error("Expected optional objectives section for %s." % String(stage_id))
			quit(1)
			return

	print("[PASS] briefing_usage_expansion_runner validated authored briefing expansion for CH04_03, CH06_02, and CH10_05.")
	quit(0)
