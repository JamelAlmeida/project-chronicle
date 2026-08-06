class_name EquipmentData
extends ItemData

const EquipmentAppearanceData = preload(
	"res://Project Chronicle/Scripts/Presentation/equipment_appearance_data.gd"
)

enum EquipmentSlot {
	WEAPON,
	OFFHAND,
	HEAD,
	CHEST,
	HANDS,
	FEET,
	RING,
	AMULET,
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
}

@export var equipment_slot: EquipmentSlot = EquipmentSlot.WEAPON
@export var rarity: Rarity = Rarity.COMMON
@export var stat_modifiers: StatBlock
@export var tags: PackedStringArray = []
@export var set_id: String = ""
@export var passive_effect_ids: PackedStringArray = []
@export var weapon_attack_cooldown: float = 0.4
## Optional visible-gear binding. Leave null until approved layer art exists for this item.
@export var appearance: EquipmentAppearanceData
