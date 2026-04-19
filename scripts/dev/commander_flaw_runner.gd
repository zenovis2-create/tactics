extends SceneTree

const CommanderProfile = preload("res://scripts/battle/commander_profile.gd")
const TacticalFlawDetector = preload("res://scripts/battle/tactical_flaw_detector.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

const SAVE_SLOT := 4

var _warning_count := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame

	save_service.delete_slot(SAVE_SLOT)
	var fresh_data := ProgressionData.new()
	var save_err := save_service.save_progression(fresh_data, SAVE_SLOT)
	if save_err != OK:
		_fail("save_progression should succeed for fresh slot_4")
		return

	var loaded_data := save_service.load_progression(SAVE_SLOT)
	if loaded_data == null:
		_fail("load_progression should return a ProgressionData instance for slot_4")
		return

	var detector := root.get_node_or_null("FlawDetector") as TacticalFlawDetector
	if detector == null:
		detector = TacticalFlawDetector.new()
		root.add_child(detector)
		await process_frame

	if detector.has_signal("flaw_warning_requested"):
		var warning_callable := Callable(self, "_on_flaw_warning_requested")
		if not detector.is_connected("flaw_warning_requested", warning_callable):
			detector.connect("flaw_warning_requested", warning_callable)

	detector.begin_battle(loaded_data)

	var chapter_actions: Array = []
	var detected_flaw := CommanderProfile.FlawType.NONE
	for turn_index in range(1, 4):
		var action := {
			"action_type": "move",
			"lane": "backline",
			"backline_only": true,
			"turn_index": turn_index,
			"unit_id": "ally_rian",
			"position": Vector2i(5, 0),
			"acted": true
		}
		chapter_actions.append(action)
		detected_flaw = detector.detect_flaw_pattern(action, chapter_actions)
		detector.apply_flaw_to_profile(detected_flaw)

	if detected_flaw != CommanderProfile.FlawType.PERSISTENT_BACKLINE:
		_fail("Three consecutive backline-only moves should detect PERSISTENT_BACKLINE")
		return

	if detector.current_profile.flaw_type != CommanderProfile.FlawType.PERSISTENT_BACKLINE:
		_fail("current_profile should store PERSISTENT_BACKLINE after detection")
		return

	if detector.current_profile.repetition_count < 3:
		_fail("repetition_count should reflect the three repeated backline decisions")
		return

	if detector.current_profile.severity < 0.6:
		_fail("severity should reach at least 0.6 after three repetitions, got %.2f" % detector.current_profile.severity)
		return

	if detector.current_profile.active_penalty.is_empty():
		_fail("active_penalty should be applied once severity reaches the activation threshold")
		return

	if not detector.current_profile.active_penalty.has("backline_unit_attack"):
		_fail("PERSISTENT_BACKLINE should apply the backline_unit_attack penalty")
		return

	if float(detector.current_profile.active_penalty.get("backline_unit_attack", 0.0)) != -0.10:
		_fail("backline_unit_attack penalty should be -0.10")
		return

	if detector.current_profile.flaw_description.strip_edges().is_empty():
		_fail("flaw_description should be non-empty after a flaw is detected")
		return

	var extra_action := {
		"action_type": "move",
		"lane": "backline",
		"backline_only": true,
		"turn_index": 4,
		"unit_id": "ally_rian",
		"position": Vector2i(5, 0),
		"acted": true
	}
	chapter_actions.append(extra_action)
	detected_flaw = detector.detect_flaw_pattern(extra_action, chapter_actions)
	detector.apply_flaw_to_profile(detected_flaw)
	if _warning_count != 1:
		_fail("Flaw warning should trigger only once per battle, got %d" % _warning_count)
		return

	print("[PASS] commander_flaw_runner: flaw detection and application verified.")
	quit(0)

func _on_flaw_warning_requested(_message: String, _flaw_type: int) -> void:
	_warning_count += 1

func _fail(message: String) -> void:
	print("[FAIL] %s" % message)
	quit(1)
