extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CAMPAIGN_PANEL_SCENE: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ashes = root.get_node_or_null("Ashes")
	if ashes == null:
		_fail("Ashes autoload is missing.")
		return

	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame

	save_service.delete_slot(1)
	ashes.reset_collection()
	var progression := ProgressionData.new()
	ashes.bind_progression(progression)

	_simulate_stage_clear(ashes, "CH04_01", "ch04_boss_leonika")
	_simulate_stage_clear(ashes, "CH07_05", "ch07_enemy_captain")

	if int(ashes.get_ashes_count()) < 2:
		_fail("Ashes count should be at least 2 after the CH04/CH07 clears.")
		return
	if int(ashes.get_ashes_by_rarity("LEGENDARY").size()) != 1:
		_fail("Exactly one legendary ashes entry should be collected in the runner.")
		return
	if int(ashes.get_ashes_by_rarity("RARE").size()) != 1:
		_fail("Exactly one rare ashes entry should be collected in the runner.")
		return

	var memorial_wall_data: Array = ashes.get_memorial_wall_data()
	if not _has_entry(memorial_wall_data, "ch04_boss_leonika", "당신이 이기는 것밖에 볼 수 없군요...", "LEGENDARY"):
		_fail("CH04 Leonika ashes entry is missing or malformed.")
		return
	if not _has_entry(memorial_wall_data, "ch07_enemy_captain", "제 꿈이...", "RARE"):
		_fail("CH07 captain ashes entry is missing or malformed.")
		return

	var err := save_service.save_progression(progression, 1)
	if err != OK:
		_fail("Saving slot_1 should succeed.")
		return
	var loaded: ProgressionData = save_service.load_progression(1)
	if loaded == null or int(loaded.ashes_collected.size()) < 2:
		_fail("Ashes entries should persist through save/load in slot_1.")
		return

	ashes.bind_progression(loaded)
	var panel = CAMPAIGN_PANEL_SCENE.instantiate()
	root.add_child(panel)
	await process_frame
	panel.show_state("camp", "Ashes Memorial", "Enemy remains wall verification.", "Continue", {})
	await process_frame
	var snapshot: Dictionary = panel.get_snapshot()
	if int(snapshot.get("ashes_count", 0)) < 2:
		_fail("Campaign panel ashes wall should render at least two entries.")
		return

	print("[PASS] ashes_fallen_runner: all assertions passed.")
	panel.queue_free()
	await process_frame
	quit(0)

func _simulate_stage_clear(ashes: Node, stage_id: String, enemy_id: String) -> void:
	ashes.set_current_stage(stage_id)
	ashes.collect_ashes(enemy_id)

func _has_entry(entries: Array, enemy_id: String, last_words: String, rarity: String) -> bool:
	for entry in entries:
		if String(entry.get("enemy_id", "")) != enemy_id:
			continue
		if String(entry.get("last_words", "")).strip_edges().is_empty():
			return false
		return String(entry.get("last_words", "")) == last_words and String(entry.get("rarity", "")) == rarity
	return false

func _fail(message: String) -> void:
	print("[FAIL] %s" % message)
	quit(1)
