extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH05_FINAL_STAGE = preload("res://data/stages/ch05_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Equipment slot runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_unlock_armor_ids([
        &"ar_greenwood_cloak",
        &"ar_whiteflow_vestment",
        &"ar_archive_smoke_coat"
    ])
    campaign.debug_unlock_weapon_ids([
        &"wp_archive_ashblade",
        &"wp_zero_trace_staff",
        &"wp_valtor_command_lance"
    ])
    campaign.debug_seed_chapter_camp(&"CH05", 4, CH05_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var party_details: Array = snapshot.get("party_details", [])
    var inventory_entries: Array = snapshot.get("inventory_entries", [])
    if not _contains_inventory_entry(inventory_entries, "Weapon:") or not _contains_inventory_entry(inventory_entries, "Armor:"):
        push_error("Equipment slot runner expected weapon and armor inventory entries.")
        quit(1)
        return

    var enoch_index: int = _find_party_index(party_details, "Enoch")
    if enoch_index == -1:
        push_error("Equipment slot runner expected Enoch in the CH05 camp roster.")
        quit(1)
        return

    main.campaign_panel.select_party_index(enoch_index)
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_enoch")
    await process_frame
    campaign.cycle_weapon_for_unit(&"ally_enoch")
    await process_frame
    campaign.cycle_armor_for_unit(&"ally_enoch")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var enoch_detail: Dictionary = _find_party_entry(updated_snapshot.get("party_details", []), "Enoch")
    if String(enoch_detail.get("weapon_slot", "")) == "None":
        push_error("Equipment slot runner expected Enoch to equip a weapon.")
        quit(1)
        return
    if String(enoch_detail.get("armor_slot", "")) == "None":
        push_error("Equipment slot runner expected Enoch to equip armor.")
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
        push_error("Equipment slot runner could not resolve battle controller.")
        quit(1)
        return

    var enoch_unit = _find_battle_unit(battle.ally_units, "Enoch")
    if enoch_unit == null:
        push_error("Equipment slot runner expected Enoch in the deployed battle party.")
        quit(1)
        return

    if enoch_unit.get_attack() <= enoch_unit.unit_data.attack and enoch_unit.get_defense() <= enoch_unit.unit_data.defense:
        push_error("Equipment slot runner expected weapon and armor equipment to affect battle stats.")
        quit(1)
        return

    print("[PASS] Equipment slot runner equipped weapon and armor in camp and carried the bonuses into battle.")
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
