extends CanvasLayer

@onready var _hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPBar
@onready var _hp_label: Label = $MarginContainer/VBoxContainer/HPLabel
@onready var _expedition_label: Label = $MarginContainer/VBoxContainer/ExpeditionLabel
@onready var _zone_banner: Control = $ZoneBanner
@onready var _zone_title: Label = $ZoneBanner/VBoxContainer/ZoneTitle
@onready var _zone_subtitle: Label = $ZoneBanner/VBoxContainer/ZoneSubtitle
@onready var _status_label: Label = $StatusMessage

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
