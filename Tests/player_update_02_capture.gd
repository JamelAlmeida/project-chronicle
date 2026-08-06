extends SceneTree

## Captures standing / prone / airborne / hurt / defeated frames for Player Update 02 report.
const OUT_DIR := "res://Project Chronicle/ValidationCaptures/PlayerUpdate02"
const PLAYER_SCENE := preload("res://Project Chronicle/Scenes/Characters/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUT_DIR)
	)

	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 2
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(800, 24)
	floor_shape.shape = floor_rect
	floor_shape.position = Vector2(0, 12)
	floor_body.add_child(floor_shape)
	root.add_child(floor_body)

	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.14, 0.16, 1.0)
	bg.size = Vector2(960, 540)
	bg.position = Vector2(-480, -320)
	root.add_child(bg)

	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	root.add_child(player)
	player.global_position = Vector2(0, -50)
	player.collision_mask = 2
	var camera := player.get_node("Camera2D") as Camera2D
	if camera != null:
		camera.enabled = true
		camera.make_current()
		camera.zoom = Vector2(2.4, 2.4)

	for _i in range(30):
		await physics_frame

	var sprite := player.get_node("Visuals/BaseCharacter") as AnimatedSprite2D
	await _capture("01_standing_idle")

	Input.action_press("move_down")
	for _i in range(8):
		await physics_frame
	await _capture("02_prone")
	Input.action_release("move_down")
	for _i in range(8):
		await physics_frame

	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for _i in range(4):
		await physics_frame
	await _capture("03_airborne")
	for _i in range(40):
		await physics_frame
		if player.is_on_floor():
			break

	player.call("_on_damaged", 1, 10)
	await process_frame
	await _capture("04_hurt")
	for _i in range(20):
		await physics_frame

	player.set("_is_dead", true)
	player.get_node("Visuals/VisualController").update_presentation(
		true, false, false, false, Vector2.ZERO, Vector2.RIGHT, true, false, false
	)
	await process_frame
	await _capture("05_defeated")

	print("PLAYER UPDATE 02 CAPTURES WRITTEN TO %s" % OUT_DIR)
	print("Sprite animation now: %s" % String(sprite.animation))
	quit(0)


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	var img := get_root().get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [OUT_DIR, name]
	var err := img.save_png(path)
	if err != OK:
		push_error("Failed to save %s (%s)" % [path, str(err)])
	else:
		print("Wrote %s" % path)
