extends "res://scripts/battle/battle_controller.gd"

func bootstrap_battle() -> void:
	super.bootstrap_battle()

	if ally_units.is_empty():
		return

	var vanguard = ally_units[0]
	if vanguard != null and is_instance_valid(vanguard):
		vanguard.set_grid_position(Vector2i(3, 11), stage_data.cell_size)
	if enemy_units.size() >= 2:
		var karon = enemy_units[0]
		var skirmisher = enemy_units[1]
		if karon != null and is_instance_valid(karon):
			karon.set_grid_position(Vector2i(12, 2), stage_data.cell_size)
		if skirmisher != null and is_instance_valid(skirmisher):
			skirmisher.set_grid_position(Vector2i(13, 3), stage_data.cell_size)
	var marked_target = ally_units[0]
	if marked_target == null or not is_instance_valid(marked_target):
		return

	boss_marked_target_id = marked_target.get_instance_id()
	boss_charge_pending = true
	_refresh_unit_visual_state()
	hud.set_transition_reason("boss_mark_telegraphed", {
		"boss": "enemy_karon",
		"target": marked_target.unit_data.unit_id
	})
