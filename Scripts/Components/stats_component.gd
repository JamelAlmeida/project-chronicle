class_name StatsComponent
extends Node

signal stats_changed

@export var base_stats: StatBlock

var _modifiers: Dictionary = {}


func _ready() -> void:
	if base_stats == null:
		base_stats = StatBlock.new()
		base_stats.max_health = 100.0
		base_stats.move_speed = 180.0
		base_stats.attack_damage = 10.0
		base_stats.attack_speed = 1.0


func set_modifier(source_id: String, modifier: StatBlock) -> void:
	if modifier == null:
		remove_modifier(source_id)
		return
	_modifiers[source_id] = modifier
	stats_changed.emit()


func remove_modifier(source_id: String) -> void:
	if _modifiers.erase(source_id):
		stats_changed.emit()


func get_stat(stat_name: String) -> float:
	var total: float = base_stats.get_stat(stat_name)
	for source_id: String in _modifiers:
		var modifier: StatBlock = _modifiers[source_id] as StatBlock
		if modifier == null:
			continue
		total += modifier.get_stat(stat_name)

	if stat_name == "attack_speed":
		return maxf(total, 0.1)
	return total


func get_max_health() -> float:
	return get_stat("max_health")


func get_move_speed() -> float:
	return get_stat("move_speed")


func get_attack_damage() -> float:
	return get_stat("attack_damage")


func get_attack_speed() -> float:
	return get_stat("attack_speed")


func get_armor() -> float:
	return get_stat("armor")


func get_crit_chance() -> float:
	return get_stat("crit_chance")


func get_lifesteal() -> float:
	return get_stat("lifesteal")
