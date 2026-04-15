extends "res://scripts/battle/battle_controller.gd"

func bootstrap_battle() -> void:
	super.bootstrap_battle()

	if ally_units.size() < 2:
		return

	var vanguard = ally_units[0]
	var scout = ally_units[1]
	if vanguard != null and is_instance_valid(vanguard):
		vanguard.set_grid_position(Vector2i(7, 6), stage_data.cell_size)
	if scout != null and is_instance_valid(scout):
		scout.set_grid_position(Vector2i(4, 6), stage_data.cell_size)

	if vanguard != null and is_instance_valid(vanguard):
		_select_unit(vanguard)
		hud.set_action_hint("Open the supply chest and break the raider line.")
