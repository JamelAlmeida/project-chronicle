extends SceneTree

const HEARTHVALE := "res://Project Chronicle/Scenes/World/Zones/hearthvale_sideview_entry.tscn"
const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"
const MOSSCRYPT := "res://Project Chronicle/Scenes/World/Zones/mosscrypt_sideview_entry.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(_action_has_physical_key("attack", KEY_E), "E remains mapped to attack")
	_expect(_action_has_physical_key("dodge", KEY_SPACE), "Space remains mapped to dodge")

	await _load_scene(HEARTHVALE)
	await _test_player_controls("Hearthvale side-view entry")

	_zone_manager().transition_to(ELDERWOOD, "from_hearthvale")
	await scene_changed
	await process_frame
	_expect(current_scene.name == "Elderwood", "Hearthvale to Elderwood transition")
	await _test_player_controls("Elderwood")
	await _test_enemy_damage_death_and_loot("Slime")
	_test_inventory_and_equipment()

	_zone_manager().transition_to(MOSSCRYPT, "from_elderwood")
	await scene_changed
	await process_frame
	_expect(current_scene.name == "MosscryptSideviewEntry", "Elderwood to Mosscrypt threshold transition")
	await _test_player_controls("Mosscrypt side-view threshold")

	var player := get_first_node_in_group("player")
	_expect(player != null, "Mosscrypt player spawned")
	if player != null:
		var equipment := player.get_node("EquipmentComponent") as EquipmentComponent
		_expect(
			equipment.get_equipped_id("weapon") == "swift_katana",
			"Equipment persists through zone transition"
		)

		_zone_manager().transition_to(ELDERWOOD, "from_mosscrypt")
		await scene_changed
		await process_frame
		_expect(current_scene.name == "Elderwood", "Mosscrypt to Elderwood transition")

		_zone_manager().transition_to(HEARTHVALE, "from_elderwood")
		await scene_changed
		await process_frame
		_expect(current_scene.name == "HearthvaleSideviewEntry", "Elderwood to Hearthvale transition")

		_zone_manager().transition_to(ELDERWOOD, "from_hearthvale")
		await scene_changed
		await process_frame

		player = get_first_node_in_group("player")
		_expect(player != null, "Player persists through side-view zone round trip")
		if player == null:
			_finish()
			return
		var health := player.get_node("HealthComponent") as HealthComponent
		health.set_current_health(1)
		player.take_damage(1)
		await scene_changed
		await process_frame
		_expect(current_scene.name == "HearthvaleSideviewEntry", "Player death returns to safe Hearthvale")


	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("VISUAL FOUNDATION SMOKE: PASS")
		quit(0)
		return

	for failure: String in _failures:
		push_error("VISUAL FOUNDATION SMOKE: %s" % failure)
	quit(1)


func _load_scene(path: String) -> void:
	var error := change_scene_to_file(path)
	_expect(error == OK, "Load scene %s" % path)
	if error == OK:
		await scene_changed
		await process_frame


func _test_player_controls(zone_name: String) -> void:
	var player := get_first_node_in_group("player") as CharacterBody2D
	_expect(player != null, "%s player spawned" % zone_name)
	if player == null:
		return

	var start_position := player.global_position
	Input.action_press("move_right")
	for _frame in range(4):
		await physics_frame
	Input.action_release("move_right")
	_expect(player.global_position.x > start_position.x, "%s movement" % zone_name)

	var melee := player.get_node("MeleeAttack") as MeleeAttack
	_expect(melee.try_attack(Vector2.RIGHT), "%s attack starts" % zone_name)
	_expect(melee.is_attacking(), "%s attack remains active" % zone_name)

	var dodge := player.get_node("DodgeComponent") as DodgeComponent
	_expect(dodge.try_dodge(Vector2.RIGHT), "%s dodge starts" % zone_name)
	_expect(dodge.is_dodging(), "%s dodge remains active" % zone_name)


func _test_enemy_damage_death_and_loot(enemy_token: String) -> void:
	## Live zones no longer place Showcase slimes; spawn an art-cleared shell for combat checks.
	var enemies_root := current_scene.get_node_or_null("Gameplay/Enemies")
	_expect(enemies_root != null, "Enemy mount exists")
	if enemies_root == null:
		return
	var slime_scene := load("res://Project Chronicle/Scenes/Characters/Slime.tscn") as PackedScene
	var enemy := slime_scene.instantiate() as EnemyBase
	enemies_root.add_child(enemy)
	enemy.global_position = Vector2(1180.0, 620.0)
	await process_frame
	await process_frame

	_expect(enemy != null and (enemy.enemy_id == "slime"), "%s shell spawned" % enemy_token)
	if enemy == null:
		return

	var initial_enemy_count := get_nodes_in_group("enemies").size()
	var initial_pickup_count := _count_nodes_of_type(current_scene, LootPickup)
	var initial_health := enemy.health
	enemy.take_damage(1)
	_expect(enemy.health == initial_health - 1, "%s takes damage" % enemy_token)
	enemy.take_damage(99999)
	await process_frame
	await process_frame
	_expect(
		get_nodes_in_group("enemies").size() == initial_enemy_count - 1,
		"%s death" % enemy_token
	)
	_expect(
		_count_nodes_of_type(current_scene, LootPickup) == initial_pickup_count + 1,
		"%s loot drop" % enemy_token
	)


func _test_inventory_and_equipment() -> void:
	var player := get_first_node_in_group("player")
	_expect(player != null, "Inventory/equipment player available")
	if player == null:
		return

	var equipment := player.get_node_or_null("EquipmentComponent") as EquipmentComponent
	_expect(equipment != null, "Equipment component available")
	var before: int = _inventory().get_quantity("slime_gel")
	var added: int = _inventory().add_item("slime_gel", 1)
	_expect(added == 1, "Inventory accepts item")
	_expect(_inventory().get_quantity("slime_gel") == before + 1, "Inventory quantity updates")

	var weapon_added: int = _inventory().add_item("swift_katana", 1)
	_expect(weapon_added == 1, "Inventory accepts equipment")
	_expect(equipment.equip_from_inventory("swift_katana"), "Equipment can be equipped")
	_expect(equipment.get_equipped_id("weapon") == "swift_katana", "Equipment slot updates")


func _count_nodes_of_type(root: Node, script_type: Variant) -> int:
	var count := 1 if is_instance_of(root, script_type) else 0
	for child: Node in root.get_children():
		count += _count_nodes_of_type(child, script_type)
	return count


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _action_has_physical_key(action: StringName, physical_keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == physical_keycode:
			return true
	return false


func _zone_manager():
	return root.get_node("ZoneManager")


func _inventory():
	return root.get_node("Inventory")
