class_name NpcInteractable
extends Area3D
## Walk close + interact button.

@export var npc_id: StringName = &"elder"
@export var display_name: String = "NPC"
@export var body_color: Color = Color("6b8f71")

var player_in_range: bool = false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	monitoring = true
	body_entered.connect(func(b):
		if b.is_in_group("player"):
			player_in_range = true
			_set_prompt(true)
	)
	body_exited.connect(func(b):
		if b.is_in_group("player"):
			player_in_range = false
			_set_prompt(false)
	)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.2
	shape.shape = sphere
	add_child(shape)
	_build_visual()
	add_to_group("npcs")


func _build_visual() -> void:
	var body := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.4
	mesh.height = 1.5
	body.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = body_color
	body.material_override = mat
	body.position = Vector3(0, 0.75, 0)
	add_child(body)
	var label := Label3D.new()
	label.text = display_name
	label.font_size = 40
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 2.0, 0)
	add_child(label)
	# Solid collision so player can't walk through
	var solid := StaticBody3D.new()
	solid.collision_layer = 1
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.5
	col.shape = cap
	col.position = Vector3(0, 0.75, 0)
	solid.add_child(col)
	add_child(solid)


func _set_prompt(show: bool) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_interact_prompt"):
		hud.set_interact_prompt(show, display_name)


func try_interact() -> void:
	if not player_in_range:
		return
	var lines: PackedStringArray = ContentDB.npc_dialogue.get(npc_id, PackedStringArray(["..."]))
	EventBus.dialogue_requested.emit(npc_id, lines)
	EventBus.npc_interact_requested.emit(npc_id)
	AudioService.play_ui(&"ui_click")
	if npc_id == &"blacksmith":
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("open_upgrade_from_blacksmith"):
			hud.open_upgrade_from_blacksmith()
	elif npc_id == &"merchant":
		if GameState.spend_gold(15):
			GameState.add_item_by_id(&"health_vial", 1)
			AudioService.play_sfx(&"loot_pickup")
