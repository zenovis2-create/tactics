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
        push_error("Final equipment slot runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_unlock_weapon_ids([
        &"wp_saria_mercy_staff",
        &"wp_houndline_bow",
        &"wp_standard_breaker_blade",
        &"wp_keeper_root_staff",
        &"wp_eclipse_resonance_blade"
    ])
    campaign.debug_unlock_armor_ids([
        &"ar_elyor_procession_mail",
        &"ar_ruin_tracker_coat",
        &"ar_capital_witness_plate",
        &"ar_revision_guard_cloak",
        &"ar_bellward_plate"
    ])
    campaign.debug_seed_chapter_camp(&"CH09B", 4, CH09B_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var inventory_entries: Array = snapshot.get("inventory_entries", [])
    if not _contains_inventory_entry(inventory_entries, "Weapon: Eclipse Resonance Blade"):
        push_error("Final equipment slot runner expected Eclipse Resonance Blade in inventory.")
        quit(1)
        return
    if not _contains_inventory_entry(inventory_entries, "Armor: Bellward Plate"):
        push_error("Final equipment slot runner expected Bellward Plate in inventory.")
        quit(1)
        return

    var noah_index: int = _find_party_index(snapshot.get("party_details", []), "Noah")
    if noah_index == -1:
        push_error("Final equipment slot runner expected Noah in the CH09B camp roster.")
        quit(1)
        return

    main.campaign_panel.select_party_index(noah_index)
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_noah")
    await process_frame
    campaign.cycle_weapon_for_unit(&"ally_noah")
    await process_frame
    campaign.cycle_armor_for_unit(&"ally_noah")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var noah_detail: Dictionary = _find_party_entry(updated_snapshot.get("party_details", []), "Noah")
    if String(noah_detail.get("weapon_slot", "")) == "None":
        push_error("Final equipment slot runner expected Noah to equip a final weapon.")
        quit(1)
        return
    if String(noah_detail.get("armor_slot", "")) == "None":
        push_error("Final equipment slot runner expected Noah to equip final armor.")
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
        push_error("Final equipment slot runner could not resolve battle controller.")
        quit(1)
        return

    var noah_unit = _find_battle_unit(battle.ally_units, "Noah")
    if noah_unit == null:
        push_error("Final equipment slot runner expected Noah in the deployed battle party.")
        quit(1)
        return

    if noah_unit.get_attack() <= noah_unit.unit_data.attack and noah_unit.get_defense() <= noah_unit.unit_data.defense:
        push_error("Final equipment slot runner expected endgame weapon and armor to affect battle stats.")
        quit(1)
        return

    print("[PASS] Final equipment slot runner equipped endgame weapon and armor in camp and carried the bonuses into battle.")
    quit(0)

func _contains_inventory_entry(inventory_entries: Array, expected_text: String) -> bool:
    for entry in inventory_entries:
        if String(entry).contains(expected_text):
            return true
    return false

func _find_party_index(party_details: Array, expected_name: String) -> int:
    for index in range(party_details.size()):
        var entry = party_details[index]
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return index
    return -1

func _find_party_entry(party_details: Array, expected_name: String) -> Dictionary:
    for entry in party_details:
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return entry
    return {}

func _find_battle_unit(units: Array, expected_name: String):
    for unit in units:
        if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
            continue
        if unit.unit_data.display_name == expected_name:
            return unit
    return null
