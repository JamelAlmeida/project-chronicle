class_name ZoneTransition
extends Area2D

@export_file("*.tscn") var target_scene: String = ""
@export var target_spawn_id: String = "default"
@export var require_interact: bool = false
@export var prompt_text: String = "Enter"

var _player_inside: Node = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1


func _unhandled_input(event: InputEvent) -> void:
	if not require_interact:
		return
	if _player_inside == null:
		return
	if event.is_action_pressed("interact"):
		_trigger_transition()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = body
	if not require_interact:
		_trigger_transition()


func _on_body_exited(body: Node) -> void:
	if body == _player_inside:
		_player_inside = null


func _trigger_transition() -> void:
	if target_scene.is_empty():
		return
	_zone_manager().transition_to(target_scene, target_spawn_id)


func _zone_manager():
	return get_node("/root/ZoneManager")
