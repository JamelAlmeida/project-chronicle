class_name ChronicleUITheme
extends RefCounted

const COLOR_INK := Color(0.035, 0.04, 0.045, 0.97)
const COLOR_PANEL := Color(0.065, 0.07, 0.075, 0.96)
const COLOR_INSET := Color(0.025, 0.03, 0.034, 0.92)
const COLOR_BRASS := Color(0.55, 0.40, 0.18, 1.0)
const COLOR_GOLD := Color(0.92, 0.74, 0.36, 1.0)
const COLOR_TEXT := Color(0.88, 0.86, 0.78, 1.0)
const COLOR_MUTED := Color(0.58, 0.60, 0.58, 1.0)
const COLOR_HEALTH := Color(0.58, 0.12, 0.12, 1.0)
const COLOR_XP := Color(0.24, 0.48, 0.67, 1.0)
const COLOR_TECHNIQUE := Color(0.48, 0.37, 0.68, 1.0)
const COLOR_QUEST := Color(0.38, 0.55, 0.31, 1.0)


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
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	style.shadow_size = 5
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	return style


static func inset_style(accent: Color = Color(0.22, 0.22, 0.20, 1.0)) -> StyleBoxFlat:
	var style := panel_style(COLOR_INSET, accent)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.shadow_size = 0
	return style


static func bar_background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.02, 0.022, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.25, 0.20, 0.12, 1.0)
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
	style.border_color = color.lightened(0.28)
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
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = alignment
	return label


static func style_button(button: Button, accent: Color = COLOR_BRASS) -> Button:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", COLOR_GOLD)
	button.add_theme_stylebox_override("normal", inset_style(accent.darkened(0.45)))
	button.add_theme_stylebox_override("hover", inset_style(accent.darkened(0.20)))
	button.add_theme_stylebox_override("pressed", inset_style(accent))
	button.add_theme_stylebox_override("disabled", inset_style(Color(0.12, 0.12, 0.12, 1.0)))
	return button


static func make_separator() -> HSeparator:
	var separator := HSeparator.new()
	separator.add_theme_constant_override("separation", 8)
	separator.modulate = COLOR_BRASS
	return separator
