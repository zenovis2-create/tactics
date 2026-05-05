extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const RIAN_DATA = preload("res://data/units/ally_rian.tres")
const SWORD = preload("res://data/weapons/wp_standard_breaker_blade.tres")
const HEAVY_ARMOR = preload("res://data/armors/ar_bellward_plate.tres")
const RELIC = preload("res://data/accessories/acc_bell_oath_relic.tres")

const OVERLAY_IDS := [
	"weapon_sword",
	"weapon_lance",
	"weapon_bow",
	"weapon_staff",
	"armor_heavy",
	"armor_light_cloak",
	"accessory_relic",
	"accessory_shield",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for overlay_id in OVERLAY_IDS:
		var frames := BattleArtCatalog.load_equipment_overlay_frames(overlay_id)
		if frames.size() != 16:
			return _fail("%s should expose 16 equipment overlay frames, found %d." % [overlay_id, frames.size()])
		for frame in frames:
			if frame == null or frame.get_width() != 128 or frame.get_height() != 128:
				return _fail("%s equipment overlay frames should be 128x128 textures." % overlay_id)

	var actor := UNIT_SCENE.instantiate() as UnitActor
	if actor == null:
		return _fail("Equipment overlay runner could not instantiate UnitActor.")
	root.add_child(actor)
	actor.setup_from_data(RIAN_DATA)
	actor.set_equipped_weapon(SWORD)
	actor.set_equipped_armor(HEAVY_ARMOR)
	actor.set_equipped_accessory(RELIC)
	await process_frame

	if not _assert_overlay(actor, "EquipmentWeaponOverlay"):
		return
	if not _assert_overlay(actor, "EquipmentArmorOverlay"):
		return
	if not _assert_overlay(actor, "EquipmentAccessoryOverlay"):
		return

	print("[PASS] equipment_overlay_runtime_runner validated imagegen equipment overlays and UnitActor layering.")
	quit(0)


func _assert_overlay(actor: UnitActor, node_name: String) -> bool:
	var sprite := actor.get_node_or_null("CharacterVisualRoot/%s" % node_name) as Sprite2D
	if sprite == null:
		return _fail("%s should be created under CharacterVisualRoot." % node_name)
	if not sprite.visible or sprite.texture == null:
		return _fail("%s should be visible with an overlay texture after equipment is set." % node_name)
	if sprite.texture.get_width() != 128 or sprite.texture.get_height() != 128:
		return _fail("%s should use a 128x128 runtime overlay texture." % node_name)
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
