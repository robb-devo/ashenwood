class_name EnemyController
extends CharacterBody3D
## AI with patrol, chase, attack telegraphs (elite), knockback.

enum State { IDLE, PATROL, CHASE, TELEGRAPH, ATTACK, DEAD }

const LootDropScene = preload("res://scenes/loot/loot_drop.tscn")

@export var enemy_id: StringName = &"forest_slime"

var def
var hp: int = 1
var max_hp: int = 1
var state: State = State.IDLE
var _attack_cd: float = 0.0
var _player: Node3D
var _visual: Node3D
var _hp_label: Label3D
var _knockback: Vector3 = Vector3.ZERO
var _patrol_target: Vector3
var _telegraph_time: float = 0.0
var _telegraph_mesh: MeshInstance3D
var _home: Vector3
var _boss_announced: bool = false


func setup(id: StringName) -> void:
	enemy_id = id


func _ready() -> void:
	def = ContentDB.get_enemy(enemy_id)
	if def == null:
		queue_free()
		return
	hp = def.max_hp
	max_hp = def.max_hp
	collision_layer = 4
	collision_mask = 1
	add_to_group("enemies")
	_home = global_position
	_patrol_target = global_position + Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
	_build_visual()
	_player = get_tree().get_first_node_in_group("player")


func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)
	var shadow := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.5 * def.scale
	disc.bottom_radius = 0.5 * def.scale
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
			_add_mesh(_sphere(0.16 * def.scale, Color(0.1, 0.15, 0.1)), Vector3(-0.18, 0.55 * def.scale, 0.35))
			_add_mesh(_sphere(0.16 * def.scale, Color(0.1, 0.15, 0.1)), Vector3(0.18, 0.55 * def.scale, 0.35))
		"wolf":
			_add_mesh(_box(Vector3(0.45, 0.4, 0.9) * def.scale, def.body_color), Vector3(0, 0.55 * def.scale, 0))
			_add_mesh(_box(Vector3(0.28, 0.28, 0.35) * def.scale, Color("4a3c34")), Vector3(0, 0.7 * def.scale, 0.45))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(-0.16, 0.22, 0.25))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(0.16, 0.22, 0.25))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(-0.16, 0.22, -0.25))
			_add_mesh(_box(Vector3(0.12, 0.35, 0.12) * def.scale, Color("3a2e28")), Vector3(0.16, 0.22, -0.25))
		"bandit":
			_add_mesh(_box(Vector3(0.5, 0.7, 0.32) * def.scale, def.body_color), Vector3(0, 0.95 * def.scale, 0))
			_add_mesh(_sphere(0.22 * def.scale, Color("d7b07a")), Vector3(0, 1.45 * def.scale, 0))
			_add_mesh(_box(Vector3(0.12, 0.12, 0.55) * def.scale, Color("9aa0a8")), Vector3(0.35, 0.95, 0.25))
		"skeleton":
			_add_mesh(_box(Vector3(0.45, 0.55, 0.28) * def.scale, def.body_color), Vector3(0, 0.9 * def.scale, 0))
			_add_mesh(_sphere(0.24 * def.scale, Color("e8dfcf")), Vector3(0, 1.4 * def.scale, 0))
			_add_mesh(_box(Vector3(0.14, 0.45, 0.14) * def.scale, def.body_color), Vector3(-0.28, 0.85, 0))
			_add_mesh(_box(Vector3(0.14, 0.45, 0.14) * def.scale, def.body_color), Vector3(0.28, 0.85, 0))
		"gravekeeper":
			_add_mesh(_box(Vector3(0.75, 1.0, 0.45) * def.scale, def.body_color), Vector3(0, 1.05 * def.scale, 0))
			_add_mesh(_sphere(0.3 * def.scale, Color("cfc6b4")), Vector3(0, 1.75 * def.scale, 0))
			_add_mesh(_box(Vector3(0.95, 0.22, 0.55) * def.scale, Color("2a3038")), Vector3(0, 1.65 * def.scale, 0))
			_add_mesh(_box(Vector3(0.14, 0.14, 1.25) * def.scale, Color("8a93a0")), Vector3(0.5, 1.15, 0.4))
			_add_mesh(_sphere(0.22 * def.scale, Color("c9a45c")), Vector3(0, 2.05 * def.scale, 0))
		_:
			_add_mesh(_box(Vector3(0.5, 0.9, 0.4) * def.scale, def.body_color), Vector3(0, 0.7, 0))

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42 * def.scale
	shape.height = 1.35 * def.scale
	col.shape = shape
	col.position = Vector3(0, 0.7 * def.scale, 0)
	add_child(col)

	_hp_label = Label3D.new()
	_hp_label.font_size = 30
	_hp_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_hp_label.modulate = Color("ffe6a8")
	_hp_label.outline_size = 6
	_hp_label.position = Vector3(0, 1.9 * def.scale, 0)
	_hp_label.text = "%d" % hp
	add_child(_hp_label)


func _add_mesh(mi: MeshInstance3D, pos: Vector3) -> void:
	mi.position = pos
	_visual.add_child(mi)


func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.78
	m.emission_enabled = true
	m.emission = color * 0.12
	m.emission_energy_multiplier = 0.4
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


func apply_knockback(force: Vector3) -> void:
	_knockback = force


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_attack_cd = maxf(0.0, _attack_cd - delta)
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	if _knockback.length_squared() > 0.01:
		velocity = _knockback
		_knockback = _knockback.move_toward(Vector3.ZERO, 14.0 * delta)
		move_and_slide()
		return

	if not GameState.is_alive() or _player == null:
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
				_announce_boss()
			elif randf() < 0.01:
				state = State.PATROL
				_patrol_target = _home + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
		State.PATROL:
			if dist <= def.detect_range:
				state = State.CHASE
				_announce_boss()
			else:
				var to_p := _patrol_target - global_position
				to_p.y = 0
				if to_p.length() < 0.6:
					state = State.IDLE
				else:
					velocity = to_p.normalized() * def.move_speed * 0.55
					_face(to_p.normalized(), delta)
		State.CHASE:
			if dist > def.detect_range * 1.4:
				state = State.IDLE
				velocity = Vector3.ZERO
			elif dist <= def.attack_range:
				velocity = Vector3.ZERO
				if def.elite and _attack_cd <= 0.0:
					_start_telegraph()
				elif _attack_cd <= 0.0:
					state = State.ATTACK
			else:
				var dir := to_player.normalized()
				velocity = dir * def.move_speed
				_face(dir, delta)
		State.TELEGRAPH:
			velocity = Vector3.ZERO
			_telegraph_time -= delta
			if _telegraph_time <= 0.0:
				_clear_telegraph()
				state = State.ATTACK
		State.ATTACK:
			velocity = Vector3.ZERO
			_do_attack()
			_attack_cd = def.attack_cooldown
			state = State.CHASE

	move_and_slide()


func _announce_boss() -> void:
	if def == null or not def.elite or _boss_announced:
		return
	_boss_announced = true
	EventBus.boss_engaged.emit(enemy_id, hp, max_hp)
	AudioService.play_sfx(&"boss")


func _start_telegraph() -> void:
	state = State.TELEGRAPH
	_telegraph_time = 0.85
	_telegraph_mesh = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.4
	cyl.bottom_radius = 0.4
	cyl.height = 0.06
	_telegraph_mesh.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.15, 0.12, 0.45)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.18, 0.08)
	mat.emission_energy_multiplier = 2.2
	_telegraph_mesh.material_override = mat
	_telegraph_mesh.position = Vector3(0, 0.06, 0)
	add_child(_telegraph_mesh)
	var tw := create_tween()
	tw.tween_property(cyl, "top_radius", def.attack_range * 1.05, 0.8)
	tw.parallel().tween_property(cyl, "bottom_radius", def.attack_range * 1.05, 0.8)


func _clear_telegraph() -> void:
	if _telegraph_mesh and is_instance_valid(_telegraph_mesh):
		_telegraph_mesh.queue_free()
	_telegraph_mesh = null


func _face(dir: Vector3, delta: float) -> void:
	if _visual == null or dir.length_squared() < 0.0001:
		return
	var yaw := atan2(dir.x, dir.z)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, yaw, clampf(10.0 * delta, 0.0, 1.0))


func _do_attack() -> void:
	if _player and _player.has_method("receive_enemy_hit"):
		var d: float = global_position.distance_to(_player.global_position)
		var reach: float = def.attack_range * (1.35 if def.elite else 1.15)
		if d <= reach:
			var dmg: int = def.damage * (2 if def.elite and randf() < 0.35 else 1)
			_player.receive_enemy_hit(dmg)
			AudioService.play_sfx(&"enemy_hit")
			AudioService.pulse_haptic(0.35 if def.elite else 0.25)
			if def.elite:
				VfxService.spawn_hit_flash(global_position + Vector3(0, 1.0, 0), true)
				var cam := get_tree().get_first_node_in_group("player_camera")
				if cam and cam.has_method("shake"):
					cam.shake(0.18)


func apply_damage(amount: int, is_critical: bool) -> void:
	if state == State.DEAD:
		return
	hp = maxi(0, hp - amount)
	if _hp_label:
		_hp_label.text = str(hp)
	EventBus.damage_dealt.emit(amount, is_critical, global_position + Vector3(0, 1.0, 0))
	AudioService.play_sfx(&"weapon_hit" if not is_critical else &"critical", 1.15 if is_critical else 1.0)
	AudioService.pulse_haptic(0.18 if not is_critical else 0.32)
	if def.elite:
		EventBus.boss_hp_changed.emit(enemy_id, hp, max_hp)
	# Flash white briefly
	if _visual:
		for c in _visual.get_children():
			if c is MeshInstance3D and c.material_override:
				var mat := c.material_override as StandardMaterial3D
				if mat:
					var orig := mat.albedo_color
					mat.albedo_color = Color(1.0, 1.0, 1.0)
					get_tree().create_timer(0.05).timeout.connect(func():
						if is_instance_valid(mat):
							mat.albedo_color = orig
					)
		var tw := create_tween()
		tw.tween_property(_visual, "scale", Vector3(1.22, 0.78, 1.22), 0.04)
		tw.tween_property(_visual, "scale", Vector3.ONE, 0.1)
	if state == State.IDLE or state == State.PATROL:
		state = State.CHASE
	if hp <= 0:
		_die()


func _die() -> void:
	state = State.DEAD
	_clear_telegraph()
	collision_layer = 0
	collision_mask = 0
	EventBus.enemy_died.emit(enemy_id, global_position)
	if def.elite:
		EventBus.boss_defeated.emit(enemy_id)
		AudioService.play_sfx(&"quest_complete")
	GameState.add_xp(def.xp_reward)
	AudioService.play_sfx(&"enemy_death")
	VfxService.spawn_death_burst(global_position, def.body_color if def else Color("ffe08a"))
	if _hp_label:
		_hp_label.visible = false
	if _visual:
		var tw := create_tween()
		tw.tween_property(_visual, "scale", Vector3(1.35, 0.25, 1.35), 0.14)
		tw.tween_callback(func():
			_spawn_loot(randi_range(def.gold_min, def.gold_max))
			queue_free()
		)
	else:
		_spawn_loot(randi_range(def.gold_min, def.gold_max))
		queue_free()


func _spawn_loot(gold_amount: int) -> void:
	var drop := LootDropScene.instantiate()
	drop.setup_gold(gold_amount)
	get_parent().add_child(drop)
	drop.global_position = global_position + Vector3(0, 0.4, 0)
	for entry in def.loot_table:
		if randf() <= float(entry.get("chance", 0.0)):
			var item_drop := LootDropScene.instantiate()
			var iid := StringName(str(entry.get("item_id", "")))
			item_drop.setup_item(iid, int(entry.get("qty", 1)))
			get_parent().add_child(item_drop)
			item_drop.global_position = global_position + Vector3(randf_range(-0.7, 0.7), 0.4, randf_range(-0.7, 0.7))
			var def_item = ContentDB.get_item(iid)
			if def_item and def_item.rarity >= 2:
				EventBus.rare_loot_found.emit(iid)
