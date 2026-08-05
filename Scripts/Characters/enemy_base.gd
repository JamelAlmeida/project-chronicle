class_name EnemyBase
extends CharacterBody2D

const HIT_STUN_DURATION := 0.15
const ATTACK_PRESENTATION_DURATION := 0.2

@export var move_speed := 60.0
@export var max_health := 30
@export var attack_damage := 15
@export var attack_range := 26.0
@export var attack_cooldown := 1.0
@export var detection_range := 250.0
@export var loot_item_id := ""
@export var loot_quantity := 1
@export var knockback_force_on_hit := 140.0

var health := 30
var _player: Node2D
var _knockback_velocity := Vector2.ZERO
var _hit_stun_remaining := 0.0
var _attack_cooldown_remaining := 0.0
var _attack_presentation_remaining := 0.0
var _is_dead := false
var _visual_facing := Vector2.DOWN

@onready var _placeholder_visual: CanvasItem = get_node_or_null("Visuals/PlaceholderVisual")
@onready var _character_sprite: AnimatedSprite2D = get_node_or_null("Visuals/CharacterSprite")
@onready var _visual_controller: CharacterVisualController = get_node_or_null("Visuals/VisualController")


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	_resolve_player()
	if _visual_controller != null:
		_visual_controller.refresh_art_assignment()
	_enemy_ready()


func _enemy_ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if _attack_cooldown_remaining > 0.0:
		_attack_cooldown_remaining = maxf(_attack_cooldown_remaining - delta, 0.0)
	if _attack_presentation_remaining > 0.0:
		_attack_presentation_remaining = maxf(_attack_presentation_remaining - delta, 0.0)

	if _is_dead:
		velocity = Vector2.ZERO
		_update_presentation()
		return

	if _player == null or not is_instance_valid(_player):
		_resolve_player()

	if _hit_stun_remaining > 0.0:
		_hit_stun_remaining = maxf(_hit_stun_remaining - delta, 0.0)
		velocity = _knockback_velocity
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 480.0 * delta)
		move_and_slide()
		_update_presentation()
		return

	_update_ai(delta)
	move_and_slide()
	_update_presentation()


func _update_ai(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _player == null:
		return

	var to_player := _player.global_position - global_position
	if to_player.length() <= detection_range:
		velocity = to_player.normalized() * move_speed

	_try_attack_player()


func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if health <= 0:
		return

	health -= amount
	_combat_feedback().spawn_damage_number(global_position, amount, Color(1.0, 0.85, 0.3))
	_combat_feedback().spawn_damage_particles(global_position)
	_apply_hit_reaction(knockback)

	if health <= 0:
		_on_defeated()


func _try_attack_player() -> bool:
	if _player == null or _attack_cooldown_remaining > 0.0:
		return false

	if global_position.distance_to(_player.global_position) > attack_range:
		return false

	if not _player.has_method("take_damage"):
		return false

	var knockback := Vector2.ZERO
	if knockback_force_on_hit > 0.0:
		knockback = (_player.global_position - global_position).normalized() * knockback_force_on_hit

	if _player.take_damage(attack_damage, knockback):
		_attack_cooldown_remaining = attack_cooldown
		_begin_attack_presentation()
		return true
	return false


func _apply_hit_reaction(knockback: Vector2) -> void:
	_knockback_velocity = knockback
	_hit_stun_remaining = HIT_STUN_DURATION
	_combat_feedback().flash_node(_get_body_visual())


func _on_defeated() -> void:
	_is_dead = true
	_update_presentation()
	if _visual_controller != null:
		_visual_controller.spawn_detached_death_animation()
	_combat_feedback().spawn_enemy_death_effect(global_position)
	_drop_loot()
	queue_free()


func _begin_attack_presentation(duration: float = ATTACK_PRESENTATION_DURATION) -> void:
	_attack_presentation_remaining = maxf(duration, 0.0)


func _drop_loot() -> void:
	if loot_item_id.is_empty() or loot_quantity <= 0:
		return
	var parent := get_parent()
	if parent == null:
		return
	LootPickup.spawn(parent, global_position, loot_item_id, loot_quantity)


func _resolve_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D


func _get_body_visual() -> CanvasItem:
	if _character_sprite != null and _character_sprite.visible:
		return _character_sprite
	return _placeholder_visual


func _update_presentation() -> void:
	if velocity.length_squared() > 1.0 and _hit_stun_remaining <= 0.0:
		_visual_facing = velocity.normalized()
	elif _player != null and is_instance_valid(_player):
		var to_player := _player.global_position - global_position
		if to_player.length_squared() > 0.001:
			_visual_facing = to_player.normalized()

	if _visual_controller != null:
		_visual_controller.update_presentation(
			_is_dead,
			_hit_stun_remaining > 0.0,
			false,
			_attack_presentation_remaining > 0.0,
			velocity,
			_visual_facing
		)


func _combat_feedback():
	return get_node("/root/CombatFeedback")
