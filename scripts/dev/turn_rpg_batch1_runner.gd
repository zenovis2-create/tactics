extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH04_FLOODGATE_STAGE = preload("res://data/stages/ch04_03_stage.tres")

var _failed := false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(CH04_FLOODGATE_STAGE)

    await process_frame
    await process_frame

    if not battle.hud.has_method("get_risk_forecast_snapshot"):
        _fail("BattleHUD must expose get_risk_forecast_snapshot() for risk forecast cards.")
        return
    var risk_snapshot: Dictionary = battle.hud.get_risk_forecast_snapshot()
    var cards: Array = risk_snapshot.get("cards", [])
    if cards.size() != 3:
        _fail("Risk forecast should render exactly 3 cards at battle start.")
        return
    for index in range(cards.size()):
        var card: Dictionary = cards[index]
        if String(card.get("title", "")).strip_edges().is_empty():
            _fail("Risk forecast card %d should have a title." % index)
            return
        if String(card.get("detail", "")).strip_edges().is_empty():
            _fail("Risk forecast card %d should have detail text." % index)
            return

    var ally = battle.ally_units[0]
    ally.set_grid_position(Vector2i(2, 6), battle.stage_data.cell_size)
    battle._select_unit(ally)
    await process_frame

    if not battle.hud.has_method("get_selection_snapshot"):
        _fail("BattleHUD must expose get_selection_snapshot() for preview labels.")
        return
    var selection_snapshot: Dictionary = battle.hud.get_selection_snapshot()
    var preview_labels: Array = selection_snapshot.get("preview_labels", [])
    if preview_labels.is_empty():
        _fail("Selection preview should expose state/objective delta labels when an interaction is available.")
        return

    var joined := " ".join(preview_labels)
    if joined.find("Objective +1") == -1:
        _fail("Selection preview should describe the objective delta for the nearby interaction.")
        return
    if joined.find("West Sluice Wheel") == -1:
        _fail("Selection preview should mention the nearby interaction target.")
        return

    print("[PASS] turn_rpg_batch1_runner: risk forecast and preview labels validated.")
    quit(0)

func _fail(message: String) -> void:
    if _failed:
        return
    _failed = true
    push_error("[FAIL] turn_rpg_batch1_runner: %s" % message)
    quit(1)
