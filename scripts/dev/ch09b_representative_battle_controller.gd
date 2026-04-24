extends "res://scripts/battle/battle_controller.gd"

func bootstrap_battle() -> void:
	super.bootstrap_battle()

	if ally_units.size() < 2:
		return

	var vanguard = ally_units[0]
	var scout = ally_units[1]
	if vanguard != null and is_instance_valid(vanguard):
		vanguard.set_grid_position(Vector2i(3, 2), stage_data.cell_size)
	if scout != null and is_instance_valid(scout):
		scout.set_grid_position(Vector2i(5, 4), stage_data.cell_size)
	if enemy_units.size() >= 2:
		var melkion = enemy_units[0]
		var skirmisher = enemy_units[1]
		if melkion != null and is_instance_valid(melkion):
			melkion.set_grid_position(Vector2i(5, 1), stage_data.cell_size)
		if skirmisher != null and is_instance_valid(skirmisher):
			skirmisher.set_grid_position(Vector2i(6, 2), stage_data.cell_size)

	if vanguard != null and is_instance_valid(vanguard):
		_select_unit(vanguard)
		_focus_camera_on_cells([Vector2i(4, 2), Vector2i(4, 2), Vector2i(5, 1)], Vector2(0.91, 0.91))
		hud.set_action_hint("Stabilize the archive lectern before the rewrite pressure closes.")

func _focus_camera_on_cells(cells: Array, zoom_value: Vector2) -> void:
	if battle_camera == null or stage_data == null or cells.is_empty():
		return
	var sum := Vector2.ZERO
	for cell_variant in cells:
		var cell := Vector2(cell_variant)
		sum += board_origin + (cell + Vector2(0.5, 0.5)) * Vector2(stage_data.cell_size) * board_scale
	battle_camera.position = sum / float(cells.size())
	battle_camera.zoom = zoom_value
