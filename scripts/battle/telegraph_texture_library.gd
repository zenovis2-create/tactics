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

const STATUS_ICON_SIZE := 18
const STATUS_ICON_BG := Color(0.078, 0.094, 0.125, 0.92)
const STATUS_ICON_OUTLINE := Color(0.968, 0.972, 0.992, 0.18)
const STATUS_ICON_COLORS := {
	"status_boss_mark": Color(1.0, 0.76, 0.9, 0.98),
	"status_mark": Color(1.0, 0.86, 0.6, 0.98),
	"status_fear": Color(1.0, 0.78, 0.59, 0.98),
	"status_charm": Color(1.0, 0.71, 0.79, 0.98),
	"status_dot": Color(1.0, 0.88, 0.53, 0.98),
	"status_oblivion": Color(0.85, 0.76, 1.0, 0.98)
}

static var _cache: Dictionary = {}

static func get_texture(kind: String) -> Texture2D:
	if _cache.has(kind):
		return _cache[kind]

	if kind.begins_with("status_"):
		var status_texture := _build_status_icon_texture(kind)
		if status_texture != null:
			_cache[kind] = status_texture
		return status_texture

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

static func _build_status_icon_texture(kind: String) -> Texture2D:
	var color: Color = STATUS_ICON_COLORS.get(kind, Color(1, 1, 1, 1))
	var image := Image.create(STATUS_ICON_SIZE, STATUS_ICON_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_backplate(image)

	match kind:
		"status_boss_mark":
			_draw_diamond(image, color.darkened(0.35), 2)
			_draw_cross(image, color, 2)
		"status_mark":
			_draw_cross(image, color, 1)
		"status_fear":
			_draw_triangle(image, color)
		"status_charm":
			_draw_heart(image, color)
		"status_dot":
			_draw_drop(image, color)
		"status_oblivion":
			_draw_ring(image, color)
		_:
			return null

	return ImageTexture.create_from_image(image)

static func _draw_backplate(image: Image) -> void:
	var center := STATUS_ICON_SIZE / 2
	for y in range(STATUS_ICON_SIZE):
		for x in range(STATUS_ICON_SIZE):
			var dx := x - center
			var dy := y - center
			var dist_sq := dx * dx + dy * dy
			if dist_sq <= 52:
				image.set_pixel(x, y, STATUS_ICON_BG)
			if dist_sq <= 60 and dist_sq >= 44:
				image.set_pixel(x, y, STATUS_ICON_OUTLINE)

static func _draw_cross(image: Image, color: Color, thickness: int) -> void:
	var center := STATUS_ICON_SIZE / 2
	for x in range(STATUS_ICON_SIZE):
		for offset in range(-thickness, thickness + 1):
			var y1 := center + offset
			if y1 >= 0 and y1 < STATUS_ICON_SIZE:
				image.set_pixel(x, y1, color)
			var diag_a := x + offset
			if diag_a >= 0 and diag_a < STATUS_ICON_SIZE:
				image.set_pixel(x, diag_a, color)
			var diag_b := (STATUS_ICON_SIZE - 1 - x) + offset
			if diag_b >= 0 and diag_b < STATUS_ICON_SIZE:
				image.set_pixel(x, diag_b, color)

static func _draw_diamond(image: Image, color: Color, inset: int) -> void:
	var center := STATUS_ICON_SIZE / 2
	for y in range(STATUS_ICON_SIZE):
		for x in range(STATUS_ICON_SIZE):
			if abs(x - center) + abs(y - center) <= center - inset:
				image.set_pixel(x, y, color)

static func _draw_triangle(image: Image, color: Color) -> void:
	for y in range(2, STATUS_ICON_SIZE - 2):
		var rise := y - 2
		var half_width := int(floor(float(rise) * 0.45))
		var start_x := maxi(0, (STATUS_ICON_SIZE / 2) - half_width)
		var end_x := mini(STATUS_ICON_SIZE - 1, (STATUS_ICON_SIZE / 2) + half_width)
		for x in range(start_x, end_x + 1):
			image.set_pixel(x, y, color)
	for x in range(5, STATUS_ICON_SIZE - 5):
		image.set_pixel(x, STATUS_ICON_SIZE - 4, color.darkened(0.18))

static func _draw_heart(image: Image, color: Color) -> void:
	for y in range(STATUS_ICON_SIZE):
		for x in range(STATUS_ICON_SIZE):
			var nx := (float(x) / 8.5) - 1.0
			var ny := (float(y) / 8.5) - 1.05
			var equation := pow(nx * nx + ny * ny - 1.0, 3.0) - nx * nx * pow(ny, 3.0)
			if equation <= 0.0:
				image.set_pixel(x, y, color)

static func _draw_drop(image: Image, color: Color) -> void:
	var center := STATUS_ICON_SIZE / 2
	for y in range(STATUS_ICON_SIZE):
		for x in range(STATUS_ICON_SIZE):
			var dx := x - center
			var dy := y - (center + 2)
			if dx * dx + dy * dy <= 18:
				image.set_pixel(x, y, color)
			elif y < center and abs(dx) <= maxi(0, (center - y) / 2):
				image.set_pixel(x, y, color)

static func _draw_ring(image: Image, color: Color) -> void:
	var center := STATUS_ICON_SIZE / 2
	for y in range(STATUS_ICON_SIZE):
		for x in range(STATUS_ICON_SIZE):
			var dx := x - center
			var dy := y - center
			var dist_sq := dx * dx + dy * dy
			if dist_sq <= 42 and dist_sq >= 18:
				image.set_pixel(x, y, color)
	for x in range(center - 1, center + 2):
		image.set_pixel(x, center, STATUS_ICON_BG)
