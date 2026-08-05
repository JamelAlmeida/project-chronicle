extends CanvasLayer

const TEST_ITEM_IDS: Array[String] = [
	"rusted_sword",
	"swift_katana",
	"bloodfang_blade",
	"crimson_leech_ring",
]

var _equipment: EquipmentComponent
var _stats: StatsComponent
var _slot_value_labels: Dictionary = {}


@onready var _panel: PanelContainer = $PanelContainer
@onready var _slots_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/SlotsContainer
@onready var _equip_buttons: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/EquipButtons
@onready var _attack_damage_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsContainer/AttackDamageValue
@onready var _attack_speed_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsContainer/AttackSpeedValue
@onready var _crit_chance_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsContainer/CritChanceValue
@onready var _lifesteal_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsContainer/LifestealValue
@onready var _armor_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsContainer/ArmorValue
@onready var _move_speed_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsContainer/MoveSpeedValue


func _ready() -> void:
	_panel.visible = false
	await get_tree().process_frame
	_build_equip_buttons()
	_connect_to_player()
	_build_slot_rows()
	_refresh_all()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("toggle_equipment_debug"):
		return

	_panel.visible = not _panel.visible
	if _panel.visible:
		_refresh_all()
	else:
		get_viewport().gui_release_focus()

	get_viewport().set_input_as_handled()


func _connect_to_player() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	_equipment = player.get_node("EquipmentComponent") as EquipmentComponent
	_stats = player.get_node("StatsComponent") as StatsComponent
	if _equipment != null:
		_equipment.equipment_changed.connect(_on_equipment_changed)
	if _stats != null:
		_stats.stats_changed.connect(_on_stats_changed)


func _build_equip_buttons() -> void:
	for item_id: String in TEST_ITEM_IDS:
		var item: ItemData = _item_registry().get_item(item_id)
		if item == null:
			continue

		var button := Button.new()
		button.text = "Equip %s" % item.display_name
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_equip_pressed.bind(item_id))
		_equip_buttons.add_child(button)


func _build_slot_rows() -> void:
	for child: Node in _slots_container.get_children():
		child.queue_free()

	_slot_value_labels.clear()

	for slot_key: String in EquipmentComponent.SLOT_KEYS:
		var row := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = "%s:" % slot_key.capitalize()
		name_label.custom_minimum_size = Vector2(72, 0)
		row.add_child(name_label)

		var value_label := Label.new()
		value_label.name = "%sValue" % slot_key
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(value_label)
		_slot_value_labels[slot_key] = value_label

		var unequip_button := Button.new()
		unequip_button.text = "X"
		unequip_button.focus_mode = Control.FOCUS_NONE
		unequip_button.pressed.connect(_on_unequip_pressed.bind(slot_key))
		row.add_child(unequip_button)

		_slots_container.add_child(row)


func _on_equip_pressed(item_id: String) -> void:
	if _equipment == null:
		return

	if not _inventory().has_item(item_id, 1):
		_inventory().add_item(item_id, 1)

	_equipment.equip_from_inventory(item_id)
	_refresh_all()


func _on_unequip_pressed(slot_key: String) -> void:
	if _equipment == null:
		return

	_equipment.unequip(slot_key)
	_refresh_all()


func _on_equipment_changed(_slot_key: String, _item_id: String) -> void:
	_refresh_all()


func _on_stats_changed() -> void:
	_refresh_stats()


func _refresh_all() -> void:
	_refresh_slots()
	_refresh_stats()


func _refresh_slots() -> void:
	if _equipment == null:
		return

	for slot_key: String in EquipmentComponent.SLOT_KEYS:
		var value_label: Label = _slot_value_labels.get(slot_key) as Label
		if value_label == null:
			continue

		var item_id: String = _equipment.get_equipped_id(slot_key)
		if item_id.is_empty():
			value_label.text = "(empty)"
			continue

		var item: ItemData = _item_registry().get_item(item_id)
		var display_name: String = item.display_name if item != null else item_id
		value_label.text = display_name


func _refresh_stats() -> void:
	if _stats == null:
		return

	_attack_damage_label.text = str(int(round(_stats.get_attack_damage())))
	_attack_speed_label.text = "%.2fx" % _stats.get_attack_speed()
	_crit_chance_label.text = "%.0f%%" % (_stats.get_crit_chance() * 100.0)
	_lifesteal_label.text = "%.0f%%" % (_stats.get_lifesteal() * 100.0)
	_armor_label.text = str(int(round(_stats.get_armor())))
	_move_speed_label.text = str(int(round(_stats.get_move_speed())))


func _inventory():
	return get_node("/root/Inventory")


func _item_registry():
	return get_node("/root/ItemRegistry")
