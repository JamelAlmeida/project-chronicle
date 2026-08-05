extends Node

const _EQUIPMENT_DATA_SCRIPT := preload("res://Project Chronicle/Scripts/Items/equipment_data.gd")

var _items: Dictionary = {}


func _ready() -> void:
	_register(preload("res://Project Chronicle/Resources/Items/slime_gel.tres"))
	_register(preload("res://Project Chronicle/Resources/Items/goblin_tooth.tres"))
	_register(preload("res://Project Chronicle/Resources/Items/Equipment/rusted_sword.tres"))
	_register(preload("res://Project Chronicle/Resources/Items/Equipment/swift_katana.tres"))
	_register(preload("res://Project Chronicle/Resources/Items/Equipment/bloodfang_blade.tres"))
	_register(preload("res://Project Chronicle/Resources/Items/Equipment/crimson_leech_ring.tres"))


func _register(item: ItemData) -> void:
	_items[item.id] = item


func get_item(item_id: String) -> ItemData:
	return _items.get(item_id, null)


func get_equipment(item_id: String) -> ItemData:
	var item: ItemData = get_item(item_id)
	if item != null and item.get_script() == _EQUIPMENT_DATA_SCRIPT:
		return item
	return null


func is_equipment_item(item: ItemData) -> bool:
	return item != null and item.get_script() == _EQUIPMENT_DATA_SCRIPT
