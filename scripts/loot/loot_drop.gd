class_name LootDrop
extends Area3D
## Walk-over pickup for gold / items.

var gold_amount: int = 0
var item_id: StringName = &""
var item_qty: int = 1
var _life: float = 45.0


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
	sphere.radius = 0.7
	shape.shape = sphere
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.22
	sm.height = 0.44
	mesh.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("e0b34a") if gold_amount > 0 else Color("7ec8ff")
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mesh.material_override = mat
	add_child(mesh)


func _process(delta: float) -> void:
	rotate_y(delta * 2.5)
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if gold_amount > 0:
		GameState.add_gold(gold_amount)
	elif item_id != &"":
		GameState.add_item_by_id(item_id, item_qty)
	AudioService.play_sfx(&"loot_pickup")
	VfxService.spawn_loot_pickup(global_position)
	queue_free()
