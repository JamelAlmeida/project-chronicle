class_name QuestData
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var quest_giver_id: String = ""
@export var objectives: Array[QuestObjectiveData] = []
@export var rewards: QuestRewardData
@export var prerequisite_quest_ids: PackedStringArray = []
@export_range(1, 100, 1) var recommended_level := 1
@export var next_quest_ids: PackedStringArray = []
@export var optional := false
@export var future_faction_requirements: PackedStringArray = []
@export var future_world_state_requirements: PackedStringArray = []
