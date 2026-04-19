extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH07_05_STAGE = preload("res://data/stages/ch07_05_stage.tres")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const SAVE_SLOT := 2
const LEONIKA_UNIT_ID: StringName = &"enemy_saria"
const MIRROR_DIALOGUE := "당신이 나였다면 어떻게 했을까?"
const PLAYER_UNIT_IDS: Array[StringName] = [&"ally_vanguard", &"ally_scout"]

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var enemy_view = root.get_node_or_null("/root/EnemyView")
    if enemy_view == null:
        _fail("EnemyView autoload is missing.")
        return

    enemy_view.exit_mirror_mode()
    enemy_view.mirror_battles_won = 0

    var save_service := SaveService.new()
    root.add_child(save_service)
    await process_frame
    save_service.delete_slot(SAVE_SLOT)

    var loaded_progression := _build_loaded_ch07_progress(save_service)
    if _failed:
        return

    var mirror_wins_before: int = int(enemy_view.mirror_battles_won)
    enemy_view.enter_mirror_mode()

    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    await process_frame
    await process_frame

    battle.progression_service.load_data(loaded_progression)
    battle.set_stage(CH07_05_STAGE)
    await process_frame
    await process_frame

    _assert(bool(enemy_view.mirror_mode_active), "Mirror mode should stay active after stage load.")
    _assert(String(battle.stage_data.stage_title).begins_with(enemy_view.get_mirror_chapter_title()), "Mirror stage title should use the EnemyView chapter title.")
    _assert(_has_unit(battle.ally_units, LEONIKA_UNIT_ID), "Leonika should be moved onto the ally roster in mirror mode.")
    _assert(not _has_any_unit(battle.ally_units, PLAYER_UNIT_IDS), "Original player units should leave the ally roster in mirror mode.")
    _assert(_has_all_units(battle.enemy_units, PLAYER_UNIT_IDS), "Original player units should become the mirror enemy roster.")
    _assert(String(battle.hud.transition_reason_label.text).find(MIRROR_DIALOGUE) != -1, "Mirror intro dialogue should surface Leonika's line.")
    if _failed:
        return

    battle._end_player_phase("enemy_perspective_runner")
    await process_frame
    await process_frame
    await process_frame

    _assert(battle.mirror_enemy_commander != null, "Mirror commander should be available during mirror mode.")
    _assert(not battle.mirror_enemy_commander.perspective_decisions.is_empty(), "Mirror commander should log at least one perspective decision.")
    if _failed:
        return

    var leonika = _find_unit(battle.ally_units, LEONIKA_UNIT_ID)
    _assert(leonika != null and is_instance_valid(leonika) and not leonika.is_defeated(), "Leonika should still be alive after the mirror enemy phase.")
    if _failed:
        return

    for enemy in battle.enemy_units.duplicate():
        if enemy == null or not is_instance_valid(enemy):
            continue
        battle._remove_unit_from_roster(enemy)
        enemy.current_hp = 0
        enemy.queue_free()

    await process_frame
    _assert(battle._check_battle_end(), "Mirror battle should enter victory when the mirror enemy roster is cleared.")
    await process_frame

    leonika = _find_unit(battle.ally_units, LEONIKA_UNIT_ID)
    _assert(int(enemy_view.mirror_battles_won) == mirror_wins_before + 1, "Mirror victories should increment after a mirror-mode win.")
    _assert(leonika != null and is_instance_valid(leonika) and not leonika.is_defeated(), "Leonika must survive the mirror verification battle.")
    _assert(not enemy_view.last_perspective_decisions.is_empty(), "EnemyView should receive the commander perspective decision log.")
    if _failed:
        return

    enemy_view.exit_mirror_mode()
    battle.queue_free()
    await process_frame
    save_service.delete_slot(SAVE_SLOT)

    print("[PASS] enemy_perspective_runner: CH07 mirror mode swapped sides, logged favorable enemy decisions, and recorded a Leonika survival victory.")
    quit(0)

func _build_loaded_ch07_progress(save_service: SaveService) -> ProgressionData:
    var data := ProgressionData.new()
    for chapter_number in range(1, 7):
        data.add_chapter_completed(StringName("CH%02d" % chapter_number))
    data.choices_made.append("ch07_interlude")
    data.world_timeline_id = "A"

    var save_error: Error = save_service.save_progression(data, SAVE_SLOT)
    _assert(save_error == OK, "CH07 verification slot should save successfully.")
    if _failed:
        return data

    var loaded_progression: ProgressionData = save_service.load_progression(SAVE_SLOT)
    _assert(loaded_progression != null, "CH07 verification slot should load ProgressionData.")
    _assert(loaded_progression.choices_made.has("ch07_interlude"), "Loaded slot should preserve CH07 progress.")
    return loaded_progression

func _find_unit(units: Array, unit_id: StringName):
    for unit in units:
        if unit != null and is_instance_valid(unit) and unit.unit_data != null and unit.unit_data.unit_id == unit_id:
            return unit
    return null

func _has_unit(units: Array, unit_id: StringName) -> bool:
    return _find_unit(units, unit_id) != null

func _has_any_unit(units: Array, unit_ids: Array[StringName]) -> bool:
    for unit_id in unit_ids:
        if _has_unit(units, unit_id):
            return true
    return false

func _has_all_units(units: Array, unit_ids: Array[StringName]) -> bool:
    for unit_id in unit_ids:
        if not _has_unit(units, unit_id):
            return false
    return true

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
