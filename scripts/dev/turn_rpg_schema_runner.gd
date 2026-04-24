extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed := false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _assert_stage_schema_defaults():
        quit(1)
        return
    if not _assert_progression_schema_defaults():
        quit(1)
        return
    if not await _assert_progression_save_load_roundtrip():
        quit(1)
        return
    print("[PASS] turn_rpg_schema_runner: all assertions passed.")
    quit(0)

func _assert_stage_schema_defaults() -> bool:
    var stage := StageData.new()
    if not _has_property(stage, "risk_forecast_cards"):
        return _fail("StageData must expose risk_forecast_cards.")
    if not _has_property(stage, "rule_template_id"):
        return _fail("StageData must expose rule_template_id.")
    if not _has_property(stage, "rule_template_modifiers"):
        return _fail("StageData must expose rule_template_modifiers.")
    if not _has_property(stage, "secret_hint_contract"):
        return _fail("StageData must expose secret_hint_contract.")
    if not Array(_get_or_default(stage, "risk_forecast_cards", [])).is_empty():
        return _fail("StageData risk_forecast_cards should default to empty.")
    if StringName(_get_or_default(stage, "rule_template_id", &"unexpected")) != &"":
        return _fail("StageData rule_template_id should default to empty StringName.")
    if not Dictionary(_get_or_default(stage, "rule_template_modifiers", {"bad": true})).is_empty():
        return _fail("StageData rule_template_modifiers should default to empty Dictionary.")
    if not Dictionary(_get_or_default(stage, "secret_hint_contract", {"bad": true})).is_empty():
        return _fail("StageData secret_hint_contract should default to empty Dictionary.")
    return true

func _assert_progression_schema_defaults() -> bool:
    var data := ProgressionData.new()
    if not _has_property(data, "narrative_axis_values"):
        return _fail("ProgressionData must expose narrative_axis_values.")
    if not _has_property(data, "unlocked_passive_card_ids"):
        return _fail("ProgressionData must expose unlocked_passive_card_ids.")
    if not _has_property(data, "hint_reveal_state"):
        return _fail("ProgressionData must expose hint_reveal_state.")
    if not _has_property(data, "bonus_exp_history"):
        return _fail("ProgressionData must expose bonus_exp_history.")
    if not _has_property(data, "stage_clear_records"):
        return _fail("ProgressionData must expose stage_clear_records.")
    if not Dictionary(_get_or_default(data, "narrative_axis_values", {"bad": true})).is_empty():
        return _fail("ProgressionData narrative_axis_values should default to empty Dictionary.")
    if not Array(_get_or_default(data, "unlocked_passive_card_ids", ["bad"])).is_empty():
        return _fail("ProgressionData unlocked_passive_card_ids should default to empty Array.")
    if not Dictionary(_get_or_default(data, "hint_reveal_state", {"bad": true})).is_empty():
        return _fail("ProgressionData hint_reveal_state should default to empty Dictionary.")
    if not Array(_get_or_default(data, "bonus_exp_history", [{"bad": true}])).is_empty():
        return _fail("ProgressionData bonus_exp_history should default to empty Array.")
    if not Dictionary(_get_or_default(data, "stage_clear_records", {"bad": true})).is_empty():
        return _fail("ProgressionData stage_clear_records should default to empty Dictionary.")
    return true

func _assert_progression_save_load_roundtrip() -> bool:
    var svc := SaveService.new()
    root.add_child(svc)
    await process_frame
    var data := ProgressionData.new()
    data.narrative_axis_values = {"memory": 3, "trust": 6}
    data.unlocked_passive_card_ids = [&"guard_share_plus"]
    data.hint_reveal_state = {"CH01_01": {"well_clue": 2}}
    data.bonus_exp_history = [{"stage_id": &"CH01_01", "pool": 12}]
    data.stage_clear_records = {"CH04_05": {"telemetry": {"rounds": 4}, "battle_temp_counters": {"research_logs": 2}}}
    var err := svc.save_progression(data, 2)
    if err != OK:
        return _fail("save_progression should return OK for schema roundtrip.")
    var loaded := svc.load_progression(2)
    svc.delete_slot(2)
    if loaded == null:
        return _fail("schema roundtrip should load ProgressionData.")
    if Dictionary(_get_or_default(loaded, "narrative_axis_values", {})).get("memory", 0) != 3:
        return _fail("narrative_axis_values should survive save/load.")
    if Array(_get_or_default(loaded, "unlocked_passive_card_ids", [])).size() != 1:
        return _fail("unlocked_passive_card_ids should survive save/load.")
    if int(Dictionary(Dictionary(_get_or_default(loaded, "hint_reveal_state", {})).get("CH01_01", {})).get("well_clue", 0)) != 2:
        return _fail("hint_reveal_state should survive save/load.")
    if int(Dictionary(Array(_get_or_default(loaded, "bonus_exp_history", [])).front()).get("pool", 0)) != 12:
        return _fail("bonus_exp_history should survive save/load.")
    if int(Dictionary(Dictionary(_get_or_default(loaded, "stage_clear_records", {})).get("CH04_05", {})).get("battle_temp_counters", {}).get("research_logs", 0)) != 2:
        return _fail("stage_clear_records should survive save/load.")
    return true

func _has_property(target: Object, property_name: String) -> bool:
    for property_info in target.get_property_list():
        if String(property_info.get("name", "")) == property_name:
            return true
    return false

func _get_or_default(target: Object, property_name: String, fallback):
    if not _has_property(target, property_name):
        return fallback
    return target.get(property_name)

func _fail(message: String) -> bool:
    if not _failed:
        _failed = true
        push_error("[FAIL] turn_rpg_schema_runner: %s" % message)
    return false
