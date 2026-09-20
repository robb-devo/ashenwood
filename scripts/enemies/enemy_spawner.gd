class_name EnemySpawner
extends Node3D

const EnemyScene = preload("res://scenes/enemies/enemy.tscn")

var _slots: Array[Dictionary] = []


func _ready() -> void:
	_register(&"forest_slime", [
		Vector3(-6, 0, -36), Vector3(4, 0, -40), Vector3(-2, 0, -48),
		Vector3(9, 0, -52), Vector3(-10, 0, -44), Vector3(2, 0, -56),
	])
	_register(&"wolf", [
		Vector3(-12, 0, -50), Vector3(12, 0, -46), Vector3(0, 0, -60),
	])
	_register(&"bandit", [
		Vector3(-8, 0, -42), Vector3(10, 0, -55),
	])
	_register(&"skeleton", [
		Vector3(36, 0, -8), Vector3(44, 0, -14), Vector3(50, 0, -4),
		Vector3(40, 0, 2), Vector3(52, 0, -12),
	])
	_register(&"gravekeeper", [Vector3(46, 0, -6)], false)
	for slot in _slots:
		_spawn_slot(slot)


func _process(delta: float) -> void:
	for slot in _slots:
		if slot.get("alive", false):
			continue
		if not bool(slot.get("respawn", true)):
			continue
		slot["timer"] = float(slot.get("timer", 0.0)) - delta
		if float(slot["timer"]) <= 0.0:
			_spawn_slot(slot)


func _register(enemy_id: StringName, positions: Array, respawn: bool = true) -> void:
	for pos in positions:
		_slots.append({
			"id": enemy_id,
			"pos": pos,
			"alive": false,
			"respawn": respawn,
			"timer": 0.0,
			"node": null,
		})


func _spawn_slot(slot: Dictionary) -> void:
	var enemy := EnemyScene.instantiate()
	enemy.setup(slot["id"])
	add_child(enemy)
	enemy.global_position = slot["pos"]
	slot["alive"] = true
	slot["node"] = enemy
	enemy.tree_exited.connect(func():
		slot["alive"] = false
		slot["node"] = null
		slot["timer"] = 18.0 if slot["id"] != &"gravekeeper" else 45.0
	)
