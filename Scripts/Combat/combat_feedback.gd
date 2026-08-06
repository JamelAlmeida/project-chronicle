extends Node

const DAMAGE_NUMBER_SCENE := preload("res://Project Chronicle/Scenes/UI/damage_number.tscn")

const EFFECT_DAMAGE_PARTICLES: StringName = &"damage_particles"
const EFFECT_ENEMY_DEATH: StringName = &"enemy_death"
const EFFECT_LOOT_SPARKLE: StringName = &"loot_sparkle"
const EFFECT_WEAPON_TRAIL: StringName = &"weapon_trail"

const DAMAGE_STANDARD: StringName = &"standard"
const DAMAGE_CRITICAL: StringName = &"critical"
const DAMAGE_PLAYER: StringName = &"player"

var _effect_scenes: Dictionary[StringName, PackedScene] = {}


func spawn_damage_number(
	world_position: Vector2,
	amount: int,
	kind: StringName = DAMAGE_STANDARD
) -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var damage_number: Node2D = DAMAGE_NUMBER_SCENE.instantiate()
	scene_root.add_child(damage_number)
	damage_number.global_position = world_position + Vector2(0.0, -24.0)
	if damage_number.has_method("setup"):
		damage_number.setup(str(amount), kind)


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
	var custom_effect := spawn_optional_effect(EFFECT_DAMAGE_PARTICLES, world_position)
	return custom_effect if custom_effect != null else _spawn_hit_spark(world_position)


func spawn_enemy_death_effect(world_position: Vector2) -> Node2D:
	var custom_effect := spawn_optional_effect(EFFECT_ENEMY_DEATH, world_position)
	return custom_effect if custom_effect != null else _spawn_death_wisp(world_position)


func spawn_loot_sparkle(world_position: Vector2, parent: Node = null) -> Node2D:
	var custom_effect := spawn_optional_effect(EFFECT_LOOT_SPARKLE, world_position, parent)
	return custom_effect if custom_effect != null else _spawn_loot_glint(world_position, parent)


func spawn_weapon_trail(world_position: Vector2, rotation_radians: float) -> Node2D:
	var effect := spawn_optional_effect(EFFECT_WEAPON_TRAIL, world_position)
	if effect == null:
		effect = _spawn_weapon_arc(world_position)
	if effect != null:
		effect.global_rotation = rotation_radians
	return effect


func request_camera_impact(strength_pixels: float = 1.5, duration: float = 0.08) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var camera := player.get_node_or_null("Camera2D")
	if camera != null and camera.has_method("request_shake"):
		camera.call("request_shake", strength_pixels, duration)


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


func _spawn_hit_spark(world_position: Vector2) -> Node2D:
	var root := _make_effect_root(world_position, 24)
	if root == null:
		return null
	var core := Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-16, 0), Vector2(-4, -4), Vector2(0, -14), Vector2(4, -4),
		Vector2(16, 0), Vector2(4, 4), Vector2(0, 14), Vector2(-4, 4),
	])
	# Ember-gold spark — Chronicle hit language.
	core.color = Color(0.95, 0.72, 0.38, 0.96)
	root.add_child(core)
	var inner := Polygon2D.new()
	inner.polygon = PackedVector2Array([
		Vector2(-8, 0), Vector2(0, -4), Vector2(8, 0), Vector2(0, 4),
	])
	inner.color = Color(1.0, 0.96, 0.82, 1.0)
	root.add_child(inner)
	for angle in [-0.7, 0.0, 0.7]:
		var flake := Polygon2D.new()
		flake.polygon = PackedVector2Array([
			Vector2(0, -2), Vector2(10, 0), Vector2(0, 2),
		])
		flake.rotation = angle
		flake.color = Color(0.98, 0.82, 0.48, 0.75)
		root.add_child(flake)
	root.rotation = randf_range(-0.3, 0.3)
	root.scale = Vector2(0.4, 0.4)
	var tween := root.create_tween()
	tween.set_parallel(true)
	tween.tween_property(root, "scale", Vector2(1.25, 1.25), 0.09)
	tween.tween_property(root, "modulate:a", 0.0, 0.15).set_delay(0.04)
	tween.chain().tween_callback(root.queue_free)
	return root


func _spawn_weapon_arc(world_position: Vector2) -> Node2D:
	var root := _make_effect_root(world_position + Vector2(0.0, -22.0), 18)
	if root == null:
		return null
	var outer := Line2D.new()
	outer.points = PackedVector2Array([
		Vector2(8, -28), Vector2(28, -22), Vector2(46, -10),
		Vector2(56, 0), Vector2(46, 10), Vector2(28, 22), Vector2(8, 28),
	])
	outer.width = 6.0
	outer.default_color = Color(0.78, 0.58, 0.28, 0.78)
	outer.antialiased = true
	root.add_child(outer)
	var mid := Line2D.new()
	mid.points = outer.points
	mid.width = 3.0
	mid.default_color = Color(0.96, 0.82, 0.48, 0.88)
	mid.antialiased = true
	root.add_child(mid)
	var edge := Line2D.new()
	edge.points = outer.points
	edge.width = 1.4
	edge.default_color = Color(1.0, 0.94, 0.78, 0.98)
	edge.antialiased = true
	root.add_child(edge)
	root.scale = Vector2(0.68, 0.68)
	var tween := root.create_tween()
	tween.set_parallel(true)
	tween.tween_property(root, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(root, "modulate:a", 0.0, 0.16).set_delay(0.035)
	tween.chain().tween_callback(root.queue_free)
	return root


func _spawn_death_wisp(world_position: Vector2) -> Node2D:
	var root := _make_effect_root(world_position + Vector2(0.0, -12.0), 16)
	if root == null:
		return null
	for index in range(7):
		var mote := Polygon2D.new()
		var radius := randf_range(2.0, 4.5)
		mote.polygon = PackedVector2Array([
			Vector2(0, -radius), Vector2(radius, 0),
			Vector2(0, radius), Vector2(-radius, 0),
		])
		mote.color = Color(0.52, 0.63, 0.48, randf_range(0.55, 0.85))
		mote.position = Vector2(randf_range(-12.0, 12.0), randf_range(-4.0, 8.0))
		root.add_child(mote)
		var drift := Vector2(randf_range(-22.0, 22.0), randf_range(-38.0, -18.0))
		var mote_tween := mote.create_tween()
		mote_tween.set_parallel(true)
		mote_tween.tween_property(mote, "position", mote.position + drift, 0.42)
		mote_tween.tween_property(mote, "modulate:a", 0.0, 0.42)
	var tween := root.create_tween()
	tween.tween_interval(0.46)
	tween.tween_callback(root.queue_free)
	return root


func _spawn_loot_glint(world_position: Vector2, parent: Node = null) -> Node2D:
	var root := _make_effect_root(world_position, 12, parent)
	if root == null:
		return null
	var ring := Line2D.new()
	ring.points = PackedVector2Array([
		Vector2(-10, 0), Vector2(-7, -7), Vector2(0, -10), Vector2(7, -7),
		Vector2(10, 0), Vector2(7, 7), Vector2(0, 10), Vector2(-7, 7), Vector2(-10, 0),
	])
	ring.width = 1.5
	ring.default_color = Color(0.86, 0.76, 0.47, 0.72)
	root.add_child(ring)
	var tween := root.create_tween()
	tween.set_loops()
	tween.tween_property(root, "rotation", TAU, 2.8)
	return root


func _make_effect_root(
	world_position: Vector2,
	z_layer: int,
	parent: Node = null
) -> Node2D:
	var effect_parent := parent if parent != null else get_tree().current_scene
	if effect_parent == null:
		return null
	var root := Node2D.new()
	root.z_index = z_layer
	effect_parent.add_child(root)
	root.global_position = world_position
	return root
