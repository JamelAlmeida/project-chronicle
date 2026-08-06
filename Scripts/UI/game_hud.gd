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
	_build_expedition_readout()
	_build_quest_tracker()
	_build_zone_banner()
	_build_bottom_hud()
	_build_status_message()


func _build_expedition_readout() -> void:
	var panel := PanelContainer.new()
	panel.name = "ExpeditionReadout"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(16.0, 12.0)
	panel.custom_minimum_size = Vector2(236.0, 74.0)
	panel.size = Vector2(236.0, 74.0)
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	panel.add_theme_stylebox_override("panel", UI.hud_panel_style())
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	var heading := UI.style_eyebrow(Label.new(), UI.COLOR_GOLD, 12, HORIZONTAL_ALIGNMENT_CENTER)
	heading.text = "EXPEDITION"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(heading)
	_expedition_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 13)
	_expedition_label.text = "Unsecured loot: 0"
	_expedition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(_expedition_label)
	var inventory_hint := UI.style_label(Label.new(), UI.COLOR_MUTED, 11)
	inventory_hint.name = "InventoryHint"
	inventory_hint.text = "Inventory [I]"
	box.add_child(inventory_hint)


func _build_quest_tracker() -> void:
	var panel := PanelContainer.new()
	panel.name = "QuestTracker"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -298.0
	panel.offset_top = 12.0
	panel.offset_right = -16.0
	panel.offset_bottom = 140.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	panel.add_theme_stylebox_override("panel", UI.hud_panel_style())
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var heading := UI.style_heading(Label.new(), UI.COLOR_GOLD, 12, HORIZONTAL_ALIGNMENT_CENTER)
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


func _build_zone_banner() -> void:
	_zone_banner = PanelContainer.new()
	_zone_banner.name = "ZoneBanner"
	_zone_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_zone_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_zone_banner.grow_vertical = Control.GROW_DIRECTION_END
	_zone_banner.anchor_left = 0.5
	_zone_banner.anchor_right = 0.5
	_zone_banner.anchor_top = 0.0
	_zone_banner.anchor_bottom = 0.0
	_zone_banner.offset_left = -200.0
	_zone_banner.offset_right = 200.0
	_zone_banner.offset_top = 88.0
	_zone_banner.offset_bottom = 156.0
	_zone_banner.add_theme_stylebox_override("panel", UI.hud_panel_style())
	add_child(_zone_banner)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_zone_banner.add_child(box)
	_zone_title = UI.style_heading(Label.new(), UI.COLOR_GOLD, 26, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_title)
	_zone_subtitle = UI.style_label(Label.new(), Color(0.90, 0.86, 0.76), 14, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_zone_subtitle)
	_zone_banner.modulate.a = 0.0


func _build_bottom_hud() -> void:
	## Mockup-faithful bottom composition: status · action · menu islands + XP strip.
	var root := MarginContainer.new()
	root.name = "BottomHUD"
	root.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.anchor_left = 0.0
	root.anchor_right = 1.0
	root.anchor_top = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 14.0
	root.offset_right = -14.0
	root.offset_top = -178.0
	root.offset_bottom = -8.0
	root.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_theme_constant_override("margin_left", 0)
	root.add_theme_constant_override("margin_right", 0)
	root.add_theme_constant_override("margin_top", 0)
	root.add_theme_constant_override("margin_bottom", 0)
	add_child(root)

	var shell := PanelContainer.new()
	shell.name = "HudShell"
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_theme_stylebox_override("panel", UI.master_hud_style())
	root.add_child(shell)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	shell.add_child(column)

	var row := HBoxContainer.new()
	row.name = "HudRow"
	row.add_theme_constant_override("separation", 12)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(row)

	var status := _build_status_island()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.size_flags_stretch_ratio = 1.22
	row.add_child(status)

	var action := _build_action_island()
	action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action.size_flags_stretch_ratio = 1.58
	row.add_child(action)

	var menu := _build_menu_island()
	menu.custom_minimum_size = Vector2(248.0, 112.0)
	menu.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(menu)

	_build_xp_strip(column)


func _build_xp_strip(parent: Control) -> void:
	var strip := Control.new()
	strip.name = "XPStrip"
	strip.custom_minimum_size = Vector2(0.0, 16.0)
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(strip)

	_xp_bar = ProgressBar.new()
	_xp_bar.name = "XPBar"
	_xp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_xp_bar.show_percentage = false
	_xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var xp_bg := UI.textured_style("xp_bar_9.png", 8.0, 1.0)
	if xp_bg == null:
		xp_bg = UI.bar_background()
	_xp_bar.add_theme_stylebox_override("background", xp_bg)
	var xp_fill := UI.bar_fill(UI.COLOR_XP)
	xp_fill.content_margin_top = 0.0
	xp_fill.content_margin_bottom = 0.0
	_xp_bar.add_theme_stylebox_override("fill", xp_fill)
	strip.add_child(_xp_bar)

	_xp_label = UI.style_label(Label.new(), Color(0.93, 0.90, 0.82), 11, HORIZONTAL_ALIGNMENT_LEFT)
	_xp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_xp_label.offset_left = 10.0
	_xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_xp_label.text = "LEVEL 1  ·  XP 0 / 100"
	strip.add_child(_xp_label)


func _build_status_island() -> Control:
	var island := PanelContainer.new()
	island.name = "StatusIsland"
	island.mouse_filter = Control.MOUSE_FILTER_STOP
	island.add_theme_stylebox_override("panel", UI.status_island_style())
	island.custom_minimum_size = Vector2(340.0, 108.0)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	island.add_child(body)

	var crest_wrap := Control.new()
	crest_wrap.custom_minimum_size = Vector2(84.0, 90.0)
	crest_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(crest_wrap)

	var crest_ring := UI.runtime_texture("crest_ring.png")
	if crest_ring != null:
		var ring := TextureRect.new()
		ring.texture = crest_ring
		ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ring.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ring.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		crest_wrap.add_child(ring)
	else:
		var crest_icon := Icons.make_rect(Icons.CREST, Vector2(52, 52))
		crest_icon.set_anchors_preset(Control.PRESET_CENTER)
		crest_icon.anchor_left = 0.5
		crest_icon.anchor_top = 0.5
		crest_icon.anchor_right = 0.5
		crest_icon.anchor_bottom = 0.5
		crest_icon.offset_left = -26.0
		crest_icon.offset_top = -26.0
		crest_icon.offset_right = 26.0
		crest_icon.offset_bottom = 26.0
		crest_wrap.add_child(crest_icon)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_theme_constant_override("separation", 5)
	body.add_child(box)

	_level_label = UI.style_heading(Label.new(), UI.COLOR_GOLD, 14)
	_level_label.text = "ADVENTURER  ·  LEVEL 1"
	box.add_child(_level_label)

	var hp_stack := Control.new()
	hp_stack.custom_minimum_size = Vector2(240.0, 26.0)
	box.add_child(hp_stack)
	_hp_bar = ProgressBar.new()
	_hp_bar.name = "HPBar"
	_hp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hp_bar.show_percentage = false
	var hp_bg := UI.textured_style("bar_empty_9.png", 6.0, 1.0)
	if hp_bg == null:
		hp_bg = UI.bar_background()
	_hp_bar.add_theme_stylebox_override("background", hp_bg)
	var hp_fill := UI.textured_style("bar_hp_9.png", 4.0, 0.0)
	if hp_fill == null:
		hp_fill = UI.bar_fill(UI.COLOR_HEALTH)
	else:
		(hp_fill as StyleBoxTexture).modulate_color = Color(1.0, 0.48, 0.40, 1.0)
	_hp_bar.add_theme_stylebox_override("fill", hp_fill)
	hp_stack.add_child(_hp_bar)
	_hp_label = UI.style_label(Label.new(), Color(1.0, 0.97, 0.90), 13, HORIZONTAL_ALIGNMENT_CENTER)
	_hp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hp_label.text = "HP 100 / 100"
	_hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_stack.add_child(_hp_label)

	var steadfast_stack := Control.new()
	steadfast_stack.custom_minimum_size = Vector2(240.0, 20.0)
	box.add_child(steadfast_stack)
	_steadfast_bar = ProgressBar.new()
	_steadfast_bar.name = "SteadfastBar"
	_steadfast_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_steadfast_bar.max_value = 100.0
	_steadfast_bar.value = 100.0
	_steadfast_bar.show_percentage = false
	var steadfast_bg := UI.textured_style("bar_empty_9.png", 5.0, 1.0)
	if steadfast_bg == null:
		steadfast_bg = UI.bar_background()
	_steadfast_bar.add_theme_stylebox_override("background", steadfast_bg)
	var steadfast_fill := UI.textured_style("bar_steadfast_9.png", 4.0, 0.0)
	if steadfast_fill == null:
		steadfast_fill = UI.bar_fill(UI.COLOR_STEADFAST)
	_steadfast_bar.add_theme_stylebox_override("fill", steadfast_fill)
	steadfast_stack.add_child(_steadfast_bar)

	var steadfast_row := HBoxContainer.new()
	steadfast_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	steadfast_row.offset_left = 8.0
	steadfast_row.offset_right = -8.0
	steadfast_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_stack.add_child(steadfast_row)
	var steadfast_name := UI.style_label(Label.new(), Color(0.86, 0.90, 1.0), 11)
	steadfast_name.text = "STEADFAST"
	steadfast_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	steadfast_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_row.add_child(steadfast_name)
	_resource_label = UI.style_label(Label.new(), Color(0.92, 0.95, 1.0), 11, HORIZONTAL_ALIGNMENT_RIGHT)
	_resource_label.text = "100 / 100"
	_resource_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_row.add_child(_resource_label)
	return island


func _build_action_island() -> Control:
	## Mockup framing/proportions — content reflects real assignments only.
	## Unassigned slots stay blank; no showcase filler icons.
	var island := PanelContainer.new()
	island.name = "ActionIsland"
	island.mouse_filter = Control.MOUSE_FILTER_STOP
	island.add_theme_stylebox_override("panel", UI.action_island_style())
	island.custom_minimum_size = Vector2(520.0, 108.0)

	var center := HBoxContainer.new()
	center.name = "ActionBar"
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 7)
	island.add_child(center)

	_action_bar_slots.clear()
	_hotbar_slots.clear()

	# Genuinely implemented core actions.
	center.add_child(_make_action_slot(
		&"attack",
		"Basic Attack",
		"E",
		Color(0.82, 0.60, 0.24),
		Icons.texture(Icons.ATTACK)
	))
	center.add_child(_make_action_slot(
		&"dash",
		"Combat Dash",
		"SPACE",
		Color(0.28, 0.58, 0.50),
		Icons.texture(Icons.DASH)
	))

	# Hotbar 1–5: empty shells with keybinds; icons assigned dynamically later.
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

	# Extra reserved tray slot — blank, no invented content.
	center.add_child(_make_action_slot(
		&"reserved",
		"Reserved Slot",
		"",
		Color(0.35, 0.30, 0.22),
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
	slot.custom_minimum_size = Vector2(64.0, 78.0)
	slot.tooltip_text = action_name
	slot.add_theme_stylebox_override(
		"panel",
		UI.action_slot_style(accent if assigned else Color(0.22, 0.18, 0.14), assigned)
	)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 3)
	slot.add_child(box)

	var icon_stack := Control.new()
	icon_stack.name = "IconStack"
	icon_stack.custom_minimum_size = Vector2(48, 44)
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

	var lock_rect := TextureRect.new()
	lock_rect.name = "LockOverlay"
	lock_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lock_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lock_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	lock_rect.modulate = Color(1.0, 1.0, 1.0, 0.82)
	lock_rect.set_anchors_preset(Control.PRESET_CENTER)
	lock_rect.anchor_left = 0.5
	lock_rect.anchor_top = 0.5
	lock_rect.anchor_right = 0.5
	lock_rect.anchor_bottom = 0.5
	lock_rect.offset_left = -11.0
	lock_rect.offset_top = -11.0
	lock_rect.offset_right = 11.0
	lock_rect.offset_bottom = 11.0
	lock_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_rect.texture = UI.runtime_texture("icon_lock.png")
	lock_rect.visible = false
	icon_stack.add_child(lock_rect)

	var cooldown := UI.style_label(Label.new(), Color.WHITE, 11, HORIZONTAL_ALIGNMENT_CENTER)
	cooldown.name = "CooldownLabel"
	cooldown.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cooldown.text = ""
	cooldown.visible = false
	cooldown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_stack.add_child(cooldown)

	var key := UI.style_keybind(Label.new(), true, 11)
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
	var lock_overlay := slot.get_meta("lock_overlay") as TextureRect
	var accent: Color = slot.get_meta("accent", UI.COLOR_BRASS)
	var has_icon := icon_texture != null and not locked

	if icon != null:
		icon.texture = icon_texture if has_icon else null
		icon.visible = has_icon
	if lock_overlay != null:
		## Locked state shows ONLY the lock — never filler artwork underneath.
		lock_overlay.visible = locked
	slot.tooltip_text = tooltip
	slot.set_meta("assigned", has_icon)
	slot.set_meta("locked", locked)
	slot.modulate = Color(0.62, 0.62, 0.62, 0.94) if locked else Color.WHITE
	slot.add_theme_stylebox_override(
		"panel",
		UI.action_slot_style(accent if has_icon else Color(0.22, 0.18, 0.14), has_icon)
	)


func clear_action_slot(slot: PanelContainer, tooltip: String = "Unassigned") -> void:
	assign_action_slot(slot, null, tooltip, false)


func _build_menu_island() -> Control:
	var island := PanelContainer.new()
	island.name = "MenuIsland"
	island.mouse_filter = Control.MOUSE_FILTER_STOP
	island.add_theme_stylebox_override("panel", UI.menu_island_style())

	var grid := GridContainer.new()
	grid.name = "MenuGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	island.add_child(grid)

	grid.add_child(_make_menu_button("CHARACTER", "C", &"character", "icon_helm.png"))
	grid.add_child(_make_menu_button("INVENTORY", "I", &"inventory", "icon_bag.png"))
	grid.add_child(_make_menu_button("TECHNIQUES", "K", &"techniques", "icon_slash.png"))
	grid.add_child(_make_menu_button("QUEST LOG", "J", &"quests", "icon_scroll.png"))
	return island


func _make_menu_button(text: String, key: String, panel_id: StringName, kit_icon: String) -> Button:
	var button := UI.style_button(Button.new())
	button.custom_minimum_size = Vector2(112.0, 46.0)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_constant_override("icon_max_width", 22)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var tex := UI.runtime_texture(kit_icon)
	if tex != null:
		button.icon = tex
		button.expand_icon = true
	button.text = "%s [%s]" % [text, key]
	button.pressed.connect(_open_panel.bind(panel_id))
	return button


func _build_status_message() -> void:
	_status_label = UI.style_label(Label.new(), Color.WHITE, 15, HORIZONTAL_ALIGNMENT_CENTER)
	_status_label.name = "StatusMessage"
	_status_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_status_label.position = Vector2(-300.0, -196.0)
	_status_label.size = Vector2(600.0, 26.0)
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
				rtl.append_text("[color=#f5d678]%s[/color]\n" % line)
			else:
				rtl.append_text("[color=#b8ae9c]%s[/color]\n" % line)
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
