class_name VillageBuilder
extends Node3D
## Handcrafted Ashenwood Village layout (Milestone 1).
## Composition guides the player toward forest / cemetery exits later.

const PropFactoryScript = preload("res://scripts/world/prop_factory.gd")


func _ready() -> void:
	_build_ground()
	_build_paths()
	_build_buildings()
	_build_fences()
	_build_props()
	_build_trees()
	_build_campfire()
	_build_boundary()
	_build_labels()


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(90.0, 90.0)
	ground.mesh = plane
	ground.material_override = PropFactoryScript.make_material(GameConfig.COLOR_GROUND_VILLAGE, 0.95)
	add_child(ground)

	# Soft village "plaza" disk
	var plaza := MeshInstance3D.new()
	var disk := CylinderMesh.new()
	disk.top_radius = 8.5
	disk.bottom_radius = 8.5
	disk.height = 0.08
	plaza.mesh = disk
	plaza.material_override = PropFactoryScript.make_material(Color("4a5c42"), 0.92)
	plaza.position = Vector3(0.0, 0.02, 0.0)
	add_child(plaza)


func _build_paths() -> void:
	# North path toward future forest
	add_child(PropFactoryScript.box(Vector3(3.2, 0.06, 28.0), GameConfig.COLOR_PATH, Vector3(0.0, 0.0, -12.0)))
	# South entrance path
	add_child(PropFactoryScript.box(Vector3(3.2, 0.06, 16.0), GameConfig.COLOR_PATH, Vector3(0.0, 0.0, 14.0)))
	# East / west cross path
	add_child(PropFactoryScript.box(Vector3(26.0, 0.06, 3.0), GameConfig.COLOR_PATH, Vector3(0.0, 0.0, 0.0)))


func _build_buildings() -> void:
	_add_building("Blacksmith", Vector3(-10.0, 0.0, -4.0), Vector3(6.0, 4.0, 5.0), Color("6a4f3d"))
	_add_building("General Shop", Vector3(10.0, 0.0, -3.5), Vector3(5.5, 3.6, 5.0), Color("5f5548"))
	_add_building("Elder Hall", Vector3(0.0, 0.0, -10.5), Vector3(7.0, 4.4, 5.5), Color("5a4a40"))
	_add_building("Cottage A", Vector3(-11.0, 0.0, 6.5), Vector3(4.5, 3.2, 4.2), Color("6b5a48"))
	_add_building("Cottage B", Vector3(11.0, 0.0, 7.0), Vector3(4.8, 3.3, 4.4), Color("645548"))
	_add_building("Storehouse", Vector3(-4.5, 0.0, 11.5), Vector3(4.0, 2.8, 3.6), Color("5c5044"))


func _add_building(building_name: String, position: Vector3, size: Vector3, wall_color: Color) -> void:
	var building := Node3D.new()
	building.name = building_name
	building.position = position
	add_child(building)

	building.add_child(PropFactoryScript.box(size, wall_color))
	# Roof
	var roof := PropFactoryScript.box(Vector3(size.x + 0.6, 0.7, size.z + 0.6), GameConfig.COLOR_ROOF, Vector3(0.0, size.y, 0.0))
	building.add_child(roof)
	# Door marker
	var door := PropFactoryScript.box(Vector3(1.1, 1.8, 0.15), Color("2c2118"), Vector3(0.0, 0.0, size.z * 0.5 + 0.05))
	building.add_child(door)


func _build_fences() -> void:
	# Soft perimeter toward woods
	for x in range(-16, 17, 2):
		if abs(x) < 3:
			continue
		add_child(PropFactoryScript.box(Vector3(0.2, 1.0, 0.2), GameConfig.COLOR_WOOD, Vector3(float(x), 0.0, -18.0)))
		add_child(PropFactoryScript.box(Vector3(1.8, 0.15, 0.12), GameConfig.COLOR_WOOD, Vector3(float(x) + 0.9, 0.55, -18.0)))


func _build_props() -> void:
	# Barrels / crates near blacksmith and shop
	add_child(PropFactoryScript.cylinder(0.35, 0.8, Color("6a4a2e"), Vector3(-7.2, 0.0, -1.5)))
	add_child(PropFactoryScript.cylinder(0.35, 0.8, Color("6a4a2e"), Vector3(-6.4, 0.0, -1.8)))
	add_child(PropFactoryScript.box(Vector3(0.8, 0.8, 0.8), Color("7a6548"), Vector3(7.5, 0.0, -1.2)))
	add_child(PropFactoryScript.box(Vector3(0.9, 0.7, 0.7), Color("6f5d45"), Vector3(8.4, 0.0, -1.6)))
	# Lamps
	_add_lamp(Vector3(-3.5, 0.0, 3.0))
	_add_lamp(Vector3(3.5, 0.0, 3.0))
	_add_lamp(Vector3(-3.5, 0.0, -3.0))
	_add_lamp(Vector3(3.5, 0.0, -3.0))
	# Rocks near entrance
	add_child(PropFactoryScript.box(Vector3(1.4, 0.7, 1.1), Color("5a5a58"), Vector3(-5.5, 0.0, 16.0)))
	add_child(PropFactoryScript.box(Vector3(1.0, 0.55, 0.9), Color("4f4f4d"), Vector3(5.8, 0.0, 15.5)))
	# Bushes
	for pos in [Vector3(-8.0, 0.35, 2.0), Vector3(8.2, 0.35, 2.4), Vector3(-2.0, 0.3, 9.5), Vector3(2.4, 0.3, 9.2)]:
		add_child(PropFactoryScript.sphere(0.55, GameConfig.COLOR_FOLIAGE, pos))


func _add_lamp(position: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.position = position
	add_child(lamp)
	lamp.add_child(PropFactoryScript.cylinder(0.08, 1.6, GameConfig.COLOR_WOOD, Vector3.ZERO, false))
	var glow := PropFactoryScript.sphere(0.22, Color("e8c56a"), Vector3(0.0, 1.7, 0.0))
	lamp.add_child(glow)
	var light := OmniLight3D.new()
	light.light_color = Color("ffc878")
	light.light_energy = 1.1
	light.omni_range = 5.5
	light.position = Vector3(0.0, 1.7, 0.0)
	lamp.add_child(light)


func _build_trees() -> void:
	var tree_spots := [
		Vector3(-16, 0, -8), Vector3(-18, 0, 2), Vector3(-15, 0, 12),
		Vector3(16, 0, -7), Vector3(18, 0, 3), Vector3(15, 0, 13),
		Vector3(-12, 0, -16), Vector3(12, 0, -16), Vector3(0, 0, -20),
		Vector3(-20, 0, -14), Vector3(20, 0, -12), Vector3(-7, 0, 18),
		Vector3(7, 0, 18), Vector3(-22, 0, 8), Vector3(22, 0, 6),
	]
	for spot in tree_spots:
		_add_tree(spot)


func _add_tree(position: Vector3) -> void:
	var tree := Node3D.new()
	tree.position = position
	add_child(tree)
	tree.add_child(PropFactoryScript.cylinder(0.35, 2.2, Color("5a4030")))
	var canopy := PropFactoryScript.sphere(1.6, GameConfig.COLOR_FOLIAGE, Vector3(0.0, 3.1, 0.0))
	tree.add_child(canopy)
	# Simple collision for trunk already included via cylinder StaticBody


func _build_campfire() -> void:
	var fire := Node3D.new()
	fire.name = "Campfire"
	fire.position = Vector3(0.0, 0.0, 2.5)
	add_child(fire)
	fire.add_child(PropFactoryScript.cylinder(0.7, 0.25, Color("3a3a38"), Vector3.ZERO, false))
	fire.add_child(PropFactoryScript.sphere(0.35, GameConfig.COLOR_FIRE, Vector3(0.0, 0.55, 0.0)))
	var light := OmniLight3D.new()
	light.light_color = GameConfig.COLOR_FIRE
	light.light_energy = 2.0
	light.omni_range = 8.0
	light.position = Vector3(0.0, 0.8, 0.0)
	fire.add_child(light)


func _build_boundary() -> void:
	# Invisible walls so player stays in the village slice for Milestone 1.
	var thickness := 2.0
	var height := 4.0
	var half := 28.0
	add_child(PropFactoryScript.invisible_wall(Vector3(half * 2.0, height, thickness), Vector3(0.0, 0.0, -half)))
	add_child(PropFactoryScript.invisible_wall(Vector3(half * 2.0, height, thickness), Vector3(0.0, 0.0, half)))
	add_child(PropFactoryScript.invisible_wall(Vector3(thickness, height, half * 2.0), Vector3(-half, 0.0, 0.0)))
	add_child(PropFactoryScript.invisible_wall(Vector3(thickness, height, half * 2.0), Vector3(half, 0.0, 0.0)))


func _build_labels() -> void:
	# Subtle floating markers for key buildings (readable on phone).
	_add_label("Blacksmith", Vector3(-10.0, 5.2, -4.0))
	_add_label("Shop", Vector3(10.0, 4.8, -3.5))
	_add_label("Elder", Vector3(0.0, 5.6, -10.5))


func _add_label(text: String, position: Vector3) -> void:
	var anchor := Node3D.new()
	anchor.position = position
	add_child(anchor)
	var label := Label3D.new()
	label.text = text
	label.font_size = 48
	label.modulate = Color(0.92, 0.88, 0.78, 0.9)
	label.outline_modulate = Color(0.05, 0.05, 0.05, 0.85)
	label.outline_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	anchor.add_child(label)
