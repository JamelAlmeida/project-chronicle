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
var _quest_tracker_label: Control
var _zone_banner: PanelContainer
var _zone_title: Label
var _zone_subtitle: Label
var _status_label: Label
var _technique_cooldown_label: Label
var _technique_slot: PanelContainer
var _action_bar_slots: Array[PanelContainer] = []
var _hotbar_slots: Array[PanelContainer] = []

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
	## Clean structural foundation — no legacy ornament hierarchy.
	_build_top_left()
	_build_top_right()
	_build_bottom_hud()
	_build_overlay_layer()


func _build_top_left() -> void:
	var top_left := Control.new()
	top_left.name = "TopLeft"
	top_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_left.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(top_left)

	var panel := PanelContainer.new()
	panel.name = "ExpeditionPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(16.0, 12.0)
	panel.custom_minimum_size = Vector2(220.0, 68.0)
	panel.size = Vector2(220.0, 68.0)
	panel.add_theme_stylebox_override("panel", UI.hud_panel_style())
	top_left.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	var heading := UI.style_eyebrow(Label.new(), UI.COLOR_MUTED, 11, HORIZONTAL_ALIGNMENT_LEFT)
	heading.text = "EXPEDITION"
	box.add_child(heading)
	_expedition_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 13)
	_expedition_label.text = "Unsecured loot: 0"
	box.add_child(_expedition_label)
	var inventory_hint := UI.style_label(Label.new(), UI.COLOR_MUTED, 11)
	inventory_hint.name = "InventoryHint"
	inventory_hint.text = "Inventory [I]"
	box.add_child(inventory_hint)


func _build_top_right() -> void:
	var top_right := Control.new()
	top_right.name = "TopRight"
	top_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_right.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(top_right)

	var panel := PanelContainer.new()
	panel.name = "QuestTracker"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -280.0
	panel.offset_top = 12.0
	panel.offset_right = -16.0
	panel.offset_bottom = 130.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.add_theme_stylebox_override("panel", UI.hud_panel_style())
	top_right.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var heading := UI.style_heading(Label.new(), UI.COLOR_MUTED, 11, HORIZONTAL_ALIGNMENT_LEFT)
	heading.text = "ACTIVE QUESTS"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(heading)
	var tracker := RichTextLabel.new()
	tracker.name = "QuestTrackerBody"
	tracker.bbcode_enabled = true
	tracker.fit_content = true
	tracker.scroll_active = false
	tracker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tracker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tracker.add_theme_font_override("normal_font", UI.body_font())
	tracker.add_theme_font_size_override("normal_font_size", 12)
	tracker.add_theme_color_override("default_color", UI.COLOR_TEXT)
	_quest_tracker_label = tracker
	box.add_child(tracker)


func _build_overlay_layer() -> void:
	var overlay := Control.new()
	overlay.name = "OverlayLayer"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var tooltips := Control.new()
	tooltips.name = "Tooltips"
	tooltips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltips.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(tooltips)

	var loot := Control.new()
	loot.name = "LootNotifications"
	loot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(loot)

	var combat_ui := Control.new()
	combat_ui.name = "FutureCombatUI"
	combat_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combat_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(combat_ui)

	_zone_banner = PanelContainer.new()
	_zone_banner.name = "ZoneBanner"
	_zone_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_zone_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_zone_banner.grow_vertical = Control.GROW_DIRECTION_END
	_zone_banner.anchor_left = 0.5
	_zone_banner.anchor_right = 0.5
	_zone_banner.anchor_top = 0.0
	_zone_banner.anchor_bottom = 0.0
	_zone_banner.offset_left = -180.0
	_zone_banner.offset_right = 180.0
	_zone_banner.offset_top = 72.0
	_zone_banner.offset_bottom = 130.0
	_zone_banner.add_theme_stylebox_override("panel", UI.hud_panel_style())
	overlay.add_child(_zone_banner)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_zone_banner.add_child(box)
	_zone_title = UI.style_heading(Label.new(), UI.COLOR_GOLD, 22, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_title)
	_zone_subtitle = UI.style_label(Label.new(), UI.COLOR_MUTED, 13, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_subtitle)
	_zone_banner.modulate.a = 0.0

	_status_label = UI.style_label(Label.new(), Color.WHITE, 15, HORIZONTAL_ALIGNMENT_CENTER)
	_status_label.name = "StatusMessage"
	_status_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_status_label.position = Vector2(-300.0, -196.0)
	_status_label.size = Vector2(600.0, 26.0)
	_status_label.modulate.a = 0.0
	loot.add_child(_status_label)


func _build_bottom_hud() -> void:
	var root := MarginContainer.new()
	root.name = "BottomHUD"
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.anchor_left = 0.0
	root.anchor_right = 1.0
	root.anchor_top = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 16.0
	root.offset_right = -16.0
	root.offset_top = -152.0
	root.offset_bottom = -12.0
	root.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(root)

	var column := VBoxContainer.new()
	column.name = "BottomColumn"
	column.add_theme_constant_override("separation", 6)
	root.add_child(column)

	var row := HBoxContainer.new()
	row.name = "HudRow"
	row.add_theme_constant_override("separation", 10)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(row)

	var status := _build_player_status()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.size_flags_stretch_ratio = 1.15
	row.add_child(status)

	var action := _build_action_bar()
	action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action.size_flags_stretch_ratio = 1.55
	row.add_child(action)

	var menu := _build_menu_buttons()
	menu.custom_minimum_size = Vector2(230.0, 96.0)
	menu.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(menu)

	_build_experience_bar(column)


func _build_experience_bar(parent: Control) -> void:
	var strip := Control.new()
	strip.name = "ExperienceBar"
	strip.custom_minimum_size = Vector2(0.0, 18.0)
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(strip)

	_xp_bar = ProgressBar.new()
	_xp_bar.name = "XPBar"
	_xp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_xp_bar.show_percentage = false
	_xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_xp_bar.add_theme_stylebox_override("background", UI.bar_background())
	var xp_fill := UI.bar_fill(UI.COLOR_XP)
	xp_fill.content_margin_top = 0.0
	xp_fill.content_margin_bottom = 0.0
	_xp_bar.add_theme_stylebox_override("fill", xp_fill)
	strip.add_child(_xp_bar)

	_xp_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 11, HORIZONTAL_ALIGNMENT_LEFT)
	_xp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_xp_label.offset_left = 8.0
	_xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_xp_label.text = "LEVEL 1  ·  XP 0 / 100"
	strip.add_child(_xp_label)


func _build_player_status() -> Control:
	var island := PanelContainer.new()
	island.name = "PlayerStatus"
	island.mouse_filter = Control.MOUSE_FILTER_STOP
	island.add_theme_stylebox_override("panel", UI.status_island_style())
	island.custom_minimum_size = Vector2(300.0, 96.0)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_theme_constant_override("separation", 4)
	island.add_child(box)

	_level_label = UI.style_heading(Label.new(), UI.COLOR_GOLD, 13)
	_level_label.text = "ADVENTURER  ·  LEVEL 1"
	box.add_child(_level_label)

	var hp_stack := Control.new()
	hp_stack.custom_minimum_size = Vector2(0.0, 24.0)
	box.add_child(hp_stack)
	_hp_bar = ProgressBar.new()
	_hp_bar.name = "HPBar"
	_hp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hp_bar.show_percentage = false
	_hp_bar.add_theme_stylebox_override("background", UI.bar_background())
	_hp_bar.add_theme_stylebox_override("fill", UI.bar_fill(UI.COLOR_HEALTH))
	hp_stack.add_child(_hp_bar)
	_hp_label = UI.style_label(Label.new(), Color(1.0, 0.97, 0.95), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_hp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hp_label.text = "HP 100 / 100"
	_hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_stack.add_child(_hp_label)

	var steadfast_stack := Control.new()
	steadfast_stack.custom_minimum_size = Vector2(0.0, 18.0)
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

	var steadfast_row := HBoxContainer.new()
	steadfast_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	steadfast_row.offset_left = 6.0
	steadfast_row.offset_right = -6.0
	steadfast_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_stack.add_child(steadfast_row)
	var steadfast_name := UI.style_label(Label.new(), Color(0.86, 0.90, 1.0), 10)
	steadfast_name.text = "STEADFAST"
	steadfast_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	steadfast_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_row.add_child(steadfast_name)
	_resource_label = UI.style_label(Label.new(), Color(0.92, 0.95, 1.0), 10, HORIZONTAL_ALIGNMENT_RIGHT)
	_resource_label.text = "100 / 100"
	_resource_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_row.add_child(_resource_label)
	return island


func _build_action_bar() -> Control:
	## Structural action tray — assigned icons only; empty slots stay blank.
	var island := PanelContainer.new()
	island.name = "ActionBarShell"
	island.mouse_filter = Control.MOUSE_FILTER_STOP
	island.add_theme_stylebox_override("panel", UI.action_island_style())
	island.custom_minimum_size = Vector2(480.0, 96.0)

	var center := HBoxContainer.new()
	center.name = "ActionBar"
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 6)
	island.add_child(center)

	_action_bar_slots.clear()
	_hotbar_slots.clear()

	center.add_child(_make_action_slot(
		&"attack",
		"Basic Attack",
		"E",
		Color(0.72, 0.52, 0.28),
		Icons.texture(Icons.ATTACK)
	))
	center.add_child(_make_action_slot(
		&"dash",
		"Combat Dash",
		"SPACE",
		Color(0.28, 0.58, 0.50),
		Icons.texture(Icons.DASH)
	))

	for index in range(5):
		var key := str(index + 1)
		var slot := _make_action_slot(
			StringName("hotbar_%d" % (index + 1)),
			"Unassigned",
			key,
			UI.COLOR_BRASS,
			null
		)
		_hotbar_slots.append(slot)
		center.add_child(slot)
		if index == 0:
			_technique_slot = slot
			_technique_cooldown_label = slot.get_meta("cooldown_label") as Label

	center.add_child(_make_action_slot(
		&"reserved",
		"Reserved Slot",
		"",
		Color(0.35, 0.36, 0.40),
		null
	))
	return island


func _make_action_slot(
	slot_id: StringName,
	action_name: String,
	key_text: String,
	accent: Color,
	assigned_icon: Texture2D
) -> PanelContainer:
	var assigned := assigned_icon != null
	var slot := PanelContainer.new()
	slot.name = "Slot_%s" % String(slot_id)
	slot.custom_minimum_size = Vector2(58.0, 72.0)
	slot.tooltip_text = action_name
	slot.add_theme_stylebox_override(
		"panel",
		UI.action_slot_style(accent if assigned else Color(0.28, 0.30, 0.34), assigned)
	)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	slot.add_child(box)

	var icon_stack := Control.new()
	icon_stack.name = "IconStack"
	icon_stack.custom_minimum_size = Vector2(42, 40)
	box.add_child(icon_stack)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = assigned_icon
	icon.visible = assigned
	icon_stack.add_child(icon)

	var lock_rect := ColorRect.new()
	lock_rect.name = "LockOverlay"
	lock_rect.color = Color(0.08, 0.08, 0.10, 0.72)
	lock_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lock_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_rect.visible = false
	icon_stack.add_child(lock_rect)

	var cooldown := UI.style_label(Label.new(), Color.WHITE, 11, HORIZONTAL_ALIGNMENT_CENTER)
	cooldown.name = "CooldownLabel"
	cooldown.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cooldown.text = ""
	cooldown.visible = false
	cooldown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_stack.add_child(cooldown)

	var key := UI.style_keybind(Label.new(), true, 10)
	key.name = "Keybind"
	key.text = key_text
	box.add_child(key)

	slot.set_meta("slot_id", slot_id)
	slot.set_meta("icon_rect", icon)
	slot.set_meta("lock_overlay", lock_rect)
	slot.set_meta("cooldown_label", cooldown)
	slot.set_meta("keybind_label", key)
	slot.set_meta("accent", accent)
	slot.set_meta("assigned", assigned)
	slot.set_meta("locked", false)
	_action_bar_slots.append(slot)
	return slot


## Assign a real gameplay icon to a hotbar/action slot. Pass null to clear.
func assign_action_slot(
	slot: PanelContainer,
	icon_texture: Texture2D,
	tooltip: String = "Unassigned",
	locked: bool = false
) -> void:
	if slot == null:
		return
	var icon := slot.get_meta("icon_rect") as TextureRect
	var lock_overlay := slot.get_meta("lock_overlay") as CanvasItem
	var accent: Color = slot.get_meta("accent", UI.COLOR_BRASS)
	var has_icon := icon_texture != null and not locked

	if icon != null:
		icon.texture = icon_texture if has_icon else null
		icon.visible = has_icon
	if lock_overlay != null:
		## Locked state shows ONLY the lock overlay — never filler artwork underneath.
		lock_overlay.visible = locked
	slot.tooltip_text = tooltip
	slot.set_meta("assigned", has_icon)
	slot.set_meta("locked", locked)
	slot.modulate = Color(0.62, 0.62, 0.62, 0.94) if locked else Color.WHITE
	slot.add_theme_stylebox_override(
		"panel",
		UI.action_slot_style(accent if has_icon else Color(0.28, 0.30, 0.34), has_icon)
	)


func clear_action_slot(slot: PanelContainer, tooltip: String = "Unassigned") -> void:
	assign_action_slot(slot, null, tooltip, false)


func _build_menu_buttons() -> Control:
	var island := PanelContainer.new()
	island.name = "MenuButtons"
	island.mouse_filter = Control.MOUSE_FILTER_STOP
	island.add_theme_stylebox_override("panel", UI.menu_island_style())

	var grid := GridContainer.new()
	grid.name = "MenuGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	island.add_child(grid)

	grid.add_child(_make_menu_button("CHARACTER", "C", &"character"))
	grid.add_child(_make_menu_button("INVENTORY", "I", &"inventory"))
	grid.add_child(_make_menu_button("TECHNIQUES", "K", &"techniques"))
	grid.add_child(_make_menu_button("QUEST LOG", "J", &"quests"))
	return island


func _make_menu_button(text: String, key: String, panel_id: StringName) -> Button:
	var button := UI.style_button(Button.new())
	button.custom_minimum_size = Vector2(104.0, 40.0)
	button.add_theme_font_size_override("font_size", 11)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.icon = null
	button.text = "%s [%s]" % [text, key]
	button.pressed.connect(_open_panel.bind(panel_id))
	return button


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
	_expedition_label.text = "Unsecured loot: %d" % total


func _refresh_quest_tracker() -> void:
	if _quest_tracker_label == null:
		return
	var quest_lines: PackedStringArray = _quest_manager().get_visible_quest_lines()
	if quest_lines.is_empty():
		_quest_tracker_label.text = "No tracked objectives.\nPress F near opportunities."
		_quest_tracker_label.add_theme_color_override("font_color", UI.COLOR_TEXT)
		return
	# Prefer BBCode hierarchy: gold titles, muted ivory objectives.
	if _quest_tracker_label is RichTextLabel:
		var rtl := _quest_tracker_label as RichTextLabel
		rtl.clear()
		for line: String in quest_lines:
			if line.begins_with("◆"):
				rtl.append_text("[color=#e8e6dc]%s[/color]\n" % line)
			else:
				rtl.append_text("[color=#a8aab0]%s[/color]\n" % line)
	else:
		_quest_tracker_label.text = "\n".join(quest_lines)


func _refresh_action_slot_state() -> void:
	if _hotbar_slots.is_empty():
		return

	# Hotbar slot 1 mirrors equipped active Technique when present.
	# Unassigned slots stay visually empty — never showcase filler art.
	var primary := _hotbar_slots[0] if _hotbar_slots.size() > 0 else _technique_slot
	if primary == null:
		return

	var technique_id: String = _technique_manager().get_equipped_active(0)
	if technique_id.is_empty():
		clear_action_slot(primary, "Unassigned")
		if _technique_cooldown_label != null:
			_technique_cooldown_label.visible = false
			_technique_cooldown_label.text = ""
	else:
		var technique: TechniqueData = _technique_manager().get_technique(technique_id)
		if technique == null:
			clear_action_slot(primary, "Unassigned")
		else:
			## Only show a Technique icon when the Technique has real authored art.
			assign_action_slot(primary, technique.icon, technique.display_name, false)
			primary.set_meta("accent", UI.COLOR_TECHNIQUE)
			var remaining: float = _technique_manager().get_cooldown_remaining(technique_id)
			if _technique_cooldown_label != null:
				_technique_cooldown_label.visible = remaining > 0.0
				_technique_cooldown_label.text = "%.1f" % remaining if remaining > 0.0 else ""
			var ready := remaining <= 0.0
			primary.modulate = Color(0.58, 0.58, 0.58) if not ready else Color.WHITE
			primary.add_theme_stylebox_override(
				"panel",
				UI.action_slot_style(
					UI.COLOR_TECHNIQUE if technique.icon != null else Color(0.22, 0.18, 0.14),
					technique.icon != null and ready
				)
			)

	# Slots 2–5 remain blank until real assignments exist.
	for index in range(1, _hotbar_slots.size()):
		var slot := _hotbar_slots[index]
		if not bool(slot.get_meta("assigned", false)) and not bool(slot.get_meta("locked", false)):
			clear_action_slot(slot, "Unassigned")


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
