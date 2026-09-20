class_name PlayerController
extends CharacterBody3D
## Responsive movement + weapon-aware combat (melee / bow / wand).

const CombatMathScript = preload("res://scripts/combat/combat_math.gd")
const PlayerVisualBuilderScript = preload("res://scripts/player/player_visual_builder.gd")
const ItemDefScript = preload("res://scripts/data/item_def.gd")
const ProjectileScene = preload("res://scenes/combat/projectile.tscn")

@export var move_speed: float = 6.5
@export var acceleration: float = 28.0
@export var friction: float = 32.0
@export var rotation_speed: float = 14.0

@onready var visual: Node3D = $Visual
@onready var bounce: Node3D = $Visual/Bounce
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _desired_velocity: Vector3 = Vector3.ZERO
var _is_moving: bool = false
var _attack_cd: float = 0.0
var _attacking: bool = false
var _dead: bool = false
var _respawn_timer: float = 0.0
var _i_frames: float = 0.0
var _zone: StringName = &"village"


func _ready() -> void:
	move_speed = GameConfig.PLAYER_MOVE_SPEED
	acceleration = GameConfig.PLAYER_ACCELERATION
	friction = GameConfig.PLAYER_FRICTION
	rotation_speed = GameConfig.PLAYER_ROTATION_SPEED
	PlayerVisualBuilderScript.build(bounce)
	_refresh_weapon_visual()
	add_to_group("player")
	global_position = GameState.position
	EventBus.player_spawned.emit(self)
	EventBus.player_respawned.connect(_on_respawned)
	EventBus.equipment_changed.connect(_refresh_weapon_visual)
	EventBus.player_died.connect(_on_died_signal)
	_play_anim("idle")
	AudioService.play_music(&"village_ambient")


func _physics_process(delta: float) -> void:
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_i_frames = maxf(0.0, _i_frames - delta)
	_update_zone()

	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_attack_cooldown"):
		var wdef := _get_weapon_def()
		var max_cd: float = 0.38 / maxf(0.5, wdef.attack_speed if wdef else 1.0)
		hud.set_attack_cooldown(_attack_cd / max_cd)

	if _dead:
		_respawn_timer -= delta
		velocity = Vector3.ZERO
		return

	if InputService.consume_attack() or Input.is_action_just_pressed("ui_accept"):
		try_attack()
	if InputService.consume_interact() or Input.is_action_just_pressed("ui_focus_next"):
		_try_interact_nearest()

	var input_dir := InputService.move_vector
	if input_dir.length_squared() < 0.0001:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var move_dir := Vector3(input_dir.x, 0.0, input_dir.y)
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


func _get_weapon_def() -> ItemDef:
	var eq = GameState.equipment[ItemDefScript.Slot.WEAPON]
	if eq == null:
		return ContentDB.get_item(&"rusty_sword")
	return ContentDB.get_item(eq.item_id)


func try_attack() -> void:
	if _dead or _attack_cd > 0.0:
		return
	var wdef := _get_weapon_def()
	var speed_mult := wdef.attack_speed if wdef else 1.0
	_attack_cd = 0.38 / maxf(0.5, speed_mult)
	_attacking = true

	var target := _find_auto_aim_target(wdef.attack_range if wdef else 2.5)
	if target != null:
		var to_t := target.global_position - global_position
		to_t.y = 0.0
		if to_t.length_squared() > 0.0001:
			_face_direction(to_t.normalized(), 1.0)

	_play_anim("attack")
	AudioService.play_sfx(&"player_attack")
	AudioService.pulse_haptic(0.15)

	if wdef and wdef.weapon_type == ItemDefScript.WeaponType.BOW:
		_fire_projectile(target, Color("d8e8b0"), wdef)
	elif wdef and wdef.weapon_type == ItemDefScript.WeaponType.WAND:
		_fire_projectile(target, Color("ff7a3a"), wdef)
	else:
		_deal_melee_hits(target, wdef.attack_range if wdef else 2.3)

	var cam := get_tree().get_first_node_in_group("player_camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.08)

	get_tree().create_timer(0.18).timeout.connect(func():
		_attacking = false
		_play_anim("walk" if _is_moving else "idle")
	)


func _fire_projectile(preferred: Node3D, tint: Color, wdef: ItemDef) -> void:
	var dir := get_facing_direction()
	if preferred != null and is_instance_valid(preferred):
		dir = preferred.global_position - global_position
		dir.y = 0.0
		if dir.length_squared() > 0.0001:
			dir = dir.normalized()
	var roll: Dictionary = CombatMathScript.roll_player_damage()
	var proj := ProjectileScene.instantiate()
	get_parent().add_child(proj)
	proj.setup(global_position + Vector3(0, 1.1, 0) + dir * 0.6, dir, int(roll.damage), bool(roll.critical), wdef.projectile_speed, tint, self)


func _find_auto_aim_target(range_v: float) -> Node3D:
	var best: Node3D = null
	var best_score := range_v
	var facing := get_facing_direction()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		var to_e: Vector3 = enemy.global_position - global_position
		to_e.y = 0.0
		var dist := to_e.length()
		if dist > range_v or dist < 0.01:
			continue
		var score := dist - facing.dot(to_e.normalized()) * 0.8
		if score < best_score:
			best_score = score
			best = enemy as Node3D
	return best


func _deal_melee_hits(preferred: Node3D, range_v: float) -> void:
	var facing := get_facing_direction()
	var hit_any := false
	if preferred != null and is_instance_valid(preferred) and preferred.has_method("apply_damage"):
		var d: float = global_position.distance_to(preferred.global_position)
		if d <= range_v * 1.05:
			var roll: Dictionary = CombatMathScript.roll_player_damage()
			preferred.apply_damage(int(roll.damage), bool(roll.critical))
			if preferred.has_method("apply_knockback"):
				preferred.apply_knockback(facing * 4.0)
			hit_any = true
			if bool(roll.critical):
				var cam := get_tree().get_first_node_in_group("player_camera")
				if cam and cam.has_method("shake"):
					cam.shake(0.14)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy) or enemy == preferred:
			continue
		var to_e: Vector3 = enemy.global_position - global_position
		to_e.y = 0.0
		var dist := to_e.length()
		if dist > range_v:
			continue
		if dist > 0.25 and facing.dot(to_e.normalized()) < 0.15:
			continue
		var roll2: Dictionary = CombatMathScript.roll_player_damage()
		enemy.apply_damage(int(roll2.damage), bool(roll2.critical))
		if enemy.has_method("apply_knockback"):
			enemy.apply_knockback(facing * 3.2)
		hit_any = true

	if not hit_any:
		VfxService.spawn_hit_flash(global_position + Vector3(0, 0.9, 0) + facing * 1.2, false)


func receive_enemy_hit(raw_damage: int) -> void:
	if _dead or _i_frames > 0.0:
		return
	var taken := GameState.apply_damage(raw_damage)
	_i_frames = 0.55
	EventBus.damage_dealt.emit(taken, false, global_position + Vector3(0, 1.3, 0))
	_play_anim("hit")
	var cam := get_tree().get_first_node_in_group("player_camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.12)
	if not GameState.is_alive():
		_die()


func _die() -> void:
	_dead = true
	_respawn_timer = 999.0
	_play_anim("death")
	AudioService.play_sfx(&"player_death")
	velocity = Vector3.ZERO


func _on_died_signal() -> void:
	_die()


func return_to_village() -> void:
	GameState.respawn()


func _on_respawned() -> void:
	_dead = false
	_respawn_timer = 0.0
	global_position = GameConfig.VILLAGE_SPAWN
	_play_anim("idle")


func _refresh_weapon_visual() -> void:
	var wdef := _get_weapon_def()
	PlayerVisualBuilderScript.set_weapon(bounce, wdef)


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
	var t := 1.0 if delta >= 1.0 else clampf(rotation_speed * delta, 0.0, 1.0)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, t)


func _set_moving(moving: bool) -> void:
	if _is_moving == moving:
		return
	_is_moving = moving
	if not _attacking and not _dead:
		_play_anim("walk" if moving else "idle")


func _play_anim(anim_name: StringName) -> void:
	if anim_player == null or not anim_player.has_animation(anim_name):
		return
	if anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)


func get_facing_direction() -> Vector3:
	return -visual.global_transform.basis.z


func _update_zone() -> void:
	var next: StringName = &"village"
	if global_position.x > 26.0:
		next = &"cemetery"
	elif global_position.z < -22.0:
		next = &"forest"
	if next == _zone:
		return
	_zone = next
	match _zone:
		&"forest":
			AudioService.play_music(&"forest_ambient")
			_set_world_mood(Color(0.16, 0.2, 0.18), 0.007, Color(0.85, 0.95, 0.88), 0.95)
		&"cemetery":
			AudioService.play_music(&"cemetery_ambient")
			_set_world_mood(Color(0.1, 0.11, 0.14), 0.012, Color(0.7, 0.78, 0.95), 0.85)
		_:
			AudioService.play_music(&"village_ambient")
			_set_world_mood(Color(0.12, 0.14, 0.16), 0.0055, Color(1.0, 0.93, 0.82), 1.15)


func _set_world_mood(bg: Color, fog_density: float, sun_color: Color, sun_energy: float) -> void:
	var env_node := get_tree().current_scene.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node and env_node.environment:
		env_node.environment.background_color = bg
		env_node.environment.fog_density = fog_density
	var sun := get_tree().current_scene.get_node_or_null("Sun") as DirectionalLight3D
	if sun:
		sun.light_color = sun_color
		sun.light_energy = sun_energy
