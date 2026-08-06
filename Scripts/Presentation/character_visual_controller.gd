class_name CharacterVisualController
extends Node

## Presentation-only adapter for replaceable AnimatedSprite2D character art.
## Expected animation names are documented by get_supported_animation_names().
## Modular layer contract (96×112, X=48, Y=102, shared timing): see Documentation/ART_PIPELINE.md.
## Live BaseCharacter remains the temporary combined Adventurer preset until modular layers are authored.

@export var sprite_path: NodePath = ^"../CharacterSprite"
@export var placeholder_path: NodePath = ^"../PlaceholderVisual"
@export var locomotion_animation: StringName = &"walk"
@export var mirror_left_from_right := false
@export var jump_apex_speed_threshold := 60.0

var _current_state: StringName = &"idle"
var _current_direction: StringName = &"down"

@onready var _sprite: AnimatedSprite2D = get_node_or_null(sprite_path) as AnimatedSprite2D
@onready var _placeholder: CanvasItem = get_node_or_null(placeholder_path) as CanvasItem


func _ready() -> void:
	if _sprite != null:
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_refresh_animation(true)


func update_presentation(
	is_dead: bool,
	is_hurt: bool,
	is_dodging: bool,
	is_attacking: bool,
	motion: Vector2,
	facing: Vector2,
	is_on_floor: bool = true,
	is_prone: bool = false,
	jump_takeoff_active: bool = false
) -> void:
	if facing.length_squared() > 0.001:
		_current_direction = _direction_name(facing)

	var next_state: StringName = &"idle"
	if is_dead:
		next_state = &"death"
	elif is_hurt:
		next_state = &"hurt"
	elif is_dodging:
		next_state = &"dodge"
	elif is_attacking:
		next_state = &"attack"
	elif is_prone and is_on_floor:
		next_state = &"prone"
	elif not is_on_floor:
		next_state = _airborne_state(motion.y, jump_takeoff_active)
	elif absf(motion.x) > 1.0:
		next_state = locomotion_animation

	var state_changed := next_state != _current_state
	_current_state = next_state
	_refresh_animation(state_changed)


func refresh_art_assignment() -> void:
	_refresh_animation(true)


func spawn_detached_death_animation(parent: Node = null) -> AnimatedSprite2D:
	if _sprite == null or _sprite.sprite_frames == null:
		return null

	var animation := _find_state_animation(&"death", _current_direction)
	if animation == &"":
		return null

	var effect_parent := parent if parent != null else get_tree().current_scene
	if effect_parent == null:
		return null

	var death_sprite := AnimatedSprite2D.new()
	death_sprite.sprite_frames = _sprite.sprite_frames
	death_sprite.animation = animation
	death_sprite.centered = _sprite.centered
	death_sprite.offset = _sprite.offset
	death_sprite.flip_h = _sprite.flip_h
	death_sprite.flip_v = _sprite.flip_v
	death_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	death_sprite.modulate = _sprite.modulate
	death_sprite.self_modulate = _sprite.self_modulate
	effect_parent.add_child(death_sprite)
	death_sprite.global_transform = _sprite.global_transform
	death_sprite.z_index = _sprite.z_index
	death_sprite.play(animation)
	return death_sprite


func get_supported_animation_names() -> PackedStringArray:
	return PackedStringArray([
		"idle", "idle_down", "idle_up", "idle_left", "idle_right",
		"walk", "walk_down", "walk_up", "walk_left", "walk_right",
		"run", "run_down", "run_up", "run_left", "run_right",
		"jump", "jump_right", "jump_takeoff", "jump_takeoff_right",
		"jump_rise", "jump_rise_right", "jump_apex", "jump_apex_right",
		"fall", "fall_right",
		"prone", "prone_right",
		"dash", "dash_right",
		"attack", "attack_down", "attack_up", "attack_left", "attack_right",
		"melee_basic", "melee_attack_down", "melee_attack_up", "melee_attack_left", "melee_attack_right",
		"dodge", "dodge_down", "dodge_up", "dodge_left", "dodge_right",
		"hurt", "hurt_right", "hurt_down", "hurt_up", "hurt_left",
		"death", "death_right", "death_down", "death_up", "death_left",
	])


func _airborne_state(vertical_velocity: float, jump_takeoff_active: bool) -> StringName:
	if jump_takeoff_active:
		return &"jump_takeoff"
	if vertical_velocity < -jump_apex_speed_threshold:
		if _has_animation(&"jump_rise") or _has_animation(&"jump_rise_right"):
			return &"jump_rise"
		return &"jump"
	if vertical_velocity > jump_apex_speed_threshold:
		return &"fall"
	if _has_animation(&"jump_apex") or _has_animation(&"jump_apex_right"):
		return &"jump_apex"
	return &"jump"


func _refresh_animation(restart: bool) -> void:
	if _sprite == null:
		if _placeholder != null:
			_placeholder.visible = true
		return

	var animation := _find_state_animation(_current_state, _current_direction)
	if animation == &"":
		animation = _find_safe_fallback_animation()

	var has_usable_art := animation != &""
	_sprite.visible = has_usable_art
	if _placeholder != null:
		_placeholder.visible = not has_usable_art

	if not has_usable_art:
		return

	# Hurt is intentionally non-directional for knockback semantics: still mirror by facing only.
	_sprite.flip_h = (
		mirror_left_from_right
		and _current_direction == &"left"
		and not _has_animation(StringName("%s_left" % _current_state))
	)
	if restart or _sprite.animation != animation or not _sprite.is_playing():
		_sprite.play(animation)


func _find_state_animation(state: StringName, direction: StringName) -> StringName:
	var candidates: Array[StringName] = []
	if state == &"attack":
		candidates.append(StringName("melee_attack_%s" % direction))
		candidates.append(StringName("attack_%s" % direction))
		if mirror_left_from_right and direction == &"left":
			candidates.append(&"melee_attack_right")
			candidates.append(&"attack_right")
		candidates.append(&"melee_attack_side")
		candidates.append(&"attack_side")
		candidates.append(&"melee_attack")
		candidates.append(&"attack")
	elif state == &"walk" or state == &"run" or state == &"move":
		candidates.append(StringName("%s_%s" % [state, direction]))
		if state == &"run":
			candidates.append(StringName("walk_%s" % direction))
		candidates.append(StringName("move_%s" % direction))
		if mirror_left_from_right and direction == &"left":
			candidates.append(StringName("%s_right" % state))
			candidates.append(&"walk_right")
			candidates.append(&"move_right")
		candidates.append(state)
		candidates.append(&"walk")
		candidates.append(&"move")
	elif state == &"dodge":
		candidates.append(StringName("dodge_%s" % direction))
		candidates.append(StringName("dash_%s" % direction))
		if mirror_left_from_right and direction == &"left":
			candidates.append(&"dodge_right")
			candidates.append(&"dash_right")
		candidates.append(&"dodge")
		candidates.append(&"dash")
	elif (
		state == &"jump"
		or state == &"fall"
		or state == &"jump_takeoff"
		or state == &"jump_rise"
		or state == &"jump_apex"
	):
		candidates.append(StringName("%s_%s" % [state, direction]))
		if mirror_left_from_right and direction == &"left":
			candidates.append(StringName("%s_right" % state))
		candidates.append(state)
		if state == &"jump_rise":
			candidates.append(&"jump_right")
			candidates.append(&"jump")
		elif state == &"jump_apex":
			candidates.append(&"jump_right")
			candidates.append(&"jump")
		elif state == &"jump_takeoff":
			candidates.append(&"jump_right")
			candidates.append(&"jump")
		elif state == &"fall":
			candidates.append(&"jump")
	elif state == &"hurt":
		# Universal / non-directional flinch — prefer plain `hurt` over directional variants.
		candidates.append(&"hurt")
		candidates.append(&"hurt_right")
		candidates.append(StringName("hurt_%s" % direction))
		if mirror_left_from_right and direction == &"left":
			candidates.append(&"hurt_right")
	elif state == &"prone":
		candidates.append(StringName("prone_%s" % direction))
		if mirror_left_from_right and direction == &"left":
			candidates.append(&"prone_right")
		candidates.append(&"prone")
	else:
		candidates.append(StringName("%s_%s" % [state, direction]))
		if mirror_left_from_right and direction == &"left":
			candidates.append(StringName("%s_right" % state))
			candidates.append(StringName("%s_side" % state))
		candidates.append(state)

	for candidate: StringName in candidates:
		if _has_animation(candidate):
			return candidate
	return &""


func _find_safe_fallback_animation() -> StringName:
	var idle_directional := StringName("idle_%s" % _current_direction)
	if _has_animation(idle_directional):
		return idle_directional
	if mirror_left_from_right and _current_direction == &"left" and _has_animation(&"idle_right"):
		return &"idle_right"
	if _has_animation(&"idle"):
		return &"idle"
	if _has_animation(&"default"):
		return &"default"
	if _sprite.sprite_frames == null:
		return &""
	for animation: StringName in _sprite.sprite_frames.get_animation_names():
		if _has_animation(animation):
			return animation
	return &""


func _has_animation(animation: StringName) -> bool:
	return (
		_sprite != null
		and _sprite.sprite_frames != null
		and _sprite.sprite_frames.has_animation(animation)
		and _sprite.sprite_frames.get_frame_count(animation) > 0
	)


func _direction_name(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return &"right" if direction.x >= 0.0 else &"left"
	return &"down" if direction.y >= 0.0 else &"up"
