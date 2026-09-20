class_name UiTheme
extends RefCounted
## Shared Ashenwood premium mobile UI styles.


static func panel_dark(radius: float = 22.0, alpha: float = 0.78) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.07, 0.09, 0.11, alpha)
	s.border_color = Color(0.78, 0.66, 0.42, 0.55)
	s.set_border_width_all(2)
	s.set_corner_radius_all(int(radius))
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 8
	return s


static func panel_glass(radius: float = 18.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.1, 0.12, 0.14, 0.55)
	s.border_color = Color(0.9, 0.84, 0.68, 0.28)
	s.set_border_width_all(1)
	s.set_corner_radius_all(int(radius))
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


static func circle(fill: Color, border: Color, radius: float = 80.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(3)
	s.set_corner_radius_all(int(radius))
	s.shadow_color = Color(0, 0, 0, 0.4)
	s.shadow_size = 10
	return s


static func bar_hp() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.72, 0.22, 0.24, 0.95)
	s.set_corner_radius_all(8)
	return s


static func bar_xp() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.78, 0.62, 0.28, 0.95)
	s.set_corner_radius_all(8)
	return s


static func bar_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.05, 0.06, 0.07, 0.85)
	s.set_corner_radius_all(8)
	s.set_border_width_all(1)
	s.border_color = Color(1, 1, 1, 0.08)
	return s


static func button_quiet() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.12, 0.14, 0.16, 0.85)
	s.border_color = Color(0.78, 0.66, 0.42, 0.45)
	s.set_border_width_all(2)
	s.set_corner_radius_all(16)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s
