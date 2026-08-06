extends EnemyBase

enum GuardianState {
	IDLE,
	APPROACH,
	TELEGRAPH,
	STRIKE,
	RECOVER,
}

@export var telegraph_duration := 0.7
@export var strike_duration := 0.18
@export var recover_duration := 0.55
@export var strike_range := 42.0

var _state: GuardianState = GuardianState.IDLE
var _state_timer := 0.0

@onready var _telegraph_visual: CanvasItem = get_node_or_null("Visuals/TelegraphVisual")


func _enemy_ready() -> void:
	enemy_id = "crypt_guardian"
	xp_reward = 160
	move_speed = 45.0
	max_health = 120
	health = max_health
	attack_damage = 28
	attack_range = strike_range
	attack_cooldown = 1.6
	detection_range = 320.0
	knockback_force_on_hit = 260.0
	if loot_item_id.is_empty():
		loot_item_id = "slime_gel"
		loot_quantity = 3
	_set_telegraph_visible(false)


func _update_ai(delta: float) -> void:
	velocity = Vector2.ZERO
	if _player == null:
		_set_telegraph_visible(false)
		return

	var to_player := _player.global_position - global_position
	var distance := to_player.length()

	if _state_timer > 0.0:
		_state_timer = maxf(_state_timer - delta, 0.0)

	match _state:
		GuardianState.IDLE:
			_set_telegraph_visible(false)
			if distance <= detection_range:
				_state = GuardianState.APPROACH

		GuardianState.APPROACH:
			_set_telegraph_visible(false)
			if distance > detection_range:
				_state = GuardianState.IDLE
				return
			velocity = to_player.normalized() * move_speed
			if distance <= strike_range and _attack_cooldown_remaining <= 0.0:
				_state = GuardianState.TELEGRAPH
				_state_timer = telegraph_duration
				_set_telegraph_visible(true)

		GuardianState.TELEGRAPH:
			_set_telegraph_visible(true)
			velocity = Vector2.ZERO
			if _state_timer <= 0.0:
				_state = GuardianState.STRIKE
				_state_timer = strike_duration
				_perform_guardian_strike(to_player)

		GuardianState.STRIKE:
			_set_telegraph_visible(false)
			velocity = to_player.normalized() * (move_speed * 0.35)
			if _state_timer <= 0.0:
				_state = GuardianState.RECOVER
				_state_timer = recover_duration

		GuardianState.RECOVER:
			_set_telegraph_visible(false)
			velocity = Vector2.ZERO
			if _state_timer <= 0.0:
				_state = GuardianState.APPROACH


func _perform_guardian_strike(to_player: Vector2) -> void:
	_begin_attack_presentation(strike_duration)
	if _player == null or not _player.has_method("take_damage"):
		return

	if global_position.distance_to(_player.global_position) > strike_range + 10.0:
		_attack_cooldown_remaining = attack_cooldown * 0.5
		return

	if _player.has_method("is_hurtbox_hit_by_point"):
		var aim := Vector2(_player.global_position.x, global_position.y - attack_hit_height)
		if not bool(_player.call("is_hurtbox_hit_by_point", aim)):
			_attack_cooldown_remaining = attack_cooldown * 0.35
			return

	var knockback := to_player.normalized() * knockback_force_on_hit
	if _player.take_damage(attack_damage, knockback):
		_attack_cooldown_remaining = attack_cooldown


func _set_telegraph_visible(visible_flag: bool) -> void:
	if _telegraph_visual != null:
		_telegraph_visual.visible = visible_flag
