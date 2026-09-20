extends Node
## Juicy mobile VFX: damage numbers, flashes, rings, death bursts.

var _damage_pool: Array[Label3D] = []
var _world_fx_root: Node3D


func _ready() -> void:
	EventBus.damage_dealt.connect(_on_damage)
	EventBus.player_leveled_up.connect(func(_l): spawn_level_up())
	call_deferred("_ensure_root")


func _ensure_root() -> void:
	var main := get_tree().current_scene
	if main == null:
		return
	_world_fx_root = main.get_node_or_null("VfxRoot") as Node3D
	if _world_fx_root == null:
		_world_fx_root = Node3D.new()
		_world_fx_root.name = "VfxRoot"
		main.add_child(_world_fx_root)


func _on_damage(amount: int, is_critical: bool, world_position: Vector3) -> void:
	spawn_damage_number(amount, is_critical, world_position)
	spawn_hit_flash(world_position, is_critical)


func spawn_damage_number(amount: int, is_critical: bool, world_position: Vector3) -> void:
	_ensure_root()
	if _world_fx_root == null:
		return
	var label: Label3D
	if _damage_pool.is_empty():
		label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.outline_size = 8
		label.font_size = 44
		_world_fx_root.add_child(label)
	else:
		label = _damage_pool.pop_back()
		label.visible = true
		label.modulate.a = 1.0
		label.scale = Vector3.ONE

	label.text = str(amount)
	if is_critical:
		label.text = "%d!" % amount
		label.modulate = Color("ffe08a")
		label.font_size = 64
		label.scale = Vector3(1.35, 1.35, 1.35)
	else:
		label.modulate = Color("ffffff")
		label.font_size = 44
		label.scale = Vector3.ONE

	var side := randf_range(-0.35, 0.35)
	label.global_position = world_position + Vector3(side, 1.35, 0)
	var peak := label.global_position + Vector3(side * 0.4, 1.55, 0)
	var end := peak + Vector3(side * 0.2, 0.35, 0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "global_position", peak, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "scale", Vector3.ONE * (1.15 if is_critical else 1.0), 0.12)
	tw.chain().tween_property(label, "global_position", end, 0.35).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.35)
	tw.chain().tween_callback(func():
		label.visible = false
		label.modulate.a = 1.0
		label.scale = Vector3.ONE
		_damage_pool.append(label)
	)


func spawn_hit_flash(world_position: Vector3, critical: bool = false) -> void:
	_ensure_root()
	if _world_fx_root == null:
		return
	var flash := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.42 if critical else 0.24
	sphere.height = sphere.radius * 2.0
	flash.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffe08a") if critical else Color(1, 1, 1, 0.95)
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mat.emission_energy_multiplier = 2.8 if critical else 1.6
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash.material_override = mat
	_world_fx_root.add_child(flash)
	flash.global_position = world_position + Vector3(0, 1.0, 0)
	var tw := create_tween()
	tw.tween_property(flash, "scale", Vector3.ONE * (2.2 if critical else 1.7), 0.14)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.14)
	tw.tween_callback(flash.queue_free)

	# Slash streaks for crit
	if critical:
		for i in 3:
			var streak := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(0.08, 0.08, 0.9)
			streak.mesh = box
			var sm := StandardMaterial3D.new()
			sm.albedo_color = Color("ffe6a0")
			sm.emission_enabled = true
			sm.emission = Color("ffc040")
			sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			streak.material_override = sm
			_world_fx_root.add_child(streak)
			streak.global_position = world_position + Vector3(0, 1.0, 0)
			streak.rotation = Vector3(randf_range(-0.6, 0.6), randf_range(0, TAU), randf_range(-0.4, 0.4))
			var st := create_tween()
			st.tween_property(streak, "scale", Vector3(0.2, 0.2, 1.6), 0.12)
			st.parallel().tween_property(sm, "albedo_color:a", 0.0, 0.12)
			st.tween_callback(streak.queue_free)


func spawn_death_burst(world_position: Vector3, color: Color = Color("ffe08a")) -> void:
	_ensure_root()
	if _world_fx_root == null:
		return
	for i in 6:
		var p := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.12
		s.height = 0.24
		p.mesh = s
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		p.material_override = mat
		_world_fx_root.add_child(p)
		p.global_position = world_position + Vector3(0, 0.8, 0)
		var dir := Vector3(randf_range(-1, 1), randf_range(0.4, 1.2), randf_range(-1, 1)).normalized()
		var tw := create_tween()
		tw.tween_property(p, "global_position", p.global_position + dir * randf_range(0.8, 1.6), 0.35)
		tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.35)
		tw.tween_callback(p.queue_free)


func spawn_level_up() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	spawn_hit_flash(player.global_position + Vector3(0, 0.5, 0), true)
	_ensure_root()
	if _world_fx_root == null:
		return
	var ring := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.35
	cyl.bottom_radius = 0.35
	cyl.height = 0.08
	ring.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffd76a")
	mat.emission_enabled = true
	mat.emission = Color("ffc040")
	mat.emission_energy_multiplier = 3.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = mat
	_world_fx_root.add_child(ring)
	ring.global_position = player.global_position + Vector3(0, 0.12, 0)
	var tw := create_tween()
	tw.tween_property(cyl, "top_radius", 2.8, 0.5)
	tw.parallel().tween_property(cyl, "bottom_radius", 2.8, 0.5)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.5)
	tw.tween_callback(ring.queue_free)
	spawn_death_burst(player.global_position, Color("ffe08a"))


func spawn_quest_complete() -> void:
	spawn_level_up()


func spawn_loot_pickup(world_position: Vector3) -> void:
	spawn_hit_flash(world_position, false)
	spawn_death_burst(world_position, Color("e0b34a"))


func spawn_swing(origin: Vector3, facing: Vector3) -> void:
	_ensure_root()
	if _world_fx_root == null:
		return
	var arc := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.4, 0.08, 0.35)
	arc.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.55)
	mat.emission_enabled = true
	mat.emission = Color("fff2c8")
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arc.material_override = mat
	_world_fx_root.add_child(arc)
	arc.global_position = origin + facing * 1.0 + Vector3(0, 1.0, 0)
	if facing.length_squared() > 0.001:
		arc.look_at(arc.global_position + facing, Vector3.UP)
	var tw := create_tween()
	tw.tween_property(arc, "scale", Vector3(1.3, 1.0, 0.4), 0.1)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.12)
	tw.tween_callback(arc.queue_free)
