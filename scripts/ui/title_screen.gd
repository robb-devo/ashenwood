extends Control
## Polished title screen → loads main game.

const UiThemeScript = preload("res://scripts/ui/ui_theme.gd")

var _settings_panel: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("0d1210")
	add_child(bg)

	# Soft atmospheric gradient blocks
	var glow := ColorRect.new()
	glow.set_anchors_preset(Control.PRESET_CENTER)
	glow.offset_left = -320
	glow.offset_top = -480
	glow.offset_right = 320
	glow.offset_bottom = 40
	glow.color = Color(0.18, 0.26, 0.2, 0.4)
	add_child(glow)

	var mist := ColorRect.new()
	mist.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	mist.offset_top = -420
	mist.color = Color(0.08, 0.1, 0.09, 0.55)
	add_child(mist)

	var title := Label.new()
	title.text = "ASHENWOOD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -400
	title.offset_top = 380
	title.offset_right = 400
	title.offset_bottom = 480
	title.add_theme_font_size_override("font_size", 76)
	title.add_theme_color_override("font_color", Color("e8d7a8"))
	add_child(title)

	var sub := Label.new()
	sub.text = "A dark woodland adventure"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.offset_left = -400
	sub.offset_top = 490
	sub.offset_right = 400
	sub.offset_bottom = 540
	sub.add_theme_font_size_override("font_size", 26)
	sub.add_theme_color_override("font_color", Color(0.75, 0.8, 0.72, 0.8))
	add_child(sub)

	var play := Button.new()
	play.text = "PLAY"
	play.set_anchors_preset(Control.PRESET_CENTER)
	play.offset_left = -180
	play.offset_top = 20
	play.offset_right = 180
	play.offset_bottom = 120
	play.add_theme_font_size_override("font_size", 40)
	_style_cta(play, Color("c9a45c"), Color("f2e3b0"))
	play.pressed.connect(_on_play)
	add_child(play)

	var settings := Button.new()
	settings.text = "SETTINGS"
	settings.set_anchors_preset(Control.PRESET_CENTER)
	settings.offset_left = -180
	settings.offset_top = 140
	settings.offset_right = 180
	settings.offset_bottom = 220
	settings.add_theme_font_size_override("font_size", 28)
	_style_cta(settings, Color("3a453c"), Color("8a9a80"))
	settings.add_theme_color_override("font_color", Color("efe6d4"))
	settings.pressed.connect(_toggle_settings)
	add_child(settings)

	var ver := Label.new()
	ver.text = "v%s" % ProjectSettings.get_setting("application/config/version", "0.6")
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	ver.offset_left = -100
	ver.offset_top = -80
	ver.offset_right = 100
	ver.offset_bottom = -40
	ver.add_theme_font_size_override("font_size", 18)
	ver.add_theme_color_override("font_color", Color(0.7, 0.72, 0.65, 0.5))
	add_child(ver)

	var tw := create_tween().set_loops()
	tw.tween_property(play, "scale", Vector2(1.03, 1.03), 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(play, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)

	_build_settings()


func _build_settings() -> void:
	_settings_panel = PanelContainer.new()
	_settings_panel.visible = false
	_settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	_settings_panel.offset_left = -260
	_settings_panel.offset_top = -200
	_settings_panel.offset_right = 260
	_settings_panel.offset_bottom = 220
	_settings_panel.add_theme_stylebox_override("panel", UiThemeScript.panel_dark(24, 0.95))
	add_child(_settings_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	_settings_panel.add_child(v)
	var h := Label.new()
	h.text = "Settings"
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_font_size_override("font_size", 32)
	h.add_theme_color_override("font_color", Color("ffe6a8"))
	v.add_child(h)
	_add_slider(v, "Music", AudioService.music_volume, func(val): AudioService.set_music_volume(val))
	_add_slider(v, "SFX", AudioService.sfx_volume, func(val): AudioService.set_sfx_volume(val))
	var vib := CheckButton.new()
	vib.text = "Vibration"
	vib.button_pressed = AudioService.vibration_enabled
	vib.add_theme_font_size_override("font_size", 24)
	vib.toggled.connect(func(on): AudioService.set_vibration_enabled(on))
	v.add_child(vib)
	var close := Button.new()
	close.text = "Close"
	close.custom_minimum_size = Vector2(0, 64)
	close.add_theme_font_size_override("font_size", 26)
	_style_cta(close, Color("4a5548"), Color("aab89a"))
	close.add_theme_color_override("font_color", Color("efe6d4"))
	close.pressed.connect(func(): _settings_panel.visible = false)
	v.add_child(close)


func _add_slider(parent: Control, label: String, value: float, on_change: Callable) -> void:
	var row := VBoxContainer.new()
	parent.add_child(row)
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color("efe6d4"))
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(0, 36)
	s.value_changed.connect(on_change)
	row.add_child(s)


func _toggle_settings() -> void:
	AudioService.play_ui(&"ui_click")
	_settings_panel.visible = not _settings_panel.visible


func _style_cta(btn: Button, fill: Color, border: Color) -> void:
	var n := StyleBoxFlat.new()
	n.bg_color = fill
	n.border_color = border
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
