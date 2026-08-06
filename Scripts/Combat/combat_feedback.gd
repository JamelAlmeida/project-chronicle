extends Node

const DAMAGE_NUMBER_SCENE := preload("res://Project Chronicle/Scenes/UI/damage_number.tscn")

const EFFECT_DAMAGE_PARTICLES: StringName = &"damage_particles"
const EFFECT_ENEMY_DEATH: StringName = &"enemy_death"
const EFFECT_LOOT_SPARKLE: StringName = &"loot_sparkle"
const EFFECT_WEAPON_TRAIL: StringName = &"weapon_trail"

const DAMAGE_STANDARD: StringName = &"standard"
const DAMAGE_CRITICAL: StringName = &"critical"
const DAMAGE_PLAYER: StringName = &"player"

## Mirrors FloatingCombatText.DamageType for callers that prefer ints/kinds.
const TYPE_PHYSICAL := 0
const TYPE_FIRE := 1
const TYPE_FROST := 2
const TYPE_ARCANE := 3
const TYPE_POISON := 4
const TYPE_BLEED := 5
const TYPE_HEALING := 6
const TYPE_SHIELD := 7
const TYPE_LIFESTEAL := 8
const TYPE_PLAYER_INCOMING := 9

var _effect_scenes: Dictionary[StringName, PackedScene] = {}


## Spawns FloatingCombatText for the ACTUAL resolved combat amount.
## Never invents values — callers must pass the same integer applied to HP.
func spawn_damage_number(
	world_position: Vector2,
	amount: int,
	kind: StringName = DAMAGE_STANDARD
) -> void:
	spawn_floating_combat_text(
		world_position,
		amount,
		kind == DAMAGE_CRITICAL,
		_damage_type_from_kind(kind)
	)


func spawn_floating_combat_text(
	world_position: Vector2,
	amount: int,
	is_critical: bool = false,
	damage_type: int = TYPE_PHYSICAL
) -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var floating: Node2D = DAMAGE_NUMBER_SCENE.instantiate() as Node2D
	if floating == null:
		return
	scene_root.add_child(floating)
	floating.global_position = world_position + Vector2(0.0, -24.0)
	if floating.has_method("show_damage"):
		floating.call("show_damage", amount, is_critical, damage_type)


func _damage_type_from_kind(kind: StringName) -> int:
	match kind:
		DAMAGE_PLAYER:
			return TYPE_PLAYER_INCOMING
		&"healing":
			return TYPE_HEALING
		&"fire":
			return TYPE_FIRE
		&"frost":
			return TYPE_FROST
		&"arcane":
			return TYPE_ARCANE
		&"poison":
			return TYPE_POISON
		&"bleed":
			return TYPE_BLEED
		&"shield":
			return TYPE_SHIELD
		&"lifesteal":
			return TYPE_LIFESTEAL
		_:
			return TYPE_PHYSICAL


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
	var tex_root := _spawn_showcase_sprite(
		world_position,
		[
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/hit_spark_a.png",
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/hit_spark_b.png",
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/hit_spark_c.png",
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/hit_burst.png",
		],
		24,
		Vector2(0.55, 0.55),
		Vector2(1.15, 1.15),
		0.18
	)
	if tex_root != null:
		return tex_root
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
	var tex_root := _spawn_showcase_sprite(
		world_position + Vector2(18.0, -22.0),
		[
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/slash_a.png",
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/slash_b.png",
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/slash_c.png",
			"res://Project Chronicle/Assets/Showcase/Runtime/Combat/slash_d.png",
		],
		18,
		Vector2(0.42, 0.42),
		Vector2(0.78, 0.78),
		0.2
	)
	if tex_root != null:
		return tex_root
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


func _spawn_loot_glint(world_position: Vector2, parent: Node = null) -> Node2D:
	var tex := _load_showcase_tex(
		"res://Project Chronicle/Assets/Showcase/Runtime/Combat/loot_sparkle.png"
	)
	if tex != null:
		var sparkle_root := _make_effect_root(world_position, 12, parent)
		if sparkle_root == null:
			return null
		var sprite := Sprite2D.new()
		sprite.texture = tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.centered = true
		sprite.scale = Vector2(0.35, 0.35)
		sparkle_root.add_child(sprite)
		var sparkle_tween := sparkle_root.create_tween()
		sparkle_tween.set_loops()
		sparkle_tween.tween_property(sparkle_root, "rotation", TAU, 2.4)
		sparkle_tween.parallel().tween_property(sprite, "modulate:a", 0.55, 1.2)
		sparkle_tween.tween_property(sprite, "modulate:a", 1.0, 1.2)
		return sparkle_root
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


func _spawn_showcase_sprite(
	world_position: Vector2,
	paths: Array,
	z_layer: int,
	start_scale: Vector2,
	end_scale: Vector2,
	life: float
) -> Node2D:
	var path: String = paths[randi() % paths.size()]
	var tex := _load_showcase_tex(path)
	if tex == null:
		return null
	var root := _make_effect_root(world_position, z_layer)
	if root == null:
		return null
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	sprite.modulate = Color(1.08, 1.02, 0.88, 1.0)
	root.add_child(sprite)
	root.rotation = randf_range(-0.25, 0.25)
	root.scale = start_scale
	var tween := root.create_tween()
	tween.set_parallel(true)
	tween.tween_property(root, "scale", end_scale, life * 0.45)
	tween.tween_property(root, "modulate:a", 0.0, life).set_delay(life * 0.2)
	tween.chain().tween_callback(root.queue_free)
	return root


func _load_showcase_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	if FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	return null


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
