class_name StatsComponent
extends Node

signal stats_changed

@export var base_stats: StatBlock

var _effect_modifiers: Dictionary = {}
var _equipment_modifiers: Dictionary = {}


func _ready() -> void:
	if base_stats == null:
		base_stats = StatBlock.new()
		base_stats.strength = 5.0
		base_stats.dexterity = 5.0
		base_stats.vitality = 5.0
		base_stats.intellect = 5.0
		base_stats.max_health = 100.0
		base_stats.move_speed = 180.0
		base_stats.attack_damage = 10.0
		base_stats.attack_speed = 1.0
	var progression := get_node_or_null("/root/CharacterProgression")
	if progression != null:
		progression.level_up.connect(_on_progression_changed)
		progression.stat_allocated.connect(_on_stat_allocated)
		progression.progression_reset.connect(_on_progression_reset)
	var techniques := get_node_or_null("/root/TechniqueManager")
	if techniques != null:
		techniques.techniques_changed.connect(_on_techniques_changed)


func set_modifier(source_id: String, modifier: StatBlock) -> void:
	if modifier == null:
		remove_modifier(source_id)
		return
	_effect_modifiers[source_id] = modifier
	stats_changed.emit()


func remove_modifier(source_id: String) -> void:
	if _effect_modifiers.erase(source_id):
		stats_changed.emit()


func set_equipment_modifier(source_id: String, modifier: StatBlock) -> void:
	if modifier == null:
		remove_equipment_modifier(source_id)
		return
	_equipment_modifiers[source_id] = modifier
	stats_changed.emit()


func remove_equipment_modifier(source_id: String) -> void:
	if _equipment_modifiers.erase(source_id):
		stats_changed.emit()


func get_stat(stat_name: String) -> float:
	var total := float(get_stat_breakdown(stat_name).get("total", 0.0))
	if stat_name == "attack_speed":
		return maxf(total, 0.1)
	if stat_name == "crit_chance" or stat_name == "lifesteal":
		return clampf(total, 0.0, 1.0)
	return total


func get_stat_breakdown(stat_name: String) -> Dictionary:
	var base_value := base_stats.get_stat(stat_name)
	var allocated_value := _get_allocated_value(stat_name)
	var equipment_value := _sum_modifiers(_equipment_modifiers, stat_name)
	var effect_value := _sum_modifiers(_effect_modifiers, stat_name)
	var level_value := _get_level_growth(stat_name)

	if not _is_core_stat(stat_name):
		allocated_value += _get_derived_bonus(
			stat_name,
			_get_allocated_core(&"strength"),
			_get_allocated_core(&"dexterity"),
			_get_allocated_core(&"vitality"),
			_get_allocated_core(&"intellect")
		)
		equipment_value += _get_derived_bonus_from_modifiers(stat_name, _equipment_modifiers)
		effect_value += _get_derived_bonus_from_modifiers(stat_name, _effect_modifiers)
		effect_value += _get_technique_bonus(stat_name)

	return {
		"base": base_value,
		"allocated": allocated_value,
		"equipment": equipment_value,
		"effects": effect_value,
		"level": level_value,
		"total": base_value + allocated_value + equipment_value + effect_value + level_value,
	}


func get_core_stat(stat_name: StringName) -> float:
	return get_stat(String(stat_name))


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


func _sum_modifiers(modifiers: Dictionary, stat_name: String) -> float:
	var total := 0.0
	for source_id: String in modifiers:
		var modifier: StatBlock = modifiers[source_id] as StatBlock
		if modifier != null:
			total += modifier.get_stat(stat_name)
	return total


func _get_allocated_value(stat_name: String) -> float:
	if not _is_core_stat(stat_name):
		return 0.0
	return _get_allocated_core(StringName(stat_name))


func _get_allocated_core(stat_name: StringName) -> float:
	var progression := get_node_or_null("/root/CharacterProgression")
	if progression == null:
		return 0.0
	return float(progression.get_allocated_points(stat_name))


func _get_derived_bonus_from_modifiers(stat_name: String, modifiers: Dictionary) -> float:
	return _get_derived_bonus(
		stat_name,
		_sum_modifiers(modifiers, "strength"),
		_sum_modifiers(modifiers, "dexterity"),
		_sum_modifiers(modifiers, "vitality"),
		_sum_modifiers(modifiers, "intellect")
	)


func _get_derived_bonus(
	stat_name: String,
	strength_bonus: float,
	dexterity_bonus: float,
	vitality_bonus: float,
	intellect_bonus: float
) -> float:
	match stat_name:
		"max_health":
			return vitality_bonus * 8.0
		"attack_damage":
			return strength_bonus * 2.0 + dexterity_bonus * 0.5 + intellect_bonus * 0.4
		"attack_speed":
			return dexterity_bonus * 0.02
		"armor":
			return vitality_bonus * 0.6 + strength_bonus * 0.2
		"crit_chance":
			return dexterity_bonus * 0.005
		_:
			return 0.0


func _get_level_growth(stat_name: String) -> float:
	var progression := get_node_or_null("/root/CharacterProgression")
	if progression == null:
		return 0.0
	var levels_gained: float = maxf(float(progression.current_level - 1), 0.0)
	match stat_name:
		"max_health":
			return levels_gained * 4.0
		"attack_damage":
			return levels_gained * 0.6
		_:
			return 0.0


func _get_technique_bonus(stat_name: String) -> float:
	var techniques := get_node_or_null("/root/TechniqueManager")
	if techniques == null:
		return 0.0
	match stat_name:
		"attack_damage":
			return techniques.get_effect_value(&"flat_attack_damage")
		"max_health":
			return techniques.get_effect_value(&"flat_max_health")
		_:
			return 0.0


func _is_core_stat(stat_name: String) -> bool:
	return stat_name in ["strength", "dexterity", "vitality", "intellect"]


func _on_progression_changed(_new_level: int, _stat_points_awarded: int) -> void:
	stats_changed.emit()


func _on_stat_allocated(_stat_id: StringName, _new_total: int) -> void:
	stats_changed.emit()


func _on_progression_reset() -> void:
	stats_changed.emit()


func _on_techniques_changed() -> void:
	stats_changed.emit()
