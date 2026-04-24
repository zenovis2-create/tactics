extends "res://scripts/battle/battle_controller.gd"

func bootstrap_battle() -> void:
	super.bootstrap_battle()

	if ally_units.size() < 2:
		return

	var vanguard = ally_units[0]
	var marked_target = ally_units[1]
	if vanguard != null and is_instance_valid(vanguard):
		vanguard.set_grid_position(Vector2i(9, 4), stage_data.cell_size)
	if marked_target != null and is_instance_valid(marked_target):
		marked_target.set_grid_position(Vector2i(10, 3), stage_data.cell_size)
	if enemy_units.size() >= 2:
		var saria = enemy_units[0]
		var skirmisher = enemy_units[1]
		if saria != null and is_instance_valid(saria):
			saria.set_grid_position(Vector2i(11, 2), stage_data.cell_size)
		if skirmisher != null and is_instance_valid(skirmisher):
			skirmisher.set_grid_position(Vector2i(12, 4), stage_data.cell_size)
	if marked_target == null or not is_instance_valid(marked_target):
		return

	boss_marked_target_id = marked_target.get_instance_id()
	boss_charge_pending = true
	_refresh_unit_visual_state()
	_focus_camera_on_cells([Vector2i(9, 3), Vector2i(9, 3), Vector2i(10, 2)], Vector2(0.9, 0.9))
	hud.set_transition_reason("boss_mark_telegraphed", {
		"boss": "enemy_saria",
		"target": marked_target.unit_data.unit_id
	})

func _focus_camera_on_cells(cells: Array, zoom_value: Vector2) -> void:
	if battle_camera == null or stage_data == null or cells.is_empty():
		return
	var sum := Vector2.ZERO
	for cell_variant in cells:
		var cell := Vector2(cell_variant)
		sum += board_origin + (cell + Vector2(0.5, 0.5)) * Vector2(stage_data.cell_size) * board_scale
	battle_camera.position = sum / float(cells.size())
	battle_camera.zoom = zoom_value
