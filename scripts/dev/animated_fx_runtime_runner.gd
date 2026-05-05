extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

const FX_FILES := [
	"hit_spark.png",
	"objective_burst.png",
	"mark_ring.png",
	"trap_burst.png",
	"finale_burst.png",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for file_name in FX_FILES:
		var frames := BattleArtCatalog.load_fx_animation(file_name)
		if frames.size() != 16:
			return _fail("%s should expose 16 animated FX frames, found %d." % [file_name, frames.size()])

	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var before_count: int = battle.effects_root.get_child_count()
	battle._play_world_fx("hit_spark.png", Vector2i(1, 1), Color.WHITE, 0.24, 0.96)
	await process_frame
	if battle.effects_root.get_child_count() <= before_count:
		return _fail("Animated hit_spark should spawn a world FX node.")

	var latest: Node = battle.effects_root.get_child(battle.effects_root.get_child_count() - 1)
	if not latest is AnimatedSprite2D:
		return _fail("Animated hit_spark should use AnimatedSprite2D.")
	var sprite := latest as AnimatedSprite2D
	if sprite.sprite_frames == null or sprite.sprite_frames.get_frame_count("default") != 16:
		return _fail("Animated hit_spark SpriteFrames should contain 16 default frames.")

	print("[PASS] animated_fx_runtime_runner validated imagegen FX frames and battle world FX playback.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
