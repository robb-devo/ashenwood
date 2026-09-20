extends Node
## Versioned local save. Auto-saves on key events + timer.

const SAVE_PATH := "user://ashenwood_save_v1.json"
const SAVE_VERSION := 1

var _auto_timer: float = 0.0


func _ready() -> void:
	EventBus.save_requested.connect(save_game)
	EventBus.load_requested.connect(load_game)
	EventBus.player_leveled_up.connect(func(_l): save_game())
	EventBus.quest_completed.connect(func(_q): save_game())
	EventBus.equipment_changed.connect(func(): save_game())
	load_game()


func _process(delta: float) -> void:
	_auto_timer += delta
	if _auto_timer >= 20.0:
		_auto_timer = 0.0
		save_game()


func save_game() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player:
		GameState.position = player.global_position
	var payload := {
		"version": SAVE_VERSION,
		"player": GameState.to_save_dict(),
		"quests": QuestService.to_save_dict(),
		"settings": {
			"music": AudioService.music_volume,
			"sfx": AudioService.sfx_volume,
			"vibration": AudioService.vibration_enabled,
		},
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		EventBus.save_completed.emit(false)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	EventBus.save_completed.emit(true)


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	var version := int(data.get("version", 1))
	if version > SAVE_VERSION:
		push_warning("Save version newer than game; loading best-effort.")
	if data.has("player"):
		GameState.load_save_dict(data["player"])
	if data.has("quests"):
		QuestService.load_save_dict(data["quests"])
	if data.has("settings"):
		var s: Dictionary = data["settings"]
		AudioService.set_music_volume(float(s.get("music", 0.8)))
		AudioService.set_sfx_volume(float(s.get("sfx", 1.0)))
		AudioService.set_vibration_enabled(bool(s.get("vibration", true)))


func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
