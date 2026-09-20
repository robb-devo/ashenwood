extends Control
## Commercial title screen — brand-first, warm woodland fantasy.

const UiThemeScript = preload("res://scripts/ui/ui_theme.gd")

var _settings_panel: Control
var _title: Label
var _play: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	_play_intro()


func _build() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("0c110e")
	add_child(bg)

	# Atmospheric bands
	var top_glow := ColorRect.new()
	top_glow.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_glow.offset_bottom = 700
	top_glow.color = Color(0.16, 0.22, 0.17, 0.55)
	add_child(top_glow)

	var mid := ColorRect.new()
	mid.set_anchors_preset(Control.PRESET_CENTER)
	mid.offset_left = -420
	mid.offset_top = -520
	mid.offset_right = 420
	mid.offset_bottom = 80
	mid.color = Color(0.14, 0.2, 0.15, 0.35)
	add_child(mid)

	var mist := ColorRect.new()
	mist.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	mist.offset_top = -520
	mist.color = Color(0.06, 0.08, 0.07, 0.65)
	add_child(mist)

	# Brand mark
	var crest := Panel.new()
	crest.set_anchors_preset(Control.PRESET_CENTER_TOP)
	crest.offset_left = -56
	crest.offset_top = 280
	crest.offset_right = 56
	crest.offset_bottom = 392
	crest.add_theme_stylebox_override("panel", UiThemeScript.circle(UiThemeScript.BRASS, UiThemeScript.BRASS_LIGHT, 60))
	add_child(crest)
	var crest_l := Label.new()
	crest_l.text = "A"
	crest_l.set_anchors_preset(Control.PRESET_FULL_RECT)
	crest_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crest_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(crest_l, 52, UiThemeScript.INK)
	crest.add_child(crest_l)

	_title = Label.new()
	_title.text = "ASHENWOOD"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_title.offset_left = -460
	_title.offset_top = 420
	_title.offset_right = 460
	_title.offset_bottom = 530
	UiThemeScript.style_label(_title, 78, UiThemeScript.BRASS_LIGHT, true)
	add_child(_title)

	var sub := Label.new()
	sub.text = "A dark woodland adventure"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.offset_left = -400
	sub.offset_top = 530
	sub.offset_right = 400
	sub.offset_bottom = 580
	UiThemeScript.style_label(sub, 26, UiThemeScript.MUTED)
	add_child(sub)

	_play = Button.new()
	_play.text = "PLAY"
	_play.set_anchors_preset(Control.PRESET_CENTER)
	_play.offset_left = -200
	_play.offset_top = 40
	_play.offset_right = 200
	_play.offset_bottom = 150
	_play.add_theme_font_size_override("font_size", 42)
	UiThemeScript.style_primary_button(_play)
	_play.pivot_offset = Vector2(200, 55)
	_play.pressed.connect(_on_play)
	add_child(_play)

	var settings := Button.new()
	settings.text = "SETTINGS"
	settings.set_anchors_preset(Control.PRESET_CENTER)
	settings.offset_left = -200
	settings.offset_top = 170
	settings.offset_right = 200
	settings.offset_bottom = 260
	settings.add_theme_font_size_override("font_size", 28)
	UiThemeScript.style_secondary_button(settings)
	settings.pressed.connect(_toggle_settings)
	add_child(settings)

	var ver := Label.new()
	ver.text = "v%s" % ProjectSettings.get_setting("application/config/version", "0.7")
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	ver.offset_left = -120
	ver.offset_top = -90
	ver.offset_right = 120
	ver.offset_bottom = -40
	UiThemeScript.style_label(ver, 18, Color(UiThemeScript.MUTED.r, UiThemeScript.MUTED.g, UiThemeScript.MUTED.b, 0.55))
	add_child(ver)

	_build_settings()


func _play_intro() -> void:
	_title.modulate.a = 0.0
	_play.modulate.a = 0.0
	_play.scale = Vector2(0.9, 0.9)
	var tw := create_tween()
	tw.tween_property(_title, "modulate:a", 1.0, 0.45)
	tw.tween_property(_play, "modulate:a", 1.0, 0.25)
	tw.parallel().tween_property(_play, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		var pulse := create_tween().set_loops()
		pulse.tween_property(_play, "scale", Vector2(1.035, 1.035), 0.95).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(_play, "scale", Vector2.ONE, 0.95).set_trans(Tween.TRANS_SINE)
	)


func _build_settings() -> void:
	_settings_panel = PanelContainer.new()
	_settings_panel.visible = false
	_settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	_settings_panel.offset_left = -280
	_settings_panel.offset_top = -240
	_settings_panel.offset_right = 280
	_settings_panel.offset_bottom = 260
	_settings_panel.add_theme_stylebox_override("panel", UiThemeScript.panel_main(28, 0.98))
	add_child(_settings_panel)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	_settings_panel.add_child(v)

	var h := Label.new()
	h.text = "Settings"
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(h, 34, UiThemeScript.BRASS_LIGHT)
	v.add_child(h)

	_add_slider(v, "Music", AudioService.music_volume, func(val): AudioService.set_music_volume(val))
	_add_slider(v, "SFX", AudioService.sfx_volume, func(val): AudioService.set_sfx_volume(val))

	var vib := CheckButton.new()
	vib.text = "Vibration"
	vib.button_pressed = AudioService.vibration_enabled
	vib.add_theme_font_size_override("font_size", 24)
	vib.add_theme_color_override("font_color", UiThemeScript.CREAM)
	vib.toggled.connect(func(on): AudioService.set_vibration_enabled(on))
	v.add_child(vib)

	var close := Button.new()
	close.text = "CLOSE"
	close.custom_minimum_size = Vector2(0, 72)
	close.add_theme_font_size_override("font_size", 26)
	UiThemeScript.style_primary_button(close)
	close.pressed.connect(func():
		UiThemeScript.animate_close(_settings_panel)
		AudioService.play_ui()
	)
	v.add_child(close)


func _add_slider(parent: Control, label: String, value: float, on_change: Callable) -> void:
	var row := VBoxContainer.new()
	parent.add_child(row)
	var l := Label.new()
	l.text = label
	UiThemeScript.style_label(l, 22, UiThemeScript.MUTED)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(0, 40)
	s.value_changed.connect(on_change)
	row.add_child(s)


func _toggle_settings() -> void:
	AudioService.play_ui(&"ui_click")
	if _settings_panel.visible:
		UiThemeScript.animate_close(_settings_panel)
	else:
		UiThemeScript.animate_open(_settings_panel)


func _on_play() -> void:
	AudioService.play_ui(&"ui_confirm")
	UiThemeScript.pulse_control(_play)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.22)
	tw.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	)
