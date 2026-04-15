extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH03_FINAL_STAGE = preload("res://data/stages/ch03_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Three-person sortie runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_seed_chapter_camp(&"CH03", 4, CH03_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var party_details: Array = snapshot.get("party_details", [])
    if _find_party_index(party_details, "Tia") == -1:
        push_error("Three-person sortie runner expected Tia in the CH03 camp roster.")
        quit(1)
        return

    campaign.assign_unit_to_sortie(&"ally_tia")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var deployed_ids: Array = updated_snapshot.get("deployed_party_unit_ids", [])
    if deployed_ids.size() != 3:
        push_error("Three-person sortie runner expected three deployed ids, got %s." % [deployed_ids])
        quit(1)
        return

    if not deployed_ids.has("ally_tia"):
        push_error("Three-person sortie runner expected Tia in the deployed ids.")
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
        push_error("Three-person sortie runner could not resolve battle controller.")
        quit(1)
        return

    var ally_names: Array[String] = []
    for unit in battle.ally_units:
        if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
            continue
        ally_names.append(unit.unit_data.display_name)

    if ally_names.size() != 3:
        push_error("Three-person sortie runner expected 3 deployed allies in battle, got %s." % [ally_names])
        quit(1)
        return

    if not ally_names.has("Rian") or not ally_names.has("Serin") or not ally_names.has("Tia"):
        push_error("Three-person sortie runner expected Rian, Serin, and Tia in battle, got %s." % [ally_names])
        quit(1)
        return

    print("[PASS] Three-person sortie runner added Tia in camp and carried a 3-unit lineup into the next battle.")
    quit(0)

func _find_party_index(party_details: Array, expected_name: String) -> int:
    for index in range(party_details.size()):
        var entry = party_details[index]
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return index
    return -1
