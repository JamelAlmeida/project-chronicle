extends SceneTree

const PLAYER_SCENE := preload("res://Project Chronicle/Scenes/Characters/player.tscn")

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 2
	floor_body.collision_mask = 0
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(400, 20)
	floor_shape.shape = floor_rect
	floor_shape.position = Vector2(0, 10)
	floor_body.add_child(floor_shape)
	root.add_child(floor_body)

	var player := PLAYER_SCENE.instantiate()
	root.add_child(player)
	player.global_position = Vector2(0, -40)
	player.collision_mask = 2
	await process_frame
	for _settle in range(20):
		await physics_frame
		if player.is_on_floor():
			break

	var sprite := player.get_node("Visuals/BaseCharacter") as AnimatedSprite2D
	var placeholder := player.get_node("Visuals/PlaceholderVisual") as CanvasItem
	var controller := player.get_node("Visuals/VisualController") as CharacterVisualController
	var equipment := player.get_node_or_null("Visuals/EquipmentVisuals")
	var ground_shadow := player.get_node_or_null("Visuals/GroundShadow") as CanvasItem
	var attack_visual := player.get_node_or_null("MeleeAttack/AttackVisual") as CanvasItem

	_expect(sprite.visible, "Approved kit player sprite is visible")
	_expect(not placeholder.visible, "Placeholder is hidden while kit art is usable")
	_expect(
		sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,
		"Player sprite uses nearest-neighbor filtering"
	)
	_expect(equipment != null, "EquipmentVisuals hook exists for future visible gear")
	_expect(
		equipment.get_node_or_null("Legs") != null
		and equipment.get_node_or_null("Feet") != null
		and equipment.get_node_or_null("Hands") != null
		and equipment.get_node_or_null("Cloak") != null
		and equipment.get_node_or_null("Body") != null
		and equipment.get_node_or_null("Head") != null
		and equipment.get_node_or_null("MainHand") != null
		and equipment.get_node_or_null("OffHand") != null,
		"EquipmentVisuals includes future gear layer hooks"
	)
	_expect(player.get_node_or_null("Visuals/HairBack") != null, "HairBack layer hook exists")
	_expect(player.get_node_or_null("Visuals/HairFront") != null, "HairFront layer hook exists")
	_expect(player.get_node_or_null("Visuals/CharacterFX") != null, "CharacterFX layer hook exists")
	_expect(
		equipment.get_children().size() >= 1
		and str(equipment.get_child(0).name) == "Cloak",
		"EquipmentVisuals draw order starts with Cloak (back)"
	)
	_expect(ground_shadow == null or not ground_shadow.visible, "Programmer GroundShadow is disabled")
	_expect(attack_visual == null or not attack_visual.visible, "Programmer AttackVisual stays hidden")
	_expect(is_equal_approx(sprite.scale.x, 1.0) and is_equal_approx(sprite.scale.y, 1.0), "Player sprite scale is 1.0")
	_expect(sprite.position.y < 0.0, "Player sprite is grounded above feet")
	_expect(
		sprite.sprite_frames != null
		and String(sprite.sprite_frames.resource_path).ends_with("adventurer_kit_v1_sprite_frames.tres"),
		"Live player uses approved Adventurer kit frames"
	)

	var idle_animation := &"idle_right"
	var run_animation := &"run_right"
	var attack_animation := &"melee_attack_right"
	_expect(sprite.sprite_frames.has_animation(idle_animation), "Side-view idle exists")
	_expect(sprite.sprite_frames.has_animation(run_animation), "Side-view run exists")
	_expect(sprite.sprite_frames.has_animation(&"jump_right"), "Side-view jump exists")
	_expect(sprite.sprite_frames.has_animation(&"jump_takeoff"), "Jump takeoff exists")
	_expect(sprite.sprite_frames.has_animation(&"jump_rise"), "Jump rise exists")
	_expect(sprite.sprite_frames.has_animation(&"jump_apex"), "Jump apex exists")
	_expect(sprite.sprite_frames.has_animation(&"fall_right"), "Side-view fall exists")
	_expect(sprite.sprite_frames.has_animation(&"prone"), "Prone animation exists")
	_expect(sprite.sprite_frames.has_animation(&"hurt"), "Universal hurt exists")
	_expect(sprite.sprite_frames.has_animation(&"death"), "Defeated pose exists")
	_expect(sprite.sprite_frames.has_animation(&"dash_right"), "Side-view dash exists")
	_expect(sprite.sprite_frames.has_animation(attack_animation), "Side-view melee attack exists")

	controller.update_presentation(false, false, false, false, Vector2.ZERO, Vector2.RIGHT, true)
	_expect(sprite.animation == idle_animation and not sprite.flip_h, "Right idle is selected")

	controller.update_presentation(false, false, false, false, Vector2.RIGHT * 100.0, Vector2.RIGHT, true)
	_expect(sprite.animation == run_animation and not sprite.flip_h, "Right run is selected")

	controller.update_presentation(false, false, false, false, Vector2(0.0, -120.0), Vector2.RIGHT, false, false, true)
	_expect(sprite.animation == &"jump_takeoff_right" or sprite.animation == &"jump_takeoff", "Takeoff uses jump_takeoff")

	controller.update_presentation(false, false, false, false, Vector2(0.0, -120.0), Vector2.RIGHT, false)
	_expect(
		sprite.animation == &"jump_rise_right" or sprite.animation == &"jump_rise" or sprite.animation == &"jump_right",
		"Rising uses jump rise"
	)

	controller.update_presentation(false, false, false, false, Vector2(0.0, 0.0), Vector2.RIGHT, false)
	_expect(
		sprite.animation == &"jump_apex_right" or sprite.animation == &"jump_apex" or sprite.animation == &"jump_right",
		"Apex uses jump apex"
	)

	controller.update_presentation(false, false, false, false, Vector2(0.0, 120.0), Vector2.RIGHT, false)
	_expect(sprite.animation == &"fall_right" and not sprite.flip_h, "Descending uses fall")

	controller.update_presentation(false, false, false, false, Vector2.ZERO, Vector2.RIGHT, true, true)
	_expect(sprite.animation == &"prone_right" or sprite.animation == &"prone", "Prone pose selected")

	controller.update_presentation(false, true, false, false, Vector2.ZERO, Vector2.RIGHT, true)
	_expect(sprite.animation == &"hurt" or sprite.animation == &"hurt_right", "Universal hurt selected")

	controller.update_presentation(true, false, false, false, Vector2.ZERO, Vector2.RIGHT, true)
	_expect(sprite.animation == &"death" or sprite.animation == &"death_right", "Defeated pose selected")

	controller.update_presentation(false, false, true, false, Vector2.RIGHT * 100.0, Vector2.RIGHT, true)
	_expect(
		(sprite.animation == &"dodge_right" or sprite.animation == &"dash_right") and not sprite.flip_h,
		"Dodge/dash visual is selected"
	)

	controller.update_presentation(false, false, false, true, Vector2.ZERO, Vector2.RIGHT, true)
	_expect(sprite.animation == attack_animation and not sprite.flip_h, "Right attack is selected")

	controller.update_presentation(false, false, false, false, Vector2.ZERO, Vector2.LEFT, true)
	_expect(sprite.animation == idle_animation and sprite.flip_h, "Left idle mirrors side-view art")
	controller.update_presentation(false, false, false, true, Vector2.ZERO, Vector2.LEFT, true)
	_expect(sprite.animation == attack_animation and sprite.flip_h, "Left attack mirrors side-view art")

	var hurtbox := player.get_node_or_null("Hurtbox/CollisionShape2D") as CollisionShape2D
	_expect(hurtbox != null, "Player hurtbox exists")
	_expect(player.has_method("get_hurtbox_global_rect"), "Hurtbox rect helper exists")
	_expect(player.has_method("is_prone"), "Prone query exists")

	# Standing vs prone height: high aim should clear prone.
	var standing_rect: Rect2 = player.get_hurtbox_global_rect()
	Input.action_press("move_down")
	for _i in range(4):
		await physics_frame
	_expect(player.is_prone(), "S enters prone while grounded")
	var prone_rect: Rect2 = player.get_hurtbox_global_rect()
	_expect(prone_rect.size.y < standing_rect.size.y, "Prone hurtbox is shorter than standing")
	var high_aim := Vector2(player.global_position.x, player.global_position.y - 22.0)
	_expect(not player.is_hurtbox_hit_by_point(high_aim), "High attack aim clears prone hurtbox")
	Input.action_release("move_down")
	for _i in range(4):
		await physics_frame
	_expect(not player.is_prone(), "Releasing S stands when clear")

	player.queue_free()
	await process_frame

	if _failures.is_empty():
		print("ADVENTURER SPRITE SMOKE: PASS")
		quit(0)
		return

	for failure: String in _failures:
		push_error("ADVENTURER SPRITE SMOKE: %s" % failure)
	quit(1)


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
