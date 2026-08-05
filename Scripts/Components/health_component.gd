class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal damaged(amount: int, remaining: int)
signal died

@export var max_health := 100
@export var invulnerability_duration := 0.6

var current_health := 100
var _invulnerability_remaining := 0.0
var _external_invulnerability := false


func _ready() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	if _invulnerability_remaining > 0.0:
		_invulnerability_remaining = maxf(_invulnerability_remaining - delta, 0.0)


func is_invulnerable() -> bool:
	return _invulnerability_remaining > 0.0 or _external_invulnerability


func set_external_invulnerability(enabled: bool) -> void:
	_external_invulnerability = enabled


func set_max_health(value: int) -> void:
	max_health = maxi(value, 1)
	current_health = mini(current_health, max_health)
	health_changed.emit(current_health, max_health)


func set_current_health(value: int) -> void:
	current_health = clampi(value, 0, max_health)
	health_changed.emit(current_health, max_health)


func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return

	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> bool:
	if amount <= 0 or current_health <= 0 or is_invulnerable():
		return false

	current_health = maxi(current_health - amount, 0)
	_invulnerability_remaining = invulnerability_duration
	damaged.emit(amount, current_health)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit()

	return true
