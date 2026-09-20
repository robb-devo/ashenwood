class_name MobileJoystick
extends Control
## Bottom-center virtual stick: knob starts centered, drag direction = walk direction.

signal joystick_updated(direction: Vector2)
signal joystick_released

@export var max_radius: float = 120.0
@export var deadzone: float = 0.1

var _base: Panel
var _ring: Panel
var _knob: Panel
var _active_touch_index: int = -1
var _output: Vector2 = Vector2.ZERO
var _idle_modulate := Color(1, 1, 1, 0.42)
var _active_modulate := Color(1, 1, 1, 0.92)


func _ready() -> void:
	max_radius = GameConfig.JOYSTICK_MAX_RADIUS
	deadzone = GameConfig.JOYSTICK_DEADZONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_visuals()
	_center_knob()
	modulate = _idle_modulate


func _build_visuals() -> void:
	# Outer soft ring
	_ring = Panel.new()
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.set_anchors_preset(Control.PRESET_CENTER)
	_ring.offset_left = -150
	_ring.offset_top = -150
	_ring.offset_right = 150
	_ring.offset_bottom = 150
	var ring_style := StyleBoxFlat.new()
	ring_style.bg_color = Color(0.08, 0.1, 0.12, 0.18)
	ring_style.border_color = Color(0.86, 0.74, 0.48, 0.22)
	ring_style.set_border_width_all(2)
	ring_style.set_corner_radius_all(160)
	_ring.add_theme_stylebox_override("panel", ring_style)
	add_child(_ring)

	_base = Panel.new()
	_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base.set_anchors_preset(Control.PRESET_CENTER)
	_base.offset_left = -118
	_base.offset_top = -118
	_base.offset_right = 118
	_base.offset_bottom = 118
	var base_style := StyleBoxFlat.new()
	base_style.bg_color = Color(0.06, 0.08, 0.1, 0.45)
	base_style.border_color = Color(0.9, 0.78, 0.5, 0.55)
	base_style.set_border_width_all(3)
	base_style.set_corner_radius_all(140)
	base_style.shadow_color = Color(0, 0, 0, 0.35)
	base_style.shadow_size = 12
	_base.add_theme_stylebox_override("panel", base_style)
	add_child(_base)

	# Crosshair guides
	for axis in [true, false]:
		var guide := ColorRect.new()
		guide.mouse_filter = Control.MOUSE_FILTER_IGNORE
		guide.color = Color(0.9, 0.82, 0.6, 0.14)
		_base.add_child(guide)
		if axis:
			guide.set_anchors_preset(Control.PRESET_CENTER)
			guide.offset_left = -1.5
			guide.offset_top = -70
			guide.offset_right = 1.5
			guide.offset_bottom = 70
		else:
			guide.set_anchors_preset(Control.PRESET_CENTER)
			guide.offset_left = -70
			guide.offset_top = -1.5
			guide.offset_right = 70
			guide.offset_bottom = 1.5

	_knob = Panel.new()
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_knob.custom_minimum_size = Vector2(92, 92)
	_knob.size = Vector2(92, 92)
	var knob_style := StyleBoxFlat.new()
	knob_style.bg_color = Color(0.9, 0.78, 0.5, 0.88)
	knob_style.border_color = Color(1.0, 0.94, 0.78, 0.9)
	knob_style.set_border_width_all(3)
	knob_style.set_corner_radius_all(60)
	knob_style.shadow_color = Color(0.9, 0.7, 0.3, 0.35)
	knob_style.shadow_size = 10
	_knob.add_theme_stylebox_override("panel", knob_style)
	_base.add_child(_knob)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _active_touch_index == -1:
			_active_touch_index = touch.index
			modulate = _active_modulate
			_update_from_local_pos(touch.position)
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
			_active_touch_index = 0
			modulate = _active_modulate
			_update_from_local_pos(mouse.position)
			accept_event()
		elif not mouse.pressed and _active_touch_index == 0:
			_release()
			accept_event()
	elif event is InputEventMouseMotion and _active_touch_index == 0:
		_update_from_local_pos((event as InputEventMouseMotion).position)
		accept_event()


func _update_from_local_pos(local_pos: Vector2) -> void:
	var center := size * 0.5
	var offset := local_pos - center
	if offset.length() > max_radius:
		offset = offset.limit_length(max_radius)
	_knob.position = (_base.size * 0.5) + offset - _knob.size * 0.5

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
	_center_knob()
	modulate = _idle_modulate
	joystick_released.emit()


func _center_knob() -> void:
	if _base == null or _knob == null:
		return
	_knob.position = _base.size * 0.5 - _knob.size * 0.5


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_center_knob()
