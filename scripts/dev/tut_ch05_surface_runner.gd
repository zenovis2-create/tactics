extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CUTSCENE_PLAYER = preload("res://scripts/cutscene/cutscene_player.gd")
const CUTSCENE_CATALOG = preload("res://data/cutscenes/cutscene_catalog.gd")
const CH04_05_STAGE = preload("res://data/stages/ch04_05_stage.tres")
const CH05_05_STAGE = preload("res://data/stages/ch05_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_tutorial_hud_inventory_and_skills():
        return
    if not await _assert_cutscene_start():
        return
    if not await _assert_boss_stage_entry(CH04_05_STAGE, &"CH04_05"):
        return
    if not await _assert_boss_stage_entry(CH05_05_STAGE, &"CH05_05"):
        return

    print("[PASS] tut_ch05_surface_runner verified tutorial HUD/inventory/skills, cutscene start, and CH04/CH05 boss-stage entry.")
    quit(0)

func _assert_tutorial_hud_inventory_and_skills() -> bool:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    await process_frame
    await process_frame

    if battle.hud == null:
        return _fail("Tutorial battle did not expose BattleHUD.")
    if battle.selected_unit == null:
        return _fail("Tutorial battle did not auto-select a ready ally.")

    var unit = battle.selected_unit
    battle._on_world_cell_pressed(unit.grid_position)
    await process_frame

    battle.hud.open_inventory_panel()
    await process_frame
    if not battle.hud.inventory_panel.visible:
        return _fail("Inventory panel did not open in tutorial battle.")
    if String(battle.hud.party_list.text).strip_edges().is_empty():
        return _fail("Inventory panel did not render party unit text.")
    if battle.input_controller.world_input_enabled:
        return _fail("World input should be blocked while inventory is open.")
    battle.hud.close_inventory_panel()
    await process_frame

    var tutorial_enemy_ids: Array[String] = []
    for enemy in battle.enemy_units:
        if enemy == null or not is_instance_valid(enemy) or enemy.unit_data == null:
            continue
        tutorial_enemy_ids.append(String(enemy.unit_data.unit_id))
    tutorial_enemy_ids.sort()
    if tutorial_enemy_ids != ["enemy_raider", "enemy_raider"]:
        return _fail("Tutorial battle should now open on two baseline raiders, got %s." % [str(tutorial_enemy_ids)])

    battle.hud.set_transition_reason("skill_targeting_active", {"skill": "basic_attack"})
    await process_frame
    if battle.hud.telegraph_label.text.find("Basic Attack") == -1:
        return _fail("Skill targeting telegraph should name the selected skill.")
    if battle.hud.telegraph_detail_label.text.find("highlighted target") == -1:
        return _fail("Skill targeting telegraph should explain the next manual action.")

    battle.hud.set_transition_reason("skill_telegraphed", {"skill": "basic_attack", "target": "enemy_raider"})
    await process_frame
    if battle.hud.telegraph_label.text.find("Basic Attack") == -1:
        return _fail("Skill execution telegraph should keep the skill name visible.")
    if battle.hud.telegraph_detail_label.text.find("Raider") == -1:
        return _fail("Skill execution telegraph should expose the target name.")

    battle.hud.set_transition_reason("skill_insufficient_resource", {"skill": "basic_attack", "cost": "1 morale"})
    await process_frame
    if battle.hud.telegraph_label.text.find("Unavailable") == -1:
        return _fail("Skill resource failure telegraph should clearly mark the skill as unavailable.")
    if battle.hud.telegraph_detail_label.text.find("1 morale") == -1:
        return _fail("Skill resource failure telegraph should expose the missing cost.")

    battle.queue_free()
    await process_frame
    return true

func _assert_cutscene_start() -> bool:
    var player = CUTSCENE_PLAYER.new()
    root.add_child(player)
    await process_frame

    var cutscene = CUTSCENE_CATALOG.get_cutscene(&"ch01_start")
    if cutscene == null:
        return _fail("Cutscene catalog could not resolve ch01_start.")
    player.play(cutscene)
    await process_frame
    if not player.is_playing():
        return _fail("Cutscene player did not begin playback for ch01_start.")
    if StringName(player.get_snapshot().get("cutscene_id", &"")) != &"ch01_start":
        return _fail("Cutscene snapshot did not expose ch01_start while playing.")

    player.skip()
    await process_frame
    player.queue_free()
    await process_frame
    return true

func _assert_boss_stage_entry(stage_data, expected_stage_id: StringName) -> bool:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    await process_frame
    await process_frame

    battle.set_stage(stage_data)
    await process_frame
    await process_frame

    if battle.stage_data == null or StringName(battle.stage_data.stage_id) != expected_stage_id:
        return _fail("Boss battle smoke failed to load %s." % [expected_stage_id])
    if battle.hud == null:
        return _fail("Boss battle smoke for %s did not create BattleHUD." % [expected_stage_id])

    var boss_count := 0
    for enemy in battle.enemy_units:
        if enemy != null and is_instance_valid(enemy) and enemy.unit_data != null and enemy.unit_data.is_boss:
            boss_count += 1
    if boss_count < 1:
        return _fail("Boss battle smoke for %s did not spawn a boss unit." % [expected_stage_id])

    battle.queue_free()
    await process_frame
    return true

func _fail(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
