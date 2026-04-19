extends SceneTree

const BUS_SILENCE_DB := -80.0
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const BattleScene = preload("res://scenes/battle/BattleScene.tscn")

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame

	save_service.delete_slot(8)
	var save_error := save_service.save_progression(ProgressionData.new(), 8)
	_assert(save_error == OK, "Expected fresh slot_8 save to succeed, got %s." % error_string(save_error))
	if _failed:
		return

	var music: Node = root.get_node_or_null("Music")
	_assert(music != null, "Music autoload should exist at /root/Music.")
	_assert(music != null and music.has_method("activate_layer"), "Music autoload should expose activate_layer().")
	_assert(music != null and music.has_method("deactivate_layer"), "Music autoload should expose deactivate_layer().")
	if _failed:
		return

	var initial_layers: Array[String] = []
	music.play_layered_track("bgm_battle_default", initial_layers)
	await process_frame

	var base_bus := AudioServer.get_bus_index(&"MusicBase")
	var drums_bus := AudioServer.get_bus_index(&"MusicDrums")
	_assert(base_bus != -1, "MusicBase bus should exist once Music initializes.")
	_assert(drums_bus != -1, "MusicDrums bus should exist once Music initializes.")
	if _failed:
		return

	var drums_before := AudioServer.get_bus_volume_db(drums_bus)
	music.activate_layer("DRUMS", 0.05)
	await _wait_seconds(0.08)
	var drums_after := AudioServer.get_bus_volume_db(drums_bus)
	_assert(drums_after > drums_before, "activate_layer(DRUMS) should raise the MusicDrums bus volume.")
	_assert(music.is_layer_active("DRUMS_PERCUSSION"), "DRUMS_PERCUSSION should report active after activation.")
	if _failed:
		return

	music.trigger_spotlight_music("triple_kill")
	await _wait_seconds(0.1)
	_assert(music.get_layer_level("DRUMS_PERCUSSION") > 1.0, "triple_kill should boost the drums layer above its base level.")
	if _failed:
		return

	music.trigger_spotlight_music("bond_death")
	await _wait_seconds(0.12)
	_assert(music.has_layer("VOCAL_CHORUS"), "bond_death should resolve the vocal chorus layer definition.")
	_assert(music.is_layer_active("VOCAL_CHORUS"), "bond_death should activate the vocal chorus layer.")
	if _failed:
		return

	var battle: Node = BattleScene.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	_assert(AudioServer.get_bus_volume_db(base_bus) > BUS_SILENCE_DB, "Battle bootstrap should leave the base soundtrack bus active.")
	if _failed:
		return

	var enemy_units: Array = battle.get("enemy_units")
	enemy_units.clear()
	battle.set("enemy_units", enemy_units)
	battle.call("_check_battle_end")
	await _wait_seconds(2.15)
	_assert(not music.is_layer_active("BASE_MELODY"), "Battle end should deactivate the base melody layer.")
	_assert(not music.is_layer_active("DRUMS_PERCUSSION"), "Battle end should deactivate the drums layer.")
	_assert(not music.is_layer_active("VOCAL_CHORUS"), "Battle end should deactivate the vocal layer.")
	if _failed:
		return

	print("[PASS] living_soundtrack_runner: layered music activation, spotlight boosts, and battle-end shutdown verified.")
	quit(0)


func _wait_seconds(duration: float) -> void:
	await create_timer(duration, false).timeout


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	print("[FAIL] %s" % message)
	quit(1)
