class_name FacingComponent
extends Node

## Single source of horizontal facing for side-view attacks, dodges, and visuals.

var direction := Vector2.RIGHT


func update_from_movement(input_direction: Vector2) -> void:
	if not is_zero_approx(input_direction.x):
		direction = Vector2(signf(input_direction.x), 0.0)


func get_direction() -> Vector2:
	return direction
