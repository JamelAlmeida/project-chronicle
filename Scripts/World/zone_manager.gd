extends Node

signal zone_changed(zone_data: ZoneData)
signal loot_secured(item_summaries: Array)
signal expedition_loot_lost(item_summaries: Array)

const HEARTHVALE_SCENE := "res://Project Chronicle/Scenes/World/Zones/hearthvale.tscn"
const DEFAULT_SPAWN_ID := "default"

var current_zone: ZoneData
var pending_spawn_id: String = DEFAULT_SPAWN_ID

var _saved_equipment: Dictionary = {}
var _saved_health_current: int = -1
var _is_transitioning := false
var _death_respawn_pending := false


func is_in_safe_zone() -> bool:
	return current_zone != null and current_zone.is_safe()


func transition_to(scene_path: String, spawn_id: String = DEFAULT_SPAWN_ID) -> void:
	if _is_transitioning or scene_path.is_empty():
		return

	_is_transitioning = true
	pending_spawn_id = spawn_id if not spawn_id.is_empty() else DEFAULT_SPAWN_ID
	_capture_player_state()
	get_tree().call_deferred("change_scene_to_file", scene_path)


func handle_player_death() -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	_capture_player_state()
	var lost: Array = _inventory().lose_expedition_loot()
	if not lost.is_empty():
		expedition_loot_lost.emit(lost)
		_notify_loot_lost(lost)

	_death_respawn_pending = true
	_saved_health_current = -1
	pending_spawn_id = DEFAULT_SPAWN_ID
	get_tree().call_deferred("change_scene_to_file", HEARTHVALE_SCENE)


func on_zone_ready(zone: Node) -> void:
	var zone_data: ZoneData = zone.get("zone_data") as ZoneData
	current_zone = zone_data

	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		var spawn_position: Vector2 = zone.call("get_spawn_position", pending_spawn_id)
		player.global_position = spawn_position
		_restore_player_state(player)

	pending_spawn_id = DEFAULT_SPAWN_ID
	_is_transitioning = false

	if current_zone != null and current_zone.is_safe():
		_secure_expedition_loot()
		if _death_respawn_pending:
			_death_respawn_pending = false
			_fully_heal_player(player)

	if current_zone != null:
		zone_changed.emit(current_zone)


func _secure_expedition_loot() -> void:
	var secured: Array = _inventory().secure_expedition_loot()
	if secured.is_empty():
		return

	loot_secured.emit(secured)
	_notify_loot_secured(secured)


func _capture_player_state() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var equipment: EquipmentComponent = player.get_node_or_null("EquipmentComponent") as EquipmentComponent
	_saved_equipment.clear()
	if equipment != null:
		for slot_key: String in EquipmentComponent.SLOT_KEYS:
			_saved_equipment[slot_key] = equipment.get_equipped_id(slot_key)

	var health: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		_saved_health_current = health.current_health


func _restore_player_state(player: Node) -> void:
	var equipment: EquipmentComponent = player.get_node_or_null("EquipmentComponent") as EquipmentComponent
	if equipment != null and not _saved_equipment.is_empty():
		equipment.restore_equipped_state(_saved_equipment)

	var health: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
	if health != null and _saved_health_current >= 0:
		health.set_current_health(_saved_health_current)


func _fully_heal_player(player: Node) -> void:
	if player == null:
		return
	var health: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		health.set_current_health(health.max_health)


func _notify_loot_secured(summaries: Array) -> void:
	var message := "Loot secured: %s" % _format_summaries(summaries)
	print(message)
	_hud_message(message, Color(0.55, 0.95, 0.65))


func _notify_loot_lost(summaries: Array) -> void:
	var message := "Expedition loot lost: %s" % _format_summaries(summaries)
	print(message)
	_hud_message(message, Color(1.0, 0.45, 0.4))


func _format_summaries(summaries: Array) -> String:
	var parts: PackedStringArray = []
	for entry in summaries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var item_id: String = str(entry.get("item_id", ""))
		var quantity: int = int(entry.get("quantity", 0))
		var item: ItemData = _item_registry().get_item(item_id)
		var display_name: String = item.display_name if item != null else item_id
		parts.append("%s x%d" % [display_name, quantity])
	return ", ".join(parts)


func _hud_message(text: String, color: Color) -> void:
	var hud := get_tree().get_first_node_in_group("game_hud")
	if hud != null and hud.has_method("show_status_message"):
		hud.call("show_status_message", text, color)


func _inventory():
	return get_node("/root/Inventory")


func _item_registry():
	return get_node("/root/ItemRegistry")
