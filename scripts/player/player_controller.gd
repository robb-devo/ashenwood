class_name PlayerController
extends CharacterBody3D
## Movement + melee combat + death/respawn.

const CombatMathScript = preload("res://scripts/combat/combat_math.gd")

@export var move_speed: float = 6.5
@export var acceleration: float = 28.0
@export var friction: float = 32.0
@export var rotation_speed: float = 14.0
@export var attack_range: float = 2.1
@export var attack_cooldown: float = 0.38

@onready var visual: Node3D = $Visual
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _desired_velocity: Vector3 = Vector3.ZERO
var _is_moving: bool = false
var _attack_cd: float = 0.0
var _attacking: bool = false
var _dead: bool = false
var _respawn_timer: float = 0.0
var _i_frames: float = 0.0


func _ready() -> void:
	move_speed = GameConfig.PLAYER_MOVE_SPEED
	acceleration = GameConfig.PLAYER_ACCELERATION
	friction = GameConfig.PLAYER_FRICTION
	rotation_speed = GameConfig.PLAYER_ROTATION_SPEED
	add_to_group("player")
	global_position = GameState.position
	EventBus.player_spawned.emit(self)
	EventBus.player_respawned.connect(_on_respawned)
	_play_anim("idle")


func _physics_process(delta: float) -> void:
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_i_frames = maxf(0.0, _i_frames - delta)

	if _dead:
		_respawn_timer -= delta
		velocity = Vector3.ZERO
		if _respawn_timer <= 0.0:
			GameState.respawn()
		return

	if InputService.consume_attack() or Input.is_action_just_pressed("ui_accept"):
		try_attack()

	if InputService.consume_interact() or Input.is_action_just_pressed("ui_focus_next"):
		_try_interact_nearest()

	var input_dir := InputService.move_vector
	if input_dir.length_squared() < 0.0001:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var move_dir := Vector3(input_dir.x, 0.0, -input_dir.y)
	if move_dir.length_squared() > 0.0001 and not _attacking:
		move_dir = move_dir.normalized()
		_desired_velocity = move_dir * move_speed
		_face_direction(move_dir, delta)
		_set_moving(true)
	else:
		_desired_velocity = Vector3.ZERO
		if not _attacking:
			_set_moving(false)

	var horiz := Vector3(velocity.x, 0.0, velocity.z)
	if _desired_velocity.length_squared() > 0.0001:
		horiz = horiz.move_toward(_desired_velocity, acceleration * delta)
	else:
		horiz = horiz.move_toward(Vector3.ZERO, friction * delta)
	velocity.x = horiz.x
	velocity.z = horiz.z
	velocity.y = 0.0
	move_and_slide()
	GameState.position = global_position


func try_attack() -> void:
	if _dead or _attack_cd > 0.0:
		return
	_attack_cd = attack_cooldown
	_attacking = true
	_play_anim("attack")
	AudioService.play_sfx(&"player_attack")
	AudioService.pulse_haptic(0.15)
	_deal_melee_hits()
	get_tree().create_timer(0.22).timeout.connect(func():
		_attacking = false
		_play_anim("walk" if _is_moving else "idle")
	)


func _deal_melee_hits() -> void:
	var origin := global_position + Vector3(0, 0.8, 0)
	var facing := get_facing_direction()
	var hit_any := false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		var to_e: Vector3 = enemy.global_position - global_position
		to_e.y = 0.0
		var dist := to_e.length()
		if dist > attack_range:
			continue
		if dist > 0.2 and facing.dot(to_e.normalized()) < 0.15:
			continue
		var roll: Dictionary = CombatMathScript.roll_player_damage()
		if enemy.has_method("apply_damage"):
			enemy.apply_damage(int(roll.damage), bool(roll.critical))
			hit_any = true
	if not hit_any:
		# Still show a tiny swing feedback forward
		VfxService.spawn_hit_flash(origin + facing * 1.2, false)


func receive_enemy_hit(raw_damage: int) -> void:
	if _dead or _i_frames > 0.0:
		return
	var taken := GameState.apply_damage(raw_damage)
	_i_frames = 0.55
	EventBus.damage_dealt.emit(taken, false, global_position + Vector3(0, 1.3, 0))
	_play_anim("hit")
	if not GameState.is_alive():
		_die()


func _die() -> void:
	_dead = true
	_respawn_timer = 2.2
	_play_anim("death")
	AudioService.play_sfx(&"player_death")
	velocity = Vector3.ZERO


func _on_respawned() -> void:
	_dead = false
	global_position = GameConfig.VILLAGE_SPAWN
	_play_anim("idle")


func _try_interact_nearest() -> void:
	var best: Node = null
	var best_dist := 999.0
	for npc in get_tree().get_nodes_in_group("npcs"):
		if npc is NpcInteractable and npc.player_in_range:
			var d: float = global_position.distance_to(npc.global_position)
			if d < best_dist:
				best_dist = d
				best = npc
	if best:
		best.try_interact()


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.0001:
		return
	var target_yaw := atan2(direction.x, direction.z)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, clampf(rotation_speed * delta, 0.0, 1.0))


func _set_moving(moving: bool) -> void:
	if _is_moving == moving:
		return
	_is_moving = moving
	if not _attacking and not _dead:
		_play_anim("walk" if moving else "idle")


func _play_anim(anim_name: StringName) -> void:
	if anim_player == null:
		return
	if not anim_player.has_animation(anim_name):
		# Graceful fallback for missing clips
		if anim_name == &"attack" or anim_name == &"hit" or anim_name == &"death":
			return
		return
	if anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)


func get_facing_direction() -> Vector3:
	return -visual.global_transform.basis.z
