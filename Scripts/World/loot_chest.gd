class_name LootChest
extends Area2D

signal opened(loot: Array)

@export var loot_table: LootTable
@export var prompt_text: String = "Open Chest [F]"

var _is_open := false
var _player_inside: Node = null

@onready var _closed_visual: CanvasItem = $ClosedVisual
@onready var _opened_visual: CanvasItem = $OpenedVisual
@onready var _prompt_label: Label = $PromptLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1
	_update_visuals()
	if _prompt_label != null:
		_prompt_label.visible = false
		_prompt_label.text = prompt_text


func _unhandled_input(event: InputEvent) -> void:
	if _is_open or _player_inside == null:
		return
	if event.is_action_pressed("interact"):
		_open_chest()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = body
	if _prompt_label != null and not _is_open:
		_prompt_label.visible = true


func _on_body_exited(body: Node) -> void:
	if body == _player_inside:
		_player_inside = null
		if _prompt_label != null:
			_prompt_label.visible = false


func _open_chest() -> void:
	if _is_open:
		return

	_is_open = true
	_update_visuals()
	if _prompt_label != null:
		_prompt_label.visible = false

	var loot: Array[Dictionary] = []
	if loot_table != null:
		loot = loot_table.roll_all()

	var parent := get_parent()
	for entry: Dictionary in loot:
		var item_id: String = str(entry.get("item_id", ""))
		var quantity: int = int(entry.get("quantity", 0))
		if item_id.is_empty() or quantity <= 0:
			continue
		LootPickup.spawn(parent, global_position + Vector2(randf_range(-18.0, 18.0), randf_range(-8.0, 8.0)), item_id, quantity)

	opened.emit(loot)
	print("Chest opened with %d loot drops." % loot.size())


func _update_visuals() -> void:
	if _closed_visual != null:
		_closed_visual.visible = not _is_open
	if _opened_visual != null:
		_opened_visual.visible = _is_open
