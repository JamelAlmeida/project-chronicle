class_name CameraPresentation
extends Camera2D

## Side-view framing for Chronicle's action-RPG presentation.
## Zoom and vertical offset keep the Adventurer readable above the bottom HUD.

@export var enable_smoothing := false
@export_range(0.1, 20.0, 0.1) var smoothing_speed := 6.0
@export_range(0.0, 160.0, 1.0) var look_ahead_distance := 56.0
@export_range(1.0, 20.0, 0.5) var look_ahead_speed := 7.0
@export var vertical_offset := -18.0
@export var gameplay_zoom := Vector2(1.62, 1.62)
@export_range(0.0, 12.0, 0.25) var maximum_shake_pixels := 4.0

var _rest_offset := Vector2.ZERO
var _shake_strength := 0.0
var _shake_remaining := 0.0
var _shake_duration := 0.0


func _ready() -> void:
	zoom = gameplay_zoom
	_rest_offset = Vector2(offset.x, vertical_offset)
	offset = _rest_offset
	position_smoothing_enabled = enable_smoothing
	position_smoothing_speed = smoothing_speed
	set_process(false)


func _physics_process(delta: float) -> void:
	var parent_body := get_parent() as CharacterBody2D
	if parent_body == null:
		return

	var facing_sign := signf(parent_body.velocity.x)
	var facing_component := parent_body.get_node_or_null("FacingComponent") as FacingComponent
	if facing_component != null and is_zero_approx(facing_sign):
		facing_sign = signf(facing_component.get_direction().x)
	if is_zero_approx(facing_sign):
		facing_sign = 1.0

	var target_x := facing_sign * look_ahead_distance
	_rest_offset.x = move_toward(_rest_offset.x, target_x, look_ahead_speed * look_ahead_distance * delta)
	if _shake_remaining <= 0.0:
		offset = _rest_offset


func request_shake(strength_pixels: float = 2.0, duration: float = 0.1) -> void:
	if strength_pixels <= 0.0 or duration <= 0.0:
		return
	_shake_strength = minf(strength_pixels, maximum_shake_pixels)
	_shake_duration = duration
	_shake_remaining = duration
	set_process(true)


func _process(delta: float) -> void:
	_shake_remaining = maxf(_shake_remaining - delta, 0.0)
	if _shake_remaining <= 0.0:
		offset = _rest_offset
		set_process(false)
		return

	var fade := _shake_remaining / _shake_duration
	offset = _rest_offset + Vector2(
		randf_range(-_shake_strength, _shake_strength),
		randf_range(-_shake_strength, _shake_strength)
	) * fade
