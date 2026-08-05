class_name QuestObjectiveData
extends Resource

enum ObjectiveType {
	KILL_ENEMY,
	COLLECT_ITEM,
	DISCOVER_LOCATION,
	TALK_INTERACT,
	EVENT,
}

@export var objective_type: ObjectiveType = ObjectiveType.KILL_ENEMY
@export var target_id: String = ""
@export_range(1, 999, 1) var required_amount := 1
@export var description: String = ""
@export var optional := false
