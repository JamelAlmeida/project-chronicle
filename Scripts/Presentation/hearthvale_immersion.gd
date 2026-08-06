extends Node2D

const UI := preload("res://Project Chronicle/Scripts/UI/chronicle_ui_theme.gd")

var _time := 0.0
var _lantern_glows: Array[CanvasItem] = []
var _smoke_motes: Array[Dictionary] = []
var _banner: Polygon2D


func _ready() -> void:
	_build_distant_landscape()
	_build_settlement()
	_build_path_details()
	_build_ambient_life()
	_style_existing_labels()


func _process(delta: float) -> void:
	_time += delta
	for index in _lantern_glows.size():
		var glow := _lantern_glows[index]
		var pulse := 0.78 + sin(_time * 5.2 + float(index) * 1.7) * 0.16
		glow.modulate.a = pulse
		glow.scale = Vector2.ONE * (0.94 + pulse * 0.08)
	for index in _smoke_motes.size():
		var smoke: Dictionary = _smoke_motes[index]
		var mote := smoke["node"] as Polygon2D
		var origin: Vector2 = smoke["origin"]
		var phase: float = fmod(_time * 0.22 + float(smoke["phase"]), 1.0)
		mote.position = origin + Vector2(sin(phase * TAU + index) * 8.0, -phase * 92.0)
		mote.scale = Vector2.ONE * lerpf(0.65, 1.55, phase)
		mote.modulate.a = sin(phase * PI) * 0.34
	if _banner != null:
		_banner.skew = sin(_time * 1.35) * 0.045


func _build_distant_landscape() -> void:
	var layer := Node2D.new()
	layer.name = "HearthvaleDistance"
	layer.z_index = -18
	add_child(layer)
	var moon := Polygon2D.new()
	moon.position = Vector2(1460, 195)
	moon.polygon = _circle_points(24, 46.0)
	moon.color = Color(0.86, 0.72, 0.42, 0.28)
	layer.add_child(moon)
	var dusk := Polygon2D.new()
	dusk.polygon = PackedVector2Array([
		Vector2(-200, 40), Vector2(900, 60), Vector2(760, 640), Vector2(-200, 640),
	])
	dusk.color = Color(0.92, 0.62, 0.28, 0.07)
	layer.add_child(dusk)
	for cloud_points in [
		PackedVector2Array([
			Vector2(80, 255), Vector2(220, 238), Vector2(345, 255),
			Vector2(220, 266), Vector2(80, 262),
		]),
		PackedVector2Array([
			Vector2(1050, 270), Vector2(1220, 245), Vector2(1410, 264),
			Vector2(1270, 283), Vector2(1050, 278),
		]),
	]:
		_add_polygon(layer, cloud_points, Color(0.55, 0.48, 0.36, 0.14))
	_add_polygon(layer, PackedVector2Array([
		Vector2(-300, 400), Vector2(80, 275), Vector2(380, 360),
		Vector2(720, 240), Vector2(1100, 360), Vector2(1480, 255),
		Vector2(2100, 380), Vector2(2100, 720), Vector2(-300, 720),
	]), Color(0.18, 0.16, 0.12, 1.0))
	for entry in [
		[90.0, 400.0, 145.0], [340.0, 380.0, 185.0], [720.0, 405.0, 135.0],
		[1120.0, 390.0, 170.0], [1480.0, 408.0, 130.0], [1770.0, 380.0, 185.0],
	]:
		_add_distant_roof(layer, float(entry[0]), float(entry[1]), float(entry[2]))
	var horizon := Line2D.new()
	horizon.points = PackedVector2Array([Vector2(-200, 430), Vector2(2050, 430)])
	horizon.width = 3.0
	horizon.default_color = Color(0.72, 0.48, 0.22, 0.22)
	layer.add_child(horizon)


func _build_settlement() -> void:
	var architecture := Node2D.new()
	architecture.name = "HearthvaleArchitecture"
	architecture.z_index = -4
	add_child(architecture)
	_add_building(architecture, Vector2(95, 620), 245.0, 255.0, Color(0.43, 0.31, 0.22), "THE WAYFARER")
	_add_building(architecture, Vector2(390, 620), 270.0, 305.0, Color(0.49, 0.39, 0.27), "HEARTH HALL")
	_add_building(architecture, Vector2(735, 620), 230.0, 240.0, Color(0.37, 0.32, 0.27), "FORGE")
	_add_building(architecture, Vector2(1035, 620), 255.0, 265.0, Color(0.46, 0.36, 0.25), "PROVISIONS")
	_add_building(architecture, Vector2(1335, 620), 210.0, 225.0, Color(0.42, 0.34, 0.25), "")
	_add_well(architecture, Vector2(555, 615))
	_add_gate_details(architecture, Vector2(1610, 620))


func _build_path_details() -> void:
	var details := Node2D.new()
	details.name = "HearthvaleGroundDetails"
	details.z_index = -1
	add_child(details)
	for index in range(46):
		var x := 20.0 + float(index) * 38.0
		var width := 23.0 + float(index % 4) * 3.0
		var stone := Polygon2D.new()
		stone.polygon = PackedVector2Array([
			Vector2(-width * 0.5, -4), Vector2(width * 0.42, -5),
			Vector2(width * 0.5, 2), Vector2(-width * 0.42, 3),
		])
		stone.position = Vector2(x, 616.0 + float(index % 3) * 2.0)
		stone.color = Color(0.40, 0.37, 0.30, 0.82)
		details.add_child(stone)
	for x in [275.0, 305.0, 1180.0, 1210.0, 1445.0]:
		var post := Line2D.new()
		post.points = PackedVector2Array([Vector2(x, 620), Vector2(x, 570)])
		post.width = 7.0
		post.default_color = Color(0.24, 0.15, 0.09, 1.0)
		details.add_child(post)
	var fence := Line2D.new()
	fence.points = PackedVector2Array([
		Vector2(255, 589), Vector2(325, 582), Vector2(325, 596),
		Vector2(255, 601), Vector2(255, 589),
	])
	fence.width = 4.0
	fence.default_color = Color(0.35, 0.22, 0.12, 0.92)
	details.add_child(fence)


func _build_ambient_life() -> void:
	var ambience := Node2D.new()
	ambience.name = "HearthvaleAmbientLife"
	ambience.z_index = -2
	add_child(ambience)
	for position in [Vector2(205, 478), Vector2(510, 430), Vector2(820, 486), Vector2(1160, 467), Vector2(1515, 505)]:
		_add_lantern(ambience, position)
	for chimney in [Vector2(145, 375), Vector2(455, 316), Vector2(770, 395), Vector2(1100, 363)]:
		for index in range(4):
			var mote := Polygon2D.new()
			mote.polygon = _circle_points(8, 4.0 + index)
			mote.color = Color(0.64, 0.64, 0.59, 1.0)
			ambience.add_child(mote)
			_smoke_motes.append({
				"node": mote,
				"origin": chimney,
				"phase": float(index) * 0.24 + chimney.x * 0.0007,
			})


func _add_building(
	parent: Node,
	base_position: Vector2,
	width: float,
	height: float,
	wall_color: Color,
	sign_text: String
) -> void:
	var building := Node2D.new()
	building.position = base_position
	parent.add_child(building)
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.5, 0), Vector2(-width * 0.5, -height),
		Vector2(width * 0.5, -height), Vector2(width * 0.5, 0),
	]), wall_color)
	_add_polygon(building, PackedVector2Array([
		Vector2(-width * 0.58, -height + 8), Vector2(0, -height - 72),
		Vector2(width * 0.58, -height + 8), Vector2(width * 0.48, -height + 25),
		Vector2(0, -height - 48), Vector2(-width * 0.48, -height + 25),
	]), Color(0.22, 0.105, 0.075, 1.0))
	var beam_color := Color(0.20, 0.12, 0.075, 0.96)
	for x in [-width * 0.42, 0.0, width * 0.42]:
		var beam := Line2D.new()
		beam.points = PackedVector2Array([Vector2(x, -height + 8), Vector2(x, -6)])
		beam.width = 8.0
		beam.default_color = beam_color
		building.add_child(beam)
	var crossbeam := Line2D.new()
	crossbeam.points = PackedVector2Array([
		Vector2(-width * 0.5, -height * 0.48), Vector2(width * 0.5, -height * 0.48),
	])
	crossbeam.width = 7.0
	crossbeam.default_color = beam_color
	building.add_child(crossbeam)
	for x in [-width * 0.27, width * 0.27]:
		_add_window(building, Vector2(x, -height * 0.62))
	var door := Polygon2D.new()
	door.polygon = PackedVector2Array([
		Vector2(-20, 0), Vector2(-20, -65), Vector2(0, -78),
		Vector2(20, -65), Vector2(20, 0),
	])
	door.color = Color(0.17, 0.09, 0.055, 1.0)
	building.add_child(door)
	var chimney := Polygon2D.new()
	chimney.polygon = PackedVector2Array([
		Vector2(-12, -height - 52), Vector2(-10, -height - 112),
		Vector2(15, -height - 112), Vector2(13, -height - 46),
	])
	chimney.position.x = -width * 0.30
	chimney.color = Color(0.25, 0.21, 0.18, 1.0)
	building.add_child(chimney)
	if not sign_text.is_empty():
		var sign := UI.style_heading(Label.new(), Color(0.83, 0.68, 0.39), 11, HORIZONTAL_ALIGNMENT_CENTER)
		sign.text = sign_text
		sign.position = Vector2(-70, -height * 0.34)
		sign.size = Vector2(140, 24)
		building.add_child(sign)


func _add_window(parent: Node, window_position: Vector2) -> void:
	var frame := Polygon2D.new()
	frame.position = window_position
	frame.polygon = PackedVector2Array([
		Vector2(-25, -27), Vector2(25, -27), Vector2(25, 27), Vector2(-25, 27),
	])
	frame.color = Color(0.18, 0.11, 0.07, 1.0)
	parent.add_child(frame)
	var light := Polygon2D.new()
	light.position = window_position
	light.polygon = PackedVector2Array([
		Vector2(-18, -20), Vector2(18, -20), Vector2(18, 20), Vector2(-18, 20),
	])
	light.color = Color(0.95, 0.62, 0.22, 0.92)
	parent.add_child(light)
	_lantern_glows.append(light)


func _add_lantern(parent: Node, lantern_position: Vector2) -> void:
	var post := Line2D.new()
	post.points = PackedVector2Array([lantern_position + Vector2(0, 42), lantern_position + Vector2(0, -16)])
	post.width = 5.0
	post.default_color = Color(0.18, 0.12, 0.08, 1.0)
	parent.add_child(post)
	var glow := Polygon2D.new()
	glow.position = lantern_position
	glow.polygon = PackedVector2Array([
		Vector2(0, -12), Vector2(9, -4), Vector2(7, 10), Vector2(0, 15),
		Vector2(-7, 10), Vector2(-9, -4),
	])
	glow.color = Color(1.0, 0.61, 0.18, 0.88)
	parent.add_child(glow)
	_lantern_glows.append(glow)


func _add_well(parent: Node, well_position: Vector2) -> void:
	var well := Node2D.new()
	well.position = well_position
	parent.add_child(well)
	_add_polygon(well, PackedVector2Array([
		Vector2(-45, 0), Vector2(-52, -25), Vector2(-38, -45),
		Vector2(38, -45), Vector2(52, -25), Vector2(45, 0),
	]), Color(0.34, 0.34, 0.30, 1.0))
	var roof := Polygon2D.new()
	roof.polygon = PackedVector2Array([
		Vector2(-62, -78), Vector2(0, -112), Vector2(62, -78), Vector2(48, -64), Vector2(-48, -64),
	])
	roof.color = Color(0.28, 0.14, 0.085, 1.0)
	well.add_child(roof)
	for x in [-43.0, 43.0]:
		var post := Line2D.new()
		post.points = PackedVector2Array([Vector2(x, -12), Vector2(x, -78)])
		post.width = 6.0
		post.default_color = Color(0.22, 0.13, 0.08, 1.0)
		well.add_child(post)


func _add_gate_details(parent: Node, gate_position: Vector2) -> void:
	var gate := Node2D.new()
	gate.position = gate_position
	parent.add_child(gate)
	for x in [-66.0, 66.0]:
		_add_polygon(gate, PackedVector2Array([
			Vector2(x - 18, 0), Vector2(x - 20, -176), Vector2(x, -205),
			Vector2(x + 20, -176), Vector2(x + 18, 0),
		]), Color(0.31, 0.25, 0.19, 1.0))
	var lintel := Line2D.new()
	lintel.points = PackedVector2Array([Vector2(-78, -172), Vector2(78, -172)])
	lintel.width = 14.0
	lintel.default_color = Color(0.24, 0.14, 0.08, 1.0)
	gate.add_child(lintel)
	_banner = Polygon2D.new()
	_banner.position = Vector2(0, -165)
	_banner.polygon = PackedVector2Array([
		Vector2(-34, 0), Vector2(34, 0), Vector2(28, 72),
		Vector2(0, 58), Vector2(-28, 72),
	])
	_banner.color = Color(0.37, 0.12, 0.10, 0.96)
	gate.add_child(_banner)


func _add_distant_roof(parent: Node, x: float, base_y: float, width: float) -> void:
	_add_polygon(parent, PackedVector2Array([
		Vector2(x - width * 0.5, base_y), Vector2(x, base_y - width * 0.38),
		Vector2(x + width * 0.5, base_y), Vector2(x + width * 0.42, base_y + 80),
		Vector2(x - width * 0.42, base_y + 80),
	]), Color(0.12, 0.11, 0.10, 0.92))


func _style_existing_labels() -> void:
	var safety_label := get_parent().get_node_or_null("GameplayLayer/SafetyLabel") as Label
	if safety_label != null:
		UI.style_heading(safety_label, Color(0.90, 0.73, 0.40), 17)
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
