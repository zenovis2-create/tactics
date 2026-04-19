extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH01_FINAL_STAGE = preload("res://data/stages/ch01_05_stage.tres")
const CRITICAL_PLACEHOLDER_FRAGMENT := "/audio/sfx/"
const PRODUCTION_MANIFEST_PATH := "res://data/audio/sfx_manifest.json"
const PLACEHOLDER_MANIFEST_PATH := "res://data/audio/sfx_placeholder_manifest.json"

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)

	await process_frame
	await process_frame

	if main.audio_event_router == null:
		_fail("Main should expose AudioEventRouter.")
		return

	var battle = main.battle_controller
	battle.hud.open_inventory_panel()
	await process_frame
	_assert_last_cue(main, "ui_inventory_open_01")
	_assert_resolved_asset(main, "ui_inventory_open_01")
	if _failed:
		return

	battle.hud.close_inventory_panel()
	await process_frame
	_assert_last_cue(main, "ui_inventory_close_01")
	_assert_resolved_asset(main, "ui_inventory_close_01")
	if _failed:
		return

	battle.hud._on_wait_pressed()
	await process_frame
	_assert_last_cue(main, "ui_common_confirm_01")
	_assert_manifest_source(main, "ui_common_confirm_01", PRODUCTION_MANIFEST_PATH)
	if _failed:
		return

	battle.hud._on_cancel_pressed()
	await process_frame
	_assert_last_cue(main, "ui_common_cancel_01")
	_assert_manifest_source(main, "ui_common_cancel_01", PRODUCTION_MANIFEST_PATH)
	if _failed:
		return

	battle.hud.set_transition_reason("boss_mark_telegraphed")
	await process_frame
	_assert_last_cue(main, "battle_boss_mark_warn_01")
	_assert_resolved_asset(main, "battle_boss_mark_warn_01")
	_assert_critical_placeholder_asset(main, "battle_boss_mark_warn_01")
	if _failed:
		return

	battle.hud.set_transition_reason("boss_command_buff")
	await process_frame
	_assert_last_cue(main, "battle_boss_command_warn_01")
	_assert_critical_placeholder_asset(main, "battle_boss_command_warn_01")
	if _failed:
		return

	battle.hud.set_transition_reason("boss_charge_resolve")
	await process_frame
	_assert_last_cue(main, "battle_boss_charge_impact_01")
	_assert_resolved_asset(main, "battle_boss_charge_impact_01")
	_assert_critical_placeholder_asset(main, "battle_boss_charge_impact_01")
	if _failed:
		return

	battle.hud.set_transition_reason("attack_resolved_deterministic")
	await process_frame
	_assert_last_cue(main, "battle_hit_confirm_01")
	_assert_critical_placeholder_asset(main, "battle_hit_confirm_01")
	if _failed:
		return

	battle.hud.set_transition_reason("attack_missed")
	await process_frame
	_assert_last_cue(main, "battle_miss_01")
	_assert_critical_placeholder_asset(main, "battle_miss_01")
	if _failed:
		return

	var campaign = main.campaign_controller
	campaign._active_chapter_id = &"CH01"
	campaign._active_stage_index = 3
	campaign._current_stage = CH01_FINAL_STAGE
	campaign._enter_camp_state()
	await process_frame
	await process_frame

	main.campaign_panel.select_party_index(1)
	await process_frame
	_assert_last_cue(main, "camp_party_select_01")
	_assert_resolved_asset(main, "camp_party_select_01")
	_assert_manifest_source(main, "camp_party_select_01", PRODUCTION_MANIFEST_PATH)
	if _failed:
		return

	main.campaign_panel.cycle_selected_party_weapon()
	await process_frame
	_assert_last_cue(main, "camp_loadout_weapon_cycle_01")
	_assert_resolved_asset(main, "camp_loadout_weapon_cycle_01")
	if _failed:
		return

	main.campaign_panel.assign_selected_party_member()
	await process_frame
	_assert_last_cue(main, "camp_party_assign_01")
	_assert_resolved_asset(main, "camp_party_assign_01")
	if _failed:
		return

	main.campaign_panel._select_section("party")
	await process_frame
	_assert_last_cue(main, "ui_panel_tab_shift_01")
	_assert_resolved_asset(main, "ui_panel_tab_shift_01")
	_assert_manifest_source(main, "ui_panel_tab_shift_01", PRODUCTION_MANIFEST_PATH)
	if _failed:
		return

	main.campaign_panel._on_advance_pressed()
	await process_frame
	_assert_history_contains(main, "camp_next_battle_confirm_01")
	_assert_manifest_source(main, "camp_next_battle_confirm_01", PRODUCTION_MANIFEST_PATH)
	_assert_no_missing_cues(main)
	if _failed:
		return

	print("[PASS] SFX trigger integration runner validated cue routing across battle and camp surfaces.")
	quit(0)

func _assert_last_cue(main, expected: String) -> void:
	var snapshot: Dictionary = main.audio_event_router.get_snapshot()
	if String(snapshot.get("last_cue", "")) != expected:
		_fail("Expected last cue %s, got %s." % [expected, snapshot.get("last_cue", "")])

func _assert_history_contains(main, expected: String) -> void:
	var snapshot: Dictionary = main.audio_event_router.get_snapshot()
	var history: Array = snapshot.get("cue_history", [])
	for cue in history:
		if String(cue) == expected:
			return
	_fail("Expected cue history to contain %s, got %s." % [expected, history])

func _assert_resolved_asset(main, expected_cue: String) -> void:
	var snapshot: Dictionary = main.audio_event_router.get_snapshot()
	var asset_path := String(snapshot.get("last_asset_path", ""))
	if asset_path.is_empty():
		_fail("Expected cue %s to resolve to an asset path." % expected_cue)
		return
	if not asset_path.contains(expected_cue):
		_fail("Expected asset path for %s to contain cue id, got %s." % [expected_cue, asset_path])
		return

func _assert_critical_placeholder_asset(main, expected_cue: String) -> void:
	main.audio_event_router._resolve_stream(expected_cue)
	var snapshot: Dictionary = main.audio_event_router.get_snapshot()
	var asset_path := String(snapshot.get("last_asset_path", ""))
	if not asset_path.contains(CRITICAL_PLACEHOLDER_FRAGMENT):
		_fail("Expected cue %s to resolve under %s, got %s." % [expected_cue, CRITICAL_PLACEHOLDER_FRAGMENT, asset_path])
	_assert_manifest_source(main, expected_cue, PLACEHOLDER_MANIFEST_PATH)

func _assert_manifest_source(main, expected_cue: String, expected_manifest_path: String) -> void:
	main.audio_event_router._resolve_stream(expected_cue)
	var snapshot: Dictionary = main.audio_event_router.get_snapshot()
	var manifest_path := String(snapshot.get("last_manifest_path", ""))
	if manifest_path != expected_manifest_path:
		_fail("Expected cue %s to resolve from %s, got %s." % [expected_cue, expected_manifest_path, manifest_path])

func _assert_no_missing_cues(main) -> void:
	var snapshot: Dictionary = main.audio_event_router.get_snapshot()
	var missing: Array = snapshot.get("missing_cues", [])
	if not missing.is_empty():
		_fail("Expected no missing cues, got %s." % [missing])

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
