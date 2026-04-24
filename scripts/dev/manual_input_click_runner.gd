extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    await process_frame
    await process_frame
    await process_frame

    if battle == null or battle.input_controller == null:
        return _fail("manual_input_click_runner could not resolve battle or input controller.")
    if battle.selected_unit == null:
        return _fail("manual_input_click_runner expected an auto-selected ally at battle start.")

    var unit = battle.selected_unit
    var unit_screen: Vector2 = _cell_center_screen(battle, unit.grid_position)
    var select_event := InputEventMouseButton.new()
    select_event.button_index = MOUSE_BUTTON_LEFT
    select_event.pressed = true
    select_event.position = unit_screen
    battle.input_controller._unhandled_input(select_event)
    await process_frame

    if battle.selected_unit != unit:
        return _fail("Screen click on selected unit did not keep unit selected.")

    var reachable: Array = battle.reachable_cells
    if reachable.is_empty():
        return _fail("Selected unit has no reachable cells for click-path test.")

    var destination: Vector2i = Vector2i(reachable[0])
    if destination == unit.grid_position and reachable.size() > 1:
        destination = Vector2i(reachable[1])
    if destination == unit.grid_position:
        return _fail("Could not find a destination cell different from the selected unit cell.")

    var move_event := InputEventMouseButton.new()
    move_event.button_index = MOUSE_BUTTON_LEFT
    move_event.pressed = true
    move_event.position = _cell_center_screen(battle, destination)
    battle.input_controller._unhandled_input(move_event)
    await process_frame

    if unit.grid_position != destination:
        return _fail("Screen click move did not change unit grid position. expected=%s actual=%s" % [destination, unit.grid_position])

    print("[PASS] manual_input_click_runner validated selection and movement through InputController screen clicks.")
    quit(0)

func _cell_center_screen(battle, cell: Vector2i) -> Vector2:
    return battle.board_origin + Vector2(
        (float(cell.x) + 0.5) * float(battle.input_controller.cell_size.x),
        (float(cell.y) + 0.5) * float(battle.input_controller.cell_size.y)
    )

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
