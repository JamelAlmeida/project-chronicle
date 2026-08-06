extends SceneTree

const PLAYER_SCENE := preload("res://Project Chronicle/Scenes/Characters/player.tscn")

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PLAYER_SCENE.instantiate()
	root.add_child(player)
	await process_frame

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
		and equipment.get_node_or_null("MainHand") != null,
		"EquipmentVisuals includes future gear layer hooks"
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
	_expect(sprite.sprite_frames.has_animation(&"fall_right"), "Side-view fall exists")
	_expect(sprite.sprite_frames.has_animation(&"dash_right"), "Side-view dash exists")
	_expect(sprite.sprite_frames.has_animation(attack_animation), "Side-view melee attack exists")

	controller.update_presentation(false, false, false, false, Vector2.ZERO, Vector2.RIGHT, true)
	_expect(sprite.animation == idle_animation and not sprite.flip_h, "Right idle is selected")

	controller.update_presentation(false, false, false, false, Vector2.RIGHT * 100.0, Vector2.RIGHT, true)
	_expect(sprite.animation == run_animation and not sprite.flip_h, "Right run is selected")

	controller.update_presentation(false, false, false, false, Vector2(0.0, -120.0), Vector2.RIGHT, false)
	_expect(sprite.animation == &"jump_right" and not sprite.flip_h, "Rising uses jump")

	controller.update_presentation(false, false, false, false, Vector2(0.0, 120.0), Vector2.RIGHT, false)
	_expect(sprite.animation == &"fall_right" and not sprite.flip_h, "Descending uses fall")

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
