extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const ChronicleGenerator = preload("res://scripts/battle/chronicle_generator.gd")
const ChronicleEntry = preload("res://scripts/battle/chronicle_entry.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	save_service.delete_slot(2)

	var progression := ProgressionData.new()
	var save_error := save_service.save_progression(progression, 2)
	if save_error != OK:
		_fail("Expected fresh slot_2 save to succeed, got %s" % error_string(save_error))
		return

	progression = save_service.load_progression(2)
	var chronicle := root.get_node_or_null("Chronicle") as ChronicleGenerator
	if chronicle == null:
		chronicle = ChronicleGenerator.new()
		root.add_child(chronicle)
		await process_frame

	var cases := [
		{
			"chapter_id": "CH04_01",
			"battle_log": [{
				"turn_count": 4,
				"ally_count": 3,
				"enemy_count": 3,
				"enemies_defeated": ["enemy_raider", "enemy_skirmisher"],
				"allies_lost": [],
				"weather_events": ["downpour"],
				"key_moments": [
					{"type": "attack", "actor_id": "ally_vanguard", "target_id": "enemy_raider", "turn": 2},
					{"type": "attack", "actor_id": "ally_scout", "target_id": "enemy_skirmisher", "turn": 4},
				],
			}],
			"choices": ["hold_the_line"],
			"expected_style": ChronicleEntry.ChronicleStyle.POETIC,
		},
		{
			"chapter_id": "CH07_05",
			"battle_log": [{
				"turn_count": 8,
				"ally_count": 2,
				"enemy_count": 4,
				"enemies_defeated": ["enemy_saria", "enemy_skirmisher"],
				"allies_lost": [{"unit_id": "ally_serin", "turn": 8}],
				"weather_events": [],
				"key_moments": [
					{"type": "sacrifice_play", "actor_id": "ally_serin", "protected_unit_id": "ally_rian", "actor_died": true, "turn": 8},
					{"type": "attack", "actor_id": "ally_rian", "target_id": "enemy_saria", "turn": 8},
				],
			}],
			"choices": ["answer_the_hymn"],
			"expected_style": ChronicleEntry.ChronicleStyle.BATTLE,
		},
		{
			"chapter_id": "CH09B_05",
			"battle_log": [{
				"turn_count": 6,
				"ally_count": 2,
				"enemy_count": 3,
				"enemies_defeated": ["enemy_melkion", "enemy_skirmisher"],
				"allies_lost": [],
				"weather_events": ["rain_comfort", "rain_drain", "thunder_fear"],
				"key_moments": [
					{"type": "weather", "weather_effect_id": "rain_comfort", "turn": 2},
					{"type": "weather", "weather_effect_id": "rain_drain", "turn": 4},
					{"type": "weather", "weather_effect_id": "thunder_fear", "turn": 6},
				],
			}],
			"choices": ["trust_the_storm"],
			"expected_style": ChronicleEntry.ChronicleStyle.POETIC,
		},
	]

	var passed_cases := 0
	for case_data in cases:
		var entry := chronicle.generate_entry(String(case_data.get("chapter_id", "")), case_data.get("battle_log", []), case_data.get("choices", []))
		progression.add_chronicle_entry(entry)
		if entry.style != case_data.get("expected_style", ChronicleEntry.ChronicleStyle.CONCISE):
			_fail("%s expected style %s, got %s" % [entry.chapter_id, str(case_data.get("expected_style")), str(entry.style)])
			return
		if entry.get_formatted_text().strip_edges().is_empty():
			_fail("%s should produce non-empty formatted chronicle text" % entry.chapter_id)
			return
		passed_cases += 1

	if progression.chronicle_entries.size() != 3:
		_fail("Expected 3 chronicle entries in progression, got %d" % progression.chronicle_entries.size())
		return

	save_error = save_service.save_progression(progression, 2)
	if save_error != OK:
		_fail("Expected slot_2 chronicle save to succeed, got %s" % error_string(save_error))
		return

	var loaded := save_service.load_progression(2)
	if loaded.chronicle_entries.size() != 3:
		_fail("Expected chronicle persistence in slot_2, got %d entries after load" % loaded.chronicle_entries.size())
		return

	print("[PASS] living_chronicle_runner: %d/3 entries generated with correct styles." % passed_cases)
	quit(0)

func _fail(message: String) -> void:
	print("[FAIL] %s" % message)
	quit(1)
