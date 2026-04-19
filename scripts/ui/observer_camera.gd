class_name ObserverCamera
extends Node3D

# Observer Camera — free-perspective camera for watching battles
# Controls: WASD to pan, Q/E to zoom, drag to rotate

signal camera_moved(position: Vector3)

const PAN_SPEED := 15.0
const ZOOM_SPEED := 10.0
const ROTATE_SPEED := 2.0
const MIN_HEIGHT := 5.0
const MAX_HEIGHT := 60.0
const DEFAULT_HEIGHT := 25.0

var _is_active: bool = false
var _target_position: Vector3 = Vector3.ZERO
var _current_height: float = DEFAULT_HEIGHT
var _rotation_angle: float = 0.0
var _drag_active: bool = false
var _last_drag_pos: Vector2 = Vector2.ZERO

var _observed_battle_id: String = ""

func _ready() -> void:
	_is_active = false
	position = Vector3(0, _current_height, 0)

func activate(observed_battle_id: String = "") -> void:
	_is_active = true
	_observed_battle_id = observed_battle_id
	print("[ObserverCamera] Activated for battle: %s" % observed_battle_id if not observed_battle_id.is_empty() else "[ObserverCamera] Activated")

func deactivate() -> void:
	_is_active = false
	_observed_battle_id = ""
	print("[ObserverCamera] Deactivated")

func is_active() -> bool:
	return _is_active

func get_observed_battle_id() -> String:
	return _observed_battle_id

func focus_on_position(world_pos: Vector3) -> void:
	_target_position = world_pos
	_smooth_move()

func focus_on_unit(unit_name: String) -> void:
	# In a real implementation, this would look up the unit's world position
	# from the battle state. Here we just set the target.
	_target_position = Vector3(0, 0, 0)
	print("[ObserverCamera] Focusing on unit: %s" % unit_name)

func _process(delta: float) -> void:
	if not _is_active:
		return
	_handle_keyboard_input(delta)
	_smooth_move()

func _handle_keyboard_input(delta: float) -> void:
	var move_vec := Vector3.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_vec.z -= PAN_SPEED * delta
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_vec.z += PAN_SPEED * delta
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_vec.x -= PAN_SPEED * delta
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_vec.x += PAN_SPEED * delta
	if Input.is_key_pressed(KEY_Q):
		_current_height = clampf(_current_height - ZOOM_SPEED * delta, MIN_HEIGHT, MAX_HEIGHT)
	if Input.is_key_pressed(KEY_E):
		_current_height = clampf(_current_height + ZOOM_SPEED * delta, MIN_HEIGHT, MAX_HEIGHT)
	var rotated_move := move_vec.rotated(Vector3.UP, _rotation_angle)
	_target_position += rotated_move

func _smooth_move() -> void:
	var target := Vector3(_target_position.x, _current_height, _target_position.z)
	position = position.lerp(target, 0.1)
	if position.distance_to(target) > 0.1:
		camera_moved.emit(position)

func _input(event: InputEvent) -> void:
	if not _is_active:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			_drag_active = mb.pressed
			_last_drag_pos = mb.position
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_current_height = clampf(_current_height - ZOOM_SPEED * 0.3, MIN_HEIGHT, MAX_HEIGHT)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_current_height = clampf(_current_height + ZOOM_SPEED * 0.3, MIN_HEIGHT, MAX_HEIGHT)
	elif event is InputEventMouseMotion and _drag_active:
		var mm: InputEventMouseMotion = event
		var delta := mm.position - _last_drag_pos
		_rotation_angle -= delta.x * 0.005
		_current_height = clampf(_current_height + delta.y * 0.1, MIN_HEIGHT, MAX_HEIGHT)
		_last_drag_pos = mm.position

func get_camera_info() -> Dictionary:
	return {
		"is_active": _is_active,
		"position": position,
		"height": _current_height,
		"rotation": _rotation_angle,
		"battle_id": _observed_battle_id
	}
