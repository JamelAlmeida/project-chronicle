extends Node

const DAMAGE_NUMBER_SCENE := preload("res://Project Chronicle/Scenes/UI/damage_number.tscn")

const EFFECT_DAMAGE_PARTICLES: StringName = &"damage_particles"
const EFFECT_ENEMY_DEATH: StringName = &"enemy_death"
const EFFECT_LOOT_SPARKLE: StringName = &"loot_sparkle"
const EFFECT_WEAPON_TRAIL: StringName = &"weapon_trail"

var _effect_scenes: Dictionary[StringName, PackedScene] = {}


func spawn_damage_number(world_position: Vector2, amount: int, color: Color = Color.WHITE) -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var damage_number: Node2D = DAMAGE_NUMBER_SCENE.instantiate()
	scene_root.add_child(damage_number)
	damage_number.global_position = world_position + Vector2(0.0, -24.0)
	if damage_number.has_method("setup"):
		damage_number.setup(str(amount), color)


func flash_node(node: CanvasItem, flash_color: Color = Color(2.5, 2.5, 2.5, 1.0), duration: float = 0.12) -> void:
	if node == null:
		return

	node.modulate = flash_color
	var tween := node.create_tween()
	tween.tween_property(node, "modulate", Color.WHITE, duration)


func register_effect(effect_name: StringName, scene: PackedScene) -> void:
	if scene == null:
		_effect_scenes.erase(effect_name)
		return
	_effect_scenes[effect_name] = scene


func spawn_damage_particles(world_position: Vector2) -> Node2D:
	return spawn_optional_effect(EFFECT_DAMAGE_PARTICLES, world_position)


func spawn_enemy_death_effect(world_position: Vector2) -> Node2D:
	return spawn_optional_effect(EFFECT_ENEMY_DEATH, world_position)


func spawn_loot_sparkle(world_position: Vector2, parent: Node = null) -> Node2D:
	return spawn_optional_effect(EFFECT_LOOT_SPARKLE, world_position, parent)


func spawn_weapon_trail(world_position: Vector2, rotation_radians: float) -> Node2D:
	var effect := spawn_optional_effect(EFFECT_WEAPON_TRAIL, world_position)
	if effect != null:
		effect.global_rotation = rotation_radians
	return effect


func spawn_optional_effect(
	effect_name: StringName,
	world_position: Vector2,
	parent: Node = null
) -> Node2D:
	var effect_scene: PackedScene = _effect_scenes.get(effect_name)
	if effect_scene == null:
		return null

	var effect := effect_scene.instantiate() as Node2D
	if effect == null:
		return null

	var effect_parent := parent if parent != null else get_tree().current_scene
	if effect_parent == null:
		effect.queue_free()
		return null

	effect_parent.add_child(effect)
	effect.global_position = world_position
	return effect
