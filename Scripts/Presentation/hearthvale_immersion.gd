extends Node2D

## Authored Hearthvale settlement dressing — warm timber/stone home language.

const UI := preload("res://Project Chronicle/Scripts/UI/chronicle_ui_theme.gd")

var _time := 0.0
var _lantern_glows: Array[CanvasItem] = []
var _window_glows: Array[CanvasItem] = []
var _smoke_motes: Array[Dictionary] = []
var _dust_motes: Array[Dictionary] = []
var _banner: Polygon2D


func _ready() -> void:
	_tone_sky()
	_build_distant_landscape()
	_build_settlement()
	_build_street_life()
	_build_path_details()
	_build_ambient_life()
	_style_existing_labels()


func _process(delta: float) -> void:
	_time += delta
	for index in _lantern_glows.size():
		var glow := _lantern_glows[index]
		var pulse := 0.76 + sin(_time * 4.8 + float(index) * 1.55) * 0.18
		glow.modulate.a = pulse
		glow.scale = Vector2.ONE * (0.92 + pulse * 0.1)
	for index in _window_glows.size():
		var glow := _window_glows[index]
		glow.modulate.a = 0.82 + sin(_time * 2.1 + float(index) * 0.9) * 0.1
	for index in _smoke_motes.size():
		var smoke: Dictionary = _smoke_motes[index]
		var mote := smoke["node"] as Polygon2D
		var origin: Vector2 = smoke["origin"]
		var phase: float = fmod(_time * 0.20 + float(smoke["phase"]), 1.0)
		mote.position = origin + Vector2(sin(phase * TAU + index) * 10.0, -phase * 110.0)
		mote.scale = Vector2.ONE * lerpf(0.55, 1.7, phase)
		mote.modulate.a = sin(phase * PI) * 0.38
	for index in _dust_motes.size():
		var entry: Dictionary = _dust_motes[index]
		var mote := entry["node"] as Polygon2D
		var origin: Vector2 = entry["origin"]
		var phase: float = float(entry["phase"])
		mote.position = origin + Vector2(
			sin(_time * 0.55 + phase) * 22.0,
			sin(_time * 0.8 + phase * 1.4) * 8.0
		)
		mote.modulate.a = 0.18 + sin(_time * 1.4 + phase) * 0.1
	if _banner != null:
		_banner.skew = sin(_time * 1.25) * 0.05


func _tone_sky() -> void:
	var sky := get_parent().get_node_or_null("DistantBackground/Sky") as ColorRect
	if sky != null:
		sky.color = Color(0.28, 0.20, 0.14, 1.0)
	var silhouette := get_parent().get_node_or_null("DistantBackground/VillageSilhouette") as Polygon2D
	if silhouette != null:
		silhouette.color = Color(0.10, 0.085, 0.07, 0.94)
	var ground := get_parent().get_node_or_null("GameplayLayer/Ground/Visual") as ColorRect
	if ground != null:
		ground.color = Color(0.20, 0.17, 0.13, 1.0)
	var top := get_parent().get_node_or_null("GameplayLayer/Ground/Top") as ColorRect
	if top != null:
		top.color = Color(0.48, 0.38, 0.24, 1.0)


func _build_distant_landscape() -> void:
	var layer := Node2D.new()
	layer.name = "HearthvaleDistance"
	layer.z_index = -18
	add_child(layer)

	var dusk := Polygon2D.new()
	dusk.polygon = PackedVector2Array([
		Vector2(-220, 20), Vector2(980, 50), Vector2(820, 640), Vector2(-220, 640),
	])
	dusk.color = Color(0.95, 0.58, 0.22, 0.10)
	layer.add_child(dusk)

	var moon := Polygon2D.new()
	moon.position = Vector2(1520, 165)
	moon.polygon = _circle_points(22, 38.0)
	moon.color = Color(0.92, 0.78, 0.48, 0.34)
	layer.add_child(moon)
	var moon_haze := Polygon2D.new()
	moon_haze.position = moon.position
	moon_haze.polygon = _circle_points(18, 68.0)
	moon_haze.color = Color(0.88, 0.62, 0.28, 0.07)
	layer.add_child(moon_haze)

	for cloud_points in [
		PackedVector2Array([
			Vector2(60, 235), Vector2(210, 214), Vector2(340, 238),
			Vector2(210, 252), Vector2(60, 246),
		]),
		PackedVector2Array([
			Vector2(1080, 250), Vector2(1260, 222), Vector2(1460, 248),
			Vector2(1300, 268), Vector2(1080, 260),
		]),
	]:
		_add_polygon(layer, cloud_points, Color(0.48, 0.38, 0.28, 0.16))

	_add_polygon(layer, PackedVector2Array([
		Vector2(-320, 390), Vector2(70, 255), Vector2(360, 345),
		Vector2(700, 220), Vector2(1080, 345), Vector2(1460, 235),
		Vector2(2100, 365), Vector2(2100, 720), Vector2(-320, 720),
	]), Color(0.14, 0.11, 0.085, 1.0))

	for entry in [
		[70.0, 390.0, 150.0], [320.0, 365.0, 190.0], [690.0, 395.0, 140.0],
		[1080.0, 375.0, 175.0], [1440.0, 398.0, 135.0], [1740.0, 368.0, 190.0],
	]:
		_add_distant_roof(layer, float(entry[0]), float(entry[1]), float(entry[2]))

	var horizon := Line2D.new()
	horizon.points = PackedVector2Array([Vector2(-200, 418), Vector2(2050, 418)])
	horizon.width = 4.0
	horizon.default_color = Color(0.78, 0.48, 0.18, 0.28)
	layer.add_child(horizon)


func _build_settlement() -> void:
	var architecture := Node2D.new()
	architecture.name = "HearthvaleArchitecture"
	architecture.z_index = -4
	add_child(architecture)

	_add_building(architecture, Vector2(95, 620), 250.0, 268.0, Color(0.46, 0.34, 0.24), "THE WAYFARER", true)
	_add_building(architecture, Vector2(390, 620), 278.0, 318.0, Color(0.52, 0.42, 0.30), "HEARTH HALL", true)
	_add_building(architecture, Vector2(735, 620), 236.0, 248.0, Color(0.38, 0.33, 0.28), "FORGE", false)
	_add_building(architecture, Vector2(1035, 620), 260.0, 278.0, Color(0.48, 0.37, 0.26), "PROVISIONS", true)
	_add_building(architecture, Vector2(1335, 620), 218.0, 236.0, Color(0.44, 0.35, 0.26), "", false)

	_add_market_stall(architecture, Vector2(890, 620))
	_add_well(architecture, Vector2(555, 615))
	_add_gate_details(architecture, Vector2(1610, 620))
	_add_garden_bed(architecture, Vector2(250, 618))
	_add_garden_bed(architecture, Vector2(1200, 618))
	_add_barrel_cluster(architecture, Vector2(680, 620))
	_add_barrel_cluster(architecture, Vector2(1480, 620))


func _build_street_life() -> void:
	var life := Node2D.new()
	life.name = "HearthvaleStreetLife"
	life.z_index = -3
	add_child(life)
	# Warm street wash under settlement windows.
	for wash in [
		[Vector2(95, 610), 220.0], [Vector2(390, 610), 250.0],
		[Vector2(735, 610), 200.0], [Vector2(1035, 610), 230.0],
		[Vector2(1335, 610), 190.0],
	]:
		var glow := Polygon2D.new()
		glow.position = wash[0]
		var half_w: float = float(wash[1]) * 0.5
		glow.polygon = PackedVector2Array([
			Vector2(-half_w, -8), Vector2(half_w, -8),
			Vector2(half_w * 0.7, 18), Vector2(-half_w * 0.7, 18),
		])
		glow.color = Color(0.95, 0.55, 0.18, 0.08)
		life.add_child(glow)


func _build_path_details() -> void:
	var details := Node2D.new()
	details.name = "HearthvaleGroundDetails"
	details.z_index = -1
	add_child(details)

	# Cobble path with mortar gaps.
	for index in range(52):
		var x := 12.0 + float(index) * 34.0
		var width := 20.0 + float(index % 5) * 2.8
		var height := 7.0 + float(index % 3)
		var stone := Polygon2D.new()
		stone.polygon = PackedVector2Array([
			Vector2(-width * 0.5, -height * 0.4), Vector2(width * 0.42, -height * 0.55),
			Vector2(width * 0.52, height * 0.35), Vector2(-width * 0.45, height * 0.45),
		])
		stone.position = Vector2(x, 614.0 + float(index % 4) * 2.2)
		var shade := 0.02 * float(index % 3)
		stone.color = Color(0.42 - shade, 0.38 - shade, 0.30 - shade, 0.88)
		details.add_child(stone)
		if index % 3 == 0:
			var moss := Polygon2D.new()
			moss.polygon = PackedVector2Array([
				Vector2(-6, -1), Vector2(5, -2), Vector2(4, 2), Vector2(-5, 2),
			])
			moss.position = stone.position + Vector2(0, -2)
			moss.color = Color(0.28, 0.36, 0.18, 0.55)
			details.add_child(moss)

	# Path edge rails near garden and gate approach.
	for x in [268.0, 300.0, 1175.0, 1208.0, 1450.0, 1485.0]:
		var post := Line2D.new()
		post.points = PackedVector2Array([Vector2(x, 620), Vector2(x, 562)])
		post.width = 6.0
		post.default_color = Color(0.22, 0.13, 0.075, 1.0)
		details.add_child(post)

	var fence := Line2D.new()
	fence.points = PackedVector2Array([
		Vector2(250, 582), Vector2(318, 574), Vector2(318, 590),
		Vector2(250, 596), Vector2(250, 582),
	])
	fence.width = 4.0
	fence.default_color = Color(0.34, 0.20, 0.11, 0.94)
	details.add_child(fence)


func _build_ambient_life() -> void:
	var ambience := Node2D.new()
	ambience.name = "HearthvaleAmbientLife"
	ambience.z_index = -2
	add_child(ambience)

	for position in [
		Vector2(205, 470), Vector2(510, 418), Vector2(820, 478),
		Vector2(1160, 455), Vector2(1515, 492), Vector2(1585, 540),
	]:
		_add_lantern(ambience, position)

	for chimney in [Vector2(145, 355), Vector2(455, 298), Vector2(770, 378), Vector2(1100, 348)]:
		for index in range(5):
			var mote := Polygon2D.new()
			mote.polygon = _circle_points(7, 3.5 + index * 0.7)
			mote.color = Color(0.62, 0.60, 0.55, 1.0)
			ambience.add_child(mote)
			_smoke_motes.append({
				"node": mote,
				"origin": chimney,
				"phase": float(index) * 0.2 + chimney.x * 0.0006,
			})

	for index in range(14):
		var mote := Polygon2D.new()
		mote.polygon = _circle_points(6, 1.6)
		mote.color = Color(0.95, 0.78, 0.42, 0.55)
		var origin := Vector2(80.0 + fmod(float(index * 127), 1550.0), 360.0 + fmod(float(index * 53), 180.0))
		mote.position = origin
		ambience.add_child(mote)
		_dust_motes.append({"node": mote, "origin": origin, "phase": float(index) * 0.8})


func _add_building(
	parent: Node,
	base_position: Vector2,
	width: float,
	height: float,
	wall_color: Color,
	sign_text: String,
	has_awning: bool
) -> void:
	var building := Node2D.new()
	building.position = base_position
	parent.add_child(building)

	# Stone plinth.
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.52, 0), Vector2(-width * 0.52, -22),
		Vector2(width * 0.52, -22), Vector2(width * 0.52, 0),
	]), Color(0.32, 0.30, 0.26, 1.0))
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.5, -4), Vector2(-width * 0.5, -18),
		Vector2(width * 0.5, -18), Vector2(width * 0.5, -4),
	]), Color(0.40, 0.37, 0.32, 1.0))

	# Stucco body.
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.5, -20), Vector2(-width * 0.5, -height),
		Vector2(width * 0.5, -height), Vector2(width * 0.5, -20),
	]), wall_color)
	# Subtle wall shade for volume.
	_add_polygon(building, PackedVector2Array([
		Vector2(width * 0.18, -20), Vector2(width * 0.18, -height),
		Vector2(width * 0.5, -height), Vector2(width * 0.5, -20),
	]), Color(0.0, 0.0, 0.0, 0.10))

	# Layered roof.
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.60, -height + 10), Vector2(0, -height - 82),
		Vector2(width * 0.60, -height + 10), Vector2(width * 0.50, -height + 28),
		Vector2(0, -height - 58), Vector2(-width * 0.50, -height + 28),
	]), Color(0.20, 0.09, 0.06, 1.0))
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.48, -height + 16), Vector2(0, -height - 62),
		Vector2(width * 0.48, -height + 16),
	]), Color(0.30, 0.14, 0.09, 1.0))
	# Ridge highlight.
	var ridge := Line2D.new()
	ridge.points = PackedVector2Array([
		Vector2(-width * 0.08, -height - 70), Vector2(width * 0.08, -height - 70),
	])
	ridge.width = 3.0
	ridge.default_color = Color(0.42, 0.22, 0.12, 0.9)
	building.add_child(ridge)

	# Timber frame.
	var beam_color := Color(0.18, 0.10, 0.06, 0.98)
	for x in [-width * 0.48, -width * 0.18, width * 0.18, width * 0.48]:
		var beam := Line2D.new()
		beam.points = PackedVector2Array([Vector2(x, -height + 12), Vector2(x, -18)])
		beam.width = 7.0
		beam.default_color = beam_color
		building.add_child(beam)
	for y_ratio in [0.32, 0.62]:
		var crossbeam := Line2D.new()
		crossbeam.points = PackedVector2Array([
			Vector2(-width * 0.5, -height * y_ratio), Vector2(width * 0.5, -height * y_ratio),
		])
		crossbeam.width = 6.0
		crossbeam.default_color = beam_color
		building.add_child(crossbeam)
	# Diagonal braces on outer bays.
	for side in [-1.0, 1.0]:
		var brace := Line2D.new()
		brace.points = PackedVector2Array([
			Vector2(side * width * 0.48, -height * 0.32),
			Vector2(side * width * 0.18, -height * 0.62),
		])
		brace.width = 4.0
		brace.default_color = Color(0.16, 0.09, 0.05, 0.85)
		building.add_child(brace)

	# Windows with mullions and warm spill.
	for x in [-width * 0.30, width * 0.30]:
		_add_window(building, Vector2(x, -height * 0.58))
	if height > 270.0:
		_add_window(building, Vector2(0, -height * 0.78), true)

	# Door with frame and iron handle.
	var door_frame := Polygon2D.new()
	door_frame.polygon = PackedVector2Array([
		Vector2(-28, -18), Vector2(-28, -88), Vector2(0, -102),
		Vector2(28, -88), Vector2(28, -18),
	])
	door_frame.color = Color(0.14, 0.08, 0.045, 1.0)
	building.add_child(door_frame)
	var door := Polygon2D.new()
	door.polygon = PackedVector2Array([
		Vector2(-22, -20), Vector2(-22, -82), Vector2(0, -94),
		Vector2(22, -82), Vector2(22, -20),
	])
	door.color = Color(0.22, 0.11, 0.06, 1.0)
	building.add_child(door)
	var handle := Polygon2D.new()
	handle.polygon = PackedVector2Array([
		Vector2(12, -48), Vector2(18, -48), Vector2(18, -54), Vector2(12, -54),
	])
	handle.color = Color(0.72, 0.58, 0.28, 1.0)
	building.add_child(handle)

	# Chimney with cap.
	var chimney := Polygon2D.new()
	chimney.polygon = PackedVector2Array([
		Vector2(-14, -height - 48), Vector2(-12, -height - 118),
		Vector2(16, -height - 118), Vector2(14, -height - 42),
	])
	chimney.position.x = -width * 0.28
	chimney.color = Color(0.28, 0.24, 0.20, 1.0)
	building.add_child(chimney)
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.28 - 18, -height - 118),
		Vector2(-width * 0.28 + 20, -height - 118),
		Vector2(-width * 0.28 + 16, -height - 108),
		Vector2(-width * 0.28 - 14, -height - 108),
	]), Color(0.22, 0.18, 0.15, 1.0))

	if has_awning:
		_add_polygon(building, PackedVector2Array([
			Vector2(-width * 0.22, -height * 0.38), Vector2(width * 0.22, -height * 0.38),
			Vector2(width * 0.26, -height * 0.28), Vector2(-width * 0.26, -height * 0.28),
		]), Color(0.42, 0.16, 0.12, 0.95))

	if not sign_text.is_empty():
		var board := Polygon2D.new()
		board.polygon = PackedVector2Array([
			Vector2(-72, -height * 0.36 - 4), Vector2(72, -height * 0.36 - 4),
			Vector2(68, -height * 0.36 + 22), Vector2(-68, -height * 0.36 + 22),
		])
		board.color = Color(0.16, 0.09, 0.05, 0.96)
		building.add_child(board)
		var sign := UI.style_heading(Label.new(), Color(0.88, 0.72, 0.40), 11, HORIZONTAL_ALIGNMENT_CENTER)
		sign.text = sign_text
		sign.position = Vector2(-70, -height * 0.36)
		sign.size = Vector2(140, 22)
		building.add_child(sign)


func _add_window(parent: Node, window_position: Vector2, small: bool = false) -> void:
	var half_w := 18.0 if small else 24.0
	var half_h := 20.0 if small else 26.0
	var frame := Polygon2D.new()
	frame.position = window_position
	frame.polygon = PackedVector2Array([
		Vector2(-half_w - 4, -half_h - 4), Vector2(half_w + 4, -half_h - 4),
		Vector2(half_w + 4, half_h + 4), Vector2(-half_w - 4, half_h + 4),
	])
	frame.color = Color(0.16, 0.09, 0.05, 1.0)
	parent.add_child(frame)
	var light := Polygon2D.new()
	light.position = window_position
	light.polygon = PackedVector2Array([
		Vector2(-half_w, -half_h), Vector2(half_w, -half_h),
		Vector2(half_w, half_h), Vector2(-half_w, half_h),
	])
	light.color = Color(1.0, 0.72, 0.28, 0.94)
	parent.add_child(light)
	_window_glows.append(light)
	# Mullion cross.
	var v := Line2D.new()
	v.points = PackedVector2Array([
		window_position + Vector2(0, -half_h), window_position + Vector2(0, half_h),
	])
	v.width = 2.5
	v.default_color = Color(0.18, 0.10, 0.06, 0.9)
	parent.add_child(v)
	var h := Line2D.new()
	h.points = PackedVector2Array([
		window_position + Vector2(-half_w, 0), window_position + Vector2(half_w, 0),
	])
	h.width = 2.5
	h.default_color = Color(0.18, 0.10, 0.06, 0.9)
	parent.add_child(h)
	# Soft spill below window.
	var spill := Polygon2D.new()
	spill.position = window_position + Vector2(0, half_h + 18)
	spill.polygon = PackedVector2Array([
		Vector2(-half_w * 0.8, -10), Vector2(half_w * 0.8, -10),
		Vector2(half_w * 1.4, 28), Vector2(-half_w * 1.4, 28),
	])
	spill.color = Color(1.0, 0.62, 0.22, 0.12)
	parent.add_child(spill)


func _add_lantern(parent: Node, lantern_position: Vector2) -> void:
	var post := Line2D.new()
	post.points = PackedVector2Array([lantern_position + Vector2(0, 48), lantern_position + Vector2(0, -18)])
	post.width = 5.0
	post.default_color = Color(0.16, 0.10, 0.06, 1.0)
	parent.add_child(post)
	var arm := Line2D.new()
	arm.points = PackedVector2Array([lantern_position + Vector2(0, -14), lantern_position + Vector2(14, -10)])
	arm.width = 3.0
	arm.default_color = Color(0.18, 0.11, 0.07, 1.0)
	parent.add_child(arm)
	var cage := Polygon2D.new()
	cage.position = lantern_position + Vector2(14, -4)
	cage.polygon = PackedVector2Array([
		Vector2(-8, -10), Vector2(8, -10), Vector2(7, 12), Vector2(0, 16), Vector2(-7, 12),
	])
	cage.color = Color(0.12, 0.08, 0.05, 1.0)
	parent.add_child(cage)
	var glow := Polygon2D.new()
	glow.position = lantern_position + Vector2(14, -2)
	glow.polygon = PackedVector2Array([
		Vector2(0, -8), Vector2(6, -2), Vector2(5, 8), Vector2(0, 12),
		Vector2(-5, 8), Vector2(-6, -2),
	])
	glow.color = Color(1.0, 0.68, 0.22, 0.92)
	parent.add_child(glow)
	_lantern_glows.append(glow)
	var pool := Polygon2D.new()
	pool.position = lantern_position + Vector2(8, 48)
	pool.polygon = PackedVector2Array([
		Vector2(-28, -4), Vector2(28, -4), Vector2(36, 14), Vector2(-36, 14),
	])
	pool.color = Color(1.0, 0.58, 0.18, 0.10)
	parent.add_child(pool)


func _add_well(parent: Node, well_position: Vector2) -> void:
	var well := Node2D.new()
	well.position = well_position
	parent.add_child(well)
	_add_polygon(well, PackedVector2Array([
		Vector2(-48, 0), Vector2(-55, -28), Vector2(-40, -50),
		Vector2(40, -50), Vector2(55, -28), Vector2(48, 0),
	]), Color(0.36, 0.35, 0.30, 1.0))
	_add_polygon(well, PackedVector2Array([
		Vector2(-34, -28), Vector2(34, -28), Vector2(28, -42), Vector2(-28, -42),
	]), Color(0.18, 0.28, 0.34, 0.85))
	var roof := Polygon2D.new()
	roof.polygon = PackedVector2Array([
		Vector2(-66, -82), Vector2(0, -118), Vector2(66, -82), Vector2(52, -68), Vector2(-52, -68),
	])
	roof.color = Color(0.26, 0.12, 0.07, 1.0)
	well.add_child(roof)
	for x in [-46.0, 46.0]:
		var post := Line2D.new()
		post.points = PackedVector2Array([Vector2(x, -14), Vector2(x, -82)])
		post.width = 6.0
		post.default_color = Color(0.20, 0.12, 0.07, 1.0)
		well.add_child(post)


func _add_gate_details(parent: Node, gate_position: Vector2) -> void:
	var gate := Node2D.new()
	gate.position = gate_position
	parent.add_child(gate)
	for x in [-70.0, 70.0]:
		_add_polygon(gate, PackedVector2Array([
			Vector2(x - 20, 0), Vector2(x - 22, -188), Vector2(x, -220),
			Vector2(x + 22, -188), Vector2(x + 20, 0),
		]), Color(0.34, 0.28, 0.21, 1.0))
		_add_polygon(gate, PackedVector2Array([
			Vector2(x - 12, -20), Vector2(x - 14, -170), Vector2(x + 14, -170), Vector2(x + 12, -20),
		]), Color(0.28, 0.22, 0.16, 1.0))
	var lintel := Line2D.new()
	lintel.points = PackedVector2Array([Vector2(-84, -180), Vector2(84, -180)])
	lintel.width = 16.0
	lintel.default_color = Color(0.22, 0.13, 0.07, 1.0)
	gate.add_child(lintel)
	_banner = Polygon2D.new()
	_banner.position = Vector2(0, -172)
	_banner.polygon = PackedVector2Array([
		Vector2(-36, 0), Vector2(36, 0), Vector2(30, 78),
		Vector2(0, 62), Vector2(-30, 78),
	])
	_banner.color = Color(0.40, 0.12, 0.10, 0.96)
	gate.add_child(_banner)
	var crest := Polygon2D.new()
	crest.position = Vector2(0, -145)
	crest.polygon = PackedVector2Array([
		Vector2(0, -14), Vector2(10, -4), Vector2(8, 12), Vector2(0, 16), Vector2(-8, 12), Vector2(-10, -4),
	])
	crest.color = Color(0.78, 0.62, 0.28, 0.9)
	gate.add_child(crest)


func _add_market_stall(parent: Node, stall_position: Vector2) -> void:
	var stall := Node2D.new()
	stall.position = stall_position
	parent.add_child(stall)
	_add_polygon(stall, PackedVector2Array([
		Vector2(-55, 0), Vector2(-55, -42), Vector2(55, -42), Vector2(55, 0),
	]), Color(0.28, 0.18, 0.10, 1.0))
	_add_polygon(stall, PackedVector2Array([
		Vector2(-68, -42), Vector2(0, -78), Vector2(68, -42), Vector2(58, -32), Vector2(-58, -32),
	]), Color(0.48, 0.18, 0.12, 1.0))
	for x in [-30.0, 0.0, 30.0]:
		_add_polygon(stall, PackedVector2Array([
			Vector2(x - 10, -38), Vector2(x + 10, -38), Vector2(x + 8, -18), Vector2(x - 8, -18),
		]), Color(0.72, 0.42, 0.18, 0.9))


func _add_garden_bed(parent: Node, bed_position: Vector2) -> void:
	var bed := Node2D.new()
	bed.position = bed_position
	parent.add_child(bed)
	_add_polygon(bed, PackedVector2Array([
		Vector2(-42, 0), Vector2(-38, -14), Vector2(38, -14), Vector2(42, 0),
	]), Color(0.22, 0.16, 0.10, 1.0))
	for entry in [
		[Vector2(-22, -18), Color(0.42, 0.55, 0.22)],
		[Vector2(0, -22), Color(0.62, 0.28, 0.28)],
		[Vector2(22, -18), Color(0.72, 0.58, 0.22)],
		[Vector2(-8, -28), Color(0.48, 0.32, 0.55)],
	]:
		var bloom := Polygon2D.new()
		bloom.position = entry[0]
		bloom.polygon = _circle_points(7, 5.0)
		bloom.color = entry[1]
		bed.add_child(bloom)


func _add_barrel_cluster(parent: Node, cluster_position: Vector2) -> void:
	var cluster := Node2D.new()
	cluster.position = cluster_position
	parent.add_child(cluster)
	for entry in [Vector2(-14, 0), Vector2(12, 2)]:
		_add_polygon(cluster, PackedVector2Array([
			entry + Vector2(-12, 0), entry + Vector2(-14, -28),
			entry + Vector2(14, -28), entry + Vector2(12, 0),
		]), Color(0.32, 0.20, 0.10, 1.0))
		var band := Line2D.new()
		band.points = PackedVector2Array([entry + Vector2(-13, -14), entry + Vector2(13, -14)])
		band.width = 2.5
		band.default_color = Color(0.18, 0.12, 0.07, 1.0)
		cluster.add_child(band)


func _add_distant_roof(parent: Node, x: float, base_y: float, width: float) -> void:
	_add_polygon(parent, PackedVector2Array([
		Vector2(x - width * 0.5, base_y), Vector2(x, base_y - width * 0.40),
		Vector2(x + width * 0.5, base_y), Vector2(x + width * 0.42, base_y + 85),
		Vector2(x - width * 0.42, base_y + 85),
	]), Color(0.10, 0.09, 0.08, 0.94))


func _style_existing_labels() -> void:
	var safety_label := get_parent().get_node_or_null("GameplayLayer/SafetyLabel") as Label
	if safety_label != null:
		UI.style_heading(safety_label, Color(0.92, 0.76, 0.42), 16)
		safety_label.text = "HEARTHVALE  ·  SAFE HAVEN"


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
