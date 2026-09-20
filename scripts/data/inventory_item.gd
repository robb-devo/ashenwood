class_name InventoryItem
extends RefCounted

var item_id: StringName
var quantity: int = 1
var upgrade_level: int = 0
var uid: String = ""


func to_dict() -> Dictionary:
	return {
		"item_id": String(item_id),
		"quantity": quantity,
		"upgrade_level": upgrade_level,
		"uid": uid,
	}


static func from_dict(data: Dictionary) -> InventoryItem:
	var item := InventoryItem.new()
	item.item_id = StringName(str(data.get("item_id", "")))
	item.quantity = int(data.get("quantity", 1))
	item.upgrade_level = int(data.get("upgrade_level", 0))
	item.uid = str(data.get("uid", ""))
	return item
