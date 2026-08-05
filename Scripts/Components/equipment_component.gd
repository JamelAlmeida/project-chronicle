class_name EquipmentComponent
extends Node

signal equipment_changed(slot_key: String, item_id: String)

const SLOT_KEYS: Array[String] = [
	"weapon",
	"offhand",
	"head",
	"chest",
	"hands",
	"feet",
	"ring1",
	"ring2",
	"amulet",
]

const _EQUIPMENT_DATA_SCRIPT := preload("res://Project Chronicle/Scripts/Items/equipment_data.gd")

var _equipped: Dictionary = {}
var _stats: StatsComponent


func _ready() -> void:
	for slot_key: String in SLOT_KEYS:
		_equipped[slot_key] = ""
	_stats = get_parent().get_node("StatsComponent") as StatsComponent


func equip_from_inventory(item_id: String) -> bool:
	if item_id.is_empty() or not _inventory().has_item(item_id, 1):
		return false

	var item: ItemData = _item_registry().get_item(item_id)
	if item == null or not _is_equipment(item):
		return false

	var equipment: EquipmentData = item as EquipmentData
	var slot_key: String = _resolve_slot_for_equip(equipment)
	if slot_key.is_empty():
		return false

	if not get_equipped_id(slot_key).is_empty():
		if not unequip(slot_key):
			return false

	if not _inventory().remove_item(item_id, 1):
		return false

	_set_slot(slot_key, item_id)
	return true


func unequip(slot_key: String) -> bool:
	if not SLOT_KEYS.has(slot_key):
		return false

	var item_id: String = get_equipped_id(slot_key)
	if item_id.is_empty():
		return false

	if _inventory().add_item(item_id, 1) <= 0:
		return false

	_clear_slot(slot_key)
	return true


func get_equipped_id(slot_key: String) -> String:
	return str(_equipped.get(slot_key, ""))


func get_equipped_item(slot_key: String) -> EquipmentData:
	var item_id: String = get_equipped_id(slot_key)
	if item_id.is_empty():
		return null

	var item: ItemData = _item_registry().get_item(item_id)
	if _is_equipment(item):
		return item as EquipmentData
	return null


func get_weapon_attack_cooldown() -> float:
	var weapon: EquipmentData = get_equipped_item("weapon")
	if weapon != null:
		return weapon.weapon_attack_cooldown
	return 0.4


func restore_equipped_state(equipped_state: Dictionary) -> void:
	for slot_key: String in SLOT_KEYS:
		var item_id: String = str(equipped_state.get(slot_key, ""))
		if item_id.is_empty():
			if not get_equipped_id(slot_key).is_empty():
				_equipped[slot_key] = ""
				_stats.remove_modifier(slot_key)
				equipment_changed.emit(slot_key, "")
			continue
		_set_slot(slot_key, item_id)


func _resolve_slot_for_equip(equipment: EquipmentData) -> String:
	match equipment.equipment_slot:
		EquipmentData.EquipmentSlot.WEAPON:
			return "weapon"
		EquipmentData.EquipmentSlot.OFFHAND:
			return "offhand"
		EquipmentData.EquipmentSlot.HEAD:
			return "head"
		EquipmentData.EquipmentSlot.CHEST:
			return "chest"
		EquipmentData.EquipmentSlot.HANDS:
			return "hands"
		EquipmentData.EquipmentSlot.FEET:
			return "feet"
		EquipmentData.EquipmentSlot.AMULET:
			return "amulet"
		EquipmentData.EquipmentSlot.RING:
			if get_equipped_id("ring1").is_empty():
				return "ring1"
			if get_equipped_id("ring2").is_empty():
				return "ring2"
			return "ring1"
		_:
			return ""


func _set_slot(slot_key: String, item_id: String) -> void:
	_equipped[slot_key] = item_id
	_apply_item_modifier(slot_key, item_id)
	equipment_changed.emit(slot_key, item_id)


func _clear_slot(slot_key: String) -> void:
	_equipped[slot_key] = ""
	_stats.remove_modifier(slot_key)
	equipment_changed.emit(slot_key, "")


func _apply_item_modifier(slot_key: String, item_id: String) -> void:
	var item: ItemData = _item_registry().get_item(item_id)
	if _is_equipment(item):
		var equipment: EquipmentData = item as EquipmentData
		if equipment.stat_modifiers != null:
			_stats.set_modifier(slot_key, equipment.stat_modifiers)
		else:
			_stats.remove_modifier(slot_key)
	else:
		_stats.remove_modifier(slot_key)


func _is_equipment(item: ItemData) -> bool:
	return item != null and item.get_script() == _EQUIPMENT_DATA_SCRIPT


func _inventory():
	return get_node("/root/Inventory")


func _item_registry():
	return get_node("/root/ItemRegistry")
