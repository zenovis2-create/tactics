extends SceneTree

const BattleResultScreen = preload("res://scripts/battle/battle_result_screen.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var progression := ProgressionData.new()
	progression.badges_of_heroism = 43
	progression.sacrificed_units = [{
		"unit_id": "ally_serin",
		"name": "Serin",
		"epitaph": "She held the bridge lantern high enough for the squad to cross."
	}]
	progression.epitaphs = ["Serin — She held the bridge lantern high enough for the squad to cross."]

	var result := {
		"title": "Victory",
		"objective": "Hold the northern bridge.",
		"reward_entries": [],
		"unit_exp_results": [],
		"memory_entries": [],
		"evidence_entries": [],
		"letter_entries": [],
		"progression_data": progression,
		"badge_narrative": ""
	}

	var screen := BattleResultScreen.new()
	root.add_child(screen)
	await process_frame
	await process_frame

	screen.show_result(result)
	await process_frame

	var snapshot: Dictionary = screen.get_result_snapshot()
	_assert(bool(snapshot.get("badge_narrative_visible", false)), "Badge narrative panel should be visible when badges are seeded.")
	_assert(String(snapshot.get("badge_narrative_summary", "")).find("Badges of Heroism: 43") != -1, "Summary should include the badge total line.")
	_assert(String(snapshot.get("badge_narrative_summary", "")).find("43 badges = 43전 43생 = 1 true death") != -1, "Summary should include the rebirth tagline.")
	_assert(String(result.get("badge_narrative", "")).find("당신은 43전투를 치렀다.") != -1, "Result summary dict should receive the generated badge_narrative text.")
	_assert(String(result.get("badge_narrative", "")).find("Serin — She held the bridge lantern high enough for the squad to cross.") != -1, "Narrative should mention the fallen name and epitaph.")
	_assert(String(snapshot.get("badge_narrative_stone", "")).find("이 이름은 石에 새겨졌다") != -1, "Stone text should mark the fallen name as engraved.")

	screen.queue_free()
	await process_frame

	if _failed:
		print("[FAIL] badge_narrative_runner detected a badge/death narrative regression.")
		quit(1)
		return
	print("[PASS] badge_narrative_runner: retry-as-rebirth narrative renders badge totals, epitaphs, and engraved memorial text.")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
