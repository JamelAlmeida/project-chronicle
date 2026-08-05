class_name CameraPresentation
extends Camera2D

## Optional camera polish. Defaults preserve the existing camera behavior.

@export var enable_smoothing := false
@export_range(0.1, 20.0, 0.1) var smoothing_speed := 6.0
@export_range(0.0, 12.0, 0.25) var maximum_shake_pixels := 4.0

var _rest_offset := Vector2.ZERO
var _shake_strength := 0.0
var _shake_remaining := 0.0
var _shake_duration := 0.0


func _ready() -> void:
	_rest_offset = offset
	position_smoothing_enabled = enable_smoothing
	position_smoothing_speed = smoothing_speed
	set_process(false)


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
