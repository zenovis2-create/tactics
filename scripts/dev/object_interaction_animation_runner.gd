extends SceneTree

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const INTERACTIVE_OBJECT_SCENE: PackedScene = preload("res://scenes/battle/InteractiveObject.tscn")
const INTERACTIVE_OBJECT_DATA_SCRIPT = preload("res://scripts/data/interactive_object_data.gd")

const OBJECT_TYPES := [
	"chest",
	"lever",
	"door",
	"gate",
	"altar",
	"gate_control",
	"well",
	"battery",
	"shrine",
	"floodgate",
	"evidence",
	"bell",
	"chain_control",
	"keeper_lectern",
	"route_marker",
	"latch",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for object_type in OBJECT_TYPES:
		var frames := BattleArtCatalog.load_object_interaction_animation(object_type)
		if frames.size() != 16:
			return _fail("%s should expose 16 object interaction frames, found %d." % [object_type, frames.size()])
		for frame in frames:
			if frame == null or frame.get_width() != 128 or frame.get_height() != 128:
				return _fail("%s interaction frames should be 128x128 textures." % object_type)

	var actor := _spawn_object("chest", "Runner Chest")
	if actor == null:
		return _fail("Object interaction animation runner could not instantiate a chest object.")

	var result: Dictionary = actor.resolve_interaction(null)
	if result.get("resolved", false) != true:
		return _fail("Resolving an object should start from a successful interaction result.")

	await process_frame
	var animation := actor.get_node_or_null("InteractionAnimation") as AnimatedSprite2D
	if animation == null:
		return _fail("InteractiveObjectActor should create an InteractionAnimation AnimatedSprite2D.")
	if not animation.visible:
		return _fail("InteractionAnimation should become visible after resolve_interaction.")
	if animation.sprite_frames == null or animation.sprite_frames.get_frame_count("interact") != 16:
		return _fail("InteractionAnimation should contain 16 interact frames.")
	if not animation.is_playing():
		return _fail("InteractionAnimation should play immediately after resolve_interaction.")

	print("[PASS] object_interaction_animation_runner validated imagegen object frames and actor playback.")
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


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
