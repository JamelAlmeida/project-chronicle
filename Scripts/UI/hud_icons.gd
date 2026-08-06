class_name HudIcons
extends RefCounted

## Loads Chronicle HUD pixel icons with nearest-neighbor presentation.

const ICON_ROOT := "res://Project Chronicle/Assets/UI/Icons/"

const CREST := "crest"
const ATTACK := "attack"
const DASH := "dash"
const TECHNIQUE := "technique"
const ARC_SLASH := "arc_slash"
const PULSE_WAVE := "pulse_wave"
const VERDANT_BLOOM := "verdant_bloom"
const POTION := "potion"
const MENU_CHARACTER := "menu_character"
const MENU_INVENTORY := "menu_inventory"
const MENU_TECHNIQUES := "menu_techniques"
const MENU_QUESTS := "menu_quests"

static var _cache: Dictionary = {}


static func texture(icon_id: String) -> Texture2D:
	if icon_id.is_empty():
		return null
	if _cache.has(icon_id):
		return _cache[icon_id] as Texture2D
	var path := "%s%s.png" % [ICON_ROOT, icon_id]
	var image := Image.new()
	if image.load(path) != OK:
		push_warning("Missing HUD icon: %s" % path)
		return null
	var tex := ImageTexture.create_from_image(image)
	_cache[icon_id] = tex
	return tex


static func make_rect(icon_id: String, size: Vector2 = Vector2(40, 40)) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture(icon_id)
	rect.custom_minimum_size = size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect
