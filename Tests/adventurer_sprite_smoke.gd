extends SceneTree

const PLAYER_SCENE := preload("res://Project Chronicle/Scenes/Characters/player.tscn")

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PLAYER_SCENE.instantiate()
	root.add_child(player)
	await process_frame

	var sprite := player.get_node("Visuals/PlayerSprite") as AnimatedSprite2D
	var placeholder := player.get_node("Visuals/PlaceholderVisual") as CanvasItem
	var controller := player.get_node("Visuals/VisualController") as CharacterVisualController

	_expect(sprite.visible, "Generated player sprite is visible")
	_expect(not placeholder.visible, "Placeholder is hidden while generated art is usable")
	_expect(
		sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,
		"Player sprite uses nearest-neighbor filtering"
	)
	_expect(sprite.position == Vector2(0.0, -24.0), "Player sprite is grounded on side-view feet")

	var idle_animation := &"idle_right"
	var walk_animation := &"walk_right"
	var attack_animation := &"melee_attack_right"
	_expect(sprite.sprite_frames.has_animation(idle_animation), "Side-view idle exists")
	_expect(sprite.sprite_frames.has_animation(walk_animation), "Side-view walk exists")
	_expect(sprite.sprite_frames.has_animation(attack_animation), "Side-view melee attack exists")

	controller.update_presentation(false, false, false, false, Vector2.ZERO, Vector2.RIGHT)
	_expect(sprite.animation == idle_animation and not sprite.flip_h, "Right idle is selected")

	controller.update_presentation(false, false, false, false, Vector2.RIGHT * 100.0, Vector2.RIGHT)
	_expect(sprite.animation == walk_animation and not sprite.flip_h, "Right walk is selected")
	_expect_walk_frames_are_aligned(sprite.sprite_frames, walk_animation)

	controller.update_presentation(false, false, false, true, Vector2.ZERO, Vector2.RIGHT)
	_expect(sprite.animation == attack_animation and not sprite.flip_h, "Right attack is selected")
	_expect_attack_frames_are_aligned(sprite.sprite_frames, attack_animation)

	controller.update_presentation(false, false, false, false, Vector2.ZERO, Vector2.LEFT)
	_expect(sprite.animation == idle_animation and sprite.flip_h, "Left idle mirrors side-view art")
	controller.update_presentation(false, false, false, true, Vector2.ZERO, Vector2.LEFT)
	_expect(sprite.animation == attack_animation and sprite.flip_h, "Left attack mirrors side-view art")

	player.queue_free()
	await process_frame

	if _failures.is_empty():
		print("ADVENTURER SPRITE SMOKE: PASS")
		quit(0)
		return

	for failure: String in _failures:
		push_error("ADVENTURER SPRITE SMOKE: %s" % failure)
	quit(1)


func _expect_walk_frames_are_aligned(frames: SpriteFrames, animation: StringName) -> void:
	var expected_bottom := -1
	for frame_index in range(frames.get_frame_count(animation)):
		var texture := frames.get_frame_texture(animation, frame_index)
		var image := texture.get_image()
		_expect(image.get_size() == Vector2i(32, 48), "%s frame size" % animation)

		var opaque_bottom := _find_opaque_bottom(image)
		_expect(opaque_bottom >= 0, "%s frame %d has visible pixels" % [animation, frame_index])
		if expected_bottom < 0:
			expected_bottom = opaque_bottom
		else:
			_expect(
				opaque_bottom == expected_bottom,
				"%s feet remain aligned on frame %d" % [animation, frame_index]
			)


func _expect_attack_frames_are_aligned(frames: SpriteFrames, animation: StringName) -> void:
	_expect(frames.get_frame_count(animation) == 3, "%s has three attack phases" % animation)
	var expected_bottom := -1
	for frame_index in range(frames.get_frame_count(animation)):
		var texture := frames.get_frame_texture(animation, frame_index)
		var image := texture.get_image()
		_expect(image.get_size() == Vector2i(112, 48), "%s frame size" % animation)
		var opaque_bottom := _find_opaque_bottom(image)
		if expected_bottom < 0:
			expected_bottom = opaque_bottom
		else:
			_expect(
				opaque_bottom == expected_bottom,
				"%s feet remain aligned on frame %d" % [animation, frame_index]
			)


func _find_opaque_bottom(image: Image) -> int:
	for y in range(image.get_height() - 1, -1, -1):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:
				return y
	return -1


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
