extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CUTSCENE_PLAYER = preload("res://scripts/cutscene/cutscene_player.gd")
const CUTSCENE_CATALOG = preload("res://data/cutscenes/cutscene_catalog.gd")
const EXPECTED_STAGE_ORDER := [&"CH01_02", &"CH01_03", &"CH01_04", &"CH01_05"]
const CUTSCENE_KEYWORDS := {
    &"CH01_02": ["retreat officer", "Ruined Well"],
    &"CH01_03": ["cold command voice", "North Gate"],
    &"CH01_04": ["weak point of the gate", "Dawn Oath"]
}
const CAMP_KEYWORDS := [
    "Serin is now locked in as an ally.",
    "mem_frag_ch01_first_order",
    "Hardren seal evidence points north."
]

var _wait_tested: bool = false
var _cutscene_log_offset: int = 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_opening_cutscene_catalog_and_playback():
        return

    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    if not _assert_initial_title_state(main):
        return

    main.title_screen.new_game_requested.emit()
    await process_frame
    await process_frame

    if not await _assert_stage_entry(main, EXPECTED_STAGE_ORDER[0]):
        return

    for stage_id in EXPECTED_STAGE_ORDER:
        var battle = main.battle_controller
        if battle == null:
            return _fail("CH01 tutorial runner could not resolve battle controller.")

        await _play_battle_to_victory(battle)
        await process_frame
        await process_frame

        var post_battle_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if stage_id == EXPECTED_STAGE_ORDER[-1]:
            if not _assert_final_camp_snapshot(post_battle_snapshot):
                return
            break

        if String(post_battle_snapshot.get("mode", "")) != "cutscene":
            return _fail("Expected cutscene mode after %s, got %s." % [stage_id, String(post_battle_snapshot.get("mode", ""))])
        if not _assert_cutscene_snapshot(stage_id, post_battle_snapshot):
            return

        main.advance_campaign_step()
        await process_frame
        await process_frame

        var next_index: int = EXPECTED_STAGE_ORDER.find(stage_id) + 1
        if next_index >= EXPECTED_STAGE_ORDER.size():
            return _fail("CH01 tutorial runner lost track of the next stage after %s." % String(stage_id))
        if not await _assert_stage_entry(main, EXPECTED_STAGE_ORDER[next_index]):
            return

    if not _wait_tested:
        return _fail("CH01 tutorial runner never exercised Wait during battle.")

    print("[PASS] ch01_tutorial_e2e_runner reached title start, opening cutscene playback, CH01_02~05, and CH01 camp handoff.")
    quit(0)

func _assert_opening_cutscene_catalog_and_playback() -> bool:
    var player = CUTSCENE_PLAYER.new()
    root.add_child(player)
    await process_frame

    var cutscene = CUTSCENE_CATALOG.get_cutscene(&"ch01_start")
    if cutscene == null:
        return _fail("Cutscene catalog could not resolve ch01_start.")
    player.play(cutscene)
    await process_frame
    if not player.is_playing():
        return _fail("Opening cutscene did not begin playback for ch01_start.")
    var snapshot: Dictionary = player.get_snapshot()
    if StringName(snapshot.get("cutscene_id", &"")) != &"ch01_start":
        return _fail("Opening cutscene snapshot did not expose ch01_start while playing.")
    player.skip()
    await process_frame
    player.queue_free()
    await process_frame
    return true

func _assert_initial_title_state(main: Node) -> bool:
    if main.title_screen == null:
        return _fail("CH01 tutorial runner expected Main to expose a title_screen.")
    var title_snapshot: Dictionary = main.title_screen.get_layout_snapshot()
    if not bool(title_snapshot.get("visible", false)):
        return _fail("Initial state should show the title screen.")
    if main.battle_controller != null and main.battle_controller.visible:
        return _fail("Battle scene should stay hidden until New Game starts the CH01 flow.")
    return true

func _assert_cutscene_snapshot(stage_id: StringName, snapshot: Dictionary) -> bool:
    var body: String = String(snapshot.get("panel_body", ""))
    var keywords: Array = CUTSCENE_KEYWORDS.get(stage_id, [])
    for keyword in keywords:
        if body.find(String(keyword)) == -1:
            return _fail("Cutscene body for %s is missing keyword '%s'." % [stage_id, String(keyword)])
    return true

func _assert_final_camp_snapshot(snapshot: Dictionary) -> bool:
    if String(snapshot.get("mode", "")) != "camp":
        return _fail("Expected camp mode after CH01_05, got %s." % String(snapshot.get("mode", "")))

    var body: String = String(snapshot.get("panel_body", ""))
    for keyword in CAMP_KEYWORDS:
        if body.find(keyword) == -1:
            return _fail("Camp snapshot is missing keyword '%s'." % keyword)

    var party_details: Variant = snapshot.get("party_details", null)
    if typeof(party_details) != TYPE_ARRAY:
        return _fail("Camp snapshot should expose party_details for CH01 handoff verification.")
    if not _party_contains_name(party_details, "Serin"):
        return _fail("CH01 camp roster did not include Serin.")

    var presentation_cards: Variant = snapshot.get("presentation_cards", null)
    if typeof(presentation_cards) != TYPE_ARRAY:
        return _fail("Camp snapshot should expose presentation_cards for CH01 handoff verification.")
    if presentation_cards.is_empty():
        return _fail("CH01 camp should surface at least one presentation card.")

    return true

func _party_contains_name(party_details: Array, expected_name: String) -> bool:
    for entry in party_details:
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return true
    return false

func _assert_briefing_snapshot(snapshot: Dictionary, expected_stage_id: StringName) -> bool:
    if String(snapshot.get("mode", "")) != "briefing":
        return _fail("Expected briefing mode before %s, got %s." % [expected_stage_id, String(snapshot.get("mode", ""))])
    if StringName(snapshot.get("current_stage_id", &"")) != expected_stage_id:
        return _fail("Expected briefing to preserve stage id %s, got %s." % [expected_stage_id, StringName(snapshot.get("current_stage_id", &""))])

    var flow_text: String = String(snapshot.get("flow_text", ""))
    if flow_text.find("작전 브리핑") == -1:
        return _fail("Briefing snapshot should expose flow_text through get_campaign_state_snapshot().")

    var body: String = String(snapshot.get("body", ""))
    if body.find("턴 제한: 10") == -1:
        return _fail("CH01_05 briefing should expose the configured turn limit.")
    if body.find("Defeat enemy commander with Serin") == -1:
        return _fail("CH01_05 briefing should expose the optional objective for Serin.")
    return true

func _assert_start_cutscene(battle, expected_cutscene_id: StringName) -> bool:
    if battle == null or battle.cutscene_player == null:
        return _fail("Battle controller should expose cutscene_player for CH01 start-cutscene checks.")

    var event_log: Array[Dictionary] = battle.cutscene_player.get_event_log()
    for index in range(_cutscene_log_offset, event_log.size()):
        var entry: Dictionary = event_log[index]
        if String(entry.get("event", "")) == "cutscene_started" and StringName(entry.get("id", &"")) == expected_cutscene_id:
            _cutscene_log_offset = event_log.size()
            return true
    return _fail("Expected start cutscene %s to begin for current CH01 stage." % String(expected_cutscene_id))

func _finish_active_cutscene(battle) -> void:
    if battle == null or battle.cutscene_player == null:
        return
    var safety: int = 0
    while battle.cutscene_player.is_playing():
        battle.cutscene_player.advance_beat_immediate()
        await process_frame
        safety += 1
        if safety > 60:
            _fail("Timed out finishing an active cutscene during CH01 tutorial flow.")
            return

func _assert_battle_ready(main: Node, expected_stage_id: StringName) -> bool:
    var snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(snapshot.get("mode", "")) != "battle":
        return _fail("Expected battle mode for %s, got %s." % [expected_stage_id, String(snapshot.get("mode", ""))])
    if StringName(snapshot.get("current_stage_id", &"")) != expected_stage_id:
        return _fail("Expected stage %s, got %s." % [expected_stage_id, StringName(snapshot.get("current_stage_id", &""))])

    var battle = main.battle_controller
    if battle == null:
        return _fail("CH01 tutorial runner could not resolve battle controller.")
    if battle.stage_data == null or StringName(battle.stage_data.stage_id) != expected_stage_id:
        return _fail("Battle scene did not load %s stage data." % String(expected_stage_id))
    return true

func _assert_expected_pre_battle_state(main: Node, expected_stage_id: StringName) -> bool:
    if expected_stage_id == &"CH01_05":
        var snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(snapshot.get("mode", "")) == "briefing":
            return _assert_briefing_snapshot(snapshot, expected_stage_id)
    return true

func _assert_stage_entry(main: Node, expected_stage_id: StringName) -> bool:
    if not _assert_expected_pre_battle_state(main, expected_stage_id):
        return false

    var snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(snapshot.get("mode", "")) == "briefing":
        main.advance_campaign_step()
        await process_frame
        await process_frame

    if not _assert_battle_ready(main, expected_stage_id):
        return false

    var battle = main.battle_controller
    if not _assert_start_cutscene(battle, battle.stage_data.start_cutscene_id):
        return false
    await _finish_active_cutscene(battle)
    return true

func _play_battle_to_victory(battle) -> void:
    var max_round_loops: int = 20
    for _round_loop in range(max_round_loops):
        await _wait_for_player_phase(battle)
        if _is_battle_finished(battle):
            break

        await _play_player_phase(battle)
        await process_frame
        await process_frame

        if _is_battle_finished(battle):
            break

    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        _fail("Battle did not finish in victory during CH01 tutorial automation. %s" % _describe_battle_state(battle))
        return

func _wait_for_player_phase(battle) -> void:
    var safety: int = 0
    while not _is_battle_finished(battle):
        if battle.cutscene_player != null and battle.cutscene_player.is_playing():
            await _finish_active_cutscene(battle)
            continue
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        await process_frame
        safety += 1
        if safety > 180:
            _fail("Timed out waiting for player phase in CH01 tutorial runner.")
            return

func _play_player_phase(battle) -> void:
    while true:
        if _is_battle_finished(battle):
            return

        var ready_units: Array = _get_ready_ally_units(battle)
        if ready_units.is_empty():
            battle._on_end_turn_requested()
            await process_frame
            return

        var unit = ready_units[0]
        battle._on_world_cell_pressed(unit.grid_position)
        await process_frame

        var acted: bool = await _take_action_for_unit(battle, unit)
        if acted:
            return

        _fail("CH01 tutorial runner could not find a valid player action.")
        return

func _take_action_for_unit(battle, unit) -> bool:
    var interaction_destination: Vector2i = _pick_interaction_destination(battle, unit)
    if interaction_destination != Vector2i(-1, -1):
        if interaction_destination != unit.grid_position:
            battle._on_world_cell_pressed(interaction_destination)
            await process_frame

        var interactable = _find_interactable_object_for_selected_unit(battle)
        if interactable != null:
            battle._on_world_cell_pressed(interactable.grid_position)
            await process_frame
            return true

    var opponents: Array = battle.enemy_units
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)
    var plan: Dictionary = battle.ai_service.pick_action(unit, opponents, battle.path_service, battle.range_service, dynamic_blocked)
    var action_type: String = String(plan.get("type", "wait"))

    if action_type == "attack":
        var immediate_target = plan.get("target", null)
        if immediate_target != null:
            battle._on_world_cell_pressed(immediate_target.grid_position)
            await process_frame
            return true

    if action_type == "move_attack":
        var move_to: Vector2i = plan.get("move_to", unit.grid_position)
        if move_to != unit.grid_position:
            battle._on_world_cell_pressed(move_to)
            await process_frame

        var target = plan.get("target", null)
        if target != null:
            battle._on_world_cell_pressed(target.grid_position)
            await process_frame
            return true

    if action_type == "move_wait":
        var wait_destination: Vector2i = plan.get("move_to", unit.grid_position)
        if wait_destination != unit.grid_position:
            battle._on_world_cell_pressed(wait_destination)
            await process_frame

        battle._on_wait_requested()
        _wait_tested = true
        await process_frame
        return true

    battle._on_wait_requested()
    _wait_tested = true
    await process_frame
    return true

func _get_ready_ally_units(battle) -> Array:
    var ready_units: Array = []
    for unit in battle.ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
            ready_units.append(unit)
    return ready_units

func _is_battle_finished(battle) -> bool:
    var phase: int = int(battle.current_phase)
    return phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT)

func _describe_battle_state(battle) -> String:
    var object_states: Array[String] = []
    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor):
            continue
        object_states.append("%s=%s" % [str(object_actor.object_data.object_id), str(object_actor.is_resolved)])

    return "stage=%s phase=%s enemies=%d objects=[%s]" % [
        str(battle.stage_data.stage_id),
        str(battle.current_phase),
        battle.enemy_units.size(),
        str(object_states)
    ]

func _pick_interaction_destination(battle, unit) -> Vector2i:
    var win_condition: String = String(battle.stage_data.win_condition)
    if win_condition != "resolve_all_interactions" and win_condition != "resolve_all_interactions_and_defeat_all_enemies":
        return Vector2i(-1, -1)

    var best_destination := Vector2i(-1, -1)
    var best_cost: int = 2147483647
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)

    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
            continue

        if object_actor.can_interact(unit):
            return unit.grid_position

        var candidate_cells: Array = battle.range_service.get_attack_cells(object_actor.grid_position, object_actor.object_data.interaction_range)
        for cell in candidate_cells:
            if not battle.path_service.is_walkable(cell, dynamic_blocked):
                continue

            var path: Array = battle.path_service.find_path(unit.grid_position, cell, dynamic_blocked)
            if path.is_empty():
                continue

            var path_cost: int = battle.path_service.get_path_cost(path)
            if path_cost < best_cost:
                best_cost = path_cost
                best_destination = battle.ai_service._truncate_path_to_movement(path, unit.get_movement(), battle.path_service)

    return best_destination

func _find_interactable_object_for_selected_unit(battle):
    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
            continue
        if battle._can_selected_unit_interact(object_actor):
            return object_actor
    return null

func _fail(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
