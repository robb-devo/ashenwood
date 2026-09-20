class_name MobileJoystick
extends Control
## Lower-left virtual joystick for portrait mobile controls.

signal joystick_updated(direction: Vector2)
signal joystick_released

@export var max_radius: float = 110.0
@export var deadzone: float = 0.12

@onready var base: Panel = $Base
@onready var knob: Panel = $Base/Knob

var _active_touch_index: int = -1
var _base_center: Vector2 = Vector2.ZERO
var _output: Vector2 = Vector2.ZERO


func _ready() -> void:
	max_radius = GameConfig.JOYSTICK_MAX_RADIUS
	deadzone = GameConfig.JOYSTICK_DEADZONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_center_knob()
	set_process_input(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_base_center = base.size * 0.5
		_center_knob()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _active_touch_index == -1:
			_active_touch_index = touch.index
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
			_update_from_local_pos(mouse.position)
			accept_event()
		elif not mouse.pressed and _active_touch_index == 0:
			_release()
			accept_event()
	elif event is InputEventMouseMotion and _active_touch_index == 0:
		var motion := event as InputEventMouseMotion
		_update_from_local_pos(motion.position)
		accept_event()


func _update_from_local_pos(local_pos: Vector2) -> void:
	_base_center = base.size * 0.5
	var local_in_base := local_pos - base.position
	var offset := local_in_base - _base_center
	if offset.length() > max_radius:
		offset = offset.limit_length(max_radius)
	knob.position = _base_center + offset - knob.size * 0.5

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
	joystick_released.emit()


func _center_knob() -> void:
	if base == null or knob == null:
		return
	_base_center = base.size * 0.5
	knob.position = _base_center - knob.size * 0.5
