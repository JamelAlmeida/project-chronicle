class_name ChronicleUITheme
extends RefCounted

const BODY_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Alegreya-Variable.ttf"
const HEADING_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"

const COLOR_INK := Color(0.045, 0.035, 0.028, 0.97)
const COLOR_PANEL := Color(0.07, 0.055, 0.042, 0.96)
const COLOR_INSET := Color(0.028, 0.022, 0.018, 0.94)
const COLOR_STONE := Color(0.11, 0.09, 0.07, 0.98)
const COLOR_BRASS := Color(0.62, 0.46, 0.22, 1.0)
const COLOR_BRASS_LIGHT := Color(0.82, 0.64, 0.32, 1.0)
const COLOR_GOLD := Color(0.93, 0.78, 0.42, 1.0)
const COLOR_TEXT := Color(0.94, 0.90, 0.80, 1.0)
const COLOR_MUTED := Color(0.68, 0.62, 0.52, 1.0)
const COLOR_HEALTH := Color(0.72, 0.14, 0.12, 1.0)
const COLOR_STEADFAST := Color(0.18, 0.42, 0.72, 1.0)
const COLOR_XP := Color(0.22, 0.48, 0.78, 1.0)
const COLOR_TECHNIQUE := Color(0.52, 0.34, 0.72, 1.0)
const COLOR_QUEST := Color(0.38, 0.55, 0.28, 1.0)

static var _body_font: FontFile
static var _heading_font: FontFile


static func body_font() -> FontFile:
	if _body_font == null:
		_body_font = _load_font(BODY_FONT_PATH)
	return _body_font


static func heading_font() -> FontFile:
	if _heading_font == null:
		_heading_font = _load_font(HEADING_FONT_PATH)
	return _heading_font


static func _load_font(path: String) -> FontFile:
	var font := FontFile.new()
	font.data = FileAccess.get_file_as_bytes(path)
	return font


static func panel_style(background: Color = COLOR_PANEL, border: Color = COLOR_BRASS) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.7)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0.0, 3.0)
	style.content_margin_left = 14.0
	style.content_margin_top = 11.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 11.0
	return style


## Compact top trackers — quiet over the world.
static func hud_panel_style(background: Color = COLOR_PANEL, border: Color = COLOR_BRASS) -> StyleBoxFlat:
	var style := panel_style(background, border)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0.0, 2.0)
	style.content_margin_left = 10.0
	style.content_margin_top = 7.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 7.0
	return style


## Full-width bottom adventure bar — dark stone with warm gold edging.
static func bottom_hud_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_STONE
	style.border_width_left = 0
	style.border_width_top = 3
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.border_color = COLOR_BRASS_LIGHT
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_right = 0
	style.corner_radius_bottom_left = 0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.78)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0.0, -2.0)
	style.content_margin_left = 16.0
	style.content_margin_top = 10.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 6.0
	return style


static func inset_style(accent: Color = Color(0.22, 0.18, 0.14, 1.0)) -> StyleBoxFlat:
	var style := panel_style(COLOR_INSET, accent)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.shadow_size = 2
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.content_margin_left = 4.0
	style.content_margin_top = 4.0
	style.content_margin_right = 4.0
	style.content_margin_bottom = 4.0
	return style


static func action_slot_style(accent: Color) -> StyleBoxFlat:
	var style := inset_style(accent.lightened(0.12))
	style.bg_color = Color(0.05, 0.04, 0.03, 0.96)
	style.border_color = accent.lightened(0.18)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	return style


static func section_style(accent: Color = COLOR_BRASS) -> StyleBoxFlat:
	var style := inset_style(accent.darkened(0.34))
	style.bg_color = Color(0.035, 0.028, 0.022, 0.94)
	style.border_width_top = 2
	style.border_color = accent.darkened(0.12)
	return style


static func bar_background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.03, 0.025, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.42, 0.32, 0.16, 1.0)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style


static func bar_fill(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = color.lightened(0.42)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style


static func style_label(
	label: Label,
	color: Color = COLOR_TEXT,
	font_size: int = 14,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.015, 0.01, 1.0))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_font_override("font", body_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = alignment
	return label


static func style_heading(
	label: Label,
	color: Color = COLOR_GOLD,
	font_size: int = 18,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	style_label(label, color, font_size, alignment)
	label.add_theme_font_override("font", heading_font())
	label.add_theme_constant_override("outline_size", 3)
	return label


static func style_eyebrow(
	label: Label,
	color: Color = COLOR_BRASS_LIGHT,
	font_size: int = 11,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	style_heading(label, color, font_size, alignment)
	return label


static func style_button(button: Button, accent: Color = COLOR_BRASS) -> Button:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", COLOR_GOLD)
	button.add_theme_font_override("font", body_font())
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("normal", inset_style(accent.darkened(0.4)))
	button.add_theme_stylebox_override("hover", inset_style(accent.darkened(0.12)))
	button.add_theme_stylebox_override("pressed", inset_style(accent))
	button.add_theme_stylebox_override("disabled", inset_style(Color(0.12, 0.1, 0.08, 1.0)))
	return button


static func make_separator() -> HSeparator:
	var separator := HSeparator.new()
	separator.add_theme_constant_override("separation", 8)
	separator.modulate = COLOR_BRASS_LIGHT
	return separator
