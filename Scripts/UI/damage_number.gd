class_name FloatingCombatText
extends Node2D

## Runtime floating combat text. Displays ONLY the resolved combat amount passed in.
## Never invents damage values and never uses baked number sprites from art sheets.

enum DamageType {
	PHYSICAL,
	FIRE,
	FROST,
	ARCANE,
	POISON,
	BLEED,
	HEALING,
	SHIELD,
	LIFESTEAL,
	PLAYER_INCOMING,
}

const COMBAT_FONT_PATH := "res://Project Chronicle/Assets/Fonts/Cinzel-Variable.ttf"

## Soft stack offset so rapid multi-hits remain readable without sharing one Label.
static var _recent_spawn_slots: Array[Dictionary] = []
static var _font_cache: Font

@export var amount: int = 0
@export var is_critical: bool = false
@export var damage_type: DamageType = DamageType.PHYSICAL


func show_damage(
	resolved_amount: int,
	critical: bool = false,
	type: Variant = DamageType.PHYSICAL
) -> void:
	amount = resolved_amount
	is_critical = critical
	if typeof(type) == TYPE_INT:
		damage_type = type as DamageType
	elif typeof(type) == TYPE_NIL:
		damage_type = DamageType.PHYSICAL
	else:
		damage_type = type as DamageType
	_build_and_animate()


## Backward-compatible entry used by CombatFeedback.
func setup(text: String, kind: StringName = &"standard") -> void:
	var resolved := int(text) if text.is_valid_int() else 0
	# Strip legacy "!" suffixes if any caller still passes them.
	if text.ends_with("!") and text.substr(0, text.length() - 1).is_valid_int():
		resolved = int(text.substr(0, text.length() - 1))
	var critical := kind == &"critical"
	var type := DamageType.PHYSICAL
	match kind:
		&"critical":
			type = DamageType.PHYSICAL
			critical = true
		&"player":
			type = DamageType.PLAYER_INCOMING
		&"healing":
			type = DamageType.HEALING
		&"fire":
			type = DamageType.FIRE
		&"frost":
			type = DamageType.FROST
		&"arcane":
			type = DamageType.ARCANE
		&"poison":
			type = DamageType.POISON
		&"bleed":
			type = DamageType.BLEED
		&"shield":
			type = DamageType.SHIELD
		&"lifesteal":
			type = DamageType.LIFESTEAL
		_:
			type = DamageType.PHYSICAL
	show_damage(resolved, critical, type)


func _build_and_animate() -> void:
	add_to_group("floating_combat_text")
	# Authoritative display string — exactly the resolved integer, never sheet examples.
	var display_value := str(amount)

	var label := Label.new()
	label.name = "AmountLabel"
	label.text = display_value
	label.add_theme_font_override("font", _combat_font())
	label.add_theme_color_override("font_color", _color_for_type(damage_type, is_critical))
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.014, 0.01, 0.98))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	label.add_theme_constant_override("outline_size", 8 if is_critical else 5)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_font_size_override("font_size", 42 if is_critical else 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-96.0, -40.0)
	label.size = Vector2(192.0, 56.0)
	add_child(label)

	if is_critical:
		var crit := Label.new()
		crit.name = "CritCallout"
		crit.text = "CRIT!"
		crit.add_theme_font_override("font", _combat_font())
		crit.add_theme_color_override("font_color", Color(1.0, 0.74, 0.34, 1.0))
		crit.add_theme_color_override("font_outline_color", Color(0.02, 0.014, 0.01, 0.98))
		crit.add_theme_constant_override("outline_size", 5)
		crit.add_theme_font_size_override("font_size", 16)
		crit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		crit.position = Vector2(-64.0, 12.0)
		crit.size = Vector2(128.0, 22.0)
		add_child(crit)
		_spawn_crit_burst()

	var stack_offset := _consume_stack_offset()
	position += stack_offset

	var drift_x := randf_range(-14.0, 14.0)
	var travel := Vector2(drift_x, -78.0 if is_critical else -54.0)
	var lifetime := 0.92 if is_critical else 0.72
	scale = Vector2(0.38, 0.38) if is_critical else Vector2(0.62, 0.62)
	rotation = randf_range(-0.05, 0.05)
	z_index = 80

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK if is_critical else Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + travel, lifetime)
	tween.tween_property(
		self,
		"scale",
		Vector2(1.22, 1.22) if is_critical else Vector2(1.04, 1.04),
		0.12 if is_critical else 0.10
	)
	tween.tween_property(self, "modulate:a", 0.0, 0.34).set_delay(lifetime - 0.34)
	tween.chain().tween_callback(queue_free)


func _spawn_crit_burst() -> void:
	var burst := Polygon2D.new()
	burst.name = "CritBurst"
	burst.polygon = PackedVector2Array([
		Vector2(0, -10), Vector2(3, -3), Vector2(10, 0), Vector2(3, 3),
		Vector2(0, 10), Vector2(-3, 3), Vector2(-10, 0), Vector2(-3, -3),
	])
	burst.color = Color(1.0, 0.78, 0.36, 0.55)
	burst.z_index = -1
	add_child(burst)
	var burst_tween := burst.create_tween()
	burst_tween.set_parallel(true)
	burst_tween.tween_property(burst, "scale", Vector2(2.4, 2.4), 0.18)
	burst_tween.tween_property(burst, "modulate:a", 0.0, 0.18)
	burst_tween.chain().tween_callback(burst.queue_free)


func _consume_stack_offset() -> Vector2:
	var now_ms := Time.get_ticks_msec()
	# Drop stale slots older than a short window.
	var kept: Array[Dictionary] = []
	for slot: Dictionary in _recent_spawn_slots:
		if now_ms - int(slot.get("t", 0)) < 420:
			kept.append(slot)
	_recent_spawn_slots = kept

	var index := _recent_spawn_slots.size()
	var offset := Vector2(
		float((index % 3) - 1) * 18.0,
		float(-(index % 5)) * 16.0
	)
	_recent_spawn_slots.append({"t": now_ms, "o": offset})
	return offset


static func _combat_font() -> Font:
	if _font_cache != null:
		return _font_cache
	var base := FontFile.new()
	base.data = FileAccess.get_file_as_bytes(COMBAT_FONT_PATH)
	var variation := FontVariation.new()
	variation.base_font = base
	variation.variation_opentype = {0x77676874: 750}
	_font_cache = variation
	return _font_cache


static func _color_for_type(type: DamageType, critical: bool) -> Color:
	if critical and type == DamageType.PHYSICAL:
		# Luminous pale copper / warm-gold critical emphasis.
		return Color(1.0, 0.78, 0.36, 1.0)
	match type:
		DamageType.PLAYER_INCOMING:
			return Color(0.92, 0.48, 0.42, 1.0)
		DamageType.HEALING, DamageType.LIFESTEAL:
			return Color(0.55, 0.88, 0.58, 1.0)
		DamageType.FIRE:
			return Color(1.0, 0.55, 0.28, 1.0)
		DamageType.FROST:
			return Color(0.62, 0.82, 1.0, 1.0)
		DamageType.ARCANE:
			return Color(0.78, 0.62, 1.0, 1.0)
		DamageType.POISON:
			return Color(0.55, 0.86, 0.38, 1.0)
		DamageType.BLEED:
			return Color(0.86, 0.28, 0.32, 1.0)
		DamageType.SHIELD:
			return Color(0.72, 0.82, 0.92, 1.0)
		_:
			# Warm ivory ordinary physical hit.
			return Color(0.98, 0.92, 0.78, 1.0)
