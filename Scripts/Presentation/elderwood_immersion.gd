extends Node2D

const ART_ROOT := "res://Project Chronicle/Assets/PixelArt/Environment/Elderwood/"

var _textures: Dictionary[String, Texture2D] = {}
var _time := 0.0
var _motes: Array[Dictionary] = []
var _leaves: Array[Dictionary] = []
var _swaying_props: Array[Dictionary] = []
var _mist_bands: Array[CanvasItem] = []


func _ready() -> void:
	_load_textures()
	_tone_existing_scene()
	_build_ground_treatment()
	_build_forest_depth()
	_build_authored_props()
	_build_atmosphere()


func _process(delta: float) -> void:
	_time += delta
	for index in _motes.size():
		var entry: Dictionary = _motes[index]
		var mote := entry["node"] as Polygon2D
		var origin: Vector2 = entry["origin"]
		var phase: float = float(entry["phase"])
		mote.position = origin + Vector2(
			sin(_time * 0.65 + phase) * 18.0,
			sin(_time * 0.92 + phase * 1.7) * 7.0
		)
		mote.modulate.a = 0.34 + sin(_time * 1.8 + phase) * 0.18
	for index in _leaves.size():
		var entry: Dictionary = _leaves[index]
		var leaf := entry["node"] as Polygon2D
		var origin: Vector2 = entry["origin"]
		var phase := fmod(_time * float(entry["speed"]) + float(entry["phase"]), 1.0)
		leaf.position = origin + Vector2(phase * 210.0, sin(phase * TAU * 1.4 + index) * 22.0 + phase * 32.0)
		leaf.rotation = phase * TAU * 1.5
		leaf.modulate.a = sin(phase * PI) * 0.72
	for index in _swaying_props.size():
		var entry: Dictionary = _swaying_props[index]
		var prop := entry["node"] as Node2D
		prop.rotation = float(entry["base_rotation"]) + sin(_time * float(entry["speed"]) + index) * float(entry["amount"])
	for index in _mist_bands.size():
		var mist := _mist_bands[index]
		mist.position.x = sin(_time * (0.10 + index * 0.035) + index) * (30.0 + index * 12.0)


func _load_textures() -> void:
	for texture_name in [
		"grass_fill", "worn_ground", "tree_ancient_a", "tree_ancient_b", "tree_ancient_c",
		"rock_large", "rock_medium", "rock_small", "bush_dark", "bush_flower",
		"grass_tuft", "flowers", "mushrooms", "fallen_log", "stump",
		"mossy_pillar", "ruined_arch", "carved_stone", "broken_wall_corner",
		"broken_wall_tall", "broken_wall_end", "waystone_fragment",
	]:
		_textures[texture_name] = load("%s%s.png" % [ART_ROOT, texture_name]) as Texture2D


func _tone_existing_scene() -> void:
	var zone := get_parent()
	var sky := zone.get_node_or_null("DistantBackground/Sky") as ColorRect
	if sky != null:
		sky.color = Color(0.055, 0.105, 0.12, 1.0)
	var canopy := zone.get_node_or_null("DistantBackground/DistantCanopy") as Polygon2D
	if canopy != null:
		canopy.color = Color(0.035, 0.082, 0.073, 1.0)
	var depth := zone.get_node_or_null("MidBackground/ForestDepth") as Polygon2D
	if depth != null:
		depth.color = Color(0.038, 0.105, 0.071, 0.92)
	var existing_mist := zone.get_node_or_null("AtmosphericOverlays/MistBand") as ColorRect
	if existing_mist != null:
		existing_mist.color = Color(0.42, 0.56, 0.48, 0.028)
	for landmark_path in [
		"GameplayLayer/Landmarks/AncientTree",
		"GameplayLayer/Landmarks/RuinArch",
	]:
		var landmark := zone.get_node_or_null(landmark_path) as CanvasItem
		if landmark != null:
			landmark.visible = false


func _build_ground_treatment() -> void:
	var ground_visual := get_parent().get_node_or_null("GameplayLayer/Terrain/MainGround/Visual") as CanvasItem
	if ground_visual != null:
		ground_visual.visible = false
	var topsoil := get_parent().get_node_or_null("GameplayLayer/Terrain/MainGround/Topsoil") as ColorRect
	if topsoil != null:
		topsoil.color = Color(0.23, 0.34, 0.14, 1.0)
	var layer := Node2D.new()
	layer.name = "ElderwoodGroundArt"
	layer.z_index = -3
	add_child(layer)
	var soil := ColorRect.new()
	soil.position = Vector2(0, 620)
	soil.size = Vector2(2400, 100)
	soil.color = Color(0.075, 0.115, 0.07, 1.0)
	soil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(soil)
	_add_tiled_rect(layer, _textures["grass_fill"], Rect2(0, 610, 2400, 42), Color(0.66, 0.78, 0.58, 1.0))
	for rect in [
		Rect2(520, 608, 290, 28), Rect2(1090, 608, 300, 28), Rect2(1850, 608, 285, 28),
	]:
		_add_tiled_rect(layer, _textures["worn_ground"], rect, Color(0.72, 0.66, 0.52, 0.68))
	for path in [
		"GameplayLayer/Terrain/EntryRise/Visual",
		"GameplayLayer/Terrain/OptionalRoute/LowerOneWay/Visual",
		"GameplayLayer/Terrain/OptionalRoute/MiddleOneWay/Visual",
		"GameplayLayer/Terrain/OptionalRoute/HighOneWay/Visual",
	]:
		var platform := get_parent().get_node_or_null(path) as ColorRect
		if platform != null:
			platform.color = Color(0.24, 0.31, 0.13, 1.0)


func _build_forest_depth() -> void:
	var distant := Node2D.new()
	distant.name = "LayeredForestSilhouettes"
	distant.z_index = -32
	add_child(distant)
	for entry in [
		[Vector2(-80, 90), Vector2(2.8, 1.15)],
		[Vector2(300, 70), Vector2(3.4, 1.35)],
		[Vector2(760, 105), Vector2(3.0, 1.2)],
		[Vector2(1190, 68), Vector2(3.5, 1.4)],
		[Vector2(1650, 92), Vector2(3.25, 1.25)],
		[Vector2(2110, 62), Vector2(3.6, 1.35)],
		[Vector2(2480, 100), Vector2(2.8, 1.2)],
	]:
		var crown := Polygon2D.new()
		crown.position = entry[0]
		crown.polygon = _circle_points(18, 74.0)
		crown.scale = entry[1]
		crown.color = Color(0.022, 0.061, 0.050, 0.96)
		distant.add_child(crown)
	for branch_y in [150.0, 225.0]:
		var branch := Line2D.new()
		branch.points = PackedVector2Array([
			Vector2(-120, branch_y), Vector2(420, branch_y + 34),
			Vector2(920, branch_y - 8), Vector2(1430, branch_y + 28),
			Vector2(1980, branch_y - 4), Vector2(2520, branch_y + 22),
		])
		branch.width = 18.0 if branch_y < 200.0 else 11.0
		branch.default_color = Color(0.025, 0.064, 0.050, 0.86)
		distant.add_child(branch)
	for entry in [
		["tree_ancient_c", Vector2(-80, 635), 2.45],
		["tree_ancient_a", Vector2(260, 640), 2.15],
		["tree_ancient_b", Vector2(610, 638), 2.55],
		["tree_ancient_c", Vector2(1010, 640), 2.30],
		["tree_ancient_a", Vector2(1390, 638), 2.60],
		["tree_ancient_b", Vector2(1810, 640), 2.35],
		["tree_ancient_c", Vector2(2210, 640), 2.60],
		["tree_ancient_a", Vector2(2510, 638), 2.25],
	]:
		_add_sprite(
			distant,
			str(entry[0]),
			entry[1],
			float(entry[2]),
			Color(0.13, 0.25, 0.19, 0.66)
		)
	var middle := Node2D.new()
	middle.name = "ElderwoodMiddleGrowth"
	middle.z_index = -5
	add_child(middle)
	for entry in [
		["tree_ancient_a", Vector2(125, 620), 1.55],
		["tree_ancient_b", Vector2(440, 620), 1.70],
		["tree_ancient_c", Vector2(875, 620), 1.45],
		["tree_ancient_a", Vector2(1530, 620), 1.72],
		["tree_ancient_b", Vector2(1870, 620), 1.85],
		["tree_ancient_c", Vector2(2290, 620), 1.65],
	]:
		var tree := _add_sprite(middle, str(entry[0]), entry[1], float(entry[2]), Color(0.72, 0.82, 0.67, 1.0))
		if tree != null:
			_swaying_props.append({"node": tree, "base_rotation": 0.0, "speed": randf_range(0.42, 0.62), "amount": 0.006})


func _build_authored_props() -> void:
	var props := Node2D.new()
	props.name = "ElderwoodAuthoredProps"
	props.z_index = -2
	add_child(props)
	for entry in [
		["rock_medium", Vector2(285, 620), 1.15],
		["bush_flower", Vector2(360, 620), 1.2],
		["mushrooms", Vector2(515, 620), 1.1],
		["fallen_log", Vector2(905, 620), 1.1],
		["flowers", Vector2(1080, 620), 1.0],
		["stump", Vector2(1470, 620), 1.1],
		["rock_large", Vector2(1765, 620), 1.05],
		["bush_dark", Vector2(1980, 620), 1.3],
		["mushrooms", Vector2(2240, 620), 1.15],
	]:
		_add_sprite(props, str(entry[0]), entry[1], float(entry[2]), Color(0.90, 0.94, 0.84, 1.0))
	var ruins := Node2D.new()
	ruins.name = "ForgottenWayside"
	ruins.z_index = -3
	add_child(ruins)
	for entry in [
		["waystone_fragment", Vector2(190, 620), 1.25],
		["broken_wall_corner", Vector2(1170, 620), 1.35],
		["mossy_pillar", Vector2(1275, 620), 1.4],
		["broken_wall_end", Vector2(1370, 620), 1.25],
		["carved_stone", Vector2(2055, 620), 1.15],
		["ruined_arch", Vector2(2180, 620), 1.55],
	]:
		_add_sprite(ruins, str(entry[0]), entry[1], float(entry[2]), Color(0.67, 0.73, 0.63, 1.0))
	var foreground := Node2D.new()
	foreground.name = "ElderwoodForegroundFraming"
	foreground.z_index = 24
	add_child(foreground)
	_add_sprite(foreground, "bush_dark", Vector2(20, 680), 2.1, Color(0.18, 0.32, 0.23, 0.82))
	_add_sprite(foreground, "grass_tuft", Vector2(2360, 680), 2.2, Color(0.16, 0.29, 0.20, 0.82))


func _build_atmosphere() -> void:
	var atmosphere := Node2D.new()
	atmosphere.name = "ElderwoodAmbientLife"
	atmosphere.z_index = 14
	add_child(atmosphere)
	for index in range(26):
		var mote := Polygon2D.new()
		var radius := 1.4 if index % 4 else 2.2
		mote.polygon = _circle_points(8, radius)
		mote.color = Color(0.72, 0.83, 0.52, 0.72 if index % 4 else 0.9)
		var origin := Vector2(
			80.0 + fmod(float(index * 193), 2240.0),
			255.0 + fmod(float(index * 71), 315.0)
		)
		mote.position = origin
		atmosphere.add_child(mote)
		_motes.append({"node": mote, "origin": origin, "phase": float(index) * 0.73})
	for index in range(12):
		var leaf := Polygon2D.new()
		leaf.polygon = PackedVector2Array([
			Vector2(-4, 0), Vector2(0, -2), Vector2(5, 0), Vector2(0, 2),
		])
		leaf.color = Color(0.47, 0.57, 0.25, 0.78)
		var origin := Vector2(-120.0 + float(index % 4) * 620.0, 170.0 + float(index % 3) * 105.0)
		atmosphere.add_child(leaf)
		_leaves.append({
			"node": leaf,
			"origin": origin,
			"phase": float(index % 5) * 0.18,
			"speed": 0.055 + float(index % 4) * 0.009,
		})
	for index in range(3):
		var mist := ColorRect.new()
		mist.position = Vector2(-120, 535 + index * 25)
		mist.size = Vector2(2640, 34 + index * 10)
		mist.color = Color(0.48, 0.62, 0.54, 0.035 + index * 0.012)
		mist.mouse_filter = Control.MOUSE_FILTER_IGNORE
		atmosphere.add_child(mist)
		atmosphere.move_child(mist, 0)
		_mist_bands.append(mist)


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


func _circle_points(segments: int, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
