class_name PlayerVisualBuilder
extends RefCounted
## Stylized fantasy wanderer + equippable weapon mesh.


static func build(parent: Node3D) -> void:
	_clear(parent)
	var shadow := _disc(0.55, 0.04, Color(0, 0, 0, 0.35))
	shadow.position = Vector3(0, 0.02, 0)
	parent.add_child(shadow)
	parent.add_child(_box(Vector3(0.22, 0.18, 0.34), Color("3a2a22"), Vector3(-0.16, 0.09, 0.04)))
	parent.add_child(_box(Vector3(0.22, 0.18, 0.34), Color("3a2a22"), Vector3(0.16, 0.09, 0.04)))
	parent.add_child(_box(Vector3(0.2, 0.42, 0.24), Color("2c3540"), Vector3(-0.15, 0.38, 0.0)))
	parent.add_child(_box(Vector3(0.2, 0.42, 0.24), Color("2c3540"), Vector3(0.15, 0.38, 0.0)))
	parent.add_child(_box(Vector3(0.62, 0.7, 0.36), Color("4e6a58"), Vector3(0.0, 0.92, 0.0)))
	parent.add_child(_box(Vector3(0.42, 0.34, 0.12), Color("c2a46a"), Vector3(0.0, 1.0, 0.2)))
	parent.add_child(_box(Vector3(0.66, 0.1, 0.38), Color("5a4030"), Vector3(0.0, 0.62, 0.0)))
	parent.add_child(_box(Vector3(0.22, 0.18, 0.28), Color("6b7f6a"), Vector3(-0.4, 1.18, 0.0)))
	parent.add_child(_box(Vector3(0.22, 0.18, 0.28), Color("6b7f6a"), Vector3(0.4, 1.18, 0.0)))
	parent.add_child(_box(Vector3(0.16, 0.46, 0.16), Color("d7b07a"), Vector3(-0.42, 0.88, 0.05)))
	parent.add_child(_box(Vector3(0.16, 0.46, 0.16), Color("d7b07a"), Vector3(0.42, 0.88, 0.05)))
	parent.add_child(_box(Vector3(0.7, 0.85, 0.08), Color("2a3d4a"), Vector3(0.0, 0.95, -0.24)))
	parent.add_child(_sphere(0.24, Color("e0b892"), Vector3(0.0, 1.55, 0.04)))
	parent.add_child(_sphere(0.27, Color("3d4f45"), Vector3(0.0, 1.62, -0.02)))
	parent.add_child(_box(Vector3(0.42, 0.16, 0.34), Color("3d4f45"), Vector3(0.0, 1.48, -0.02)))
	var weapon_root := Node3D.new()
	weapon_root.name = "WeaponRoot"
	weapon_root.position = Vector3(0.42, 0.85, 0.18)
	parent.add_child(weapon_root)


static func set_weapon(parent: Node3D, wdef: ItemDef) -> void:
	var root := parent.get_node_or_null("WeaponRoot") as Node3D
	if root == null:
		return
	for c in root.get_children():
		c.queue_free()
	if wdef == null:
		return
	var ItemDefScript = preload("res://scripts/data/item_def.gd")
	match wdef.weapon_type:
		ItemDefScript.WeaponType.BOW:
			root.add_child(_box(Vector3(0.08, 0.55, 0.08), wdef.icon_color, Vector3(0, 0.1, 0)))
			root.add_child(_box(Vector3(0.06, 0.06, 0.45), Color("d8c8a0"), Vector3(0.05, 0.1, 0.1)))
		ItemDefScript.WeaponType.WAND:
			root.add_child(_box(Vector3(0.07, 0.07, 0.7), wdef.icon_color, Vector3(0, 0, 0.15)))
			root.add_child(_sphere(0.12, Color("ffaa55"), Vector3(0, 0, 0.5)))
		_:
			root.add_child(_box(Vector3(0.08, 0.08, 0.72), wdef.icon_color, Vector3(0, 0, 0.2)))
			root.add_child(_box(Vector3(0.22, 0.06, 0.08), Color("b08d4e"), Vector3(0, 0, -0.12)))
			root.add_child(_box(Vector3(0.07, 0.07, 0.16), Color("5a4030"), Vector3(0, 0, -0.28)))


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
