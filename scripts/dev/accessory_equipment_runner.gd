extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH02_FINAL_STAGE = preload("res://data/stages/ch02_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Accessory runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_unlock_accessory_ids([
        &"acc_militia_emblem",
        &"acc_broken_captain_seal",
        &"acc_gatekeeper_ring",
        &"acc_hardren_iron_crest"
    ])
    campaign.debug_seed_chapter_camp(&"CH02", 4, CH02_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var inventory_entries: Array = snapshot.get("inventory_entries", [])
    if inventory_entries.is_empty():
        push_error("Accessory runner expected inventory entries to include unlocked accessories.")
        quit(1)
        return

    var bran_index: int = _find_party_index(snapshot.get("party_details", []), "Bran")
    if bran_index == -1:
        push_error("Accessory runner could not find Bran in camp roster.")
        quit(1)
        return

    main.campaign_panel.select_party_index(bran_index)
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_bran")
    await process_frame
    campaign.cycle_accessory_for_unit(&"ally_bran")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var updated_party_details: Array = updated_snapshot.get("party_details", [])
    var bran_detail: Dictionary = _find_party_entry(updated_party_details, "Bran")
    if String(bran_detail.get("accessory_slot", "")) == "None":
        push_error("Accessory runner expected Bran to equip an accessory.")
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
        push_error("Accessory runner could not resolve battle controller.")
        quit(1)
        return

    var bran_unit = _find_battle_unit(battle.ally_units, "Bran")
    if bran_unit == null:
        push_error("Accessory runner expected Bran in the deployed battle party.")
        quit(1)
        return

    if bran_unit.get_defense() <= bran_unit.unit_data.defense and bran_unit.get_movement() <= bran_unit.unit_data.movement:
        push_error("Accessory runner expected Bran's equipped accessory to affect battle stats.")
        quit(1)
        return

    print("[PASS] Accessory runner unlocked CH02 accessories, equipped Bran, and carried the bonus into battle.")
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
