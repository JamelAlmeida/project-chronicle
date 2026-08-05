class_name LootPickup
extends Area2D

const LOOT_PICKUP_SCENE_PATH: String = "res://Project Chronicle/Scenes/World/loot_pickup.tscn"

@export var item_id: String = "slime_gel"
@export var quantity: int = 1

var _item_id: String = ""
var _quantity: int = 1
var _hover_time := 0.0

@onready var _icon: Sprite2D = $Icon
@onready var _fallback_visual: ColorRect = $ColorRect
@onready var _sparkle: Polygon2D = $Sparkle


static func spawn(parent: Node, world_position: Vector2, item_id: String, quantity: int = 1) -> void:
	var pickup_scene: PackedScene = load(LOOT_PICKUP_SCENE_PATH) as PackedScene
	if pickup_scene == null:
		return

	var pickup: LootPickup = pickup_scene.instantiate() as LootPickup
	if pickup == null:
		return

	parent.add_child(pickup)
	pickup.global_position = world_position
	pickup.setup(item_id, quantity)


func setup(item_id: String, quantity: int = 1) -> void:
	_item_id = item_id
	_quantity = quantity

	var item: ItemData = _item_registry().get_item(item_id)
	if item != null:
		$Label.text = item.display_name
		if item.icon != null:
			_icon.texture = item.icon
			_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			_icon.visible = true
			_fallback_visual.visible = false
		else:
			_icon.visible = false
			_fallback_visual.visible = true


func _ready() -> void:
	add_to_group("loot_pickups")
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = false
	if _item_id.is_empty():
		setup(item_id, quantity)
	_combat_feedback().spawn_loot_sparkle(global_position, self)


func _process(delta: float) -> void:
	_hover_time += delta
	var hover_offset := sin(_hover_time * 2.4) * 1.5
	_icon.position.y = hover_offset
	_fallback_visual.position.y = hover_offset
	_sparkle.rotation = _hover_time * 0.8
	_sparkle.modulate.a = 0.45 + sin(_hover_time * 4.0) * 0.25


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	var added: int = _inventory().add_item(_item_id, _quantity)
	if added <= 0:
		return

	var item: ItemData = _item_registry().get_item(_item_id)
	var display_name: String = item.display_name if item != null else _item_id
	var total: int = _inventory().get_quantity(_item_id)
	print("Collected %s x%d (Total: %d)" % [display_name, added, total])
	queue_free()


func _inventory():
	return get_node("/root/Inventory")


func _item_registry():
	return get_node("/root/ItemRegistry")


func _combat_feedback():
	return get_node("/root/CombatFeedback")
