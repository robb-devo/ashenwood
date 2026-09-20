class_name ItemDef
extends RefCounted

enum Slot { NONE, WEAPON, HELMET, CHEST, GLOVES, BOOTS }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
enum Kind { EQUIPMENT, CONSUMABLE, CURRENCY }
enum WeaponType { NONE, SWORD, BOW, WAND }

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
var weapon_type: WeaponType = WeaponType.NONE
var attack_speed: float = 1.0
var attack_range: float = 2.2
var projectile_speed: float = 14.0
var rarity_stat_mult: float = 1.0


static func rarity_color(r: Rarity) -> Color:
	match r:
		Rarity.COMMON: return Color("a8a59c")
		Rarity.UNCOMMON: return Color("5faf6e")
		Rarity.RARE: return Color("5a9ad4")
		Rarity.EPIC: return Color("a78be0")
		Rarity.LEGENDARY: return Color("e0b14a")
	return Color.WHITE


static func rarity_name(r: Rarity) -> String:
	match r:
		Rarity.COMMON: return "Common"
		Rarity.UNCOMMON: return "Uncommon"
		Rarity.RARE: return "Rare"
		Rarity.EPIC: return "Epic"
		Rarity.LEGENDARY: return "Legendary"
	return "Common"


static func rarity_multiplier(r: Rarity) -> float:
	match r:
		Rarity.COMMON: return 1.0
		Rarity.UNCOMMON: return 1.12
		Rarity.RARE: return 1.25
		Rarity.EPIC: return 1.4
		Rarity.LEGENDARY: return 1.6
	return 1.0
