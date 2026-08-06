extends Node2D

## Showcase Master Pack immersion — warm Hearthvale edge into Elderwood combat depth.
## Replaces flat placeholder dressing with approved modular environment crops.

const ENV_ROOT := "res://Project Chronicle/Assets/Showcase/Runtime/Environment/"

var _textures: Dictionary[String, Texture2D] = {}
var _time := 0.0
var _swaying: Array[Dictionary] = []
var _motes: Array[Dictionary] = []


func _ready() -> void:
	_load_textures()
	_tone_existing_scene()
	_hide_placeholder_landmarks()
	_build_sky_and_depth()
	_build_hearthvale_edge()
	_build_combat_lane()
	_build_elderwood_depth()
	_build_ground_dressing()
	_build_atmosphere()


func _process(delta: float) -> void:
	_time += delta
	for index in _swaying.size():
		var entry: Dictionary = _swaying[index]
		var node := entry["node"] as Node2D
		node.rotation = float(entry["base"]) + sin(_time * float(entry["speed"]) + index) * float(entry["amount"])
	for index in _motes.size():
		var entry: Dictionary = _motes[index]
		var mote := entry["node"] as CanvasItem
		var origin: Vector2 = entry["origin"]
		var phase: float = float(entry["phase"])
		mote.position = origin + Vector2(
			sin(_time * 0.55 + phase) * 16.0,
			sin(_time * 0.9 + phase * 1.4) * 6.0
		)
		mote.modulate.a = 0.35 + sin(_time * 1.6 + phase) * 0.18


func _load_textures() -> void:
	for texture_name in [
		"cottage_large", "cottage_medium", "roof_a", "roof_b", "chimney_a",
		"elderwood_sign", "banner_crest", "lantern_post", "fence_a", "fence_b",
		"barrels", "ground_long", "stone_wall", "stone_steps", "grass_tuft_a",
		"grass_tuft_b", "ground_strip",
		"tree_ancient", "forest_cluster_a", "forest_cluster_b", "platform_wide",
		"platform_ledge", "ruined_arch", "waystone", "lantern_ruin",
		"platform_corner", "platform_mid", "rock_cluster", "platform_low",
		"mushrooms", "bush_dark", "grass_dark_a", "grass_dark_b", "fireflies", "rubble",
	]:
		var path := "%s%s.png" % [ENV_ROOT, texture_name]
		if ResourceLoader.exists(path) or FileAccess.file_exists(path):
			_textures[texture_name] = _load_tex(path)


func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var image := Image.load_from_file(path)
	if image != null and not image.is_empty():
		return ImageTexture.create_from_image(image)
	return null


func _tex(name: String) -> Texture2D:
	return _textures.get(name) as Texture2D


func _tone_existing_scene() -> void:
	var zone := get_parent()
	var sky := zone.get_node_or_null("DistantBackground/Sky") as ColorRect
	if sky != null:
		# Warm golden-hour left into cooler forest depth.
		sky.color = Color(0.42, 0.28, 0.18, 1.0)
	var canopy := zone.get_node_or_null("DistantBackground/DistantCanopy") as Polygon2D
	if canopy != null:
		canopy.color = Color(0.06, 0.09, 0.07, 1.0)
	var depth := zone.get_node_or_null("MidBackground/ForestDepth") as Polygon2D
	if depth != null:
		depth.color = Color(0.04, 0.08, 0.06, 0.92)
	var ground := zone.get_node_or_null("GameplayLayer/Terrain/MainGround/Visual") as ColorRect
	if ground != null:
		ground.color = Color(0.12, 0.16, 0.10, 1.0)
	var topsoil := zone.get_node_or_null("GameplayLayer/Terrain/MainGround/Topsoil") as ColorRect
	if topsoil != null:
		topsoil.color = Color(0.28, 0.38, 0.16, 1.0)
	var mist := zone.get_node_or_null("AtmosphericOverlays/MistBand") as ColorRect
	if mist != null:
		mist.color = Color(0.55, 0.48, 0.32, 0.05)


func _hide_placeholder_landmarks() -> void:
	var zone := get_parent()
	for landmark_path in [
		"GameplayLayer/Landmarks/AncientTree",
		"GameplayLayer/Landmarks/RuinArch",
	]:
		var landmark := zone.get_node_or_null(landmark_path) as CanvasItem
		if landmark != null:
			landmark.visible = false
	var left_leaves := zone.get_node_or_null("ForegroundLayer/LeftLeaves") as Polygon2D
	if left_leaves != null:
		left_leaves.modulate = Color(0.55, 0.45, 0.28, 0.55)
	var right_leaves := zone.get_node_or_null("ForegroundLayer/RightLeaves") as Polygon2D
	if right_leaves != null:
		right_leaves.color = Color(0.02, 0.06, 0.04, 0.9)


func _build_sky_and_depth() -> void:
	var distant := Node2D.new()
	distant.name = "ShowcaseDistant"
	distant.z_index = -38
	add_child(distant)
	_place(distant, "forest_cluster_a", Vector2(980, 420), 0.55, Color(0.55, 0.58, 0.52, 0.85))
	_place(distant, "forest_cluster_b", Vector2(1680, 430), 0.62, Color(0.48, 0.52, 0.46, 0.9))

	var mid := Node2D.new()
	mid.name = "ShowcaseMid"
	mid.z_index = -18
	add_child(mid)
	_place(mid, "forest_cluster_a", Vector2(720, 480), 0.78, Color(0.72, 0.78, 0.68, 0.95))
	_place(mid, "forest_cluster_b", Vector2(1480, 470), 0.85, Color(0.65, 0.72, 0.62, 1.0))
	_place(mid, "tree_ancient", Vector2(1880, 520), 0.95, Color(0.85, 0.9, 0.82, 1.0))


func _build_hearthvale_edge() -> void:
	var town := Node2D.new()
	town.name = "HearthvaleEdge"
	town.z_index = -8
	add_child(town)
	_place(town, "cottage_large", Vector2(210, 430), 0.72, Color(1.05, 0.98, 0.88, 1.0))
	_place(town, "cottage_medium", Vector2(430, 500), 0.58, Color(1.0, 0.95, 0.86, 1.0))
	_place(town, "chimney_a", Vector2(280, 280), 0.45, Color(1.0, 1.0, 1.0, 0.95))
	# Lantern crop includes nearby fence pieces — still reads as warm town-edge light.
	_place(town, "lantern_post", Vector2(580, 500), 0.48, Color(1.12, 1.02, 0.82, 1.0))
	_place(town, "banner_crest", Vector2(120, 480), 0.4, Color(1.0, 1.0, 1.0, 0.95))
	_place(town, "fence_a", Vector2(480, 600), 0.5, Color(1.0, 0.96, 0.88, 1.0))
	_place(town, "barrels", Vector2(360, 600), 0.4, Color(1.0, 0.95, 0.88, 1.0))
	_place(town, "stone_steps", Vector2(700, 600), 0.45, Color(0.95, 0.98, 0.92, 1.0))
	_place(town, "stone_wall", Vector2(640, 590), 0.42, Color(0.95, 0.96, 0.9, 1.0))


func _build_combat_lane() -> void:
	var lane := Node2D.new()
	lane.name = "CombatLane"
	lane.z_index = -4
	add_child(lane)
	_place(lane, "platform_ledge", Vector2(900, 545), 0.62, Color(0.95, 1.0, 0.92, 1.0))
	_place(lane, "platform_mid", Vector2(1180, 575), 0.55, Color(0.92, 0.98, 0.9, 1.0))
	_place(lane, "platform_corner", Vector2(1420, 585), 0.5, Color(0.9, 0.96, 0.88, 1.0))
	_place(lane, "ruined_arch", Vector2(1240, 470), 0.58, Color(0.92, 0.95, 0.9, 1.0))
	_place(lane, "lantern_ruin", Vector2(1560, 530), 0.45, Color(1.15, 1.05, 0.8, 1.0))
	_place(lane, "rock_cluster", Vector2(980, 600), 0.4, Color(0.9, 0.92, 0.88, 1.0))
	_place(lane, "rubble", Vector2(1120, 610), 0.35, Color(0.9, 0.92, 0.88, 1.0))
	_place(lane, "mushrooms", Vector2(1340, 605), 0.45, Color.WHITE)


func _build_elderwood_depth() -> void:
	var deep := Node2D.new()
	deep.name = "ElderwoodDepth"
	deep.z_index = -2
	add_child(deep)
	_place(deep, "tree_ancient", Vector2(2080, 500), 1.05, Color(0.8, 0.88, 0.78, 1.0))
	_place(deep, "platform_low", Vector2(1900, 620), 0.55, Color(0.85, 0.9, 0.82, 1.0))
	_place(deep, "bush_dark", Vector2(1750, 600), 0.55, Color(0.9, 0.95, 0.88, 1.0))
	_place(deep, "mushrooms", Vector2(1820, 610), 0.5, Color(1.0, 1.0, 1.0, 1.0))
	var sway_tree := _place(deep, "tree_ancient", Vector2(2250, 490), 0.88, Color(0.75, 0.84, 0.72, 1.0))
	if sway_tree != null:
		_swaying.append({"node": sway_tree, "base": 0.0, "speed": 0.35, "amount": 0.012})


func _build_ground_dressing() -> void:
	var ground := Node2D.new()
	ground.name = "GroundDressing"
	ground.z_index = -1
	add_child(ground)
	_place(ground, "ground_long", Vector2(380, 640), 0.85, Color(1.05, 1.0, 0.9, 1.0))
	_place(ground, "ground_strip", Vector2(900, 650), 0.9, Color(0.95, 1.0, 0.9, 1.0))
	_place(ground, "ground_strip", Vector2(1400, 650), 0.9, Color(0.9, 0.96, 0.88, 1.0))
	_place(ground, "stone_wall", Vector2(720, 630), 0.55, Color(0.95, 0.96, 0.9, 1.0))
	for x in [200.0, 520.0, 880.0, 1200.0, 1600.0, 2000.0]:
		_place(ground, "grass_tuft_a" if int(x) % 400 < 200 else "grass_tuft_b", Vector2(x, 615), 0.55, Color.WHITE)
		_place(ground, "grass_dark_a" if int(x) % 300 < 150 else "grass_dark_b", Vector2(x + 60.0, 620), 0.5, Color.WHITE)


func _build_atmosphere() -> void:
	var atmo := Node2D.new()
	atmo.name = "ShowcaseAtmosphere"
	atmo.z_index = 12
	add_child(atmo)
	var fireflies := _place(atmo, "fireflies", Vector2(1300, 420), 0.7, Color(1.2, 1.1, 0.7, 0.85))
	if fireflies != null:
		_motes.append({"node": fireflies, "origin": fireflies.position, "phase": 0.4})
	var glow := _place(atmo, "fireflies", Vector2(560, 380), 0.45, Color(1.3, 1.05, 0.55, 0.55))
	if glow != null:
		_motes.append({"node": glow, "origin": glow.position, "phase": 1.7})


func _place(
	parent: Node2D,
	texture_name: String,
	pos: Vector2,
	scale_factor: float,
	modulate: Color
) -> Sprite2D:
	var texture := _tex(texture_name)
	if texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	sprite.position = pos
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.modulate = modulate
	parent.add_child(sprite)
	return sprite
