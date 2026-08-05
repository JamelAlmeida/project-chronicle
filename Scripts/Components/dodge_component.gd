class_name DodgeComponent
extends Node

signal dodge_started
signal dodge_finished

@export var dodge_speed := 450.0
@export var dodge_duration := 0.2
@export var dodge_cooldown := 0.8
@export var iframes_start := 0.05
@export var iframes_end := 0.15

var _cooldown_remaining := 0.0
var _is_dodging := false
var _dodge_time_remaining := 0.0
var _dodge_direction := Vector2.RIGHT


func _physics_process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)

	if not _is_dodging:
		return

	_dodge_time_remaining = maxf(_dodge_time_remaining - delta, 0.0)
	if _dodge_time_remaining <= 0.0:
		_is_dodging = false
		dodge_finished.emit()


func try_dodge(direction: Vector2) -> bool:
	if _is_dodging or _cooldown_remaining > 0.0:
		return false

	var dodge_direction: Vector2 = direction.normalized() if direction.length_squared() > 0.0 else Vector2.RIGHT
	_start_dodge(dodge_direction)
	return true


func is_dodging() -> bool:
	return _is_dodging


func get_dodge_velocity() -> Vector2:
	if not _is_dodging:
		return Vector2.ZERO
	return _dodge_direction * dodge_speed * (1.0 + _get_dash_enhancement())


func get_iframes_active() -> bool:
	if not _is_dodging:
		return false

	var elapsed: float = dodge_duration - _dodge_time_remaining
	return elapsed >= iframes_start and elapsed <= iframes_end


func _start_dodge(direction: Vector2) -> void:
	_is_dodging = true
	_dodge_time_remaining = dodge_duration
	_dodge_direction = direction
	_cooldown_remaining = dodge_cooldown * (1.0 - _get_dash_enhancement())
	dodge_started.emit()
	var events := get_node_or_null("/root/GameplayEvents")
	if events != null:
		events.dodge_used.emit()


func _get_dash_enhancement() -> float:
	var techniques := get_node_or_null("/root/TechniqueManager")
	if techniques == null:
		return 0.0
	return clampf(techniques.get_effect_value(&"dash_enhancement"), 0.0, 0.75)
