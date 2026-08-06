class_name TechniqueData
extends Resource

enum TechniqueType {
	ACTIVE,
	PASSIVE,
}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var technique_type: TechniqueType = TechniqueType.PASSIVE
@export var category: StringName = &"general"
@export var tags: PackedStringArray = []
@export var unlock_source: String = ""
@export_range(1, 100, 1) var minimum_level := 1
@export var prerequisites: PackedStringArray = []
@export_range(1, 20, 1) var starting_rank := 1
@export_range(1, 20, 1) var maximum_rank := 1
@export var gameplay_handler: StringName
@export_range(0.0, 60.0, 0.05) var cooldown := 0.0
@export var effect_value := 0.0


func is_active() -> bool:
	return technique_type == TechniqueType.ACTIVE
