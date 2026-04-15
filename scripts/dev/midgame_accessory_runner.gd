extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH04_FINAL_STAGE = preload("res://data/stages/ch04_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Midgame accessory runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_unlock_accessory_ids([
        &"acc_verdant_plume",
        &"acc_trap_hunter_needle",
        &"acc_sap_charm",
        &"acc_watergate_boots",
        &"acc_locked_bell_shard",
        &"acc_sanctified_pendant",
        &"acc_whiteflow_token"
    ])
    campaign.debug_seed_chapter_camp(&"CH04", 4, CH04_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var inventory_entries: Array = snapshot.get("inventory_entries", [])
    if inventory_entries.is_empty():
        push_error("Midgame accessory runner expected inventory entries to include Chapter 3/4 accessories.")
        quit(1)
        return

    if _find_party_index(snapshot.get("party_details", []), "Tia") == -1:
        push_error("Midgame accessory runner expected Tia in the CH04 camp roster.")
        quit(1)
        return

    campaign.cycle_accessory_for_unit(&"ally_serin")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var serin_detail: Dictionary = _find_party_entry(updated_snapshot.get("party_details", []), "Serin")
    if String(serin_detail.get("accessory_slot", "")) == "None":
        push_error("Midgame accessory runner expected Serin to equip a Chapter 4 accessory.")
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
        push_error("Midgame accessory runner could not resolve battle controller.")
        quit(1)
        return

    var serin_unit = _find_battle_unit(battle.ally_units, "Serin")
    if serin_unit == null:
        push_error("Midgame accessory runner expected Serin in the deployed battle party.")
        quit(1)
        return

    if serin_unit.get_defense() <= serin_unit.unit_data.defense and serin_unit.get_movement() <= serin_unit.unit_data.movement:
        push_error("Midgame accessory runner expected Serin's equipped accessory to affect battle stats.")
        quit(1)
        return

    print("[PASS] Midgame accessory runner unlocked CH03/CH04 accessories, equipped Serin, and carried the bonus into battle.")
    quit(0)

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
