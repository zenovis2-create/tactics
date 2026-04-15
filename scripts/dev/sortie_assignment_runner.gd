extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH01_FINAL_STAGE = preload("res://data/stages/ch01_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Sortie assignment runner could not resolve campaign controller.")
        quit(1)
        return

    campaign._active_chapter_id = &"CH02"
    campaign._active_stage_index = 4
    campaign._current_stage = preload("res://data/stages/ch02_05_stage.tres")
    campaign._enter_chapter_two_camp()
    await process_frame
    await process_frame

    var camp_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var party_details: Array = camp_snapshot.get("party_details", [])
    var bran_index: int = _find_party_index(party_details, "Bran")
    if bran_index == -1:
        push_error("Bran was not present in the Chapter 2 camp roster.")
        quit(1)
        return

    main.campaign_panel.select_party_index(bran_index)
    await process_frame
    main.campaign_panel.assign_selected_party_member()
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var deployed_ids: Array = updated_snapshot.get("deployed_party_unit_ids", [])
    if not deployed_ids.has("ally_bran"):
        push_error("Bran was not assigned into the deployed party ids.")
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
        push_error("Sortie assignment runner could not resolve battle controller after camp advance.")
        quit(1)
        return

    var ally_names: Array[String] = []
    for unit in battle.ally_units:
        if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
            continue
        ally_names.append(unit.unit_data.display_name)

    if not ally_names.has("Rian"):
        push_error("Deployed battle party is missing Rian.")
        quit(1)
        return

    if not ally_names.has("Bran"):
        push_error("Deployed battle party did not bring Bran into the next stage.")
        quit(1)
        return

    if ally_names.has("Serin"):
        push_error("Flexible sortie slot did not replace Serin with Bran.")
        quit(1)
        return

    print("[PASS] Sortie assignment runner assigned Bran in camp and carried the lineup into the next battle.")
    quit(0)

func _find_party_index(party_details: Array, expected_name: String) -> int:
    for index in range(party_details.size()):
        var entry = party_details[index]
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return index
    return -1
