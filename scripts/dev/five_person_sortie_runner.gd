extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH09B_FINAL_STAGE = preload("res://data/stages/ch09b_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Five-person sortie runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_seed_chapter_camp(&"CH09B", 4, CH09B_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var party_details: Array = snapshot.get("party_details", [])
    for expected_name in ["Bran", "Tia", "Karl", "Noah"]:
        if _find_party_index(party_details, expected_name) == -1:
            push_error("Five-person sortie runner expected %s in the CH09B camp roster." % expected_name)
            quit(1)
            return

    campaign.assign_unit_to_sortie(&"ally_bran")
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_tia")
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_karl")
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_noah")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var deployed_ids: Array = updated_snapshot.get("deployed_party_unit_ids", [])
    if deployed_ids.size() != 5:
        push_error("Five-person sortie runner expected five deployed ids, got %s." % [deployed_ids])
        quit(1)
        return

    for expected_id in ["ally_rian", "ally_bran", "ally_tia", "ally_karl", "ally_noah"]:
        if not deployed_ids.has(expected_id):
            push_error("Five-person sortie runner expected %s in deployed ids, got %s." % [expected_id, deployed_ids])
            quit(1)
            return

    main.advance_campaign_step()
    await process_frame
    await process_frame
    main.advance_campaign_step()
    await process_frame
    await process_frame

    var battle = main.battle_controller
    if battle == null:
        push_error("Five-person sortie runner could not resolve battle controller.")
        quit(1)
        return

    var ally_names: Array[String] = []
    for unit in battle.ally_units:
        if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
            continue
        ally_names.append(unit.unit_data.display_name)

    if ally_names.size() != 5:
        push_error("Five-person sortie runner expected 5 deployed allies in battle, got %s." % [ally_names])
        quit(1)
        return

    for expected_name in ["Rian", "Bran", "Tia", "Karl", "Noah"]:
        if not ally_names.has(expected_name):
            push_error("Five-person sortie runner expected %s in battle, got %s." % [expected_name, ally_names])
            quit(1)
            return

    print("[PASS] Five-person sortie runner carried a 5-unit lineup into the next battle.")
    quit(0)

func _find_party_index(party_details: Array, expected_name: String) -> int:
    for index in range(party_details.size()):
        var entry = party_details[index]
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return index
    return -1
