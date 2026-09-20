class_name UiTheme
extends RefCounted
## Ashenwood commercial mobile UI kit.
## Warm brass on deep woodland charcoal — thick, readable, premium.

# --- Palette ---
const INK := Color("101612")
const PANEL := Color("1a221c")
const PANEL_RAISED := Color("243028")
const PANEL_SOFT := Color(0.12, 0.16, 0.13, 0.92)
const BRASS := Color("d4a84b")
const BRASS_LIGHT := Color("f0d78a")
const BRASS_DEEP := Color("9a7030")
const CREAM := Color("f3ebe0")
const MUTED := Color(0.78, 0.74, 0.66, 0.78)
const MOSS := Color("5f8a62")
const HP := Color("c4454a")
const HP_DEEP := Color("7a2428")
const XP := Color("c9a045")
const DANGER := Color("e05545")
const SUCCESS := Color("6db87a")


static func color_ink() -> Color:
	return INK


static func color_cream() -> Color:
	return CREAM


static func color_brass() -> Color:
	return BRASS


static func color_muted() -> Color:
	return MUTED


static func panel_main(radius: float = 28.0, alpha: float = 0.94) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(PANEL.r, PANEL.g, PANEL.b, alpha)
	s.border_color = Color(BRASS.r, BRASS.g, BRASS.b, 0.55)
	s.set_border_width_all(3)
	s.set_corner_radius_all(int(radius))
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 18
	s.content_margin_bottom = 18
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = 16
	s.shadow_offset = Vector2(0, 6)
	return s


static func panel_card(radius: float = 22.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL_RAISED
	s.border_color = Color(1, 1, 1, 0.06)
	s.set_border_width_all(2)
	s.set_corner_radius_all(int(radius))
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	s.shadow_color = Color(0, 0, 0, 0.28)
	s.shadow_size = 8
	return s


static func panel_glass(radius: float = 20.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.08, 0.11, 0.09, 0.72)
	s.border_color = Color(BRASS.r, BRASS.g, BRASS.b, 0.28)
	s.set_border_width_all(2)
	s.set_corner_radius_all(int(radius))
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


static func panel_pill(fill: Color = PANEL_RAISED, border: Color = BRASS) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = Color(border.r, border.g, border.b, 0.65)
	s.set_border_width_all(2)
	s.set_corner_radius_all(40)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	s.shadow_color = Color(0, 0, 0, 0.3)
	s.shadow_size = 8
	return s


static func circle(fill: Color, border: Color, radius: float = 80.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(4)
	s.set_corner_radius_all(int(radius))
	s.shadow_color = Color(0, 0, 0, 0.4)
	s.shadow_size = 12
	s.shadow_offset = Vector2(0, 4)
	return s


static func bar_hp() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = HP
	s.set_corner_radius_all(10)
	return s


static func bar_xp() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = XP
	s.set_corner_radius_all(8)
	return s


static func bar_boss() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = DANGER
	s.set_corner_radius_all(10)
	return s


static func bar_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.05, 0.07, 0.06, 0.9)
	s.set_corner_radius_all(10)
	s.set_border_width_all(1)
	s.border_color = Color(1, 1, 1, 0.08)
	return s


static func button_primary() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BRASS
	s.border_color = BRASS_LIGHT
	s.set_border_width_all(3)
	s.set_corner_radius_all(22)
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 16
	s.content_margin_bottom = 16
	s.shadow_color = Color(0.6, 0.4, 0.1, 0.35)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 4)
	return s


static func button_primary_pressed() -> StyleBoxFlat:
	var s := button_primary()
	s.bg_color = BRASS_DEEP
	s.shadow_size = 4
	return s


static func button_secondary() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL_RAISED
	s.border_color = Color(BRASS.r, BRASS.g, BRASS.b, 0.45)
	s.set_border_width_all(2)
	s.set_corner_radius_all(18)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s


static func button_quiet() -> StyleBoxFlat:
	return button_secondary()


static func button_tab(active: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if active:
		s.bg_color = Color(BRASS.r, BRASS.g, BRASS.b, 0.22)
		s.border_color = BRASS
		s.set_border_width_all(2)
	else:
		s.bg_color = Color(0, 0, 0, 0)
		s.border_color = Color(0, 0, 0, 0)
		s.set_border_width_all(0)
	s.set_corner_radius_all(16)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


static func rarity_frame(rarity: int) -> StyleBoxFlat:
	var ItemDefScript = preload("res://scripts/data/item_def.gd")
	var c: Color = ItemDefScript.rarity_color(rarity)
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.14, 0.17, 0.15, 0.95)
	s.border_color = c
	s.set_border_width_all(3)
	s.set_corner_radius_all(18)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	s.shadow_color = Color(c.r, c.g, c.b, 0.25)
	s.shadow_size = 8
	return s


static func style_label(label: Label, size: int, color: Color = CREAM, outline: bool = false) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if outline:
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		label.add_theme_constant_override("outline_size", 6)


static func style_primary_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", button_primary())
	btn.add_theme_stylebox_override("pressed", button_primary_pressed())
	btn.add_theme_stylebox_override("hover", button_primary())
	btn.add_theme_stylebox_override("disabled", button_secondary())
	btn.add_theme_color_override("font_color", INK)
	btn.add_theme_color_override("font_pressed_color", INK)
	btn.add_theme_color_override("font_hover_color", INK)
	btn.focus_mode = Control.FOCUS_NONE


static func style_secondary_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", button_secondary())
	btn.add_theme_stylebox_override("pressed", button_secondary())
	btn.add_theme_stylebox_override("hover", button_secondary())
	btn.add_theme_color_override("font_color", CREAM)
	btn.focus_mode = Control.FOCUS_NONE


static func pulse_control(node: Control, scale_to: float = 0.94) -> void:
	if node == null:
		return
	node.pivot_offset = node.size * 0.5
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector2(scale_to, scale_to), 0.06)
	tw.tween_property(node, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func animate_open(panel: Control) -> void:
	if panel == null:
		return
	panel.visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	panel.pivot_offset = panel.size * 0.5
	var tw := panel.create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.16)
	tw.parallel().tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func animate_close(panel: Control, done: Callable = Callable()) -> void:
	if panel == null:
		return
	var tw := panel.create_tween()
	tw.tween_property(panel, "modulate:a", 0.0, 0.12)
	tw.parallel().tween_property(panel, "scale", Vector2(0.94, 0.94), 0.12)
	tw.tween_callback(func():
		panel.visible = false
		panel.modulate.a = 1.0
		panel.scale = Vector2.ONE
		if done.is_valid():
			done.call()
	)
