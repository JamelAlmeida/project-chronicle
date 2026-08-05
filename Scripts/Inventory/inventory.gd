extends Node

signal item_added(item_id: String, quantity_added: int, new_total: int)
signal expedition_loot_changed
signal secured_loot_changed

var _secured: Dictionary = {}
var _expedition: Dictionary = {}


func add_item(item_id: String, quantity: int = 1) -> int:
	var item: ItemData = _item_registry().get_item(item_id)
	if item == null or quantity <= 0:
		return 0

	var current: int = get_quantity(item_id)
	var space_remaining: int = item.max_stack - current
	if space_remaining <= 0:
		return 0

	var quantity_added: int = mini(quantity, space_remaining)
	if _is_safe_zone():
		_secured[item_id] = int(_secured.get(item_id, 0)) + quantity_added
		secured_loot_changed.emit()
	else:
		_expedition[item_id] = int(_expedition.get(item_id, 0)) + quantity_added
		expedition_loot_changed.emit()

	var new_total: int = get_quantity(item_id)
	item_added.emit(item_id, quantity_added, new_total)
	return quantity_added


func get_quantity(item_id: String) -> int:
	return int(_secured.get(item_id, 0)) + int(_expedition.get(item_id, 0))


func get_secured_quantity(item_id: String) -> int:
	return int(_secured.get(item_id, 0))


func get_expedition_quantity(item_id: String) -> int:
	return int(_expedition.get(item_id, 0))


func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_quantity(item_id) >= quantity


func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not has_item(item_id, quantity):
		return false

	var remaining := quantity
	var expedition_qty: int = int(_expedition.get(item_id, 0))
	if expedition_qty > 0:
		var from_expedition: int = mini(remaining, expedition_qty)
		var new_expedition: int = expedition_qty - from_expedition
		if new_expedition <= 0:
			_expedition.erase(item_id)
		else:
			_expedition[item_id] = new_expedition
		remaining -= from_expedition
		expedition_loot_changed.emit()

	if remaining > 0:
		var secured_qty: int = int(_secured.get(item_id, 0))
		var new_secured: int = secured_qty - remaining
		if new_secured <= 0:
			_secured.erase(item_id)
		else:
			_secured[item_id] = new_secured
		secured_loot_changed.emit()

	return true


func secure_expedition_loot() -> Array:
	if _expedition.is_empty():
		return []

	var summaries: Array = []
	for item_id: String in _expedition.keys():
		var quantity: int = int(_expedition[item_id])
		if quantity <= 0:
			continue
		_secured[item_id] = int(_secured.get(item_id, 0)) + quantity
		summaries.append({"item_id": item_id, "quantity": quantity})

	_expedition.clear()
	expedition_loot_changed.emit()
	secured_loot_changed.emit()
	return summaries


func lose_expedition_loot() -> Array:
	if _expedition.is_empty():
		return []

	var summaries: Array = []
	for item_id: String in _expedition.keys():
		var quantity: int = int(_expedition[item_id])
		if quantity <= 0:
			continue
		summaries.append({"item_id": item_id, "quantity": quantity})

	_expedition.clear()
	expedition_loot_changed.emit()
	return summaries


func get_expedition_summary() -> Array:
	var summaries: Array = []
	for item_id: String in _expedition.keys():
		summaries.append({"item_id": item_id, "quantity": int(_expedition[item_id])})
	return summaries


func get_inventory_summary() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	var item_ids: Dictionary = {}
	for item_id: String in _secured.keys():
		item_ids[item_id] = true
	for item_id: String in _expedition.keys():
		item_ids[item_id] = true
	for item_id: String in item_ids.keys():
		var secured_quantity := get_secured_quantity(item_id)
		var expedition_quantity := get_expedition_quantity(item_id)
		summaries.append({
			"item_id": item_id,
			"secured": secured_quantity,
			"expedition": expedition_quantity,
			"total": secured_quantity + expedition_quantity,
		})
	summaries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_item: ItemData = _item_registry().get_item(str(a.get("item_id", "")))
		var b_item: ItemData = _item_registry().get_item(str(b.get("item_id", "")))
		var a_name := a_item.display_name if a_item != null else str(a.get("item_id", ""))
		var b_name := b_item.display_name if b_item != null else str(b.get("item_id", ""))
		return a_name.naturalnocasecmp_to(b_name) < 0
	)
	return summaries


func clear() -> void:
	_secured.clear()
	_expedition.clear()
	expedition_loot_changed.emit()
	secured_loot_changed.emit()


func _is_safe_zone() -> bool:
	var zone_manager := get_node_or_null("/root/ZoneManager")
	if zone_manager == null:
		return true
	# Before the first zone finishes loading, treat inventory as secured.
	if zone_manager.current_zone == null:
		return true
	return zone_manager.is_in_safe_zone()


func _item_registry():
	return get_node("/root/ItemRegistry")
