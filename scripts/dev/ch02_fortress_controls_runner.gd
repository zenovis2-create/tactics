extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH02_FORTRESS_STAGE = preload("res://data/stages/ch02_04_stage.tres")

const EXPECTED_OBJECTIVE_TEXTS := [
    "Secure the three tunnel controls to expose Hardren's inner gate. (0/3)",
    "One tunnel control is aligned. Secure the remaining controls. (1/3)",
    "Two tunnel controls are aligned. Secure the last control. (2/3)",
    "All tunnel controls are aligned. The inner gate route is exposed. (3/3)"
]

const EXPECTED_STATE_IDS := [
    &"fortress_controls_unsecured",
    &"fortress_controls_one_secured",
    &"fortress_controls_two_secured",
    &"fortress_controls_exposed"
]

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(CH02_FORTRESS_STAGE)

    await process_frame
    await process_frame

    _assert_equal(battle.interactive_objects.size(), 3, "CH02 fortress stage should author three control points.")
    if _failed:
        return

    _assert_objective_state(battle, 0)
    if _failed:
        return

    var ally = battle.ally_units[0]
    for index in range(battle.interactive_objects.size()):
        battle._resolve_interaction(ally, battle.interactive_objects[index])
        await process_frame
        _assert_objective_state(battle, index + 1)
        if _failed:
            return

    if not battle._check_battle_end():
        _fail("Resolving every fortress control should satisfy the CH02_04 win condition.")
        return

    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        _fail("CH02 fortress controls should finish in victory after the final control resolves.")
        return

    print("[PASS] CH02 fortress controls runner validated authored objective progression and victory state.")
    quit(0)

func _assert_objective_state(battle, resolved_count: int) -> void:
    if battle.hud.objective_label.text != "Objective: %s" % EXPECTED_OBJECTIVE_TEXTS[resolved_count]:
        _fail("Unexpected fortress objective label at %d controls: %s" % [
            resolved_count,
            battle.hud.objective_label.text
        ])
        return

    var snapshot: Dictionary = battle.get_objective_state_snapshot()
    _assert_equal(int(snapshot.get("resolved_interactions", -1)), resolved_count, "Resolved interaction count drifted.")
    if _failed:
        return
    _assert_equal(int(snapshot.get("required_interactions", -1)), 3, "CH02 fortress controls should require all three authored controls.")
    if _failed:
        return
    _assert_equal(StringName(snapshot.get("state_id", &"")), EXPECTED_STATE_IDS[resolved_count], "Unexpected fortress objective state id.")

func _assert_equal(actual, expected, message: String) -> void:
    if actual == expected:
        return
    _fail("%s Expected %s, got %s." % [message, str(expected), str(actual)])

func _fail(message: String) -> void:
    if _failed:
        return
    _failed = true
    push_error(message)
    quit(1)
