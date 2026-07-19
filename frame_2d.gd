extends Line2D

@export var pos_button: Button
@export var end_button: Button
var dragging := 0


func _ready() -> void:
	pos_button.keep_pressed_outside = true
	pos_button.button_down.connect(func(): dragging = 1)
	pos_button.button_up.connect(func(): dragging = 0)
	end_button.keep_pressed_outside = true
	end_button.button_down.connect(func(): dragging = 2)
	end_button.button_up.connect(func(): dragging = 0)
	
	var p := points
	var c1 := pos_button.position + pos_button.size/2
	var c2 := end_button.position + end_button.size/2
	p[0] = c1
	p[1] = Vector2(c2.x, c1.y)
	p[2] = c2
	p[3] = Vector2(c1.x, c2.y)
	points = p


func _process(_delta: float) -> void:
	if dragging == 0: return
	var p := points
	if dragging == 1:
		var center := pos_button.position + pos_button.size/2
		p[0] = center
		p[1].y = center.y
		p[3].x = center.x
	elif dragging == 2:
		var center := end_button.position + end_button.size/2
		p[1].x = center.x
		p[2] = center
		p[3].y = center.y
	points = p


func _input(event: InputEvent) -> void:
	if dragging == 0: return
	if event is InputEventMouseMotion:
		if dragging == 1: pos_button.position += event.relative
		elif dragging == 2: end_button.position += event.relative
