extends SceneTree

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const CampController = preload("res://scripts/camp/camp_controller.gd")
const BattleResultScreen = preload("res://scripts/battle/battle_result_screen.gd")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _assert_progression_command_diff():
        return
    if not _assert_progression_fragment_diff():
        return
    if not await _assert_battle_result_unlock_visibility():
        return
    if not await _assert_camp_summary_unlock_visibility():
        return
    if not _assert_progression_service_unlock_logs():
        return

    print("[PASS] s4a_unlock_visibility_runner: all assertions passed.")
    quit(0)

func _assert_progression_command_diff() -> bool:
    var data: ProgressionData = ProgressionData.new()
    if not data.has_method("get_newly_unlocked_commands"):
        return _fail("ProgressionData must implement get_newly_unlocked_commands().")
    if not data.has_method("snapshot_unlock_state"):
        return _fail("ProgressionData must implement snapshot_unlock_state().")

    data.unlocked_commands[&"tactical_shift"] = true
    data.unlocked_commands[&"cover_advance"] = true
    data.snapshot_unlock_state()
    data.unlocked_commands[&"rally_cry"] = true

    var recent: Array[String] = data.get_newly_unlocked_commands()
    if recent.size() != 1 or recent[0] != "rally_cry":
        return _fail("get_newly_unlocked_commands() should return only commands unlocked after the snapshot.")
    return true

func _assert_progression_fragment_diff() -> bool:
    var data: ProgressionData = ProgressionData.new()
    if not data.has_method("get_recently_recovered_fragments"):
        return _fail("ProgressionData must implement get_recently_recovered_fragments().")
    if not data.has_method("snapshot_unlock_state"):
        return _fail("ProgressionData must implement snapshot_unlock_state().")

    data.recovered_fragments[&"ch01_fragment"] = true
    data.snapshot_unlock_state()
    data.recovered_fragments[&"ch02_fragment"] = true
    data.recovered_fragments[&"ch03_fragment"] = true

    var recent: Array[String] = data.get_recently_recovered_fragments()
    if recent.size() != 2:
        return _fail("get_recently_recovered_fragments() should return only fragments recovered after the snapshot.")
    if recent[0] != "ch02_fragment" or recent[1] != "ch03_fragment":
        return _fail("Recently recovered fragments should remain sorted and exclude older fragments.")
    return true

func _assert_battle_result_unlock_visibility() -> bool:
    var screen: BattleResultScreen = BattleResultScreen.new()
    root.add_child(screen)
    await process_frame

    screen.show_result({
        "title": "Victory",
        "command_unlocked": "tactical_shift",
        "recovered_fragment_ids": ["ch01_fragment"]
    })

    var body_text := String(screen.body_label.text if screen.body_label != null else "")
    screen.queue_free()

    if body_text.find("해금") == -1:
        return _fail("BattleResultScreen victory summary should include a 해금 entry when a command unlocks.")
    if body_text.find("tactical_shift") == -1:
        return _fail("BattleResultScreen unlock entry should include the unlocked command id.")
    return true

func _assert_camp_summary_unlock_visibility() -> bool:
    var ctrl: CampController = CampController.new()
    root.add_child(ctrl)
    await process_frame

    var data: ProgressionData = ProgressionData.new()
    data.recovered_fragments[&"ch01_fragment"] = true
    data.unlocked_commands[&"tactical_shift"] = true
    data.snapshot_unlock_state()
    data.recovered_fragments[&"ch02_fragment"] = true
    data.unlocked_commands[&"cover_advance"] = true

    ctrl.enter_camp(&"ch02", {}, data)
    var summary: Dictionary = ctrl.get_camp_summary()
    ctrl.queue_free()

    if not summary.has("newly_unlocked_commands"):
        return _fail("CampController.get_camp_summary() must include newly_unlocked_commands.")
    if not summary.has("recently_recovered_fragments"):
        return _fail("CampController.get_camp_summary() must include recently_recovered_fragments.")

    var unlocked: Array = summary.get("newly_unlocked_commands", [])
    var fragments: Array = summary.get("recently_recovered_fragments", [])
    if unlocked.size() != 1 or String(unlocked[0]) != "cover_advance":
        return _fail("Camp summary should expose only newly unlocked commands since the previous snapshot.")
    if fragments.size() != 1 or String(fragments[0]) != "ch02_fragment":
        return _fail("Camp summary should expose only recently recovered fragments since the previous snapshot.")
    return true

func _assert_progression_service_unlock_logs() -> bool:
    var svc: ProgressionService = ProgressionService.new()
    root.add_child(svc)
    svc.recover_fragment(&"ch01_fragment")
    var log: Array[Dictionary] = svc.get_event_log()
    svc.queue_free()

    var fragment_event: Dictionary = {}
    var command_event: Dictionary = {}
    for entry: Dictionary in log:
        if entry.get("event") == "fragment_recovered":
            fragment_event = entry
        elif entry.get("event") == "command_unlocked":
            command_event = entry

    if fragment_event.is_empty():
        return _fail("ProgressionService should log fragment_recovered events.")
    if command_event.is_empty():
        return _fail("ProgressionService should log command_unlocked events.")
    if String(fragment_event.get("fragment_id", "")) != "ch01_fragment":
        return _fail("fragment_recovered log should include the fragment_id.")
    if int(fragment_event.get("recovered_fragment_count", 0)) != 1:
        return _fail("fragment_recovered log should include recovered_fragment_count for UI summaries.")
    if not (fragment_event.get("recovered_fragment_ids", []) as Array).has("ch01_fragment"):
        return _fail("fragment_recovered log should include recovered_fragment_ids for UI summaries.")
    if String(command_event.get("command_id", "")) != "tactical_shift":
        return _fail("command_unlocked log should include the command_id.")
    if String(command_event.get("source_fragment", "")) != "ch01_fragment":
        return _fail("command_unlocked log should include the source fragment.")
    if int(command_event.get("unlocked_command_count", 0)) != 1:
        return _fail("command_unlocked log should include unlocked_command_count for UI summaries.")
    if not (command_event.get("unlocked_command_ids", []) as Array).has("tactical_shift"):
        return _fail("command_unlocked log should include unlocked_command_ids for UI summaries.")
    return true

func _fail(message: String) -> bool:
    print("[FAIL] %s" % message)
    _failed = true
    quit(1)
    return false
