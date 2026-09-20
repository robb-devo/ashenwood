extends Node3D
## Main entry for Ashenwood vertical slice.


func _ready() -> void:
	DisplayServer.window_set_title("%s" % GameConfig.APP_DISPLAY_NAME)
	AudioService.play_music(&"village_ambient")
	if OS.is_debug_build() and "--qa-capture" in OS.get_cmdline_user_args():
		call_deferred("_qa_capture")


func _qa_capture() -> void:
	await get_tree().create_timer(1.0).timeout
	var player := get_tree().get_first_node_in_group("player") as Node3D
	_shot("village")
	if player:
		player.global_position = Vector3(0, 0, -40)
		await get_tree().create_timer(0.7).timeout
		_shot("forest")
		player.global_position = Vector3(44, 0, -6)
		await get_tree().create_timer(0.7).timeout
		_shot("cemetery")
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("_open_menu_to"):
		hud._open_menu_to(&"bag")
		await get_tree().create_timer(0.5).timeout
		_shot("inventory")
	get_tree().quit()


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if img == null:
		return
	var path := ProjectSettings.globalize_path("res://dist/qa_%s.png" % name)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://dist"))
	img.save_png(path)
	print("CAPTURED ", path)
