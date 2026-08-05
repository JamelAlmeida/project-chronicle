extends CharacterBody2D

const KNOCKBACK_DECAY := 900.0
const HURT_PRESENTATION_DURATION := 0.18

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


func _ready() -> void:
	add_to_group("player")
	_health.damaged.connect(_on_damaged)
	_health.died.connect(_on_died)
	_stats.stats_changed.connect(_on_stats_changed)
	_sync_health_from_stats()
	_visual_controller.refresh_art_assignment()


func _physics_process(_delta: float) -> void:
	if _is_dead:
		velocity = Vector2.ZERO
		_update_presentation(_delta)
		return

	_health.set_external_invulnerability(_dodge.get_iframes_active())

	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	if _knockback_velocity.length_squared() > 4.0:
		velocity = _knockback_velocity
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * _delta)
		move_and_slide()
		_update_presentation(_delta)
		return

	_knockback_velocity = Vector2.ZERO

	if not _dodge.is_dodging():
		if not _melee_attack.is_attacking():
			_facing.update_from_movement(direction)

		var dodge_direction: Vector2 = direction if direction.length_squared() > 0.0 else _facing.get_direction()
		if Input.is_action_just_pressed("dodge"):
			_dodge.try_dodge(dodge_direction)

	if _dodge.is_dodging():
		velocity = _dodge.get_dodge_velocity()
	else:
		velocity = direction * _stats.get_move_speed()

	move_and_slide()

	if Input.is_action_just_pressed("attack"):
		var attack_direction := _get_mouse_attack_direction()
		_facing.update_from_movement(attack_direction)
		_melee_attack.try_attack(attack_direction)
	_update_presentation(_delta)


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


func _get_mouse_attack_direction() -> Vector2:
	var to_mouse := get_global_mouse_position() - global_position
	if to_mouse.length_squared() <= 0.001:
		return _facing.get_direction()
	return to_mouse.normalized()


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
