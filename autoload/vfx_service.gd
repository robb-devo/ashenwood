extends Node
## Lightweight pooled VFX for mobile.

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
		label.outline_size = 6
		label.font_size = 42
		_world_fx_root.add_child(label)
	else:
		label = _damage_pool.pop_back()
		label.visible = true
	label.text = str(amount)
	label.modulate = Color("ffd76a") if is_critical else Color("ffffff")
	label.font_size = 56 if is_critical else 42
	label.global_position = world_position + Vector3(0, 1.4, 0)
	var tween := create_tween()
	tween.tween_property(label, "global_position", label.global_position + Vector3(0, 1.2, 0), 0.55)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.55)
	tween.tween_callback(func():
		label.visible = false
		label.modulate.a = 1.0
		_damage_pool.append(label)
	)


func spawn_hit_flash(world_position: Vector3, critical: bool = false) -> void:
	_ensure_root()
	if _world_fx_root == null:
		return
	var flash := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.35 if critical else 0.22
	sphere.height = sphere.radius * 2.0
	flash.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffe08a") if critical else Color("ffffff")
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = mat
	_world_fx_root.add_child(flash)
	flash.global_position = world_position + Vector3(0, 1.0, 0)
	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector3.ONE * 1.8, 0.18)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.18)
	tween.tween_callback(flash.queue_free)


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
	cyl.top_radius = 0.4
	cyl.bottom_radius = 0.4
	cyl.height = 0.08
	ring.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffd76a")
	mat.emission_enabled = true
	mat.emission = Color("ffc040")
	mat.emission_energy_multiplier = 2.5
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = mat
	_world_fx_root.add_child(ring)
	ring.global_position = player.global_position + Vector3(0, 0.15, 0)
	var tw := create_tween()
	tw.tween_property(cyl, "top_radius", 2.4, 0.55)
	tw.parallel().tween_property(cyl, "bottom_radius", 2.4, 0.55)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.55)
	tw.tween_callback(ring.queue_free)


func spawn_quest_complete() -> void:
	spawn_level_up()


func spawn_loot_pickup(world_position: Vector3) -> void:
	spawn_hit_flash(world_position, false)
