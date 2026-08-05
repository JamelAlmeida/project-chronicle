extends SceneTree

const HEARTHVALE := "res://Project Chronicle/Scenes/World/Zones/hearthvale_sideview_entry.tscn"
const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"
const MOSSCRYPT := "res://Project Chronicle/Scenes/World/Zones/mosscrypt_sideview_entry.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(InputMap.has_action("jump"), "Jump input action exists")
	_expect(_action_has_physical_key("attack", KEY_E), "E remains melee attack")
	_expect(_action_has_physical_key("dodge", KEY_SPACE), "Space remains dodge")
	_expect(_action_has_physical_key("toggle_equipment_debug", KEY_TAB), "Tab remains equipment UI")

	await _load_scene(HEARTHVALE)
	var player := await _settle_player()
	_expect(player != null, "Side-view Hearthvale player spawns")
	if player == null:
		_finish()
		return
	_expect(player.is_on_floor(), "Player lands on solid terrain")
	var equipment_ui := current_scene.get_node("EquipmentDebugPanel")
	var tab_event := InputEventAction.new()
	tab_event.action = &"toggle_equipment_debug"
	tab_event.pressed = true
	equipment_ui.call("_input", tab_event)
	_expect(
		current_scene.get_node("EquipmentDebugPanel/PanelContainer").visible,
		"Tab equipment UI handler still opens"
	)
	equipment_ui.call("_input", tab_event)

	var start_x := player.global_position.x
	Input.action_press("move_right")
	await _wait_physics(8)
	Input.action_release("move_right")
	_expect(player.global_position.x > start_x, "Player accelerates right")

	var floor_y := player.global_position.y
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	await _wait_physics(3)
	_expect(player.global_position.y < floor_y, "Player jumps upward")
	_expect(not player.is_on_floor(), "Player cannot remain grounded while jumping")
	player = await _settle_player()
	_expect(player != null and player.is_on_floor(), "Player lands after jumping")

	var dodge: DodgeComponent = player.get_node("DodgeComponent") as DodgeComponent
	_expect(dodge.try_dodge(Vector2.RIGHT), "Grounded side-view dash starts")
	await physics_frame
	_expect(dodge.is_dodging(), "Side-view dash remains active")

	_zone_manager().transition_to(ELDERWOOD, "from_hearthvale")
	await scene_changed
	await process_frame
	_expect(current_scene.name == "Elderwood", "Hearthvale transitions to Elderwood")
	player = await _settle_player()
	_expect(player != null and player.is_on_floor(), "Elderwood player lands")
	_expect(
		current_scene.get_node("GameplayLayer/Terrain/OptionalRoute/LowerOneWay/CollisionShape2D").one_way_collision,
		"Elderwood includes a one-way platform"
	)
	player.global_position = Vector2(980.0, 620.0)
	player.velocity = Vector2.ZERO
	await _wait_physics(2)
	Input.action_press("jump")
	await _wait_physics(28)
	Input.action_release("jump")
	var reached_lower_route := false
	for _frame in range(60):
		await physics_frame
		if player.is_on_floor() and player.global_position.y < 590.0:
			reached_lower_route = true
			break
	_expect(reached_lower_route, "Optional elevated route is reachable")

	var camera := player.get_node("Camera2D") as Camera2D
	_expect(camera != null and camera.limit_enabled, "Side-view camera uses map limits")

	var slime := get_first_node_in_group("enemies") as EnemyBase
	_expect(slime != null, "Side-view Slime spawns")
	if slime != null:
		await _wait_physics(12)
		_expect(slime.is_on_floor(), "Slime stays grounded")
		player.global_position = Vector2(slime.global_position.x - 180.0, 620.0)
		player.velocity = Vector2.ZERO
		var slime_start_x := slime.global_position.x
		await _wait_physics(12)
		_expect(slime.global_position.x < slime_start_x, "Slime approaches horizontally")

		var health := player.get_node("HealthComponent") as HealthComponent
		player.global_position = slime.global_position + Vector2(-24.0, 0.0)
		player.velocity = Vector2.ZERO
		var health_before_contact := health.current_health
		slime.call("_try_attack_player")
		_expect(health.current_health < health_before_contact, "Slime damages the player")

		var melee := player.get_node("MeleeAttack") as MeleeAttack
		_expect(melee.try_attack(Vector2.RIGHT), "Right-facing melee starts")
		_expect(is_zero_approx(melee.rotation), "Melee hitbox faces right")
		await _wait_physics(35)
		_expect(melee.try_attack(Vector2.LEFT), "Left-facing melee starts")
		_expect(is_equal_approx(absf(melee.rotation), PI), "Melee hitbox faces left")
		await _wait_physics(35)

		var equipment := player.get_node("EquipmentComponent") as EquipmentComponent
		_inventory().add_item("swift_katana", 1)
		_expect(equipment.equip_from_inventory("swift_katana"), "Equipment still equips")
		_expect(equipment.get_equipped_id("weapon") == "swift_katana", "Equipment state updates")
		_inventory().add_item("crimson_leech_ring", 1)
		_expect(equipment.equip_from_inventory("crimson_leech_ring"), "Lifesteal ring equips")
		health.set_current_health(maxi(health.current_health - 30, 1))
		var health_before_lifesteal := health.current_health
		melee.call("_apply_lifesteal", 50)
		_expect(health.current_health > health_before_lifesteal, "Lifesteal still heals")

		var pickup_count := _count_nodes_of_type(current_scene, LootPickup)
		var expedition_before: int = _inventory().get_expedition_quantity("slime_gel")
		var death_position := slime.global_position
		slime.take_damage(99999)
		await process_frame
		await process_frame
		_expect(_count_nodes_of_type(current_scene, LootPickup) == pickup_count + 1, "Slime drops loot")
		var dropped_pickup := _nearest_pickup(death_position)
		_expect(dropped_pickup != null, "Dropped loot remains collectible")
		if dropped_pickup != null:
			dropped_pickup.call("_on_body_entered", player)
			_expect(
				_inventory().get_expedition_quantity("slime_gel") > expedition_before,
				"Elderwood loot is unsecured"
			)

	_zone_manager().transition_to(MOSSCRYPT, "from_elderwood")
	await scene_changed
	await process_frame
	_expect(current_scene.name == "MosscryptSideviewEntry", "Right exit reaches Mosscrypt placeholder")

	_zone_manager().transition_to(HEARTHVALE, "from_elderwood")
	await scene_changed
	await process_frame
	_expect(_inventory().get_expedition_quantity("slime_gel") == 0, "Returning safe secures expedition loot")
	_finish()


func _settle_player() -> CharacterBody2D:
	var player := get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		return null
	for _frame in range(90):
		await physics_frame
		if player.is_on_floor():
			return player
	return player


func _wait_physics(frame_count: int) -> void:
	for _frame in range(frame_count):
		await physics_frame


func _load_scene(path: String) -> void:
	var error := change_scene_to_file(path)
	_expect(error == OK, "Scene loads: %s" % path)
	if error == OK:
		await scene_changed
		await process_frame


func _nearest_pickup(world_position: Vector2) -> LootPickup:
	var nearest: LootPickup
	var nearest_distance := INF
	for node: Node in get_nodes_in_group("loot_pickups"):
		var pickup := node as LootPickup
		if pickup == null:
			continue
		var distance := pickup.global_position.distance_squared_to(world_position)
		if distance < nearest_distance:
			nearest = pickup
			nearest_distance = distance
	if nearest != null:
		return nearest
	return _find_nearest_pickup(current_scene, world_position)


func _find_nearest_pickup(root_node: Node, world_position: Vector2) -> LootPickup:
	var nearest: LootPickup
	var nearest_distance := INF
	if root_node is LootPickup:
		nearest = root_node as LootPickup
		nearest_distance = nearest.global_position.distance_squared_to(world_position)
	for child: Node in root_node.get_children():
		var candidate := _find_nearest_pickup(child, world_position)
		if candidate == null:
			continue
		var distance := candidate.global_position.distance_squared_to(world_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest


func _count_nodes_of_type(root_node: Node, script_type: Variant) -> int:
	var count := 1 if is_instance_of(root_node, script_type) else 0
	for child: Node in root_node.get_children():
		count += _count_nodes_of_type(child, script_type)
	return count


func _action_has_physical_key(action: StringName, physical_keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == physical_keycode:
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _finish() -> void:
	if _failures.is_empty():
		print("SIDEVIEW FOUNDATION SMOKE: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("SIDEVIEW FOUNDATION SMOKE: %s" % failure)
	quit(1)


func _zone_manager():
	return root.get_node("ZoneManager")


func _inventory():
	return root.get_node("Inventory")
