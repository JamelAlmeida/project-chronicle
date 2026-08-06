extends Node2D

const COMBAT_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"


func setup(text: String, kind: StringName = &"standard") -> void:
	var label := Label.new()
	label.text = text
	var combat_font := FontFile.new()
	combat_font.data = FileAccess.get_file_as_bytes(COMBAT_FONT_PATH)
	label.add_theme_font_override("font", combat_font)
	label.add_theme_color_override("font_color", _color_for_kind(kind))
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.014, 0.01, 0.98))
	label.add_theme_constant_override("outline_size", 6 if kind == &"critical" else 4)
	label.add_theme_font_size_override("font_size", 32 if kind == &"critical" else 23)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-64.0, -22.0)
	label.size = Vector2(128.0, 42.0)
	add_child(label)

	var travel := Vector2(randf_range(-12.0, 12.0), -48.0 if kind == &"critical" else -36.0)
	scale = Vector2(0.52, 0.52) if kind == &"critical" else Vector2(0.70, 0.70)
	rotation = randf_range(-0.04, 0.04)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + travel, 0.68)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08) if kind == &"critical" else Vector2.ONE, 0.12)
	tween.tween_property(label, "modulate:a", 0.0, 0.28).set_delay(0.38)
	tween.chain().tween_callback(queue_free)


func _color_for_kind(kind: StringName) -> Color:
	match kind:
		&"critical":
			# Luminous pale copper — Chronicle critical emphasis.
			return Color(1.0, 0.78, 0.42, 1.0)
		&"player":
			# Muted rose for damage taken.
			return Color(0.90, 0.46, 0.42, 1.0)
		_:
			# Warm ivory for ordinary hits.
			return Color(0.96, 0.90, 0.74, 1.0)
