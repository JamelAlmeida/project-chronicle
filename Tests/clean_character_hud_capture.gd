extends SceneTree

## Headless validation capture for the clean character + HUD pass.
## Writes PNGs under ValidationCaptures/CleanCharacterHud/.

const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"
const OUT_DIR := "res://ValidationCaptures/CleanCharacterHud/"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR.trim_suffix("/")))
	_inventory().clear()
	_progression().reset_progression()
	_techniques().reset_techniques()
	_quests().reset_quests()

	var error := change_scene_to_file(ELDERWOOD)
	_expect(error == OK, "Elderwood loads for capture")
	if error != OK:
		_finish()
		return
	await scene_changed
	await process_frame
	await process_frame
	await process_frame

	var player := get_first_node_in_group("player") as Node2D
	var hud := current_scene.get_node("GameHUD")
	var menu := current_scene.get_node("EquipmentDebugPanel")
	_expect(player != null, "Player present")
	_expect(hud != null, "HUD present")

	var sprite := player.get_node("Visuals/BaseCharacter") as AnimatedSprite2D
	_expect(sprite != null and sprite.visible, "Adventurer visible")
	_expect(not (player.get_node("Visuals/GroundShadow") as CanvasItem).visible, "GroundShadow disabled")
	_expect(not (player.get_node("MeleeAttack/AttackVisual") as CanvasItem).visible, "AttackVisual hidden")
	_expect(is_equal_approx(sprite.scale.x, 1.0), "Sprite scale 1.0")

	# Full HUD + player in scene.
	await _capture("01_full_hud_and_player.png")

	# Face left to confirm flip, then right again.
	var controller := player.get_node("Visuals/VisualController") as CharacterVisualController
	controller.update_presentation(false, false, false, false, Vector2.LEFT * 80.0, Vector2.LEFT, true)
	await process_frame
	await process_frame
	# Flip is validated by adventurer_sprite_smoke; capture documents the pose.
	await _capture("02_player_facing_left.png")
	controller.update_presentation(false, false, false, false, Vector2.ZERO, Vector2.RIGHT, true)
	await process_frame

	menu.call("open_panel", &"character")
	await process_frame
	await process_frame
	_expect(menu.call("is_panel_open", &"character"), "Character panel open for capture")
	await _capture("03_character_inventory_window.png")
	menu.call("open_panel", &"inventory")
	await process_frame
	await _capture("04_inventory_window.png")
	menu.call("close_panel")

	_finish()


func _capture(filename: String) -> void:
	await process_frame
	await process_frame
	var viewport := root.get_viewport()
	var image := viewport.get_texture().get_image()
	if image == null:
		_expect(false, "Capture failed for %s" % filename)
		return
	var path := OUT_DIR + filename
	var err := image.save_png(path)
	_expect(err == OK, "Saved %s" % path)
	print("CAPTURED: ", ProjectSettings.globalize_path(path))


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)


func _finish() -> void:
	if _failures.is_empty():
		print("CLEAN CHARACTER HUD CAPTURE: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CLEAN CHARACTER HUD CAPTURE: %s" % failure)
	quit(1)


func _inventory():
	return root.get_node("Inventory")


func _progression():
	return root.get_node("CharacterProgression")


func _techniques():
	return root.get_node("TechniqueManager")


func _quests():
	return root.get_node("QuestManager")
