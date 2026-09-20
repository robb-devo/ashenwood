class_name PlayerVisualBuilder
extends RefCounted
## Builds a stylized fantasy wanderer readable from top-down.


static func build(parent: Node3D) -> void:
	_clear(parent)
	var shadow := _disc(0.55, 0.04, Color(0, 0, 0, 0.35))
	shadow.position = Vector3(0, 0.02, 0)
	parent.add_child(shadow)

	# Boots
	parent.add_child(_box(Vector3(0.22, 0.18, 0.34), Color("3a2a22"), Vector3(-0.16, 0.09, 0.04)))
	parent.add_child(_box(Vector3(0.22, 0.18, 0.34), Color("3a2a22"), Vector3(0.16, 0.09, 0.04)))
	# Legs
	parent.add_child(_box(Vector3(0.2, 0.42, 0.24), Color("2c3540"), Vector3(-0.15, 0.38, 0.0)))
	parent.add_child(_box(Vector3(0.2, 0.42, 0.24), Color("2c3540"), Vector3(0.15, 0.38, 0.0)))
	# Torso / tunic
	parent.add_child(_box(Vector3(0.62, 0.7, 0.36), Color("4e6a58"), Vector3(0.0, 0.92, 0.0)))
	# Chest plate accent
	parent.add_child(_box(Vector3(0.42, 0.34, 0.12), Color("c2a46a"), Vector3(0.0, 1.0, 0.2)))
	# Belt
	parent.add_child(_box(Vector3(0.66, 0.1, 0.38), Color("5a4030"), Vector3(0.0, 0.62, 0.0)))
	# Shoulders
	parent.add_child(_box(Vector3(0.22, 0.18, 0.28), Color("6b7f6a"), Vector3(-0.4, 1.18, 0.0)))
	parent.add_child(_box(Vector3(0.22, 0.18, 0.28), Color("6b7f6a"), Vector3(0.4, 1.18, 0.0)))
	# Arms
	parent.add_child(_box(Vector3(0.16, 0.46, 0.16), Color("d7b07a"), Vector3(-0.42, 0.88, 0.05)))
	parent.add_child(_box(Vector3(0.16, 0.46, 0.16), Color("d7b07a"), Vector3(0.42, 0.88, 0.05)))
	# Cloak
	parent.add_child(_box(Vector3(0.7, 0.85, 0.08), Color("2a3d4a"), Vector3(0.0, 0.95, -0.24)))
	# Head
	parent.add_child(_sphere(0.24, Color("e0b892"), Vector3(0.0, 1.55, 0.04)))
	# Hood
	parent.add_child(_sphere(0.27, Color("3d4f45"), Vector3(0.0, 1.62, -0.02)))
	parent.add_child(_box(Vector3(0.42, 0.16, 0.34), Color("3d4f45"), Vector3(0.0, 1.48, -0.02)))
	# Sword (right hip / forward readable)
	var sword := Node3D.new()
	sword.name = "Sword"
	sword.position = Vector3(0.42, 0.85, 0.18)
	sword.rotation_degrees = Vector3(10, 0, -18)
	parent.add_child(sword)
	sword.add_child(_box(Vector3(0.08, 0.08, 0.72), Color("c9d0d8"), Vector3(0, 0, 0.2)))
	sword.add_child(_box(Vector3(0.22, 0.06, 0.08), Color("b08d4e"), Vector3(0, 0, -0.12)))
	sword.add_child(_box(Vector3(0.07, 0.07, 0.16), Color("5a4030"), Vector3(0, 0, -0.28)))


static func _clear(parent: Node3D) -> void:
	for c in parent.get_children():
		c.queue_free()


static func _mat(color: Color, rough: float = 0.78) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	if color.a < 0.99:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


static func _box(size: Vector3, color: Color, pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color)
	mi.position = pos
	return mi


static func _sphere(radius: float, color: Color, pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.material_override = _mat(color, 0.7)
	mi.position = pos
	return mi


static func _disc(radius: float, height: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = _mat(color, 1.0)
	return mi
