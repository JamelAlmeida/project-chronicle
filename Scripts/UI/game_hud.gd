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
	panel.position = Vector2(18.0, 14.0)
	panel.custom_minimum_size = Vector2(248.0, 78.0)
	panel.size = Vector2(248.0, 78.0)
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	panel.add_theme_stylebox_override("panel", UI.hud_panel_style())
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var heading := UI.style_eyebrow(Label.new(), UI.COLOR_GOLD, 13, HORIZONTAL_ALIGNMENT_CENTER)
	heading.text = "EXPEDITION"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(heading)
	_expedition_label = UI.style_label(Label.new(), UI.COLOR_TEXT, 14)
	_expedition_label.text = "Unsecured loot: 0"
	_expedition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(_expedition_label)
	var inventory_hint := UI.style_label(Label.new(), UI.COLOR_MUTED, 12)
	inventory_hint.name = "InventoryHint"
	inventory_hint.text = "Inventory [I]"
	box.add_child(inventory_hint)


func _build_quest_tracker() -> void:
	var panel := PanelContainer.new()
	panel.name = "QuestTracker"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -312.0
	panel.offset_top = 14.0
	panel.offset_right = -18.0
	panel.offset_bottom = 148.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	panel.add_theme_stylebox_override("panel", UI.hud_panel_style())
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var heading := UI.style_heading(Label.new(), UI.COLOR_GOLD, 13, HORIZONTAL_ALIGNMENT_CENTER)
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
	tracker.add_theme_font_size_override("normal_font_size", 13)
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
	## One cohesive premium HUD composition matching the approved mockup.
	var root := PanelContainer.new()
	root.name = "BottomHUD"
	root.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_theme_stylebox_override("panel", UI.master_hud_style())
	root.anchor_left = 0.0
	root.anchor_right = 1.0
	root.anchor_top = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 16.0
	root.offset_right = -16.0
	root.offset_top = -168.0
	root.offset_bottom = -10.0
	root.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(root)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	root.add_child(column)

	var row := HBoxContainer.new()
	row.name = "HudRow"
	row.add_theme_constant_override("separation", 18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(row)

	var status := _build_status_island()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.size_flags_stretch_ratio = 1.15
	row.add_child(status)

	var action := _build_action_island()
	action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action.size_flags_stretch_ratio = 1.55
	row.add_child(action)

	var menu := _build_menu_island()
	menu.custom_minimum_size = Vector2(236.0, 108.0)
	menu.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(menu)

	_build_xp_strip(column)


func _build_xp_strip(parent: Control) -> void:
	var strip := Control.new()
	strip.name = "XPStrip"
	strip.custom_minimum_size = Vector2(0.0, 18.0)
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(strip)

	_xp_bar = ProgressBar.new()
	_xp_bar.name = "XPBar"
	_xp_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_xp_bar.show_percentage = false
	_xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var xp_bg := UI.textured_style("xp_bar_9.png", 6.0, 1.0)
	if xp_bg == null:
		xp_bg = UI.bar_background()
	_xp_bar.add_theme_stylebox_override("background", xp_bg)
	_xp_bar.add_theme_stylebox_override("fill", UI.bar_fill(UI.COLOR_XP))
	strip.add_child(_xp_bar)

	_xp_label = UI.style_label(Label.new(), Color(0.92, 0.90, 0.82), 12, HORIZONTAL_ALIGNMENT_LEFT)
	_xp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_xp_label.offset_left = 8.0
	_xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_xp_label.text = "LEVEL 1  ·  XP 0 / 100"
	strip.add_child(_xp_label)


func _build_status_island() -> Control:
	var island := HBoxContainer.new()
	island.name = "StatusIsland"
	island.add_theme_constant_override("separation", 10)
	island.mouse_filter = Control.MOUSE_FILTER_STOP

	var crest_wrap := Control.new()
	crest_wrap.custom_minimum_size = Vector2(72.0, 72.0)
	crest_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	island.add_child(crest_wrap)

	var crest_ring := UI.runtime_texture("crest_ring.png")
	if crest_ring != null:
		var ring := TextureRect.new()
		ring.texture = crest_ring
		ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ring.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ring.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		crest_wrap.add_child(ring)
	var crest_icon := Icons.make_rect(Icons.CREST, Vector2(44, 44))
	crest_icon.set_anchors_preset(Control.PRESET_CENTER)
	crest_icon.anchor_left = 0.5
	crest_icon.anchor_top = 0.5
	crest_icon.anchor_right = 0.5
	crest_icon.anchor_bottom = 0.5
	crest_icon.offset_left = -22.0
	crest_icon.offset_top = -22.0
	crest_icon.offset_right = 22.0
	crest_icon.offset_bottom = 22.0
	crest_wrap.add_child(crest_icon)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	island.add_child(box)

	_level_label = UI.style_heading(Label.new(), UI.COLOR_GOLD, 15)
	_level_label.text = "ADVENTURER  ·  LEVEL 1"
	box.add_child(_level_label)

	var hp_stack := Control.new()
	hp_stack.custom_minimum_size = Vector2(260.0, 24.0)
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
		(hp_fill as StyleBoxTexture).modulate_color = Color(1.0, 0.55, 0.45, 1.0)
	_hp_bar.add_theme_stylebox_override("fill", hp_fill)
	hp_stack.add_child(_hp_bar)
	_hp_label = UI.style_label(Label.new(), Color(1.0, 0.96, 0.90), 13, HORIZONTAL_ALIGNMENT_CENTER)
	_hp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hp_label.text = "HP 100 / 100"
	_hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_stack.add_child(_hp_label)

	var steadfast_stack := Control.new()
	steadfast_stack.custom_minimum_size = Vector2(260.0, 18.0)
	box.add_child(steadfast_stack)
	_steadfast_bar = ProgressBar.new()
	_steadfast_bar.name = "SteadfastBar"
	_steadfast_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_steadfast_bar.max_value = 100.0
	_steadfast_bar.value = 100.0
	_steadfast_bar.show_percentage = false
	_steadfast_bar.add_theme_stylebox_override("background", UI.bar_background())
	var steadfast_fill := UI.textured_style("bar_steadfast_9.png", 4.0, 0.0)
	if steadfast_fill == null:
		steadfast_fill = UI.bar_fill(UI.COLOR_STEADFAST)
	_steadfast_bar.add_theme_stylebox_override("fill", steadfast_fill)
	steadfast_stack.add_child(_steadfast_bar)
	_resource_label = UI.style_label(Label.new(), Color(0.90, 0.94, 1.0), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_resource_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_resource_label.text = "STEADFAST  100 / 100"
	_resource_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steadfast_stack.add_child(_resource_label)
	return island


func _build_action_island() -> Control:
	var island := CenterContainer.new()
	island.name = "ActionIsland"
	island.mouse_filter = Control.MOUSE_FILTER_STOP

	var center := HBoxContainer.new()
	center.name = "ActionBar"
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 6)
	island.add_child(center)

	center.add_child(_make_action_slot(Icons.ATTACK, "Basic Attack", "E", Color(0.82, 0.60, 0.24), true))
	center.add_child(_make_action_slot(Icons.DASH, "Combat Dash", "SPACE", Color(0.28, 0.58, 0.50), true))
	_technique_slot = _make_action_slot(Icons.TECHNIQUE, "No active Technique", "1", UI.COLOR_TECHNIQUE, true)
	_technique_cooldown_label = _technique_slot.get_meta("cooldown_label") as Label
	center.add_child(_technique_slot)
	center.add_child(_make_action_slot(Icons.ARC_SLASH, "Future Technique", "2", Color(0.74, 0.58, 0.24), false))
	center.add_child(_make_action_slot(Icons.PULSE_WAVE, "Future Technique", "3", Color(0.28, 0.52, 0.78), false))
	center.add_child(_make_action_slot(Icons.VERDANT_BLOOM, "Future Technique", "4", Color(0.32, 0.62, 0.38), false))
	center.add_child(_make_action_slot(Icons.POTION, "Potion", "5", Color(0.72, 0.28, 0.28), false))
	center.add_child(_make_action_slot("", "Reserved Slot", "", Color(0.35, 0.30, 0.22), false))
	return island


func _make_action_slot(
	icon_id: String,
	action_name: String,
	key_text: String,
	accent: Color,
	unlocked: bool
) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(58.0, 72.0)
	slot.tooltip_text = action_name
	slot.add_theme_stylebox_override(
		"panel",
		UI.action_slot_style(accent if unlocked else Color(0.22, 0.18, 0.14), false)
	)
	if not unlocked:
		slot.modulate = Color(0.58, 0.58, 0.58, 0.92)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	slot.add_child(box)

	var icon_stack := Control.new()
	icon_stack.custom_minimum_size = Vector2(44, 40)
	box.add_child(icon_stack)

	var kit_icon := _kit_action_icon(icon_id) if not icon_id.is_empty() else null
	var icon: Control
	if kit_icon != null:
		var tex := TextureRect.new()
		tex.texture = kit_icon
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if not unlocked:
			tex.modulate = Color(0.70, 0.70, 0.70, 0.85)
		icon = tex
	elif not icon_id.is_empty():
		icon = Icons.make_rect(icon_id, Vector2(40, 38))
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		icon = Control.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_stack.add_child(icon)

	if not unlocked and not icon_id.is_empty():
		var lock_tex := UI.runtime_texture("icon_lock.png")
		if lock_tex != null:
			var lock_rect := TextureRect.new()
			lock_rect.texture = lock_tex
			lock_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			lock_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			lock_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			lock_rect.modulate = Color(1.0, 1.0, 1.0, 0.78)
			lock_rect.set_anchors_preset(Control.PRESET_CENTER)
			lock_rect.anchor_left = 0.5
			lock_rect.anchor_top = 0.5
			lock_rect.anchor_right = 0.5
			lock_rect.anchor_bottom = 0.5
			lock_rect.offset_left = -10.0
			lock_rect.offset_top = -10.0
			lock_rect.offset_right = 10.0
			lock_rect.offset_bottom = 10.0
			lock_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon_stack.add_child(lock_rect)

	var cooldown := UI.style_label(Label.new(), Color.WHITE, 11, HORIZONTAL_ALIGNMENT_CENTER)
	cooldown.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cooldown.text = ""
	cooldown.visible = false
	cooldown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_stack.add_child(cooldown)

	var key := UI.style_keybind(Label.new(), unlocked or key_text.is_empty(), 11)
	key.text = key_text
	box.add_child(key)

	slot.set_meta("icon_rect", icon)
	slot.set_meta("cooldown_label", cooldown)
	slot.set_meta("accent", accent)
	slot.set_meta("unlocked", unlocked)
	return slot


func _kit_action_icon(icon_id: String) -> Texture2D:
	match icon_id:
		Icons.ATTACK:
			return UI.runtime_texture("icon_sword.png")
		Icons.DASH:
			return UI.runtime_texture("icon_shadow.png")
		Icons.TECHNIQUE:
			var mage := UI.runtime_texture("icon_mage.png")
			return mage if mage != null else UI.runtime_texture("icon_shadow.png")
		Icons.ARC_SLASH:
			var slash := UI.runtime_texture("icon_slash.png")
			return slash if slash != null else UI.runtime_texture("icon_fire.png")
		Icons.PULSE_WAVE:
			var ice := UI.runtime_texture("icon_ice.png")
			return ice if ice != null else UI.runtime_texture("icon_nature.png")
		Icons.VERDANT_BLOOM:
			return UI.runtime_texture("icon_nature.png")
		Icons.POTION:
			return UI.runtime_texture("icon_potion.png")
		_:
			return null


func _build_menu_island() -> Control:
	var island := GridContainer.new()
	island.name = "MenuIsland"
	island.columns = 2
	island.add_theme_constant_override("h_separation", 8)
	island.add_theme_constant_override("v_separation", 8)
	island.mouse_filter = Control.MOUSE_FILTER_STOP

	island.add_child(_make_menu_button("CHARACTER", "C", &"character", "icon_helm.png"))
	island.add_child(_make_menu_button("INVENTORY", "I", &"inventory", "icon_bag.png"))
	island.add_child(_make_menu_button("TECHNIQUES", "K", &"techniques", "icon_scroll.png"))
	island.add_child(_make_menu_button("QUEST LOG", "J", &"quests", "icon_nature.png"))
	return island


func _make_menu_button(text: String, key: String, panel_id: StringName, kit_icon: String) -> Button:
	var button := UI.style_button(Button.new())
	button.custom_minimum_size = Vector2(110.0, 44.0)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_constant_override("icon_max_width", 20)
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
	if _technique_slot == null or _technique_cooldown_label == null:
		return
	var accent: Color = _technique_slot.get_meta("accent", UI.COLOR_TECHNIQUE)
	var technique_id: String = _technique_manager().get_equipped_active(0)
	if technique_id.is_empty():
		_technique_slot.tooltip_text = "No active Technique"
		_technique_cooldown_label.visible = true
		_technique_cooldown_label.text = "LOCKED"
		_technique_slot.modulate = Color(0.62, 0.62, 0.62)
		_technique_slot.add_theme_stylebox_override(
			"panel",
			UI.action_slot_style(Color(0.22, 0.18, 0.14), false)
		)
		return
	var technique: TechniqueData = _technique_manager().get_technique(technique_id)
	if technique == null:
		return
	_technique_slot.tooltip_text = technique.display_name
	var remaining: float = _technique_manager().get_cooldown_remaining(technique_id)
	_technique_cooldown_label.visible = remaining > 0.0
	_technique_cooldown_label.text = "%.1f" % remaining if remaining > 0.0 else ""
	var ready := remaining <= 0.0
	_technique_slot.modulate = Color(0.58, 0.58, 0.58) if not ready else Color.WHITE
	_technique_slot.add_theme_stylebox_override(
		"panel",
		UI.action_slot_style(accent, ready)
	)


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
