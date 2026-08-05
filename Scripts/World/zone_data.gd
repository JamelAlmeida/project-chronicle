class_name ZoneData
extends Resource

enum ZoneType {
	SAFE,
	WILDERNESS,
	DUNGEON,
}

@export var zone_id: String = ""
@export var display_name: String = ""
@export var zone_type: ZoneType = ZoneType.WILDERNESS
@export var danger_rating: int = 0
@export var danger_label: String = ""
@export var biome: String = ""
@export var recommended_threat: int = 0
@export var possible_enemy_groups: PackedStringArray = []
@export var possible_loot_groups: PackedStringArray = []
@export var seed_value: int = 0
@export_file("*.tscn") var scene_path: String = ""


func is_safe() -> bool:
	return zone_type == ZoneType.SAFE


func get_banner_subtitle() -> String:
	if not danger_label.is_empty():
		return danger_label
	match zone_type:
		ZoneType.SAFE:
			return "Safe Haven"
		ZoneType.WILDERNESS:
			return "Danger %s" % _roman_numeral(maxi(danger_rating, 1))
		ZoneType.DUNGEON:
			return "Danger %s" % _roman_numeral(maxi(danger_rating, 1))
		_:
			return ""


func _roman_numeral(value: int) -> String:
	match value:
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"
		4:
			return "IV"
		5:
			return "V"
		_:
			return str(value)
