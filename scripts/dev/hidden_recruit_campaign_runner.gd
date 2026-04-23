extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH07_FINAL_STAGE = preload("res://data/stages/ch07_05_stage.tres")
const CH08_FIRST_STAGE = preload("res://data/stages/ch08_01_stage.tres")
const CH08_FINAL_STAGE = preload("res://data/stages/ch08_05_stage.tres")
const CH09A_FIRST_STAGE = preload("res://data/stages/ch09a_01_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    var battle = main.battle_controller
    var panel = main.campaign_panel
    if campaign == null or battle == null or panel == null:
        push_error("Hidden recruit runner could not resolve main campaign dependencies.")
        quit(1)
        return

    campaign.debug_seed_chapter_camp(&"CH07", 4, CH07_FINAL_STAGE)
    await process_frame
    await process_frame
    var ch07_snapshot: Dictionary = panel.get_snapshot()
    if _has_party_member(ch07_snapshot.get("party_details", []), "Mira"):
        push_error("Hidden recruit runner expected Mira to stay hidden before CH07 reward resolution.")
        quit(1)
        return
    if _has_party_member(ch07_snapshot.get("party_details", []), "Lete"):
        push_error("Hidden recruit runner expected Lete to stay hidden before CH08 reward resolution.")
        quit(1)
        return

    battle.last_result_summary = {"stars_earned": 1}
    battle.battle_objective_flags = {"recruit_mira": true}
    campaign._commit_stage_rewards(CH07_FINAL_STAGE)
    campaign.debug_seed_chapter_camp(&"CH08", 0, CH08_FIRST_STAGE)
    await process_frame
    await process_frame
    var ch08_snapshot: Dictionary = panel.get_snapshot()
    if not _has_party_member(ch08_snapshot.get("party_details", []), "Mira"):
        push_error("Hidden recruit runner expected Mira to join the CH08 camp roster after CH07 rescue rewards commit.")
        quit(1)
        return

    battle.last_result_summary = {"stars_earned": 1}
    battle.battle_objective_flags = {"lete_defects_alive": true}
    campaign._commit_stage_rewards(CH08_FINAL_STAGE)
    campaign.debug_seed_chapter_camp(&"CH09A", 0, CH09A_FIRST_STAGE)
    await process_frame
    await process_frame
    var ch09a_snapshot: Dictionary = panel.get_snapshot()
    if not _has_party_member(ch09a_snapshot.get("party_details", []), "Lete"):
        push_error("Hidden recruit runner expected Lete to join the CH09A camp roster after CH08 reward resolution.")
        quit(1)
        return

    print("[PASS] Hidden recruit campaign runner verified Mira/Lete roster gating and reward-driven unlocks.")
    quit(0)

func _has_party_member(party_details: Array, expected_name: String) -> bool:
    for entry in party_details:
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        if String(entry.get("name", "")) == expected_name:
            return true
    return false
