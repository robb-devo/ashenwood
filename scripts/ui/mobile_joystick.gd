class_name MobileJoystick
extends Control
## Archero-style stick: idle at bottom-center, activates anywhere in a large touch zone.
## Touch relocates the stick under your finger; drag from that origin to move.

signal joystick_updated(direction: Vector2)
signal joystick_released

@export var max_radius: float = 120.0
@export var deadzone: float = 0.1
@export var edge_margin: float = 130.0

var _visual: Control
var _base: Panel
var _ring: Panel
var _knob: Panel
var _active_touch_index: int = -1
var _output: Vector2 = Vector2.ZERO
var _origin: Vector2 = Vector2.ZERO
var _idle_modulate := Color(1, 1, 1, 0.34)
var _active_modulate := Color(1, 1, 1, 0.96)


func _ready() -> void:
	max_radius = GameConfig.JOYSTICK_MAX_RADIUS
	deadzone = GameConfig.JOYSTICK_DEADZONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_visuals()
	call_deferred("_reset_to_idle")


func _build_visuals() -> void:
	_visual = Control.new()
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual.custom_minimum_size = Vector2(300, 300)
	_visual.size = Vector2(300, 300)
	add_child(_visual)

	_ring = Panel.new()
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.set_anchors_preset(Control.PRESET_CENTER)
	_ring.offset_left = -148
	_ring.offset_top = -148
	_ring.offset_right = 148
	_ring.offset_bottom = 148
	var ring_style := StyleBoxFlat.new()
	ring_style.bg_color = Color(0.08, 0.11, 0.09, 0.18)
	ring_style.border_color = Color(0.83, 0.68, 0.35, 0.18)
	ring_style.set_border_width_all(2)
	ring_style.set_corner_radius_all(160)
	_ring.add_theme_stylebox_override("panel", ring_style)
	_visual.add_child(_ring)

	_base = Panel.new()
	_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base.set_anchors_preset(Control.PRESET_CENTER)
	_base.offset_left = -112
	_base.offset_top = -112
	_base.offset_right = 112
	_base.offset_bottom = 112
	var base_style := StyleBoxFlat.new()
	base_style.bg_color = Color(0.08, 0.11, 0.09, 0.52)
	base_style.border_color = Color(0.83, 0.68, 0.35, 0.55)
	base_style.set_border_width_all(4)
	base_style.set_corner_radius_all(130)
	base_style.shadow_color = Color(0, 0, 0, 0.35)
	base_style.shadow_size = 14
	_base.add_theme_stylebox_override("panel", base_style)
	_visual.add_child(_base)

	var inner := Panel.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.set_anchors_preset(Control.PRESET_CENTER)
	inner.offset_left = -70
	inner.offset_top = -70
	inner.offset_right = 70
	inner.offset_bottom = 70
	var inner_style := StyleBoxFlat.new()
	inner_style.bg_color = Color(0.14, 0.18, 0.15, 0.32)
	inner_style.set_corner_radius_all(80)
	inner.add_theme_stylebox_override("panel", inner_style)
	_base.add_child(inner)

	_knob = Panel.new()
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_knob.custom_minimum_size = Vector2(88, 88)
	_knob.size = Vector2(88, 88)
	var knob_style := StyleBoxFlat.new()
	knob_style.bg_color = Color(0.83, 0.68, 0.35, 0.92)
	knob_style.border_color = Color(0.96, 0.88, 0.62, 0.95)
	knob_style.set_border_width_all(4)
	knob_style.set_corner_radius_all(50)
	knob_style.shadow_color = Color(0.7, 0.5, 0.15, 0.35)
	knob_style.shadow_size = 12
	_knob.add_theme_stylebox_override("panel", knob_style)
	_visual.add_child(_knob)

	modulate = _idle_modulate


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _active_touch_index == -1:
			_begin(touch.index, touch.position)
			accept_event()
		elif not touch.pressed and touch.index == _active_touch_index:
			_release()
			accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _active_touch_index:
			_update_from_local_pos(drag.position)
			accept_event()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed and _active_touch_index == -1:
			_begin(0, mouse.position)
			accept_event()
		elif not mouse.pressed and _active_touch_index == 0:
			_release()
			accept_event()
	elif event is InputEventMouseMotion and _active_touch_index == 0:
		_update_from_local_pos((event as InputEventMouseMotion).position)
		accept_event()


func _begin(touch_index: int, local_pos: Vector2) -> void:
	_active_touch_index = touch_index
	_origin = _clamp_origin(local_pos)
	_place_visual_at(_origin)
	_center_knob()
	modulate = _active_modulate
	_update_from_local_pos(local_pos)


func _clamp_origin(pos: Vector2) -> Vector2:
	var m := edge_margin
	return Vector2(
		clampf(pos.x, m, maxf(m, size.x - m)),
		clampf(pos.y, m, maxf(m, size.y - m))
	)


func _place_visual_at(center: Vector2) -> void:
	if _visual == null:
		return
	_visual.position = center - _visual.size * 0.5


func _idle_center() -> Vector2:
	# Bottom-center resting spot inside the large pad.
	return Vector2(size.x * 0.5, size.y * 0.62)


func _reset_to_idle() -> void:
	_origin = _idle_center()
	_place_visual_at(_origin)
	_center_knob()
	modulate = _idle_modulate


func _update_from_local_pos(local_pos: Vector2) -> void:
	var offset := local_pos - _origin
	if offset.length() > max_radius:
		offset = offset.limit_length(max_radius)

	if _knob and _visual:
		_knob.position = _visual.size * 0.5 + offset - _knob.size * 0.5

	var strength := offset.length() / max_radius
	if strength < deadzone:
		_output = Vector2.ZERO
	else:
		_output = offset.normalized() * clampf((strength - deadzone) / (1.0 - deadzone), 0.0, 1.0)
	InputService.set_move_vector(_output)
	joystick_updated.emit(_output)


func _release() -> void:
	_active_touch_index = -1
	_output = Vector2.ZERO
	InputService.clear_move_vector()
	_reset_to_idle()
	joystick_released.emit()


func _center_knob() -> void:
	if _visual == null or _knob == null:
		return
	_knob.position = _visual.size * 0.5 - _knob.size * 0.5


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _active_touch_index < 0:
		_reset_to_idle()
