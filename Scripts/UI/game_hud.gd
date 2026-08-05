extends CanvasLayer

@onready var _hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPBar
@onready var _hp_label: Label = $MarginContainer/VBoxContainer/HPLabel
@onready var _expedition_label: Label = $MarginContainer/VBoxContainer/ExpeditionLabel
@onready var _zone_banner: Control = $ZoneBanner
@onready var _zone_title: Label = $ZoneBanner/VBoxContainer/ZoneTitle
@onready var _zone_subtitle: Label = $ZoneBanner/VBoxContainer/ZoneSubtitle
@onready var _status_label: Label = $StatusMessage
@onready var _level_label: Label = $ProgressionPanel/MarginContainer/VBoxContainer/LevelLabel
@onready var _xp_bar: ProgressBar = $ProgressionPanel/MarginContainer/VBoxContainer/XPBar
@onready var _xp_label: Label = $ProgressionPanel/MarginContainer/VBoxContainer/XPLabel
@onready var _stats_label: Label = $ProgressionPanel/MarginContainer/VBoxContainer/StatsLabel
@onready var _techniques_label: Label = $ProgressionPanel/MarginContainer/VBoxContainer/TechniquesLabel
@onready var _quests_label: Label = $ProgressionPanel/MarginContainer/VBoxContainer/QuestsLabel

var _banner_tween: Tween
var _status_tween: Tween


func _ready() -> void:
	add_to_group("game_hud")
	_zone_banner.modulate.a = 0.0
	_status_label.modulate.a = 0.0
	_status_label.text = ""
	await get_tree().process_frame
	_connect_to_player()
	_connect_to_systems()
	_refresh_expedition_label()
	_refresh_progression_panel()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("allocate_strength"):
		_allocate_stat(&"strength")
	elif event.is_action_pressed("allocate_dexterity"):
		_allocate_stat(&"dexterity")
	elif event.is_action_pressed("allocate_vitality"):
		_allocate_stat(&"vitality")
	elif event.is_action_pressed("allocate_intellect"):
		_allocate_stat(&"intellect")
	elif event.is_action_pressed("interact"):
		var result: String = _quest_manager().perform_context_action()
		show_status_message(result, Color(0.72, 0.86, 1.0))
		_refresh_progression_panel()


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
		if not inventory.expedition_loot_changed.is_connected(_on_expedition_changed):
			inventory.expedition_loot_changed.connect(_on_expedition_changed)
		if not inventory.item_added.is_connected(_on_item_added):
			inventory.item_added.connect(_on_item_added)

	var progression := get_node_or_null("/root/CharacterProgression")
	if progression != null:
		progression.xp_gained.connect(_on_xp_gained)
		progression.level_up.connect(_on_level_up)
		progression.stat_points_changed.connect(_on_stat_points_changed)
		progression.stat_allocated.connect(_on_stat_allocated)

	var techniques := get_node_or_null("/root/TechniqueManager")
	if techniques != null:
		techniques.technique_unlocked.connect(_on_technique_unlocked)
		techniques.techniques_changed.connect(_on_techniques_changed)

	var quests := get_node_or_null("/root/QuestManager")
	if quests != null:
		quests.quest_state_changed.connect(_on_quest_state_changed)
		quests.quest_objective_progressed.connect(_on_quest_objective_progressed)


func _on_health_changed(current: int, maximum: int) -> void:
	_hp_bar.max_value = maximum
	_hp_bar.value = current
	_hp_label.text = "HP %d / %d" % [current, maximum]


func _on_zone_changed(zone_data: ZoneData) -> void:
	if zone_data == null:
		return
	show_zone_banner(zone_data.display_name.to_upper(), zone_data.get_banner_subtitle())
	_refresh_expedition_label()


func _on_expedition_changed() -> void:
	_refresh_expedition_label()


func _on_item_added(item_id: String, quantity_added: int, _new_total: int) -> void:
	var zone_manager := get_node_or_null("/root/ZoneManager")
	if zone_manager == null or zone_manager.is_in_safe_zone():
		return

	var item: ItemData = get_node("/root/ItemRegistry").get_item(item_id)
	var display_name: String = item.display_name if item != null else item_id
	show_status_message("Unsecured loot: %s x%d" % [display_name, quantity_added], Color(1.0, 0.85, 0.45))


func _refresh_expedition_label() -> void:
	var inventory := get_node_or_null("/root/Inventory")
	if inventory == null:
		_expedition_label.text = "Expedition: 0"
		return

	var total := 0
	for entry in inventory.get_expedition_summary():
		total += int(entry.get("quantity", 0))
	_expedition_label.text = "Expedition Loot: %d" % total


func _refresh_progression_panel() -> void:
	var progression := get_node_or_null("/root/CharacterProgression")
	if progression == null:
		return
	var xp_needed: int = progression.get_xp_needed_for_next_level()
	_level_label.text = "ADVENTURER — LEVEL %d" % progression.current_level
	_xp_bar.max_value = maxi(xp_needed, 1)
	_xp_bar.value = progression.current_xp
	_xp_label.text = "XP %d / %d" % [progression.current_xp, xp_needed]
	_stats_label.text = (
		"Unspent Points: %d\n[1] STR %d  [2] DEX %d  [3] VIT %d  [4] INT %d"
		% [
			progression.unspent_stat_points,
			5 + progression.get_allocated_points(&"strength"),
			5 + progression.get_allocated_points(&"dexterity"),
			5 + progression.get_allocated_points(&"vitality"),
			5 + progression.get_allocated_points(&"intellect"),
		]
	)

	var technique_names: PackedStringArray = []
	for technique: TechniqueData in _technique_manager().get_unlocked_techniques():
		technique_names.append(technique.display_name)
	_techniques_label.text = "Techniques [Q]\n%s" % (
		", ".join(technique_names) if not technique_names.is_empty() else "None unlocked"
	)

	var quest_lines: PackedStringArray = _quest_manager().get_visible_quest_lines()
	_quests_label.text = "Quests [F accept/turn in]\n%s" % (
		"\n".join(quest_lines) if not quest_lines.is_empty() else "No active quests"
	)


func _allocate_stat(stat_id: StringName) -> void:
	if _progression().allocate_stat(stat_id):
		show_status_message("Allocated 1 %s" % String(stat_id).capitalize(), Color(0.55, 0.9, 0.65))
	else:
		show_status_message("No stat point available", Color(0.85, 0.65, 0.4))
	_refresh_progression_panel()


func _on_xp_gained(amount: int, _current_xp: int, _xp_needed: int) -> void:
	if amount > 0:
		show_status_message("+%d XP" % amount, Color(0.55, 0.85, 1.0))
	_refresh_progression_panel()


func _on_level_up(new_level: int, stat_points_awarded: int) -> void:
	show_status_message(
		"LEVEL %d — +%d stat point" % [new_level, stat_points_awarded],
		Color(1.0, 0.82, 0.3)
	)
	_refresh_progression_panel()


func _on_stat_points_changed(_unspent_points: int) -> void:
	_refresh_progression_panel()


func _on_stat_allocated(_stat_id: StringName, _new_total: int) -> void:
	_refresh_progression_panel()


func _on_technique_unlocked(technique_id: String) -> void:
	var technique: TechniqueData = _technique_manager().get_technique(technique_id)
	if technique != null:
		show_status_message("Technique unlocked: %s" % technique.display_name, Color(0.7, 0.65, 1.0))
	_refresh_progression_panel()


func _on_techniques_changed() -> void:
	_refresh_progression_panel()


func _on_quest_state_changed(_quest_id: String, _new_state: int) -> void:
	_refresh_progression_panel()


func _on_quest_objective_progressed(
	_quest_id: String,
	_objective_index: int,
	_current: int,
	_required: int
) -> void:
	_refresh_progression_panel()


func _progression():
	return get_node("/root/CharacterProgression")


func _technique_manager():
	return get_node("/root/TechniqueManager")


func _quest_manager():
	return get_node("/root/QuestManager")
