extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const NPCPersonalityTracker = preload("res://scripts/battle/npc_personality_tracker.gd")
const AdaptiveDialogueFilter = preload("res://scripts/battle/adaptive_dialogue_filter.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	save_service.delete_slot(11)

	var progression := ProgressionData.new()
	var save_error := save_service.save_progression(progression, 11)
	if save_error != OK:
		_fail("Expected fresh slot_11 save to succeed, got %s" % error_string(save_error))
		return
	progression = save_service.load_progression(11)

	var personality = _resolve_personality_tracker()
	var adaptive_filter = _resolve_adaptive_filter()
	if personality == null or adaptive_filter == null:
		_fail("Adaptive narrative autoloads should be available for verification.")
		return

	personality.reset(progression)
	if not _assert(is_equal_approx(personality.get_attitude("leonika"), -10.0), "Fresh slot_11 should start Leonika at -10 attitude."):
		return
	personality.modify_attitude("leonika", 25.0)
	if not _assert(is_equal_approx(personality.get_attitude("leonika"), 15.0), "Leonika attitude should become +15 after a +25 adjustment."):
		return
	var leonika_friendly := String(personality.get_npc_dialogue_variant("leonika", "ch10_final"))
	if not _assert(leonika_friendly.find("지도자") != -1, "Positive Leonika finale dialogue should contain 지도자."):
		return

	personality.reset(progression)
	personality.modify_attitude("leonika", -40.0)
	if not _assert(is_equal_approx(personality.get_attitude("leonika"), -50.0), "Leonika attitude should become -50 after a -40 adjustment."):
		return
	var leonika_hostile := String(personality.get_npc_dialogue_variant("leonika", "ch10_final"))
	if not _assert(leonika_hostile.find("피가") != -1, "Hostile Leonika finale dialogue should contain 피가."):
		return

	personality.reset(progression)
	personality.modify_attitude("rian", 5.0)
	if not _assert(is_equal_approx(personality.get_attitude("rian"), 5.0), "Rian attitude should become +5 after a +5 adjustment."):
		return
	var rian_variant := String(personality.get_npc_dialogue_variant("rian", "support_b"))
	if not _assert(rian_variant.find("_FRIENDLY") != -1, "Positive Rian support_b dialogue should use the friendly suffix."):
		return
	if not _assert(String(adaptive_filter.get_adapted_dialogue_key("rian", "support_b")) == rian_variant, "AdaptiveDialogueFilter should forward the resolved support_b variant."):
		return

	print("[PASS] adaptive_narrative_runner: Leonika and Rian adaptive dialogue variants validated on fresh slot_11.")
	quit(0)

func _resolve_personality_tracker():
	var tracker = root.get_node_or_null("NPCPersonality")
	if tracker != null:
		return tracker
	tracker = NPCPersonalityTracker.new()
	tracker.name = "NPCPersonality"
	root.add_child(tracker)
	return tracker

func _resolve_adaptive_filter():
	var adaptive_filter = root.get_node_or_null("AdaptiveDialogueFilter")
	if adaptive_filter != null:
		return adaptive_filter
	adaptive_filter = AdaptiveDialogueFilter.new()
	adaptive_filter.name = "AdaptiveDialogueFilter"
	root.add_child(adaptive_filter)
	return adaptive_filter

func _assert(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false

func _fail(message: String) -> void:
	_failed = true
	print("[FAIL] %s" % message)
	quit(1)
