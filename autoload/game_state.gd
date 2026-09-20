extends Node
## Runtime player progression / combat stats. Equipment bonuses applied here.

signal stats_changed

const ItemDefScript = preload("res://scripts/data/item_def.gd")
const InventoryItemScript = preload("res://scripts/data/inventory_item.gd")

var level: int = 1
var xp: int = 0
var gold: int = 0
var hp: int = 100

var base_max_hp: int = 100
var base_attack: int = 8
var base_defense: int = 2
var base_crit_chance: float = 0.05
var base_crit_damage: float = 0.5

var inventory: Array = [] # InventoryItem
var equipment: Dictionary = {
	ItemDefScript.Slot.WEAPON: null,
	ItemDefScript.Slot.HELMET: null,
	ItemDefScript.Slot.CHEST: null,
	ItemDefScript.Slot.GLOVES: null,
	ItemDefScript.Slot.BOOTS: null,
}

var position: Vector3 = Vector3(0, 0, 4)
var _uid_counter: int = 1


func _ready() -> void:
	position = GameConfig.VILLAGE_SPAWN
	_grant_starter_loadout()
	hp = get_max_hp()
	stats_changed.emit()


func _grant_starter_loadout() -> void:
	if not inventory.is_empty():
		return
	gold = 50
	var sword := _make_item(&"rusty_sword")
	var tunic := _make_item(&"traveler_tunic")
	var boots := _make_item(&"traveler_boots")
	inventory.append(sword)
	inventory.append(tunic)
	inventory.append(boots)
	inventory.append(_make_item(&"health_vial", 3))
	equip_uid(sword.uid)
	equip_uid(tunic.uid)
	equip_uid(boots.uid)


func _make_item(item_id: StringName, qty: int = 1) -> InventoryItem:
	var item := InventoryItemScript.new()
	item.item_id = item_id
	item.quantity = qty
	item.upgrade_level = 0
	item.uid = "i%d" % _uid_counter
	_uid_counter += 1
	return item


func xp_to_next_level(at_level: int = -1) -> int:
	var lv := level if at_level < 0 else at_level
	return 40 + (lv - 1) * 35


func get_max_hp() -> int:
	return base_max_hp + _equip_sum("max_hp") + (level - 1) * 12


func get_attack() -> int:
	return base_attack + _equip_sum("attack") + (level - 1) * 2


func get_defense() -> int:
	return base_defense + _equip_sum("defense") + (level - 1)


func get_crit_chance() -> float:
	return clampf(base_crit_chance + _equip_sum_f("crit_chance"), 0.0, 0.75)


func get_crit_damage() -> float:
	return base_crit_damage + _equip_sum_f("crit_damage")


func _equip_sum(stat: String) -> int:
	var total := 0
	for slot in equipment.keys():
		var inv_item: InventoryItem = equipment[slot]
		if inv_item == null:
			continue
		var def: ItemDef = ContentDB.get_item(inv_item.item_id)
		if def == null:
			continue
		var value: int = int(def.get(stat))
		total += value + inv_item.upgrade_level * _upgrade_bonus(stat)
	return total


func _equip_sum_f(stat: String) -> float:
	var total := 0.0
	for slot in equipment.keys():
		var inv_item: InventoryItem = equipment[slot]
		if inv_item == null:
			continue
		var def: ItemDef = ContentDB.get_item(inv_item.item_id)
		if def == null:
			continue
		total += float(def.get(stat))
	return total


func _upgrade_bonus(stat: String) -> int:
	match stat:
		"attack": return 2
		"defense": return 1
		"max_hp": return 4
	return 0


func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	xp += amount
	EventBus.player_xp_changed.emit(xp, xp_to_next_level())
	while xp >= xp_to_next_level():
		xp -= xp_to_next_level()
		level += 1
		base_max_hp += 12
		base_attack += 2
		base_defense += 1
		hp = get_max_hp()
		EventBus.player_leveled_up.emit(level)
		AudioService.play_sfx(&"level_up")
		VfxService.spawn_level_up()
	stats_changed.emit()
	EventBus.player_xp_changed.emit(xp, xp_to_next_level())


func add_gold(amount: int) -> void:
	gold = max(0, gold + amount)
	EventBus.player_gold_changed.emit(gold)
	stats_changed.emit()


func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	add_gold(-amount)
	return true


func heal(amount: int) -> void:
	hp = mini(get_max_hp(), hp + amount)
	stats_changed.emit()


func apply_damage(raw: int) -> int:
	var mitigated: int = maxi(1, raw - get_defense())
	hp = maxi(0, hp - mitigated)
	stats_changed.emit()
	if hp <= 0:
		EventBus.player_died.emit()
	return mitigated


func is_alive() -> bool:
	return hp > 0


func respawn() -> void:
	hp = get_max_hp()
	position = GameConfig.VILLAGE_SPAWN
	stats_changed.emit()
	EventBus.player_respawned.emit()


func find_item_by_uid(uid: String) -> InventoryItem:
	for item in inventory:
		if item.uid == uid:
			return item
	return null


func add_item_by_id(item_id: StringName, qty: int = 1) -> void:
	var def: ItemDef = ContentDB.get_item(item_id)
	if def == null:
		return
	if def.stackable:
		for item in inventory:
			if item.item_id == item_id:
				item.quantity += qty
				EventBus.inventory_changed.emit()
				EventBus.loot_collected.emit(item_id, qty)
				return
		var stack := _make_item(item_id, qty)
		inventory.append(stack)
	else:
		for _i in qty:
			inventory.append(_make_item(item_id, 1))
	EventBus.inventory_changed.emit()
	EventBus.loot_collected.emit(item_id, qty)


func equip_uid(uid: String) -> bool:
	var item := find_item_by_uid(uid)
	if item == null:
		return false
	var def: ItemDef = ContentDB.get_item(item.item_id)
	if def == null or def.kind != ItemDefScript.Kind.EQUIPMENT:
		return false
	if level < def.level_req:
		return false
	var previous: InventoryItem = equipment[def.slot]
	equipment[def.slot] = item
	EventBus.equipment_changed.emit()
	stats_changed.emit()
	# Keep previous in inventory (already there). previous unused intentionally.
	if previous:
		pass
	return true


func unequip_slot(slot: int) -> void:
	equipment[slot] = null
	EventBus.equipment_changed.emit()
	stats_changed.emit()


func upgrade_uid(uid: String) -> bool:
	var item := find_item_by_uid(uid)
	if item == null:
		return false
	var def: ItemDef = ContentDB.get_item(item.item_id)
	if def == null or def.kind != ItemDefScript.Kind.EQUIPMENT:
		return false
	var cost := def.upgrade_cost_base + item.upgrade_level * def.upgrade_cost_base
	if not spend_gold(cost):
		return false
	item.upgrade_level += 1
	EventBus.equipment_changed.emit()
	EventBus.inventory_changed.emit()
	stats_changed.emit()
	AudioService.play_sfx(&"upgrade")
	return true


func upgrade_preview(uid: String) -> Dictionary:
	var item := find_item_by_uid(uid)
	if item == null:
		return {}
	var def: ItemDef = ContentDB.get_item(item.item_id)
	if def == null:
		return {}
	var cost := def.upgrade_cost_base + item.upgrade_level * def.upgrade_cost_base
	return {
		"name": def.name,
		"level": item.upgrade_level,
		"next_level": item.upgrade_level + 1,
		"attack": def.attack + item.upgrade_level * 2,
		"attack_next": def.attack + (item.upgrade_level + 1) * 2,
		"defense": def.defense + item.upgrade_level * 1,
		"defense_next": def.defense + (item.upgrade_level + 1) * 1,
		"cost": cost,
	}


func use_consumable_uid(uid: String) -> bool:
	var item := find_item_by_uid(uid)
	if item == null:
		return false
	var def: ItemDef = ContentDB.get_item(item.item_id)
	if def == null or def.kind != ItemDefScript.Kind.CONSUMABLE:
		return false
	heal(maxi(20, def.max_hp))
	item.quantity -= 1
	if item.quantity <= 0:
		inventory.erase(item)
	EventBus.inventory_changed.emit()
	stats_changed.emit()
	return true


func use_first_consumable(item_id: StringName) -> bool:
	for item in inventory:
		if item.item_id == item_id:
			return use_consumable_uid(item.uid)
	return false


func to_save_dict() -> Dictionary:
	var inv: Array = []
	for item in inventory:
		inv.append(item.to_dict())
	var eq: Dictionary = {}
	for slot in equipment.keys():
		var it: InventoryItem = equipment[slot]
		eq[str(slot)] = it.uid if it else ""
	return {
		"level": level,
		"xp": xp,
		"gold": gold,
		"hp": hp,
		"base_max_hp": base_max_hp,
		"base_attack": base_attack,
		"base_defense": base_defense,
		"inventory": inv,
		"equipment": eq,
		"uid_counter": _uid_counter,
		"position": {"x": position.x, "y": position.y, "z": position.z},
	}


func load_save_dict(data: Dictionary) -> void:
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	gold = int(data.get("gold", 0))
	base_max_hp = int(data.get("base_max_hp", 100))
	base_attack = int(data.get("base_attack", 8))
	base_defense = int(data.get("base_defense", 2))
	hp = int(data.get("hp", get_max_hp()))
	_uid_counter = int(data.get("uid_counter", 1))
	inventory.clear()
	for entry in data.get("inventory", []):
		inventory.append(InventoryItemScript.from_dict(entry))
	for slot in equipment.keys():
		equipment[slot] = null
	var eq: Dictionary = data.get("equipment", {})
	for slot_key in eq.keys():
		var uid := str(eq[slot_key])
		if uid.is_empty():
			continue
		equipment[int(slot_key)] = find_item_by_uid(uid)
	var pos: Dictionary = data.get("position", {})
	position = Vector3(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)), float(pos.get("z", 4.0)))
	stats_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.equipment_changed.emit()
	EventBus.player_gold_changed.emit(gold)
	EventBus.player_xp_changed.emit(xp, xp_to_next_level())
