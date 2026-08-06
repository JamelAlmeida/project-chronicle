extends CanvasLayer

const UI := preload("res://Project Chronicle/Scripts/UI/chronicle_ui_theme.gd")
## Character preview uses the approved Adventurer kit — not archived PixelArt player sheets.
const PLAYER_PREVIEW_TEXTURE := preload("res://Project Chronicle/Assets/Characters/Adventurer/Runtime/runtime_idle.png")
const PLAYER_PREVIEW_REGION := Rect2(0.0, 0.0, 96.0, 112.0)
const PANEL_TITLES := {
	&"character": "CHARACTER",
	&"inventory": "INVENTORY",
	&"techniques": "TECHNIQUE BOOK",
	&"quests": "QUEST LOG",
}
const CORE_STAT_NAMES := {
	&"strength": "Strength",
	&"dexterity": "Dexterity",
	&"vitality": "Vitality",
	&"intellect": "Intellect",
}
const EQUIP_SLOT_LABELS := {
	"weapon": "Weapon",
	"offhand": "Offhand",
	"head": "Head",
	"chest": "Chest",
	"hands": "Hands",
	"feet": "Feet",
	"ring1": "Ring 1",
	"ring2": "Ring 2",
	"amulet": "Amulet",
}

var _overlay: Control
var _window: PanelContainer
var _title_label: Label
var _content: VBoxContainer
var _current_panel: StringName = &""
var _player: Node
var _equipment: EquipmentComponent
var _stats: StatsComponent
var _refresh_pending := false


func _ready() -> void:
	add_to_group("chronicle_menu")
	_build_interface()
	await get_tree().process_frame
	_connect_to_player()
	_connect_to_systems()


func _input(event: InputEvent) -> void:
	var requested_panel: StringName = &""
	if event.is_action_pressed("toggle_character"):
		requested_panel = &"character"
	elif event.is_action_pressed("toggle_inventory"):
		requested_panel = &"inventory"
	elif event.is_action_pressed("toggle_techniques"):
		requested_panel = &"techniques"
	elif event.is_action_pressed("toggle_quest_log"):
		requested_panel = &"quests"
	elif event.is_action_pressed("ui_cancel") and _overlay.visible:
		close_panel()
		get_viewport().set_input_as_handled()
		return
	if requested_panel.is_empty():
		return
	open_panel(requested_panel)
	get_viewport().set_input_as_handled()


func open_panel(panel_id: StringName) -> void:
	if not PANEL_TITLES.has(panel_id):
		return
	if _overlay.visible and _current_panel == panel_id:
		close_panel()
		return
	_current_panel = panel_id
	_title_label.text = str(PANEL_TITLES[panel_id])
	_overlay.visible = true
	_rebuild_content()


func close_panel() -> void:
	_overlay.visible = false
	_current_panel = &""
	get_viewport().gui_release_focus()


func is_panel_open(panel_id: StringName = &"") -> bool:
	return _overlay.visible and (panel_id.is_empty() or _current_panel == panel_id)


func _build_interface() -> void:
	_overlay = Control.new()
	_overlay.name = "MenuOverlay"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.012, 0.014, 0.42)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(shade)

	_window = PanelContainer.new()
	_window.name = "RootWindow"
	_window.set_anchors_preset(Control.PRESET_CENTER)
	_window.position = Vector2(-520.0, -300.0)
	_window.size = Vector2(1040.0, 600.0)
	_window.mouse_filter = Control.MOUSE_FILTER_STOP
	_window.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# One outer frame only — no stacked decorative chrome.
	_window.add_theme_stylebox_override("panel", UI.panel_style(UI.COLOR_PANEL))
	_overlay.add_child(_window)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 8)
	_window.add_child(root_box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	root_box.add_child(header)
	_title_label = UI.style_heading(Label.new(), UI.COLOR_GOLD, 26)
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)
	var close_button := UI.style_button(Button.new())
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(92.0, 32.0)
	close_button.add_theme_font_size_override("font_size", 14)
	close_button.pressed.connect(close_panel)
	header.add_child(close_button)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	root_box.add_child(tabs)
	tabs.add_child(_make_tab_button("Character [C]", &"character"))
	tabs.add_child(_make_tab_button("Inventory [I]", &"inventory"))
	tabs.add_child(_make_tab_button("Techniques [K]", &"techniques"))
	tabs.add_child(_make_tab_button("Quest Log [J]", &"quests"))

	root_box.add_child(UI.make_separator())
	var scroll := ScrollContainer.new()
	scroll.name = "ContentScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_box.add_child(scroll)
	_content = VBoxContainer.new()
	_content.name = "Content"
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 12)
	scroll.add_child(_content)
	_overlay.visible = false


func _make_tab_button(text: String, panel_id: StringName) -> Button:
	var button := UI.style_button(Button.new())
	button.text = text
	button.custom_minimum_size = Vector2(172.0, 34.0)
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(open_panel.bind(panel_id))
	return button


func _connect_to_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		return
	_equipment = _player.get_node("EquipmentComponent") as EquipmentComponent
	_stats = _player.get_node("StatsComponent") as StatsComponent
	if _equipment != null:
		_equipment.equipment_changed.connect(func(_slot: String, _item: String): _refresh_if_open())
	if _stats != null:
		_stats.stats_changed.connect(_refresh_if_open)


func _connect_to_systems() -> void:
	var inventory: Node = _inventory()
	inventory.item_added.connect(func(_id: String, _added: int, _total: int): _refresh_if_open())
	inventory.expedition_loot_changed.connect(_refresh_if_open)
	inventory.secured_loot_changed.connect(_refresh_if_open)
	var progression: Node = _progression()
	progression.xp_gained.connect(func(_a: int, _b: int, _c: int): _refresh_if_open())
	progression.level_up.connect(func(_a: int, _b: int): _refresh_if_open())
	progression.stat_points_changed.connect(func(_a: int): _refresh_if_open())
	var techniques: Node = _techniques()
	techniques.techniques_changed.connect(_refresh_if_open)
	var quests: Node = _quests()
	quests.quest_state_changed.connect(func(_a: String, _b: int): _refresh_if_open())
	quests.quest_objective_progressed.connect(
		func(_a: String, _b: int, _c: int, _d: int): _refresh_if_open()
	)


func _refresh_if_open() -> void:
	if not _overlay.visible or _refresh_pending:
		return
	_refresh_pending = true
	call_deferred("_deferred_rebuild")


func _deferred_rebuild() -> void:
	_refresh_pending = false
	if _overlay.visible:
		_rebuild_content()


func _rebuild_content() -> void:
	for child: Node in _content.get_children():
		child.free()
	match _current_panel:
		&"character":
			_build_character_content()
		&"inventory":
			_build_inventory_content()
		&"techniques":
			_build_technique_content()
		&"quests":
			_build_quest_content()


func _build_character_content() -> void:
	if _equipment == null or _stats == null:
		_content.add_child(_message_label("Character data is not available."))
		return
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 14)
	_content.add_child(columns)
	columns.add_child(_build_character_preview_column())
	columns.add_child(_build_stats_column())


func _build_character_preview_column() -> Control:
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 420.0
	column.add_theme_constant_override("separation", 10)

	var progression: Node = _progression()
	var identity := UI.style_heading(Label.new(), UI.COLOR_GOLD, 20, HORIZONTAL_ALIGNMENT_CENTER)
	identity.text = "THE ADVENTURER"
	column.add_child(identity)
	var level := UI.style_label(Label.new(), UI.COLOR_TEXT, 14, HORIZONTAL_ALIGNMENT_CENTER)
	level.text = "Level %d  ·  %d / %d XP" % [
		progression.current_level,
		progression.current_xp,
		progression.get_xp_needed_for_next_level(),
	]
	column.add_child(level)

	# Preview + equipment: one layout, slots around the portrait — no nested frames.
	var gear_stage := HBoxContainer.new()
	gear_stage.alignment = BoxContainer.ALIGNMENT_CENTER
	gear_stage.add_theme_constant_override("separation", 8)
	column.add_child(gear_stage)

	var left_slots := VBoxContainer.new()
	left_slots.add_theme_constant_override("separation", 6)
	gear_stage.add_child(left_slots)
	left_slots.add_child(_make_equip_slot_tile("head"))
	left_slots.add_child(_make_equip_slot_tile("chest"))
	left_slots.add_child(_make_equip_slot_tile("hands"))
	left_slots.add_child(_make_equip_slot_tile("feet"))

	var center := VBoxContainer.new()
	center.add_theme_constant_override("separation", 6)
	gear_stage.add_child(center)

	var preview_ring := PanelContainer.new()
	preview_ring.custom_minimum_size = Vector2(168.0, 200.0)
	var ring_style := UI.inset_style(Color(0.30, 0.25, 0.16))
	var portrait := UI.runtime_texture("portrait_ring.png")
	if portrait != null:
		var style := StyleBoxTexture.new()
		style.texture = portrait
		style.texture_margin_left = 22.0
		style.texture_margin_top = 22.0
		style.texture_margin_right = 22.0
		style.texture_margin_bottom = 22.0
		style.content_margin_left = 12.0
		style.content_margin_top = 12.0
		style.content_margin_right = 12.0
		style.content_margin_bottom = 12.0
		ring_style = style
	preview_ring.add_theme_stylebox_override("panel", ring_style)
	center.add_child(preview_ring)

	var preview := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = PLAYER_PREVIEW_TEXTURE
	atlas.region = PLAYER_PREVIEW_REGION
	preview.texture = atlas
	preview.custom_minimum_size = Vector2(120.0, 168.0)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview_ring.add_child(preview)

	var weapon_row := HBoxContainer.new()
	weapon_row.alignment = BoxContainer.ALIGNMENT_CENTER
	weapon_row.add_theme_constant_override("separation", 8)
	center.add_child(weapon_row)
	weapon_row.add_child(_make_equip_slot_tile("weapon"))
	weapon_row.add_child(_make_equip_slot_tile("offhand"))

	var right_slots := VBoxContainer.new()
	right_slots.add_theme_constant_override("separation", 6)
	gear_stage.add_child(right_slots)
	right_slots.add_child(_make_equip_slot_tile("amulet"))
	right_slots.add_child(_make_equip_slot_tile("ring1"))
	right_slots.add_child(_make_equip_slot_tile("ring2"))

	return column


func _make_equip_slot_tile(slot_key: String) -> Control:
	var tile := PanelContainer.new()
	tile.custom_minimum_size = Vector2(92.0, 78.0)
	tile.add_theme_stylebox_override("panel", UI.equipment_slot_style())
	tile.tooltip_text = str(EQUIP_SLOT_LABELS.get(slot_key, slot_key.capitalize()))

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 1)
	tile.add_child(box)

	var slot_label := UI.style_eyebrow(Label.new(), UI.COLOR_BRASS_LIGHT, 11, HORIZONTAL_ALIGNMENT_CENTER)
	slot_label.text = str(EQUIP_SLOT_LABELS.get(slot_key, slot_key.capitalize()))
	box.add_child(slot_label)

	var item_id := _equipment.get_equipped_id(slot_key)
	var item: ItemData = _item_registry().get_item(item_id)
	var value := UI.style_label(Label.new(), UI.COLOR_TEXT if item != null else UI.COLOR_MUTED, 12, HORIZONTAL_ALIGNMENT_CENTER)
	value.text = item.display_name if item != null else "—"
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.custom_minimum_size.x = 70.0
	if item is EquipmentData:
		value.tooltip_text = _equipment_tooltip(item as EquipmentData)
	box.add_child(value)

	var remove := UI.style_button(Button.new())
	remove.text = "Unequip"
	remove.custom_minimum_size = Vector2(74.0, 24.0)
	remove.add_theme_font_size_override("font_size", 11)
	remove.disabled = item_id.is_empty()
	remove.pressed.connect(_on_unequip_pressed.bind(slot_key))
	box.add_child(remove)
	return tile


func _build_stats_column() -> Control:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)

	var attrs := PanelContainer.new()
	attrs.add_theme_stylebox_override("panel", UI.section_style())
	column.add_child(attrs)
	var attrs_box := VBoxContainer.new()
	attrs_box.add_theme_constant_override("separation", 8)
	attrs.add_child(attrs_box)

	var points := UI.style_heading(Label.new(), UI.COLOR_GOLD, 17)
	points.text = "CORE ATTRIBUTES"
	attrs_box.add_child(points)
	var unspent := UI.style_label(Label.new(), UI.COLOR_BRASS_LIGHT, 14)
	unspent.text = "Unspent Points: %d" % _progression().unspent_stat_points
	attrs_box.add_child(unspent)

	var core_grid := GridContainer.new()
	core_grid.columns = 4
	core_grid.add_theme_constant_override("h_separation", 10)
	core_grid.add_theme_constant_override("v_separation", 8)
	attrs_box.add_child(core_grid)
	for stat_id: StringName in CharacterProgression.CORE_STATS:
		_add_core_stat_row(core_grid, stat_id)

	var combat := PanelContainer.new()
	combat.add_theme_stylebox_override("panel", UI.section_style())
	column.add_child(combat)
	var combat_box := VBoxContainer.new()
	combat_box.add_theme_constant_override("separation", 6)
	combat.add_child(combat_box)
	var derived_heading := UI.style_heading(Label.new(), UI.COLOR_GOLD, 16)
	derived_heading.text = "COMBAT STATISTICS"
	combat_box.add_child(derived_heading)
	var derived_grid := GridContainer.new()
	derived_grid.columns = 2
	derived_grid.add_theme_constant_override("h_separation", 18)
	derived_grid.add_theme_constant_override("v_separation", 4)
	combat_box.add_child(derived_grid)
	_add_derived_stat(derived_grid, "Max Health", _stats.get_max_health(), "max_health")
	_add_derived_stat(derived_grid, "Attack Damage", _stats.get_attack_damage(), "attack_damage")
	_add_derived_stat(derived_grid, "Attack Speed", _stats.get_attack_speed(), "attack_speed", "%.2fx")
	_add_derived_stat(derived_grid, "Critical Chance", _stats.get_crit_chance() * 100.0, "crit_chance", "%.1f%%")
	_add_derived_stat(derived_grid, "Armor", _stats.get_armor(), "armor")
	_add_derived_stat(derived_grid, "Lifesteal", _stats.get_lifesteal() * 100.0, "lifesteal", "%.1f%%")
	_add_derived_stat(derived_grid, "Move Speed", _stats.get_move_speed(), "move_speed")
	return column


func _add_core_stat_row(grid: GridContainer, stat_id: StringName) -> void:
	var breakdown := _stats.get_stat_breakdown(String(stat_id))
	var base_value := float(breakdown.get("base", 0.0))
	var total := float(breakdown.get("total", 0.0))
	var bonus := total - base_value
	var name := UI.style_label(Label.new(), UI.COLOR_TEXT, 14)
	name.text = str(CORE_STAT_NAMES[stat_id])
	grid.add_child(name)
	var value := UI.style_label(Label.new(), UI.COLOR_GOLD, 15, HORIZONTAL_ALIGNMENT_RIGHT)
	value.text = "%d" % int(round(total))
	grid.add_child(value)
	var details := UI.style_label(Label.new(), UI.COLOR_MUTED, 12)
	details.text = "Base %d  Bonus %+d" % [int(round(base_value)), int(round(bonus))]
	details.tooltip_text = _breakdown_tooltip(breakdown)
	grid.add_child(details)
	var add_button := Button.new()
	UI.style_plus_button(add_button)
	add_button.disabled = _progression().unspent_stat_points <= 0
	add_button.tooltip_text = "Spend one point in %s" % str(CORE_STAT_NAMES[stat_id])
	add_button.pressed.connect(_on_allocate_stat.bind(stat_id))
	grid.add_child(add_button)


func _add_derived_stat(
	grid: GridContainer,
	display_name: String,
	value: float,
	stat_name: String,
	format: String = "%.0f"
) -> void:
	var name := UI.style_label(Label.new(), UI.COLOR_MUTED, 13)
	name.text = display_name
	grid.add_child(name)
	var value_label := UI.style_label(Label.new(), UI.COLOR_TEXT, 14, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.text = format % value
	value_label.tooltip_text = _breakdown_tooltip(_stats.get_stat_breakdown(stat_name))
	grid.add_child(value_label)


func _build_inventory_content() -> void:
	var heading := UI.style_label(Label.new(), UI.COLOR_MUTED, 12)
	heading.text = "Secured belongings and current expedition loot. Equipment can be equipped directly."
	_content.add_child(heading)
	var summaries: Array[Dictionary] = _inventory().get_inventory_summary()
	if summaries.is_empty():
		_content.add_child(_message_label("Your inventory is empty."))
		return
	for entry: Dictionary in summaries:
		var item_id := str(entry.get("item_id", ""))
		var item: ItemData = _item_registry().get_item(item_id)
		if item == null:
			continue
		var row_panel := PanelContainer.new()
		# One restrained section frame per row — no nested decorative frames.
		row_panel.add_theme_stylebox_override("panel", UI.section_style())
		_content.add_child(row_panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row_panel.add_child(row)
		if item.icon != null:
			var icon := TextureRect.new()
			icon.texture = item.icon
			icon.custom_minimum_size = Vector2(46.0, 46.0)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			row.add_child(icon)
		else:
			var icon_fallback := TextureRect.new()
			var bag := UI.runtime_texture("icon_bag.png")
			if bag != null:
				icon_fallback.texture = bag
				icon_fallback.custom_minimum_size = Vector2(46.0, 46.0)
				icon_fallback.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon_fallback.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon_fallback.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				row.add_child(icon_fallback)
			else:
				var glyph := UI.style_heading(Label.new(), UI.COLOR_GOLD, 18, HORIZONTAL_ALIGNMENT_CENTER)
				glyph.text = "◆"
				glyph.custom_minimum_size.x = 46.0
				row.add_child(glyph)
		var description := VBoxContainer.new()
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(description)
		var name := UI.style_label(Label.new(), UI.COLOR_TEXT, 14)
		name.text = "%s  ×%d" % [item.display_name, int(entry.get("total", 0))]
		description.add_child(name)
		var detail := UI.style_label(Label.new(), UI.COLOR_MUTED, 11)
		detail.text = "%s\nSecured %d  ·  Expedition %d" % [
			item.description,
			int(entry.get("secured", 0)),
			int(entry.get("expedition", 0)),
		]
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.add_child(detail)
		if _item_registry().is_equipment_item(item):
			var equip := UI.style_button(Button.new(), Color(0.36, 0.48, 0.30))
			equip.text = "Equip"
			equip.custom_minimum_size = Vector2(84.0, 34.0)
			equip.tooltip_text = _equipment_tooltip(item as EquipmentData)
			equip.pressed.connect(_on_equip_pressed.bind(item_id))
			row.add_child(equip)


func _build_technique_content() -> void:
	var intro := UI.style_label(Label.new(), UI.COLOR_MUTED, 12)
	intro.text = "Techniques shape an Adventurer through discoveries, teachers, quests, and milestones."
	_content.add_child(intro)
	var techniques: Array[TechniqueData] = _techniques().get_unlocked_techniques()
	if techniques.is_empty():
		_content.add_child(_message_label("No Techniques have been unlocked."))
		return
	for technique: TechniqueData in techniques:
		var panel := PanelContainer.new()
		var accent := UI.COLOR_TECHNIQUE if technique.is_active() else Color(0.40, 0.46, 0.32)
		panel.add_theme_stylebox_override("panel", UI.section_style(accent))
		_content.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		panel.add_child(row)
		var glyph := UI.style_label(Label.new(), accent.lightened(0.35), 22, HORIZONTAL_ALIGNMENT_CENTER)
		glyph.text = "✦" if technique.is_active() else "◇"
		glyph.custom_minimum_size.x = 44.0
		row.add_child(glyph)
		var text_box := VBoxContainer.new()
		text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text_box)
		var name := UI.style_heading(Label.new(), UI.COLOR_GOLD, 15)
		name.text = "%s  ·  %s" % [
			technique.display_name,
			"ACTIVE" if technique.is_active() else "PASSIVE",
		]
		text_box.add_child(name)
		var description := UI.style_label(Label.new(), UI.COLOR_TEXT, 12)
		description.text = technique.description
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_box.add_child(description)
		var source := UI.style_label(Label.new(), UI.COLOR_MUTED, 10)
		source.text = "Unlocked: %s  ·  Level %d%s" % [
			technique.unlock_source,
			technique.minimum_level,
			"  ·  %.1fs cooldown" % technique.cooldown if technique.is_active() else "",
		]
		text_box.add_child(source)
		var state := UI.style_label(Label.new(), Color(0.66, 0.88, 0.58), 12)
		state.custom_minimum_size.x = 105.0
		state.text = "EQUIPPED" if _techniques().is_equipped(technique.id) else "OWNED"
		row.add_child(state)


func _build_quest_content() -> void:
	var intro := UI.style_label(Label.new(), UI.COLOR_MUTED, 12)
	intro.text = "Press F to accept or turn in the next available quest opportunity."
	_content.add_child(intro)
	var quest_ids: PackedStringArray = _quests().get_known_quest_ids()
	if quest_ids.is_empty():
		_content.add_child(_message_label("No known quests."))
		return
	for quest_id: String in quest_ids:
		var quest: QuestData = _quests().get_quest(quest_id)
		if quest == null:
			continue
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", UI.section_style(UI.COLOR_QUEST))
		_content.add_child(panel)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 4)
		panel.add_child(box)
		var heading := UI.style_heading(Label.new(), Color(0.74, 0.88, 0.66), 15)
		heading.text = "%s  ·  %s" % [quest.title, _quests().get_state_name(quest_id).to_upper()]
		box.add_child(heading)
		var description := UI.style_label(Label.new(), UI.COLOR_TEXT, 12)
		description.text = quest.description
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(description)
		var objective_lines: PackedStringArray = _quests().get_objective_lines(quest_id)
		var objectives := UI.style_label(Label.new(), UI.COLOR_GOLD, 11)
		objectives.text = "\n".join(objective_lines) if not objective_lines.is_empty() else "Objectives reveal when accepted."
		box.add_child(objectives)


func _message_label(text: String) -> Label:
	var label := UI.style_label(Label.new(), UI.COLOR_MUTED, 14, HORIZONTAL_ALIGNMENT_CENTER)
	label.text = text
	label.custom_minimum_size.y = 80.0
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _on_allocate_stat(stat_id: StringName) -> void:
	if _progression().allocate_stat(stat_id):
		_notify("Allocated 1 %s" % str(CORE_STAT_NAMES[stat_id]), Color(0.60, 0.90, 0.62))
	else:
		_notify("No stat point available", Color(0.88, 0.64, 0.38))
	_refresh_if_open()


func _on_equip_pressed(item_id: String) -> void:
	if _equipment != null and _equipment.equip_from_inventory(item_id):
		var item: ItemData = _item_registry().get_item(item_id)
		_notify("Equipped %s" % item.display_name, UI.COLOR_GOLD)
		_refresh_if_open()


func _on_unequip_pressed(slot_key: String) -> void:
	if _equipment != null and _equipment.unequip(slot_key):
		_notify("Unequipped %s slot" % slot_key.capitalize(), UI.COLOR_TEXT)
		_refresh_if_open()


func _notify(text: String, color: Color) -> void:
	var hud := get_tree().get_first_node_in_group("game_hud")
	if hud != null:
		hud.call("show_status_message", text, color)


func _breakdown_tooltip(breakdown: Dictionary) -> String:
	return "Base %.1f\nAllocated %.1f\nEquipment %.1f\nEffects %.1f\nLevel %.1f" % [
		float(breakdown.get("base", 0.0)),
		float(breakdown.get("allocated", 0.0)),
		float(breakdown.get("equipment", 0.0)),
		float(breakdown.get("effects", 0.0)),
		float(breakdown.get("level", 0.0)),
	]


func _equipment_tooltip(item: EquipmentData) -> String:
	var lines: PackedStringArray = [item.description]
	if item.stat_modifiers != null:
		for stat_name: String in [
			"strength", "dexterity", "vitality", "intellect", "max_health",
			"attack_damage", "attack_speed", "armor", "crit_chance", "lifesteal", "move_speed",
		]:
			var value := item.stat_modifiers.get_stat(stat_name)
			if not is_zero_approx(value):
				var sign_text := "+" if value > 0.0 else ""
				lines.append("%s %s%.2f" % [stat_name.capitalize(), sign_text, value])
	return "\n".join(lines)


func _inventory():
	return get_node("/root/Inventory")


func _item_registry():
	return get_node("/root/ItemRegistry")


func _progression():
	return get_node("/root/CharacterProgression")


func _techniques():
	return get_node("/root/TechniqueManager")


func _quests():
	return get_node("/root/QuestManager")
