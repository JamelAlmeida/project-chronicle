class_name ChronicleUITheme
extends RefCounted

const BODY_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Alegreya-Variable.ttf"
const HEADING_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"
## Showcase Master Pack UI crops are preferred; ChronicleV2 remains the fallback kit.
const SHOWCASE_UI_ROOT := "res://Project Chronicle/Assets/Showcase/Runtime/UI/"
const UI_RUNTIME_ROOT := "res://Project Chronicle/Assets/UI/ChronicleV2/Runtime/"

const COLOR_INK := Color(0.028, 0.022, 0.016, 0.98)
const COLOR_PANEL := Color(0.048, 0.038, 0.028, 0.94)
const COLOR_INSET := Color(0.018, 0.014, 0.010, 0.96)
const COLOR_STONE := Color(0.075, 0.060, 0.045, 0.92)
const COLOR_BRASS := Color(0.62, 0.48, 0.26, 1.0)
const COLOR_BRASS_LIGHT := Color(0.88, 0.72, 0.40, 1.0)
const COLOR_GOLD := Color(0.96, 0.84, 0.48, 1.0)
const COLOR_TEXT := Color(0.97, 0.94, 0.86, 1.0)
const COLOR_MUTED := Color(0.72, 0.66, 0.56, 1.0)
const COLOR_HEALTH := Color(0.72, 0.14, 0.14, 1.0)
const COLOR_STEADFAST := Color(0.18, 0.44, 0.74, 1.0)
const COLOR_XP := Color(0.22, 0.50, 0.80, 1.0)
const COLOR_TECHNIQUE := Color(0.52, 0.36, 0.74, 1.0)
const COLOR_QUEST := Color(0.40, 0.58, 0.30, 1.0)
const COLOR_OUTLINE := Color(0.010, 0.008, 0.005, 0.92)

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
	# OpenType 'wght' axis — stronger presence without a second font file.
	variation.variation_opentype = {0x77676874: weight}
	return variation


static func runtime_texture(name: String) -> Texture2D:
	if _texture_cache.has(name):
		return _texture_cache[name] as Texture2D
	var tex := _load_texture_from_roots(name, [SHOWCASE_UI_ROOT, UI_RUNTIME_ROOT])
	if tex == null:
		return null
	_texture_cache[name] = tex
	return tex


static func showcase_texture(relative_path: String) -> Texture2D:
	## Load any Showcase runtime crop: "UI/foo.png", "Environment/bar.png", "Combat/baz.png".
	if _texture_cache.has(relative_path):
		return _texture_cache[relative_path] as Texture2D
	var path := "res://Project Chronicle/Assets/Showcase/Runtime/%s" % relative_path
	var tex := _load_texture_path(path)
	if tex == null:
		return null
	_texture_cache[relative_path] = tex
	return tex


static func _load_texture_from_roots(name: String, roots: Array) -> Texture2D:
	for root in roots:
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
	texture_name: String,
	margin: float = 24.0,
	content_margin: float = 12.0,
	stretch_mode: StyleBoxTexture.AxisStretchMode = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
) -> StyleBox:
	var tex := runtime_texture(texture_name)
	if tex == null:
		return null
	var style := StyleBoxTexture.new()
	style.texture = tex
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	style.content_margin_left = content_margin
	style.content_margin_top = content_margin
	style.content_margin_right = content_margin
	style.content_margin_bottom = content_margin
	style.axis_stretch_horizontal = stretch_mode
	style.axis_stretch_vertical = stretch_mode
	return style


static func panel_style(background: Color = COLOR_PANEL, border: Color = COLOR_BRASS) -> StyleBox:
	var textured := textured_style("panel_main_9.png", 36.0, 16.0)
	if textured == null:
		textured = textured_style("panel_compact_9.png", 28.0, 14.0)
	if textured != null:
		return textured
	return _flat_panel(background, border, 2, 12.0, 10.0, 7)


## Compact top trackers — quiet over the world.
static func hud_panel_style(background: Color = COLOR_PANEL, border: Color = COLOR_BRASS) -> StyleBox:
	var textured := textured_style("panel_tracker_9.png", 22.0, 10.0)
	if textured == null:
		textured = textured_style("panel_header_9.png", 20.0, 8.0)
	if textured != null:
		var tex_style := textured as StyleBoxTexture
		tex_style.content_margin_top = 8.0
		tex_style.content_margin_bottom = 8.0
		return tex_style
	return _flat_panel(background, border.lightened(0.08), 1, 10.0, 6.0, 3)


## Localized bottom-HUD island — translucent, restrained, not full-width.
static func hud_island_style() -> StyleBox:
	return _island_style_named("status_island_9.png", "panel_compact_9.png")


static func status_island_style() -> StyleBox:
	return _island_style_named("status_island_9.png", "panel_compact_9.png")


static func action_island_style() -> StyleBox:
	## Prefer compact modular chrome — the sheet's "action strip" includes baked slot cells.
	return _island_style_named("panel_compact_9.png", "panel_header_9.png")


static func menu_island_style() -> StyleBox:
	## Prefer modular chrome — sheet menu strip includes baked icon cells.
	return _island_style_named("panel_compact_9.png", "btn_chrome_9.png")


static func _island_style_named(primary: String, fallback: String) -> StyleBox:
	var textured := textured_style(primary, 22.0, 10.0)
	if textured == null:
		textured = textured_style(fallback, 22.0, 10.0)
	if textured != null:
		var tex_style := textured as StyleBoxTexture
		tex_style.texture_margin_top = 16.0
		tex_style.texture_margin_bottom = 16.0
		tex_style.content_margin_left = 12.0
		tex_style.content_margin_top = 8.0
		tex_style.content_margin_right = 12.0
		tex_style.content_margin_bottom = 8.0
		tex_style.modulate_color = Color(1.0, 1.0, 1.0, 0.96)
		return tex_style
	return _flat_panel(
		Color(0.045, 0.035, 0.025, 0.82),
		Color(0.55, 0.42, 0.22, 0.70),
		1,
		12.0,
		8.0,
		8
	)


## @deprecated Prefer hud_island_style() — kept for callers that still expect a bottom chrome helper.
static func bottom_hud_style() -> StyleBox:
	return hud_island_style()


static func inset_style(accent: Color = Color(0.22, 0.18, 0.14, 1.0)) -> StyleBox:
	var textured := textured_style("panel_inset.png", 22.0, 8.0)
	if textured == null:
		textured = textured_style("panel_section_9.png", 22.0, 8.0)
	if textured != null:
		return textured
	return _flat_panel(COLOR_INSET, accent, 1, 8.0, 6.0, 1)


## Ornate showcase action slot — selected frame when emphasized, empty frame otherwise.
static func action_slot_style(accent: Color, emphasized: bool = false) -> StyleBox:
	var tex_name := "slot_selected_9.png" if emphasized else "slot_empty_9.png"
	var textured := textured_style(tex_name, 14.0, 6.0)
	if textured == null:
		textured = textured_style("slot_square.png", 12.0, 5.0)
	if textured != null:
		var tex_style := textured as StyleBoxTexture
		if emphasized:
			tex_style.modulate_color = Color(1.06, 1.02, 0.94, 1.0).lerp(accent, 0.08)
		return tex_style
	var flat := StyleBoxFlat.new()
	flat.bg_color = Color(0.018, 0.014, 0.010, 0.78)
	var border_w := 2 if emphasized else 1
	flat.border_width_left = border_w
	flat.border_width_top = border_w
	flat.border_width_right = border_w
	flat.border_width_bottom = border_w
	if emphasized:
		flat.border_color = accent.lightened(0.22).lerp(COLOR_GOLD, 0.35)
	else:
		flat.border_color = Color(0.42, 0.34, 0.22, 0.55).lerp(accent, 0.18)
	flat.corner_radius_top_left = 3
	flat.corner_radius_top_right = 3
	flat.corner_radius_bottom_right = 3
	flat.corner_radius_bottom_left = 3
	flat.content_margin_left = 4.0
	flat.content_margin_top = 4.0
	flat.content_margin_right = 4.0
	flat.content_margin_bottom = 3.0
	flat.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	flat.shadow_size = 3
	flat.shadow_offset = Vector2(0.0, 1.0)
	return flat


static func equipment_slot_style() -> StyleBox:
	var tex := runtime_texture("equip_slot.png")
	if tex == null:
		tex = runtime_texture("equip_slot_sm.png")
	if tex != null:
		var style := StyleBoxTexture.new()
		style.texture = tex
		style.texture_margin_left = 18.0
		style.texture_margin_top = 18.0
		style.texture_margin_right = 18.0
		style.texture_margin_bottom = 18.0
		style.content_margin_left = 8.0
		style.content_margin_top = 8.0
		style.content_margin_right = 8.0
		style.content_margin_bottom = 8.0
		return style
	return action_slot_style(COLOR_BRASS)


static func section_style(accent: Color = COLOR_BRASS) -> StyleBox:
	var textured := textured_style("panel_section_9.png", 24.0, 10.0)
	if textured == null:
		textured = textured_style("panel_compact_9.png", 24.0, 10.0)
	if textured != null:
		return textured
	return _flat_panel(Color(0.03, 0.024, 0.018, 0.95), accent.darkened(0.1), 1, 8.0, 8.0, 0)


static func bar_background() -> StyleBox:
	var textured := textured_style("bar_empty_9.png", 8.0, 2.0)
	if textured == null:
		textured = textured_style("bar_thin_9.png", 6.0, 1.0)
	if textured != null:
		return textured
	return _flat_panel(Color(0.03, 0.024, 0.018, 1.0), Color(0.38, 0.28, 0.14, 1.0), 1, 0.0, 0.0, 0)


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
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.92))
	button.add_theme_color_override("font_pressed_color", COLOR_GOLD)
	button.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_override("font", body_font())
	button.add_theme_font_size_override("font_size", 13)
	var normal := textured_style("btn_chrome_9.png", 16.0, 8.0)
	if normal == null:
		normal = textured_style("char_btn.png", 18.0, 10.0)
	if normal == null:
		normal = inset_style(accent.darkened(0.42))
	var hover := normal.duplicate()
	if hover is StyleBoxTexture:
		(hover as StyleBoxTexture).modulate_color = Color(1.08, 1.05, 0.95, 1.0)
	var pressed := normal.duplicate()
	if pressed is StyleBoxTexture:
		(pressed as StyleBoxTexture).modulate_color = Color(0.92, 0.88, 0.78, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", inset_style(Color(0.12, 0.1, 0.08, 1.0)))
	return button


static func style_plus_button(button: Button) -> Button:
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.custom_minimum_size = Vector2(28.0, 28.0)
	button.expand_icon = true
	button.flat = true
	var plus := runtime_texture("btn_plus.png")
	if plus != null:
		button.icon = plus
		button.add_theme_constant_override("icon_max_width", 28)
	else:
		button.text = "+"
		style_button(button, Color(0.34, 0.50, 0.28))
	return button


static func make_separator() -> HSeparator:
	var separator := HSeparator.new()
	separator.add_theme_constant_override("separation", 8)
	separator.modulate = COLOR_BRASS_LIGHT
	var divider := runtime_texture("char_divider.png")
	if divider == null:
		divider = runtime_texture("divider_flourish.png")
	if divider != null:
		# Visual flourish via modulate only; keep native separator behavior.
		separator.modulate = Color(1.0, 0.92, 0.72, 0.85)
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
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	if shadow > 0:
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
		style.shadow_size = shadow
		style.shadow_offset = Vector2(0.0, 1.0)
	style.content_margin_left = content_h
	style.content_margin_top = content_v
	style.content_margin_right = content_h
	style.content_margin_bottom = content_v
	return style
