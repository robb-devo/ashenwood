extends Node
## Data-driven content registry. Swap values later without rewriting systems.

const ItemDefScript = preload("res://scripts/data/item_def.gd")
const EnemyDefScript = preload("res://scripts/data/enemy_def.gd")
const QuestDefScript = preload("res://scripts/data/quest_def.gd")

var items: Dictionary = {} # StringName -> ItemDef
var enemies: Dictionary = {} # StringName -> EnemyDef
var quests: Dictionary = {} # StringName -> QuestDef
var npc_dialogue: Dictionary = {} # StringName -> PackedStringArray


func _ready() -> void:
	_register_items()
	_register_enemies()
	_register_quests()
	_register_dialogue()


func get_item(id: StringName) -> ItemDef:
	return items.get(id) as ItemDef


func get_enemy(id: StringName) -> EnemyDef:
	return enemies.get(id) as EnemyDef


func get_quest(id: StringName) -> QuestDef:
	return quests.get(id) as QuestDef


func _add_item(def: ItemDef) -> void:
	items[def.id] = def


func _item(id: String, name: String, slot: int, rarity: int, level: int, atk: int, defn: int, hp: int, cost: int, desc: String, color: Color, ranged: bool = false) -> void:
	var d := ItemDefScript.new()
	d.id = StringName(id)
	d.name = name
	d.description = desc
	d.kind = ItemDefScript.Kind.EQUIPMENT
	d.slot = slot
	d.rarity = rarity
	d.level_req = level
	d.attack = atk
	d.defense = defn
	d.max_hp = hp
	d.upgrade_cost_base = cost
	d.icon_color = color
	d.is_ranged = ranged
	if slot == ItemDefScript.Slot.WEAPON:
		d.crit_chance = 0.05
		d.crit_damage = 0.35
	_add_item(d)


func _register_items() -> void:
	var S = ItemDefScript
	_item("rusty_sword", "Rusty Sword", S.Slot.WEAPON, S.Rarity.COMMON, 1, 6, 0, 0, 20, "A worn blade. Better than fists.", Color("8a7a5a"))
	_item("iron_sword", "Iron Sword", S.Slot.WEAPON, S.Rarity.UNCOMMON, 3, 12, 0, 0, 40, "Reliable iron edge.", Color("9aa0a8"))
	_item("steel_sword", "Steel Sword", S.Slot.WEAPON, S.Rarity.RARE, 5, 20, 0, 0, 70, "Sharp steel from the Ashenwood forge.", Color("c0c8d4"))
	_item("hunter_bow", "Hunter Bow", S.Slot.WEAPON, S.Rarity.UNCOMMON, 4, 14, 0, 0, 45, "Ranged frame ready for future arrows.", Color("6b8f4e"), true)
	_item("fire_wand", "Fire Wand", S.Slot.WEAPON, S.Rarity.RARE, 6, 18, 0, 0, 80, "Warm ember core. Ranged-ready.", Color("e07040"), true)

	_item("cloth_hood", "Cloth Hood", S.Slot.HELMET, S.Rarity.COMMON, 1, 0, 1, 5, 15, "Simple traveler cloth.", Color("6d5a48"))
	_item("leather_hood", "Leather Hood", S.Slot.HELMET, S.Rarity.UNCOMMON, 3, 0, 3, 12, 30, "Stitched forest leather.", Color("5a4030"))
	_item("iron_helmet", "Iron Helmet", S.Slot.HELMET, S.Rarity.RARE, 5, 0, 6, 20, 55, "Heavy protection.", Color("7a8088"))

	_item("traveler_tunic", "Traveler Tunic", S.Slot.CHEST, S.Rarity.COMMON, 1, 0, 2, 10, 20, "Comfortable starting armor.", Color("4a5c4a"))
	_item("leather_armor", "Leather Armor", S.Slot.CHEST, S.Rarity.UNCOMMON, 3, 0, 5, 25, 45, "Quiet and flexible.", Color("4a3828"))
	_item("iron_armor", "Iron Armor", S.Slot.CHEST, S.Rarity.RARE, 5, 0, 10, 40, 75, "Clanking but sturdy.", Color("6e747c"))

	_item("traveler_gloves", "Traveler Gloves", S.Slot.GLOVES, S.Rarity.COMMON, 1, 1, 1, 0, 12, "Light hand wraps.", Color("6a5848"))
	_item("leather_gloves", "Leather Gloves", S.Slot.GLOVES, S.Rarity.UNCOMMON, 3, 2, 2, 0, 28, "Grip for the blade.", Color("523828"))
	_item("iron_gauntlets", "Iron Gauntlets", S.Slot.GLOVES, S.Rarity.RARE, 5, 4, 4, 5, 50, "Crushing fists.", Color("777d85"))

	_item("traveler_boots", "Traveler Boots", S.Slot.BOOTS, S.Rarity.COMMON, 1, 0, 1, 5, 12, "Dusty but whole.", Color("5c4a38"))
	_item("leather_boots", "Leather Boots", S.Slot.BOOTS, S.Rarity.UNCOMMON, 3, 0, 3, 10, 28, "Quiet steps.", Color("4a3424"))
	_item("iron_boots", "Iron Boots", S.Slot.BOOTS, S.Rarity.RARE, 5, 0, 5, 15, 50, "Heavy tread.", Color("6f757d"))

	var potion := ItemDefScript.new()
	potion.id = &"health_vial"
	potion.name = "Health Vial"
	potion.description = "Restores a small amount of HP."
	potion.kind = ItemDefScript.Kind.CONSUMABLE
	potion.rarity = ItemDefScript.Rarity.COMMON
	potion.stackable = true
	potion.max_hp = 40
	potion.icon_color = Color("d45454")
	_add_item(potion)


func _enemy(id: String, name: String, hp: int, dmg: int, spd: float, detect: float, atk_r: float, cd: float, xp: int, gmin: int, gmax: int, color: Color, scale: float, elite: bool, loot: Array) -> void:
	var e := EnemyDefScript.new()
	e.id = StringName(id)
	e.name = name
	e.max_hp = hp
	e.damage = dmg
	e.move_speed = spd
	e.detect_range = detect
	e.attack_range = atk_r
	e.attack_cooldown = cd
	e.xp_reward = xp
	e.gold_min = gmin
	e.gold_max = gmax
	e.body_color = color
	e.scale = scale
	e.elite = elite
	e.loot_table = loot
	enemies[e.id] = e


func _register_enemies() -> void:
	_enemy("forest_slime", "Forest Slime", 28, 4, 2.6, 7.0, 1.4, 1.2, 10, 2, 5, Color("4f9a55"), 0.85, false, [
		{"item_id": "health_vial", "chance": 0.18, "qty": 1},
		{"item_id": "cloth_hood", "chance": 0.06, "qty": 1},
	])
	_enemy("wolf", "Wolf", 42, 7, 4.4, 9.0, 1.5, 0.95, 18, 4, 9, Color("6a5a4e"), 1.0, false, [
		{"item_id": "leather_hood", "chance": 0.08, "qty": 1},
		{"item_id": "leather_boots", "chance": 0.07, "qty": 1},
		{"item_id": "health_vial", "chance": 0.2, "qty": 1},
	])
	_enemy("skeleton", "Skeleton", 55, 9, 3.2, 8.5, 1.7, 1.05, 26, 6, 12, Color("cfc6b4"), 1.05, false, [
		{"item_id": "iron_sword", "chance": 0.05, "qty": 1},
		{"item_id": "iron_helmet", "chance": 0.05, "qty": 1},
		{"item_id": "health_vial", "chance": 0.22, "qty": 1},
	])
	_enemy("gravekeeper", "Gravekeeper", 160, 16, 3.0, 11.0, 2.0, 1.25, 80, 25, 45, Color("3d4a58"), 1.35, true, [
		{"item_id": "steel_sword", "chance": 0.35, "qty": 1},
		{"item_id": "iron_armor", "chance": 0.25, "qty": 1},
		{"item_id": "health_vial", "chance": 0.5, "qty": 2},
	])


func _quest(id: String, title: String, desc: String, otype: int, target: String, count: int, xp: int, gold: int, item: String, next_id: String) -> void:
	var q := QuestDefScript.new()
	q.id = StringName(id)
	q.title = title
	q.description = desc
	q.objective_type = otype
	q.target_id = StringName(target)
	q.target_count = count
	q.xp_reward = xp
	q.gold_reward = gold
	q.item_reward_id = StringName(item)
	q.next_quest_id = StringName(next_id)
	quests[q.id] = q


func _register_quests() -> void:
	var Q = QuestDefScript
	_quest("welcome", "Welcome to Ashenwood", "Talk to the Village Elder near the hall.", Q.ObjectiveType.TALK, "elder", 1, 25, 20, "traveler_gloves", "into_woods")
	_quest("into_woods", "Into the Woods", "Kill 5 Forest Slimes in the Whispering Woods.", Q.ObjectiveType.KILL, "forest_slime", 5, 60, 40, "leather_hood", "wolves_gate")
	_quest("wolves_gate", "Wolves at the Gate", "Kill 3 Wolves stalking the forest paths.", Q.ObjectiveType.KILL, "wolf", 3, 90, 60, "iron_sword", "restless_dead")
	_quest("restless_dead", "The Restless Dead", "Kill 5 Skeletons in the Old Cemetery.", Q.ObjectiveType.KILL, "skeleton", 5, 140, 90, "iron_helmet", "gravekeeper")
	_quest("gravekeeper", "The Gravekeeper", "Defeat the Gravekeeper.", Q.ObjectiveType.KILL, "gravekeeper", 1, 250, 200, "steel_sword", "")


func _register_dialogue() -> void:
	npc_dialogue[&"elder"] = PackedStringArray([
		"Welcome to Ashenwood, wanderer.",
		"The woods grow restless, and the cemetery no longer sleeps.",
		"Clear the threats, and the village will arm you well.",
	])
	npc_dialogue[&"blacksmith"] = PackedStringArray([
		"Got steel and scars enough for both of us.",
		"Bring gold. I'll temper your gear.",
	])
	npc_dialogue[&"merchant"] = PackedStringArray([
		"Supplies, odds, and ends.",
		"I'll sell you a Health Vial for 15 gold when we talk.",
		"Survive the woods and spend freely.",
	])
