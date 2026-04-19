class_name EmotionalLayerController
extends Node

signal spotlight_triggered(spotlight_type: String)
signal bond_death_started(unit_id: String)

var _campaign_controller: Node = null


func _ready() -> void:
	if not spotlight_triggered.is_connected(_on_spotlight_triggered):
		spotlight_triggered.connect(_on_spotlight_triggered)
	if not bond_death_started.is_connected(_on_bond_death_started):
		bond_death_started.connect(_on_bond_death_started)
	set_process(true)
	_try_connect_campaign_controller()


func _process(_delta: float) -> void:
	if _campaign_controller != null and is_instance_valid(_campaign_controller):
		set_process(false)
		return
	_try_connect_campaign_controller()


func emit_spotlight(spotlight_type: String) -> void:
	var normalized_type := spotlight_type.strip_edges().to_lower()
	if normalized_type.is_empty():
		return
	spotlight_triggered.emit(normalized_type)


func _on_spotlight_triggered(spotlight_type: String) -> void:
	var normalized_type := spotlight_type.strip_edges().to_lower()
	if normalized_type not in ["bond_death", "boss", "critical", "victory"]:
		return
	var music := _get_layered_music()
	if music == null:
		return
	music.call("trigger_spotlight_music", normalized_type)


func _on_bond_death_started(unit_id: String) -> void:
	var music := _get_layered_music()
	if music == null:
		return
	music.call("trigger_spotlight_music", "bond_death")


func _try_connect_campaign_controller() -> void:
	var candidate := _find_campaign_controller(get_tree().root)
	if candidate == null:
		set_process(true)
		return
	_campaign_controller = candidate
	_connect_campaign_signals(candidate)
	set_process(false)


func _connect_campaign_signals(controller: Node) -> void:
	if controller == null:
		return
	if controller.has_signal("spotlight_triggered"):
		var spotlight_callback := Callable(self, "_on_campaign_spotlight_triggered")
		if not controller.spotlight_triggered.is_connected(spotlight_callback):
			controller.spotlight_triggered.connect(spotlight_callback)
	if controller.has_signal("bond_death_started"):
		var bond_started_callback := Callable(self, "_on_campaign_bond_death_started")
		if not controller.bond_death_started.is_connected(bond_started_callback):
			controller.bond_death_started.connect(bond_started_callback)
	if controller.has_signal("bond_death_triggered"):
		var bond_triggered_callback := Callable(self, "_on_campaign_bond_death_triggered")
		if not controller.bond_death_triggered.is_connected(bond_triggered_callback):
			controller.bond_death_triggered.connect(bond_triggered_callback)


func _on_campaign_spotlight_triggered(spotlight_type: Variant, _payload: Variant = null) -> void:
	var normalized_type := String(spotlight_type).strip_edges().to_lower()
	if normalized_type.is_empty():
		return
	spotlight_triggered.emit(normalized_type)


func _on_campaign_bond_death_started(unit_id: Variant = "") -> void:
	bond_death_started.emit(String(unit_id))


func _on_campaign_bond_death_triggered(unit_id: Variant = "", _ending_id: Variant = "") -> void:
	bond_death_started.emit(String(unit_id))


func _get_layered_music() -> Node:
	var layered_music := get_node_or_null("/root/LayeredMusic")
	if layered_music != null:
		return layered_music
	return get_node_or_null("/root/Music")


func _find_campaign_controller(node: Node) -> Node:
	for child in node.get_children():
		if _is_campaign_controller_candidate(child):
			return child
		var nested_match := _find_campaign_controller(child)
		if nested_match != null:
			return nested_match
	return null


func _is_campaign_controller_candidate(node: Node) -> bool:
	if node == null or node == self:
		return false
	var script: Script = node.get_script()
	var script_path := String(script.resource_path) if script != null else ""
	var identity_match := node.name == "CampaignController" or node.get_class() == "CampaignController" or script_path.ends_with("campaign_controller.gd")
	if not identity_match:
		return false
	return node.has_signal("spotlight_triggered") or node.has_signal("bond_death_started") or node.has_signal("bond_death_triggered")
