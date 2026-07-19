extends Camera3D

@export var output_path := "user://spritesheet.png"
@export var directions := 4
@export var rotation_center: Node3D
@export var capture_viewport: SubViewport
@export var frame_2d: Line2D
var angles: PackedFloat32Array
var current_angle := 0


func _ready() -> void:
	var step := 360.0 / directions
	var angle := 0.0
	for _dir in range(directions):
		angles.append(angle)
		angle += step
	print(angles)


func _input(e: InputEvent) -> void:
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
	await RenderingServer.frame_post_draw
	# setup sheet
	var first := capture_viewport.get_texture().get_image()
	var frame_width := first.get_width()
	var frame_height := first.get_height()
	var sheet := Image.create(frame_width * directions, frame_height, false, Image.FORMAT_RGBA8)
	#
	for i in directions:
		rotation_center.rotation_degrees.y = angles[i]
		await RenderingServer.frame_post_draw # Wait until this rotation has actually rendered.
		var img := capture_viewport.get_texture().get_image()
		sheet.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(i * frame_width, 0))
	#
	var err := sheet.save_png(output_path)
	if err == OK: print("Saved spritesheet to: ", ProjectSettings.globalize_path(output_path))
	else: push_error("Failed to save spritesheet.")
	#
	current_angle = 0
	rotation_center.rotation_degrees.y = angles[current_angle]
