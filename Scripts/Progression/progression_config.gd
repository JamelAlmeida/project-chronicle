class_name ProgressionConfig
extends Resource

@export_range(1, 200, 1) var maximum_level := 100
@export_range(1, 10000, 1) var base_xp_requirement := 50
@export_range(0, 1000, 1) var linear_xp_growth := 18
@export_range(0.0, 1000.0, 1.0) var curved_xp_growth := 8.0
@export_range(1.0, 3.0, 0.05) var curve_exponent := 1.45
@export_range(0, 10, 1) var stat_points_per_level := 1
@export var milestone_levels: PackedInt32Array = PackedInt32Array([10, 20, 30, 40])


func get_xp_requirement(level: int) -> int:
	if level >= maximum_level:
		return 0
	var level_index := maxi(level - 1, 0)
	return maxi(
		int(round(
			float(base_xp_requirement)
			+ float(linear_xp_growth * level_index)
			+ curved_xp_growth * pow(float(level_index), curve_exponent)
		)),
		1
	)
