extends Node

signal technique_unlocked(technique_id: String)
signal technique_equipped(technique_id: String, slot_index: int)
signal techniques_changed

const PASSIVE_SLOT_COUNT := 3
const ACTIVE_SLOT_COUNT := 1

var _registry: Dictionary = {}
var _unlocked_ranks: Dictionary = {}
var _equipped_passives: Array[String] = ["", "", ""]
var _equipped_actives: Array[String] = [""]
var _cooldowns: Dictionary = {}


func _ready() -> void:
	_register(preload("res://Project Chronicle/Resources/Techniques/forceful_edge.tres"))
	_register(preload("res://Project Chronicle/Resources/Techniques/arc_sweep.tres"))
	_register(preload("res://Project Chronicle/Resources/Techniques/trailblazers_step.tres"))
	_register(preload("res://Project Chronicle/Resources/Techniques/resolute_breath.tres"))

	var progression := get_node_or_null("/root/CharacterProgression")
	if progression != null:
		if not progression.level_up.is_connected(_on_level_up):
			progression.level_up.connect(_on_level_up)
		if not progression.progression_reset.is_connected(_on_progression_reset):
			progression.progression_reset.connect(_on_progression_reset)
		_unlock_level_techniques(progression.current_level)


func _process(delta: float) -> void:
	for technique_id: String in _cooldowns.keys():
		var remaining: float = maxf(float(_cooldowns[technique_id]) - delta, 0.0)
		if remaining <= 0.0:
			_cooldowns.erase(technique_id)
		else:
			_cooldowns[technique_id] = remaining


func get_technique(technique_id: String) -> TechniqueData:
	return _registry.get(technique_id, null) as TechniqueData


func get_unlocked_techniques() -> Array[TechniqueData]:
	var results: Array[TechniqueData] = []
	for technique_id: String in _unlocked_ranks:
		var technique := get_technique(technique_id)
		if technique != null:
			results.append(technique)
	return results


func is_unlocked(technique_id: String) -> bool:
	return int(_unlocked_ranks.get(technique_id, 0)) > 0


func unlock_technique(technique_id: String, auto_equip: bool = true) -> bool:
	var technique := get_technique(technique_id)
	if technique == null or is_unlocked(technique_id):
		return false
	if not _prerequisites_met(technique):
		return false

	_unlocked_ranks[technique_id] = technique.starting_rank
	if auto_equip:
		_equip_first_open_slot(technique)
	technique_unlocked.emit(technique_id)
	techniques_changed.emit()
	return true


func equip_technique(technique_id: String, slot_index: int = 0) -> bool:
	var technique := get_technique(technique_id)
	if technique == null or not is_unlocked(technique_id):
		return false

	var slots := _equipped_actives if technique.is_active() else _equipped_passives
	if slot_index < 0 or slot_index >= slots.size():
		return false
	for index in range(slots.size()):
		if slots[index] == technique_id:
			slots[index] = ""
	slots[slot_index] = technique_id
	technique_equipped.emit(technique_id, slot_index)
	techniques_changed.emit()
	return true


func is_equipped(technique_id: String) -> bool:
	return _equipped_actives.has(technique_id) or _equipped_passives.has(technique_id)


func get_equipped_active(slot_index: int = 0) -> String:
	if slot_index < 0 or slot_index >= _equipped_actives.size():
		return ""
	return _equipped_actives[slot_index]


func get_equipped_passives() -> Array[String]:
	return _equipped_passives.duplicate()


func get_effect_value(gameplay_handler: StringName) -> float:
	var total := 0.0
	for technique_id: String in _equipped_passives:
		var technique := get_technique(technique_id)
		if technique != null and technique.gameplay_handler == gameplay_handler:
			total += technique.effect_value
	return total


func try_begin_active(technique_id: String) -> bool:
	var technique := get_technique(technique_id)
	if (
		technique == null
		or not technique.is_active()
		or not is_unlocked(technique_id)
		or not is_equipped(technique_id)
		or float(_cooldowns.get(technique_id, 0.0)) > 0.0
	):
		return false
	_cooldowns[technique_id] = technique.cooldown
	return true


func get_cooldown_remaining(technique_id: String) -> float:
	return float(_cooldowns.get(technique_id, 0.0))


func reset_techniques() -> void:
	_unlocked_ranks.clear()
	_equipped_passives = ["", "", ""]
	_equipped_actives = [""]
	_cooldowns.clear()
	var progression := get_node_or_null("/root/CharacterProgression")
	if progression != null:
		_unlock_level_techniques(progression.current_level)
	techniques_changed.emit()


func _register(technique: TechniqueData) -> void:
	if technique != null and not technique.id.is_empty():
		_registry[technique.id] = technique


func _prerequisites_met(technique: TechniqueData) -> bool:
	for prerequisite_id: String in technique.prerequisites:
		if not is_unlocked(prerequisite_id):
			return false
	return true


func _equip_first_open_slot(technique: TechniqueData) -> void:
	var slots := _equipped_actives if technique.is_active() else _equipped_passives
	for index in range(slots.size()):
		if slots[index].is_empty():
			slots[index] = technique.id
			technique_equipped.emit(technique.id, index)
			return


func _unlock_level_techniques(level: int) -> void:
	for technique: TechniqueData in _registry.values():
		if technique.unlock_source == "Level milestone" and technique.minimum_level <= level:
			unlock_technique(technique.id)


func _on_level_up(new_level: int, _stat_points_awarded: int) -> void:
	_unlock_level_techniques(new_level)


func _on_progression_reset() -> void:
	reset_techniques()
