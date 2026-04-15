class_name TelegraphTextureLibrary
extends RefCounted

const HOSTILE_SHEET := "res://artifacts/ash29/ash29_hostile_telegraph_concept_sheet_v1.png"
const SUPPORT_SHEET := "res://artifacts/ash30/ash30_support_danger_overlay_concept_sheet_v1.png"

const HOSTILE_RECTS := {
	"mark": Rect2i(90, 150, 240, 240),
	"charge": Rect2i(560, 150, 320, 220),
	"command": Rect2i(80, 500, 320, 220),
	"danger": Rect2i(600, 470, 280, 280)
}

const SUPPORT_RECTS := {
	"heal": Rect2i(360, 40, 300, 220),
	"protect": Rect2i(300, 360, 420, 180),
	"danger_overlay": Rect2i(250, 650, 500, 190)
}

static var _cache: Dictionary = {}

static func get_texture(kind: String) -> Texture2D:
	if _cache.has(kind):
		return _cache[kind]

	var rect: Rect2i
	var source_path: String = ""
	if HOSTILE_RECTS.has(kind):
		rect = HOSTILE_RECTS[kind]
		source_path = HOSTILE_SHEET
	elif SUPPORT_RECTS.has(kind):
		rect = SUPPORT_RECTS[kind]
		source_path = SUPPORT_SHEET
	else:
		return null

	var absolute_path: String = ProjectSettings.globalize_path(source_path)
	if not FileAccess.file_exists(absolute_path):
		return null

	var image := Image.new()
	if image.load(absolute_path) != OK:
		return null

	var cropped: Image = image.get_region(rect)
	var texture: Texture2D = ImageTexture.create_from_image(cropped)
	_cache[kind] = texture
	return texture
