extends CanvasLayer

const UI := preload("res://Project Chronicle/Scripts/UI/chronicle_ui_theme.gd")

var _hp_bar: ProgressBar
var _hp_label: Label
var _level_label: Label
var _resource_label: Label
var _xp_bar: ProgressBar
var _xp_label: Label
var _expedition_label: Label
var _quest_tracker_label: Label
var _zone_banner: PanelContainer
var _zone_title: Label
var _zone_subtitle: Label
var _status_label: Label
var _technique_name_label: Label
var _technique_cooldown_label: Label
var _technique_slot: PanelContainer

var _banner_tween: Tween
var _status_tween: Tween


func _ready() -> void:
	add_to_group("game_hud")
	_build_interface()
	await get_tree().process_frame
	_connect_to_player()
	_connect_to_systems()
	_refresh_all()


func _process(_delta: float) -> void:
	_refresh_action_slot_state()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var result: String = _quest_manager().perform_context_action()
		show_status_message(result, Color(0.72, 0.86, 1.0))
		_refresh_quest_tracker()


func show_zone_banner(title: String, subtitle: String) -> void:
	_zone_title.text = title
	_zone_subtitle.text = subtitle
	_zone_banner.modulate.a = 0.0
	if _banner_tween != null:
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_property(_zone_banner, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_interval(1.8)
	_banner_tween.tween_property(_zone_banner, "modulate:a", 0.0, 0.45)


func show_status_message(text: String, color: Color = Color.WHITE) -> void:
	_status_label.text = text
	_status_label.add_theme_color_override("font_color", color)
	_status_label.modulate.a = 0.0
	if _status_tween != null:
		_status_tween.kill()
	_status_tween = create_tween()
	_status_tween.tween_property(_status_label, "modulate:a", 1.0, 0.15)
	_status_tween.tween_interval(2.4)
	_status_tween.tween_property(_status_label, "modulate:a", 0.0, 0.4)


func _build_interface() -> void:
	_build_expedition_readout()
	_build_quest_tracker()
	_build_zone_banner()
	_build_bottom_hud()
	_build_status_message()


func _build_expedition_readout() -> void:
	var panel := PanelContainer.new()
	panel.name = "ExpeditionReadout"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(20.0, 20.0)
	panel.size = Vector2(286.0, 82.0)
	panel.add_theme_stylebox_override("panel", UI.panel_style(Color(0.025, 0.03, 0.032, 0.94)))
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var heading := UI.style_eyebrow(Label.new(), UI.COLOR_BRASS_LIGHT, 11)
	heading.text = "FIELD LEDGER  ·  EXPEDITION"
	box.add_child(heading)
	box.add_child(UI.make_separator())
	_expedition_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 14)
	_expedition_label.text = "Unsecured loot: 0"
	box.add_child(_expedition_label)


func _build_quest_tracker() -> void:
	var panel := PanelContainer.new()
	panel.name = "QuestTracker"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -370.0
	panel.offset_top = 20.0
	panel.offset_right = -20.0
	panel.offset_bottom = 202.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.add_theme_stylebox_override("panel", UI.panel_style(Color(0.025, 0.032, 0.027, 0.94), UI.COLOR_QUEST))
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)
	var heading := UI.style_heading(Label.new(), Color(0.73, 0.84, 0.63), 15)
	heading.text = "ACTIVE QUESTS"
	box.add_child(heading)
	var key_hint := UI.style_label(Label.new(), UI.COLOR_MUTED, 10)
	key_hint.text = "QUEST LOG [J]  ·  CONTEXT ACTION [F]"
	box.add_child(key_hint)
	box.add_child(UI.make_separator())
	_quest_tracker_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 13)
	_quest_tracker_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quest_tracker_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_quest_tracker_label)


func _build_zone_banner() -> void:
	_zone_banner = PanelContainer.new()
	_zone_banner.name = "ZoneBanner"
	_zone_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_zone_banner.position = Vector2(-210.0, 34.0)
	_zone_banner.size = Vector2(420.0, 88.0)
	_zone_banner.add_theme_stylebox_override(
		"panel",
		UI.panel_style(Color(0.035, 0.04, 0.045, 0.84), Color(0.48, 0.36, 0.17, 0.9))
	)
	add_child(_zone_banner)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_zone_banner.add_child(box)
	_zone_title = UI.style_heading(Label.new(), UI.COLOR_GOLD, 26, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_title)
	_zone_subtitle = UI.style_label(Label.new(), Color(0.74, 0.77, 0.72), 15, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_subtitle)
	_zone_banner.modulate.a = 0.0


func _build_bottom_hud() -> void:
	var panel := PanelContainer.new()
	panel.name = "BottomHUD"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 18.0
	panel.offset_top = -158.0
	panel.offset_right = -18.0
	panel.offset_bottom = -16.0
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.add_theme_stylebox_override("panel", UI.panel_style(UI.COLOR_INK))
	add_child(panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 5)
	panel.add_child(outer)

	var main_row := HBoxContainer.new()
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", 16)
	outer.add_child(main_row)
	main_row.add_child(_build_vitals())
	main_row.add_child(_build_action_bar())
	main_row.add_child(_build_menu_access())

	var xp_row := HBoxContainer.new()
	xp_row.add_theme_constant_override("separation", 8)
	outer.add_child(xp_row)
	_xp_label = UI.style_label(Label.new(), Color(0.70, 0.82, 0.90), 12)
	_xp_label.custom_minimum_size.x = 190.0
	xp_row.add_child(_xp_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.name = "XPBar"
	_xp_bar.custom_minimum_size.y = 13.0
	_xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_xp_bar.show_percentage = false
	_xp_bar.add_theme_stylebox_override("background", UI.bar_background())
	_xp_bar.add_theme_stylebox_override("fill", UI.bar_fill(UI.COLOR_XP))
	xp_row.add_child(_xp_bar)


func _build_vitals() -> Control:
	var box := VBoxContainer.new()
	box.name = "Vitals"
	box.custom_minimum_size.x = 300.0
	box.add_theme_constant_override("separation", 3)
	_level_label = UI.style_heading(Label.new(), UI.COLOR_GOLD, 15)
	_level_label.text = "ADVENTURER  ·  LEVEL 1"
	box.add_child(_level_label)
	_hp_label = UI.style_label(Label.new(), Color(0.96, 0.78, 0.72), 12)
	_hp_label.text = "HP 100 / 100"
	box.add_child(_hp_label)
	_hp_bar = ProgressBar.new()
	_hp_bar.name = "HPBar"
	_hp_bar.custom_minimum_size = Vector2(284.0, 19.0)
	_hp_bar.show_percentage = false
	_hp_bar.add_theme_stylebox_override("background", UI.bar_background())
	_hp_bar.add_theme_stylebox_override("fill", UI.bar_fill(UI.COLOR_HEALTH))
	box.add_child(_hp_bar)
	_resource_label = UI.style_label(Label.new(), UI.COLOR_MUTED, 11)
	_resource_label.text = "SECONDARY RESOURCE  ·  RESERVED"
	box.add_child(_resource_label)
	return box


func _build_action_bar() -> Control:
	var center := VBoxContainer.new()
	center.name = "ActionBar"
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	var heading := UI.style_eyebrow(Label.new(), UI.COLOR_MUTED, 10, HORIZONTAL_ALIGNMENT_CENTER)
	heading.text = "ADVENTURER ACTIONS"
	center.add_child(heading)
	var slots := HBoxContainer.new()
	slots.alignment = BoxContainer.ALIGNMENT_CENTER
	slots.add_theme_constant_override("separation", 5)
	center.add_child(slots)

	slots.add_child(_make_action_slot("Steel", "Basic Attack", "E", Color(0.45, 0.34, 0.22)))
	slots.add_child(_make_action_slot("Step", "Combat Dash", "SPACE", Color(0.28, 0.42, 0.38)))
	_technique_slot = _make_action_slot("Technique", "No active Technique", "1 / Q", UI.COLOR_TECHNIQUE)
	_technique_name_label = _technique_slot.get_meta("name_label") as Label
	_technique_cooldown_label = _technique_slot.get_meta("cooldown_label") as Label
	slots.add_child(_technique_slot)
	for index in range(2, 6):
		slots.add_child(_make_action_slot("—", "Future Technique", str(index), Color(0.20, 0.20, 0.19)))
	return center


func _make_action_slot(icon_text: String, action_name: String, key_text: String, accent: Color) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(76.0, 80.0)
	slot.tooltip_text = action_name
	slot.add_theme_stylebox_override("panel", UI.inset_style(accent))
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	slot.add_child(box)
	var icon := UI.style_heading(Label.new(), accent.lightened(0.45), 11, HORIZONTAL_ALIGNMENT_CENTER)
	icon.text = icon_text
	icon.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(icon)
	var cooldown := UI.style_label(Label.new(), Color.WHITE, 12, HORIZONTAL_ALIGNMENT_CENTER)
	cooldown.text = ""
	box.add_child(cooldown)
	var key := UI.style_label(Label.new(), UI.COLOR_GOLD, 10, HORIZONTAL_ALIGNMENT_CENTER)
	key.text = key_text
	box.add_child(key)
	slot.set_meta("name_label", icon)
	slot.set_meta("cooldown_label", cooldown)
	return slot


func _build_menu_access() -> Control:
	var box := GridContainer.new()
	box.name = "MenuAccess"
	box.columns = 2
	box.custom_minimum_size.x = 282.0
	box.add_theme_constant_override("h_separation", 7)
	box.add_theme_constant_override("v_separation", 7)
	box.add_child(_make_menu_button("Character", "C", &"character"))
	box.add_child(_make_menu_button("Inventory", "I", &"inventory"))
	box.add_child(_make_menu_button("Techniques", "K", &"techniques"))
	box.add_child(_make_menu_button("Quest Log", "J", &"quests"))
	return box


func _make_menu_button(text: String, key: String, panel_id: StringName) -> Button:
	var button := UI.style_button(Button.new())
	button.custom_minimum_size = Vector2(136.0, 36.0)
	button.text = "%s  [%s]" % [text, key]
	button.pressed.connect(_open_panel.bind(panel_id))
	return button


func _build_status_message() -> void:
	_status_label = UI.style_label(Label.new(), Color.WHITE, 15, HORIZONTAL_ALIGNMENT_CENTER)
	_status_label.name = "StatusMessage"
	_status_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_status_label.position = Vector2(-300.0, -180.0)
	_status_label.size = Vector2(600.0, 30.0)
	_status_label.modulate.a = 0.0
	add_child(_status_label)


func _connect_to_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var health: HealthComponent = player.get_node("HealthComponent")
	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)
	_on_health_changed(health.current_health, health.max_health)


func _connect_to_systems() -> void:
	var zone_manager := get_node_or_null("/root/ZoneManager")
	if zone_manager != null:
		if not zone_manager.zone_changed.is_connected(_on_zone_changed):
			zone_manager.zone_changed.connect(_on_zone_changed)
		if zone_manager.current_zone != null:
			_on_zone_changed(zone_manager.current_zone)

	var inventory := get_node_or_null("/root/Inventory")
	if inventory != null:
		inventory.expedition_loot_changed.connect(_refresh_expedition_label)
		inventory.item_added.connect(_on_item_added)

	var progression := get_node_or_null("/root/CharacterProgression")
	if progression != null:
		progression.xp_gained.connect(_on_xp_gained)
		progression.level_up.connect(_on_level_up)
		progression.stat_points_changed.connect(_on_progression_changed)
		progression.stat_allocated.connect(_on_stat_allocated)

	var techniques := get_node_or_null("/root/TechniqueManager")
	if techniques != null:
		techniques.technique_unlocked.connect(_on_technique_unlocked)
		techniques.techniques_changed.connect(_refresh_action_slot_state)

	var quests := get_node_or_null("/root/QuestManager")
	if quests != null:
		quests.quest_state_changed.connect(_on_quest_state_changed)
		quests.quest_objective_progressed.connect(_on_quest_objective_progressed)


func _refresh_all() -> void:
	_refresh_progression()
	_refresh_expedition_label()
	_refresh_quest_tracker()
	_refresh_action_slot_state()


func _on_health_changed(current: int, maximum: int) -> void:
	_hp_bar.max_value = maximum
	_hp_bar.value = current
	_hp_label.text = "HP  %d / %d" % [current, maximum]


func _on_zone_changed(zone_data: ZoneData) -> void:
	if zone_data == null:
		return
	show_zone_banner(zone_data.display_name.to_upper(), zone_data.get_banner_subtitle())
	_refresh_expedition_label()


func _refresh_progression() -> void:
	var progression := get_node_or_null("/root/CharacterProgression")
	if progression == null:
		return
	var xp_needed: int = maxi(progression.get_xp_needed_for_next_level(), 1)
	_level_label.text = "ADVENTURER  ·  LEVEL %d" % progression.current_level
	_xp_bar.max_value = xp_needed
	_xp_bar.value = progression.current_xp
	_xp_label.text = "LEVEL %d  ·  XP %d / %d" % [
		progression.current_level,
		progression.current_xp,
		xp_needed,
	]


func _refresh_expedition_label() -> void:
	var inventory := get_node_or_null("/root/Inventory")
	if inventory == null:
		_expedition_label.text = "Unsecured loot: 0"
		return
	var total := 0
	for entry: Dictionary in inventory.get_expedition_summary():
		total += int(entry.get("quantity", 0))
	_expedition_label.text = "Unsecured loot: %d  ·  Inventory [I]" % total


func _refresh_quest_tracker() -> void:
	if _quest_tracker_label == null:
		return
	var quest_lines: PackedStringArray = _quest_manager().get_visible_quest_lines()
	_quest_tracker_label.text = (
		"\n".join(quest_lines)
		if not quest_lines.is_empty()
		else "No tracked objectives.\nPress F near opportunities."
	)


func _refresh_action_slot_state() -> void:
	if _technique_name_label == null:
		return
	var technique_id: String = _technique_manager().get_equipped_active(0)
	if technique_id.is_empty():
		_technique_name_label.text = "Technique"
		_technique_cooldown_label.text = "LOCKED"
		_technique_slot.modulate = Color(0.62, 0.62, 0.62)
		return
	var technique: TechniqueData = _technique_manager().get_technique(technique_id)
	if technique == null:
		return
	_technique_name_label.text = technique.display_name
	var remaining: float = _technique_manager().get_cooldown_remaining(technique_id)
	_technique_cooldown_label.text = "%.1f" % remaining if remaining > 0.0 else "READY"
	_technique_slot.modulate = Color(0.58, 0.58, 0.58) if remaining > 0.0 else Color.WHITE


func _open_panel(panel_id: StringName) -> void:
	var menu := get_tree().get_first_node_in_group("chronicle_menu")
	if menu != null:
		menu.call("open_panel", panel_id)


func _on_item_added(item_id: String, quantity_added: int, _new_total: int) -> void:
	var zone_manager := get_node_or_null("/root/ZoneManager")
	if zone_manager == null or zone_manager.is_in_safe_zone():
		return
	var item: ItemData = get_node("/root/ItemRegistry").get_item(item_id)
	var display_name: String = item.display_name if item != null else item_id
	show_status_message("Unsecured loot: %s x%d" % [display_name, quantity_added], Color(1.0, 0.85, 0.45))


func _on_xp_gained(amount: int, _current_xp: int, _xp_needed: int) -> void:
	if amount > 0:
		show_status_message("+%d XP" % amount, Color(0.55, 0.85, 1.0))
	_refresh_progression()


func _on_level_up(new_level: int, stat_points_awarded: int) -> void:
	show_status_message(
		"LEVEL %d  ·  +%d stat point" % [new_level, stat_points_awarded],
		UI.COLOR_GOLD
	)
	_refresh_progression()


func _on_progression_changed(_unused: int) -> void:
	_refresh_progression()


func _on_stat_allocated(_stat_id: StringName, _new_total: int) -> void:
	_refresh_progression()


func _on_technique_unlocked(technique_id: String) -> void:
	var technique: TechniqueData = _technique_manager().get_technique(technique_id)
	if technique != null:
		show_status_message("Technique unlocked: %s" % technique.display_name, Color(0.74, 0.66, 1.0))
	_refresh_action_slot_state()


func _on_quest_state_changed(_quest_id: String, _new_state: int) -> void:
	_refresh_quest_tracker()


func _on_quest_objective_progressed(
	_quest_id: String,
	_objective_index: int,
	_current: int,
	_required: int
) -> void:
	_refresh_quest_tracker()


func _technique_manager():
	return get_node("/root/TechniqueManager")


func _quest_manager():
	return get_node("/root/QuestManager")
