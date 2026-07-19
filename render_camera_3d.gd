@tool
extends Camera3D

@export var output_path := "user://spritesheet.png"
@export var directions := 4
@export var model_anim_player: AnimationPlayer
@export var anims_to_render: Array[AnimRenderConfig]
@export var frame_delay := 0.0
@export_subgroup("Nodes")
@export var rotation_center: Node3D
@export var capture_viewport: SubViewport
@export var frame_2d: Line2D
var angles: PackedFloat32Array
var current_angle := 0


func _ready() -> void:
	if Engine.is_editor_hint(): return
	var step := 360.0 / directions
	var angle := 0.0
	for _dir in range(directions):
		angles.append(angle)
		angle += step
	print(angles)


func _input(e: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if e is InputEventKey:
		if e.echo: return
		if e.pressed:
			match e.keycode:
				KEY_LEFT:
					current_angle = posmod(current_angle + 1, angles.size())
					rotation_center.rotation_degrees.y = angles[current_angle]
				KEY_RIGHT:
					current_angle = posmod(current_angle - 1, angles.size())
					rotation_center.rotation_degrees.y = angles[current_angle]
				KEY_S:
					create_spritesheet()


func create_spritesheet() -> void:
	if anims_to_render.size() > 0:
		for anim in anims_to_render:
			_create_spritesheet_animated(anim)
	else:
		_create_spritesheet_no_animation()


func _create_spritesheet_no_animation() -> void:
	# setup sheet
	var frame_size := Vector2i(frame_2d.points[2] - frame_2d.points[0])
	print(frame_2d.points[2], " - ", frame_2d.points[1], " = ", frame_size)
	var sheet := Image.create(frame_size.x * directions, frame_size.y, false, Image.FORMAT_RGBA8)
	# render loop
	for dir in directions:
		rotation_center.rotation_degrees.y = angles[dir]
		await RenderingServer.frame_post_draw # Wait until this rotation has actually rendered.
		var img := capture_viewport.get_texture().get_image()
		sheet.blit_rect(img, Rect2i(frame_2d.points[0], frame_size), Vector2i(dir * frame_size.x, 0))
		if frame_delay > 0: await get_tree().create_timer(frame_delay).timeout
	# save file
	var err := sheet.save_png(output_path)
	if err == OK: print("Saved spritesheet to: ", ProjectSettings.globalize_path(output_path))
	else: push_error("Failed to save spritesheet.")
	# reset scene
	current_angle = 0
	rotation_center.rotation_degrees.y = angles[current_angle]


func _create_spritesheet_animated(ac:AnimRenderConfig) -> void:
	var frame_count := ac.frames_to_capture
	if frame_count <= 1: return
	# setup sheet
	if ac.frame_override:
		printerr("frame_override not implemented") # TODO
		return
	var frame_size := Vector2i(frame_2d.points[2] - frame_2d.points[0])
	print(frame_2d.points[2], " - ", frame_2d.points[1], " = ", frame_size)
	var sheet := Image.create(frame_size.x * frame_count, frame_size.y * directions, false, Image.FORMAT_RGBA8)
	var anim_length := model_anim_player.get_animation(ac.anim_name).length
	model_anim_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	model_anim_player.play(ac.anim_name)
	# render loop
	for dir in range(directions):
		print("rendering direction ", dir)
		for frame_idx in range(frame_count):
			var frame_time_idx: float
			#if frame_idx == 0: frame_time_idx = 0
			#else: frame_time_idx = anim_length / (frame_count-1) * frame_idx
			frame_time_idx = anim_length / (float)(frame_count) * frame_idx
			rotation_center.rotation_degrees.y = angles[dir]
			model_anim_player.seek(frame_time_idx, true)
			print("frame ", frame_idx, " at ", frame_time_idx)
			await RenderingServer.frame_post_draw # Wait until this rotation has actually rendered.
			var img := capture_viewport.get_texture().get_image()
			sheet.blit_rect(img, Rect2i(frame_2d.points[0], frame_size), Vector2i(frame_idx * frame_size.x, dir * frame_size.y))
			if frame_delay > 0: await get_tree().create_timer(frame_delay).timeout
	# save file
	var err := sheet.save_png(output_path)
	if err == OK: print("Saved spritesheet to: ", ProjectSettings.globalize_path(output_path))
	else: push_error("Failed to save spritesheet.")
	# reset scene
	current_angle = 0
	rotation_center.rotation_degrees.y = angles[current_angle]
