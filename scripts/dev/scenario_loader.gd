class_name ScenarioLoader
extends RefCounted

const ScenarioData = preload("res://scripts/data/scenario.gd")

static func load_scenario(scenario_id: StringName) -> ScenarioData:
	var file_path := "user://scenarios/%s.tres" % scenario_id
	if ResourceLoader.exists(file_path):
		var loaded: ScenarioData = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		return loaded
	push_warning("[ScenarioLoader] Scenario not found: ", scenario_id)
	return null

static func save_scenario(scenario: ScenarioData) -> bool:
	var scenario_dir := DirAccess.open("user://scenarios/")
	if scenario_dir == null:
		DirAccess.make_dir_recursive_absolute("user://scenarios")
	var file_path := "user://scenarios/%s.tres" % scenario.scenario_id
	var result := ResourceSaver.save(scenario, file_path)
	if result == OK:
		print("[ScenarioLoader] Saved: ", file_path)
		return true
	push_error("[ScenarioLoader] Save failed: ", result)
	return false

static func delete_scenario(scenario_id: StringName) -> bool:
	var file_path := "user://scenarios/%s.tres" % scenario_id
	if FileAccess.file_exists(file_path):
		var err := DirAccess.remove_absolute(file_path)
		if err == OK:
			print("[ScenarioLoader] Deleted: ", file_path)
			return true
		push_error("[ScenarioLoader] Delete failed: ", err)
	return false

static func list_all_scenarios() -> Array[Dictionary]:
	var scenarios: Array[Dictionary] = []
	var scenario_dir := DirAccess.open("user://scenarios/")
	if scenario_dir == null:
		return scenarios
	scenario_dir.list_dir_begin()
	var file_name := scenario_dir.get_next()
	while not file_name.is_empty():
		if file_name.ends_with(".tres"):
			var scenario_id: StringName = StringName(file_name.replace(".tres", ""))
			var loaded: ScenarioData = load_scenario(scenario_id)
			if loaded != null:
				scenarios.append({
					"scenario_id": loaded.scenario_id,
					"title": loaded.get_display_title(),
					"description": loaded.scenario_description,
					"author": loaded.author_name,
					"difficulty": loaded.difficulty_rating,
					"stage_count": loaded.get_stage_count(),
					"tags": Array(loaded.tags)
				})
		file_name = scenario_dir.get_next()
	scenario_dir.list_lib_entries_end()
	return scenarios

static func import_from_json(json_path: String) -> ScenarioData:
	if not FileAccess.file_exists(json_path):
		push_error("[ScenarioLoader] JSON file not found: ", json_path)
		return null
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("[ScenarioLoader] Cannot open JSON: ", json_path)
		return null
	var json_text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error("[ScenarioLoader] JSON parse error: ", parse_result)
		return null
	var data: Dictionary = json.data
	var scenario := ScenarioData.new()
	scenario.scenario_id = StringName(data.get("scenario_id", "imported_%d" % Time.get_unix_time_from_system()))
	scenario.scenario_title = data.get("title", "Imported Scenario")
	scenario.scenario_description = data.get("description", "")
	scenario.author_name = data.get("author", "Unknown")
	scenario.difficulty_rating = data.get("difficulty", 1)
	scenario.tags = PackedStringArray(data.get("tags", []))
	if data.has("stages"):
		for stage_data: Dictionary in data["stages"]:
			var stage := ScenarioData.ScenarioStage.new()
			stage.stage_id = StringName(stage_data.get("stage_id", "stage_001"))
			stage.stage_title = stage_data.get("title", "")
			stage.map_width = stage_data.get("map_width", 8)
			stage.map_height = stage_data.get("map_height", 8)
			stage.turn_limit = stage_data.get("turn_limit", 20)
			stage.briefing_text = stage_data.get("briefing", "")
			stage.victory_text = stage_data.get("victory", "")
			stage.defeat_text = stage_data.get("defeat", "")
			if stage_data.has("ally_spawns"):
				for spawn: Array in stage_data["ally_spawns"]:
					stage.ally_spawns.append(Vector2i(spawn[0], spawn[1]))
			if stage_data.has("enemy_spawns"):
				for spawn: Array in stage_data["enemy_spawns"]:
					stage.enemy_spawns.append(Vector2i(spawn[0], spawn[1]))
			if stage_data.has("blocked"):
				for cell: Array in stage_data["blocked"]:
					stage.blocked_cells.append(Vector2i(cell[0], cell[1]))
			scenario.stages.append(stage)
	if data.has("dialogues"):
		scenario.dialogue_catalog = data["dialogues"]
	return scenario

static func export_to_json(scenario: ScenarioData, json_path: String) -> bool:
	var data: Dictionary = {
		"scenario_id": String(scenario.scenario_id),
		"title": scenario.scenario_title,
		"description": scenario.scenario_description,
		"author": scenario.author_name,
		"difficulty": scenario.difficulty_rating,
		"tags": Array(scenario.tags),
		"stages": []
	}
	for stage: ScenarioData.ScenarioStage in scenario.stages:
		var stage_dict: Dictionary = {
			"stage_id": String(stage.stage_id),
			"title": stage.stage_title,
			"map_width": stage.map_width,
			"map_height": stage.map_height,
			"turn_limit": stage.turn_limit,
			"briefing": stage.briefing_text,
			"victory": stage.victory_text,
			"defeat": stage.defeat_text,
			"ally_spawns": [],
			"enemy_spawns": [],
			"blocked": []
		}
		for spawn: Vector2i in stage.ally_spawns:
			stage_dict["ally_spawns"].append([spawn.x, spawn.y])
		for spawn: Vector2i in stage.enemy_spawns:
			stage_dict["enemy_spawns"].append([spawn.x, spawn.y])
		for cell: Vector2i in stage.blocked_cells:
			stage_dict["blocked"].append([cell.x, cell.y])
		data["stages"].append(stage_dict)
	if not scenario.dialogue_catalog.is_empty():
		data["dialogues"] = scenario.dialogue_catalog
	var file := FileAccess.open(json_path, FileAccess.WRITE)
	if file == null:
		push_error("[ScenarioLoader] Cannot write JSON: ", json_path)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("[ScenarioLoader] Exported to ", json_path)
	return true

# === Steam Workshop Stub ===
static func publish_to_workshop(scenario: ScenarioData) -> bool:
	# Stub: Steam Workshop integration placeholder
	# In production, this would use SteamWorkshop API to publish the scenario
	push_warning("[ScenarioLoader] Steam Workshop publish stub called for: ", scenario.scenario_id)
	return false

static func download_from_workshop(workshop_id: String) -> ScenarioData:
	# Stub: Steam Workshop download placeholder
	push_warning("[ScenarioLoader] Steam Workshop download stub called for: ", workshop_id)
	return null

static func list_workshop_scenarios() -> Array[Dictionary]:
	# Stub: Returns empty list until Steam API is integrated
	push_warning("[ScenarioLoader] Steam Workshop list stub called")
	return []
