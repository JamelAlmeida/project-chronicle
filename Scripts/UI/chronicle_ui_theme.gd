class_name ChronicleUITheme
extends RefCounted

const BODY_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Alegreya-Variable.ttf"
const HEADING_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"

const COLOR_INK := Color(0.018, 0.022, 0.025, 0.975)
const COLOR_PANEL := Color(0.042, 0.047, 0.049, 0.965)
const COLOR_INSET := Color(0.018, 0.022, 0.024, 0.94)
const COLOR_BRASS := Color(0.47, 0.34, 0.17, 1.0)
const COLOR_BRASS_LIGHT := Color(0.68, 0.51, 0.25, 1.0)
const COLOR_GOLD := Color(0.88, 0.71, 0.39, 1.0)
const COLOR_TEXT := Color(0.91, 0.88, 0.79, 1.0)
const COLOR_MUTED := Color(0.60, 0.61, 0.56, 1.0)
const COLOR_HEALTH := Color(0.50, 0.075, 0.075, 1.0)
const COLOR_XP := Color(0.25, 0.43, 0.57, 1.0)
const COLOR_TECHNIQUE := Color(0.43, 0.34, 0.58, 1.0)
const COLOR_QUEST := Color(0.31, 0.47, 0.27, 1.0)

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
	style.border_width_top = 1
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0.0, 3.0)
	style.content_margin_left = 14.0
	style.content_margin_top = 11.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 11.0
	return style


static func inset_style(accent: Color = Color(0.22, 0.22, 0.20, 1.0)) -> StyleBoxFlat:
	var style := panel_style(COLOR_INSET, accent)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.shadow_size = 2
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	return style


static func section_style(accent: Color = COLOR_BRASS) -> StyleBoxFlat:
	var style := inset_style(accent.darkened(0.34))
	style.bg_color = Color(0.028, 0.032, 0.032, 0.94)
	style.border_width_top = 2
	style.border_color = accent.darkened(0.12)
	return style


static func bar_background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.008, 0.01, 0.011, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.30, 0.23, 0.13, 1.0)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func bar_fill(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = color.lightened(0.38)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func style_label(
	label: Label,
	color: Color = COLOR_TEXT,
	font_size: int = 14,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.015, 0.015, 0.015, 1.0))
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
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_stylebox_override("normal", inset_style(accent.darkened(0.52)))
	button.add_theme_stylebox_override("hover", inset_style(accent.darkened(0.22)))
	button.add_theme_stylebox_override("pressed", inset_style(accent))
	button.add_theme_stylebox_override("disabled", inset_style(Color(0.12, 0.12, 0.12, 1.0)))
	return button


static func make_separator() -> HSeparator:
	var separator := HSeparator.new()
	separator.add_theme_constant_override("separation", 8)
	separator.modulate = COLOR_BRASS_LIGHT
	return separator
