class_name ItemData
extends Resource

enum ItemType {
	MATERIAL,
	CONSUMABLE,
	WEAPON,
	ARMOR,
	RING,
	QUEST,
}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
## Optional world-drop sprite (≈24–40 px longest side). When null, LootPickup falls back to icon.
@export var world_sprite: Texture2D
@export var item_type: ItemType = ItemType.MATERIAL
@export var max_stack: int = 99
