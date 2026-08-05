class_name MeleeAttack
extends Area2D

const _StatsComponentScript := preload("res://Project Chronicle/Scripts/Components/stats_component.gd")
const _EquipmentComponentScript := preload("res://Project Chronicle/Scripts/Components/equipment_component.gd")

signal attack_started
signal attack_finished

@export var active_duration := 0.12
@export var knockback_force := 120.0

var _cooldown_remaining := 0.0
var _is_attacking := false
var _hit_targets: Array[Node] = []

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _visual: CanvasItem = $AttackVisual


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_deactivate_hitbox()


func _physics_process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)


func try_attack(facing: Vector2) -> bool:
	if _is_attacking or _cooldown_remaining > 0.0:
		return false

	var direction := Vector2.RIGHT
	if facing.x < 0.0:
		direction = Vector2.LEFT
	_perform_attack(direction)
	return true


func is_attacking() -> bool:
	return _is_attacking


func _perform_attack(direction: Vector2) -> void:
	_is_attacking = true
	_cooldown_remaining = _get_attack_cooldown()
	_hit_targets.clear()

	rotation = 0.0 if direction.x >= 0.0 else PI
	_activate_hitbox()
	attack_started.emit()
	_combat_feedback().spawn_weapon_trail(global_position, rotation)

	await get_tree().create_timer(active_duration).timeout

	_deactivate_hitbox()
	_is_attacking = false
	attack_finished.emit()


func _get_attack_cooldown() -> float:
	var stats: StatsComponent = _get_stats_component()
	var equipment: EquipmentComponent = _get_equipment_component()
	if stats == null:
		return 0.4

	var base_cooldown: float = 0.4
	if equipment != null:
		base_cooldown = equipment.get_weapon_attack_cooldown()

	return base_cooldown / stats.get_attack_speed()


func _calculate_damage() -> int:
	var stats: StatsComponent = _get_stats_component()
	if stats == null:
		return 10

	var damage: float = stats.get_attack_damage()
	if randf() < stats.get_crit_chance():
		damage *= 2.0

	return maxi(int(round(damage)), 1)


func _apply_lifesteal(damage_dealt: int) -> void:
	var stats: StatsComponent = _get_stats_component()
	if stats == null or damage_dealt <= 0:
		return

	var lifesteal_ratio: float = stats.get_lifesteal()
	if lifesteal_ratio <= 0.0:
		return

	var heal_amount: int = int(floor(float(damage_dealt) * lifesteal_ratio))
	if heal_amount <= 0:
		return

	var health: HealthComponent = get_parent().get_node("HealthComponent") as HealthComponent
	if health != null:
		health.heal(heal_amount)


func _get_stats_component() -> StatsComponent:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return null
	return parent_node.get_node("StatsComponent") as StatsComponent


func _get_equipment_component() -> EquipmentComponent:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return null
	return parent_node.get_node("EquipmentComponent") as EquipmentComponent


func _combat_feedback():
	return get_node("/root/CombatFeedback")


func _activate_hitbox() -> void:
	_collision_shape.disabled = false
	_visual.visible = true


func _deactivate_hitbox() -> void:
	_collision_shape.disabled = true
	_visual.visible = false


func _on_body_entered(body: Node) -> void:
	if body == get_parent() or body in _hit_targets:
		return

	if not body.has_method("take_damage"):
		return

	if not body is Node2D:
		return

	var target_body: Node2D = body as Node2D
	var damage_dealt: int = _calculate_damage()
	_hit_targets.append(body)
	var horizontal_delta := target_body.global_position.x - (get_parent() as Node2D).global_position.x
	var knockback_direction := Vector2(signf(horizontal_delta), 0.0)
	if is_zero_approx(knockback_direction.x):
		knockback_direction = Vector2.RIGHT if rotation == 0.0 else Vector2.LEFT
	body.take_damage(damage_dealt, knockback_direction * knockback_force)
	_apply_lifesteal(damage_dealt)
