class_name PlayerCamera
extends Camera3D
## Smooth follow camera for portrait top-down play.

@export var follow_target: Node3D
@export var distance: float = 14.0
@export var height: float = 16.0
@export var pitch_deg: float = -55.0
@export var follow_smoothing: float = 8.0
@export var look_ahead: float = 1.25

var _velocity_bias: Vector3 = Vector3.ZERO


func _ready() -> void:
	distance = GameConfig.CAMERA_DISTANCE
	height = GameConfig.CAMERA_HEIGHT
	pitch_deg = GameConfig.CAMERA_PITCH_DEG
	follow_smoothing = GameConfig.CAMERA_FOLLOW_SMOOTHING
	look_ahead = GameConfig.CAMERA_LOOK_AHEAD
	projection = PROJECTION_PERSPECTIVE
	fov = 42.0
	current = true
	if follow_target == null:
		follow_target = get_tree().get_first_node_in_group("player") as Node3D


func _physics_process(delta: float) -> void:
	if follow_target == null:
		follow_target = get_tree().get_first_node_in_group("player") as Node3D
		if follow_target == null:
			return

	var target_pos := follow_target.global_position
	if follow_target is CharacterBody3D:
		var body := follow_target as CharacterBody3D
		_velocity_bias = _velocity_bias.lerp(body.velocity * look_ahead * 0.08, clampf(6.0 * delta, 0.0, 1.0))
		target_pos += _velocity_bias

	var offset := Vector3(0.0, height, distance)
	var desired := target_pos + offset
	global_position = global_position.lerp(desired, clampf(follow_smoothing * delta, 0.0, 1.0))

	var look_at_pos := target_pos + Vector3(0.0, 0.75, 0.0)
	look_at(look_at_pos, Vector3.UP)
