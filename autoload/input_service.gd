extends Node
## Aggregates virtual joystick / future ability input for gameplay systems.
## Keeps CharacterBody controllers free of raw touch handling.

var move_vector: Vector2 = Vector2.ZERO
var attack_pressed: bool = false
var interact_pressed: bool = false

func set_move_vector(value: Vector2) -> void:
	if value.length() < GameConfig.JOYSTICK_DEADZONE:
		move_vector = Vector2.ZERO
		return
	move_vector = value.limit_length(1.0)


func clear_move_vector() -> void:
	move_vector = Vector2.ZERO


func consume_attack() -> bool:
	if not attack_pressed:
		return false
	attack_pressed = false
	return true


func consume_interact() -> bool:
	if not interact_pressed:
		return false
	interact_pressed = false
	return true
