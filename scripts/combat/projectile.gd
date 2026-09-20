class_name Projectile
extends Area3D
## Simple ranged projectile for bow / wand.

var velocity: Vector3 = Vector3.ZERO
var damage: int = 1
var is_critical: bool = false
var lifetime: float = 1.6
var owner_player: Node = null
var color: Color = Color.WHITE


func setup(from: Vector3, dir: Vector3, dmg: int, crit: bool, speed: float, tint: Color, source: Node) -> void:
	global_position = from
	velocity = dir.normalized() * speed
	damage = dmg
	is_critical = crit
	color = tint
	owner_player = source


func _ready() -> void:
	collision_layer = 32
	collision_mask = 4 # enemies
	monitoring = true
	body_entered.connect(_on_body)
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.4
	mesh.material_override = mat
	add_child(mesh)
	var shape := CollisionShape3D.new()
	var s := SphereShape3D.new()
	s.radius = 0.2
	shape.shape = s
	add_child(shape)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body(body: Node) -> void:
	if body == owner_player:
		return
	if body.is_in_group("enemies") and body.has_method("apply_damage"):
		body.apply_damage(damage, is_critical)
		if body.has_method("apply_knockback"):
			body.apply_knockback(velocity.normalized() * 3.5)
		VfxService.spawn_hit_flash(global_position, is_critical)
		queue_free()
