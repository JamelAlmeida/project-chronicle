extends SceneTree

const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _load_scene(ELDERWOOD)
	_expect(current_scene != null and current_scene.name == "Elderwood", "Elderwood loads")
	if current_scene != null:
		_test_elderwood_foundation()
		_test_player_attack_art()
		_test_hud_shell()
		_test_loot_pickup_shell()
		_test_old_showcase_art_cleared()

	_test_item_icons()

	if _failures.is_empty():
		print("ELDERWOOD VISUAL BENCHMARK SMOKE: PASS")
		quit(0)
		return

	for failure: String in _failures:
		push_error("ELDERWOOD VISUAL BENCHMARK SMOKE: %s" % failure)
	quit(1)


func _load_scene(path: String) -> void:
	var error := change_scene_to_file(path)
	_expect(error == OK, "Load scene %s" % path)
	if error == OK:
		await scene_changed
		for _frame in range(3):
			await process_frame


func _test_elderwood_foundation() -> void:
	_expect(current_scene.has_node("Background"), "Background layer is present")
	_expect(current_scene.has_node("Midground"), "Midground layer is present")
	_expect(current_scene.has_node("Gameplay"), "Gameplay layer is present")
	_expect(current_scene.has_node("Gameplay/Collision"), "Collision is separated under Gameplay")
	_expect(current_scene.has_node("ApprovedEnvironmentArt"), "Approved art mount point is present")
	_expect(current_scene.has_node("Foreground"), "Foreground layer is present")
	_expect(not current_scene.has_node("ImmersionDressing"), "Legacy immersion dressing is retired")
	_expect(
		current_scene.get_node(
			"Gameplay/Collision/OptionalRoute/LowerOneWay/CollisionShape2D"
		).one_way_collision,
		"Optional elevated route uses one-way collision"
	)
	_expect(
		current_scene.has_node("Gameplay/Collision/EntryRise/CollisionShape2D"),
		"Entry rise collision is present"
	)
	_expect(
		not current_scene.has_node("Gameplay/Collision/OptionalRoute/MiddleOneWay"),
		"Prototype middle ghost platform is removed"
	)
	_expect(
		not current_scene.has_node("Gameplay/Collision/OptionalRoute/HighOneWay"),
		"Prototype high ghost platform is removed"
	)
	_expect(
		not current_scene.has_node("Gameplay/Collision/RootBridge"),
		"Prototype root-bridge ghost platform is removed"
	)
	_expect(
		current_scene.get_node_or_null("ApprovedEnvironmentArt/EntryRiseVisual") == null,
		"Legacy Showcase entry-rise platform art is cleared"
	)
	_expect(
		current_scene.get_node_or_null("ApprovedEnvironmentArt/CenterLedgeVisual") == null,
		"Legacy Showcase center ledge art is cleared"
	)
	_expect(
		current_scene.get_node("ApprovedEnvironmentArt").get_child_count() == 0,
		"ApprovedEnvironmentArt mount is empty pending new Chronicle art"
	)
	_expect(
		current_scene.get_node("Gameplay/Enemies").get_child_count() == 0,
		"Legacy Showcase slime instances are removed from Elderwood"
	)
	_expect(
		current_scene.get_node("Gameplay/Loot").get_child_count() == 0,
		"Legacy slime-gel world drop is removed from Elderwood"
	)
	_expect(
		current_scene.get_node_or_null("Gameplay/Collision/MainGround/Visual") == null,
		"Prototype main-ground ColorRect is removed"
	)
	_expect(
		current_scene.get_node_or_null("Gameplay/Collision/OptionalRoute/LowerOneWay/Visual") == null,
		"Prototype elevated-platform ColorRect is removed"
	)
	_expect(
		current_scene.get_node_or_null("DistantBackground/DistantCanopy") == null,
		"Primitive distant canopy is removed"
	)
	_expect(
		current_scene.get_node_or_null("MidBackground/ForestDepth") == null,
		"Primitive forest depth wedges are removed"
	)


func _test_enemy_art(_expected_name: String) -> void:
	## Showcase slime art retired — enemy presentation awaits new Chronicle packs.
	pass


func _test_old_showcase_art_cleared() -> void:
	_expect(
		not ResourceLoader.exists(
			"res://Project Chronicle/Scenes/Characters/Slime.tscn"
		) or (
			load("res://Project Chronicle/Scenes/Characters/Slime.tscn") as PackedScene
		) != null,
		"Slime scene still loads as gameplay shell"
	)
	var slime_scene := load("res://Project Chronicle/Scenes/Characters/Slime.tscn") as PackedScene
	var slime := slime_scene.instantiate()
	current_scene.add_child(slime)
	var sprite := slime.get_node("Visuals/CharacterSprite") as AnimatedSprite2D
	var fallback := slime.get_node("Visuals/PlaceholderVisual") as CanvasItem
	_expect(sprite.sprite_frames == null, "Slime no longer references Showcase SpriteFrames")
	_expect(not sprite.visible, "Slime sprite stays hidden until new art is assigned")
	_expect(not fallback.visible, "Slime ColorRect placeholder stays hidden")
	slime.queue_free()


func _test_player_attack_art() -> void:
	var player := get_first_node_in_group("player")
	_expect(player != null, "Player is present")
	if player == null:
		return
	var attack_visual := player.get_node("MeleeAttack/AttackVisual")
	_expect(attack_visual is Polygon2D, "Melee prototype rectangle is replaced by a shaped slash")
	_expect(not (attack_visual as CanvasItem).visible, "AttackVisual stays hidden (Adventurer frames carry melee)")


func _test_hud_shell() -> void:
	var hud := get_first_node_in_group("game_hud")
	_expect(hud != null, "HUD is present")
	if hud != null:
		_expect(hud.has_node("BottomHUD"), "Functional bottom HUD shell is present")
		_expect(hud.find_child("ZoneBanner", true, false) != null, "Zone banner shell is present")
		_expect(hud.has_node("TopLeft/ExpeditionPanel"), "Expedition panel shell is present")
		_expect(not hud.has_node("HudShell"), "Legacy HudShell is absent")


func _test_loot_pickup_shell() -> void:
	var pickup: LootPickup = preload("res://Project Chronicle/Scenes/World/loot_pickup.tscn").instantiate()
	current_scene.add_child(pickup)
	pickup.setup("slime_gel", 1)
	_expect(pickup != null, "Loot pickup can instantiate")
	_expect(not pickup.get_node("Icon").visible, "Slime gel has no legacy icon art")
	_expect(pickup.get_node("ColorRect").visible, "Loot falls back without inventing drop art")
	pickup.queue_free()


func _test_item_icons() -> void:
	var slime_gel: ItemData = root.get_node("ItemRegistry").get_item("slime_gel")
	_expect(slime_gel != null, "slime_gel item data remains registered")
	_expect(slime_gel != null and slime_gel.icon == null, "slime_gel legacy PixelArt icon cleared")
	for item_id: String in [
		"swift_katana",
		"bloodfang_blade",
		"crimson_leech_ring",
	]:
		var item: ItemData = root.get_node("ItemRegistry").get_item(item_id)
		_expect(item != null and item.icon != null, "%s icon loads" % item_id)
		if item != null and item.icon != null:
			_expect(item.icon.get_size() == Vector2(32, 32), "%s icon is normalized to 32x32" % item_id)


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
