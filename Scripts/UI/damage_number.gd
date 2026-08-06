extends Node2D

const COMBAT_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"


func setup(text: String, kind: StringName = &"standard") -> void:
	var label := Label.new()
	label.text = text
	var combat_font := FontFile.new()
	combat_font.data = FileAccess.get_file_as_bytes(COMBAT_FONT_PATH)
	label.add_theme_font_override("font", combat_font)
	label.add_theme_color_override("font_color", _color_for_kind(kind))
	label.add_theme_color_override("font_outline_color", Color(0.025, 0.018, 0.014, 0.98))
	label.add_theme_constant_override("outline_size", 5 if kind == &"critical" else 4)
	label.add_theme_font_size_override("font_size", 30 if kind == &"critical" else 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-60.0, -20.0)
	label.size = Vector2(120.0, 40.0)
	add_child(label)

	var travel := Vector2(randf_range(-10.0, 10.0), -42.0 if kind == &"critical" else -32.0)
	scale = Vector2(0.58, 0.58) if kind == &"critical" else Vector2(0.76, 0.76)
	rotation = randf_range(-0.035, 0.035)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + travel, 0.64)
	tween.tween_property(self, "scale", Vector2.ONE, 0.13)
	tween.tween_property(label, "modulate:a", 0.0, 0.30).set_delay(0.36)
	tween.chain().tween_callback(queue_free)


func _color_for_kind(kind: StringName) -> Color:
	match kind:
		&"critical":
			return Color(1.0, 0.81, 0.47, 1.0)
		&"player":
			return Color(0.92, 0.48, 0.45, 1.0)
		_:
			return Color(0.93, 0.86, 0.69, 1.0)
