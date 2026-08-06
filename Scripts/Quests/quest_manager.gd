extends Node

enum QuestState {
	UNAVAILABLE,
	AVAILABLE,
	ACTIVE,
	READY_TO_TURN_IN,
	COMPLETED,
}

signal quest_state_changed(quest_id: String, new_state: QuestState)
signal quest_objective_progressed(quest_id: String, objective_index: int, current: int, required: int)
signal quest_reward_granted(quest_id: String)

var _registry: Dictionary = {}
var _states: Dictionary = {}
var _progress: Dictionary = {}


func _ready() -> void:
	_register(preload("res://Project Chronicle/Resources/Quests/elderwood_trial.tres"))
	_register(preload("res://Project Chronicle/Resources/Quests/gel_for_the_road.tres"))

	var events := get_node_or_null("/root/GameplayEvents")
	if events != null:
		events.enemy_defeated.connect(_on_enemy_defeated)
		events.location_discovered.connect(_on_location_discovered)
	var inventory := get_node_or_null("/root/Inventory")
	if inventory != null:
		inventory.item_added.connect(_on_item_added)
	_refresh_availability()


func get_quest(quest_id: String) -> QuestData:
	return _registry.get(quest_id, null) as QuestData


func get_state(quest_id: String) -> QuestState:
	return _states.get(quest_id, QuestState.UNAVAILABLE)


func get_state_name(quest_id: String) -> String:
	match get_state(quest_id):
		QuestState.UNAVAILABLE:
			return "Unavailable"
		QuestState.AVAILABLE:
			return "Available"
		QuestState.ACTIVE:
			return "Active"
		QuestState.READY_TO_TURN_IN:
			return "Ready to turn in"
		QuestState.COMPLETED:
			return "Completed"
		_:
			return "Unknown"


func activate_quest(quest_id: String) -> bool:
	if get_state(quest_id) != QuestState.AVAILABLE:
		return false
	var quest := get_quest(quest_id)
	if quest == null:
		return false

	var objective_progress: Array[int] = []
	for objective: QuestObjectiveData in quest.objectives:
		var initial := 0
		if objective.objective_type == QuestObjectiveData.ObjectiveType.COLLECT_ITEM:
			initial = mini(_inventory().get_quantity(objective.target_id), objective.required_amount)
		objective_progress.append(initial)
	_progress[quest_id] = objective_progress
	_set_state(quest_id, QuestState.ACTIVE)
	_check_ready(quest_id)
	return true


func turn_in_quest(quest_id: String) -> bool:
	if get_state(quest_id) != QuestState.READY_TO_TURN_IN:
		return false
	var quest := get_quest(quest_id)
	if quest == null:
		return false

	_grant_rewards(quest)
	_set_state(quest_id, QuestState.COMPLETED)
	var events := get_node_or_null("/root/GameplayEvents")
	if events != null:
		events.quest_completed.emit(quest_id)
	quest_reward_granted.emit(quest_id)
	_refresh_availability()
	return true


func perform_context_action() -> String:
	for quest_id: String in _registry:
		if get_state(quest_id) == QuestState.READY_TO_TURN_IN:
			turn_in_quest(quest_id)
			return "Turned in %s" % get_quest(quest_id).title
	for quest_id: String in _registry:
		if get_state(quest_id) == QuestState.AVAILABLE:
			activate_quest(quest_id)
			return "Accepted %s" % get_quest(quest_id).title
	return "No quest action available"


func get_visible_quest_lines() -> PackedStringArray:
	var lines: PackedStringArray = []
	for quest_id: String in _registry:
		var state := get_state(quest_id)
		if state == QuestState.UNAVAILABLE or state == QuestState.COMPLETED:
			continue
		var quest := get_quest(quest_id)
		if state == QuestState.AVAILABLE:
			lines.append("◆  %s" % quest.title)
			lines.append("    Available — press F to accept.")
			continue
		if state == QuestState.READY_TO_TURN_IN:
			lines.append("◆  %s" % quest.title)
			lines.append("    Ready to turn in — press F.")
			continue
		lines.append("◆  %s" % quest.title)
		var progress: Array = _progress.get(quest_id, [])
		for index in range(quest.objectives.size()):
			var objective: QuestObjectiveData = quest.objectives[index]
			var current := int(progress[index]) if index < progress.size() else 0
			lines.append("    %s (%d/%d)" % [objective.description, current, objective.required_amount])
	return lines


func get_known_quest_ids() -> PackedStringArray:
	var quest_ids: PackedStringArray = []
	for quest_id: String in _registry:
		if get_state(quest_id) != QuestState.UNAVAILABLE:
			quest_ids.append(quest_id)
	return quest_ids


func get_objective_lines(quest_id: String) -> PackedStringArray:
	var lines: PackedStringArray = []
	var quest := get_quest(quest_id)
	if quest == null:
		return lines
	var progress: Array = _progress.get(quest_id, [])
	for index in range(quest.objectives.size()):
		var objective: QuestObjectiveData = quest.objectives[index]
		var current := int(progress[index]) if index < progress.size() else 0
		var suffix := " (Optional)" if objective.optional else ""
		lines.append(
			"%s%s  %d/%d"
			% [objective.description, suffix, current, objective.required_amount]
		)
	return lines


func reset_quests() -> void:
	_progress.clear()
	for quest_id: String in _registry:
		_states[quest_id] = QuestState.UNAVAILABLE
	_refresh_availability()


func _register(quest: QuestData) -> void:
	if quest == null or quest.id.is_empty():
		return
	_registry[quest.id] = quest
	_states[quest.id] = QuestState.UNAVAILABLE


func _refresh_availability() -> void:
	for quest_id: String in _registry:
		if get_state(quest_id) != QuestState.UNAVAILABLE:
			continue
		var quest := get_quest(quest_id)
		var prerequisites_met := true
		for prerequisite_id: String in quest.prerequisite_quest_ids:
			if get_state(prerequisite_id) != QuestState.COMPLETED:
				prerequisites_met = false
				break
		if prerequisites_met:
			_set_state(quest_id, QuestState.AVAILABLE)


func _advance_matching_objectives(objective_type: QuestObjectiveData.ObjectiveType, target_id: String, amount: int) -> void:
	if amount <= 0:
		return
	for quest_id: String in _registry:
		if get_state(quest_id) != QuestState.ACTIVE:
			continue
		var quest := get_quest(quest_id)
		var progress: Array = _progress.get(quest_id, [])
		for index in range(quest.objectives.size()):
			var objective: QuestObjectiveData = quest.objectives[index]
			if objective.objective_type != objective_type or objective.target_id != target_id:
				continue
			var current := int(progress[index]) if index < progress.size() else 0
			var updated := mini(current + amount, objective.required_amount)
			progress[index] = updated
			quest_objective_progressed.emit(quest_id, index, updated, objective.required_amount)
		_progress[quest_id] = progress
		_check_ready(quest_id)


func _check_ready(quest_id: String) -> void:
	if get_state(quest_id) != QuestState.ACTIVE:
		return
	var quest := get_quest(quest_id)
	var progress: Array = _progress.get(quest_id, [])
	for index in range(quest.objectives.size()):
		var objective: QuestObjectiveData = quest.objectives[index]
		if objective.optional:
			continue
		if index >= progress.size() or int(progress[index]) < objective.required_amount:
			return
	_set_state(quest_id, QuestState.READY_TO_TURN_IN)


func _grant_rewards(quest: QuestData) -> void:
	if quest.rewards == null:
		return
	if quest.rewards.xp > 0:
		_progression().gain_xp(quest.rewards.xp, &"quest")
	for index in range(quest.rewards.item_ids.size()):
		var quantity := 1
		if index < quest.rewards.item_quantities.size():
			quantity = maxi(quest.rewards.item_quantities[index], 1)
		_inventory().add_item(quest.rewards.item_ids[index], quantity)
	for technique_id: String in quest.rewards.technique_ids:
		_techniques().unlock_technique(technique_id)


func _set_state(quest_id: String, state: QuestState) -> void:
	if get_state(quest_id) == state:
		return
	_states[quest_id] = state
	quest_state_changed.emit(quest_id, state)


func _on_enemy_defeated(enemy_id: String, _xp_reward: int, _world_position: Vector2) -> void:
	_advance_matching_objectives(QuestObjectiveData.ObjectiveType.KILL_ENEMY, enemy_id, 1)


func _on_item_added(item_id: String, quantity_added: int, _new_total: int) -> void:
	_advance_matching_objectives(QuestObjectiveData.ObjectiveType.COLLECT_ITEM, item_id, quantity_added)


func _on_location_discovered(location_id: String) -> void:
	_advance_matching_objectives(QuestObjectiveData.ObjectiveType.DISCOVER_LOCATION, location_id, 1)


func _inventory():
	return get_node("/root/Inventory")


func _progression():
	return get_node("/root/CharacterProgression")


func _techniques():
	return get_node("/root/TechniqueManager")
