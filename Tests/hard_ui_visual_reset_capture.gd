extends SceneTree

## Full-screen validation capture for the hard UI visual reset.
## Confirms legacy ornament HUD art is gone from active presentation.

const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"
const OUT_DIR := "res://ValidationCaptures/HardUiVisualReset/"

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

	var hud := current_scene.get_node("GameHUD")
	var menu := current_scene.get_node("EquipmentDebugPanel")
	_expect(hud != null, "HUD present")
	_expect(hud.has_node("TopLeft/ExpeditionPanel"), "New ExpeditionPanel present")
	_expect(hud.has_node("TopRight/QuestTracker"), "New QuestTracker present")
	_expect(hud.find_child("PlayerStatus", true, false) != null, "New PlayerStatus present")
	_expect(hud.find_child("ActionBarShell", true, false) != null, "New ActionBarShell present")
	_expect(hud.find_child("MenuButtons", true, false) != null, "New MenuButtons present")
	_expect(hud.find_child("ExperienceBar", true, false) != null, "New ExperienceBar present")
	_expect(hud.has_node("OverlayLayer"), "OverlayLayer present")
	_expect(hud.find_child("HudShell", true, false) == null, "Legacy HudShell removed")
	_expect(hud.find_child("StatusIsland", true, false) == null, "Legacy StatusIsland removed")
	_expect(hud.find_child("ActionIsland", true, false) == null, "Legacy ActionIsland removed")
	_expect(hud.find_child("MenuIsland", true, false) == null, "Legacy MenuIsland removed")
	_expect(hud.find_child("ExpeditionReadout", true, false) == null, "Legacy ExpeditionReadout removed")
	_expect(not ChronicleUITheme.USE_ORNAMENT_SKINS, "Ornament skins disabled")
	_expect(ChronicleUITheme.runtime_texture("bottom_hud.png") == null, "bottom_hud not live-loadable")
	_expect(ChronicleUITheme.runtime_texture("crest_ring.png") == null, "crest_ring not live-loadable")
	_expect(ChronicleUITheme.runtime_texture("panel_tracker_9.png") == null, "panel_tracker not live-loadable")
	_expect(menu.has_node("WindowLayer"), "WindowLayer present on menu")

	await _capture("01_hard_ui_reset_gameplay.png")

	menu.call("open_panel", &"character")
	await process_frame
	await process_frame
	_expect(menu.call("is_panel_open", &"character"), "Character window opens")
	await _capture("02_hard_ui_reset_character_window.png")
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
		print("HARD UI VISUAL RESET CAPTURE: PASS")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HARD UI VISUAL RESET CAPTURE: %s" % failure)
	quit(1)


func _inventory():
	return root.get_node("Inventory")


func _progression():
	return root.get_node("CharacterProgression")


func _techniques():
	return root.get_node("TechniqueManager")


func _quests():
	return root.get_node("QuestManager")
