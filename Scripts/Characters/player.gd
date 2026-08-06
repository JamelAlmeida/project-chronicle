extends CharacterBody2D

const KNOCKBACK_DECAY := 900.0
## Matches 3-frame hurt clip at 12 fps (~0.25s). Presentation only; does not lock controls.
const HURT_PRESENTATION_DURATION := 0.25
const JUMP_TAKEOFF_DURATION := 0.06

const STANDING_COLLISION_SIZE := Vector2(22, 38)
const STANDING_COLLISION_OFFSET := Vector2(0, -19)
const PRONE_COLLISION_SIZE := Vector2(34, 12)
const PRONE_COLLISION_OFFSET := Vector2(0, -6)

const STANDING_HURTBOX_SIZE := Vector2(20, 36)
const STANDING_HURTBOX_OFFSET := Vector2(0, -20)
const PRONE_HURTBOX_SIZE := Vector2(32, 10)
const PRONE_HURTBOX_OFFSET := Vector2(0, -5)

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
@export_range(0.0, 3.0, 0.05) var death_presentation_delay := 0.9

@onready var _melee_attack: MeleeAttack = $MeleeAttack
@onready var _health: HealthComponent = $HealthComponent
@onready var _facing: FacingComponent = $FacingComponent
@onready var _dodge: DodgeComponent = $DodgeComponent
@onready var _stats: StatsComponent = $StatsComponent
@onready var _equipment: EquipmentComponent = $EquipmentComponent
@onready var _placeholder_visual: CanvasItem = $Visuals/PlaceholderVisual
@onready var _player_sprite: AnimatedSprite2D = $Visuals/BaseCharacter
@onready var _visual_controller: CharacterVisualController = $Visuals/VisualController
@onready var _body_collision: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D

var _knockback_velocity := Vector2.ZERO
var _is_dead := false
var _hurt_presentation_remaining := 0.0
var _coyote_remaining := 0.0
var _jump_buffer_remaining := 0.0
var _jump_takeoff_remaining := 0.0
var _is_prone := false
var _standing_collision_shape: RectangleShape2D
var _prone_collision_shape: RectangleShape2D
var _standing_hurtbox_shape: RectangleShape2D
var _prone_hurtbox_shape: RectangleShape2D


func _ready() -> void:
	add_to_group("player")
	_health.damaged.connect(_on_damaged)
	_health.died.connect(_on_died)
	_stats.stats_changed.connect(_on_stats_changed)
	_sync_health_from_stats()
	_setup_collision_profiles()
	_apply_collision_profile(false)
	_visual_controller.refresh_art_assignment()


func _physics_process(delta: float) -> void:
	if _is_dead:
		velocity.x = move_toward(velocity.x, 0.0, move_deceleration * delta)
		_apply_gravity(delta)
		move_and_slide()
		_update_presentation(delta)
		return

	if _is_gameplay_input_blocked():
		velocity.x = move_toward(velocity.x, 0.0, move_deceleration * delta)
		_apply_gravity(delta)
		move_and_slide()
		_update_presentation(delta)
		return

	_health.set_external_invulnerability(_dodge.get_iframes_active())
	_update_jump_timers(delta)
	_jump_takeoff_remaining = maxf(_jump_takeoff_remaining - delta, 0.0)

	var input_axis := Input.get_axis("move_left", "move_right")
	var horizontal_direction := Vector2(input_axis, 0.0)
	if not is_zero_approx(input_axis) and not _melee_attack.is_attacking() and not _is_prone:
		_facing.update_from_movement(horizontal_direction)

	_update_prone_state()

	if Input.is_action_just_pressed("jump") and not _is_prone:
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
		and not _is_prone
		and is_on_floor()
	):
		var dodge_direction := horizontal_direction
		if dodge_direction.length_squared() <= 0.0:
			dodge_direction = _facing.get_direction()
		_dodge.try_dodge(Vector2(signf(dodge_direction.x), 0.0))

	if _dodge.is_dodging():
		velocity.x = _dodge.get_dodge_velocity().x
		_apply_gravity(delta)
	elif _is_prone:
		velocity.x = move_toward(velocity.x, 0.0, move_deceleration * delta)
		_apply_gravity(delta)
	else:
		_update_horizontal_velocity(input_axis, delta)
		_apply_gravity(delta)
		_try_consume_buffered_jump()

	move_and_slide()

	if not _is_prone and not _dodge.is_dodging():
		if (
			Input.is_action_just_pressed("technique_primary")
			or Input.is_action_just_pressed("action_slot_1")
		):
			var technique_id: String = _technique_manager().get_equipped_active(0)
			if not technique_id.is_empty():
				_melee_attack.try_technique(technique_id, _facing.get_direction())
		if Input.is_action_just_pressed("attack"):
			_melee_attack.try_attack(_facing.get_direction())
	_update_presentation(delta)


func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> bool:
	if _is_dead:
		return false

	var armor := maxf(_stats.get_armor(), 0.0)
	var mitigated_amount := maxi(int(round(float(amount) * 100.0 / (100.0 + armor))), 1)
	if not _health.take_damage(mitigated_amount):
		var avoided_events := get_node_or_null("/root/GameplayEvents")
		if avoided_events != null:
			avoided_events.damage_avoided.emit(&"invulnerable")
		return false

	if knockback.length_squared() > 0.0:
		_knockback_velocity = knockback

	_combat_feedback().spawn_damage_number(global_position, mitigated_amount, &"player")
	_combat_feedback().spawn_damage_particles(global_position)
	var events := get_node_or_null("/root/GameplayEvents")
	if events != null:
		events.damage_taken.emit(mitigated_amount, _health.current_health)
	return true


func get_stats_component() -> StatsComponent:
	return _stats


func get_equipment_component() -> EquipmentComponent:
	return _equipment


func is_prone() -> bool:
	return _is_prone


func get_hurtbox_global_rect() -> Rect2:
	var shape := _hurtbox_shape.shape as RectangleShape2D
	if shape == null:
		return Rect2(global_position, Vector2.ZERO)
	var size := shape.size
	var top_left := _hurtbox_shape.global_position - size * 0.5
	return Rect2(top_left, size)


func is_hurtbox_hit_by_point(world_point: Vector2) -> bool:
	return get_hurtbox_global_rect().has_point(world_point)


func _setup_collision_profiles() -> void:
	_standing_collision_shape = RectangleShape2D.new()
	_standing_collision_shape.size = STANDING_COLLISION_SIZE
	_prone_collision_shape = RectangleShape2D.new()
	_prone_collision_shape.size = PRONE_COLLISION_SIZE
	_standing_hurtbox_shape = RectangleShape2D.new()
	_standing_hurtbox_shape.size = STANDING_HURTBOX_SIZE
	_prone_hurtbox_shape = RectangleShape2D.new()
	_prone_hurtbox_shape.size = PRONE_HURTBOX_SIZE


func _apply_collision_profile(prone: bool) -> void:
	if prone:
		_body_collision.shape = _prone_collision_shape
		_body_collision.position = PRONE_COLLISION_OFFSET
		_hurtbox_shape.shape = _prone_hurtbox_shape
		_hurtbox_shape.position = PRONE_HURTBOX_OFFSET
	else:
		_body_collision.shape = _standing_collision_shape
		_body_collision.position = STANDING_COLLISION_OFFSET
		_hurtbox_shape.shape = _standing_hurtbox_shape
		_hurtbox_shape.position = STANDING_HURTBOX_OFFSET


func _update_prone_state() -> void:
	if not is_on_floor() or _dodge.is_dodging() or _is_dead:
		if _is_prone:
			_try_stand_from_prone(true)
		return

	var wants_prone := Input.is_action_pressed("move_down")
	if wants_prone and not _is_prone:
		_is_prone = true
		_jump_buffer_remaining = 0.0
		_apply_collision_profile(true)
	elif not wants_prone and _is_prone:
		_try_stand_from_prone(false)


func _try_stand_from_prone(force: bool) -> void:
	if not _is_prone:
		return
	if force or _has_stand_clearance():
		_is_prone = false
		_apply_collision_profile(false)


func _has_stand_clearance() -> bool:
	var previous_shape := _body_collision.shape
	var previous_offset := _body_collision.position
	_body_collision.shape = _standing_collision_shape
	_body_collision.position = STANDING_COLLISION_OFFSET
	var blocked := test_move(global_transform, Vector2.ZERO)
	_body_collision.shape = previous_shape
	_body_collision.position = previous_offset
	return not blocked


func _is_gameplay_input_blocked() -> bool:
	var menu := get_tree().get_first_node_in_group("chronicle_menu")
	return menu != null and bool(menu.call("is_panel_open"))


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
	if _is_prone:
		return
	if _jump_buffer_remaining <= 0.0 or _coyote_remaining <= 0.0:
		return
	velocity.y = -jump_velocity
	_jump_buffer_remaining = 0.0
	_coyote_remaining = 0.0
	_jump_takeoff_remaining = JUMP_TAKEOFF_DURATION


func _on_damaged(_amount: int, _remaining: int) -> void:
	_hurt_presentation_remaining = HURT_PRESENTATION_DURATION
	_combat_feedback().flash_node(_get_body_visual())


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	_is_prone = false
	_apply_collision_profile(false)
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
		_facing.get_direction(),
		is_on_floor(),
		_is_prone,
		_jump_takeoff_remaining > 0.0
	)


func _inventory():
	return get_node("/root/Inventory")


func _combat_feedback():
	return get_node("/root/CombatFeedback")


func _zone_manager():
	return get_node("/root/ZoneManager")


func _technique_manager():
	return get_node("/root/TechniqueManager")
