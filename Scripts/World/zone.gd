class_name Zone
extends Node2D

@export var zone_data: ZoneData

@onready var _spawn_points: Node2D = $SpawnPoints


func _ready() -> void:
	add_to_group("zone")
	_zone_manager().on_zone_ready(self)


func get_spawn_position(spawn_id: String) -> Vector2:
	if _spawn_points == null:
		return global_position

	var spawn_node := _spawn_points.get_node_or_null(spawn_id)
	if spawn_node is Node2D:
		return (spawn_node as Node2D).global_position

	var default_node := _spawn_points.get_node_or_null("default")
	if default_node is Node2D:
		return (default_node as Node2D).global_position

	if _spawn_points.get_child_count() > 0 and _spawn_points.get_child(0) is Node2D:
		return (_spawn_points.get_child(0) as Node2D).global_position

	return global_position


func _zone_manager():
	return get_node("/root/ZoneManager")
