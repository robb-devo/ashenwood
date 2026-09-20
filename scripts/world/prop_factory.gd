class_name PropFactory
extends RefCounted
## Builds lightweight placeholder meshes with consistent materials.
## Replace meshes later without rewriting world layout code.


static func make_material(color: Color, roughness: float = 0.85) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = 0.0
	return mat


static func box(size: Vector3, color: Color, position: Vector3 = Vector3.ZERO) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = position

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = make_material(color)
	mesh_instance.position = Vector3(0.0, size.y * 0.5, 0.0)
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = mesh_instance.position
	body.add_child(collision)
	return body


static func cylinder(radius: float, height: float, color: Color, position: Vector3 = Vector3.ZERO, collidable: bool = true) -> Node3D:
	var root: Node3D
	if collidable:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		root = body
		var collision := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		collision.shape = shape
		collision.position = Vector3(0.0, height * 0.5, 0.0)
		body.add_child(collision)
	else:
		root = Node3D.new()

	root.position = position
	var mesh_instance := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	mesh_instance.mesh = cyl
	mesh_instance.material_override = make_material(color)
	mesh_instance.position = Vector3(0.0, height * 0.5, 0.0)
	root.add_child(mesh_instance)
	return root


static func sphere(radius: float, color: Color, position: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	mesh_instance.mesh = sphere_mesh
	mesh_instance.material_override = make_material(color, 0.7)
	mesh_instance.position = position
	return mesh_instance


static func invisible_wall(size: Vector3, position: Vector3 = Vector3.ZERO) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = position
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = Vector3(0.0, size.y * 0.5, 0.0)
	body.add_child(collision)
	return body
