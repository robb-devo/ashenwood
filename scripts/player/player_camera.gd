class_name PlayerCamera
extends Camera3D
## Smooth follow + subtle combat shake.

@export var follow_target: Node3D
@export var distance: float = 14.0
@export var height: float = 16.0
@export var follow_smoothing: float = 8.0
@export var look_ahead: float = 1.25

var _velocity_bias: Vector3 = Vector3.ZERO
var _shake: float = 0.0


func _ready() -> void:
	distance = GameConfig.CAMERA_DISTANCE
	height = GameConfig.CAMERA_HEIGHT
	follow_smoothing = GameConfig.CAMERA_FOLLOW_SMOOTHING
	look_ahead = GameConfig.CAMERA_LOOK_AHEAD
	projection = PROJECTION_PERSPECTIVE
	fov = 48.0
	current = true
	add_to_group("player_camera")
	if follow_target == null:
		follow_target = get_tree().get_first_node_in_group("player") as Node3D


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


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
	if _shake > 0.0:
		desired += Vector3(randf_range(-1, 1), randf_range(-0.4, 0.4), randf_range(-1, 1)) * _shake
		_shake = move_toward(_shake, 0.0, delta * 1.8)
	global_position = global_position.lerp(desired, clampf(follow_smoothing * delta, 0.0, 1.0))
	look_at(target_pos + Vector3(0.0, 1.1, 0.0), Vector3.UP)
