extends Node2D

var select_item = -1
var mouse_in_area = false

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
	var scale = get_parent().get_scale()
	var hud_offset = get_parent().hud_offset * scale
	var item_size = get_parent().item_size * scale
	var rows = get_parent().rows
	var cols = get_parent().columns
	
	
	var parent_pos = get_parent().get_parent().get_pos()
	var hud_p = Vector2(parent_pos.x + hud_offset.x + 2, parent_pos.y + hud_offset.y + 2)

	if mouse_in_area:
		var xy = Vector2(
			ceil((mouse_p.x - hud_p.x) / (item_size.x)) - 1,
			ceil((mouse_p.y - hud_p.y) / (item_size.y)) - 1
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
		var scale = get_parent().get_scale()
		var pos = get_parent().get_cell_position(int(select_item))
		draw_rect(Rect2(pos + Vector2(2, 2) * scale, get_parent().item_size - Vector2(4, 4) * scale), Color(255, 0, 0, 0.5))

func _on_items_area_mouse_enter():
	mouse_in_area = true

func _on_items_area_mouse_exit():
	mouse_in_area = false
