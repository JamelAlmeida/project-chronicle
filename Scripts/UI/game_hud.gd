extends CanvasLayer

const UI := preload("res://Project Chronicle/Scripts/UI/chronicle_ui_theme.gd")
const Icons := preload("res://Project Chronicle/Scripts/UI/hud_icons.gd")

var _hp_bar: ProgressBar
var _hp_label: Label
var _level_label: Label
var _resource_label: Label
var _steadfast_bar: ProgressBar
var _xp_bar: ProgressBar
var _xp_label: Label
var _expedition_label: Label
var _quest_tracker_label: Label
var _zone_banner: PanelContainer
var _zone_title: Label
var _zone_subtitle: Label
var _status_label: Label
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
	panel.position = Vector2(14.0, 12.0)
	panel.size = Vector2(228.0, 48.0)
	panel.add_theme_stylebox_override(
		"panel",
		UI.hud_panel_style(Color(0.035, 0.028, 0.022, 0.86), UI.COLOR_BRASS_LIGHT)
	)
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	panel.add_child(box)
	var heading := UI.style_eyebrow(Label.new(), UI.COLOR_GOLD, 9)
	heading.text = "EXPEDITION"
	box.add_child(heading)
	_expedition_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 11)
	_expedition_label.text = "Unsecured loot: 0"
	box.add_child(_expedition_label)


func _build_quest_tracker() -> void:
	var panel := PanelContainer.new()
	panel.name = "QuestTracker"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -286.0
	panel.offset_top = 12.0
	panel.offset_right = -14.0
	panel.offset_bottom = 108.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.add_theme_stylebox_override(
		"panel",
		UI.hud_panel_style(Color(0.035, 0.03, 0.024, 0.86), UI.COLOR_QUEST)
	)
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	var heading := UI.style_heading(Label.new(), Color(0.80, 0.90, 0.60), 11)
	heading.text = "ACTIVE QUESTS"
	box.add_child(heading)
	_quest_tracker_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 11)
	_quest_tracker_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quest_tracker_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_quest_tracker_label)


func _build_zone_banner() -> void:
	_zone_banner = PanelContainer.new()
	_zone_banner.name = "ZoneBanner"
	_zone_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_zone_banner.position = Vector2(-190.0, 26.0)
	_zone_banner.size = Vector2(380.0, 66.0)
	_zone_banner.add_theme_stylebox_override(
		"panel",
		UI.hud_panel_style(Color(0.04, 0.032, 0.024, 0.88), Color(0.72, 0.54, 0.26, 0.95))
	)
	add_child(_zone_banner)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_zone_banner.add_child(box)
	_zone_title = UI.style_heading(Label.new(), UI.COLOR_GOLD, 24, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_title)
	_zone_subtitle = UI.style_label(Label.new(), Color(0.84, 0.80, 0.70), 12, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_subtitle)
	_zone_banner.modulate.a = 0.0


func _build_bottom_hud() -> void:
	var panel := PanelContainer.new()
	panel.name = "BottomHUD"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 0.0
	panel.offset_top = -128.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.add_theme_stylebox_override("panel", UI.bottom_hud_style())
	add_child(panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 5)
	panel.add_child(outer)

	var main_row := HBoxContainer.new()
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", 14)
	outer.add_child(main_row)
	main_row.add_child(_build_vitals())
	main_row.add_child(_build_action_bar())
	main_row.add_child(_build_menu_access())

	var xp_row := HBoxContainer.new()
	xp_row.add_theme_constant_override("separation", 8)
	outer.add_child(xp_row)
	_xp_label = UI.style_label(Label.new(), Color(0.78, 0.88, 0.96), 10)
	_xp_label.custom_minimum_size.x = 150.0
	xp_row.add_child(_xp_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.name = "XPBar"
	_xp_bar.custom_minimum_size.y = 6.0
	_xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_xp_bar.show_percentage = false
	_xp_bar.add_theme_stylebox_override("background", UI.bar_background())
	_xp_bar.add_theme_stylebox_override("fill", UI.bar_fill(UI.COLOR_XP))
	xp_row.add_child(_xp_bar)


func _build_vitals() -> Control:
	var row := HBoxContainer.new()
	row.name = "Vitals"
	row.custom_minimum_size.x = 300.0
	row.add_theme_constant_override("separation", 8)

	var crest := PanelContainer.new()
	crest.custom_minimum_size = Vector2(52.0, 52.0)
	crest.add_theme_stylebox_override("panel", UI.action_slot_style(UI.COLOR_BRASS_LIGHT))
	var crest_icon := Icons.make_rect(Icons.CREST, Vector2(40, 40))
	crest.add_child(crest_icon)
	row.add_child(crest)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	row.add_child(box)

	_level_label = UI.style_heading(Label.new(), UI.COLOR_GOLD, 12)
	_level_label.text = "ADVENTURER  ·  LEVEL 1"
	box.add_child(_level_label)

	var hp_stack := Control.new()
	hp_stack.custom_minimum_size = Vector2(230.0, 16.0)
	box.add_child(hp_stack)
	_hp_bar = ProgressBar.new()
	_hp_bar.name = "HPBar"
	_hp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hp_bar.show_percentage = false
	_hp_bar.add_theme_stylebox_override("background", UI.bar_background())
	_hp_bar.add_theme_stylebox_override("fill", UI.bar_fill(UI.COLOR_HEALTH))
	hp_stack.add_child(_hp_bar)
	_hp_label = UI.style_label(Label.new(), Color(1.0, 0.93, 0.88), 10, HORIZONTAL_ALIGNMENT_CENTER)
	_hp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hp_label.text = "HP 100 / 100"
	_hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_stack.add_child(_hp_label)

	var steadfast_stack := Control.new()
	steadfast_stack.custom_minimum_size = Vector2(230.0, 12.0)
	box.add_child(steadfast_stack)
	_steadfast_bar = ProgressBar.new()
	_steadfast_bar.name = "SteadfastBar"
	_steadfast_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_steadfast_bar.max_value = 100.0
	_steadfast_bar.value = 100.0
	_steadfast_bar.show_percentage = false
	_steadfast_bar.add_theme_stylebox_override("background", UI.bar_background())
	_steadfast_bar.add_theme_stylebox_override("fill", UI.bar_fill(UI.COLOR_STEADFAST))
	steadfast_stack.add_child(_steadfast_bar)
	_resource_label = UI.style_label(Label.new(), Color(0.86, 0.92, 1.0), 9, HORIZONTAL_ALIGNMENT_CENTER)
	_resource_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_resource_label.text = "STEADFAST  100 / 100"
	_resource_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_stack.add_child(_resource_label)
	return row


func _build_action_bar() -> Control:
	var center := HBoxContainer.new()
	center.name = "ActionBar"
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 5)

	center.add_child(_make_action_slot(Icons.ATTACK, "Basic Attack", "E", Color(0.82, 0.60, 0.24), true))
	center.add_child(_make_action_slot(Icons.DASH, "Combat Dash", "SPACE", Color(0.28, 0.58, 0.50), true))
	_technique_slot = _make_action_slot(Icons.TECHNIQUE, "No active Technique", "1", UI.COLOR_TECHNIQUE, true)
	_technique_cooldown_label = _technique_slot.get_meta("cooldown_label") as Label
	center.add_child(_technique_slot)
	center.add_child(_make_action_slot(Icons.ARC_SLASH, "Future Technique", "2", Color(0.74, 0.58, 0.24), false))
	center.add_child(_make_action_slot(Icons.PULSE_WAVE, "Future Technique", "3", Color(0.28, 0.52, 0.78), false))
	center.add_child(_make_action_slot(Icons.VERDANT_BLOOM, "Future Technique", "4", Color(0.32, 0.62, 0.38), false))
	center.add_child(_make_action_slot(Icons.POTION, "Future Technique", "5", Color(0.72, 0.28, 0.28), false))
	return center


func _make_action_slot(
	icon_id: String,
	action_name: String,
	key_text: String,
	accent: Color,
	unlocked: bool
) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(58.0, 68.0)
	slot.tooltip_text = action_name
	slot.add_theme_stylebox_override(
		"panel",
		UI.action_slot_style(accent if unlocked else Color(0.20, 0.16, 0.12))
	)
	if not unlocked:
		slot.modulate = Color(0.68, 0.68, 0.68, 0.86)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 1)
	slot.add_child(box)

	var icon_plate := PanelContainer.new()
	icon_plate.custom_minimum_size = Vector2(46.0, 42.0)
	var plate_style := StyleBoxFlat.new()
	plate_style.bg_color = Color(0.05, 0.038, 0.028, 0.98)
	plate_style.border_width_left = 1
	plate_style.border_width_top = 1
	plate_style.border_width_right = 1
	plate_style.border_width_bottom = 1
	plate_style.border_color = accent.lightened(0.22) if unlocked else Color(0.24, 0.2, 0.15, 1.0)
	plate_style.corner_radius_top_left = 3
	plate_style.corner_radius_top_right = 3
	plate_style.corner_radius_bottom_right = 3
	plate_style.corner_radius_bottom_left = 3
	plate_style.content_margin_left = 2.0
	plate_style.content_margin_top = 2.0
	plate_style.content_margin_right = 2.0
	plate_style.content_margin_bottom = 2.0
	icon_plate.add_theme_stylebox_override("panel", plate_style)
	box.add_child(icon_plate)

	var icon_stack := Control.new()
	icon_stack.custom_minimum_size = Vector2(40, 36)
	icon_plate.add_child(icon_stack)
	var icon := Icons.make_rect(icon_id, Vector2(38, 36))
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_stack.add_child(icon)

	var cooldown := UI.style_label(Label.new(), Color.WHITE, 10, HORIZONTAL_ALIGNMENT_CENTER)
	cooldown.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cooldown.text = ""
	cooldown.visible = false
	cooldown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_stack.add_child(cooldown)

	var key := UI.style_heading(Label.new(), UI.COLOR_GOLD if unlocked else UI.COLOR_MUTED, 9, HORIZONTAL_ALIGNMENT_CENTER)
	key.text = key_text
	box.add_child(key)

	slot.set_meta("icon_rect", icon)
	slot.set_meta("cooldown_label", cooldown)
	return slot


func _build_menu_access() -> Control:
	var box := GridContainer.new()
	box.name = "MenuAccess"
	box.columns = 2
	box.custom_minimum_size.x = 256.0
	box.add_theme_constant_override("h_separation", 5)
	box.add_theme_constant_override("v_separation", 5)
	box.add_child(_make_menu_button("CHARACTER", "C", &"character", Icons.MENU_CHARACTER))
	box.add_child(_make_menu_button("INVENTORY", "I", &"inventory", Icons.MENU_INVENTORY))
	box.add_child(_make_menu_button("TECHNIQUES", "K", &"techniques", Icons.MENU_TECHNIQUES))
	box.add_child(_make_menu_button("QUEST LOG", "J", &"quests", Icons.MENU_QUESTS))
	return box


func _make_menu_button(text: String, key: String, panel_id: StringName, icon_id: String) -> Button:
	var button := UI.style_button(Button.new())
	button.custom_minimum_size = Vector2(122.0, 32.0)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_constant_override("icon_max_width", 20)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.icon = Icons.texture(icon_id)
	button.expand_icon = true
	button.text = "%s [%s]" % [text, key]
	button.pressed.connect(_open_panel.bind(panel_id))
	return button


func _build_status_message() -> void:
	_status_label = UI.style_label(Label.new(), Color.WHITE, 13, HORIZONTAL_ALIGNMENT_CENTER)
	_status_label.name = "StatusMessage"
	_status_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_status_label.position = Vector2(-300.0, -146.0)
	_status_label.size = Vector2(600.0, 24.0)
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
	if _technique_slot == null or _technique_cooldown_label == null:
		return
	var technique_id: String = _technique_manager().get_equipped_active(0)
	if technique_id.is_empty():
		_technique_slot.tooltip_text = "No active Technique"
		_technique_cooldown_label.visible = true
		_technique_cooldown_label.text = "LOCKED"
		_technique_slot.modulate = Color(0.62, 0.62, 0.62)
		return
	var technique: TechniqueData = _technique_manager().get_technique(technique_id)
	if technique == null:
		return
	_technique_slot.tooltip_text = technique.display_name
	var remaining: float = _technique_manager().get_cooldown_remaining(technique_id)
	_technique_cooldown_label.visible = remaining > 0.0
	_technique_cooldown_label.text = "%.1f" % remaining if remaining > 0.0 else ""
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
