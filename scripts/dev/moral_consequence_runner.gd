extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const EthicsTracker = preload("res://scripts/battle/ethics_tracker.gd")

const SLOT_ID := 9

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ethics = root.get_node_or_null("/root/Ethics")
	if not ethics is EthicsTracker:
		_fail("Ethics autoload is missing.")
		return
	var moral_consequence = root.get_node_or_null("/root/MoralConsequence")
	if moral_consequence == null:
		_fail("MoralConsequence autoload is missing.")
		return

	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame

	save_service.delete_slot(SLOT_ID)
	var loaded_data = save_service.load_progression(SLOT_ID)
	if loaded_data == null:
		_fail("Fresh slot_9 should load default progression data.")
		return

	ethics.bind_progression(loaded_data)
	ethics.reset_tracking()
	if moral_consequence.has_method("bind_progression"):
		moral_consequence.bind_progression(loaded_data)

	for _index in range(3):
		ethics.record_decision("CH01", "spared_enemy", ethics.get_decision_weight("spared_enemy"))
	_assert(is_equal_approx(ethics.ethics_score, 15.0), "Three spared_enemy decisions should set ethics_score to +15.")

	ethics.record_decision("CH02", "burned_bridge", ethics.get_decision_weight("burned_bridge"))
	_assert(is_equal_approx(ethics.ethics_score, 5.0), "One burned_bridge after +15 should set ethics_score to +5.")
	_assert(ethics.get_ethics_bracket() == "pragmatic", "+5 should remain in the pragmatic bracket.")

	ethics.record_decision("CH03", "left_unit_to_die", ethics.get_decision_weight("left_unit_to_die"))
	_assert(is_equal_approx(ethics.ethics_score, -10.0), "One left_unit_to_die after +5 should set ethics_score to -10.")
	_assert(ethics.get_ethics_bracket() == "pragmatic", "-10 should remain in the pragmatic bracket.")

	for _index in range(2):
		ethics.record_decision("CH04", "burned_bridge", ethics.get_decision_weight("burned_bridge"))
	_assert(is_equal_approx(ethics.ethics_score, -30.0), "Two more burned_bridge decisions should set ethics_score to -30.")
	_assert(ethics.get_ethics_bracket() == "ruthless", "-30 should fall into the ruthless bracket for consequence application.")

	var boss_modifier = moral_consequence.apply_consequences_to_boss("leonika")
	_assert(is_equal_approx(float(boss_modifier.boss_damage_multiplier), 1.15), "Ruthless bracket should raise boss damage multiplier to 1.15.")
	var boss_dialogue := String(moral_consequence.get_boss_dialogue_variant("leonika"))
	_assert(boss_dialogue.find("학살자") != -1, "Leonika ruthless dialogue should mention 학살자.")

	print("[PASS] moral_consequence_runner: ethics brackets, boss modifiers, and dialogue variants verified.")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)

func _fail(message: String) -> void:
	print("[FAIL] %s" % message)
	quit(1)
