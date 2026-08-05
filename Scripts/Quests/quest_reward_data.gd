class_name QuestRewardData
extends Resource

@export_range(0, 1000000, 1) var xp := 0
@export var item_ids: PackedStringArray = []
@export var item_quantities: PackedInt32Array = []
@export var technique_ids: PackedStringArray = []
@export var future_reward_tags: PackedStringArray = []
