extends Node

## Presentation-only Elderwood dressing. Every placement is authored; gameplay nodes,
## boundaries, encounters, transitions, and collision shapes remain untouched.

const ART_ROOT := "res://Project Chronicle/Assets/PixelArt/Environment/Elderwood/"

var _textures: Dictionary = {}


func _ready() -> void:
	_cache_textures()
	if _textures.get("grass_fill") == null or _textures.get("path_fill") == null:
		return

	_dress_ground()
	_dress_existing_obstacles()
	_dress_authored_props()

	var sign := get_node_or_null("../../ForegroundOverheadLayer/Sign") as CanvasItem
	if sign != null:
		sign.visible = false


func _cache_textures() -> void:
	var names := PackedStringArray([
		"grass_fill", "grass_a", "grass_b", "grass_dark", "grass_deep", "worn_ground",
		"path_fill", "path_center", "path_edge_left", "path_edge_right", "path_corner_a",
		"path_corner_b", "path_bend_a", "path_bend_b",
		"tree_ancient_a", "tree_ancient_b", "tree_ancient_c",
		"rock_large", "rock_medium", "rock_small", "bush_dark", "bush_flower",
		"grass_tuft", "flowers", "mushrooms", "fallen_log", "stump",
		"mossy_pillar", "ruined_arch", "carved_stone", "broken_wall_corner",
		"broken_wall_tall", "broken_wall_end", "waystone_fragment",
	])
	for texture_name: String in names:
		var path := "%s%s.png" % [ART_ROOT, texture_name]
		_textures[texture_name] = load(path) as Texture2D


func _dress_ground() -> void:
	var zone := get_node("../..")
	var ground_layer := zone.get_node("GroundLayer")
	var path_layer := zone.get_node("PathsFloorsLayer")

	_add_tiled_rect(
		ground_layer,
		_textures["grass_fill"],
		Rect2(-100.0, -100.0, 1300.0, 1000.0),
		Color.WHITE
	)
	_add_tiled_rect(
		ground_layer,
		_textures["grass_b"],
		Rect2(40.0, 70.0, 480.0, 250.0),
		Color(1.0, 1.0, 1.0, 0.34)
	)
	_add_tiled_rect(
		ground_layer,
		_textures["grass_dark"],
		Rect2(560.0, -20.0, 570.0, 280.0),
		Color(1.0, 1.0, 1.0, 0.66)
	)
	_add_tiled_rect(
		ground_layer,
		_textures["grass_deep"],
		Rect2(900.0, 80.0, 230.0, 680.0),
		Color(1.0, 1.0, 1.0, 0.32)
	)
	_add_tiled_rect(
		ground_layer,
		_textures["worn_ground"],
		Rect2(430.0, 430.0, 300.0, 240.0),
		Color(1.0, 1.0, 1.0, 0.23)
	)

	# Winding west-to-east trail, then the darker north approach to Mosscrypt.
	var path_rects := [
		Rect2(0.0, 360.0, 300.0, 80.0),
		Rect2(260.0, 340.0, 170.0, 96.0),
		Rect2(390.0, 370.0, 230.0, 86.0),
		Rect2(580.0, 350.0, 210.0, 92.0),
		Rect2(750.0, 375.0, 350.0, 78.0),
		Rect2(690.0, 205.0, 88.0, 220.0),
		Rect2(700.0, 50.0, 80.0, 190.0),
	]
	for path_rect: Rect2 in path_rects:
		_add_tiled_rect(path_layer, _textures["path_fill"], path_rect, Color.WHITE)

	_add_sprite(path_layer, "path_bend_a", Vector2(405.0, 389.0), false, Color.WHITE)
	_add_sprite(path_layer, "path_bend_b", Vector2(715.0, 375.0), false, Color.WHITE)
	_add_sprite(path_layer, "path_corner_a", Vector2(718.0, 224.0), false, Color.WHITE)
	_add_sprite(path_layer, "path_corner_b", Vector2(764.0, 410.0), false, Color.WHITE)

	var placeholder_ground := ground_layer.get_node_or_null("Ground") as CanvasItem
	if placeholder_ground != null:
		placeholder_ground.visible = false
	for child: Node in path_layer.get_children():
		if child.name in [&"PathWest", &"PathEast", &"PathNorth"]:
			(child as CanvasItem).visible = false


func _dress_existing_obstacles() -> void:
	var obstacles := get_node("../../DepthSorted/TerrainLayer/Obstacles")
	var replacements := {
		"Tree1": "tree_ancient_a",
		"Tree2": "tree_ancient_b",
		"Tree3": "tree_ancient_c",
		"Tree4": "tree_ancient_a",
		"Rock1": "rock_large",
		"Rock2": "rock_medium",
	}
	for node_name: String in replacements:
		var body := obstacles.get_node_or_null(node_name) as Node2D
		var texture_name: String = replacements[node_name]
		if body == null or _textures.get(texture_name) == null:
			continue
		var placeholder := body.get_node_or_null("Visual") as CanvasItem
		if placeholder != null:
			placeholder.visible = false
		_add_sprite(body, texture_name, Vector2.ZERO, true, Color.WHITE)


func _dress_authored_props() -> void:
	var props := get_node("../../DepthSorted/PropsLayer")
	var foliage := get_node("../../DepthSorted/FoliageDecorationsLayer")
	var foreground := get_node("../../ForegroundOverheadLayer")

	# Dense edge framing keeps the existing central encounter clearings readable.
	var edge_trees := [
		["tree_ancient_b", Vector2(90, 130)],
		["tree_ancient_c", Vector2(205, 115)],
		["tree_ancient_a", Vector2(370, 105)],
		["tree_ancient_c", Vector2(560, 100)],
		["tree_ancient_b", Vector2(900, 115)],
		["tree_ancient_a", Vector2(1040, 145)],
		["tree_ancient_c", Vector2(90, 720)],
		["tree_ancient_b", Vector2(250, 750)],
		["tree_ancient_a", Vector2(470, 730)],
		["tree_ancient_c", Vector2(760, 735)],
		["tree_ancient_b", Vector2(1030, 710)],
	]
	for entry: Array in edge_trees:
		_add_sprite(props, entry[0], entry[1], true, Color.WHITE)

	# West quiet area: flowers, fungi, and low natural clusters.
	var quiet_props := [
		["bush_flower", Vector2(145, 285)],
		["flowers", Vector2(190, 335)],
		["mushrooms", Vector2(240, 320)],
		["stump", Vector2(150, 570)],
		["fallen_log", Vector2(245, 630)],
		["grass_tuft", Vector2(360, 610)],
		["rock_small", Vector2(110, 500)],
	]
	for entry: Array in quiet_props:
		_add_sprite(foliage, entry[0], entry[1], true, Color.WHITE)

	# Reclaimed ruin landmark flanks the central clearing without shrinking combat space.
	var ruin_props := [
		["broken_wall_corner", Vector2(475, 245)],
		["mossy_pillar", Vector2(585, 270)],
		["broken_wall_end", Vector2(650, 300)],
		["carved_stone", Vector2(565, 570)],
		["waystone_fragment", Vector2(675, 610)],
		["rock_medium", Vector2(735, 575)],
	]
	for entry: Array in ruin_props:
		_add_sprite(props, entry[0], entry[1], true, Color.WHITE)

	# Mosscrypt approach: stronger stone landmark and darker, denser vegetation.
	var crypt_approach := [
		["ruined_arch", Vector2(740, 110)],
		["broken_wall_tall", Vector2(850, 175)],
		["bush_dark", Vector2(650, 150)],
		["bush_dark", Vector2(930, 245)],
		["mushrooms", Vector2(825, 225)],
		["rock_large", Vector2(1010, 315)],
		["grass_tuft", Vector2(800, 285)],
	]
	for entry: Array in crypt_approach:
		_add_sprite(props, entry[0], entry[1], true, Color(0.86, 0.91, 0.82, 1.0))

	# Sparse foreground overlap adds depth without covering the combat center.
	for entry: Array in [
		["bush_dark", Vector2(70, 795)],
		["grass_tuft", Vector2(540, 805)],
		["bush_flower", Vector2(1070, 790)],
	]:
		_add_sprite(foreground, entry[0], entry[1], true, Color(0.76, 0.82, 0.75, 0.9))


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
	parent.move_child(visual, 0)
	return visual


func _add_sprite(
	parent: Node,
	texture_name: String,
	world_position: Vector2,
	align_to_ground: bool,
	tint: Color
) -> Sprite2D:
	var texture: Texture2D = _textures.get(texture_name)
	if texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.name = StringName("Art_%s" % texture_name)
	sprite.texture = texture
	sprite.position = world_position
	if align_to_ground:
		sprite.offset.y = -float(texture.get_height()) * 0.5
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = tint
	parent.add_child(sprite)
	return sprite
