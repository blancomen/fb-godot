extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process(true)
	
	
func _process(delta):
	var mouse_p = get_viewport().get_mouse_pos()
	var hud_offset = get_parent().hud_offset
	var item_size = get_parent().item_size
	var border_size = get_parent().border_size
	var rows = get_parent().rows
	var cols = get_parent().columns
	
	var parent_pos = get_parent().get_parent().get_pos()
	var hud_p = Vector2(parent_pos.x + hud_offset.x, parent_pos.y + hud_offset.y)
	var hud_size = Vector2(
		item_size.x * cols + (cols) * border_size, 
		item_size.y * rows + (rows) * border_size
	)

	if mouse_p.x > hud_p.x && mouse_p.y > hud_p.y && mouse_p.x < hud_p.x + hud_size.x && mouse_p.y < hud_p.y + hud_size.y:
		var xy = Vector2(
			(mouse_p.x - hud_p.x),
			(mouse_p.y - hud_p.y)
		)
		
		print("On", xy)
	else:
		print("No On")
	
	update()
	
func _draw():
	var p = get_viewport().get_mouse_pos()
	draw_circle(p, 5, Color(255, 0, 0))