extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var sword_ids: Array[StringName] = [
		&"wp_archive_ashblade",
		&"wp_standard_breaker_blade",
		&"wp_eclipse_resonance_blade",
	]
	for weapon_id in sword_ids:
		var preview_path := CampaignCatalog.get_weapon_preview_path(weapon_id)
		if preview_path.find("field_sword_01_equipment_v01.png") == -1:
			push_error("field_sword preview routing should resolve %s to the field_sword_01 equipment surface." % String(weapon_id))
			quit(1)
			return
		var absolute_path := ProjectSettings.globalize_path(preview_path)
		if not FileAccess.file_exists(absolute_path):
			push_error("field_sword preview routing resolved %s, but the file does not exist." % preview_path)
			quit(1)
			return

	print("[PASS] field_sword_preview_runner validated sword-class weapon preview routing.")
	quit(0)
