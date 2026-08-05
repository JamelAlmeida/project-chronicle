extends SceneTree

const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _load_scene(ELDERWOOD)
	_expect(current_scene != null and current_scene.name == "Elderwood", "Elderwood loads")
	if current_scene != null:
		_test_elderwood_dressing()
		_test_enemy_art("Slime")
		_test_player_attack_art()
		_test_hud_skin()
		_test_loot_pickup()

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


func _test_elderwood_dressing() -> void:
	_expect(current_scene.has_node("DistantBackground"), "Distant parallax background is present")
	_expect(current_scene.has_node("MidBackground"), "Mid-background parallax is present")
	_expect(current_scene.has_node("GameplayLayer"), "Gameplay layer is present")
	_expect(current_scene.has_node("ForegroundLayer"), "Foreground layer is present")
	_expect(current_scene.has_node("AtmosphericOverlays"), "Atmospheric overlay layer is present")
	_expect(
		current_scene.get_node(
			"GameplayLayer/Terrain/OptionalRoute/LowerOneWay/CollisionShape2D"
		).one_way_collision,
		"Optional elevated route uses one-way collision"
	)
	_expect(current_scene.has_node("GameplayLayer/Landmarks/AncientTree"), "Ancient tree landmark is present")
	_expect(current_scene.has_node("GameplayLayer/Landmarks/RuinArch"), "Mosscrypt-side ruin landmark is present")


func _test_enemy_art(expected_name: String) -> void:
	var scene_token := expected_name.to_snake_case()
	for enemy: Node in get_nodes_in_group("enemies"):
		if enemy.name.begins_with(expected_name) or enemy.get_scene_file_path().contains(scene_token):
			var sprite := enemy.get_node("Visuals/CharacterSprite") as AnimatedSprite2D
			var fallback := enemy.get_node("Visuals/PlaceholderVisual") as CanvasItem
			_expect(sprite.visible, "%s generated sprite is visible" % expected_name)
			_expect(not fallback.visible, "%s fallback is retained but hidden" % expected_name)
			_expect(
				sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,
				"%s uses nearest-neighbor filtering" % expected_name
			)
			for animation: StringName in [&"idle", &"walk", &"attack", &"hurt", &"death"]:
				_expect(
					sprite.sprite_frames.has_animation(animation),
					"%s has %s art" % [expected_name, animation]
				)
			return
	_expect(false, "%s instance is present" % expected_name)


func _test_player_attack_art() -> void:
	var player := get_first_node_in_group("player")
	_expect(player != null, "Player is present")
	if player == null:
		return
	var attack_visual := player.get_node("MeleeAttack/AttackVisual")
	_expect(attack_visual is Polygon2D, "Melee prototype rectangle is replaced by a shaped slash")


func _test_hud_skin() -> void:
	var hud := get_first_node_in_group("game_hud")
	_expect(hud != null, "HUD is present")
	if hud != null:
		_expect(hud.has_node("BottomHUD"), "Charcoal and brass bottom HUD is present")
		_expect(hud.has_node("ZoneBanner"), "Zone banner skin is present")


func _test_loot_pickup() -> void:
	var pickups := get_nodes_in_group("loot_pickup_visual_test")
	var pickup: LootPickup
	if pickups.is_empty():
		pickup = preload("res://Project Chronicle/Scenes/World/loot_pickup.tscn").instantiate()
		current_scene.add_child(pickup)
		pickup.setup("slime_gel", 1)
	else:
		pickup = pickups[0] as LootPickup
	_expect(pickup != null, "Loot pickup can instantiate")
	if pickup != null:
		_expect(pickup.get_node("Icon").visible, "Loot pickup uses item icon")
		_expect(not pickup.get_node("ColorRect").visible, "Loot fallback hides when icon is usable")
		_expect(pickup.has_node("Sparkle"), "Loot pickup has restrained sparkle")


func _test_item_icons() -> void:
	for item_id: String in [
		"slime_gel",
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
