class_name EquipmentAppearanceData
extends Resource

## Optional visual binding for equipped gear.
## ChatGPT supplies approved SpriteFrames / textures; this resource only references them.
## Leave unset on items until real appearance assets exist — never invent filler art.

@export var visual_set_id: String = ""
@export var equipment_layer: StringName = &""
## SpriteFrames for the matching 96×112 modular layer (same animation contract as the body).
@export var layer_frames: SpriteFrames
## Optional static overlay if a piece does not need full animation yet.
@export var static_texture: Texture2D
## When true, hide HairFront / HairBack while this piece is equipped (typical for helmets).
@export var hides_hair: bool = false
