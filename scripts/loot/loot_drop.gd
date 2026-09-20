class_name LootDrop
extends Area3D
## Satisfying loot: pop, bounce, idle hover, magnet pickup.

var gold_amount: int = 0
var item_id: StringName = &""
var item_qty: int = 1
var _life: float = 45.0
var _mesh: MeshInstance3D
var _glow: MeshInstance3D
var _vel: Vector3 = Vector3.ZERO
var _ground_y: float = 0.35
var _magnetizing: bool = false
var _bob_t: float = 0.0
var _collected: bool = false


func setup_gold(amount: int) -> void:
	gold_amount = amount
	item_id = &""


func setup_item(id: StringName, qty: int = 1) -> void:
	item_id = id
	item_qty = qty
	gold_amount = 0


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.1
	shape.shape = sphere
	add_child(shape)

	var tint := Color("e0b34a")
	if item_id != &"":
		var def = ContentDB.get_item(item_id)
		tint = def.icon_color if def else Color("7ec8ff")
		if def:
			var ItemDefScript = preload("res://scripts/data/item_def.gd")
			if def.rarity >= ItemDefScript.Rarity.RARE:
				tint = ItemDefScript.rarity_color(def.rarity)

	_mesh = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.26 if gold_amount > 0 else 0.3
	sm.height = sm.radius * 2.0
	_mesh.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.emission_enabled = true
	mat.emission = tint
	mat.emission_energy_multiplier = 1.8
	_mesh.material_override = mat
	add_child(_mesh)

	_glow = MeshInstance3D.new()
	var gm := SphereMesh.new()
	gm.radius = 0.45
	gm.height = 0.9
	_glow.mesh = gm
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color(tint.r, tint.g, tint.b, 0.22)
	gmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_glow.material_override = gmat
	add_child(_glow)

	# Pop outward
	_vel = Vector3(randf_range(-2.2, 2.2), randf_range(4.5, 6.5), randf_range(-2.2, 2.2))
	scale = Vector3(0.2, 0.2, 0.2)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if _collected:
		return
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return

	rotate_y(delta * 2.8)
	_bob_t += delta

	if _magnetizing:
		var player := get_tree().get_first_node_in_group("player") as Node3D
		if player:
			var to_p := player.global_position + Vector3(0, 0.9, 0) - global_position
			global_position += to_p * clampf(12.0 * delta, 0.0, 1.0)
			if to_p.length() < 0.45:
				_collect()
		return

	# Ballistic pop then settle
	if _vel.length_squared() > 0.01 or absf(position.y - _ground_y) > 0.02:
		_vel.y -= 18.0 * delta
		global_position += _vel * delta
		if global_position.y <= _ground_y:
			global_position.y = _ground_y
			_vel.y *= -0.35
			_vel.x *= 0.6
			_vel.z *= 0.6
			if absf(_vel.y) < 1.0:
				_vel = Vector3.ZERO
				global_position.y = _ground_y
	else:
		# Idle hover
		_mesh.position.y = sin(_bob_t * 3.5) * 0.08
		_glow.scale = Vector3.ONE * (1.0 + sin(_bob_t * 4.0) * 0.08)

	# Magnet range
	var player2 := get_tree().get_first_node_in_group("player") as Node3D
	if player2 and global_position.distance_to(player2.global_position) < 2.4:
		_magnetizing = true


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_magnetizing = true


func _collect() -> void:
	if _collected:
		return
	_collected = true
	if gold_amount > 0:
		GameState.add_gold(gold_amount)
		EventBus.loot_collected.emit(&"gold", gold_amount)
	elif item_id != &"":
		GameState.add_item_by_id(item_id, item_qty)
		EventBus.loot_collected.emit(item_id, item_qty)
	AudioService.play_sfx(&"loot_pickup")
	VfxService.spawn_loot_pickup(global_position)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector3(1.4, 1.4, 1.4), 0.06)
	tw.tween_property(self, "scale", Vector3(0.05, 0.05, 0.05), 0.1)
	tw.tween_callback(queue_free)
