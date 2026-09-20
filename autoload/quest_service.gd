extends Node
## Quest progress + rewards.

var active_quest_id: StringName = &""
var progress: int = 0
var completed: Dictionary = {} # StringName -> true


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.npc_interact_requested.connect(_on_npc_interact)
	if active_quest_id == &"":
		start_quest(&"welcome")


func start_quest(quest_id: StringName) -> void:
	var def = ContentDB.get_quest(quest_id)
	if def == null:
		return
	active_quest_id = quest_id
	progress = 0
	EventBus.quest_started.emit(quest_id)
	EventBus.quest_updated.emit(quest_id)


func get_tracker_text() -> String:
	if active_quest_id == &"":
		return "All quests complete"
	var def = ContentDB.get_quest(active_quest_id)
	if def == null:
		return ""
	if def.objective_type == def.ObjectiveType.TALK:
		return "%s\nTalk to the Village Elder" % def.title
	return "%s\n%d / %d" % [def.title, progress, def.target_count]


func _on_enemy_died(enemy_id: StringName, _pos: Vector3) -> void:
	var def = ContentDB.get_quest(active_quest_id)
	if def == null or def.objective_type != def.ObjectiveType.KILL:
		return
	if def.target_id != enemy_id:
		return
	progress = mini(def.target_count, progress + 1)
	EventBus.quest_updated.emit(active_quest_id)
	if progress >= def.target_count:
		_complete_active()


func _on_npc_interact(npc_id: StringName) -> void:
	var def = ContentDB.get_quest(active_quest_id)
	if def == null or def.objective_type != def.ObjectiveType.TALK:
		return
	if def.target_id != npc_id:
		return
	progress = 1
	EventBus.quest_updated.emit(active_quest_id)
	_complete_active()


func _complete_active() -> void:
	var def = ContentDB.get_quest(active_quest_id)
	if def == null:
		return
	var done_id := active_quest_id
	completed[done_id] = true
	GameState.add_xp(def.xp_reward)
	GameState.add_gold(def.gold_reward)
	if def.item_reward_id != &"":
		GameState.add_item_by_id(def.item_reward_id, 1)
	AudioService.play_sfx(&"quest_complete")
	VfxService.spawn_quest_complete()
	EventBus.quest_completed.emit(done_id)
	active_quest_id = &""
	progress = 0
	if def.next_quest_id != &"":
		start_quest(def.next_quest_id)


func to_save_dict() -> Dictionary:
	return {
		"active_quest_id": String(active_quest_id),
		"progress": progress,
		"completed": completed.keys().map(func(k): return String(k)),
	}


func load_save_dict(data: Dictionary) -> void:
	completed.clear()
	for id in data.get("completed", []):
		completed[StringName(str(id))] = true
	active_quest_id = StringName(str(data.get("active_quest_id", "")))
	progress = int(data.get("progress", 0))
	if active_quest_id == &"" and not completed.has(&"welcome"):
		start_quest(&"welcome")
	elif active_quest_id != &"":
		EventBus.quest_updated.emit(active_quest_id)
