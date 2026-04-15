class_name InputController
extends Node

signal world_cell_pressed(cell: Vector2i)

@export var cell_size: Vector2i = Vector2i(64, 64)
@export var board_origin: Vector2 = Vector2.ZERO

var world_input_enabled: bool = true
var ui_blocking_rects_provider: Callable

func _unhandled_input(event: InputEvent) -> void:
    if not world_input_enabled:
        return

    var world_position := Vector2.ZERO
    var should_emit: bool = false

    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        world_position = event.position
        should_emit = true
    elif event is InputEventScreenTouch and event.pressed:
        world_position = event.position
        should_emit = true

    if not should_emit or _is_position_blocked_by_ui(world_position):
        return

    world_cell_pressed.emit(_position_to_cell(world_position))

func _position_to_cell(world_position: Vector2) -> Vector2i:
    var local_position := world_position - board_origin
    return Vector2i(
        floori(local_position.x / float(cell_size.x)),
        floori(local_position.y / float(cell_size.y))
    )

func _is_position_blocked_by_ui(world_position: Vector2) -> bool:
    if not ui_blocking_rects_provider.is_valid():
        return false

    var rects_variant: Variant = ui_blocking_rects_provider.call()
    if typeof(rects_variant) != TYPE_ARRAY:
        return false

    for rect in rects_variant:
        if rect is Rect2 and rect.has_point(world_position):
            return true
    return false
