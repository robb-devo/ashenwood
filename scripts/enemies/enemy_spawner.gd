class_name EnemySpawner
extends Node3D
## Places enemy encounters around forest / cemetery.

const EnemyScene = preload("res://scenes/enemies/enemy.tscn")


func _ready() -> void:
	_spawn_group(&"forest_slime", [
		Vector3(-6, 0, -36), Vector3(4, 0, -40), Vector3(-2, 0, -48),
		Vector3(9, 0, -52), Vector3(-10, 0, -44), Vector3(2, 0, -56),
	])
	_spawn_group(&"wolf", [
		Vector3(-12, 0, -50), Vector3(12, 0, -46), Vector3(0, 0, -60),
	])
	_spawn_group(&"skeleton", [
		Vector3(36, 0, -8), Vector3(44, 0, -14), Vector3(50, 0, -4),
		Vector3(40, 0, 2), Vector3(52, 0, -12),
	])
	_spawn_group(&"gravekeeper", [Vector3(46, 0, -6)])


func _spawn_group(enemy_id: StringName, positions: Array) -> void:
	for pos in positions:
		var enemy := EnemyScene.instantiate()
		enemy.setup(enemy_id)
		add_child(enemy)
		enemy.global_position = pos
