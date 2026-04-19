extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const TacticalNote = preload("res://scripts/battle/tactical_note.gd")
const TacticalNoteManager = preload("res://scripts/battle/tactical_note_manager.gd")

const SAVE_SLOT := 7
const BATTLE_CONTROLLER_SCRIPT_PATH := "res://scripts/battle/battle_controller.gd"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	save_service.delete_slot(SAVE_SLOT)

	var tactics := root.get_node_or_null("Tactics") as TacticalNoteManager
	if tactics == null:
		tactics = TacticalNoteManager.new()
		tactics.name = "Tactics"
		root.add_child(tactics)
		await process_frame

	tactics.set_active_slot(SAVE_SLOT)
	_assert(tactics.notes.size() == 0, "Fresh slot_7 should start with zero tactical notes.")

	var dragon_note := tactics.create_note(
		"용의 특공대",
		["dragon"],
		[{"unit_id": "ally_rian", "position": Vector2i(1, 1), "role": "vanguard"}],
		"비동기 전술 테스트용 고난도 돌격 노트",
		4
	)
	var defense_note := tactics.create_note(
		"방어선",
		["defense"],
		[{"unit_id": "ally_serin", "position": Vector2i(0, 2), "role": "guard"}],
		"정면 유지용 방어 노트",
		2
	)
	var boss_note := tactics.create_note(
		"레온니카屠宰",
		["boss"],
		[{"unit_id": "ally_noah", "position": Vector2i(2, 0), "role": "finisher"}],
		"보스전 화력 집중 전술",
		5
	)

	_assert(tactics.notes.size() == 3, "Expected 3 tactical notes after creation.")
	_assert(tactics.get_notes_by_tag("dragon").size() == 1, "Expected exactly one dragon-tagged tactic.")
	_assert(tactics.get_notes_by_difficulty(5).size() == 1, "Expected exactly one difficulty 5 tactic.")

	tactics.delete_note(defense_note.note_id)
	_assert(tactics.notes.size() == 2, "Expected 2 tactical notes after deleting 방어선.")

	tactics.increment_usage(dragon_note.note_id)
	var refreshed_dragon_note := tactics.get_note_by_id(dragon_note.note_id)
	_assert(refreshed_dragon_note != null and refreshed_dragon_note.usage_count == 1, "Expected increment_usage to raise usage_count to 1.")

	var battle_script: Variant = load(BATTLE_CONTROLLER_SCRIPT_PATH)
	_assert(battle_script is GDScript and battle_script.can_instantiate(), "Expected BattleController script to load for tactical bonus verification.")
	var battle: Node = battle_script.new()
	var bonus: float = float(battle.call("_get_tactical_note_bonus", refreshed_dragon_note))
	_assert(is_equal_approx(bonus, 1.2), "Expected tactical note bonus to equal 1.2 for difficulty 4.")
	battle.free()

	var reloaded_progression := save_service.load_progression(SAVE_SLOT)
	_assert(reloaded_progression.tactical_notes.size() == 2, "Expected persisted tactical notes count to be 2 after reload.")
	var persisted_note := reloaded_progression.tactical_notes[0] as TacticalNote
	_assert(persisted_note != null and persisted_note.usage_count == 1, "Expected persisted usage_count to remain 1 after reload.")
	_assert(tactics.get_note_by_id(boss_note.note_id) != null, "Expected boss tactic to remain accessible by ID.")

	print("[PASS] async_tactics_runner: tactical note CRUD, filtering, persistence, and battle bonus verified.")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	print("[FAIL] %s" % message)
	quit(1)
