extends SceneTree

## READ-ONLY live HUD geometry dump at 1920×1080 reference presentation.
## Does not alter gameplay or UI construction — measures only.

const ELDERWOOD := "res://Project Chronicle/Scenes/World/Zones/elderwood.tscn"
const OUT_PATH := "res://ValidationCaptures/HudGeometryAudit/geometry_report.txt"

var _lines: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	await process_frame
	await process_frame

	var error := change_scene_to_file(ELDERWOOD)
	if error != OK:
		push_error("GEOMETRY AUDIT: failed to load Elderwood")
		quit(1)
		return
	await scene_changed
	for _i in range(10):
		await process_frame

	var vp := root.get_viewport()
	var vp_size := vp.get_visible_rect().size
	_log("=== PROJECT CHRONICLE — CLEAN HUD GEOMETRY AUDIT ===")
	_log("viewport_visible=%s" % vp_size)
	_log("window_size=%s" % DisplayServer.window_get_size())
	_log("stretch_mode=%s" % ProjectSettings.get_setting("display/window/stretch/mode"))
	_log("stretch_aspect=%s" % ProjectSettings.get_setting("display/window/stretch/aspect"))
	_log("ref_w=%s ref_h=%s" % [
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	])

	var hud := current_scene.get_node_or_null("GameHUD") as CanvasLayer
	if hud == null:
		push_error("GEOMETRY AUDIT: GameHUD missing")
		quit(1)
		return

	_log("")
	_log("=== ACTIVE UI ROOT ===")
	_log("scene=%s" % current_scene.scene_file_path)
	_log("hud_scene=res://Project Chronicle/Scenes/UI/game_hud.tscn")
	_log("root_node=%s type=%s layer=%s" % [hud.name, hud.get_class(), hud.layer])
	_log("USE_ORNAMENT_SKINS=%s" % ChronicleUITheme.USE_ORNAMENT_SKINS)

	_log("")
	_log("=== HIERARCHY ===")
	_dump_tree(hud, 0)

	_log("")
	_log("=== GEOMETRY TABLE (global rects) ===")
	_log("Element | X | Y | Width | Height | NodeType")

	var keys: Array[String] = [
		"TopLeft/ExpeditionPanel",
		"TopRight/QuestTracker",
		"BottomHUD",
		"BottomHUD/BottomColumn/HudRow/PlayerStatus",
		"BottomHUD/BottomColumn/HudRow/ActionBarShell",
		"BottomHUD/BottomColumn/HudRow/MenuButtons",
		"BottomHUD/BottomColumn/ExperienceBar",
		"OverlayLayer/ZoneBanner",
	]
	for path in keys:
		var node := hud.get_node_or_null(path) as Control
		if node == null:
			_log("%s | MISSING" % path)
			continue
		_emit_rect(path.get_file() if path.get_file() != "" else path, node)

	# Detailed sub-rects
	var expedition := hud.get_node("TopLeft/ExpeditionPanel") as PanelContainer
	var quest := hud.get_node("TopRight/QuestTracker") as PanelContainer
	var bottom := hud.get_node("BottomHUD") as Control
	var status := hud.get_node("BottomHUD/BottomColumn/HudRow/PlayerStatus") as PanelContainer
	var action := hud.get_node("BottomHUD/BottomColumn/HudRow/ActionBarShell") as PanelContainer
	var menu := hud.get_node("BottomHUD/BottomColumn/HudRow/MenuButtons") as PanelContainer
	var xp := hud.get_node("BottomHUD/BottomColumn/ExperienceBar") as Control

	_log("")
	_log("=== EXPEDITION PANEL DETAIL ===")
	_detail_panel(expedition)
	_log_child_rects(expedition)

	_log("")
	_log("=== QUEST TRACKER DETAIL ===")
	_detail_panel(quest)
	_log_child_rects(quest)

	_log("")
	_log("=== BOTTOM HUD GAPS ===")
	var sr := status.get_global_rect()
	var ar := action.get_global_rect()
	var mr := menu.get_global_rect()
	var xr := xp.get_global_rect()
	var br := bottom.get_global_rect()
	_log("BottomHUD rect=%s" % _fmt(br))
	_log("gap status->action = %.1f" % (ar.position.x - sr.end.x))
	_log("gap action->menu = %.1f" % (mr.position.x - ar.end.x))
	_log("gap islands_bottom->xp = %.1f" % (xr.position.y - maxf(sr.end.y, maxf(ar.end.y, mr.end.y))))
	_log("HudRow separation theme=%s" % bottom.get_node("BottomColumn/HudRow").get_theme_constant("separation"))
	_log("BottomColumn separation theme=%s" % bottom.get_node("BottomColumn").get_theme_constant("separation"))

	_log("")
	_log("=== PLAYER STATUS DETAIL ===")
	_detail_panel(status)
	var level := _find_named(status, "Label") # first heading may be unnamed
	for child in _all_controls(status):
		_emit_rect(child.name if str(child.name) != "" else child.get_class(), child)
	var hp := status.find_child("HPBar", true, false) as Control
	var steadfast := status.find_child("SteadfastBar", true, false) as Control
	if hp != null:
		_log("HPBar outer=%s" % _fmt(hp.get_global_rect()))
		_log("HPBar thickness(h)=%.1f" % hp.get_global_rect().size.y)
	if steadfast != null:
		_log("SteadfastBar outer=%s" % _fmt(steadfast.get_global_rect()))
		_log("SteadfastBar thickness(h)=%.1f" % steadfast.get_global_rect().size.y)

	_log("")
	_log("=== ACTION BAR DETAIL ===")
	_detail_panel(action)
	var bar := action.get_node("ActionBar") as HBoxContainer
	_log("ActionBar separation=%s child_count=%s" % [bar.get_theme_constant("separation"), bar.get_child_count()])
	var slot_index := 0
	var prev_end := -1.0
	for child in bar.get_children():
		if child is Control:
			var c := child as Control
			var r := c.get_global_rect()
			_log("slot[%d] name=%s rect=%s assigned_meta=%s" % [
				slot_index, c.name, _fmt(r), str(c.get_meta("assigned", false))
			])
			if prev_end >= 0.0:
				_log("  gap_from_prev=%.1f" % (r.position.x - prev_end))
			prev_end = r.end.x
			var icon_stack := c.find_child("IconStack", true, false) as Control
			var keybind := c.find_child("Keybind", true, false) as Control
			var cooldown := c.find_child("CooldownLabel", true, false) as Control
			var lock := c.find_child("LockOverlay", true, false) as Control
			var icon := c.find_child("Icon", true, false) as TextureRect
			if icon_stack != null:
				_log("  IconStack=%s" % _fmt(icon_stack.get_global_rect()))
			if keybind != null:
				_log("  Keybind=%s text='%s'" % [_fmt(keybind.get_global_rect()), keybind.text if keybind is Label else ""])
			if cooldown != null:
				_log("  CooldownLabel present visible=%s" % cooldown.visible)
			if lock != null:
				_log("  LockOverlay present visible=%s" % lock.visible)
			if icon != null:
				_log("  Icon visible=%s has_texture=%s" % [icon.visible, icon.texture != null])
			slot_index += 1

	_log("")
	_log("=== MENU BUTTONS DETAIL ===")
	_detail_panel(menu)
	var grid := menu.get_node("MenuGrid") as GridContainer
	_log("MenuGrid columns=%s h_sep=%s v_sep=%s" % [
		grid.columns,
		grid.get_theme_constant("h_separation"),
		grid.get_theme_constant("v_separation"),
	])
	var prev_btn: Control = null
	for child in grid.get_children():
		if child is Control:
			var b := child as Control
			_log("button name=%s text='%s' rect=%s min=%s" % [
				b.name,
				b.text if b is Button else "",
				_fmt(b.get_global_rect()),
				b.custom_minimum_size if b is Control else Vector2.ZERO,
			])
			if prev_btn != null:
				var pr := prev_btn.get_global_rect()
				var cr := b.get_global_rect()
				if is_equal_approx(pr.position.y, cr.position.y):
					_log("  h_gap=%.1f" % (cr.position.x - pr.end.x))
				else:
					_log("  v_gap=%.1f" % (cr.position.y - pr.end.y))
			prev_btn = b

	_log("")
	_log("=== XP AREA ===")
	_emit_rect("ExperienceBar", xp)
	var xp_bar := xp.find_child("XPBar", true, false) as Control
	if xp_bar != null:
		_log("XPBar=%s thickness=%.1f" % [_fmt(xp_bar.get_global_rect()), xp_bar.get_global_rect().size.y])

	_log("")
	_log("=== STYLE CONTENT MARGINS (authored) ===")
	_log_style("ExpeditionPanel", expedition)
	_log_style("QuestTracker", quest)
	_log_style("PlayerStatus", status)
	_log_style("ActionBarShell", action)
	_log_style("MenuButtons", menu)
	if bar.get_child_count() > 0 and bar.get_child(0) is PanelContainer:
		_log_style("ActionSlot0", bar.get_child(0) as PanelContainer)

	_log("")
	_log("=== PLAYER ART ===")
	var player := get_first_node_in_group("player")
	if player != null:
		var sprite := player.get_node_or_null("Visuals/BaseCharacter") as AnimatedSprite2D
		if sprite != null and sprite.sprite_frames != null:
			_log("sprite_frames=%s" % sprite.sprite_frames.resource_path)
			_log("visible=%s scale=%s" % [sprite.visible, sprite.scale])
			_log("animations=%s" % ",".join(sprite.sprite_frames.get_animation_names()))
		else:
			_log("sprite missing")
	else:
		_log("player missing")

	_log("")
	_log("=== OLD ART LIVE DEPENDENCY CHECK ===")
	_log("runtime_texture(bottom_hud.png)=%s" % str(ChronicleUITheme.runtime_texture("bottom_hud.png")))
	_log("runtime_texture(panel_tracker_9.png)=%s" % str(ChronicleUITheme.runtime_texture("panel_tracker_9.png")))
	_log("runtime_texture(status_island_9.png)=%s" % str(ChronicleUITheme.runtime_texture("status_island_9.png")))
	_log("runtime_texture(menu_island_9.png)=%s" % str(ChronicleUITheme.runtime_texture("menu_island_9.png")))
	_log("runtime_texture(crest_ring.png)=%s" % str(ChronicleUITheme.runtime_texture("crest_ring.png")))
	_log("textured_style(any)=%s" % str(ChronicleUITheme.textured_style("bottom_hud.png")))
	var live_tex_hits := _scan_textures(hud)
	_log("live_hud_texture_paths_count=%d" % live_tex_hits.size())
	for p in live_tex_hits:
		_log("LIVE_TEX %s" % p)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://ValidationCaptures/HudGeometryAudit"))
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(_lines))
		f.close()
		print("GEOMETRY AUDIT WROTE: ", ProjectSettings.globalize_path(OUT_PATH))
	for line in _lines:
		print(line)
	print("GEOMETRY AUDIT: PASS")
	quit(0)


func _detail_panel(panel: PanelContainer) -> void:
	var r := panel.get_global_rect()
	_log("name=%s type=%s rect=%s min=%s anchors LTRB=%.3f,%.3f,%.3f,%.3f offsets LTRB=%.1f,%.1f,%.1f,%.1f grow_h=%s grow_v=%s" % [
		panel.name, panel.get_class(), _fmt(r), panel.custom_minimum_size,
		panel.anchor_left, panel.anchor_top, panel.anchor_right, panel.anchor_bottom,
		panel.offset_left, panel.offset_top, panel.offset_right, panel.offset_bottom,
		panel.grow_horizontal, panel.grow_vertical,
	])
	var style := panel.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		var flat := style as StyleBoxFlat
		_log("bg=StyleBoxFlat content_margins LTRB=%.1f,%.1f,%.1f,%.1f border=%d corner=%d" % [
			flat.content_margin_left, flat.content_margin_top, flat.content_margin_right, flat.content_margin_bottom,
			flat.border_width_left, flat.corner_radius_top_left,
		])
	elif style is StyleBoxTexture:
		_log("bg=StyleBoxTexture (UNEXPECTED for clean reset)")
	else:
		_log("bg=%s" % (style.get_class() if style else "null"))


func _log_style(label: String, panel: PanelContainer) -> void:
	var style := panel.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		var flat := style as StyleBoxFlat
		_log("%s StyleBoxFlat margins LTRB=%.1f,%.1f,%.1f,%.1f" % [
			label, flat.content_margin_left, flat.content_margin_top, flat.content_margin_right, flat.content_margin_bottom
		])
	else:
		_log("%s style=%s" % [label, style])


func _log_child_rects(root_ctrl: Control) -> void:
	for child in _all_controls(root_ctrl):
		if child == root_ctrl:
			continue
		_emit_rect("%s/%s" % [root_ctrl.name, child.name], child)


func _emit_rect(label: String, node: Control) -> void:
	var r := node.get_global_rect()
	_log("%s | %.1f | %.1f | %.1f | %.1f | %s" % [
		label, r.position.x, r.position.y, r.size.x, r.size.y, node.get_class()
	])


func _dump_tree(node: Node, depth: int) -> void:
	var indent := "  ".repeat(depth)
	var extra := ""
	if node is Control:
		var c := node as Control
		extra = " %s" % _fmt(c.get_global_rect())
	_log("%s- %s (%s)%s" % [indent, node.name, node.get_class(), extra])
	for child in node.get_children():
		_dump_tree(child, depth + 1)


func _all_controls(root_ctrl: Node) -> Array[Control]:
	var out: Array[Control] = []
	_collect_controls(root_ctrl, out)
	return out


func _collect_controls(node: Node, out: Array[Control]) -> void:
	if node is Control:
		out.append(node as Control)
	for child in node.get_children():
		_collect_controls(child, out)


func _find_named(_root: Node, _cls: String) -> Control:
	return null


func _scan_textures(node: Node) -> PackedStringArray:
	var hits: PackedStringArray = []
	_scan_textures_recursive(node, hits)
	return hits


func _scan_textures_recursive(node: Node, hits: PackedStringArray) -> void:
	if node is TextureRect:
		var tr := node as TextureRect
		if tr.texture != null:
			var path := tr.texture.resource_path
			if path.is_empty() and tr.texture is AtlasTexture:
				var atlas := (tr.texture as AtlasTexture).atlas
				if atlas != null:
					path = atlas.resource_path
			if not path.is_empty():
				hits.append("%s -> %s" % [str(node.get_path()), path])
	for child in node.get_children():
		_scan_textures_recursive(child, hits)


func _fmt(r: Rect2) -> String:
	return "x=%.1f y=%.1f w=%.1f h=%.1f" % [r.position.x, r.position.y, r.size.x, r.size.y]


func _log(line: String) -> void:
	_lines.append(line)
