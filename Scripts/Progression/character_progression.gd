extends Node

signal xp_gained(amount: int, current_xp: int, xp_needed: int)
signal level_up(new_level: int, stat_points_awarded: int)
signal milestone_reached(level: int, milestone_id: StringName)
signal stat_points_changed(unspent_points: int)
signal stat_allocated(stat_id: StringName, new_total: int)
signal progression_reset

const CORE_STATS: Array[StringName] = [
	&"strength",
	&"dexterity",
	&"vitality",
	&"intellect",
]
const MILESTONE_IDS := {
	10: &"world_opens",
	20: &"identity_emerges",
	30: &"specialization_pronounced",
	40: &"adventurer_era_complete",
}

@export var config: ProgressionConfig = preload(
	"res://Project Chronicle/Resources/Progression/adventurer_era_progression.tres"
)

var current_level := 1
var current_xp := 0
var unspent_stat_points := 0
var _allocated_stats: Dictionary = {}


func _ready() -> void:
	for stat_id: StringName in CORE_STATS:
		_allocated_stats[stat_id] = 0
	var events := get_node_or_null("/root/GameplayEvents")
	if events != null and not events.enemy_defeated.is_connected(_on_enemy_defeated):
		events.enemy_defeated.connect(_on_enemy_defeated)


func gain_xp(amount: int, _source_id: StringName = &"") -> int:
	if amount <= 0 or current_level >= config.maximum_level:
		return 0

	current_xp += amount
	xp_gained.emit(amount, current_xp, get_xp_needed_for_next_level())

	while current_level < config.maximum_level:
		var requirement := get_xp_needed_for_next_level()
		if requirement <= 0 or current_xp < requirement:
			break
		current_xp -= requirement
		current_level += 1
		unspent_stat_points += config.stat_points_per_level
		level_up.emit(current_level, config.stat_points_per_level)
		stat_points_changed.emit(unspent_stat_points)
		if config.milestone_levels.has(current_level):
			milestone_reached.emit(
				current_level,
				MILESTONE_IDS.get(current_level, StringName("level_%d" % current_level))
			)

	xp_gained.emit(0, current_xp, get_xp_needed_for_next_level())
	return amount


func get_xp_needed_for_next_level() -> int:
	return config.get_xp_requirement(current_level)


func allocate_stat(stat_id: StringName, amount: int = 1) -> bool:
	if not CORE_STATS.has(stat_id) or amount <= 0 or unspent_stat_points < amount:
		return false
	_allocated_stats[stat_id] = get_allocated_points(stat_id) + amount
	unspent_stat_points -= amount
	stat_allocated.emit(stat_id, get_allocated_points(stat_id))
	stat_points_changed.emit(unspent_stat_points)
	return true


func get_allocated_points(stat_id: StringName) -> int:
	return int(_allocated_stats.get(stat_id, 0))


func get_allocated_stats() -> Dictionary:
	return _allocated_stats.duplicate(true)


func reset_progression() -> void:
	current_level = 1
	current_xp = 0
	unspent_stat_points = 0
	for stat_id: StringName in CORE_STATS:
		_allocated_stats[stat_id] = 0
	progression_reset.emit()
	stat_points_changed.emit(unspent_stat_points)
	xp_gained.emit(0, current_xp, get_xp_needed_for_next_level())


func _on_enemy_defeated(_enemy_id: String, xp_reward: int, _world_position: Vector2) -> void:
	gain_xp(xp_reward, &"enemy")
