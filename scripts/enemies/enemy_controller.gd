class_name EnemyController
extends CharacterBody3D
## Simple reliable AI: idle → detect → chase → attack → die.

enum State { IDLE, CHASE, ATTACK, DEAD }

const LootDropScene = preload("res://scenes/loot/loot_drop.tscn")

@export var enemy_id: StringName = &"forest_slime"

var def
var hp: int = 1
var state: State = State.IDLE
var _attack_cd: float = 0.0
var _player: Node3D
var _visual: Node3D
var _hp_label: Label3D


func setup(id: StringName) -> void:
	enemy_id = id


func _ready() -> void:
	def = ContentDB.get_enemy(enemy_id)
	if def == null:
		queue_free()
		return
	hp = def.max_hp
	collision_layer = 4
	collision_mask = 1
	add_to_group("enemies")
	_build_visual()
	_player = get_tree().get_first_node_in_group("player")


func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)

	# Soft ground shadow
	var shadow := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.45 * def.scale
	disc.bottom_radius = 0.45 * def.scale
	disc.height = 0.04
	shadow.mesh = disc
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0, 0, 0, 0.3)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow.material_override = sm
	shadow.position = Vector3(0, 0.02, 0)
	_visual.add_child(shadow)

	match String(enemy_id):
		"forest_slime":
			_add_mesh(_sphere(0.55 * def.scale, def.body_color), Vector3(0, 0.45 * def.scale, 0))
			_add_mesh(_sphere(0.18 * def.scale, Color(0.1, 0.15, 0.1)), Vector3(-0.18, 0.55 * def.scale, 0.35))
			_add_mesh(_sphere(0.18 * def.scale, Color(0.1, 0.15, 0.1)), Vector3(0.18, 0.55 * def.scale, 0.35))
		"wolf":
			_add_mesh(_box(Vector3(0.45, 0.4, 0.9) * def.scale, def.body_color), Vector3(0, 0.55 * def.scale, 0))
			_add_mesh(_box(Vector3(0.28, 0.28, 0.35) * def.scale, Color("4a3c34")), Vector3(0, 0.7 * def.scale, 0.45))
			_add_mesh(_box(Vector3(0.12, 0.12, 0.35) * def.scale, def.body_color), Vector3(0, 0.55 * def.scale, -0.55))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(-0.16, 0.22, 0.25))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(0.16, 0.22, 0.25))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(-0.16, 0.22, -0.25))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(0.16, 0.22, -0.25))
		"skeleton":
			_add_mesh(_box(Vector3(0.45, 0.55, 0.28) * def.scale, def.body_color), Vector3(0, 0.9 * def.scale, 0))
			_add_mesh(_sphere(0.24 * def.scale, Color("e8dfcf")), Vector3(0, 1.4 * def.scale, 0))
			_add_mesh(_box(Vector3(0.14, 0.45, 0.14) * def.scale, def.body_color), Vector3(-0.28, 0.85, 0))
			_add_mesh(_box(Vector3(0.14, 0.45, 0.14) * def.scale, def.body_color), Vector3(0.28, 0.85, 0))
			_add_mesh(_box(Vector3(0.14, 0.5, 0.14) * def.scale, def.body_color), Vector3(-0.12, 0.35, 0))
			_add_mesh(_box(Vector3(0.14, 0.5, 0.14) * def.scale, def.body_color), Vector3(0.12, 0.35, 0))
		"gravekeeper":
			_add_mesh(_box(Vector3(0.7, 0.9, 0.4) * def.scale, def.body_color), Vector3(0, 1.0 * def.scale, 0))
			_add_mesh(_sphere(0.28 * def.scale, Color("cfc6b4")), Vector3(0, 1.65 * def.scale, 0))
			_add_mesh(_box(Vector3(0.85, 0.2, 0.5) * def.scale, Color("2a3038")), Vector3(0, 1.55 * def.scale, 0))
			_add_mesh(_box(Vector3(0.12, 0.12, 1.1) * def.scale, Color("8a93a0")), Vector3(0.45, 1.1, 0.35))
			_add_mesh(_sphere(0.2 * def.scale, Color("c9a45c")), Vector3(0, 1.95 * def.scale, 0))
		_:
			_add_mesh(_capsule(0.35 * def.scale, 1.2 * def.scale, def.body_color), Vector3(0, 0.6 * def.scale, 0))

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4 * def.scale
	shape.height = 1.3 * def.scale
	col.shape = shape
	col.position = Vector3(0, 0.65 * def.scale, 0)
	add_child(col)

	_hp_label = Label3D.new()
	_hp_label.font_size = 30
	_hp_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_hp_label.modulate = Color("ffe6a8")
	_hp_label.outline_size = 6
	_hp_label.position = Vector3(0, 1.75 * def.scale, 0)
	_hp_label.text = "%d" % hp
	add_child(_hp_label)


func _add_mesh(mi: MeshInstance3D, pos: Vector3) -> void:
	mi.position = pos
	_visual.add_child(mi)


func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.78
	return m


func _box(size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color)
	return mi


func _sphere(radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.material_override = _mat(color)
	return mi


func _capsule(radius: float, height: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = _mat(color)
	return mi


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_attack_cd = maxf(0.0, _attack_cd - delta)
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		return
	if not GameState.is_alive():
		velocity = Vector3.ZERO
		return

	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()

	match state:
		State.IDLE:
			velocity = Vector3.ZERO
			if dist <= def.detect_range:
				state = State.CHASE
		State.CHASE:
			if dist > def.detect_range * 1.35:
				state = State.IDLE
				velocity = Vector3.ZERO
			elif dist <= def.attack_range:
				state = State.ATTACK
				velocity = Vector3.ZERO
			else:
				var dir := to_player.normalized()
				velocity = dir * def.move_speed
				_face(dir, delta)
		State.ATTACK:
			velocity = Vector3.ZERO
			if dist > def.attack_range * 1.25:
				state = State.CHASE
			elif _attack_cd <= 0.0:
				_do_attack()
				_attack_cd = def.attack_cooldown
	move_and_slide()


func _face(dir: Vector3, delta: float) -> void:
	if _visual == null or dir.length_squared() < 0.0001:
		return
	var yaw := atan2(dir.x, dir.z)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, yaw, clampf(10.0 * delta, 0.0, 1.0))


func _do_attack() -> void:
	if _player and _player.has_method("receive_enemy_hit"):
		_player.receive_enemy_hit(def.damage)
		AudioService.play_sfx(&"enemy_hit")
		AudioService.pulse_haptic(0.25)


func apply_damage(amount: int, is_critical: bool) -> void:
	if state == State.DEAD:
		return
	hp = maxi(0, hp - amount)
	if _hp_label:
		_hp_label.text = str(hp)
	EventBus.damage_dealt.emit(amount, is_critical, global_position + Vector3(0, 1.0, 0))
	AudioService.play_sfx(&"weapon_hit")
	if _visual:
		var tw := create_tween()
		tw.tween_property(_visual, "scale", Vector3(1.15, 0.85, 1.15), 0.06)
		tw.tween_property(_visual, "scale", Vector3.ONE, 0.1)
	if state == State.IDLE:
		state = State.CHASE
	if hp <= 0:
		_die()


func _die() -> void:
	state = State.DEAD
	EventBus.enemy_died.emit(enemy_id, global_position)
	GameState.add_xp(def.xp_reward)
	var gold := randi_range(def.gold_min, def.gold_max)
	_spawn_loot(gold)
	AudioService.play_sfx(&"enemy_death")
	VfxService.spawn_hit_flash(global_position, def.elite)
	queue_free()


func _spawn_loot(gold_amount: int) -> void:
	var drop := LootDropScene.instantiate()
	drop.setup_gold(gold_amount)
	get_parent().add_child(drop)
	drop.global_position = global_position + Vector3(0, 0.4, 0)
	for entry in def.loot_table:
		if randf() <= float(entry.get("chance", 0.0)):
			var item_drop := LootDropScene.instantiate()
			item_drop.setup_item(StringName(str(entry.get("item_id", ""))), int(entry.get("qty", 1)))
			get_parent().add_child(item_drop)
			item_drop.global_position = global_position + Vector3(randf_range(-0.6, 0.6), 0.4, randf_range(-0.6, 0.6))
