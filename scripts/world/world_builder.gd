class_name WorldBuilder
extends Node3D
## Builds the Milestone 2 vertical-slice map:
## Ashenwood Village + Whispering Woods + Old Cemetery.

const PropFactoryScript = preload("res://scripts/world/prop_factory.gd")
const NpcScene = preload("res://scenes/npcs/npc.tscn")

enum Zone { VILLAGE, FOREST, CEMETERY }


func _ready() -> void:
	_build_ground_zones()
	_build_village()
	_build_forest()
	_build_cemetery()
	_build_npcs()
	_build_boundary()
	_build_zone_labels()


func _build_npcs() -> void:
	_spawn_npc(&"elder", "Village Elder", Vector3(2.5, 0.0, -8.5), Color("7a8f6a"))
	_spawn_npc(&"blacksmith", "Blacksmith", Vector3(-8.5, 0.0, -2.5), Color("8a6a4a"))
	_spawn_npc(&"merchant", "Merchant", Vector3(8.8, 0.0, -1.8), Color("4a6a8a"))


func _spawn_npc(id: StringName, label: String, pos: Vector3, color: Color) -> void:
	var npc := NpcScene.instantiate()
	npc.npc_id = id
	npc.display_name = label
	npc.body_color = color
	add_child(npc)
	npc.global_position = pos


func _build_ground_zones() -> void:
	# Shared base
	var base := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(160.0, 160.0)
	base.mesh = plane
	base.material_override = PropFactoryScript.make_material(Color("2a332c"), 0.97)
	add_child(base)

	_ground_patch(Vector3(0, 0.01, 2), Vector2(46, 40), GameConfig.COLOR_GROUND_VILLAGE)
	_ground_patch(Vector3(0, 0.015, -42), Vector2(50, 48), Color("243528")) # forest
	_ground_patch(Vector3(42, 0.015, -8), Vector2(46, 46), Color("2a2c30")) # cemetery


func _ground_patch(position: Vector3, size: Vector2, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	mesh_instance.mesh = plane
	mesh_instance.material_override = PropFactoryScript.make_material(color, 0.95)
	mesh_instance.position = position
	add_child(mesh_instance)


func _build_village() -> void:
	var village := Node3D.new()
	village.name = "AshenwoodVillage"
	add_child(village)

	# Plaza
	var plaza := MeshInstance3D.new()
	var disk := CylinderMesh.new()
	disk.top_radius = 8.5
	disk.bottom_radius = 8.5
	disk.height = 0.08
	plaza.mesh = disk
	plaza.material_override = PropFactoryScript.make_material(Color("4a5c42"), 0.92)
	plaza.position = Vector3(0.0, 0.03, 0.0)
	village.add_child(plaza)

	# Paths: south entrance, north to forest, east to cemetery
	village.add_child(PropFactoryScript.box(Vector3(3.2, 0.06, 18.0), GameConfig.COLOR_PATH, Vector3(0.0, 0.0, 12.0)))
	village.add_child(PropFactoryScript.box(Vector3(3.2, 0.06, 34.0), GameConfig.COLOR_PATH, Vector3(0.0, 0.0, -18.0)))
	village.add_child(PropFactoryScript.box(Vector3(34.0, 0.06, 3.0), GameConfig.COLOR_PATH, Vector3(16.0, 0.0, -2.0)))
	village.add_child(PropFactoryScript.box(Vector3(18.0, 0.06, 3.0), GameConfig.COLOR_PATH, Vector3(-8.0, 0.0, 0.0)))

	_add_building(village, "Blacksmith", Vector3(-10.0, 0.0, -4.0), Vector3(6.0, 4.0, 5.0), Color("6a4f3d"))
	_add_building(village, "GeneralShop", Vector3(10.0, 0.0, -3.5), Vector3(5.5, 3.6, 5.0), Color("5f5548"))
	_add_building(village, "ElderHall", Vector3(0.0, 0.0, -10.5), Vector3(7.0, 4.4, 5.5), Color("5a4a40"))
	_add_building(village, "CottageA", Vector3(-11.0, 0.0, 6.5), Vector3(4.5, 3.2, 4.2), Color("6b5a48"))
	_add_building(village, "CottageB", Vector3(11.0, 0.0, 7.0), Vector3(4.8, 3.3, 4.4), Color("645548"))
	_add_building(village, "Storehouse", Vector3(-4.5, 0.0, 11.5), Vector3(4.0, 2.8, 3.6), Color("5c5044"))

	# Fence ring (gap north + east for exits)
	for x in range(-16, 17, 2):
		if abs(x) < 3:
			continue
		village.add_child(PropFactoryScript.box(Vector3(0.2, 1.0, 0.2), GameConfig.COLOR_WOOD, Vector3(float(x), 0.0, -18.0)))
		village.add_child(PropFactoryScript.box(Vector3(1.8, 0.15, 0.12), GameConfig.COLOR_WOOD, Vector3(float(x) + 0.9, 0.55, -18.0)))

	village.add_child(PropFactoryScript.cylinder(0.35, 0.8, Color("6a4a2e"), Vector3(-7.2, 0.0, -1.5)))
	village.add_child(PropFactoryScript.cylinder(0.35, 0.8, Color("6a4a2e"), Vector3(-6.4, 0.0, -1.8)))
	village.add_child(PropFactoryScript.box(Vector3(0.8, 0.8, 0.8), Color("7a6548"), Vector3(7.5, 0.0, -1.2)))
	village.add_child(PropFactoryScript.box(Vector3(0.9, 0.7, 0.7), Color("6f5d45"), Vector3(8.4, 0.0, -1.6)))

	_add_lamp(village, Vector3(-3.5, 0.0, 3.0))
	_add_lamp(village, Vector3(3.5, 0.0, 3.0))
	_add_lamp(village, Vector3(-3.5, 0.0, -3.0))
	_add_lamp(village, Vector3(3.5, 0.0, -3.0))

	village.add_child(PropFactoryScript.box(Vector3(1.4, 0.7, 1.1), Color("5a5a58"), Vector3(-5.5, 0.0, 16.0)))
	village.add_child(PropFactoryScript.box(Vector3(1.0, 0.55, 0.9), Color("4f4f4d"), Vector3(5.8, 0.0, 15.5)))
	for pos in [Vector3(-8.0, 0.35, 2.0), Vector3(8.2, 0.35, 2.4), Vector3(-2.0, 0.3, 9.5), Vector3(2.4, 0.3, 9.2)]:
		village.add_child(PropFactoryScript.sphere(0.55, GameConfig.COLOR_FOLIAGE, pos))

	_add_campfire(village, Vector3(0.0, 0.0, 2.5))

	# Village trees (softer ring)
	for spot in [
		Vector3(-16, 0, -8), Vector3(-18, 0, 2), Vector3(-15, 0, 12),
		Vector3(16, 0, 3), Vector3(15, 0, 13), Vector3(-7, 0, 18), Vector3(7, 0, 18),
	]:
		_add_tree(village, spot, 1.0)

	_add_label(village, "Blacksmith", Vector3(-10.0, 5.2, -4.0))
	_add_label(village, "Shop", Vector3(10.0, 4.8, -3.5))
	_add_label(village, "Elder", Vector3(0.0, 5.6, -10.5))
	_add_label(village, "To Woods", Vector3(0.0, 3.2, -20.0))
	_add_label(village, "To Cemetery", Vector3(20.0, 3.2, -2.0))


func _build_forest() -> void:
	var forest := Node3D.new()
	forest.name = "WhisperingWoods"
	add_child(forest)

	# Clearings + denser canopy
	_ground_patch_local(forest, Vector3(-6, 0.04, -40), Vector2(10, 8), Color("2f4034"))
	_ground_patch_local(forest, Vector3(8, 0.04, -50), Vector2(9, 7), Color("314336"))

	var tree_spots := [
		Vector3(-10, 0, -28), Vector3(8, 0, -27), Vector3(-14, 0, -34), Vector3(12, 0, -33),
		Vector3(-6, 0, -36), Vector3(4, 0, -38), Vector3(-16, 0, -44), Vector3(14, 0, -45),
		Vector3(-3, 0, -46), Vector3(7, 0, -48), Vector3(-12, 0, -52), Vector3(10, 0, -54),
		Vector3(-18, 0, -38), Vector3(18, 0, -40), Vector3(-8, 0, -58), Vector3(5, 0, -57),
		Vector3(0, 0, -62), Vector3(-15, 0, -56), Vector3(16, 0, -50), Vector3(-4, 0, -30),
		Vector3(3, 0, -32), Vector3(-20, 0, -48), Vector3(20, 0, -46),
	]
	for spot in tree_spots:
		_add_tree(forest, spot, 1.15)

	# Rocks / bushes / spawn clearings
	for rock in [Vector3(-5, 0, -35), Vector3(6, 0, -43), Vector3(-9, 0, -50), Vector3(11, 0, -39)]:
		forest.add_child(PropFactoryScript.box(Vector3(1.3, 0.8, 1.1), Color("4d524c"), rock))
	for bush in [Vector3(-2, 0.35, -33), Vector3(3, 0.35, -41), Vector3(-7, 0.35, -47), Vector3(9, 0.3, -55)]:
		forest.add_child(PropFactoryScript.sphere(0.7, Color("1f3a28"), bush))

	# Soft ambient lights in clearings
	_add_zone_light(forest, Vector3(-6, 3.5, -40), Color("7aa889"), 0.55, 12.0)
	_add_zone_light(forest, Vector3(8, 3.5, -50), Color("6f9a7d"), 0.5, 11.0)

	_add_label(forest, "Whispering Woods", Vector3(0.0, 5.0, -42.0))


func _build_cemetery() -> void:
	var cemetery := Node3D.new()
	cemetery.name = "OldCemetery"
	add_child(cemetery)

	# Broken fence perimeter
	for z in range(-24, 13, 3):
		cemetery.add_child(PropFactoryScript.box(Vector3(0.18, 1.1, 0.18), Color("3c3c3a"), Vector3(28.0, 0.0, float(z))))
		if z % 6 != 0:
			cemetery.add_child(PropFactoryScript.box(Vector3(0.12, 0.8, 2.2), Color("454542"), Vector3(28.0, 0.35, float(z) + 1.2)))
	for x in range(28, 58, 3):
		cemetery.add_child(PropFactoryScript.box(Vector3(0.18, 1.0, 0.18), Color("3c3c3a"), Vector3(float(x), 0.0, -24.0)))
		cemetery.add_child(PropFactoryScript.box(Vector3(0.18, 1.0, 0.18), Color("3c3c3a"), Vector3(float(x), 0.0, 12.0)))

	# Gravestones
	var graves := [
		Vector3(34, 0, -6), Vector3(38, 0, -10), Vector3(42, 0, -4), Vector3(46, 0, -12),
		Vector3(36, 0, 2), Vector3(44, 0, 0), Vector3(50, 0, -8), Vector3(40, 0, -16),
		Vector3(48, 0, -18), Vector3(52, 0, -2), Vector3(33, 0, -14), Vector3(55, 0, -14),
	]
	for g in graves:
		_add_gravestone(cemetery, g)

	# Dead trees
	for spot in [Vector3(32, 0, -20), Vector3(54, 0, -20), Vector3(56, 0, 6), Vector3(30, 0, 8), Vector3(49, 0, 8)]:
		_add_dead_tree(cemetery, spot)

	# Ruins + lanterns
	cemetery.add_child(PropFactoryScript.box(Vector3(4.5, 2.2, 3.5), Color("4a4744"), Vector3(46.0, 0.0, -6.0)))
	cemetery.add_child(PropFactoryScript.box(Vector3(2.2, 1.4, 1.8), Color("3f3c39"), Vector3(48.5, 0.0, -4.2)))
	_add_lantern(cemetery, Vector3(36.0, 0.0, -2.0), Color("9ab6ff"), 0.9)
	_add_lantern(cemetery, Vector3(50.0, 0.0, -10.0), Color("8aa4ef"), 0.85)
	_add_lantern(cemetery, Vector3(42.0, 0.0, 4.0), Color("7f99e0"), 0.8)

	# Foggy cool fill light
	_add_zone_light(cemetery, Vector3(44, 4.0, -6), Color("6e7ea0"), 0.7, 16.0)

	_add_label(cemetery, "Old Cemetery", Vector3(44.0, 5.2, -6.0))


func _build_boundary() -> void:
	var thickness := 2.5
	var height := 5.0
	# Expanded playable rectangle covering village + forest + cemetery
	var min_x := -30.0
	var max_x := 62.0
	var min_z := -68.0
	var max_z := 24.0
	var cx := (min_x + max_x) * 0.5
	var cz := (min_z + max_z) * 0.5
	var sx := max_x - min_x
	var sz := max_z - min_z
	add_child(PropFactoryScript.invisible_wall(Vector3(sx + 4.0, height, thickness), Vector3(cx, 0.0, min_z)))
	add_child(PropFactoryScript.invisible_wall(Vector3(sx + 4.0, height, thickness), Vector3(cx, 0.0, max_z)))
	add_child(PropFactoryScript.invisible_wall(Vector3(thickness, height, sz + 4.0), Vector3(min_x, 0.0, cz)))
	add_child(PropFactoryScript.invisible_wall(Vector3(thickness, height, sz + 4.0), Vector3(max_x, 0.0, cz)))


func _build_zone_labels() -> void:
	pass


func _add_building(parent: Node3D, building_name: String, position: Vector3, size: Vector3, wall_color: Color) -> void:
	var building := Node3D.new()
	building.name = building_name
	building.position = position
	parent.add_child(building)
	building.add_child(PropFactoryScript.box(size, wall_color))
	building.add_child(PropFactoryScript.box(Vector3(size.x + 0.6, 0.7, size.z + 0.6), GameConfig.COLOR_ROOF, Vector3(0.0, size.y, 0.0)))
	building.add_child(PropFactoryScript.box(Vector3(1.1, 1.8, 0.15), Color("2c2118"), Vector3(0.0, 0.0, size.z * 0.5 + 0.05)))


func _add_tree(parent: Node3D, position: Vector3, scale_factor: float = 1.0) -> void:
	var tree := Node3D.new()
	tree.position = position
	parent.add_child(tree)
	tree.add_child(PropFactoryScript.cylinder(0.35 * scale_factor, 2.2 * scale_factor, Color("5a4030")))
	tree.add_child(PropFactoryScript.sphere(1.55 * scale_factor, GameConfig.COLOR_FOLIAGE, Vector3(0.0, 3.0 * scale_factor, 0.0)))


func _add_dead_tree(parent: Node3D, position: Vector3) -> void:
	var tree := Node3D.new()
	tree.position = position
	parent.add_child(tree)
	tree.add_child(PropFactoryScript.cylinder(0.28, 3.2, Color("3a322c")))
	tree.add_child(PropFactoryScript.box(Vector3(1.8, 0.25, 0.25), Color("332c26"), Vector3(0.6, 2.6, 0.0)))
	tree.add_child(PropFactoryScript.box(Vector3(1.2, 0.2, 0.2), Color("332c26"), Vector3(-0.5, 2.2, 0.2)))


func _add_gravestone(parent: Node3D, position: Vector3) -> void:
	var grave := Node3D.new()
	grave.position = position
	parent.add_child(grave)
	grave.add_child(PropFactoryScript.box(Vector3(0.7, 1.1, 0.22), Color("5a5a58")))
	grave.add_child(PropFactoryScript.box(Vector3(0.9, 0.18, 0.35), Color("4d4d4b"), Vector3(0.0, 0.0, 0.0)))


func _add_lamp(parent: Node3D, position: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.position = position
	parent.add_child(lamp)
	lamp.add_child(PropFactoryScript.cylinder(0.08, 1.6, GameConfig.COLOR_WOOD, Vector3.ZERO, false))
	lamp.add_child(PropFactoryScript.sphere(0.22, Color("e8c56a"), Vector3(0.0, 1.7, 0.0)))
	var light := OmniLight3D.new()
	light.light_color = Color("ffc878")
	light.light_energy = 1.1
	light.omni_range = 5.5
	light.position = Vector3(0.0, 1.7, 0.0)
	lamp.add_child(light)


func _add_lantern(parent: Node3D, position: Vector3, color: Color, energy: float) -> void:
	var lantern := Node3D.new()
	lantern.position = position
	parent.add_child(lantern)
	lantern.add_child(PropFactoryScript.cylinder(0.07, 1.5, Color("2d2d2b"), Vector3.ZERO, false))
	lantern.add_child(PropFactoryScript.sphere(0.2, color, Vector3(0.0, 1.55, 0.0)))
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 7.0
	light.position = Vector3(0.0, 1.55, 0.0)
	lantern.add_child(light)


func _add_campfire(parent: Node3D, position: Vector3) -> void:
	var fire := Node3D.new()
	fire.name = "Campfire"
	fire.position = position
	parent.add_child(fire)
	fire.add_child(PropFactoryScript.cylinder(0.7, 0.25, Color("3a3a38"), Vector3.ZERO, false))
	fire.add_child(PropFactoryScript.sphere(0.35, GameConfig.COLOR_FIRE, Vector3(0.0, 0.55, 0.0)))
	var light := OmniLight3D.new()
	light.light_color = GameConfig.COLOR_FIRE
	light.light_energy = 2.0
	light.omni_range = 8.0
	light.position = Vector3(0.0, 0.8, 0.0)
	fire.add_child(light)


func _add_zone_light(parent: Node3D, position: Vector3, color: Color, energy: float, range_m: float) -> void:
	var light := OmniLight3D.new()
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_m
	parent.add_child(light)


func _add_label(parent: Node3D, text: String, position: Vector3) -> void:
	var anchor := Node3D.new()
	anchor.position = position
	parent.add_child(anchor)
	var label := Label3D.new()
	label.text = text
	label.font_size = 48
	label.modulate = Color(0.92, 0.88, 0.78, 0.9)
	label.outline_modulate = Color(0.05, 0.05, 0.05, 0.85)
	label.outline_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	anchor.add_child(label)


func _ground_patch_local(parent: Node3D, position: Vector3, size: Vector2, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	mesh_instance.mesh = plane
	mesh_instance.material_override = PropFactoryScript.make_material(color, 0.95)
	mesh_instance.position = position
	parent.add_child(mesh_instance)
