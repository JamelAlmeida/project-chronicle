extends SceneTree

const HEARTHVALE := "res://Project Chronicle/Scenes/World/Zones/hearthvale_sideview_entry.tscn"
const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_reset_foundation()
	_expect(_progression().get_xp_needed_for_next_level() == 50, "Level 1 XP requirement uses config")
	_expect(
		_progression().config.get_xp_requirement(40) > _progression().config.get_xp_requirement(10),
		"XP curve supports Level 40 and beyond"
	)
	_expect(_quests().get_state_name("elderwood_trial") == "Available", "Starter quest is available")
	_expect(_quests().activate_quest("elderwood_trial"), "Starter quest activates")

	await _load_scene(HEARTHVALE)
	var player := await _settle_player()
	_expect(player != null, "Progression proof player spawns")
	if player == null:
		_finish()
		return

	var stats: StatsComponent = player.get_node("StatsComponent")
	var health: HealthComponent = player.get_node("HealthComponent")
	var equipment: EquipmentComponent = player.get_node("EquipmentComponent")
	var baseline_damage := stats.get_attack_damage()
	var baseline_health := stats.get_max_health()

	_progression().gain_xp(50, &"test")
	_expect(_progression().current_level == 2, "XP gain reaches Level 2")
	_expect(_progression().unspent_stat_points == 1, "Level up grants a stat point")
	_expect(_techniques().is_unlocked("forceful_edge"), "Level 2 Technique unlocks")
	_expect(stats.get_attack_damage() > baseline_damage, "Level and passive Technique increase damage")

	_expect(_progression().allocate_stat(&"strength"), "Strength point allocates")
	_expect(stats.get_attack_damage() >= baseline_damage + 5.0, "Strength meaningfully increases melee damage")
	_progression().unspent_stat_points += 1
	_expect(_progression().allocate_stat(&"vitality"), "Vitality point allocates")
	_expect(stats.get_max_health() >= baseline_health + 12.0, "Vitality and level growth increase health")

	_inventory().add_item("swift_katana", 1)
	_expect(equipment.equip_from_inventory("swift_katana"), "Existing equipment still equips")
	var equipment_breakdown: Dictionary = stats.get_stat_breakdown("attack_damage")
	_expect(
		not is_zero_approx(float(equipment_breakdown.get("equipment", 0.0))),
		"Equipment modifier remains separated"
	)

	_inventory().add_item("crimson_leech_ring", 1)
	_expect(equipment.equip_from_inventory("crimson_leech_ring"), "Existing lifesteal ring equips")
	health.set_current_health(maxi(health.max_health - 30, 1))
	var health_before_lifesteal := health.current_health
	var melee: MeleeAttack = player.get_node("MeleeAttack")
	melee.call("_apply_lifesteal", 50)
	_expect(health.current_health > health_before_lifesteal, "Lifesteal remains functional")

	await _load_scene(ELDERWOOD)
	player = await _settle_player()
	var enemies := get_nodes_in_group("enemies")
	_expect(enemies.size() >= 2, "Elderwood contains quest targets")
	for index in range(mini(enemies.size(), 2)):
		(enemies[index] as EnemyBase).take_damage(99999)
		await process_frame
		await process_frame
	_expect(_quests().get_state_name("elderwood_trial") == "Ready to turn in", "Kill objective progresses")
	_expect(_quests().turn_in_quest("elderwood_trial"), "Starter quest turns in")
	_expect(_techniques().is_unlocked("arc_sweep"), "Quest reward unlocks Arc Sweep")
	_expect(_quests().get_state_name("gel_for_the_road") == "Available", "Quest chain unlocks next quest")

	_expect(_quests().activate_quest("gel_for_the_road"), "Collection quest activates")
	_inventory().add_item("slime_gel", 3)
	_expect(_quests().get_state_name("gel_for_the_road") == "Ready to turn in", "Collect objective progresses")
	_expect(_quests().turn_in_quest("gel_for_the_road"), "Collection quest turns in")
	_expect(_techniques().is_unlocked("trailblazers_step"), "Quest reward unlocks dash Technique")

	player = get_first_node_in_group("player")
	melee = player.get_node("MeleeAttack") as MeleeAttack
	_expect(
		melee.try_technique(_techniques().get_equipped_active(), Vector2.RIGHT),
		"Arc Sweep active Technique starts"
	)
	_expect(melee.is_attacking(), "Arc Sweep uses the multi-target melee architecture")
	await _wait_physics(20)

	while _progression().current_level < 5:
		_progression().gain_xp(_progression().get_xp_needed_for_next_level(), &"test")
	_expect(_progression().current_level == 5, "Progression foundation reaches Level 5")
	_expect(_techniques().is_unlocked("resolute_breath"), "Level 4 survival Technique unlocks")
	_finish()


func _reset_foundation() -> void:
	_inventory().clear()
	_progression().reset_progression()
	_techniques().reset_techniques()
	_quests().reset_quests()


func _load_scene(path: String) -> void:
	var error := change_scene_to_file(path)
	_expect(error == OK, "Scene loads: %s" % path)
	if error == OK:
		await scene_changed
		await process_frame


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


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _finish() -> void:
	if _failures.is_empty():
		print("PROGRESSION FOUNDATION SMOKE: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("PROGRESSION FOUNDATION SMOKE: %s" % failure)
	quit(1)


func _inventory():
	return root.get_node("Inventory")


func _progression():
	return root.get_node("CharacterProgression")


func _techniques():
	return root.get_node("TechniqueManager")


func _quests():
	return root.get_node("QuestManager")
