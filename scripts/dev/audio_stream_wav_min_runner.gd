extends SceneTree

const BGM_PATH := "res://audio/bgm/bgm_title.wav"

var _player: AudioStreamPlayer = null


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = &"Master"
	root.add_child(_player)
	await process_frame

	var absolute_path := ProjectSettings.globalize_path(BGM_PATH)
	var stream := AudioStreamWAV.load_from_file(absolute_path)
	if stream == null:
		push_error("Failed to load WAV stream from %s." % absolute_path)
		quit(1)
		return
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_player.stream = stream
	_player.play()
	await process_frame
	await process_frame

	_player.stop()
	_player.stream = null
	stream = null
	await process_frame

	_player.queue_free()
	_player = null
	await process_frame
	await process_frame

	print("[PASS] audio_stream_wav_min_runner completed.")
	quit(0)
