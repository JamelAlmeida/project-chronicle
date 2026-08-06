extends Node2D

## Showcase Master Pack immersion — warm Hearthvale edge into Elderwood combat depth.
## Hides prototype ColorRect/Polygon leftovers and dresses collision-true platforms.

const ENV_ROOT := "res://Project Chronicle/Assets/Showcase/Runtime/Environment/"

var _textures: Dictionary[String, Texture2D] = {}
var _time := 0.0
var _swaying: Array[Dictionary] = []
var _motes: Array[Dictionary] = []


func _ready() -> void:
	_load_textures()
	_hide_prototype_visuals()
	_tone_remaining_scene()
	_build_sky_and_depth()
	_build_hearthvale_edge()
	_build_playable_platforms()
	_build_combat_scenery()
	_build_elderwood_depth()
	_build_ground_lane()
	_build_atmosphere()
	_build_foreground_framing()


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


func _hide_prototype_visuals() -> void:
	var zone := get_parent()
	# Any leftover ColorRect platform visuals — collision bodies stay.
	for path in [
		"GameplayLayer/Terrain/MainGround/Visual",
		"GameplayLayer/Terrain/MainGround/Topsoil",
		"GameplayLayer/Terrain/EntryRise/Visual",
		"GameplayLayer/Terrain/OptionalRoute/LowerOneWay/Visual",
		"GameplayLayer/Terrain/OptionalRoute/MiddleOneWay/Visual",
		"GameplayLayer/Terrain/OptionalRoute/HighOneWay/Visual",
		"GameplayLayer/Terrain/RootBridge/Visual",
	]:
		var visual := zone.get_node_or_null(path) as CanvasItem
		if visual != null:
			visual.visible = false

	# Old geometric wedges replaced by showcase crops (kept hidden if still present).
	for path in [
		"MidBackground/ForestDepth",
		"ForegroundLayer/LeftLeaves",
		"ForegroundLayer/RightLeaves",
		"GameplayLayer/Landmarks/HearthvaleWaystone",
		"GameplayLayer/Landmarks/AncientTree",
		"GameplayLayer/Landmarks/RuinArch",
	]:
		var leftover := zone.get_node_or_null(path) as CanvasItem
		if leftover != null:
			leftover.visible = false


func _tone_remaining_scene() -> void:
	var zone := get_parent()
	var sky := zone.get_node_or_null("DistantBackground/Sky") as ColorRect
	if sky != null:
		sky.color = Color(0.38, 0.26, 0.18, 1.0)
	var canopy := zone.get_node_or_null("DistantBackground/DistantCanopy") as Polygon2D
	if canopy != null:
		# Soft distant fill only — no hard empty wedges competing with authored trees.
		canopy.color = Color(0.05, 0.08, 0.06, 0.55)
	var mist := zone.get_node_or_null("AtmosphericOverlays/MistBand") as ColorRect
	if mist != null:
		mist.color = Color(0.55, 0.48, 0.32, 0.04)


func _build_sky_and_depth() -> void:
	var distant := Node2D.new()
	distant.name = "ShowcaseDistant"
	distant.z_index = -38
	add_child(distant)
	_place(distant, "forest_cluster_a", Vector2(420, 390), 0.7, Color(0.42, 0.46, 0.4, 0.75))
	_place(distant, "forest_cluster_b", Vector2(980, 400), 0.78, Color(0.4, 0.45, 0.38, 0.8))
	_place(distant, "forest_cluster_a", Vector2(1580, 395), 0.82, Color(0.36, 0.42, 0.35, 0.85))
	_place(distant, "forest_cluster_b", Vector2(2140, 405), 0.75, Color(0.34, 0.4, 0.33, 0.88))

	var mid := Node2D.new()
	mid.name = "ShowcaseMid"
	mid.z_index = -18
	add_child(mid)
	_place(mid, "forest_cluster_a", Vector2(720, 470), 0.92, Color(0.68, 0.76, 0.64, 0.95))
	_place(mid, "forest_cluster_b", Vector2(1380, 460), 1.0, Color(0.6, 0.7, 0.58, 1.0))
	_place(mid, "tree_ancient", Vector2(1880, 500), 1.0, Color(0.82, 0.88, 0.78, 1.0))


func _build_hearthvale_edge() -> void:
	var town := Node2D.new()
	town.name = "HearthvaleEdge"
	town.z_index = -8
	add_child(town)
	_place(town, "cottage_large", Vector2(210, 430), 0.72, Color(1.05, 0.98, 0.88, 1.0))
	_place(town, "cottage_medium", Vector2(430, 500), 0.58, Color(1.0, 0.95, 0.86, 1.0))
	_place(town, "chimney_a", Vector2(280, 280), 0.45, Color(1.0, 1.0, 1.0, 0.95))
	_place(town, "lantern_post", Vector2(580, 500), 0.48, Color(1.12, 1.02, 0.82, 1.0))
	_place(town, "banner_crest", Vector2(120, 480), 0.4, Color(1.0, 1.0, 1.0, 0.95))
	_place(town, "waystone", Vector2(180, 575), 0.7, Color(1.0, 1.0, 0.95, 1.0))
	_place(town, "fence_a", Vector2(480, 600), 0.5, Color(1.0, 0.96, 0.88, 1.0))
	_place(town, "barrels", Vector2(360, 600), 0.4, Color(1.0, 0.95, 0.88, 1.0))
	_place(town, "stone_steps", Vector2(700, 595), 0.48, Color(0.95, 0.98, 0.92, 1.0))
	_place(town, "stone_wall", Vector2(640, 585), 0.42, Color(0.95, 0.96, 0.9, 1.0))
	_place(town, "elderwood_sign", Vector2(760, 545), 0.38, Color(1.0, 0.98, 0.9, 1.0))


func _build_playable_platforms() -> void:
	## Dress collision platforms with showcase art. Sprite tops align to collision tops.
	## MainGround top is y=620; elevated tops ≈ EntryRise 579, Lower 549, Mid 494, High 444, Root 519.
	var zone := get_parent()
	_dress_body(
		zone.get_node_or_null("GameplayLayer/Terrain/EntryRise") as StaticBody2D,
		"platform_ledge",
		0.52,
		Color(1.02, 1.0, 0.92, 1.0),
		4.0
	)
	_dress_body(
		zone.get_node_or_null("GameplayLayer/Terrain/OptionalRoute/LowerOneWay") as StaticBody2D,
		"platform_mid",
		0.5,
		Color(0.95, 1.0, 0.92, 1.0),
		5.0
	)
	_dress_body(
		zone.get_node_or_null("GameplayLayer/Terrain/OptionalRoute/MiddleOneWay") as StaticBody2D,
		"platform_ledge",
		0.46,
		Color(0.92, 0.98, 0.9, 1.0),
		4.0
	)
	_dress_body(
		zone.get_node_or_null("GameplayLayer/Terrain/OptionalRoute/HighOneWay") as StaticBody2D,
		"platform_mid",
		0.48,
		Color(0.9, 0.96, 0.88, 1.0),
		5.0
	)
	_dress_body(
		zone.get_node_or_null("GameplayLayer/Terrain/RootBridge") as StaticBody2D,
		"platform_ledge",
		0.5,
		Color(0.88, 0.78, 0.62, 1.0),
		4.0
	)

	# Small prop accents on standable tops (non-blocking sprites).
	var accents := Node2D.new()
	accents.name = "PlatformAccents"
	accents.z_index = 1
	add_child(accents)
	_place(accents, "mushrooms", Vector2(520, 568), 0.35, Color(1.0, 1.0, 1.0, 0.95))
	_place(accents, "grass_tuft_a", Vector2(940, 538), 0.4, Color.WHITE)
	_place(accents, "grass_tuft_b", Vector2(1160, 483), 0.38, Color.WHITE)
	_place(accents, "mushrooms", Vector2(1385, 433), 0.35, Color.WHITE)
	_place(accents, "grass_dark_a", Vector2(1660, 508), 0.4, Color(0.95, 0.9, 0.8, 1.0))


func _build_combat_scenery() -> void:
	## Midground scenery only — no fake standable platforms in the jump path.
	var lane := Node2D.new()
	lane.name = "CombatLane"
	lane.z_index = -4
	add_child(lane)
	_place(lane, "ruined_arch", Vector2(1240, 470), 0.58, Color(0.92, 0.95, 0.9, 1.0))
	_place(lane, "lantern_ruin", Vector2(1560, 530), 0.45, Color(1.15, 1.05, 0.8, 1.0))
	_place(lane, "rock_cluster", Vector2(980, 600), 0.4, Color(0.9, 0.92, 0.88, 1.0))
	_place(lane, "rubble", Vector2(1120, 610), 0.35, Color(0.9, 0.92, 0.88, 1.0))
	_place(lane, "mushrooms", Vector2(1340, 605), 0.45, Color.WHITE)
	# Cliff-face dressing with moss top locked to MainGround (y=620) — not a fake ledge.
	_place(lane, "platform_corner", Vector2(1520, 668), 0.4, Color(0.78, 0.84, 0.74, 0.95))


func _build_elderwood_depth() -> void:
	var deep := Node2D.new()
	deep.name = "ElderwoodDepth"
	deep.z_index = -2
	add_child(deep)
	_place(deep, "tree_ancient", Vector2(2080, 500), 1.05, Color(0.8, 0.88, 0.78, 1.0))
	# Ground-level ruin shelf — moss top aligned to MainGround collision (y=620).
	_place(deep, "platform_low", Vector2(1900, 680), 0.48, Color(0.85, 0.9, 0.82, 1.0))
	_place(deep, "bush_dark", Vector2(1750, 600), 0.55, Color(0.9, 0.95, 0.88, 1.0))
	_place(deep, "mushrooms", Vector2(1820, 610), 0.5, Color.WHITE)
	_place(deep, "ruined_arch", Vector2(2200, 500), 0.55, Color(0.78, 0.84, 0.76, 1.0))
	var sway_tree := _place(deep, "tree_ancient", Vector2(2250, 490), 0.88, Color(0.75, 0.84, 0.72, 1.0))
	if sway_tree != null:
		_swaying.append({"node": sway_tree, "base": 0.0, "speed": 0.35, "amount": 0.012})


func _build_ground_lane() -> void:
	## Continuous authored ground covering the old flat green band (collision top y=620).
	var ground := Node2D.new()
	ground.name = "GroundDressing"
	ground.z_index = -1
	add_child(ground)

	# Dark soil fill under the art so no prototype color peeks through gaps.
	var soil := Polygon2D.new()
	soil.name = "SoilFill"
	soil.polygon = PackedVector2Array([
		Vector2(0, 618), Vector2(2400, 618), Vector2(2400, 740), Vector2(0, 740),
	])
	soil.color = Color(0.07, 0.09, 0.06, 1.0)
	ground.add_child(soil)

	# Warm Hearthvale-edge ground into cooler Elderwood strips.
	_place(ground, "ground_long", Vector2(280, 655), 0.95, Color(1.08, 1.0, 0.88, 1.0))
	_place(ground, "ground_long", Vector2(720, 658), 0.9, Color(1.0, 0.98, 0.9, 1.0))
	_place(ground, "ground_strip", Vector2(1050, 638), 1.05, Color(0.95, 1.0, 0.9, 1.0))
	_place(ground, "ground_strip", Vector2(1420, 638), 1.05, Color(0.9, 0.96, 0.88, 1.0))
	_place(ground, "ground_long", Vector2(1780, 660), 0.88, Color(0.88, 0.94, 0.84, 1.0))
	_place(ground, "ground_strip", Vector2(2140, 640), 1.0, Color(0.82, 0.9, 0.8, 1.0))
	_place(ground, "stone_wall", Vector2(720, 625), 0.5, Color(0.95, 0.96, 0.9, 1.0))

	for x in [160.0, 420.0, 680.0, 940.0, 1220.0, 1500.0, 1780.0, 2060.0, 2280.0]:
		var tuft := "grass_tuft_a" if int(x) % 400 < 200 else "grass_tuft_b"
		var dark := "grass_dark_a" if int(x) % 300 < 150 else "grass_dark_b"
		_place(ground, tuft, Vector2(x, 612), 0.55, Color.WHITE)
		_place(ground, dark, Vector2(x + 48.0, 618), 0.48, Color.WHITE)


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


func _build_foreground_framing() -> void:
	var fore := Node2D.new()
	fore.name = "ShowcaseForeground"
	fore.z_index = 28
	add_child(fore)
	_place(fore, "bush_dark", Vector2(40, 680), 0.85, Color(0.35, 0.42, 0.32, 0.85))
	_place(fore, "grass_dark_a", Vector2(110, 695), 0.7, Color(0.3, 0.38, 0.28, 0.75))
	_place(fore, "bush_dark", Vector2(2340, 685), 0.9, Color(0.28, 0.36, 0.26, 0.88))
	_place(fore, "grass_dark_b", Vector2(2260, 698), 0.65, Color(0.28, 0.34, 0.25, 0.72))


func _dress_body(
	body: StaticBody2D,
	texture_name: String,
	scale_factor: float,
	modulate: Color,
	moss_pad_px: float
) -> Sprite2D:
	if body == null:
		return null
	var texture := _tex(texture_name)
	if texture == null:
		return null

	# Hide any leftover ColorRect visual under this body.
	var old_visual := body.get_node_or_null("Visual") as CanvasItem
	if old_visual != null:
		old_visual.visible = false

	var sprite := Sprite2D.new()
	sprite.name = "ShowcasePlatformVisual"
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.modulate = modulate
	sprite.z_index = -1

	# Align mossy top to collision top (RectangleShape2D top = -half_height locally).
	var collision := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var top_local := -7.0
	if collision != null and collision.shape is RectangleShape2D:
		var rect := collision.shape as RectangleShape2D
		top_local = -rect.size.y * 0.5
	var display_h := float(texture.get_height()) * scale_factor
	sprite.position = Vector2(0.0, top_local + display_h * 0.5 - moss_pad_px)

	body.add_child(sprite)
	return sprite


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
