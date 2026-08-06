class_name ChronicleUITheme
extends RefCounted

const BODY_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Alegreya-Variable.ttf"
const HEADING_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"
## HARD UI VISUAL RESET: live presentation uses flat structural styles only.
## Showcase/Runtime/UI ornament crops remain on disk as unreferenced legacy — do not load them.
const USE_ORNAMENT_SKINS := false
const SHOWCASE_UI_ROOT := "res://Project Chronicle/Assets/Showcase/Runtime/UI/"
const UI_RUNTIME_ROOT := ""

const COLOR_INK := Color(0.06, 0.07, 0.08, 0.96)
const COLOR_PANEL := Color(0.10, 0.11, 0.13, 0.88)
const COLOR_INSET := Color(0.07, 0.08, 0.09, 0.92)
const COLOR_STONE := Color(0.12, 0.13, 0.15, 0.90)
const COLOR_BRASS := Color(0.55, 0.55, 0.58, 1.0)
const COLOR_BRASS_LIGHT := Color(0.78, 0.78, 0.82, 1.0)
const COLOR_GOLD := Color(0.92, 0.90, 0.82, 1.0)
const COLOR_TEXT := Color(0.94, 0.94, 0.95, 1.0)
const COLOR_MUTED := Color(0.68, 0.68, 0.72, 1.0)
const COLOR_HEALTH := Color(0.78, 0.22, 0.22, 1.0)
const COLOR_STEADFAST := Color(0.22, 0.50, 0.82, 1.0)
const COLOR_XP := Color(0.28, 0.55, 0.88, 1.0)
const COLOR_TECHNIQUE := Color(0.55, 0.42, 0.78, 1.0)
const COLOR_QUEST := Color(0.62, 0.78, 0.48, 1.0)
const COLOR_OUTLINE := Color(0.02, 0.02, 0.03, 0.90)

static var _body_font: Font
static var _heading_font: Font
static var _texture_cache: Dictionary = {}


static func body_font() -> Font:
	if _body_font == null:
		_body_font = _make_font(BODY_FONT_PATH, 500)
	return _body_font


static func heading_font() -> Font:
	if _heading_font == null:
		_heading_font = _make_font(HEADING_FONT_PATH, 650)
	return _heading_font


static func _make_font(path: String, weight: int) -> Font:
	var base := FontFile.new()
	base.data = FileAccess.get_file_as_bytes(path)
	var variation := FontVariation.new()
	variation.base_font = base
	variation.variation_opentype = {0x77676874: weight}
	return variation


static func runtime_texture(_name: String) -> Texture2D:
	## Live UI never loads Showcase/legacy ornament textures after the hard visual reset.
	return null


static func showcase_texture(_relative_path: String) -> Texture2D:
	## Live UI never loads Showcase ornament textures after the hard visual reset.
	return null


static func _load_texture_from_roots(name: String, roots: Array) -> Texture2D:
	for root in roots:
		if str(root).is_empty():
			continue
		var tex := _load_texture_path("%s%s" % [root, name])
		if tex != null:
			return tex
	return null


static func _load_texture_path(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	if FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	return null


static func textured_style(
	_texture_name: String,
	_margin: float = 24.0,
	_content_margin: float = 12.0,
	_stretch_mode: StyleBoxTexture.AxisStretchMode = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
) -> StyleBox:
	## Ornament StyleBoxTexture paths are retired from live presentation.
	return null


static func panel_style(background: Color = COLOR_PANEL, border: Color = COLOR_BRASS) -> StyleBox:
	return _flat_panel(background, border, 1, 12.0, 10.0, 2)


static func hud_panel_style(background: Color = COLOR_PANEL, border: Color = COLOR_BRASS) -> StyleBox:
	return _flat_panel(background, border, 1, 10.0, 8.0, 1)


static func master_hud_style() -> StyleBox:
	## Structural bottom HUD shell — flat only, no ornament chrome.
	return _flat_panel(COLOR_PANEL, COLOR_BRASS, 1, 12.0, 8.0, 2)


static func hud_island_style() -> StyleBox:
	return status_island_style()


static func status_island_style() -> StyleBox:
	return _flat_panel(COLOR_PANEL, COLOR_BRASS, 1, 10.0, 8.0, 1)


static func action_island_style() -> StyleBox:
	return _flat_panel(COLOR_INSET, COLOR_BRASS, 1, 8.0, 6.0, 1)


static func menu_island_style() -> StyleBox:
	return _flat_panel(COLOR_PANEL, COLOR_BRASS, 1, 8.0, 8.0, 1)


static func _island_style_named(
	_primary: String,
	_fallback: String,
	_margin: float = 22.0,
	_content_margin: float = 10.0
) -> StyleBox:
	return _flat_panel(COLOR_PANEL, COLOR_BRASS, 1, 10.0, 8.0, 1)


static func bottom_hud_style() -> StyleBox:
	return master_hud_style()


static func inset_style(accent: Color = Color(0.22, 0.24, 0.28, 1.0)) -> StyleBox:
	return _flat_panel(COLOR_INSET, accent, 1, 8.0, 6.0, 0)


static func action_slot_style(accent: Color, emphasized: bool = false) -> StyleBox:
	var flat := StyleBoxFlat.new()
	flat.bg_color = Color(0.06, 0.07, 0.08, 0.92)
	var border_w := 2 if emphasized else 1
	flat.border_width_left = border_w
	flat.border_width_top = border_w
	flat.border_width_right = border_w
	flat.border_width_bottom = border_w
	if emphasized:
		flat.border_color = accent.lightened(0.18)
	else:
		flat.border_color = Color(0.40, 0.42, 0.46, 0.85)
	flat.corner_radius_top_left = 2
	flat.corner_radius_top_right = 2
	flat.corner_radius_bottom_right = 2
	flat.corner_radius_bottom_left = 2
	flat.content_margin_left = 4.0
	flat.content_margin_top = 4.0
	flat.content_margin_right = 4.0
	flat.content_margin_bottom = 3.0
	return flat


static func equipment_slot_style() -> StyleBox:
	return action_slot_style(COLOR_BRASS)


static func section_style(accent: Color = COLOR_BRASS) -> StyleBox:
	return _flat_panel(COLOR_INSET, accent.darkened(0.05), 1, 8.0, 8.0, 0)


static func bar_background() -> StyleBox:
	return _flat_panel(Color(0.05, 0.06, 0.07, 1.0), Color(0.35, 0.36, 0.40, 1.0), 1, 0.0, 0.0, 0)


static func bar_fill(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = color.lightened(0.32)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func style_label(
	label: Label,
	color: Color = COLOR_TEXT,
	font_size: int = 15,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_font_override("font", body_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = alignment
	return label


static func style_heading(
	label: Label,
	color: Color = COLOR_GOLD,
	font_size: int = 20,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	style_label(label, color, font_size, alignment)
	label.add_theme_font_override("font", heading_font())
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	return label


static func style_eyebrow(
	label: Label,
	color: Color = COLOR_BRASS_LIGHT,
	font_size: int = 12,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	style_heading(label, color, font_size, alignment)
	label.add_theme_constant_override("outline_size", 3)
	return label


static func style_keybind(
	label: Label,
	unlocked: bool = true,
	font_size: int = 11
) -> Label:
	var color := COLOR_GOLD if unlocked else COLOR_MUTED
	style_heading(label, color, font_size, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_constant_override("outline_size", 3)
	return label


static func style_button(button: Button, accent: Color = COLOR_BRASS) -> Button:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", COLOR_GOLD)
	button.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_override("font", body_font())
	button.add_theme_font_size_override("font_size", 13)
	var normal := inset_style(accent.darkened(0.25))
	var hover := _flat_panel(COLOR_STONE, accent.lightened(0.15), 1, 8.0, 6.0, 0)
	var pressed := _flat_panel(COLOR_INSET, accent, 1, 8.0, 6.0, 0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", inset_style(Color(0.18, 0.18, 0.20, 1.0)))
	return button


static func style_plus_button(button: Button) -> Button:
	button.focus_mode = Control.FOCUS_NONE
	button.text = "+"
	button.custom_minimum_size = Vector2(28.0, 28.0)
	button.icon = null
	style_button(button, Color(0.34, 0.50, 0.28))
	return button


static func make_separator() -> HSeparator:
	var separator := HSeparator.new()
	separator.add_theme_constant_override("separation", 8)
	separator.modulate = COLOR_BRASS_LIGHT
	return separator


static func _flat_panel(
	background: Color,
	border: Color,
	border_width: int,
	content_h: float,
	content_v: float,
	shadow: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = border
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	if shadow > 0:
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
		style.shadow_size = mini(shadow, 2)
		style.shadow_offset = Vector2(0.0, 1.0)
	style.content_margin_left = content_h
	style.content_margin_top = content_v
	style.content_margin_right = content_h
	style.content_margin_bottom = content_v
	return style
