extends SceneTree

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EncyclopediaPanelScene = preload("res://scenes/ui/encyclopedia_panel.tscn")

const SERIN_COMMENT := "Serin은 마지막까지 다리의 빛을 붙잡았다. 이 유닛을 기억하는 가장 좋은 방법은, 모두가 건널 때까지 먼저 뒤를 돌아본 사람으로 남겨 두는 것이다."

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var progression := ProgressionData.new()
	_seed_progression(progression)

	var encyclopedia = EncyclopediaPanelScene.instantiate()
	root.add_child(encyclopedia)
	await process_frame
	encyclopedia.show_encyclopedia(progression, &"CH05")
	await process_frame

	if not _assert_comment_flow(encyclopedia, progression):
		return

	encyclopedia.hide_panel()
	await process_frame
	encyclopedia.show_encyclopedia(progression, &"CH05")
	await process_frame
	encyclopedia.select_codex_entry("ally_serin")
	await process_frame

	if not _assert_comment_persists_on_reentry(encyclopedia, progression):
		return

	print("[PASS] encyclopedia_comment_runner: comment save and re-entry assertions passed.")
	quit(0)

func _seed_progression(progression: ProgressionData) -> void:
	progression.encyclopedia_entries = {
		"ally_serin": {
			"name": "Serin",
			"type": "Ally",
			"chapter_introduced": 1,
			"stats": {"hp": 16, "attack": 5, "defense": 3, "movement": 5, "range": 2},
			"quote": "No one gets left in the smoke.",
			"support_rank": 2
		},
		"ally_rian": {
			"name": "Rian",
			"type": "Ally",
			"chapter_introduced": 1,
			"stats": {"hp": 18, "attack": 6, "defense": 4, "movement": 4, "range": 1},
			"quote": "I remember enough to keep walking.",
			"support_rank": 3
		}
	}

func _assert_comment_flow(encyclopedia, progression: ProgressionData) -> bool:
	encyclopedia.select_codex_entry("ally_serin")
	encyclopedia.open_comment_editor("ally_serin")
	encyclopedia.set_comment_draft(SERIN_COMMENT)

	var editing_snapshot: Dictionary = encyclopedia.get_snapshot()
	if not bool(editing_snapshot.get("comment_editor_visible", false)):
		return _fail("Comment editor should open from the Serin codex card.")
	if String(editing_snapshot.get("comment_counter_text", "")) != "%d/280" % SERIN_COMMENT.length():
		return _fail("Comment editor should show the live 280-character counter.")

	encyclopedia.save_comment_draft()

	if progression.get_encyclopedia_comment(&"ally_serin") != SERIN_COMMENT:
		return _fail("Saving the comment should persist it into progression_data encyclopedia_comments.")
	var history: Array[Dictionary] = progression.get_comment_history_for_unit(&"ally_serin")
	if history.size() != 1:
		return _fail("Saving a codex comment should add a single comment history entry.")
	var history_entry := history[0]
	if String(history_entry.get("unit_id", "")) != "ally_serin":
		return _fail("Comment history should record the unit_id for the saved comment.")
	if String(history_entry.get("who", "")).strip_edges().is_empty() or String(history_entry.get("when", "")).strip_edges().is_empty():
		return _fail("Comment history should record who and when for the saved comment.")

	var saved_snapshot: Dictionary = encyclopedia.get_snapshot()
	if String(saved_snapshot.get("selected_comment", "")) != SERIN_COMMENT:
		return _fail("Codex snapshot should surface the freshly saved Serin comment immediately.")
	if String(saved_snapshot.get("codex_detail", "")).find("PLAYER NOTES") == -1:
		return _fail("Codex detail should include the PLAYER NOTES section after saving a comment.")
	if String(saved_snapshot.get("codex_detail", "")).find(SERIN_COMMENT) == -1:
		return _fail("Codex detail should render the saved Serin comment in the detail view.")
	return true

func _assert_comment_persists_on_reentry(encyclopedia, progression: ProgressionData) -> bool:
	if progression.get_encyclopedia_comment(&"ally_serin") != SERIN_COMMENT:
		return _fail("Serin comment should still exist in progression data after reopening the encyclopedia.")
	var reopened_snapshot: Dictionary = encyclopedia.get_snapshot()
	if String(reopened_snapshot.get("selected_comment", "")) != SERIN_COMMENT:
		return _fail("Reopened encyclopedia should load the saved Serin comment into the selected codex entry.")
	if String(reopened_snapshot.get("codex_detail", "")).find(SERIN_COMMENT) == -1:
		return _fail("Reopened codex detail should still display the saved Serin comment.")
	if int(reopened_snapshot.get("comment_history_count", 0)) != 1:
		return _fail("Reopened encyclopedia should still report the saved comment history for Serin.")
	return true

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
