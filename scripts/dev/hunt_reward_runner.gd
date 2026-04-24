extends SceneTree

const CampController = preload("res://scripts/camp/camp_controller.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var progression := ProgressionData.new()
	progression.unlocked_hunt_ids = [&"hunt_basil", &"hunt_saria", &"hunt_lete"]

	var controller := CampController.new()
	root.add_child(controller)
	await process_frame

	var hunt_result: Dictionary = controller.resolve_hunt_victory(&"hunt_lete", progression, {
		"optional_objectives_completed": ["hunt_lete_black_hounds_preserved"],
		"battle_temp_flags": {"hunt_lete_gate_latch": true}
	})
	if not progression.recovered_fragments.has(&"mem_frag_lete_hunt"):
		return _fail("Hunt victory should persist the hunt memory fragment into progression.")
	if not bool(progression.flags.get("flag_hunt_lete_cleared", false)):
		return _fail("Hunt victory should persist a cleared flag for the hunt.")
	if not bool(progression.flags.get("flag_evidence_lete_hunt_route", false)):
		return _fail("Hunt victory should persist hunt-specific evidence flags.")
	if progression.get_material_count(&"mat_lete_black_hound_fang") != 4:
		return _fail("Hunt victory should persist hunt-specific material rewards.")
	var reward_entries: Array = hunt_result.get("reward_entries", [])
	if reward_entries.size() < 3:
		return _fail("Hunt victory should surface base payout plus branch reward entries.")
	if String(reward_entries[0]).find("재료 보상") == -1:
		return _fail("Hunt reward entries should expose hunt-specific material payout first.")
	if String(reward_entries[1]).find("금화 보상") == -1:
		return _fail("Hunt reward entries should still expose committed gold gain.")
	if String(reward_entries[2]).find("흑견 보존 보너스") == -1:
		return _fail("Hunt reward entries should expose branch bonus payout when the optional objective is completed.")
	if progression.gold <= 0:
		return _fail("Hunt victory should commit gold directly into progression.")
	if String(hunt_result.get("return_summary", "")).find("흑견 추격대 보존 성공") == -1:
		return _fail("Hunt return summary should branch when the optional objective is completed.")
	if String(hunt_result.get("return_cutscene_override", "")).find("이송문 걸쇠") == -1:
		return _fail("Hunt return cutscene override should branch when the recall rule object was resolved.")
	var branch_card: Dictionary = hunt_result.get("branch_card", {})
	if String(branch_card.get("title", "")).find("흑견 추격대 보존") == -1:
		return _fail("Hunt result should expose a dedicated branch presentation card title.")

	var camp_data = controller.enter_camp(&"ch08", hunt_result, progression)
	if camp_data.get_notification_count() < 2:
		return _fail("Camp entry should surface hunt rewards as pending notifications.")
	var summary: Dictionary = controller.get_camp_summary()
	var memory_entries: Array = summary.get("memory_entries", [])
	var surfaced_rewards: Array = summary.get("reward_entries", [])
	var last_hunt_result: Dictionary = summary.get("last_hunt_result", {})
	if memory_entries.is_empty() or String(memory_entries[0]).find("mem_frag_lete_hunt") == -1:
		return _fail("Camp summary should surface the recovered hunt fragment.")
	if surfaced_rewards.is_empty():
		return _fail("Camp summary should surface pending hunt reward entries.")
	if String(last_hunt_result.get("hunt_display_name", "")).find("레테") == -1:
		return _fail("Camp summary should retain the last cleared hunt return context.")
	if String(last_hunt_result.get("return_summary", "")).find("난이도 5") == -1:
		return _fail("Hunt return summary should preserve hunt-specific difficulty context.")
	if String(last_hunt_result.get("return_cutscene_override", "")).find("이송문 걸쇠") == -1:
		return _fail("Camp summary should retain the branched return cutscene override.")
	if String(Dictionary(last_hunt_result.get("branch_card", {})).get("title", "")).find("흑견 추격대 보존") == -1:
		return _fail("Camp summary should retain the dedicated branch presentation card payload.")

	print("[PASS] hunt_reward_runner: hunt result/reward persistence and camp surface checks passed.")
	quit(0)

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
