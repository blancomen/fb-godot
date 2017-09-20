extends Node2D

var hover_item = -1
var mouse_in_area = false

var tap_screen_event = false
var tap_pos = false

var tap_time_for_move = 0.1 #sec
var tap_time_for_move_current = 0
var moved_item
var moved_item_offset = Vector2()

func _ready():
	set_process(true)
	set_process_input(true)
	
func _input(event):
	#if event.type == InputEvent.MOUSE_BUTTON:
	#	if event.button_index == BUTTON_LEFT && event.pressed:
	#		if hover_item != -1:
	#			var item = get_parent().get_item(hover_item)
	#			if typeof(item) != TYPE_NIL:
	#				get_parent().unit.set_right_hand(item)
	
	if (event.type == InputEvent.SCREEN_TOUCH):
		if (event.pressed):
			tap_screen_event = true
			hover_item = get_hover_item(event.pos)
			tap_pos = event.pos
		else:
			tap_screen_event = false
			tap_time_for_move_current = 0
		update()
	
	
func _process(delta):
	var mouse_p = get_viewport().get_mouse_pos()
	
	if tap_screen_event:
		if !moved_item:
			if tap_time_for_move_current < tap_time_for_move:
				# Wait before move
				tap_time_for_move_current += delta
			else:
				if hover_item != -1:
					# Set moved item
					moved_item = get_parent().get_item(hover_item)
					get_parent().unit.get_node("items_radius").open()
		else:
			# move item to cursor
			moved_item.set_global_pos(mouse_p - moved_item_offset)
			hover_item = get_hover_item(mouse_p)
			update()
	else:
		if moved_item:
			# Drop item
			var item_radius = get_parent().unit.get_node("items_radius")
			
			if hover_item != -1:
				get_parent().move_item(moved_item.inventory_index, hover_item)
			else:
				get_parent().move_item(moved_item.inventory_index, moved_item.inventory_index)
				if item_radius.mouse_in_radius():
					get_parent().unit.set_right_hand(moved_item)
					
			moved_item = null
			get_parent().unit.get_node("items_radius").close()
	
func get_hover_item(mouse_p):
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
		
		if xy.x < 0 || xy.y < 0 || xy.x > cols-1 || xy.y > rows-1:
			return -1
		
		return int(get_parent().xy_to_i(xy))
	else:
		return -1
	
func _draw():
	if hover_item != -1:
		var scale = get_parent().get_scale()
		var pos = get_parent().get_cell_position(int(hover_item))
		draw_rect(Rect2(pos + Vector2(2, 2) * scale, get_parent().item_size - Vector2(4, 4) * scale), Color(255, 0, 0, 0.5))

func _on_items_area_mouse_enter():
	mouse_in_area = true

func _on_items_area_mouse_exit():
	mouse_in_area = false
