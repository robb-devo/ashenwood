extends Node
## Headless/visual capture helper: boots main scene, waits, dumps PNGs, quits.


func _ready() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	await get_tree().process_frame
	await get_tree().create_timer(1.2).timeout
	_capture("hud_village")
	# Walk camera toward forest by moving player if present
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player:
		player.global_position = Vector3(0, 0, -36)
		await get_tree().create_timer(0.6).timeout
		_capture("forest")
		player.global_position = Vector3(44, 0, -6)
		await get_tree().create_timer(0.6).timeout
		_capture("cemetery")
	get_tree().quit()


func _capture(name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	if img == null:
		push_error("No viewport image")
		return
	var path := "user://qa_%s.png" % name
	img.save_png(path)
	# Also copy to project dist for easy reading
	var abs_user := ProjectSettings.globalize_path(path)
	var dest := "res://dist/qa_%s.png" % name
	var abs_dest := ProjectSettings.globalize_path(dest)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://dist"))
	DirAccess.copy_absolute(abs_user, abs_dest)
	print("CAPTURED ", abs_dest)
