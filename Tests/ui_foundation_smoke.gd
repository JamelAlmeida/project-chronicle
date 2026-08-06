extends SceneTree

const HEARTHVALE := "res://Project Chronicle/Scenes/World/Zones/hearthvale_sideview_entry.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_inventory().clear()
	_progression().reset_progression()
	_techniques().reset_techniques()
	_quests().reset_quests()
	var error := change_scene_to_file(HEARTHVALE)
	_expect(error == OK, "UI proof scene loads")
	if error != OK:
		_finish()
		return
	await scene_changed
	await process_frame
	await process_frame

	var hud := current_scene.get_node("GameHUD")
	var menu := current_scene.get_node("EquipmentDebugPanel")
	var player := get_first_node_in_group("player")
	_expect(hud.has_node("BottomHUD"), "Bottom HUD is present")
	_expect(hud.has_node("TopLeft/ExpeditionPanel"), "Expedition panel is present")
	_expect(hud.find_child("ActionBar", true, false) != null, "Action bar shell is present")
	_expect(hud.has_node("TopRight/QuestTracker"), "Quest tracker is present")
	_expect(hud.find_child("PlayerStatus", true, false) != null, "Player status shell is present")
	_expect(hud.find_child("MenuButtons", true, false) != null, "Menu buttons shell is present")
	_expect(hud.find_child("ExperienceBar", true, false) != null, "Experience bar shell is present")
	_expect(hud.has_node("OverlayLayer"), "Overlay layer is present")
	_expect(not hud.has_node("ProgressionPanel"), "Old progression debug block is absent")
	_expect(not hud.has_node("HudShell"), "Legacy HudShell ornament root is absent")
	_expect(not hud.has_node("StatusIsland"), "Legacy StatusIsland ornament root is absent")
	_expect(not hud.has_node("ActionIsland"), "Legacy ActionIsland ornament root is absent")
	_expect(not hud.has_node("MenuIsland"), "Legacy MenuIsland ornament root is absent")
	_expect(current_scene.find_children("GameHUD", "", true, false).size() == 1, "Only one GameHUD root is active")
	_expect(not ChronicleUITheme.USE_ORNAMENT_SKINS, "Ornament skins are disabled for live presentation")
	_expect(ChronicleUITheme.runtime_texture("bottom_hud.png") == null, "Legacy bottom_hud texture is not loadable by live UI")
	_expect(ChronicleUITheme.runtime_texture("status_island_9.png") == null, "Legacy status island texture is not loadable by live UI")
	_expect(ChronicleUITheme.runtime_texture("menu_island_9.png") == null, "Legacy menu island texture is not loadable by live UI")

	var player_sprite := player.get_node("Visuals/BaseCharacter") as AnimatedSprite2D
	_expect(player_sprite != null and player_sprite.visible, "Approved Adventurer sprite is visible")
	_expect(
		player_sprite.sprite_frames != null
		and String(player_sprite.sprite_frames.resource_path).ends_with("adventurer_kit_v1_sprite_frames.tres"),
		"Player uses Adventurer kit frames"
	)
	var ground_shadow := player.get_node_or_null("Visuals/GroundShadow") as CanvasItem
	_expect(ground_shadow == null or not ground_shadow.visible, "Player GroundShadow is disabled")

	# Empty hotbar slots must not show filler TextureRect content.
	var action_bar := hud.find_child("ActionBar", true, false)
	_expect(action_bar != null, "ActionBar node exists")
	if action_bar != null:
		var empty_slot := action_bar.get_node_or_null("Slot_hotbar_2") as PanelContainer
		_expect(empty_slot != null, "Hotbar slot 2 exists as empty shell")
		if empty_slot != null:
			var icon := empty_slot.find_child("Icon", true, false) as TextureRect
			_expect(icon != null and (not icon.visible or icon.texture == null), "Unassigned hotbar slot stays visually empty")

	var stats: StatsComponent = player.get_node("StatsComponent")
	var baseline_damage := stats.get_attack_damage()
	_progression().unspent_stat_points = 1
	_progression().stat_points_changed.emit(1)
	menu.call("open_panel", &"character")
	_expect(menu.call("is_panel_open", &"character"), "Character panel opens")
	_expect(player.call("_is_gameplay_input_blocked"), "Open panels block direct gameplay input")
	var strength_button := _find_button_by_tooltip(menu, "Spend one point in Strength")
	_expect(strength_button != null, "Strength allocation control is clickable")
	if strength_button != null:
		strength_button.emit_signal("pressed")
	_expect(_progression().unspent_stat_points == 0, "Clickable allocation spends one point")
	_expect(_progression().get_allocated_points(&"strength") == 1, "Clickable allocation updates Strength")
	_expect(stats.get_attack_damage() > baseline_damage, "Clickable allocation updates derived stats")

	_inventory().add_item("swift_katana", 1)
	menu.call("open_panel", &"inventory")
	_expect(menu.call("is_panel_open", &"inventory"), "Inventory panel opens")
	var equip_button := _find_button_by_text(menu, "Equip")
	_expect(equip_button != null, "Inventory exposes equipment action")
	if equip_button != null:
		equip_button.emit_signal("pressed")
	var equipment: EquipmentComponent = player.get_node("EquipmentComponent")
	_expect(equipment.get_equipped_id("weapon") == "swift_katana", "Inventory equip flow remains functional")

	menu.call("open_panel", &"techniques")
	_expect(menu.call("is_panel_open", &"techniques"), "Technique Book opens")
	menu.call("open_panel", &"quests")
	_expect(menu.call("is_panel_open", &"quests"), "Quest Log opens")
	menu.call("close_panel")
	_expect(not player.call("_is_gameplay_input_blocked"), "Closing panels restores gameplay input")
	_finish()


func _find_button_by_tooltip(root_node: Node, tooltip: String) -> Button:
	if root_node is Button and (root_node as Button).tooltip_text == tooltip:
		return root_node as Button
	for child: Node in root_node.get_children():
		var result := _find_button_by_tooltip(child, tooltip)
		if result != null:
			return result
	return null


func _find_button_by_text(root_node: Node, text: String) -> Button:
	if root_node is Button and (root_node as Button).text == text:
		return root_node as Button
	for child: Node in root_node.get_children():
		var result := _find_button_by_text(child, text)
		if result != null:
			return result
	return null


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _finish() -> void:
	if _failures.is_empty():
		print("UI FOUNDATION SMOKE: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("UI FOUNDATION SMOKE: %s" % failure)
	quit(1)


func _inventory():
	return root.get_node("Inventory")


func _progression():
	return root.get_node("CharacterProgression")


func _techniques():
	return root.get_node("TechniqueManager")


func _quests():
	return root.get_node("QuestManager")
