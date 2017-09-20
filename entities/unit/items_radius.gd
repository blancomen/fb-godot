extends Node2D

export var radius = 40
export var radius_current = 0
var radius_speed = 150
var is_open = false

var color_out = Color(0.9, 0.6, 0.36, 0.7)
var color_in = Color(0.6, 0.9, 0.36, 0.7)

func _ready():
	set_process(true)

func open():
	is_open = true
	
func close():
	is_open = false
	radius_current = 0
	update()

func mouse_in_radius():
	var mouse_pos = get_global_mouse_pos()
	return get_parent().get_pos().distance_to(mouse_pos) <= radius

func _process(delta):
	if is_open && radius_current < radius:
		radius_current += radius_speed * delta
		
	if is_open:
		update()
	
func _draw():
	var color  = color_out
	if is_open:
		if mouse_in_radius():
			color = color_in
		else:
			color = color_out

	draw_circle(Vector2(), radius_current, color)