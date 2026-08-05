extends CharacterBody2D

const KNOCKBACK_DECAY := 900.0
const HURT_PRESENTATION_DURATION := 0.18

@export_category("Side-view movement")
@export var move_acceleration := 1500.0
@export var move_deceleration := 1900.0
@export_range(0.0, 1.0, 0.05) var air_control_multiplier := 0.75
@export var gravity_acceleration := 1200.0
@export var maximum_fall_speed := 720.0
@export var jump_velocity := 420.0
@export_range(0.0, 0.3, 0.01) var coyote_time := 0.12
@export_range(0.0, 0.3, 0.01) var jump_buffer_time := 0.12
@export_range(0.1, 1.0, 0.05) var jump_release_multiplier := 0.45
@export_range(0.0, 3.0, 0.05) var death_presentation_delay := 0.0

@onready var _melee_attack: MeleeAttack = $MeleeAttack
@onready var _health: HealthComponent = $HealthComponent
@onready var _facing: FacingComponent = $FacingComponent
@onready var _dodge: DodgeComponent = $DodgeComponent
@onready var _stats: StatsComponent = $StatsComponent
@onready var _equipment: EquipmentComponent = $EquipmentComponent
@onready var _placeholder_visual: CanvasItem = $Visuals/PlaceholderVisual
@onready var _player_sprite: AnimatedSprite2D = $Visuals/PlayerSprite
@onready var _visual_controller: CharacterVisualController = $Visuals/VisualController

var _knockback_velocity := Vector2.ZERO
var _is_dead := false
var _hurt_presentation_remaining := 0.0
var _coyote_remaining := 0.0
var _jump_buffer_remaining := 0.0


func _ready() -> void:
	add_to_group("player")
	_health.damaged.connect(_on_damaged)
	_health.died.connect(_on_died)
	_stats.stats_changed.connect(_on_stats_changed)
	_sync_health_from_stats()
	_visual_controller.refresh_art_assignment()


func _physics_process(delta: float) -> void:
	if _is_dead:
		velocity.x = move_toward(velocity.x, 0.0, move_deceleration * delta)
		_apply_gravity(delta)
		move_and_slide()
		_update_presentation(delta)
		return

	_health.set_external_invulnerability(_dodge.get_iframes_active())
	_update_jump_timers(delta)

	var input_axis := Input.get_axis("move_left", "move_right")
	var horizontal_direction := Vector2(input_axis, 0.0)
	if not is_zero_approx(input_axis) and not _melee_attack.is_attacking():
		_facing.update_from_movement(horizontal_direction)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_remaining = jump_buffer_time
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_release_multiplier

	if _knockback_velocity.length_squared() > 4.0:
		velocity = _knockback_velocity
		_apply_gravity(delta)
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
		move_and_slide()
		_update_presentation(delta)
		return

	_knockback_velocity = Vector2.ZERO

	if (
		Input.is_action_just_pressed("dodge")
		and not _dodge.is_dodging()
		and not _melee_attack.is_attacking()
		and is_on_floor()
	):
		var dodge_direction := horizontal_direction
		if dodge_direction.length_squared() <= 0.0:
			dodge_direction = _facing.get_direction()
		_dodge.try_dodge(Vector2(signf(dodge_direction.x), 0.0))

	if _dodge.is_dodging():
		velocity.x = _dodge.get_dodge_velocity().x
		_apply_gravity(delta)
	else:
		_update_horizontal_velocity(input_axis, delta)
		_apply_gravity(delta)
		_try_consume_buffered_jump()

	move_and_slide()

	if Input.is_action_just_pressed("attack") and not _dodge.is_dodging():
		_melee_attack.try_attack(_facing.get_direction())
	_update_presentation(delta)


func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> bool:
	if _is_dead:
		return false

	if not _health.take_damage(amount):
		return false

	if knockback.length_squared() > 0.0:
		_knockback_velocity = knockback

	_combat_feedback().spawn_damage_number(global_position, amount, Color(1.0, 0.35, 0.35))
	_combat_feedback().spawn_damage_particles(global_position)
	return true


func get_stats_component() -> StatsComponent:
	return _stats


func get_equipment_component() -> EquipmentComponent:
	return _equipment


func _update_horizontal_velocity(input_axis: float, delta: float) -> void:
	var target_speed := input_axis * _stats.get_move_speed()
	var rate := move_acceleration if not is_zero_approx(input_axis) else move_deceleration
	if not is_on_floor():
		rate *= air_control_multiplier
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)


func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y >= 0.0:
		velocity.y = 0.0
		return
	velocity.y = minf(velocity.y + gravity_acceleration * delta, maximum_fall_speed)


func _update_jump_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_remaining = coyote_time
	else:
		_coyote_remaining = maxf(_coyote_remaining - delta, 0.0)
	_jump_buffer_remaining = maxf(_jump_buffer_remaining - delta, 0.0)


func _try_consume_buffered_jump() -> void:
	if _jump_buffer_remaining <= 0.0 or _coyote_remaining <= 0.0:
		return
	velocity.y = -jump_velocity
	_jump_buffer_remaining = 0.0
	_coyote_remaining = 0.0


func _on_damaged(_amount: int, _remaining: int) -> void:
	_hurt_presentation_remaining = HURT_PRESENTATION_DURATION
	_combat_feedback().flash_node(_get_body_visual())


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	_update_presentation(0.0)
	if death_presentation_delay > 0.0:
		await get_tree().create_timer(death_presentation_delay).timeout
		if not is_inside_tree():
			return
	_zone_manager().handle_player_death()


func _on_stats_changed() -> void:
	_sync_health_from_stats()


func _sync_health_from_stats() -> void:
	_health.set_max_health(int(_stats.get_max_health()))


func _get_body_visual() -> CanvasItem:
	if _player_sprite.visible:
		return _player_sprite
	return _placeholder_visual


func _update_presentation(delta: float) -> void:
	_hurt_presentation_remaining = maxf(_hurt_presentation_remaining - delta, 0.0)
	_visual_controller.update_presentation(
		_is_dead,
		_hurt_presentation_remaining > 0.0,
		_dodge.is_dodging(),
		_melee_attack.is_attacking(),
		velocity,
		_facing.get_direction()
	)


func _inventory():
	return get_node("/root/Inventory")


func _combat_feedback():
	return get_node("/root/CombatFeedback")


func _zone_manager():
	return get_node("/root/ZoneManager")
