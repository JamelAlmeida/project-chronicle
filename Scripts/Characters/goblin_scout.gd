extends EnemyBase

enum ScoutState {
	CHASE,
	REPOSITION,
}

@export var reposition_interval := 2.2
@export var reposition_duration := 0.55
@export var reposition_distance := 90.0

var _state: ScoutState = ScoutState.CHASE
var _state_timer := 0.0
var _reposition_direction := Vector2.RIGHT


func _enemy_ready() -> void:
	enemy_id = "goblin_scout"
	xp_reward = 45
	move_speed = 110.0
	max_health = 18
	health = max_health
	attack_damage = 10
	attack_range = 22.0
	attack_cooldown = 0.7
	detection_range = 280.0
	knockback_force_on_hit = 90.0
	if loot_item_id.is_empty():
		loot_item_id = "goblin_tooth"
		loot_quantity = 1
	_state_timer = reposition_interval


func _update_ai(delta: float) -> void:
	velocity = Vector2.ZERO
	if _player == null:
		return

	var to_player := _player.global_position - global_position
	var distance := to_player.length()
	if distance > detection_range:
		return

	_state_timer = maxf(_state_timer - delta, 0.0)

	match _state:
		ScoutState.CHASE:
			velocity = to_player.normalized() * move_speed
			_try_attack_player()
			if _state_timer <= 0.0:
				_begin_reposition(to_player)
		ScoutState.REPOSITION:
			velocity = _reposition_direction * move_speed * 1.15
			if _state_timer <= 0.0:
				_state = ScoutState.CHASE
				_state_timer = reposition_interval


func _begin_reposition(to_player: Vector2) -> void:
	_state = ScoutState.REPOSITION
	_state_timer = reposition_duration
	var away := -to_player.normalized()
	var side := away.orthogonal().normalized()
	if randf() < 0.5:
		side = -side
	_reposition_direction = (away * 0.65 + side * 0.75).normalized()
	if _reposition_direction.length_squared() <= 0.0:
		_reposition_direction = Vector2.RIGHT
