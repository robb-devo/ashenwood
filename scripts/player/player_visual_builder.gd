class_name PlayerVisualBuilder
extends RefCounted
## High-contrast stylized wanderer — readable from high phone camera.


static func build(parent: Node3D) -> void:
	_clear(parent)
	# Selection ring under feet (cool blue so not confused with fire)
	var ring := _disc(0.9, 0.05, Color(0.45, 0.85, 1.0, 0.5))
	ring.position = Vector3(0, 0.03, 0)
	parent.add_child(ring)
	var shadow := _disc(0.72, 0.03, Color(0, 0, 0, 0.45))
	shadow.position = Vector3(0, 0.015, 0)
	parent.add_child(shadow)

	# Wide footprint so top-down still reads as a character, not a coin
	parent.add_child(_box(Vector3(0.28, 0.22, 0.42), Color("2a221c"), Vector3(-0.2, 0.11, 0.05)))
	parent.add_child(_box(Vector3(0.28, 0.22, 0.42), Color("2a221c"), Vector3(0.2, 0.11, 0.05)))
	parent.add_child(_box(Vector3(0.26, 0.55, 0.3), Color("1e2a38"), Vector3(-0.18, 0.48, 0.0)))
	parent.add_child(_box(Vector3(0.26, 0.55, 0.3), Color("1e2a38"), Vector3(0.18, 0.48, 0.0)))
	# Bright moss torso — large XZ for aerial readability
	parent.add_child(_box(Vector3(0.85, 0.85, 0.55), Color("4f9a5e"), Vector3(0.0, 1.05, 0.0)))
	parent.add_child(_box(Vector3(0.9, 0.14, 0.58), Color("d4a84b"), Vector3(0.0, 0.7, 0.0)))
	parent.add_child(_box(Vector3(0.5, 0.4, 0.18), Color("f0d78a"), Vector3(0.0, 1.1, 0.28)))
	# Arms
	parent.add_child(_box(Vector3(0.2, 0.55, 0.2), Color("e8c4a0"), Vector3(-0.55, 1.0, 0.05)))
	parent.add_child(_box(Vector3(0.2, 0.55, 0.2), Color("e8c4a0"), Vector3(0.55, 1.0, 0.05)))
	parent.add_child(_box(Vector3(0.28, 0.22, 0.32), Color("3d6a48"), Vector3(-0.55, 1.3, 0.0)))
	parent.add_child(_box(Vector3(0.28, 0.22, 0.32), Color("3d6a48"), Vector3(0.55, 1.3, 0.0)))
	# Cape silhouette
	parent.add_child(_box(Vector3(0.95, 1.05, 0.14), Color("163040"), Vector3(0.0, 1.0, -0.34)))
	# Head + hood (slightly oversized)
	parent.add_child(_sphere(0.32, Color("f0c8a8"), Vector3(0.0, 1.72, 0.08)))
	parent.add_child(_sphere(0.36, Color("2a4034"), Vector3(0.0, 1.8, -0.04)))
	parent.add_child(_box(Vector3(0.55, 0.2, 0.42), Color("2a4034"), Vector3(0.0, 1.58, -0.02)))

	var weapon_root := Node3D.new()
	weapon_root.name = "WeaponRoot"
	weapon_root.position = Vector3(0.55, 0.95, 0.22)
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
			root.add_child(_box(Vector3(0.12, 0.75, 0.12), wdef.icon_color, Vector3(0, 0.15, 0)))
			root.add_child(_box(Vector3(0.1, 0.1, 0.65), Color("d8c8a0"), Vector3(0.08, 0.15, 0.15)))
		ItemDefScript.WeaponType.WAND:
			root.add_child(_box(Vector3(0.11, 0.11, 0.95), wdef.icon_color, Vector3(0, 0, 0.2)))
			root.add_child(_sphere(0.16, Color("ffaa55"), Vector3(0, 0, 0.65)))
		_:
			root.add_child(_box(Vector3(0.12, 0.12, 1.0), wdef.icon_color, Vector3(0, 0, 0.28)))
			root.add_child(_box(Vector3(0.32, 0.1, 0.12), Color("b08d4e"), Vector3(0, 0, -0.16)))
			root.add_child(_box(Vector3(0.11, 0.11, 0.24), Color("5a4030"), Vector3(0, 0, -0.36)))


static func _clear(parent: Node3D) -> void:
	for c in parent.get_children():
		c.queue_free()


static func _mat(color: Color, rough: float = 0.7) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	if color.a < 0.99:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.emission_enabled = true
	m.emission = Color(color.r, color.g, color.b) * 0.15
	m.emission_energy_multiplier = 0.55
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
	mi.material_override = _mat(color, 0.62)
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
