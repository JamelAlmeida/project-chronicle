class_name FacingComponent
extends Node

## Single source of facing for attacks, dodges, and future animations
## (idle/walk/attack: down, up, left, right).

var direction := Vector2.RIGHT


func update_from_movement(input_direction: Vector2) -> void:
	if input_direction.length_squared() > 0.0:
		direction = input_direction.normalized()


func get_direction() -> Vector2:
	return direction
