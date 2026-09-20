class_name ItemDef
extends RefCounted

enum Slot { NONE, WEAPON, HELMET, CHEST, GLOVES, BOOTS }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
enum Kind { EQUIPMENT, CONSUMABLE, CURRENCY }

var id: StringName
var name: String
var description: String
var kind: Kind = Kind.EQUIPMENT
var slot: Slot = Slot.NONE
var rarity: Rarity = Rarity.COMMON
var level_req: int = 1
var attack: int = 0
var defense: int = 0
var max_hp: int = 0
var crit_chance: float = 0.0
var crit_damage: float = 0.0
var upgrade_cost_base: int = 25
var icon_color: Color = Color.WHITE
var stackable: bool = false
var is_ranged: bool = false


static func rarity_color(r: Rarity) -> Color:
	match r:
		Rarity.COMMON: return Color("b0b0b0")
		Rarity.UNCOMMON: return Color("4caf66")
		Rarity.RARE: return Color("4a90e2")
		Rarity.EPIC: return Color("9b59d0")
		Rarity.LEGENDARY: return Color("e0a23a")
	return Color.WHITE


static func rarity_name(r: Rarity) -> String:
	match r:
		Rarity.COMMON: return "Common"
		Rarity.UNCOMMON: return "Uncommon"
		Rarity.RARE: return "Rare"
		Rarity.EPIC: return "Epic"
		Rarity.LEGENDARY: return "Legendary"
	return "Common"
