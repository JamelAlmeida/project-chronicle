extends Node2D

## Authored Elderwood immersion — dense ancient forest with warm entry into cool depth.

const ART_ROOT := "res://Project Chronicle/Assets/PixelArt/Environment/Elderwood/"

var _textures: Dictionary[String, Texture2D] = {}
var _time := 0.0
var _motes: Array[Dictionary] = []
var _leaves: Array[Dictionary] = []
var _swaying_props: Array[Dictionary] = []
var _mist_bands: Array[CanvasItem] = []
var _vine_sways: Array[Dictionary] = []


func _ready() -> void:
	_load_textures()
	_tone_existing_scene()
	_build_ground_treatment()
	_build_forest_depth()
	_build_authored_props()
	_build_platform_dressing()
	_build_atmosphere()


func _process(delta: float) -> void:
	_time += delta
	for index in _motes.size():
		var entry: Dictionary = _motes[index]
		var mote := entry["node"] as Polygon2D
		var origin: Vector2 = entry["origin"]
		var phase: float = float(entry["phase"])
		var cool: bool = bool(entry.get("cool", false))
		mote.position = origin + Vector2(
			sin(_time * 0.58 + phase) * (14.0 if cool else 20.0),
			sin(_time * 0.88 + phase * 1.6) * 7.0
		)
		mote.modulate.a = 0.28 + sin(_time * 1.7 + phase) * 0.16
	for index in _leaves.size():
		var entry: Dictionary = _leaves[index]
		var leaf := entry["node"] as Polygon2D
		var origin: Vector2 = entry["origin"]
		var phase := fmod(_time * float(entry["speed"]) + float(entry["phase"]), 1.0)
		leaf.position = origin + Vector2(phase * 230.0, sin(phase * TAU * 1.35 + index) * 24.0 + phase * 36.0)
		leaf.rotation = phase * TAU * 1.4
		leaf.modulate.a = sin(phase * PI) * 0.7
	for index in _swaying_props.size():
		var entry: Dictionary = _swaying_props[index]
		var prop := entry["node"] as Node2D
		prop.rotation = float(entry["base_rotation"]) + sin(_time * float(entry["speed"]) + index) * float(entry["amount"])
	for index in _vine_sways.size():
		var entry: Dictionary = _vine_sways[index]
		var vine := entry["node"] as Node2D
		vine.rotation = sin(_time * float(entry["speed"]) + float(entry["phase"])) * 0.045
	for index in _mist_bands.size():
		var mist := _mist_bands[index]
		mist.position.x = sin(_time * (0.09 + index * 0.03) + index) * (34.0 + index * 14.0)


func _load_textures() -> void:
	for texture_name in [
		"grass_fill", "worn_ground", "tree_ancient_a", "tree_ancient_b", "tree_ancient_c",
		"rock_large", "rock_medium", "rock_small", "bush_dark", "bush_flower",
		"grass_tuft", "flowers", "mushrooms", "fallen_log", "stump",
		"mossy_pillar", "ruined_arch", "carved_stone", "broken_wall_corner",
		"broken_wall_tall", "broken_wall_end", "waystone_fragment",
		"grass_a", "grass_b", "grass_dark", "grass_deep",
	]:
		_textures[texture_name] = load("%s%s.png" % [ART_ROOT, texture_name]) as Texture2D


func _tone_existing_scene() -> void:
	var zone := get_parent()
	var sky := zone.get_node_or_null("DistantBackground/Sky") as ColorRect
	if sky != null:
		sky.color = Color(0.14, 0.15, 0.16, 1.0)
	var canopy := zone.get_node_or_null("DistantBackground/DistantCanopy") as Polygon2D
	if canopy != null:
		canopy.color = Color(0.028, 0.07, 0.055, 1.0)
	var depth := zone.get_node_or_null("MidBackground/ForestDepth") as Polygon2D
	if depth != null:
		depth.color = Color(0.035, 0.10, 0.07, 0.96)
	var existing_mist := zone.get_node_or_null("AtmosphericOverlays/MistBand") as ColorRect
	if existing_mist != null:
		existing_mist.color = Color(0.48, 0.52, 0.42, 0.04)
	for landmark_path in [
		"GameplayLayer/Landmarks/AncientTree",
		"GameplayLayer/Landmarks/RuinArch",
	]:
		var landmark := zone.get_node_or_null(landmark_path) as CanvasItem
		if landmark != null:
			landmark.visible = false
	var left_leaves := zone.get_node_or_null("ForegroundLayer/LeftLeaves") as Polygon2D
	if left_leaves != null:
		left_leaves.color = Color(0.025, 0.07, 0.045, 0.88)
	var right_leaves := zone.get_node_or_null("ForegroundLayer/RightLeaves") as Polygon2D
	if right_leaves != null:
		right_leaves.color = Color(0.025, 0.07, 0.045, 0.88)


func _build_ground_treatment() -> void:
	var ground_visual := get_parent().get_node_or_null("GameplayLayer/Terrain/MainGround/Visual") as CanvasItem
	if ground_visual != null:
		ground_visual.visible = false
	var topsoil := get_parent().get_node_or_null("GameplayLayer/Terrain/MainGround/Topsoil") as ColorRect
	if topsoil != null:
		topsoil.color = Color(0.20, 0.32, 0.13, 1.0)
	var layer := Node2D.new()
	layer.name = "ElderwoodGroundArt"
	layer.z_index = -3
	add_child(layer)
	var soil := ColorRect.new()
	soil.position = Vector2(0, 618)
	soil.size = Vector2(2400, 110)
	soil.color = Color(0.06, 0.10, 0.065, 1.0)
	soil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(soil)
	_add_tiled_rect(layer, _textures["grass_fill"], Rect2(0, 606, 2400, 48), Color(0.62, 0.76, 0.52, 1.0))
	# Warm trail near Hearthvale entry, cooler worn paths deeper in.
	for rect in [
		Rect2(40, 604, 360, 30),
	]:
		_add_tiled_rect(layer, _textures["worn_ground"], rect, Color(0.78, 0.68, 0.48, 0.72))
	for rect in [
		Rect2(520, 606, 290, 28), Rect2(1090, 606, 300, 28), Rect2(1850, 606, 285, 28),
	]:
		_add_tiled_rect(layer, _textures["worn_ground"], rect, Color(0.58, 0.55, 0.42, 0.58))
	# Moss patches and exposed roots for ground storytelling.
	for patch in [
		[Vector2(640, 612), 48.0], [Vector2(980, 614), 36.0], [Vector2(1520, 610), 52.0],
		[Vector2(1960, 613), 40.0], [Vector2(2200, 611), 44.0],
	]:
		_add_polygon(layer, PackedVector2Array([
			patch[0] + Vector2(-float(patch[1]), 0),
			patch[0] + Vector2(-float(patch[1]) * 0.4, -8),
			patch[0] + Vector2(float(patch[1]) * 0.5, -6),
			patch[0] + Vector2(float(patch[1]), 2),
			patch[0] + Vector2(0, 6),
		]), Color(0.18, 0.32, 0.14, 0.72))
	for root in [
		PackedVector2Array([Vector2(300, 618), Vector2(360, 608), Vector2(430, 616), Vector2(480, 610)]),
		PackedVector2Array([Vector2(1180, 616), Vector2(1260, 606), Vector2(1340, 614), Vector2(1420, 608)]),
		PackedVector2Array([Vector2(1720, 618), Vector2(1800, 605), Vector2(1880, 614)]),
	]:
		var line := Line2D.new()
		line.points = root
		line.width = 5.0
		line.default_color = Color(0.18, 0.10, 0.05, 0.78)
		layer.add_child(line)
	for path in [
		"GameplayLayer/Terrain/EntryRise/Visual",
		"GameplayLayer/Terrain/OptionalRoute/LowerOneWay/Visual",
		"GameplayLayer/Terrain/OptionalRoute/MiddleOneWay/Visual",
		"GameplayLayer/Terrain/OptionalRoute/HighOneWay/Visual",
		"GameplayLayer/Terrain/RootBridge/Visual",
	]:
		var platform := get_parent().get_node_or_null(path) as ColorRect
		if platform != null:
			if path.ends_with("RootBridge/Visual"):
				platform.color = Color(0.24, 0.15, 0.08, 1.0)
			else:
				platform.color = Color(0.22, 0.30, 0.12, 1.0)


func _build_forest_depth() -> void:
	var distant := Node2D.new()
	distant.name = "LayeredForestSilhouettes"
	distant.z_index = -32
	add_child(distant)
	# Dense canopy crowns — fill empty sky.
	for entry in [
		[Vector2(-100, 95), Vector2(3.4, 1.45)],
		[Vector2(220, 70), Vector2(3.9, 1.65)],
		[Vector2(560, 105), Vector2(3.3, 1.38)],
		[Vector2(900, 68), Vector2(4.0, 1.7)],
		[Vector2(1280, 90), Vector2(3.6, 1.5)],
		[Vector2(1640, 62), Vector2(4.1, 1.72)],
		[Vector2(2020, 88), Vector2(3.7, 1.48)],
		[Vector2(2360, 70), Vector2(3.9, 1.6)],
		[Vector2(2620, 100), Vector2(3.2, 1.35)],
	]:
		var crown := Polygon2D.new()
		crown.position = entry[0]
		crown.polygon = _circle_points(16, 70.0)
		crown.scale = entry[1]
		crown.color = Color(0.018, 0.052, 0.042, 0.98)
		distant.add_child(crown)
	for branch_y in [160.0, 230.0, 295.0]:
		var branch := Line2D.new()
		branch.points = PackedVector2Array([
			Vector2(-140, branch_y), Vector2(380, branch_y + 28),
			Vector2(860, branch_y - 10), Vector2(1380, branch_y + 24),
			Vector2(1900, branch_y - 6), Vector2(2480, branch_y + 20),
		])
		branch.width = 20.0 if branch_y < 200.0 else (14.0 if branch_y < 260.0 else 9.0)
		branch.default_color = Color(0.02, 0.055, 0.042, 0.88)
		distant.add_child(branch)
	for entry in [
		["tree_ancient_c", Vector2(-90, 635), 2.85],
		["tree_ancient_a", Vector2(210, 640), 2.55],
		["tree_ancient_b", Vector2(540, 638), 2.95],
		["tree_ancient_c", Vector2(880, 640), 2.65],
		["tree_ancient_a", Vector2(1220, 638), 3.00],
		["tree_ancient_b", Vector2(1580, 640), 2.70],
		["tree_ancient_c", Vector2(1920, 638), 2.90],
		["tree_ancient_a", Vector2(2260, 640), 2.75],
		["tree_ancient_b", Vector2(2520, 638), 2.60],
	]:
		_add_sprite(
			distant,
			str(entry[0]),
			entry[1],
			float(entry[2]),
			Color(0.10, 0.22, 0.17, 0.62)
		)

	var middle := Node2D.new()
	middle.name = "ElderwoodMiddleGrowth"
	middle.z_index = -5
	add_child(middle)
	for entry in [
		["tree_ancient_a", Vector2(95, 620), 1.85],
		["tree_ancient_b", Vector2(360, 620), 2.05],
		["tree_ancient_c", Vector2(680, 620), 1.70],
		["tree_ancient_a", Vector2(980, 620), 1.95],
		["tree_ancient_b", Vector2(1380, 620), 2.15],
		["tree_ancient_c", Vector2(1720, 620), 1.90],
		["tree_ancient_a", Vector2(2050, 620), 2.10],
		["tree_ancient_b", Vector2(2340, 620), 1.95],
	]:
		var tree := _add_sprite(middle, str(entry[0]), entry[1], float(entry[2]), Color(0.70, 0.82, 0.64, 1.0))
		if tree != null:
			_swaying_props.append({"node": tree, "base_rotation": 0.0, "speed": randf_range(0.38, 0.58), "amount": 0.007})


func _build_authored_props() -> void:
	var props := Node2D.new()
	props.name = "ElderwoodAuthoredProps"
	props.z_index = -2
	add_child(props)
	# Entry cluster — warmer, inviting.
	for entry in [
		["waystone_fragment", Vector2(175, 620), 1.45],
		["rock_medium", Vector2(255, 620), 1.30],
		["bush_flower", Vector2(330, 620), 1.35],
		["flowers", Vector2(400, 620), 1.20],
		["grass_tuft", Vector2(455, 620), 1.25],
		["mushrooms", Vector2(530, 620), 1.25],
		["grass_a", Vector2(600, 620), 1.15],
	]:
		_add_sprite(props, str(entry[0]), entry[1], float(entry[2]), Color(0.95, 0.94, 0.82, 1.0))
	# Mid trail — denser authored clutter with clear combat lanes.
	for entry in [
		["fallen_log", Vector2(820, 620), 1.25],
		["bush_dark", Vector2(920, 620), 1.30],
		["rock_small", Vector2(1000, 620), 1.20],
		["mushrooms", Vector2(1075, 620), 1.30],
		["stump", Vector2(1480, 620), 1.25],
		["bush_flower", Vector2(1560, 620), 1.20],
		["grass_dark", Vector2(1630, 620), 1.25],
		["rock_large", Vector2(1780, 620), 1.20],
	]:
		_add_sprite(props, str(entry[0]), entry[1], float(entry[2]), Color(0.86, 0.90, 0.78, 1.0))
	# Deep forest — cooler, moodier.
	for entry in [
		["bush_dark", Vector2(1980, 620), 1.45],
		["mushrooms", Vector2(2080, 620), 1.35],
		["grass_deep", Vector2(2140, 620), 1.30],
		["rock_medium", Vector2(2280, 620), 1.25],
		["grass_tuft", Vector2(2360, 620), 1.20],
	]:
		_add_sprite(props, str(entry[0]), entry[1], float(entry[2]), Color(0.72, 0.80, 0.70, 1.0))

	var ruins := Node2D.new()
	ruins.name = "ForgottenWayside"
	ruins.z_index = -3
	add_child(ruins)
	for entry in [
		["broken_wall_corner", Vector2(1140, 620), 1.50],
		["mossy_pillar", Vector2(1255, 620), 1.55],
		["broken_wall_tall", Vector2(1335, 620), 1.40],
		["broken_wall_end", Vector2(1410, 620), 1.35],
		["carved_stone", Vector2(2040, 620), 1.30],
		["ruined_arch", Vector2(2175, 620), 1.70],
	]:
		_add_sprite(ruins, str(entry[0]), entry[1], float(entry[2]), Color(0.62, 0.70, 0.60, 1.0))

	# Hanging vine accents from canopy into play space (non-blocking).
	for vine_x in [480.0, 1120.0, 1680.0, 2100.0]:
		var vine := Node2D.new()
		vine.position = Vector2(vine_x, 220)
		ruins.add_child(vine)
		var strand := Line2D.new()
		strand.points = PackedVector2Array([
			Vector2(0, 0), Vector2(8, 40), Vector2(-4, 85), Vector2(6, 130), Vector2(0, 170),
		])
		strand.width = 2.5
		strand.default_color = Color(0.16, 0.28, 0.14, 0.55)
		vine.add_child(strand)
		_vine_sways.append({"node": vine, "speed": randf_range(0.5, 0.8), "phase": vine_x * 0.01})

	var foreground := Node2D.new()
	foreground.name = "ElderwoodForegroundFraming"
	foreground.z_index = 24
	add_child(foreground)
	_add_sprite(foreground, "bush_dark", Vector2(10, 685), 2.55, Color(0.14, 0.28, 0.18, 0.88))
	_add_sprite(foreground, "bush_dark", Vector2(85, 698), 1.85, Color(0.12, 0.24, 0.16, 0.76))
	_add_sprite(foreground, "grass_tuft", Vector2(160, 705), 1.6, Color(0.14, 0.26, 0.16, 0.7))
	_add_sprite(foreground, "grass_tuft", Vector2(2360, 685), 2.55, Color(0.14, 0.26, 0.17, 0.88))
	_add_sprite(foreground, "bush_dark", Vector2(2280, 698), 1.9, Color(0.12, 0.22, 0.15, 0.74))
	_add_sprite(foreground, "grass_deep", Vector2(2200, 708), 1.7, Color(0.12, 0.24, 0.15, 0.68))


func _build_platform_dressing() -> void:
	var dressing := Node2D.new()
	dressing.name = "PlatformDressing"
	dressing.z_index = -1
	add_child(dressing)
	for entry in [
		["grass_tuft", Vector2(430, 578), 0.95],
		["mushrooms", Vector2(510, 578), 0.90],
		["grass_a", Vector2(920, 548), 0.90],
		["flowers", Vector2(1040, 548), 0.85],
		["grass_tuft", Vector2(1160, 493), 0.85],
		["mushrooms", Vector2(1380, 443), 0.90],
		["grass_dark", Vector2(1640, 518), 0.95],
	]:
		_add_sprite(dressing, str(entry[0]), entry[1], float(entry[2]), Color(0.88, 0.92, 0.78, 0.95))


func _build_atmosphere() -> void:
	var atmosphere := Node2D.new()
	atmosphere.name = "ElderwoodAmbientLife"
	atmosphere.z_index = 14
	add_child(atmosphere)
	_build_light_gradient(atmosphere)
	# Warm golden motes near entry.
	for index in range(16):
		var mote := Polygon2D.new()
		mote.polygon = _circle_points(7, 1.5 if index % 3 else 2.4)
		mote.color = Color(0.92, 0.78, 0.38, 0.78)
		var origin := Vector2(60.0 + fmod(float(index * 97), 780.0), 260.0 + fmod(float(index * 61), 260.0))
		mote.position = origin
		atmosphere.add_child(mote)
		_motes.append({"node": mote, "origin": origin, "phase": float(index) * 0.7, "cool": false})
	# Cooler firefly/spore motes in the deep wood.
	for index in range(18):
		var mote := Polygon2D.new()
		mote.polygon = _circle_points(6, 1.3 if index % 2 else 2.0)
		mote.color = Color(0.55, 0.78, 0.62, 0.7) if index % 3 else Color(0.72, 0.86, 0.58, 0.75)
		var origin := Vector2(980.0 + fmod(float(index * 113), 1320.0), 240.0 + fmod(float(index * 67), 300.0))
		mote.position = origin
		atmosphere.add_child(mote)
		_motes.append({"node": mote, "origin": origin, "phase": float(index) * 0.85 + 2.0, "cool": true})
	for index in range(14):
		var leaf := Polygon2D.new()
		leaf.polygon = PackedVector2Array([
			Vector2(-5, 0), Vector2(0, -2.5), Vector2(6, 0), Vector2(0, 2.5),
		])
		leaf.color = Color(0.42, 0.48, 0.22, 0.75) if index > 6 else Color(0.58, 0.48, 0.20, 0.78)
		var origin := Vector2(-140.0 + float(index % 5) * 520.0, 190.0 + float(index % 4) * 85.0)
		atmosphere.add_child(leaf)
		_leaves.append({
			"node": leaf,
			"origin": origin,
			"phase": float(index % 6) * 0.16,
			"speed": 0.048 + float(index % 5) * 0.008,
		})
	for index in range(4):
		var mist := ColorRect.new()
		mist.position = Vector2(-140, 490 + index * 26)
		mist.size = Vector2(2680, 36 + index * 12)
		mist.color = Color(0.52, 0.55, 0.42, 0.025 + index * 0.008)
		mist.mouse_filter = Control.MOUSE_FILTER_IGNORE
		atmosphere.add_child(mist)
		atmosphere.move_child(mist, 0)
		_mist_bands.append(mist)


func _build_light_gradient(parent: Node) -> void:
	var light := Node2D.new()
	light.name = "RegionalLight"
	light.z_index = -12
	parent.add_child(light)
	# Warm entry wash from Hearthvale side.
	var wash := Polygon2D.new()
	wash.polygon = PackedVector2Array([
		Vector2(-100, 30), Vector2(860, 70), Vector2(720, 640), Vector2(-100, 640),
	])
	wash.color = Color(0.94, 0.66, 0.26, 0.09)
	light.add_child(wash)
	for index in range(5):
		var shaft := Polygon2D.new()
		var x := 70.0 + float(index) * 145.0
		shaft.polygon = PackedVector2Array([
			Vector2(x, 15), Vector2(x + 34, 15),
			Vector2(x + 115 + index * 16.0, 620), Vector2(x + 42 + index * 9.0, 620),
		])
		shaft.color = Color(0.96, 0.78, 0.36, 0.04 + float(index % 2) * 0.012)
		light.add_child(shaft)
	# Cool melancholy shade through the deep wood.
	var shade := Polygon2D.new()
	shade.polygon = PackedVector2Array([
		Vector2(980, 50), Vector2(2520, 30), Vector2(2520, 640), Vector2(860, 640),
	])
	shade.color = Color(0.03, 0.07, 0.10, 0.16)
	light.add_child(shade)
	# Soft blue-green shafts in ruins area.
	for index in range(3):
		var cool_shaft := Polygon2D.new()
		var x := 1180.0 + float(index) * 180.0
		cool_shaft.polygon = PackedVector2Array([
			Vector2(x, 40), Vector2(x + 28, 40),
			Vector2(x + 90, 620), Vector2(x + 35, 620),
		])
		cool_shaft.color = Color(0.42, 0.62, 0.58, 0.035)
		light.add_child(cool_shaft)


func _add_tiled_rect(
	parent: Node,
	texture: Texture2D,
	rect: Rect2,
	tint: Color
) -> TextureRect:
	if texture == null:
		return null
	var visual := TextureRect.new()
	visual.texture = texture
	visual.position = rect.position
	visual.size = rect.size
	visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	visual.stretch_mode = TextureRect.STRETCH_TILE
	visual.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.modulate = tint
	parent.add_child(visual)
	return visual


func _add_sprite(
	parent: Node,
	texture_name: String,
	world_position: Vector2,
	uniform_scale: float,
	tint: Color
) -> Sprite2D:
	var texture: Texture2D = _textures.get(texture_name)
	if texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.name = StringName("Art_%s" % texture_name)
	sprite.texture = texture
	sprite.position = world_position
	sprite.offset.y = -float(texture.get_height()) * 0.5
	sprite.scale = Vector2.ONE * uniform_scale
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = tint
	parent.add_child(sprite)
	return sprite


func _add_polygon(parent: Node, points: PackedVector2Array, color: Color) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.polygon = points
	polygon.color = color
	parent.add_child(polygon)
	return polygon


func _circle_points(segments: int, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
