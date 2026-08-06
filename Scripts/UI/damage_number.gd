extends Node2D

## Showcase-ready floating combat text — large MMO/action-RPG presence.
## Uses Chronicle warm gold / ember / ivory (not MapleStory number colors).

const COMBAT_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"


func setup(text: String, kind: StringName = &"standard") -> void:
	var is_crit := kind == &"critical"
	var display := text
	if is_crit and not text.ends_with("!"):
		display = "%s!" % text

	var label := Label.new()
	label.text = display
	var combat_font := FontFile.new()
	combat_font.data = FileAccess.get_file_as_bytes(COMBAT_FONT_PATH)
	var variation := FontVariation.new()
	variation.base_font = combat_font
	variation.variation_opentype = {0x77676874: 750}
	label.add_theme_font_override("font", variation)
	label.add_theme_color_override("font_color", _color_for_kind(kind))
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.014, 0.01, 0.98))
	label.add_theme_constant_override("outline_size", 8 if is_crit else 5)
	label.add_theme_font_size_override("font_size", 44 if is_crit else 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-96.0, -36.0)
	label.size = Vector2(192.0, 56.0)
	add_child(label)

	if is_crit:
		var crit := Label.new()
		crit.text = "CRIT!"
		crit.add_theme_font_override("font", variation)
		crit.add_theme_color_override("font_color", Color(1.0, 0.72, 0.32, 1.0))
		crit.add_theme_color_override("font_outline_color", Color(0.02, 0.014, 0.01, 0.98))
		crit.add_theme_constant_override("outline_size", 5)
		crit.add_theme_font_size_override("font_size", 18)
		crit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		crit.position = Vector2(-64.0, 14.0)
		crit.size = Vector2(128.0, 24.0)
		add_child(crit)

	var travel := Vector2(randf_range(-18.0, 18.0), -72.0 if is_crit else -52.0)
	scale = Vector2(0.42, 0.42) if is_crit else Vector2(0.58, 0.58)
	rotation = randf_range(-0.06, 0.06)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK if is_crit else Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + travel, 0.78 if is_crit else 0.68)
	tween.tween_property(self, "scale", Vector2(1.18, 1.18) if is_crit else Vector2(1.05, 1.05), 0.14)
	tween.tween_property(self, "modulate:a", 0.0, 0.32).set_delay(0.42)
	tween.chain().tween_callback(queue_free)


func _color_for_kind(kind: StringName) -> Color:
	match kind:
		&"critical":
			# Warm copper-gold critical emphasis.
			return Color(1.0, 0.78, 0.36, 1.0)
		&"player":
			# Muted rose for damage taken.
			return Color(0.92, 0.48, 0.42, 1.0)
		_:
			# Warm ivory for ordinary hits.
			return Color(0.98, 0.92, 0.78, 1.0)
