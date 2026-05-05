extends SceneTree

const INTERACTIVE_OBJECT_SCENE: PackedScene = preload("res://scenes/battle/InteractiveObject.tscn")
const INTERACTIVE_OBJECT_DATA_SCRIPT = preload("res://scripts/data/interactive_object_data.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var altar := _spawn_object("altar", "Altar Check")
	var lever := _spawn_object("lever", "Lever Check")
	var gate_control := _spawn_object("gate_control", "Gate Control Check")
	var well := _spawn_object("well", "Well Check")
	var battery := _spawn_object("battery", "Battery Check")
	var shrine := _spawn_object("shrine", "Shrine Check")
	var floodgate := _spawn_object("floodgate", "Floodgate Check")
	var evidence := _spawn_object("evidence", "Evidence Check")
	var bell := _spawn_object("bell", "Bell Check")
	var chest := _spawn_object("chest", "Chest Check")
	var chain_control := _spawn_object("chain_control", "Chain Control Check")
	var keeper_lectern := _spawn_object("keeper_lectern", "Keeper Lectern Check")
	var route_marker := _spawn_object("route_marker", "Route Marker Check")
	var latch := _spawn_object("latch", "Latch Check")
	var civic_seal := _spawn_object("civic_seal", "Civic Seal Check")

	if altar == null or lever == null or gate_control == null or well == null or battery == null or shrine == null or floodgate == null or evidence == null or bell == null or chest == null or chain_control == null or keeper_lectern == null or route_marker == null or latch == null or civic_seal == null:
		return _fail("Interaction object routing runner could not instantiate all object families.")

	var altar_icon: TextureRect = altar.get_node_or_null("Icon")
	var lever_icon: TextureRect = lever.get_node_or_null("Icon")
	var gate_control_icon: TextureRect = gate_control.get_node_or_null("Icon")
	var well_icon: TextureRect = well.get_node_or_null("Icon")
	var battery_icon: TextureRect = battery.get_node_or_null("Icon")
	var shrine_icon: TextureRect = shrine.get_node_or_null("Icon")
	var floodgate_icon: TextureRect = floodgate.get_node_or_null("Icon")
	var evidence_icon: TextureRect = evidence.get_node_or_null("Icon")
	var bell_icon: TextureRect = bell.get_node_or_null("Icon")
	var chest_icon: TextureRect = chest.get_node_or_null("Icon")
	var chain_control_icon: TextureRect = chain_control.get_node_or_null("Icon")
	var keeper_lectern_icon: TextureRect = keeper_lectern.get_node_or_null("Icon")
	var route_marker_icon: TextureRect = route_marker.get_node_or_null("Icon")
	var latch_icon: TextureRect = latch.get_node_or_null("Icon")
	var civic_seal_icon: TextureRect = civic_seal.get_node_or_null("Icon")
	if altar_icon == null or altar_icon.texture == null:
		return _fail("Altar object should resolve altar runtime icon.")
	if lever_icon == null or lever_icon.texture == null:
		return _fail("Lever object should resolve lever runtime icon.")
	if gate_control_icon == null or gate_control_icon.texture == null:
		return _fail("Gate-control object should resolve gate_control runtime icon.")
	if well_icon == null or well_icon.texture == null:
		return _fail("Well object should resolve memory_well runtime icon.")
	if battery_icon == null or battery_icon.texture == null:
		return _fail("Battery object should resolve battery_emplacement runtime icon.")
	if shrine_icon == null or shrine_icon.texture == null:
		return _fail("Shrine object should resolve resin_shrine runtime icon.")
	if floodgate_icon == null or floodgate_icon.texture == null:
		return _fail("Floodgate object should resolve floodgate_wheel runtime icon.")
	if evidence_icon == null or evidence_icon.texture == null:
		return _fail("Evidence object should resolve truth_dais runtime icon.")
	if bell_icon == null or bell_icon.texture == null:
		return _fail("Bell object should resolve bell_frame runtime icon.")
	if chest_icon == null or chest_icon.texture == null:
		return _fail("Chest object should resolve chest runtime icon.")
	if chain_control_icon == null or chain_control_icon.texture == null:
		return _fail("Chain-control object should resolve anchor_chain runtime icon.")
	if keeper_lectern_icon == null or keeper_lectern_icon.texture == null:
		return _fail("Keeper-lectern object should resolve archive_lectern runtime icon.")
	if route_marker_icon == null or route_marker_icon.texture == null:
		return _fail("Route-marker object should resolve split_marker_post runtime icon.")
	if latch_icon == null or latch_icon.texture == null:
		return _fail("Latch object should resolve transfer_gate_latch runtime icon.")
	if civic_seal_icon == null or civic_seal_icon.texture == null:
		return _fail("Civic-seal object should resolve city_seal_dais runtime icon.")

	if altar_icon.texture == lever_icon.texture:
		return _fail("Altar and lever should not collapse into the same runtime icon texture.")
	if lever_icon.texture == gate_control_icon.texture:
		return _fail("Lever and gate-control should not collapse into the same runtime icon texture.")
	if altar_icon.texture == well_icon.texture:
		return _fail("Altar and well should not collapse into the same runtime icon texture.")
	if gate_control_icon.texture == well_icon.texture:
		return _fail("Gate-control and well should not collapse into the same runtime icon texture.")
	if gate_control_icon.texture == battery_icon.texture:
		return _fail("Gate-control and battery should not collapse into the same runtime icon texture.")
	if lever_icon.texture == battery_icon.texture:
		return _fail("Lever and battery should not collapse into the same runtime icon texture.")
	if altar_icon.texture == shrine_icon.texture:
		return _fail("Altar and shrine should not collapse into the same runtime icon texture.")
	if well_icon.texture == shrine_icon.texture:
		return _fail("Well and shrine should not collapse into the same runtime icon texture.")
	if gate_control_icon.texture == floodgate_icon.texture:
		return _fail("Gate-control and floodgate should not collapse into the same runtime icon texture.")
	if lever_icon.texture == floodgate_icon.texture:
		return _fail("Lever and floodgate should not collapse into the same runtime icon texture.")
	if altar_icon.texture == evidence_icon.texture:
		return _fail("Altar and evidence should not collapse into the same runtime icon texture.")
	if gate_control_icon.texture == evidence_icon.texture:
		return _fail("Gate-control and evidence should not collapse into the same runtime icon texture.")
	if altar_icon.texture == bell_icon.texture:
		return _fail("Altar and bell should not collapse into the same runtime icon texture.")
	if lever_icon.texture == bell_icon.texture:
		return _fail("Lever and bell should not collapse into the same runtime icon texture.")
	if gate_control_icon.texture == chain_control_icon.texture:
		return _fail("Gate-control and chain-control should not collapse into the same runtime icon texture.")
	if bell_icon.texture == chain_control_icon.texture:
		return _fail("Bell and chain-control should not collapse into the same runtime icon texture.")
	if evidence_icon.texture == keeper_lectern_icon.texture:
		return _fail("Evidence and keeper-lectern should not collapse into the same runtime icon texture.")
	if altar_icon.texture == keeper_lectern_icon.texture:
		return _fail("Altar and keeper-lectern should not collapse into the same runtime icon texture.")
	if bell_icon.texture == keeper_lectern_icon.texture:
		return _fail("Bell and keeper-lectern should not collapse into the same runtime icon texture.")
	if gate_control_icon.texture == route_marker_icon.texture:
		return _fail("Gate-control and route-marker should not collapse into the same runtime icon texture.")
	if lever_icon.texture == route_marker_icon.texture:
		return _fail("Lever and route-marker should not collapse into the same runtime icon texture.")
	if keeper_lectern_icon.texture == route_marker_icon.texture:
		return _fail("Keeper-lectern and route-marker should not collapse into the same runtime icon texture.")
	if gate_control_icon.texture == latch_icon.texture:
		return _fail("Gate-control and latch should not collapse into the same runtime icon texture.")
	if lever_icon.texture == latch_icon.texture:
		return _fail("Lever and latch should not collapse into the same runtime icon texture.")
	if route_marker_icon.texture == latch_icon.texture:
		return _fail("Route-marker and latch should not collapse into the same runtime icon texture.")
	if chest_icon.texture == civic_seal_icon.texture:
		return _fail("Chest and civic-seal should not collapse into the same runtime icon texture.")
	if bell_icon.texture == civic_seal_icon.texture:
		return _fail("Bell and civic-seal should not collapse into the same runtime icon texture.")
	if evidence_icon.texture == civic_seal_icon.texture:
		return _fail("Evidence and civic-seal should not collapse into the same runtime icon texture.")

	print("[PASS] interaction_object_routing_runner validated altar/lever/gate-control/well/battery/shrine/floodgate/evidence/bell/chest/chain_control/keeper_lectern/route_marker/latch/civic_seal runtime routing.")
	quit(0)


func _spawn_object(object_type: String, display_name: String) -> InteractiveObjectActor:
	var object_data = INTERACTIVE_OBJECT_DATA_SCRIPT.new()
	object_data.object_id = StringName("runner_%s" % object_type)
	object_data.display_name = display_name
	object_data.object_type = object_type
	object_data.grid_position = Vector2i.ZERO
	var actor := INTERACTIVE_OBJECT_SCENE.instantiate() as InteractiveObjectActor
	if actor == null:
		return null
	root.add_child(actor)
	actor.setup_from_data(object_data)
	return actor


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
