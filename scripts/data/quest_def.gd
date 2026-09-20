class_name QuestDef
extends RefCounted

enum ObjectiveType { TALK, KILL }

var id: StringName
var title: String
var description: String
var objective_type: ObjectiveType = ObjectiveType.TALK
var target_id: StringName = &""
var target_count: int = 1
var xp_reward: int = 20
var gold_reward: int = 15
var item_reward_id: StringName = &""
var next_quest_id: StringName = &""
