extends "res://scripts/battle/battle_controller.gd"

func bootstrap_battle() -> void:
	super.bootstrap_battle()

	if ally_units.size() < 2:
		return

	var vanguard = ally_units[0]
	var scout = ally_units[1]
	if vanguard != null and is_instance_valid(vanguard):
		vanguard.set_grid_position(Vector2i(2, 5), stage_data.cell_size)
	if scout != null and is_instance_valid(scout):
		scout.set_grid_position(Vector2i(3, 6), stage_data.cell_size)
	if enemy_units.size() >= 2:
		var raider = enemy_units[0]
		var skirmisher = enemy_units[1]
		if raider != null and is_instance_valid(raider):
			raider.set_grid_position(Vector2i(5, 1), stage_data.cell_size)
		if skirmisher != null and is_instance_valid(skirmisher):
			skirmisher.set_grid_position(Vector2i(6, 1), stage_data.cell_size)

	if vanguard != null and is_instance_valid(vanguard):
		_select_unit(vanguard)
		hud.set_action_hint("Follow the vanished trail and recover the missing route markers.")
