extends SceneTree

## Validates FloatingCombatText shows the ACTUAL resolved combat amount — never baked sheet values.

const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var error := change_scene_to_file(ELDERWOOD)
	_expect(error == OK, "Elderwood loads for damage-number proof")
	if error != OK:
		_finish()
		return
	await scene_changed
	for _frame in range(4):
		await process_frame

	var enemy := get_first_node_in_group("enemies") as EnemyBase
	_expect(enemy != null, "Enemy target is present")
	if enemy == null:
		_finish()
		return

	var before := enemy.health
	enemy.take_damage(10, Vector2.ZERO, false)
	_expect(enemy.health == before - 10, "Enemy HP drops by exactly 10")
	var normal := _find_floating_with_amount(10)
	_expect(normal != null, "Floating text displays resolved amount 10")
	if normal != null:
		_expect(not bool(normal.get("is_critical")), "Normal hit is not marked critical")
		_expect(int(normal.get("amount")) == 10, "Amount property stores 10")
		var amount_label := normal.get_node_or_null("AmountLabel") as Label
		_expect(amount_label != null and amount_label.text == "10", "Label text is exactly '10'")
		_expect(normal.get_node_or_null("CritCallout") == null, "Normal hit has no CRIT! callout")

	before = enemy.health
	enemy.take_damage(12, Vector2.ZERO, false)
	_expect(enemy.health == before - 12, "Enemy HP drops by exactly 12")
	_expect(_find_floating_with_amount(12) != null, "Floating text displays resolved amount 12")

	before = enemy.health
	enemy.take_damage(18, Vector2.ZERO, true)
	_expect(enemy.health == before - 18, "Crit HP drop matches resolved 18")
	var crit := _find_floating_with_amount(18)
	_expect(crit != null, "Floating text displays resolved crit amount 18")
	if crit != null:
		_expect(bool(crit.get("is_critical")), "Crit hit is marked critical")
		var crit_label := crit.get_node_or_null("AmountLabel") as Label
		_expect(crit_label != null and crit_label.text == "18", "Crit label text is exactly '18' (no baked 2147)")
		_expect(crit.get_node_or_null("CritCallout") != null, "Crit callout CRIT! is present")
		_expect(not crit_label.text.contains("2147"), "Never displays baked example 2147")

	enemy.take_damage(7, Vector2.ZERO, false)
	enemy.take_damage(8, Vector2.ZERO, false)
	enemy.take_damage(9, Vector2.ZERO, false)
	await process_frame
	var live_count := get_nodes_in_group("floating_combat_text").size()
	_expect(live_count >= 3, "Multiple floating combat texts can coexist")

	for node: Node in get_nodes_in_group("floating_combat_text"):
		var label := node.get_node_or_null("AmountLabel") as Label
		if label == null:
			continue
		var shown := label.text
		var resolved := int(node.get("amount"))
		# Baked showcase examples must never appear unless combat actually produced them.
		if shown in ["70", "236", "796", "2147", "2147!"] and resolved not in [70, 236, 796, 2147]:
			_expect(false, "Baked example '%s' appeared without matching combat result" % shown)

	_expect(
		not ResourceLoader.exists("res://Project Chronicle/Assets/Showcase/Runtime/Combat/hit_burst.png"),
		"Baked hit_burst 2147 glyph is removed from runtime Combat pack"
	)
	_expect(
		not FileAccess.file_exists("res://Project Chronicle/Assets/Showcase/Runtime/Combat/hit_burst.png"),
		"Baked hit_burst 2147 glyph file is absent from runtime Combat pack"
	)

	_finish()


func _find_floating_with_amount(expected: int) -> Node:
	for node: Node in get_nodes_in_group("floating_combat_text"):
		if int(node.get("amount")) == expected:
			return node
	return null


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _finish() -> void:
	if _failures.is_empty():
		print("FLOATING COMBAT TEXT SMOKE: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("FLOATING COMBAT TEXT SMOKE: %s" % failure)
	quit(1)
