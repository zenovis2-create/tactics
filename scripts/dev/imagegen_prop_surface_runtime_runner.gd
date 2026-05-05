extends SceneTree

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

const RUNTIME_TEXTURES := {
	"altar integration": "res://assets/props/altar_01/runtime/altar_01_integration_v01.png",
	"altar runtime icon": "res://assets/props/altar_01/runtime/altar_01_object_icon_v01.png",
	"paladin shield integration": "res://assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png",
	"paladin shield equipment": "res://assets/props/paladin_shield/runtime/paladin_shield_equipment_v01.png",
	"paladin shield runtime icon": "res://assets/props/paladin_shield/runtime/paladin_shield_icon_v01.png",
}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert_texture_size("altar production object icon", BattleArtCatalog.load_object_icon("altar.png"), Vector2i(256, 256))
	_assert_texture_size("paladin shield production object icon", BattleArtCatalog.load_object_icon("paladin_shield.png"), Vector2i(256, 256))

	for label in RUNTIME_TEXTURES.keys():
		var path := String(RUNTIME_TEXTURES[label])
		var texture := load(path) as Texture2D
		if texture == null:
			return _fail("%s should load from %s." % [label, path])
		if label.ends_with("icon"):
			_assert_texture_size(label, texture, Vector2i(256, 256))
		elif texture.get_width() != 1536 or texture.get_height() != 1024:
			return _fail("%s should preserve 1536x1024 runtime canvas, got %dx%d." % [label, texture.get_width(), texture.get_height()])

	print("[PASS] imagegen_prop_surface_runtime_runner validated prop surfaces and production object icons.")
	quit(0)

func _assert_texture_size(label: String, texture: Texture2D, expected: Vector2i) -> void:
	if texture == null:
		return _fail("%s is missing." % label)

	var actual := Vector2i(texture.get_width(), texture.get_height())
	if actual != expected:
		return _fail("%s expected %s, got %s." % [label, expected, actual])

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
