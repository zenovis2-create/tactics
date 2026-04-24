extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")

const CASES := [
    {
        "label": "CH06_05",
        "stage": preload("res://data/stages/ch06_05_stage.tres"),
        "expected_start": &"ch06_05_intro",
        "expected_clear": &"ch06_05_outro"
    },
    {
        "label": "CH07_05",
        "stage": preload("res://data/stages/ch07_05_stage.tres"),
        "expected_start": &"ch07_05_intro",
        "expected_clear": &"ch07_05_outro"
    },
    {
        "label": "CH08_05",
        "stage": preload("res://data/stages/ch08_05_stage.tres"),
        "expected_start": &"ch08_05_intro",
        "expected_clear": &"ch08_05_outro",
        "required_object_id": &"ch08_05_transfer_gate_latch"
    },
    {
        "label": "CH09A_05",
        "stage": preload("res://data/stages/ch09a_05_stage.tres"),
        "expected_start": &"ch09a_05_intro",
        "expected_clear": &"ch09a_05_outro"
    },
    {
        "label": "CH09B_05",
        "stage": preload("res://data/stages/ch09b_05_stage.tres"),
        "expected_start": &"ch09b_05_intro",
        "expected_clear": &"ch09b_05_outro",
        "required_object_id": &"ch09b_05_archive_lectern"
    },
    {
        "label": "CH10_05",
        "stage": preload("res://data/stages/ch10_05_stage.tres"),
        "expected_start": &"ch10_05_intro",
        "expected_clear": &"",
        "required_object_id": &"ch10_05_anchor_chain"
    }
]

var _failed := false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for case_data in CASES:
        await _run_case(case_data)
        if _failed:
            return

    print("[PASS] CH06~CH10 boss surface runner validated boss spawn, cutscene references, HUD creation, and boss phase entry on boss stages.")
    quit(0)

func _run_case(case_data: Dictionary) -> void:
    var stage = case_data.get("stage", null)
    if stage == null:
        _fail("Missing stage data for %s." % case_data.get("label", "boss_case"))
        return

    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(stage)

    await process_frame
    await process_frame

    var label: String = String(case_data.get("label", stage.stage_id))
    _assert(StringName(stage.stage_id) == StringName(case_data.get("label", &"")), "%s stage id drifted." % label)
    _assert(battle.stage_data != null and StringName(battle.stage_data.stage_id) == stage.stage_id, "%s failed to load stage data into BattleController." % label)
    _assert(battle.hud != null, "%s failed to create the battle HUD." % label)
    _assert(String(battle.hud.objective_label.text).begins_with("Objective:"), "%s HUD objective label did not initialize." % label)
    _assert(battle.cutscene_player != null, "%s failed to create the cutscene player." % label)
    if _failed:
        return

    var expected_start: StringName = case_data.get("expected_start", &"")
    var expected_clear: StringName = case_data.get("expected_clear", &"")
    _assert(stage.start_cutscene_id == expected_start, "%s start cutscene id drifted." % label)
    _assert(CutsceneCatalog.get_cutscene(stage.start_cutscene_id) != null, "%s start cutscene could not be resolved from the catalog." % label)
    if expected_clear != &"":
        _assert(stage.clear_cutscene_id == expected_clear, "%s clear cutscene id drifted." % label)
        _assert(CutsceneCatalog.get_cutscene(stage.clear_cutscene_id) != null, "%s clear cutscene could not be resolved from the catalog." % label)
    else:
        _assert(stage.clear_cutscene_id == &"", "%s should hand off clear cutscene via campaign ending flow." % label)
    if _failed:
        return

    var start_snapshot: Dictionary = battle.cutscene_player.get_snapshot()
    _assert(bool(start_snapshot.get("is_playing", false)), "%s did not begin its start cutscene on stage load." % label)
    _assert(StringName(start_snapshot.get("cutscene_id", &"")) == stage.start_cutscene_id, "%s started the wrong cutscene on stage load." % label)
    if _failed:
        return

    _finish_active_cutscene(battle)
    await process_frame

    var boss = _find_boss(battle)
    _assert(boss != null, "%s did not spawn a boss enemy." % label)
    if _failed:
        return

    _assert(boss.unit_data != null and boss.unit_data.is_boss, "%s boss spawn was not flagged as a boss unit." % label)
    _assert(StringName(boss.unit_data.boss_pattern) != &"", "%s boss spawn did not expose a boss pattern id." % label)
    _assert(not boss.unit_data.boss_phase_thresholds.is_empty(), "%s boss spawn did not expose boss phase thresholds." % label)
    var required_object_id: StringName = case_data.get("required_object_id", &"")
    if required_object_id != &"":
        _assert(not battle.interactive_objects.is_empty(), "%s should author at least one late-game control object." % label)
        if not battle.interactive_objects.is_empty():
            var found_required_object := false
            for object_actor in battle.interactive_objects:
                if is_instance_valid(object_actor) and object_actor.object_data != null and object_actor.object_data.object_id == required_object_id:
                    found_required_object = true
                    break
            _assert(found_required_object, "%s late-game control object drifted." % label)
    if _failed:
        return

    var phase_keys: Array = boss.unit_data.boss_phase_thresholds.keys()
    phase_keys.sort()
    phase_keys.reverse()
    for threshold in phase_keys:
        var threshold_percent: int = int(threshold)
        var new_hp: int = max(1, int(floor(float(boss.unit_data.max_hp) * float(threshold_percent) / 100.0)))
        boss.current_hp = new_hp
        battle._check_boss_phase_transitions()
        await process_frame
        var expected_phase: StringName = boss.unit_data.get_boss_phase_for_hp(float(threshold_percent))
        var actual_phase: StringName = battle.boss_phase_by_unit.get(boss.get_instance_id(), &"")
        _assert(actual_phase == expected_phase, "%s failed to enter boss phase %s at %d%% HP." % [label, String(expected_phase), threshold_percent])
        _assert(battle.boss_event_history.has("boss_phase_%s" % String(expected_phase)), "%s did not log boss phase %s." % [label, String(expected_phase)])
        if _failed:
            return

    battle.enemy_units.clear()
    if String(stage.win_condition) == "resolve_all_interactions_and_defeat_all_enemies":
        for object_actor in battle.interactive_objects:
            if is_instance_valid(object_actor):
                object_actor.is_resolved = true
    _assert(battle._check_battle_end(), "%s did not enter victory after the enemy roster was cleared." % label)
    _assert(int(battle.current_phase) == int(battle.BattlePhase.VICTORY), "%s did not transition into BattlePhase.VICTORY." % label)
    if _failed:
        return

    if expected_clear != &"":
        var clear_snapshot: Dictionary = battle.cutscene_player.get_snapshot()
        _assert(bool(clear_snapshot.get("is_playing", false)), "%s did not begin its clear cutscene on victory." % label)
        _assert(StringName(clear_snapshot.get("cutscene_id", &"")) == expected_clear, "%s began the wrong clear cutscene on victory." % label)
        if _failed:
            return
        _finish_active_cutscene(battle)
        await process_frame
    else:
        print("[INFO] %s clear cutscene is owned by campaign ending flow, not StageData.clear_cutscene_id." % label)

    print("[PASS] %s boss surface validated: HUD, boss spawn, cutscene refs, phase thresholds, victory handoff." % label)
    battle.queue_free()
    await process_frame

func _find_boss(battle):
    for enemy in battle.enemy_units:
        if is_instance_valid(enemy) and enemy.unit_data != null and enemy.unit_data.is_boss:
            return enemy
    return null

func _finish_active_cutscene(battle) -> void:
    var safety := 0
    while is_instance_valid(battle) and battle.cutscene_player != null and battle.cutscene_player.is_playing():
        battle.cutscene_player.advance_beat_immediate()
        await process_frame
        safety += 1
        if safety > 32:
            _fail("Timed out fast-forwarding cutscene %s." % String(battle.cutscene_player.get_snapshot().get("cutscene_id", &"")))
            return

func _assert(condition: bool, message: String) -> void:
    if condition or _failed:
        return
    _fail(message)

func _fail(message: String) -> void:
    if _failed:
        return
    _failed = true
    push_error(message)
    quit(1)
