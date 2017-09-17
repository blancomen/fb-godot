extends Node2D

var select_item = -1

func _ready():
	set_process(true)
	set_process_input(true)
	
func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if select_item != -1:
				var item = get_parent().get_item(select_item)
				if typeof(item) != TYPE_NIL:
					get_parent().unit.set_right_hand(item)
				
	
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
		item_size.x * cols + (cols - 1) * border_size, 
		item_size.y * rows + (rows - 1) * border_size
	)

	if mouse_p.x > hud_p.x && mouse_p.y > hud_p.y && mouse_p.x < hud_p.x + hud_size.x && mouse_p.y < hud_p.y + hud_size.y:
		var xy = Vector2(
			ceil((mouse_p.x - hud_p.x) / item_size.x) - 1,
			ceil((mouse_p.y - hud_p.y) / item_size.y) - 1
		)
		
		if xy.x < 0:
			xy.x = 0
		
		if xy.y < 0:
			xy.y = 0
		
		if xy.x > cols:
			xy.x = cols
			
		if xy.y > rows:
			xy.y = rows
		
		select_item = int(get_parent().xy_to_i(xy))
	else:
		select_item = -1
	
	update()
	
func _draw():
	if select_item != -1:
		var pos = get_parent().get_cell_position(int(select_item))
		draw_rect(Rect2(pos, get_parent().item_size), Color(255, 0, 0))