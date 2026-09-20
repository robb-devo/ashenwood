class_name EnemyDef
extends RefCounted

var id: StringName
var name: String
var max_hp: int = 30
var damage: int = 5
var move_speed: float = 3.5
var detect_range: float = 8.0
var attack_range: float = 1.6
var attack_cooldown: float = 1.1
var xp_reward: int = 12
var gold_min: int = 2
var gold_max: int = 6
var body_color: Color = Color("5a8f4a")
var scale: float = 1.0
var elite: bool = false
## Array of { "item_id": StringName, "chance": float, "qty": int }
var loot_table: Array = []
