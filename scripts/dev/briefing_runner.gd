extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH01_STAGE = preload("res://data/stages/ch01_05_stage.tres")
const CH02_STAGE = preload("res://data/stages/ch02_05_stage.tres")
const CH03_STAGE = preload("res://data/stages/ch03_05_stage.tres")
const CH04_STAGE = preload("res://data/stages/ch04_05_stage.tres")
const CH05_STAGE = preload("res://data/stages/ch05_05_stage.tres")
const CH06_STAGE = preload("res://data/stages/ch06_05_stage.tres")
const CH07_STAGE = preload("res://data/stages/ch07_05_stage.tres")
const CH08_STAGE = preload("res://data/stages/ch08_05_stage.tres")
const CH09A_STAGE = preload("res://data/stages/ch09a_05_stage.tres")
const CH09B_STAGE = preload("res://data/stages/ch09b_05_stage.tres")
const CH10_STAGE = preload("res://data/stages/ch10_05_stage.tres")

const BRIEFING_STAGES := [
    {"chapter_id": &"CH01", "stage_index": 3, "stage_id": &"CH01_05", "stage": CH01_STAGE},
    {"chapter_id": &"CH02", "stage_index": 4, "stage_id": &"CH02_05", "stage": CH02_STAGE},
    {"chapter_id": &"CH03", "stage_index": 4, "stage_id": &"CH03_05", "stage": CH03_STAGE},
    {"chapter_id": &"CH04", "stage_index": 4, "stage_id": &"CH04_05", "stage": CH04_STAGE},
    {"chapter_id": &"CH05", "stage_index": 4, "stage_id": &"CH05_05", "stage": CH05_STAGE},
    {"chapter_id": &"CH06", "stage_index": 4, "stage_id": &"CH06_05", "stage": CH06_STAGE},
    {"chapter_id": &"CH07", "stage_index": 4, "stage_id": &"CH07_05", "stage": CH07_STAGE},
    {"chapter_id": &"CH08", "stage_index": 4, "stage_id": &"CH08_05", "stage": CH08_STAGE},
    {"chapter_id": &"CH09A", "stage_index": 4, "stage_id": &"CH09A_05", "stage": CH09A_STAGE},
    {"chapter_id": &"CH09B", "stage_index": 4, "stage_id": &"CH09B_05", "stage": CH09B_STAGE},
    {"chapter_id": &"CH10", "stage_index": 4, "stage_id": &"CH10_05", "stage": CH10_STAGE}
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    main.start_game_direct()
    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Briefing runner could not resolve campaign controller.")
        quit(1)
        return

    for entry: Dictionary in BRIEFING_STAGES:
        var chapter_id: StringName = entry.get("chapter_id", StringName())
        var stage_index: int = int(entry.get("stage_index", 0))
        var stage_id: StringName = entry.get("stage_id", StringName())
        var stage = entry.get("stage", null)
        if stage == null:
            push_error("Missing stage resource for %s." % String(stage_id))
            quit(1)
            return

        campaign._active_chapter_id = chapter_id
        campaign._active_stage_index = stage_index
        campaign._current_stage = stage.duplicate(true)
        campaign._briefing_abort_active = false

        if not campaign._should_show_briefing(stage_id):
            push_error("Expected briefing to trigger for %s." % String(stage_id))
            quit(1)
            return

        var briefing: Dictionary = campaign._get_briefing_data(stage_id)
        if briefing.is_empty():
            push_error("Expected non-empty briefing data for %s." % String(stage_id))
            quit(1)
            return

        campaign._enter_briefing_state(stage_id)
        await process_frame
        await process_frame

        var briefing_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(briefing_snapshot.get("mode", "")) != "briefing":
            push_error("Expected briefing mode for %s, got %s." % [String(stage_id), briefing_snapshot.get("mode", "")])
            quit(1)
            return

        var briefing_body: String = String(briefing_snapshot.get("panel_body", ""))
        if briefing_body.find("Enemy Intel") == -1:
            push_error("Briefing body did not include enemy intel for %s." % String(stage_id))
            quit(1)
            return
        if briefing_body.find("Terrain Summary") == -1:
            push_error("Briefing body did not include terrain summary for %s." % String(stage_id))
            quit(1)
            return
        if briefing_body.find("Optional Objectives") == -1:
            push_error("Briefing body did not include optional objectives for %s." % String(stage_id))
            quit(1)
            return

        campaign._on_briefing_abort_requested()
        await process_frame
        await process_frame

        var abort_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(abort_snapshot.get("mode", "")) != "camp":
            push_error("Expected abort to return to camp for %s, got %s." % [String(stage_id), abort_snapshot.get("mode", "")])
            quit(1)
            return

        if String(abort_snapshot.get("panel_title", "")).find("Field Camp") == -1:
            push_error("Abort camp title did not surface for %s." % String(stage_id))
            quit(1)
            return

        main.advance_campaign_step()
        await process_frame
        await process_frame

        var return_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(return_snapshot.get("mode", "")) != "briefing":
            push_error("Expected return-to-briefing flow for %s, got %s." % [String(stage_id), return_snapshot.get("mode", "")])
            quit(1)
            return

        main.advance_campaign_step()
        await process_frame
        await process_frame

        var battle_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(battle_snapshot.get("mode", "")) != "battle":
            push_error("Expected battle mode after briefing deploy for %s, got %s." % [String(stage_id), battle_snapshot.get("mode", "")])
            quit(1)
            return

        if StringName(battle_snapshot.get("current_stage_id", &"")) != stage_id:
            push_error("Expected battle stage id %s, got %s." % [String(stage_id), battle_snapshot.get("current_stage_id", &"")])
            quit(1)
            return

        var battle = main.battle_controller
        if battle == null or battle.stage_data == null or StringName(battle.stage_data.stage_id) != stage_id:
            push_error("Battle controller did not load %s after briefing deploy." % String(stage_id))
            quit(1)
            return

    await _cleanup_root_children()
    print("[PASS] Briefing runner verified 11 boss-stage briefings, abort-to-camp flow, and deploy-to-battle transitions.")
    quit(0)

func _cleanup_root_children() -> void:
    for child in root.get_children():
        if child == null or not is_instance_valid(child):
            continue
        if child == current_scene:
            continue
        child.queue_free()
    await process_frame
    await process_frame
