extends Control
## Polished title screen → loads main game.


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("0d1210")
	add_child(bg)

	var glow := ColorRect.new()
	glow.set_anchors_preset(Control.PRESET_CENTER)
	glow.offset_left = -280
	glow.offset_top = -420
	glow.offset_right = 280
	glow.offset_bottom = 80
	glow.color = Color(0.2, 0.28, 0.22, 0.35)
	add_child(glow)

	var title := Label.new()
	title.text = "ASHENWOOD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -400
	title.offset_top = 420
	title.offset_right = 400
	title.offset_bottom = 520
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color("e8d7a8"))
	add_child(title)

	var sub := Label.new()
	sub.text = "A dark woodland adventure"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.offset_left = -400
	sub.offset_top = 520
	sub.offset_right = 400
	sub.offset_bottom = 570
	sub.add_theme_font_size_override("font_size", 26)
	sub.add_theme_color_override("font_color", Color(0.75, 0.8, 0.72, 0.8))
	add_child(sub)

	var play := Button.new()
	play.text = "PLAY"
	play.set_anchors_preset(Control.PRESET_CENTER)
	play.offset_left = -180
	play.offset_top = 40
	play.offset_right = 180
	play.offset_bottom = 140
	play.add_theme_font_size_override("font_size", 40)
	_style_cta(play)
	play.pressed.connect(_on_play)
	add_child(play)

	var tw := create_tween().set_loops()
	tw.tween_property(play, "scale", Vector2(1.03, 1.03), 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(play, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)


func _style_cta(btn: Button) -> void:
	var n := StyleBoxFlat.new()
	n.bg_color = Color("c9a45c")
	n.border_color = Color("f2e3b0")
	n.set_border_width_all(3)
	n.set_corner_radius_all(28)
	n.shadow_color = Color(0, 0, 0, 0.4)
	n.shadow_size = 12
	btn.add_theme_stylebox_override("normal", n)
	btn.add_theme_stylebox_override("pressed", n)
	btn.add_theme_stylebox_override("hover", n)
	btn.add_theme_color_override("font_color", Color("1a1410"))
	btn.pivot_offset = Vector2(180, 50)


func _on_play() -> void:
	AudioService.play_ui(&"ui_confirm")
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
